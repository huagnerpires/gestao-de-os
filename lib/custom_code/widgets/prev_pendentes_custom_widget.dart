// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'index.dart'; // Imports other custom widgets

// ============================================================
//  CUSTOM WIDGET — PREVENTIVAS PENDENTES v11.5
//  ✅ Comparação SOMENTE por campo PATRIMONIO
//  ✅ FILTRO: Somente EQUIPAMENTOS_EMPRESA com CONTRATO = true
//  ✅ DIAGNÓSTICO: Mostra PAT, SETOR e SALA na lista
//  ✅ Barra de pesquisa busca por: patrimônio, email, setor, sala, equip
//  ✅ Patrimônio em destaque nos cards
//  ✅ Sem gradiente - cores do tema (claro/escuro)
//  ✅ Lista agrupada por categoria com contagem
//  ✅ Badges de categoria com cores sólidas (feitos/total/pend)
//  ✅ Chips sobrios (sem cores fortes)
//  ✅ 100% cores do tema do app
//  ✅ Badge laranja "PENDÊNCIA ABERTA" quando existir doc em PENDENCIAS
//  ✅ Ao clicar no card abre CadastrarPreventivaWidget como bottom sheet
//     com PATRIMONIO preenchido e busca automática disparada
//  ✅ Botão para visualizar imagem grande do equipamento
// ============================================================

import 'package:cloud_firestore/cloud_firestore.dart';

class PrevPendentesCustomWidget extends StatefulWidget {
  const PrevPendentesCustomWidget({
    Key? key,
    this.width,
    this.height,
  }) : super(key: key);

  final double? width;
  final double? height;

  @override
  State<PrevPendentesCustomWidget> createState() => _PrevPendentesCustomState();
}

class _PrevPendentesCustomState extends State<PrevPendentesCustomWidget> {
  // ─────────────────────────────────────────────────────────
  //  HELPERS DE TEMA
  // ─────────────────────────────────────────────────────────
  ThemeData get _theme => Theme.of(context);
  ColorScheme get _cs => _theme.colorScheme;

  Color get _cardBg => const Color(0xFF131B2E);
  Color get _inputBg => const Color(0xFF0F172A);
  Color get _inputBorder => const Color(0xFF1E293B);

  Color get _headerBg => const Color(0xFF0B0F17);
  Color get _headerFg => Colors.white;

  Color get _textStrong => Colors.white;
  Color get _textSub => const Color(0xFF94A3B8);

  Color get _primary => const Color(0xFF3B82F6);
  Color get _danger => const Color(0xFFEF4444);

  // ─────────────────────────────────────────────────────────
  //  ESTADO
  // ─────────────────────────────────────────────────────────
  int? _selYear;
  int? _selMonth;
  String? _selEmail;

  List<int> _years = [];
  List<int> _months = [];
  List<String> _emails = [];

  bool _loadingFilters = true;
  bool _loadingResults = false;
  bool _showResults = false;

  Map<String, List<_PendingItem>> _grouped = {};
  List<String> _categories = [];

  Map<String, int> _totalEquipPorEmail = {};
  Map<String, int> _totalPreviPorEmail = {};
  Map<String, int> _totalTodosEquipPorEmail = {};
  Map<String, int> _totalTodasPreviPorEmail = {};
  Map<String, int> _totalEquipPorCat = {};

  int _totalPrevNoPeriodo = 0;

  Set<String> _pendenciasPatSet = {};
  Map<String, String> _imagensPorPat = {};

  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';

  // ─────────────────────────────────────────────────────────
  //  CONSTANTES PT-BR
  // ─────────────────────────────────────────────────────────
  static const List<String> _ptMonths = [
    '',
    'Janeiro',
    'Fevereiro',
    'Março',
    'Abril',
    'Maio',
    'Junho',
    'Julho',
    'Agosto',
    'Setembro',
    'Outubro',
    'Novembro',
    'Dezembro',
  ];

  static const Map<String, int> _ptMonthMap = {
    'janeiro': 1,
    'fevereiro': 2,
    'março': 3,
    'marco': 3,
    'abril': 4,
    'maio': 5,
    'junho': 6,
    'julho': 7,
    'agosto': 8,
    'setembro': 9,
    'outubro': 10,
    'novembro': 11,
    'dezembro': 12,
  };

  // ═══════════════════════════════════════════════════════
  @override
  void initState() {
    super.initState();
    _loadFilters();
    _searchCtrl.addListener(() {
      setState(() => _searchQuery = _searchCtrl.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _reset() {
    _searchCtrl.clear();
    setState(() {
      _showResults = false;
      _grouped = {};
      _categories = [];
      _selEmail = null;
      _loadingResults = false;
      _searchQuery = '';
      _totalEquipPorEmail = {};
      _totalPreviPorEmail = {};
      _totalTodosEquipPorEmail = {};
      _totalTodasPreviPorEmail = {};
      _totalEquipPorCat = {};
      _totalPrevNoPeriodo = 0;
      _pendenciasPatSet = {};
      _imagensPorPat = {};
    });
  }

  // ─────────────────────────────────────────────────────────
  //  VISUALIZADOR DE IMAGEM GRANDE
  // ─────────────────────────────────────────────────────────
  void _abrirImagemGrande(BuildContext context, String imgUrl, String pat) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withAlpha(220),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(12),
        child: Stack(
          children: [
            // Imagem com InteractiveViewer para zoom/pan
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: InteractiveViewer(
                  minScale: 0.8,
                  maxScale: 5.0,
                  child: Image.network(
                    imgUrl,
                    fit: BoxFit.contain,
                    loadingBuilder: (_, child, progress) => progress == null
                        ? child
                        : Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              color: Colors.black.withAlpha(180),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(
                                  value: progress.expectedTotalBytes != null
                                      ? progress.cumulativeBytesLoaded /
                                          progress.expectedTotalBytes!
                                      : null,
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'Carregando imagem...',
                                  style: TextStyle(
                                      color: Colors.white70, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                    errorBuilder: (_, __, ___) => Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(180),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.broken_image_outlined,
                              color: Colors.white54, size: 48),
                          SizedBox(height: 10),
                          Text(
                            'Erro ao carregar imagem',
                            style:
                                TextStyle(color: Colors.white54, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Botão fechar (canto superior direito)
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () => Navigator.of(ctx).pop(),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(180),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close_rounded,
                      color: Colors.white, size: 20),
                ),
              ),
            ),

            // Badge PAT no canto inferior
            if (pat.isNotEmpty)
              Positioned(
                bottom: 16,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(180),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.qr_code_rounded,
                            size: 13, color: Colors.white),
                        const SizedBox(width: 6),
                        Text(
                          'PAT: $pat',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Hint de zoom
            Positioned(
              top: 16,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(130),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Pinça para dar zoom',
                    style: TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  //  CARREGA FILTROS
  // ─────────────────────────────────────────────────────────
  Future<void> _loadFilters() async {
    setState(() => _loadingFilters = true);
    try {
      final db = FirebaseFirestore.instance;
      final previDocs = (await db.collection('PREVENTIVAS').get()).docs;
      final Set<int> years = {};
      final Set<int> months = {};

      for (final doc in previDocs) {
        final d = doc.data();
        final ano = int.tryParse((d['ANO'] ?? '').toString());
        if (ano != null && ano > 2000) years.add(ano);
        final mes = (d['MES'] ?? '').toString().trim().toLowerCase();
        if (mes.isNotEmpty && _ptMonthMap.containsKey(mes)) {
          months.add(_ptMonthMap[mes]!);
        }
      }

      final userDocs = (await db.collection('USUARIOS').get()).docs;
      final Set<String> emailSet = {};
      for (final doc in userDocs) {
        final d = doc.data();
        final e = (d['email'] ?? d['EMAIL'] ?? '').toString().trim();
        if (e.isNotEmpty) emailSet.add(e);
      }

      setState(() {
        _years = years.toList()..sort((a, b) => b.compareTo(a));
        _months = months.toList()..sort();
        _emails = emailSet.toList()
          ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
        _selYear = _years.isNotEmpty ? _years.first : null;
        _selMonth = _months.isNotEmpty ? _months.first : null;
        _loadingFilters = false;
      });
    } catch (e) {
      setState(() => _loadingFilters = false);
      _snack('Erro ao carregar filtros: $e');
    }
  }

  // ─────────────────────────────────────────────────────────
  //  DIAGNÓSTICO
  // ─────────────────────────────────────────────────────────
  Future<void> _diagnostico() async {
    if (_selYear == null || _selMonth == null) {
      _snack('Selecione o ano e o mês primeiro.');
      return;
    }

    setState(() => _loadingResults = true);

    try {
      final db = FirebaseFirestore.instance;
      final lines = <_DiagLine>[];

      void header(String t) => lines.add(_DiagLine(t, _DiagType.header));
      void ok(String t) => lines.add(_DiagLine(t, _DiagType.ok));
      void warn(String t) => lines.add(_DiagLine(t, _DiagType.warning));
      void info(String t) => lines.add(_DiagLine(t, _DiagType.info));
      void detail(String t) => lines.add(_DiagLine(t, _DiagType.detail));
      void space() => lines.add(_DiagLine('', _DiagType.info));

      Query<Map<String, dynamic>> q = db
          .collection('EQUIPAMENTOS_EMPRESA')
          .where('CONTRATO', isEqualTo: true);

      if (_selEmail != null && _selEmail!.isNotEmpty) {
        q = q.where('EMAIL', isEqualTo: _selEmail);
      }
      final equipDocs = (await q.get()).docs;

      final Map<String, List<Map<String, dynamic>>> equipPorPat = {};
      int equipSemPat = 0;

      for (final doc in equipDocs) {
        final d = doc.data();
        final pat = _patrimonioNorm(d);
        if (pat.isEmpty) {
          equipSemPat++;
        } else {
          equipPorPat.putIfAbsent(pat, () => []).add({
            'docId': doc.id,
            'EMAIL': d['EMAIL'] ?? '',
            'EQUIPAMENTO': d['TIPOEQUIPAMENTO'] ??
                d['EQUIPAMENTO'] ??
                d['NOMEEQUIPAMENTO'] ??
                d['nome'] ??
                '',
            'SETOR': d['SETOR'] ?? '',
            'SALA': d['SALA'] ?? d['LOCAL'] ?? '',
            'PATRIMONIO': (d['PATRIMONIO'] ?? '').toString(),
            'BTUS': d['BTUS'] ?? '',
            'MARCA': d['MARCA'] ?? '',
          });
        }
      }

      header('EQUIPAMENTOS_EMPRESA (CONTRATO=TRUE)');
      info('Total docs: ${equipDocs.length}');
      info('Sem PATRIMONIO: $equipSemPat');
      info('Patrimônios únicos: ${equipPorPat.length}');

      final Map<String, int> catCount = {};
      for (final doc in equipDocs) {
        final d = doc.data();
        final cat = _s(
          d['TIPOEQUIPAMENTO'] ??
              d['EQUIPAMENTO'] ??
              d['NOMEEQUIPAMENTO'] ??
              d['nome'],
          'Outros',
        ).toUpperCase();
        catCount[cat] = (catCount[cat] ?? 0) + 1;
      }
      space();
      info('CATEGORIAS EM EQUIP (${catCount.length}):');
      final sortedCats = catCount.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      for (final c in sortedCats) {
        detail('  "${c.key}" → ${c.value} docs');
      }

      final equipDup =
          equipPorPat.entries.where((e) => e.value.length > 1).toList();
      if (equipDup.isNotEmpty) {
        space();
        warn('DUPLICADOS EM EQUIP_EMPRESA (${equipDup.length} patrimônios):');
        for (final dup in equipDup) {
          space();
          warn('PAT [${dup.key}] → ${dup.value.length} documentos:');
          for (int i = 0; i < dup.value.length; i++) {
            final doc = dup.value[i];
            detail('  📄 Doc ${i + 1}:');
            detail('     ID: ${doc['docId']}');
            detail('     Email: ${doc['EMAIL']}');
            detail('     Equip: ${doc['EQUIPAMENTO']}');
            detail('     Setor: ${doc['SETOR']}');
            detail('     Sala: ${doc['SALA']}');
            detail('     BTUs: ${doc['BTUS']}');
            detail('     Marca: ${doc['MARCA']}');
            detail('     Pat raw: "${doc['PATRIMONIO']}"');
          }
        }
      } else {
        ok('Nenhum patrimônio duplicado em EQUIP');
      }

      final String diagMesNome = _ptMonths[_selMonth!].toUpperCase();
      Query<Map<String, dynamic>> previQuery =
          db.collection('PREVENTIVAS').where('ANO', isEqualTo: _selYear);
      final previDocs = (await previQuery.get()).docs;

      final Map<String, List<Map<String, dynamic>>> previPorPat = {};
      int previNoPeriodo = 0;
      int previSemPat = 0;
      int previOutroMes = 0;

      for (final doc in previDocs) {
        final d = doc.data();
        final docMes = (d['MES'] ?? '').toString().trim().toUpperCase();
        if (docMes != diagMesNome) {
          previOutroMes++;
          continue;
        }

        previNoPeriodo++;
        final pat = _patrimonioNorm(d);

        if (pat.isEmpty) {
          previSemPat++;
        } else {
          previPorPat.putIfAbsent(pat, () => []).add({
            'docId': doc.id,
            'EMAIL': d['EMAIL'] ?? '',
            'EQUIPAMENTO': d['EQUIPAMENTO'] ?? d['NOME'] ?? '',
            'PATRIMONIO': (d['PATRIMONIO'] ?? '').toString(),
            'ANO': (d['ANO'] ?? '').toString(),
            'MES': (d['MES'] ?? '').toString(),
            'DATA': (d['DATADAMANUTENCAO'] ?? '').toString(),
            'SETOR': d['SETOR'] ?? '',
            'SALA': d['SALA'] ?? '',
            'RESPONSAVEL': d['RESPONSAVEL'] ?? d['TECNICORESPONSAVEL'] ?? '',
          });
        }
      }

      space();
      header('PREVENTIVAS (ANO=$_selYear, MES=$diagMesNome)');
      info('Total com ANO=$_selYear: ${previDocs.length}');
      info('Outro mês: $previOutroMes');
      info('No período: $previNoPeriodo');
      info('Sem patrimônio: $previSemPat');
      info('Patrimônios únicos: ${previPorPat.length}');

      final equipPats = equipPorPat.keys.toSet();
      final previPats = previPorPat.keys.toSet();
      final emAmbos = equipPats.intersection(previPats);
      final soEmEquip = equipPats.difference(previPats);
      final soEmPrevi = previPats.difference(equipPats);

      space();
      header('CRUZAMENTO');
      info('Em AMBAS (feitos): ${emAmbos.length}');
      info('Só EQUIP (pend c/ pat): ${soEmEquip.length}');
      info('Só PREV (órfãos): ${soEmPrevi.length}');

      setState(() => _loadingResults = false);

      if (!mounted) return;
      showDialog(
        context: context,
        builder: (ctx) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(12),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(ctx).size.height * 0.85,
            ),
            decoration: BoxDecoration(
              color: _cs.surface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 16, 8, 12),
                  decoration: BoxDecoration(
                    color: _danger.withAlpha(20),
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.bug_report_rounded, color: _danger, size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Diagnóstico — ${_ptMonths[_selMonth!]} / $_selYear',
                          style: TextStyle(
                            color: _textStrong,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(14),
                    itemCount: lines.length,
                    itemBuilder: (_, i) {
                      final line = lines[i];
                      Color color;
                      FontWeight weight;
                      double size;
                      switch (line.type) {
                        case _DiagType.header:
                          color = _primary;
                          weight = FontWeight.w800;
                          size = 14;
                          break;
                        case _DiagType.warning:
                          color = _danger;
                          weight = FontWeight.w700;
                          size = 12;
                          break;
                        case _DiagType.ok:
                          color = Colors.green;
                          weight = FontWeight.w700;
                          size = 12;
                          break;
                        case _DiagType.detail:
                          color = _textSub;
                          weight = FontWeight.w400;
                          size = 11;
                          break;
                        case _DiagType.info:
                        default:
                          color = _textStrong;
                          weight = FontWeight.w500;
                          size = 12;
                          break;
                      }
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: line.type == _DiagType.header ? 6 : 1,
                          top: line.type == _DiagType.header && i > 0 ? 14 : 0,
                        ),
                        child: line.text.isEmpty
                            ? const SizedBox(height: 6)
                            : Container(
                                padding: line.type == _DiagType.header
                                    ? const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 6)
                                    : null,
                                decoration: line.type == _DiagType.header
                                    ? BoxDecoration(
                                        color: _primary.withAlpha(25),
                                        borderRadius: BorderRadius.circular(8),
                                      )
                                    : null,
                                child: Text(
                                  line.type == _DiagType.header
                                      ? '═══ ${line.text} ═══'
                                      : line.type == _DiagType.ok
                                          ? '✅ ${line.text}'
                                          : line.type == _DiagType.warning
                                              ? '⚠️ ${line.text}'
                                              : line.text,
                                  style: TextStyle(
                                    fontSize: size,
                                    fontWeight: weight,
                                    color: color,
                                    fontFamily: 'monospace',
                                    height: 1.5,
                                  ),
                                ),
                              ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primary,
                        foregroundColor: _cs.onPrimary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Fechar',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      setState(() => _loadingResults = false);
      _snack('Erro no diagnóstico: $e');
    }
  }

  // ─────────────────────────────────────────────────────────
  //  BUSCA PENDENTES
  // ─────────────────────────────────────────────────────────
  Future<void> _buscar() async {
    if (_selYear == null || _selMonth == null) {
      _snack('Selecione o ano e o mês.');
      return;
    }
    setState(() {
      _loadingResults = true;
      _grouped = {};
      _categories = [];
    });

    try {
      final db = FirebaseFirestore.instance;

      Query<Map<String, dynamic>> q = db
          .collection('EQUIPAMENTOS_EMPRESA')
          .where('CONTRATO', isEqualTo: true);

      if (_selEmail != null && _selEmail!.isNotEmpty) {
        q = q.where('EMAIL', isEqualTo: _selEmail);
      }
      final equipDocs = (await q.get()).docs;

      final Set<String> feitosPatSet = {};
      int totalPrevNoPeriodo = 0;
      final String mesNome = _ptMonths[_selMonth!].toUpperCase();

      Query<Map<String, dynamic>> previQuery =
          db.collection('PREVENTIVAS').where('ANO', isEqualTo: _selYear);
      if (_selEmail != null && _selEmail!.isNotEmpty) {
        previQuery = previQuery.where('EMAIL', isEqualTo: _selEmail);
      }
      final previDocs = (await previQuery.get()).docs;

      for (final doc in previDocs) {
        final d = doc.data();
        final docMes = (d['MES'] ?? '').toString().trim().toUpperCase();
        if (docMes != mesNome) continue;
        totalPrevNoPeriodo++;
        final pat = _patrimonioNorm(d);
        if (pat.isNotEmpty) feitosPatSet.add(pat);
      }

      final Set<String> pendenciasPatSet = {};
      final inicioMes = Timestamp.fromDate(DateTime(_selYear!, _selMonth!, 1));
      final fimMes = Timestamp.fromDate(
        _selMonth! < 12
            ? DateTime(_selYear!, _selMonth! + 1, 1)
            : DateTime(_selYear! + 1, 1, 1),
      );

      final camposData = [
        'criadoEm',
        'timestampVisita',
        'dataVisita',
        'atualizadoEm'
      ];

      for (final campoData in camposData) {
        try {
          Query<Map<String, dynamic>> pendQuery = db
              .collection('PENDENCIAS')
              .where('resolvidoEm', isNull: true)
              .where(campoData, isGreaterThanOrEqualTo: inicioMes)
              .where(campoData, isLessThan: fimMes);

          if (_selEmail != null && _selEmail!.isNotEmpty) {
            pendQuery = pendQuery.where('emailPrincipal', isEqualTo: _selEmail);
          }

          final pendDocs = (await pendQuery.get()).docs;
          if (pendDocs.isNotEmpty) {
            for (final doc in pendDocs) {
              final pat = _norm((doc.data()['patrimonio'] ?? '').toString());
              if (pat.isNotEmpty) pendenciasPatSet.add(pat);
            }
            break;
          }
        } catch (e) {
          continue;
        }
      }

      if (pendenciasPatSet.isEmpty) {
        try {
          Query<Map<String, dynamic>> pendQuery =
              db.collection('PENDENCIAS').where('resolvidoEm', isNull: true);
          if (_selEmail != null && _selEmail!.isNotEmpty) {
            pendQuery = pendQuery.where('emailPrincipal', isEqualTo: _selEmail);
          }
          final pendDocs = (await pendQuery.get()).docs;
          final inicioMesDt = DateTime(_selYear!, _selMonth!, 1);
          final fimMesDt = _selMonth! < 12
              ? DateTime(_selYear!, _selMonth! + 1, 1)
              : DateTime(_selYear! + 1, 1, 1);

          for (final doc in pendDocs) {
            final d = doc.data();
            DateTime? dataDoc;
            for (final campo in camposData) {
              final raw = d[campo];
              if (raw is Timestamp) {
                dataDoc = raw.toDate().toLocal();
                break;
              }
            }
            final noMes = dataDoc == null ||
                (dataDoc.isAfter(
                        inicioMesDt.subtract(const Duration(seconds: 1))) &&
                    dataDoc.isBefore(fimMesDt));
            if (!noMes) continue;
            final pat = _norm((d['patrimonio'] ?? '').toString());
            if (pat.isNotEmpty) pendenciasPatSet.add(pat);
          }
        } catch (e) {
          debugPrint('📊 PENDENCIAS fallback falhou: $e');
        }
      }

      // ── IMAGENS ──
      final Set<String> todosPatrimonios = {};
      for (final doc in equipDocs) {
        final pat = _patrimonioNorm(doc.data());
        if (pat.isNotEmpty) todosPatrimonios.add(pat);
      }

      final Map<String, String> imagensPorPat = {};
      if (todosPatrimonios.isNotEmpty) {
        final patList = todosPatrimonios.toList();
        const loteSize = 30;
        final futures = <Future<QuerySnapshot<Map<String, dynamic>>>>[];
        for (int i = 0; i < patList.length; i += loteSize) {
          final lote = patList.sublist(
              i, i + loteSize > patList.length ? patList.length : i + loteSize);
          futures.add(db
              .collection('IMAGENS')
              .where('PATRIMONIO', whereIn: lote)
              .get());
        }
        final snapshots = await Future.wait(futures);
        for (final snap in snapshots) {
          for (final doc in snap.docs) {
            final d = doc.data();
            final pat = _norm((d['PATRIMONIO'] ?? '').toString());
            if (pat.isEmpty) continue;
            final url = (d['IMAGEM'] ??
                    d['imagem'] ??
                    d['URL'] ??
                    d['url'] ??
                    d['IMAGE'] ??
                    '')
                .toString()
                .trim();
            if (url.startsWith('http')) imagensPorPat[pat] = url;
          }
        }
      }

      // ── Classifica ──
      final Set<String> patConsumido = {};
      final List<_PendingItem> pendentes = [];
      int feitosCount = 0;

      final Map<String, int> totalEquipPorEmail = {};
      final Map<String, int> totalTodosEquipPorEmail = {};
      final Map<String, int> totalPreviPorEmail = {};
      final Map<String, int> totalTodasPreviPorEmail = {};
      final Map<String, int> totalEquipPorCat = {};

      for (final doc in equipDocs) {
        final d = doc.data();
        final pat = _patrimonioNorm(d);
        final email = _s(d['EMAIL'], '(sem e-mail)');
        final cat = _categoria(d);

        totalTodosEquipPorEmail[email] =
            (totalTodosEquipPorEmail[email] ?? 0) + 1;
        totalEquipPorCat[cat] = (totalEquipPorCat[cat] ?? 0) + 1;

        final tipo = _norm(
          d['TIPOEQUIPAMENTO'] ??
              d['EQUIPAMENTO'] ??
              d['NOMEEQUIPAMENTO'] ??
              d['nome'] ??
              '',
        );
        final isAC = tipo.contains('ar condicionado') ||
            tipo.contains('ar-condicionado') ||
            tipo.contains('split') ||
            tipo.contains('chiller') ||
            tipo.contains('vrf') ||
            tipo.contains('fan coil') ||
            tipo.contains('fancoil') ||
            tipo.contains('hi wall') ||
            tipo.contains('cassete') ||
            tipo.contains('piso teto') ||
            tipo == 'ac';
        if (isAC) {
          totalEquipPorEmail[email] = (totalEquipPorEmail[email] ?? 0) + 1;
        }

        bool feito = false;
        if (pat.isNotEmpty &&
            feitosPatSet.contains(pat) &&
            !patConsumido.contains(pat)) {
          patConsumido.add(pat);
          feito = true;
          feitosCount++;
        }

        if (feito) {
          totalTodasPreviPorEmail[email] =
              (totalTodasPreviPorEmail[email] ?? 0) + 1;
          if (isAC) {
            totalPreviPorEmail[email] = (totalPreviPorEmail[email] ?? 0) + 1;
          }
        } else {
          pendentes.add(_PendingItem(
            docId: doc.id,
            data: d,
            chave: pat.isEmpty ? 'sem_patrimonio:${doc.id}' : pat,
            semPatrimonio: pat.isEmpty,
          ));
        }
      }

      if (feitosCount > totalPrevNoPeriodo) {
        final ratio = totalPrevNoPeriodo / feitosCount;
        for (final key in totalTodasPreviPorEmail.keys.toList()) {
          totalTodasPreviPorEmail[key] =
              (totalTodasPreviPorEmail[key]! * ratio).round();
        }
        for (final key in totalPreviPorEmail.keys.toList()) {
          totalPreviPorEmail[key] = (totalPreviPorEmail[key]! * ratio).round();
        }
      }

      final Map<String, List<_PendingItem>> grouped = {};
      for (final item in pendentes) {
        final cat = _categoria(item.data);
        grouped.putIfAbsent(cat, () => []).add(item);
      }

      for (final list in grouped.values) {
        list.sort((a, b) => _s(a.data['EMAIL'], '')
            .toLowerCase()
            .compareTo(_s(b.data['EMAIL'], '').toLowerCase()));
      }

      final cats = grouped.keys.toList()
        ..sort((a, b) => grouped[b]!.length.compareTo(grouped[a]!.length));

      setState(() {
        _grouped = grouped;
        _categories = cats;
        _totalEquipPorEmail = totalEquipPorEmail;
        _totalPreviPorEmail = totalPreviPorEmail;
        _totalTodosEquipPorEmail = totalTodosEquipPorEmail;
        _totalTodasPreviPorEmail = totalTodasPreviPorEmail;
        _totalEquipPorCat = totalEquipPorCat;
        _totalPrevNoPeriodo = totalPrevNoPeriodo;
        _pendenciasPatSet = pendenciasPatSet;
        _imagensPorPat = imagensPorPat;
        _loadingResults = false;
        _showResults = true;
      });
    } catch (e) {
      setState(() => _loadingResults = false);
      _snack('Erro na busca: $e');
    }
  }

  // ─────────────────────────────────────────────────────────
  //  HELPERS
  // ─────────────────────────────────────────────────────────
  String _patrimonioNorm(Map<String, dynamic> d) =>
      _norm(d['PATRIMONIO'] ?? '');

  String _categoria(Map<String, dynamic> d) => _s(
          d['TIPOEQUIPAMENTO'] ??
              d['EQUIPAMENTO'] ??
              d['NOMEEQUIPAMENTO'] ??
              d['nome'],
          'Outros')
      .toUpperCase();

  DateTime? _parseDate(dynamic v) {
    if (v == null) return null;
    if (v is Timestamp) return v.toDate();
    final s = v.toString().trim();
    if (s.isEmpty) return null;
    return DateTime.tryParse(s);
  }

  String _norm(dynamic v) =>
      v.toString().toLowerCase().trim().replaceAll(RegExp(r'\s+'), ' ');

  String _s(dynamic v, String fb) {
    final s = (v ?? '').toString().trim();
    return s.isNotEmpty ? s : fb;
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg), backgroundColor: _danger));
  }

  int get _totalPendentes =>
      _grouped.values.fold(0, (sum, list) => sum + list.length);

  // ═══════════════════════════════════════════════════════
  //  BUILD
  // ═══════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
      width: widget.width ?? double.infinity,
      height: widget.height ?? double.infinity,
      color: const Color(0xFF0B0F17),
      child: _showResults ? _resultScreen() : _filterScreen(),
    ),
    );
  }

  // ═══════════════════════════════════════════════════════
  //  TELA 1 — FILTROS
  // ═══════════════════════════════════════════════════════
  Widget _filterScreen() {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
            20, 24, 20, 24 + MediaQuery.of(context).padding.bottom),
        child: Container(
          decoration: BoxDecoration(
            color: _cardBg,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: _cs.shadow.withAlpha(25),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 20, 16, 20),
                decoration: BoxDecoration(
                  color: _headerBg,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(24)),
                  border: Border(
                    bottom:
                        BorderSide(color: _cs.outlineVariant.withAlpha(100)),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _primary.withAlpha(30),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.pending_actions_rounded,
                          color: _primary, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Preventivas Pendentes',
                              style: TextStyle(
                                color: _headerFg,
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              )),
                          const SizedBox(height: 2),
                          Text('Selecione o período para verificar',
                              style: TextStyle(
                                color: _headerFg.withAlpha(140),
                                fontSize: 12,
                              )),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              _loadingFilters
                  ? Padding(
                      padding: const EdgeInsets.all(44),
                      child: Column(children: [
                        CircularProgressIndicator(color: _primary),
                        const SizedBox(height: 14),
                        Text('Carregando dados...',
                            style: TextStyle(color: _textSub, fontSize: 13)),
                      ]),
                    )
                  : Padding(
                      padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
                      child: Column(children: [
                        _dropField(
                          label: 'Ano',
                          icon: Icons.calendar_today_rounded,
                          child: _dropdown<int>(
                            value: _selYear,
                            hint: 'Selecione o ano',
                            items: _years
                                .map((y) => DropdownMenuItem(
                                      value: y,
                                      child: Text(y.toString()),
                                    ))
                                .toList(),
                            onChanged: (v) => setState(() => _selYear = v),
                          ),
                        ),
                        const SizedBox(height: 14),
                        _dropField(
                          label: 'Mês',
                          icon: Icons.event_rounded,
                          child: _dropdown<int>(
                            value: _selMonth,
                            hint: 'Selecione o mês',
                            items: _months
                                .map((m) => DropdownMenuItem(
                                      value: m,
                                      child: Text(_ptMonths[m]),
                                    ))
                                .toList(),
                            onChanged: (v) => setState(() => _selMonth = v),
                          ),
                        ),
                        const SizedBox(height: 14),
                        _dropField(
                          label: 'Cliente (opcional)',
                          icon: Icons.business_rounded,
                          child: _dropdown<String>(
                            value: _selEmail,
                            hint: 'Todos os clientes',
                            items: [
                              const DropdownMenuItem(
                                  value: null,
                                  child: Text('Todos os clientes')),
                              ..._emails.map((e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(e,
                                        overflow: TextOverflow.ellipsis),
                                  )),
                            ],
                            onChanged: (v) => setState(() => _selEmail = v),
                          ),
                        ),
                        const SizedBox(height: 26),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton.icon(
                            onPressed: _loadingResults ? null : _buscar,
                            icon: _loadingResults
                                ? SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2, color: _cs.onPrimary))
                                : const Icon(Icons.search_rounded, size: 20),
                            label: Text(
                              _loadingResults
                                  ? 'Analisando...'
                                  : 'Verificar Pendentes',
                              style: const TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _primary,
                              foregroundColor: _cs.onPrimary,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                              elevation: 0,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 44,
                          child: OutlinedButton.icon(
                            onPressed: _loadingResults ? null : _diagnostico,
                            icon:
                                const Icon(Icons.bug_report_rounded, size: 18),
                            label: const Text(
                              '🔍 Diagnóstico de Coleções',
                              style: TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: _danger,
                              side: BorderSide(color: _danger.withAlpha(128)),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                            ),
                          ),
                        ),
                      ]),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  //  TELA 2 — RESULTADOS
  // ═══════════════════════════════════════════════════════
  Widget _resultScreen() {
    final mes = _selMonth != null ? _ptMonths[_selMonth!] : '';
    final ano = _selYear?.toString() ?? '';

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 52, 16, 16),
          decoration: BoxDecoration(
            color: _headerBg,
            border: Border(
              bottom: BorderSide(color: _cs.outlineVariant.withAlpha(100)),
            ),
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: _reset,
                child: Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: _cs.outlineVariant.withAlpha(76),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.arrow_back_ios_new_rounded,
                      color: _headerFg, size: 18),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Equipamentos Pendentes',
                        style: TextStyle(
                            color: _headerFg,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                    Text(
                      '$mes / $ano'
                      '${_selEmail != null ? '  •  $_selEmail' : ''}',
                      style: TextStyle(
                          color: _headerFg.withAlpha(140), fontSize: 11),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (_totalEquipPorEmail.isNotEmpty)
          Container(
            color: _headerBg,
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Column(
              children: [
                ...(() {
                  final entries = _totalEquipPorEmail.entries.toList()
                    ..sort((a, b) => b.value.compareTo(a.value));
                  return entries.map((entry) {
                    final totalTodos = _totalTodosEquipPorEmail[entry.key] ?? 1;
                    final feitosTodos = _totalPrevNoPeriodo;
                    final pend = totalTodos - feitosTodos;
                    final pct = totalTodos > 0 ? feitosTodos / totalTodos : 0.0;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            if (_selEmail == null) ...[
                              Icon(Icons.email_outlined,
                                  size: 11, color: _textSub),
                              const SizedBox(width: 5),
                              Expanded(
                                child: Text(
                                  entry.key,
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: _textSub,
                                      fontWeight: FontWeight.w500),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ] else
                              const Spacer(),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.ac_unit_rounded,
                                    size: 11, color: _textSub),
                                const SizedBox(width: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withAlpha(38),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                        color: Colors.green.withAlpha(89),
                                        width: 0.8),
                                  ),
                                  child: Text(
                                    '$feitosTodos feitos',
                                    style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.green),
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: _primary.withAlpha(25),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                        color: _primary.withAlpha(76),
                                        width: 0.8),
                                  ),
                                  child: Text(
                                    '$totalTodos equip.',
                                    style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: _primary),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: LinearProgressIndicator(
                            value: pct.toDouble(),
                            minHeight: 7,
                            backgroundColor: _danger.withAlpha(38),
                            valueColor:
                                const AlwaysStoppedAnimation(Colors.green),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${(pct * 100).toStringAsFixed(0)}% concluído  •  $pend pendente${pend != 1 ? 's' : ''}',
                          style: TextStyle(fontSize: 10, color: _textSub),
                        ),
                        if (entries.length > 1 && entry.key != entries.last.key)
                          Divider(
                              height: 14,
                              color: _cs.outlineVariant.withAlpha(76)),
                      ],
                    );
                  });
                })(),
                const SizedBox(height: 6),
                Divider(height: 1, color: _cs.outlineVariant.withAlpha(100)),
              ],
            ),
          ),
        Container(
          color: _headerBg,
          padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              color: _inputBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _inputBorder),
            ),
            child: Row(
              children: [
                const SizedBox(width: 12),
                Icon(Icons.search_rounded, color: _textSub, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    style: TextStyle(color: _textStrong, fontSize: 13),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText:
                          'Pesquisar por patrimônio, setor, sala, email...',
                      hintStyle: TextStyle(color: _textSub, fontSize: 13),
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                if (_searchQuery.isNotEmpty)
                  GestureDetector(
                    onTap: () => _searchCtrl.clear(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child:
                          Icon(Icons.close_rounded, color: _textSub, size: 16),
                    ),
                  ),
              ],
            ),
          ),
        ),
        Expanded(
          child: Container(
            color: _cs.surface,
            child: _buildFilteredList(),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────
  //  LISTA FILTRADA
  // ─────────────────────────────────────────────────────────
  Widget _buildFilteredList() {
    Map<String, List<_PendingItem>> visivel;

    if (_searchQuery.isEmpty) {
      visivel = _grouped;
    } else {
      final q = _searchQuery;
      visivel = {};
      for (final cat in _categories) {
        final filtrados = _grouped[cat]!.where((item) {
          final d = item.data;
          final pat = _norm(d['PATRIMONIO'] ?? '');
          final email = _norm(d['EMAIL'] ?? '');
          final setor = _norm(d['SETOR'] ?? '');
          final sala = _norm(d['SALA'] ?? d['LOCAL'] ?? d['LOCALIZACAO'] ?? '');
          final equip = _norm(d['TIPOEQUIPAMENTO'] ??
              d['EQUIPAMENTO'] ??
              d['NOMEEQUIPAMENTO'] ??
              d['nome'] ??
              '');
          return pat.contains(q) ||
              email.contains(q) ||
              setor.contains(q) ||
              sala.contains(q) ||
              equip.contains(q);
        }).toList();
        if (filtrados.isNotEmpty) visivel[cat] = filtrados;
      }
    }

    if (visivel.isEmpty) {
      return _searchQuery.isNotEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search_off_rounded, size: 48, color: _textSub),
                    const SizedBox(height: 12),
                    Text(
                      'Nenhum resultado para\n"$_searchQuery"',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: _textSub, fontSize: 14),
                    ),
                  ],
                ),
              ),
            )
          : _emptyState();
    }

    final cats = visivel.keys.toList()
      ..sort((a, b) => visivel[b]!.length.compareTo(visivel[a]!.length));

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 32),
      itemCount: cats.length,
      itemBuilder: (_, i) => _categorySectionFrom(cats[i], visivel[cats[i]]!),
    );
  }

  Widget _categorySectionFrom(String cat, List<_PendingItem> items) {
    final totalCat = _totalEquipPorCat[cat] ?? items.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
          child: Row(
            children: [
              Icon(_iconEquip(cat), size: 16, color: _primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  cat,
                  style: TextStyle(
                    color: _primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$totalCat total',
                  style: TextStyle(
                    color: _cs.onPrimary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${totalCat - items.length} feitos',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _danger,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${items.length} pend.',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
        ...items.map((item) => _equipCard(item, cat)),
        Divider(height: 1, color: _cs.outlineVariant.withAlpha(100)),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────
  //  CARD EQUIPAMENTO
  // ─────────────────────────────────────────────────────────
  Widget _equipCard(_PendingItem item, String cat) {
    final d = item.data;
    final email = _s(d['EMAIL'], '');
    final setor = _s(d['SETOR'], '');
    final sala = _s(d['SALA'] ?? d['LOCAL'] ?? d['LOCALIZACAO'], '');
    final btus = _s(d['BTUS'], '');
    final marca = _s(d['MARCA'], '');
    final fluid = _s(d['FLUIDO'], '');
    final tipo = _s(d['TIPOEQUIPAMENTO'] ?? d['TIPO'], '');
    final pat = _s(d['PATRIMONIO'], '');
    final temPendencia =
        pat.isNotEmpty && _pendenciasPatSet.contains(_norm(pat));
    final patNorm = _norm(pat);
    final imgUrl = patNorm.isNotEmpty ? _imagensPorPat[patNorm] : null;
    final accentColor = temPendencia ? Colors.orange : _primary;

    return GestureDetector(
      onTap: () async {
        await showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          isDismissible: true,
          enableDrag: true,
          useSafeArea: true,
          builder: (_) => DraggableScrollableSheet(
            initialChildSize: 0.95,
            maxChildSize: 0.97,
            minChildSize: 0.25,
            shouldCloseOnMinExtent: true,
            expand: false,
            builder: (ctx, scrollCtrl) => CustomScrollView(
              controller: scrollCtrl,
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: true,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20)),
                    child: CadastrarPreventivaWidget(
                      patrimonio: pat.isNotEmpty ? pat : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: _cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: temPendencia
                ? Colors.orange.withAlpha(160)
                : _cs.outlineVariant.withAlpha(100),
            width: temPendencia ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: accentColor.withAlpha(temPendencia ? 30 : 12),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── BANNER ──────────────────────────────────────────────────────
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(15)),
              child: imgUrl != null
                  ? Stack(
                      children: [
                        Image.network(
                          imgUrl,
                          width: double.infinity,
                          height: 110,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              _bannerSemImagem(cat, accentColor, temPendencia),
                        ),
                        // Gradiente escuro na base
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  Colors.black.withAlpha(180),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),
                        // PAT badge inferior esquerdo
                        if (pat.isNotEmpty)
                          Positioned(
                            bottom: 8,
                            left: 10,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black.withAlpha(160),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.qr_code_rounded,
                                      size: 11, color: Colors.white),
                                  const SizedBox(width: 4),
                                  Text(
                                    'PAT: $pat',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        // ── BOTÃO VER IMAGEM GRANDE (canto inferior direito) ──
                        Positioned(
                          bottom: 8,
                          right: 10,
                          child: GestureDetector(
                            onTap: () =>
                                _abrirImagemGrande(context, imgUrl, pat),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black.withAlpha(160),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.zoom_in_rounded,
                                      size: 13, color: Colors.white),
                                  SizedBox(width: 4),
                                  Text(
                                    'Ver foto',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Badge pendência superior direito
                        if (temPendencia)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.orange,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.report_problem_rounded,
                                      size: 11, color: Colors.white),
                                  SizedBox(width: 4),
                                  Text(
                                    'PENDÊNCIA ABERTA',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    )
                  : _bannerSemImagem(cat, accentColor, temPendencia),
            ),

            // ── CORPO DO CARD ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (email.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: Row(children: [
                        Icon(Icons.email_outlined, size: 12, color: _textSub),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            email,
                            style: TextStyle(
                                fontSize: 11,
                                color: _textSub,
                                fontWeight: FontWeight.w500),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ]),
                    ),

                  if (setor.isNotEmpty || sala.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.location_on_rounded,
                              size: 12, color: _textSub),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              [
                                if (setor.isNotEmpty) setor,
                                if (sala.isNotEmpty) sala,
                              ].join('  •  '),
                              style: TextStyle(
                                  fontSize: 12,
                                  color: _textStrong,
                                  fontWeight: FontWeight.w600),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),

                  if (pat.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _danger.withAlpha(20),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: _danger.withAlpha(64), width: 0.9),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.warning_amber_rounded,
                                size: 12, color: _danger),
                            const SizedBox(width: 5),
                            Text(
                              'SEM PATRIMÔNIO',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: _danger,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // PAT badge (somente quando não há imagem)
                  if (pat.isNotEmpty && imgUrl == null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: accentColor.withAlpha(22),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: accentColor.withAlpha(80), width: 0.9),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.qr_code_rounded,
                                size: 12, color: accentColor),
                            const SizedBox(width: 5),
                            Text(
                              'PAT: $pat',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: accentColor,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Pendência badge (somente quando não há imagem)
                  if (temPendencia && imgUrl == null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.orange.withAlpha(28),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: Colors.orange.withAlpha(120), width: 0.9),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.report_problem_rounded,
                                size: 12, color: Colors.orange),
                            SizedBox(width: 5),
                            Text(
                              'PENDÊNCIA ABERTA',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.orange,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Chips
                  if ([tipo, btus, marca, fluid].any((v) => v.isNotEmpty))
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: [
                          if (tipo.isNotEmpty && tipo.toUpperCase() != cat)
                            _chip(tipo),
                          if (btus.isNotEmpty) _chip(btus),
                          if (marca.isNotEmpty) _chip(marca),
                          if (fluid.isNotEmpty) _chip(fluid),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  //  BANNER SEM IMAGEM
  // ─────────────────────────────────────────────────────────
  Widget _bannerSemImagem(String cat, Color accentColor, bool temPendencia) {
    return Container(
      width: double.infinity,
      height: 64,
      color: accentColor.withAlpha(18),
      child: Stack(
        children: [
          Center(
            child: Icon(
              _iconEquip(cat),
              color: accentColor.withAlpha(120),
              size: 36,
            ),
          ),
          if (temPendencia)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.report_problem_rounded,
                        size: 11, color: Colors.white),
                    SizedBox(width: 4),
                    Text(
                      'PENDÊNCIA ABERTA',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  //  ESTADO VAZIO
  // ─────────────────────────────────────────────────────────
  Widget _emptyState() {
    return Container(
      color: _cs.surface,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: _cs.tertiary.withAlpha(25),
                  shape: BoxShape.circle,
                ),
                child:
                    Icon(Icons.verified_rounded, size: 64, color: _cs.tertiary),
              ),
              const SizedBox(height: 20),
              Text('Tudo em dia! 🎉',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: _textStrong,
                  )),
              const SizedBox(height: 8),
              Text(
                'Nenhuma preventiva pendente\npara o período selecionado.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: _textSub),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  //  WIDGETS AUXILIARES
  // ═══════════════════════════════════════════════════════
  Widget _dropField({
    required String label,
    required IconData icon,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Icon(icon, size: 13, color: _primary),
          const SizedBox(width: 6),
          Text(label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _textSub,
                letterSpacing: 0.3,
              )),
        ]),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
          decoration: BoxDecoration(
            color: _inputBg,
            border: Border.all(color: _inputBorder),
            borderRadius: BorderRadius.circular(12),
          ),
          child: child,
        ),
      ],
    );
  }

  Widget _dropdown<T>({
    required T? value,
    required String hint,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<T>(
        value: value,
        isExpanded: true,
        dropdownColor: _cs.surfaceContainerHigh,
        iconEnabledColor: _primary,
        hint: Text(hint, style: TextStyle(color: _textSub, fontSize: 14)),
        items: items,
        onChanged: onChanged,
        style: TextStyle(color: _textStrong, fontSize: 14),
      ),
    );
  }

  Widget _chip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: _cs.surfaceContainerHighest,
        border: Border.all(color: _cs.outlineVariant, width: 0.8),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label,
          style: TextStyle(
            fontSize: 10,
            color: _cs.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          )),
    );
  }

  IconData _iconEquip(String v) {
    final t = v.toLowerCase();
    if (t.contains('ar') || t.contains('condicionado') || t.contains('split'))
      return Icons.ac_unit_rounded;
    if (t.contains('geladeira') || t.contains('câmara') || t.contains('camara'))
      return Icons.kitchen_rounded;
    if (t.contains('bomba')) return Icons.water_drop_rounded;
    if (t.contains('motor')) return Icons.settings_rounded;
    if (t.contains('elevador')) return Icons.elevator_rounded;
    if (t.contains('exaust') || t.contains('ventil')) return Icons.air_rounded;
    if (t.contains('chiller')) return Icons.device_thermostat_rounded;
    return Icons.build_circle_rounded;
  }
}

// ─────────────────────────────────────────────────────────
//  MODELS
// ─────────────────────────────────────────────────────────
class _PendingItem {
  final String docId;
  final Map<String, dynamic> data;
  final String chave;
  final bool semPatrimonio;

  const _PendingItem({
    required this.docId,
    required this.data,
    required this.chave,
    required this.semPatrimonio,
  });
}

enum _DiagType { header, info, warning, ok, detail }

class _DiagLine {
  final String text;
  final _DiagType type;
  const _DiagLine(this.text, this.type);
}
