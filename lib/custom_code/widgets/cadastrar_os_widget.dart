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

import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';

// ── Cores ─────────────────────────────────────────────────────
const _kViolet = Color(0xFF1D4ED8);
const _kCyan = Color(0xFF0F766E);
const _kEmerald = Color(0xFF047857);
const _kRose = Color(0xFFB91C1C);
const _kAmber = Color(0xFFB45309);

// ── OneSignal ─────────────────────────────────────────────────
const _kOsApp = '7b01186f-cf76-4b5d-8354-87d83737d40c';
const _kOsKey = 'Basic ZTdlNjIwZWItMjEyMC00M2RhLWJlZmYtMzc2NTBmNzNmMDdj';
const _kOsChan = '577bba44-d1bf-4ac9-9d11-20d89e09a61a';

// ── Meses ─────────────────────────────────────────────────────
const _kMeses = [
  'JANEIRO',
  'FEVEREIRO',
  'MARÇO',
  'ABRIL',
  'MAIO',
  'JUNHO',
  'JULHO',
  'AGOSTO',
  'SETEMBRO',
  'OUTUBRO',
  'NOVEMBRO',
  'DEZEMBRO',
];

// ── Tema adaptativo ───────────────────────────────────────────
class _K {
  _K(BuildContext c) : dark = Theme.of(c).brightness == Brightness.dark;
  final bool dark;

  Color get bg => dark ? const Color(0xFF0F172A) : const Color(0xFFFFFFFF);
  Color get card => dark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC);
  Color get input => dark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9);
  Color get bord => dark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
  Color get bord2 => dark ? const Color(0xFF475569) : const Color(0xFFCBD5E1);
  Color get ink => dark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
  Color get ink2 => dark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
  Color get ink3 => dark ? const Color(0xFF64748B) : const Color(0xFF94A3B8);
  Color get shadow => dark ? const Color(0x60000000) : const Color(0x14000000);
}

// ── Tipografia ────────────────────────────────────────────────
TextStyle _ks(double sz, {Color? c, bool b = false, double? ls, double? h}) =>
    GoogleFonts.inter(
      fontSize: sz,
      color: c,
      fontWeight: b ? FontWeight.w700 : FontWeight.w400,
      letterSpacing: ls,
      height: h,
    );

bool _fotoValida(String? s) {
  final u = (s ?? '').trim();
  return u.startsWith('http://') || u.startsWith('https://')
      ? !u.contains('Erro:')
      : false;
}

class CadastrarOsWidget extends StatefulWidget {
  const CadastrarOsWidget({super.key, this.width, this.height});
  final double? width;
  final double? height;

  @override
  State<CadastrarOsWidget> createState() => _CadState();
}

class _CadState extends State<CadastrarOsWidget> {
  final _db = FirebaseFirestore.instance;

  // controllers
  final _cPat = TextEditingController();
  final _cNos = TextEditingController();
  final _cNome = TextEditingController();
  final _cAno = TextEditingController(text: DateTime.now().year.toString());
  final _cData = TextEditingController();
  final _cDefei = TextEditingController();
  final _maskDt = MaskTextInputFormatter(mask: '##/##/####');

  // dropdowns
  String? _equip;
  String? _tec;
  String _mes = _kMeses[DateTime.now().month - 1];
  final _status = 'AGUARDANDO AVALIAÇÃO';

  // dados carregados
  List<String> _equips = [];
  List<String> _tecs = [];
  Map<String, String> _tFoto = {};

  // cliente selecionado
  String _emailCli = '';
  String _onesig = '';

  // equipamento encontrado
  Map<String, dynamic>? _eqData;

  // estado
  bool _loading = true;
  bool _salvando = false;
  bool _gerandoOs = false;
  bool _tentou = false;
  Timer? _debounce;
  final _erros = <String>{};

  @override
  void initState() {
    super.initState();
    _loadDrops();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    for (final c in [_cPat, _cNos, _cNome, _cAno, _cData, _cDefei]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _gerarOsSequencial() async {
    setState(() {
      _gerandoOs = true;
      _cNos.text = '...';
    });

    try {
      final snap = await _db
          .collection('SERVICOSREALIZADOS')
          .orderBy('DATA', descending: true)
          .limit(1)
          .get();

      int proximoNumero = 1000;

      if (snap.docs.isNotEmpty) {
        final lastOsStr =
            snap.docs.first.data()['NUMERODAOS']?.toString() ?? '';
        final lastOsInt = int.tryParse(lastOsStr);
        if (lastOsInt != null) {
          proximoNumero = lastOsInt + 1;
        }
      }

      setState(() {
        _cNos.text = proximoNumero.toString();
        _erros.remove('nos');
      });
    } catch (e) {
      debugPrint('Erro ao buscar última OS: $e');
      _snack('Erro ao buscar sequência. Insira manualmente.');
      setState(() {
        _cNos.clear();
      });
    } finally {
      setState(() {
        _gerandoOs = false;
      });
    }
  }

  Future<void> _loadDrops() async {
    try {
      final rs = await Future.wait([
        _db.collection('EQUIPAMENTOSCADASTRO').get(),
        _db.collection('PONTOS_POR_TECNICO').orderBy('TECNICO').get(),
      ]);
      final eq = <String>[], tc = <String>[], ft = <String, String>{};
      for (final d in rs[0].docs) {
        final n = (d.data()['EQUIPAMENTOS'] ?? '').toString().trim();
        if (n.isNotEmpty) eq.add(n);
      }
      for (final d in rs[1].docs) {
        final nm = (d.data()['TECNICO'] ?? '').toString().trim();
        final ph = (d.data()['FOTO'] ?? '').toString().trim();
        if (nm.isNotEmpty) {
          tc.add(nm);
          if (_fotoValida(ph)) ft[nm] = ph;
        }
      }
      setState(() {
        _equips = eq;
        _tecs = ['NÃO DEFINIDO', ...tc];
        _tFoto = ft;
        _tec = 'NÃO DEFINIDO';
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  void _onPatChanged(String v) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 1000), () => _buscarPat(v));
  }

  Future<void> _buscarPat(String pat) async {
    if (pat.trim().isEmpty) return;
    try {
      final snap = await _db
          .collection('EQUIPAMENTOS_EMPRESA')
          .where('PATRIMONIO', isEqualTo: pat.trim())
          .limit(1)
          .get();
      if (snap.docs.isEmpty) {
        setState(() => _eqData = null);
        _snack('Número não encontrado');
        return;
      }
      final data = snap.docs.first.data();
      setState(() {
        _eqData = data;
        final eq = (data['EQUIPAMENTO'] ?? '').toString().trim();
        if (_equips.contains(eq)) _equip = eq;
        final em = (data['EMAIL'] ?? '').toString().trim();
        if (em.isNotEmpty) _emailCli = em;
      });
      if (mounted) _verEquip(data);
    } catch (e) {
      _snack('Erro: $e');
    }
  }

  void _verEquip(Map<String, dynamic> d) => showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        enableDrag: true,
        isDismissible: true,
        useSafeArea: true,
        builder: (_) => _EquipSheet(data: d, k: _K(context)),
      );

  Future<void> _buscarCliente() async {
    final r = await showModalBottomSheet<_CR>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      enableDrag: true,
      isDismissible: true,
      useSafeArea: true,
      builder: (_) => _ClienteSheet(k: _K(context)),
    );
    if (r != null && mounted) {
      setState(() {
        _cNome.text = r.nome;
        _emailCli = r.email;
        _onesig = r.onesignal;
        _erros.remove('nome');
      });
    }
  }

  bool _validar() {
    final e = <String>{};
    if (_cNos.text.trim().isEmpty) e.add('nos');
    if (_cNome.text.trim().isEmpty) e.add('nome');
    if (_equip == null || _equip!.isEmpty) e.add('equip');
    if (_tec == null || _tec!.isEmpty) e.add('tec');
    if (_mes.isEmpty) e.add('mes');
    setState(() {
      _tentou = true;
      _erros
        ..clear()
        ..addAll(e);
    });
    return e.isEmpty;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // NOTIFICAÇÃO FIREBASE — cria doc na coleção NOTIFICACAO ao abrir nova O.S.
  // O campo 'os' é preenchido com o número da OS para que o NotificacaoWidget1
  // possa navegar diretamente para os detalhes da OS ao tocar na notificação.
  // ═══════════════════════════════════════════════════════════════════════════
  Future<void> _criarNotificacaoFirebase({
    required String email,
    required String nos,
    required String equipamento,
    required String sala,
    required String setor,
    required String defeito,
  }) async {
    if (email.isEmpty) return;
    try {
      await FirebaseFirestore.instance.collection('NOTIFICACAO').add({
        'email': email,
        'titulo': '🔧 Nova Ordem de Serviço Aberta',
        'mensagem': 'O.S #$nos aberta para o equipamento $equipamento '
            '— Sala: $sala, Setor: $setor.'
            '${defeito.isNotEmpty ? ' Defeito: $defeito.' : ''}',
        'tipo': 'corretiva',
        'visto': false,
        'data': Timestamp.now(),
        'status': 'AGUARDANDO AVALIAÇÃO',
        // Campo 'os' com número da OS — permite navegação direta para detalhes
        // da O.S ao tocar na notificação no NotificacaoWidget1.
        'os': nos,
      });
    } catch (e) {
      debugPrint('Erro ao criar notificação Firebase: $e');
    }
  }

  Future<void> _cadastrar() async {
    // verifica se OS já existe
    final ex = await _db
        .collection('SERVICOSREALIZADOS')
        .where('NUMERODAOS', isEqualTo: _cNos.text.trim())
        .limit(1)
        .get();
    if (ex.docs.isNotEmpty) {
      _showAlert('O.S já cadastrada.');
      return;
    }
    if (!_validar()) return;

    setState(() => _salvando = true);
    final now = DateTime.now();
    final nos = _cNos.text.trim();
    final cli = _cNome.text.trim();
    final pat = _cPat.text.trim();
    final defei = _cDefei.text.trim();
    final ano = int.tryParse(_cAno.text) ?? now.year;
    final cad = DateFormat('d/M H:mm').format(now);
    final inicio = (_status == 'INICIOU O SERVIÇO' || _status == 'CONCLUÍDA')
        ? _cData.text.trim()
        : '';

    try {
      unawaited(_db.collection('MANUTENCAO').add({
        'STATUS': _status,
        'PATRIMONIO': pat,
        'PREVISAODAPECA': '',
        'NUMERO_OS': nos,
        'TECNICORESPONSAVEL': _tec ?? '',
        'MES': _mes,
        'NOME': (_eqData?['NOME'] ?? '').toString(),
        'TIPO': (_eqData?['TIPO'] ?? '').toString(),
        'DATA_TERMINO': '',
        'Empresa': true,
        'DESCRICAODOSERVICO': '',
        'EQUIPAMENTO': (_eqData?['EQUIPAMENTO'] ?? '').toString(),
        'FLUIDO': (_eqData?['FLUIDO'] ?? '').toString(),
        'EMAIL': (_eqData?['EMAIL'] ?? _emailCli).toString(),
        'SALA': (_eqData?['SALA'] ?? '').toString(),
        'MODELO': (_eqData?['MODELO'] ?? '').toString(),
        'MARCA': (_eqData?['MARCA'] ?? '').toString(),
        'BTUS': (_eqData?['BTUS'] ?? '').toString(),
        'ANO': ano,
        'RESPONSAVEL': (_eqData?['RESPONSAVEL'] ?? '').toString(),
        'DATADAMANUTENCAO': FieldValue.serverTimestamp(),
        'DEFEITO': defei,
        'SETOR': (_eqData?['SETOR'] ?? '').toString(),
      }));

      unawaited(_db.collection('SERVICOSREALIZADOS').add({
        'SERVICO': defei,
        'EQUIPAMENTO': _equip ?? '',
        'TECNICO': _tec ?? '',
        'NUMERODAOS': nos,
        'STATUS': _status,
        'PONTOS': 0.0,
        'TERMINO': '',
        'INICIO': inicio,
        'CLIENTE': cli,
        'MES': _mes,
        'PATRIMONIO': pat,
        'CADASTRO': cad,
        'DESCRICAO': '',
        'PECA': '',
        'EMAIL': _emailCli,
        'SETOR': (_eqData?['SETOR'] ?? '').toString(),
        'SALA': (_eqData?['SALA'] ?? '').toString(),
        'DATA': FieldValue.serverTimestamp(),
        'FALTA_COMPARTILHAR': true,
        'COMPARTILHADO': false,
      }));

      unawaited(_pushOs(
        email: _emailCli,
        titulo: 'NOVA O.S CADASTRADA',
        mensagem: 'Recebemos sua solicitação e registramos a '
            'O.S #$nos. Em breve o técnico estará atendendo.',
      ));

      // ── NOVO: notificação Firebase ────────────────────────────────────────
      // Disparo assíncrono com unawaited() — não bloqueia o cadastro da OS.
      // Campo 'os' preenchido com número da OS para navegação direta pelo sino.
      if (_emailCli.isNotEmpty) {
        unawaited(_criarNotificacaoFirebase(
          email: _emailCli,
          nos: nos,
          equipamento: _equip ?? '',
          sala: (_eqData?['SALA'] ?? '').toString(),
          setor: (_eqData?['SETOR'] ?? '').toString(),
          defeito: defei,
        ));
      }
      // ─────────────────────────────────────────────────────────────────────

      if (!mounted) return;
      _snack('✅  Cadastro realizado com sucesso!');
      Navigator.pop(context);
    } catch (e) {
      if (mounted) _snack('Erro: $e');
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  Future<void> _pushOs({
    required String email,
    required String titulo,
    required String mensagem,
  }) async {
    if (email.isEmpty) return;
    try {
      await http.post(
        Uri.parse('https://onesignal.com/api/v1/notifications'),
        headers: {
          'Authorization': _kOsKey,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'app_id': _kOsApp,
          'filters': [
            {'field': 'tag', 'key': 'Email', 'relation': '=', 'value': email},
          ],
          'headings': {'en': titulo},
          'contents': {'en': mensagem},
          'android_channel_id': _kOsChan,
          'priority': 10,
        }),
      );
    } catch (e) {
      debugPrint('OneSignal: $e');
    }
  }

  void _snack(String msg) =>
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(SnackBar(
        content: Text(msg),
        duration: const Duration(milliseconds: 4000),
      ));

  Future<void> _showAlert(String msg) => showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('ATENÇÃO!'),
          content: Text(msg),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Ok'),
            ),
          ],
        ),
      );

  String? _errLabel(String key) {
    if (!_tentou || !_erros.contains(key)) return null;
    const m = {
      'nos': 'Informe o N° da O.S',
      'nome': 'Informe o nome do cliente',
      'equip': 'Selecione o equipamento',
      'tec': 'Selecione um técnico',
      'mes': 'Selecione o mês',
    };
    return m[key];
  }

  @override
  Widget build(BuildContext context) {
    final k = _K(context);

    if (_loading) {
      return Container(
        width: widget.width ?? double.infinity,
        height: widget.height,
        color: k.bg,
        child: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            CircularProgressIndicator(color: _kViolet, strokeWidth: 2.5),
            const SizedBox(height: 14),
            Text('Carregando...', style: _ks(13, c: k.ink2)),
          ]),
        ),
      );
    }

    return Container(
      width: widget.width ?? double.infinity,
      height: widget.height,
      decoration: BoxDecoration(
        color: k.bg,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Header(k: k),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _BtnCliente(k: k, onTap: _buscarCliente),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Text('Patrimônio / N° Série',
                            style: _ks(10, c: k.ink3, ls: 1.2, b: true)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('N° da O.S',
                                style: _ks(10, c: k.ink3, ls: 1.2, b: true)),
                            GestureDetector(
                              onTap: _gerandoOs ? null : _gerarOsSequencial,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 3),
                                decoration: BoxDecoration(
                                  color: _kViolet.withOpacity(.1),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                      color: _kViolet.withOpacity(.3)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (_gerandoOs)
                                      const SizedBox(
                                        width: 10,
                                        height: 10,
                                        child: CircularProgressIndicator(
                                            color: _kViolet, strokeWidth: 2),
                                      )
                                    else
                                      const Icon(Icons.autorenew_rounded,
                                          size: 10, color: _kViolet),
                                    const SizedBox(width: 4),
                                    Text('GERAR',
                                        style: _ks(9, c: _kViolet, b: true)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(children: [
                    Expanded(
                        child: _Input(
                      k: k,
                      ctrl: _cPat,
                      hint: 'Ex: 12345',
                      type: TextInputType.number,
                      suffixIcon: _cPat.text.isNotEmpty
                          ? const Icon(Icons.search_rounded,
                              size: 16, color: _kCyan)
                          : null,
                      onChanged: (v) {
                        setState(() {});
                        _onPatChanged(v);
                      },
                    )),
                    const SizedBox(width: 10),
                    Expanded(
                        child: _Input(
                      k: k,
                      ctrl: _cNos,
                      hint: 'Ex: 5281174',
                      type: TextInputType.number,
                      errLabel: _errLabel('nos'),
                      onChanged: (_) => setState(() => _erros.remove('nos')),
                    )),
                  ]),
                  if (_eqData != null) ...[
                    const SizedBox(height: 8),
                    _EqBadge(data: _eqData!, k: k),
                  ],
                  const SizedBox(height: 16),
                  _RowLabel(k: k, labels: const ['Nome do Cliente']),
                  const SizedBox(height: 6),
                  _Input(
                    k: k,
                    ctrl: _cNome,
                    hint: 'Selecione acima ou digite o nome',
                    prefixIcon: _emailCli.isNotEmpty
                        ? const Icon(Icons.person_rounded,
                            size: 16, color: _kViolet)
                        : null,
                    errLabel: _errLabel('nome'),
                    onChanged: (_) => setState(() => _erros.remove('nome')),
                  ),
                  if (_emailCli.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    _EmailTag(email: _emailCli, k: k),
                  ],
                  const SizedBox(height: 16),
                  _RowLabel(k: k, labels: const ['Equipamento', 'Técnico']),
                  const SizedBox(height: 6),
                  Row(children: [
                    Expanded(
                        child: _Dropdown(
                      k: k,
                      hint: 'EQUIPAMENTO',
                      value: _equips.contains(_equip) ? _equip : null,
                      items: _equips,
                      searchable: true,
                      errLabel: _errLabel('equip'),
                      onChanged: (v) => setState(() {
                        _equip = v;
                        _erros.remove('equip');
                      }),
                    )),
                    const SizedBox(width: 10),
                    Expanded(
                        child: _Dropdown(
                      k: k,
                      hint: 'TÉCNICO',
                      value: _tecs.contains(_tec) ? _tec : null,
                      items: _tecs,
                      searchable: true,
                      errLabel: _errLabel('tec'),
                      onChanged: (v) => setState(() {
                        _tec = v;
                        _erros.remove('tec');
                      }),
                    )),
                  ]),
                  if (_tec != null && _tec != 'NÃO DEFINIDO') ...[
                    const SizedBox(height: 8),
                    _TecRow(nome: _tec!, foto: _tFoto[_tec!], k: k),
                  ],
                  const SizedBox(height: 16),
                  _RowLabel(k: k, labels: const ['Mês', 'Ano']),
                  const SizedBox(height: 6),
                  Row(children: [
                    Expanded(
                        child: _Dropdown(
                      k: k,
                      hint: 'MÊS',
                      value: _mes,
                      items: List.from(_kMeses),
                      onChanged: (v) {
                        if (v != null) setState(() => _mes = v);
                      },
                    )),
                    const SizedBox(width: 10),
                    Expanded(
                        child: _Input(
                      k: k,
                      ctrl: _cAno,
                      hint: '2026',
                      type: TextInputType.number,
                    )),
                  ]),
                  const SizedBox(height: 16),
                  _RowLabel(k: k, labels: const ['Status']),
                  const SizedBox(height: 6),
                  _StatusBadge(k: k, status: _status),
                  if (_status == 'INICIOU O SERVIÇO' ||
                      _status == 'CONCLUÍDA') ...[
                    const SizedBox(height: 16),
                    _RowLabel(k: k, labels: const ['Data do Serviço']),
                    const SizedBox(height: 6),
                    _Input(
                      k: k,
                      ctrl: _cData,
                      hint: 'DD/MM/AAAA',
                      type: TextInputType.number,
                      fmt: _maskDt,
                    ),
                  ],
                  const SizedBox(height: 16),
                  _RowLabel(k: k, labels: const ['Descrição do Defeito']),
                  const SizedBox(height: 6),
                  _Input(
                    k: k,
                    ctrl: _cDefei,
                    hint: 'Descreva o defeito...',
                    maxLines: 4,
                  ),
                  if (_tentou && _erros.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _ErrBanner(count: _erros.length, k: k),
                  ],
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
          _Footer(
            k: k,
            loading: _salvando,
            onCadastrar: _salvando ? null : _cadastrar,
            onCancelar: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  HEADER
// ═══════════════════════════════════════════════════════════════
class _Header extends StatelessWidget {
  const _Header({required this.k});
  final _K k;

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 20, 18, 16),
            child: Row(children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_kViolet, _kCyan],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                        color: _kViolet.withOpacity(.35),
                        blurRadius: 10,
                        offset: const Offset(0, 3))
                  ],
                ),
                child: const Icon(Icons.assignment_add,
                    color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('CADASTRAR NOVA O.S',
                        style: GoogleFonts.interTight(
                          fontSize: 17,
                          color: k.ink,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                        )),
                    Text('Preencha os dados da ordem de serviço',
                        style: GoogleFonts.inter(
                          fontSize: 11.5,
                          color: k.ink3,
                        )),
                  ],
                ),
              ),
            ]),
          ),
          Container(
              height: 2,
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [_kViolet, _kCyan]),
              )),
        ],
      );
}

// ═══════════════════════════════════════════════════════════════
//  BOTÃO BUSCAR CLIENTE
// ═══════════════════════════════════════════════════════════════
class _BtnCliente extends StatefulWidget {
  const _BtnCliente({required this.k, required this.onTap});
  final _K k;
  final VoidCallback onTap;
  @override
  State<_BtnCliente> createState() => _BtnClienteState();
}

class _BtnClienteState extends State<_BtnCliente>
    with SingleTickerProviderStateMixin {
  late AnimationController _ac;
  @override
  void initState() {
    super.initState();
    _ac = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 100),
        lowerBound: 0.95,
        upperBound: 1.0,
        value: 1.0);
  }

  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final k = widget.k;
    return GestureDetector(
      onTapDown: (_) => _ac.reverse(),
      onTapUp: (_) {
        _ac.forward();
        widget.onTap();
      },
      onTapCancel: () => _ac.forward(),
      child: ScaleTransition(
        scale: _ac,
        child: Container(
          width: double.infinity,
          height: 62,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _kViolet.withOpacity(k.dark ? .18 : .12),
                _kCyan.withOpacity(k.dark ? .12 : .08),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _kViolet.withOpacity(.4), width: 1.5),
            boxShadow: [
              BoxShadow(
                  color: _kViolet.withOpacity(.12),
                  blurRadius: 12,
                  offset: const Offset(0, 3))
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: _kViolet.withOpacity(.2),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(Icons.person_search_rounded,
                    color: _kViolet, size: 18),
              ),
              const SizedBox(width: 12),
              Text('BUSCAR CLIENTE',
                  style: _ks(14, c: _kViolet, b: true, ls: .5)),
              const SizedBox(width: 10),
              const Icon(Icons.arrow_forward_ios_rounded,
                  color: _kViolet, size: 13),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  LABEL DE ROW
// ═══════════════════════════════════════════════════════════════
class _RowLabel extends StatelessWidget {
  const _RowLabel({required this.k, required this.labels});
  final _K k;
  final List<String> labels;
  @override
  Widget build(BuildContext context) => labels.length == 1
      ? Text(labels[0], style: _ks(10, c: k.ink3, ls: 1.2, b: true))
      : Row(children: [
          Expanded(
              child:
                  Text(labels[0], style: _ks(10, c: k.ink3, ls: 1.2, b: true))),
          const SizedBox(width: 10),
          Expanded(
              child:
                  Text(labels[1], style: _ks(10, c: k.ink3, ls: 1.2, b: true))),
        ]);
}

// ═══════════════════════════════════════════════════════════════
//  INPUT
// ═══════════════════════════════════════════════════════════════
class _Input extends StatefulWidget {
  const _Input({
    required this.k,
    required this.ctrl,
    this.hint,
    this.maxLines = 1,
    this.type,
    this.fmt,
    this.errLabel,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
  });
  final _K k;
  final TextEditingController ctrl;
  final String? hint;
  final int maxLines;
  final TextInputType? type;
  final MaskTextInputFormatter? fmt;
  final String? errLabel;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final void Function(String)? onChanged;

  @override
  State<_Input> createState() => _InputState();
}

class _InputState extends State<_Input> {
  bool _focus = false;
  @override
  Widget build(BuildContext context) {
    final k = widget.k;
    final err = widget.errLabel != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Focus(
          onFocusChange: (v) => setState(() => _focus = v),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            constraints:
                BoxConstraints(minHeight: widget.maxLines > 1 ? 90 : 46),
            decoration: BoxDecoration(
              color: err
                  ? _kRose.withOpacity(.05)
                  : _focus
                      ? _kCyan.withOpacity(k.dark ? .06 : .04)
                      : k.input,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: err
                    ? _kRose
                    : _focus
                        ? _kCyan.withOpacity(.6)
                        : k.bord,
                width: err || _focus ? 1.5 : 1,
              ),
            ),
            child: TextFormField(
              controller: widget.ctrl,
              maxLines: widget.maxLines,
              keyboardType: widget.type,
              inputFormatters: widget.fmt != null ? [widget.fmt!] : null,
              style: _ks(14, c: k.ink),
              onChanged: widget.onChanged,
              decoration: InputDecoration(
                isDense: true,
                hintText: widget.hint,
                hintStyle: _ks(13, c: k.ink3),
                filled: true,
                fillColor: Colors.transparent,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: widget.maxLines > 1 ? 12 : 10,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                prefixIcon: widget.prefixIcon != null
                    ? Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: widget.prefixIcon)
                    : null,
                prefixIconConstraints:
                    const BoxConstraints(minWidth: 32, minHeight: 0),
                suffixIcon: err
                    ? const Icon(Icons.error_outline_rounded,
                        color: _kRose, size: 17)
                    : widget.suffixIcon != null
                        ? Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: widget.suffixIcon)
                        : null,
                suffixIconConstraints:
                    const BoxConstraints(minWidth: 32, minHeight: 0),
              ),
              cursorColor: _kCyan,
            ),
          ),
        ),
        if (err) ...[
          const SizedBox(height: 4),
          Row(children: [
            const Icon(Icons.info_outline_rounded, color: _kRose, size: 11),
            const SizedBox(width: 4),
            Text(widget.errLabel!, style: _ks(11, c: _kRose)),
          ]),
        ] else
          const SizedBox(height: 0),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  DROPDOWN
// ═══════════════════════════════════════════════════════════════
class _Dropdown extends StatefulWidget {
  const _Dropdown({
    required this.k,
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
    this.searchable = false,
    this.errLabel,
  });
  final _K k;
  final String hint;
  final String? value;
  final List<String> items;
  final void Function(String?) onChanged;
  final bool searchable;
  final String? errLabel;

  @override
  State<_Dropdown> createState() => _DropdownState();
}

class _DropdownState extends State<_Dropdown> {
  bool _press = false;

  void _open() => showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        isDismissible: true,
        enableDrag: true,
        useSafeArea: true,
        builder: (_) => _Sheet(
          k: widget.k,
          hint: widget.hint,
          value: widget.value,
          items: widget.items,
          onChanged: widget.onChanged,
          searchable: widget.searchable,
        ),
      );

  @override
  Widget build(BuildContext context) {
    final k = widget.k;
    final err = widget.errLabel != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTapDown: (_) => setState(() => _press = true),
          onTapUp: (_) {
            setState(() => _press = false);
            _open();
          },
          onTapCancel: () => setState(() => _press = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            height: 46,
            decoration: BoxDecoration(
              color: err
                  ? _kRose.withOpacity(.05)
                  : _press
                      ? _kCyan.withOpacity(.06)
                      : k.input,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: err
                    ? _kRose
                    : _press
                        ? _kCyan
                        : k.bord,
                width: err || _press ? 1.5 : 1,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(children: [
              Expanded(
                  child: Text(
                widget.value ?? widget.hint,
                style: _ks(14,
                    c: widget.value != null
                        ? k.ink
                        : err
                            ? _kRose.withOpacity(.8)
                            : k.ink3),
                overflow: TextOverflow.ellipsis,
              )),
              err
                  ? const Icon(Icons.error_outline_rounded,
                      color: _kRose, size: 17)
                  : Icon(Icons.keyboard_arrow_down_rounded,
                      color: _press ? _kCyan : k.ink3, size: 22),
            ]),
          ),
        ),
        if (err) ...[
          const SizedBox(height: 4),
          Row(children: [
            const Icon(Icons.info_outline_rounded, color: _kRose, size: 11),
            const SizedBox(width: 4),
            Text(widget.errLabel!, style: _ks(11, c: _kRose)),
          ]),
        ] else
          const SizedBox(height: 0),
      ],
    );
  }
}

class _Sheet extends StatefulWidget {
  const _Sheet({
    required this.k,
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
    this.searchable = false,
  });
  final _K k;
  final String hint;
  final String? value;
  final List<String> items;
  final void Function(String?) onChanged;
  final bool searchable;
  @override
  State<_Sheet> createState() => _SheetState();
}

class _SheetState extends State<_Sheet> {
  List<String> _filt = [];
  final _sc = TextEditingController();
  @override
  void initState() {
    super.initState();
    _filt = widget.items;
  }

  @override
  Widget build(BuildContext context) {
    final k = widget.k;
    return Container(
      decoration: BoxDecoration(
        color: k.bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        border: Border(top: BorderSide(color: k.bord2, width: 1)),
      ),
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: .55,
        maxChildSize: .92,
        shouldCloseOnMinExtent: true,
        builder: (_, ctrl) => Column(children: [
          Center(
              child: Container(
            margin: const EdgeInsets.only(top: 10, bottom: 8),
            width: 36,
            height: 4,
            decoration: BoxDecoration(
                color: k.bord2, borderRadius: BorderRadius.circular(2)),
          )),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Text(widget.hint, style: _ks(15, c: k.ink, b: true))),
          if (widget.searchable) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: k.input,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: k.bord),
                ),
                child: Row(children: [
                  const SizedBox(width: 12),
                  Icon(Icons.search_rounded, color: k.ink3, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                      child: TextField(
                    controller: _sc,
                    style: _ks(13, c: k.ink),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      hintText: 'Pesquisar...',
                      hintStyle: _ks(13, c: k.ink3),
                    ),
                    onChanged: (q) => setState(() {
                      _filt = widget.items
                          .where(
                              (i) => i.toLowerCase().contains(q.toLowerCase()))
                          .toList();
                    }),
                  )),
                ]),
              ),
            ),
          ],
          Divider(color: k.bord, height: 1),
          Expanded(
              child: ListView.builder(
            controller: ctrl,
            itemCount: _filt.length,
            itemBuilder: (_, i) {
              final item = _filt[i];
              final sel = item == widget.value;
              return ListTile(
                tileColor:
                    sel ? _kViolet.withOpacity(k.dark ? .12 : .07) : null,
                title: Text(item,
                    style: _ks(14, c: sel ? _kViolet : k.ink, b: sel)),
                trailing: sel
                    ? Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _kViolet.withOpacity(.15),
                            border:
                                Border.all(color: _kViolet.withOpacity(.5))),
                        child: const Icon(Icons.check_rounded,
                            color: _kViolet, size: 13))
                    : null,
                onTap: () {
                  widget.onChanged(item);
                  Navigator.pop(context);
                },
              );
            },
          )),
        ]),
      ),
    );
  }

  @override
  void dispose() {
    _sc.dispose();
    super.dispose();
  }
}

// ═══════════════════════════════════════════════════════════════
//  STATUS BADGE
// ═══════════════════════════════════════════════════════════════
class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.k, required this.status});
  final _K k;
  final String status;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: const Color(0xFF64748B).withOpacity(.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF64748B).withOpacity(.3)),
        ),
        child: Row(children: [
          const Icon(Icons.lock_outline_rounded,
              color: Color(0xFF64748B), size: 15),
          const SizedBox(width: 8),
          Expanded(
              child: Text(status,
                  style: _ks(13, c: const Color(0xFF94A3B8), b: true))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFF64748B).withOpacity(.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text('FIXO',
                style: _ks(9, c: const Color(0xFF64748B), b: true, ls: .5)),
          ),
        ]),
      );
}

// ═══════════════════════════════════════════════════════════════
//  EMAIL TAG
// ═══════════════════════════════════════════════════════════════
class _EmailTag extends StatelessWidget {
  const _EmailTag({required this.email, required this.k});
  final String email;
  final _K k;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: _kViolet.withOpacity(.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _kViolet.withOpacity(.25)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.email_outlined, color: _kViolet, size: 12),
          const SizedBox(width: 5),
          Flexible(
              child: Text(email,
                  style: _ks(11, c: _kViolet),
                  overflow: TextOverflow.ellipsis)),
        ]),
      );
}

// ═══════════════════════════════════════════════════════════════
//  BADGE EQUIPAMENTO ENCONTRADO
// ═══════════════════════════════════════════════════════════════
class _EqBadge extends StatelessWidget {
  const _EqBadge({required this.data, required this.k});
  final Map<String, dynamic> data;
  final _K k;
  @override
  Widget build(BuildContext context) {
    final eq = (data['EQUIPAMENTO'] ?? '').toString();
    final sal = (data['SALA'] ?? '').toString();
    final set = (data['SETOR'] ?? '').toString();
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: _kEmerald.withOpacity(.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _kEmerald.withOpacity(.3)),
      ),
      child: Row(children: [
        const Icon(Icons.check_circle_rounded, color: _kEmerald, size: 16),
        const SizedBox(width: 8),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Equipamento encontrado',
              style: _ks(9, c: _kEmerald, b: true, ls: .5)),
          const SizedBox(height: 2),
          Text(eq, style: _ks(13, b: true), overflow: TextOverflow.ellipsis),
          if (sal.isNotEmpty || set.isNotEmpty)
            Text('$sal  •  $set',
                style: _ks(11, c: k.ink3), overflow: TextOverflow.ellipsis),
        ])),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  TÉCNICO SELECIONADO
// ═══════════════════════════════════════════════════════════════
class _TecRow extends StatelessWidget {
  const _TecRow({required this.nome, this.foto, required this.k});
  final String nome;
  final String? foto;
  final _K k;
  String get _ini => nome
      .split(' ')
      .take(2)
      .map((w) => w.isNotEmpty ? w[0] : '')
      .join()
      .toUpperCase();
  @override
  Widget build(BuildContext context) {
    final String? url = _fotoValida(foto) ? foto! : null;
    return Row(children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: url == null
                ? const LinearGradient(
                    colors: [_kViolet, _kCyan],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight)
                : null,
            border: Border.all(color: _kCyan.withOpacity(.35), width: 1.5),
          ),
          child: ClipOval(
              child: url != null
                  ? Image.network(url,
                      width: 32,
                      height: 32,
                      fit: BoxFit.cover,
                      webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
                      errorBuilder: (_, __, ___) => _IniBox(ini: _ini))
                  : _IniBox(ini: _ini)),
        ),
        const SizedBox(width: 8),
        Flexible(
            child: Text(nome,
                style: _ks(12, c: k.ink2), overflow: TextOverflow.ellipsis)),
      ]);
  }
}

class _IniBox extends StatelessWidget {
  const _IniBox({required this.ini});
  final String ini;
  @override
  Widget build(BuildContext context) => Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
              colors: [_kViolet, _kCyan],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight),
        ),
        child:
            Center(child: Text(ini, style: _ks(10, c: Colors.white, b: true))),
      );
}

// ═══════════════════════════════════════════════════════════════
//  BANNER DE ERROS
// ═══════════════════════════════════════════════════════════════
class _ErrBanner extends StatelessWidget {
  const _ErrBanner({required this.count, required this.k});
  final int count;
  final _K k;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: _kRose.withOpacity(.09),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _kRose.withOpacity(.3)),
        ),
        child: Row(children: [
          const Icon(Icons.error_outline_rounded, color: _kRose, size: 16),
          const SizedBox(width: 8),
          Expanded(
              child: Text(
            '$count campo${count > 1 ? "s obrigatórios não preenchidos" : " obrigatório não preenchido"}',
            style: _ks(12, c: _kRose),
          )),
        ]),
      );
}

// ═══════════════════════════════════════════════════════════════
//  FOOTER
// ═══════════════════════════════════════════════════════════════
class _Footer extends StatelessWidget {
  const _Footer({
    required this.k,
    required this.loading,
    required this.onCadastrar,
    required this.onCancelar,
  });
  final _K k;
  final bool loading;
  final VoidCallback? onCadastrar;
  final VoidCallback onCancelar;

  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsets.fromLTRB(
            16, 12, 16, 16 + MediaQuery.of(context).padding.bottom),
        decoration: BoxDecoration(
          color: k.bg,
          border: Border(top: BorderSide(color: k.bord)),
        ),
        child: Row(children: [
          Expanded(
              child: GestureDetector(
            onTap: onCancelar,
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: k.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: k.bord2),
              ),
              child: Center(
                  child: Text('Cancelar', style: _ks(14, c: k.ink2, b: true))),
            ),
          )),
          const SizedBox(width: 12),
          Expanded(
              flex: 2,
              child: GestureDetector(
                onTap: onCadastrar,
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: onCadastrar != null
                        ? const LinearGradient(
                            colors: [_kViolet, _kCyan],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight)
                        : null,
                    color: onCadastrar == null ? k.bord : null,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: onCadastrar != null
                        ? [
                            BoxShadow(
                                color: _kViolet.withOpacity(.35),
                                blurRadius: 12,
                                offset: const Offset(0, 4))
                          ]
                        : null,
                  ),
                  child: Center(
                      child: loading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2.5))
                          : Row(mainAxisSize: MainAxisSize.min, children: [
                              const Icon(Icons.check_circle_rounded,
                                  color: Colors.white, size: 17),
                              const SizedBox(width: 8),
                              Text('CADASTRAR O.S',
                                  style: _ks(14, c: Colors.white, b: true)),
                            ])),
                ),
              )),
        ]),
      );
}

// ═══════════════════════════════════════════════════════════════
//  VISUALIZAR EQUIPAMENTO (sheet)
// ═══════════════════════════════════════════════════════════════
class _EquipSheet extends StatelessWidget {
  const _EquipSheet({required this.data, required this.k});
  final Map<String, dynamic> data;
  final _K k;
  @override
  Widget build(BuildContext context) {
    String f(String key) => (data[key] ?? '—').toString();
    return Container(
      decoration: BoxDecoration(
        color: k.bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        border:
            Border(top: BorderSide(color: _kEmerald.withOpacity(.5), width: 2)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Center(
            child: Container(
          width: 36,
          height: 4,
          decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [_kEmerald, _kCyan]),
              borderRadius: BorderRadius.circular(2)),
        )),
        const SizedBox(height: 14),
        Row(children: [
          Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                  color: _kEmerald.withOpacity(.14),
                  borderRadius: BorderRadius.circular(11)),
              child: const Icon(Icons.devices_other_rounded,
                  color: _kEmerald, size: 20)),
          const SizedBox(width: 12),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text('EQUIPAMENTO ENCONTRADO',
                    style: _ks(10, c: _kEmerald, b: true, ls: 1)),
                Text(f('EQUIPAMENTO'),
                    style: _ks(15, b: true), overflow: TextOverflow.ellipsis),
              ])),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                  color: _kEmerald.withOpacity(.14),
                  borderRadius: BorderRadius.circular(8)),
              child: Text('OK', style: _ks(13, c: _kEmerald, b: true)),
            ),
          ),
        ]),
        const SizedBox(height: 14),
        Wrap(spacing: 10, runSpacing: 10, children: [
          _IC(label: 'PATRIMÔNIO', value: f('PATRIMONIO'), k: k),
          _IC(label: 'MARCA', value: f('MARCA'), k: k),
          _IC(label: 'MODELO', value: f('MODELO'), k: k),
          _IC(label: 'SALA', value: f('SALA'), k: k),
          _IC(label: 'SETOR', value: f('SETOR'), k: k),
          _IC(label: 'EMAIL', value: f('EMAIL'), k: k),
        ]),
      ]),
    );
  }
}

class _IC extends StatelessWidget {
  const _IC({required this.label, required this.value, required this.k});
  final String label, value;
  final _K k;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: k.card,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: k.bord),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: _ks(8, c: k.ink3, ls: 1)),
          const SizedBox(height: 2),
          Text(value, style: _ks(12, b: true), overflow: TextOverflow.ellipsis),
        ]),
      );
}

// ═══════════════════════════════════════════════════════════════
//  RESULTADO DA BUSCA DE CLIENTE
// ═══════════════════════════════════════════════════════════════
class _CR {
  final String nome, email, foto, onesignal;
  const _CR({
    required this.nome,
    required this.email,
    this.foto = '',
    this.onesignal = '',
  });
}

// ═══════════════════════════════════════════════════════════════
//  SHEET DE BUSCAR CLIENTE
// ═══════════════════════════════════════════════════════════════
class _ClienteSheet extends StatefulWidget {
  const _ClienteSheet({required this.k});
  final _K k;
  @override
  State<_ClienteSheet> createState() => _ClienteSheetState();
}

class _ClienteSheetState extends State<_ClienteSheet> {
  final _db = FirebaseFirestore.instance;
  final _ctrl = TextEditingController();

  List<Map<String, dynamic>> _all = [];
  List<Map<String, dynamic>> _filtered = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    try {
      final snap =
          await FirebaseFirestore.instance.collection('USUARIOS').get();
      final list = <Map<String, dynamic>>[];
      for (final doc in snap.docs) {
        final d = doc.data();
        final nome = (d['display_name'] ?? '').toString().trim();
        final em = (d['email'] ?? '').toString().trim();
        final foto = (d['photo_url'] ?? '').toString().trim();
        final os = (d['ONESIGNAL'] ?? '').toString().trim();
        if (nome.isNotEmpty || em.isNotEmpty) {
          list.add({'nome': nome, 'email': em, 'foto': foto, 'onesignal': os});
        }
      }
      setState(() {
        _all = list;
        _filtered = list;
        _loading = false;
      });
    } catch (e) {
      debugPrint('USUARIOS: $e');
      setState(() => _loading = false);
    }
  }

  void _search(String q) {
    final query = q.toLowerCase().trim();
    setState(() {
      _filtered = query.isEmpty
          ? _all
          : _all.where((m) {
              final n = (m['nome'] ?? '').toString().toLowerCase();
              final e = (m['email'] ?? '').toString().toLowerCase();
              return n.contains(query) || e.contains(query);
            }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final k = widget.k;
    return Container(
      height: MediaQuery.of(context).size.height * .82,
      decoration: BoxDecoration(
        color: k.bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        border:
            Border(top: BorderSide(color: _kViolet.withOpacity(.5), width: 2)),
      ),
      child: Column(children: [
        Center(
            child: Container(
          margin: const EdgeInsets.only(top: 10, bottom: 6),
          width: 36,
          height: 4,
          decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [_kViolet, _kCyan]),
              borderRadius: BorderRadius.circular(2)),
        )),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 8, 12),
          child: Row(children: [
            Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                    color: _kViolet.withOpacity(.14),
                    borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.people_rounded,
                    color: _kViolet, size: 18)),
            const SizedBox(width: 12),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text('Buscar Cliente', style: _ks(16, c: k.ink, b: true)),
                  Text('Digite o nome da empresa ou email',
                      style: _ks(11, c: k.ink3)),
                ])),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
          child: Container(
            height: 46,
            decoration: BoxDecoration(
              color: k.input,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _kViolet.withOpacity(.35), width: 1.5),
            ),
            child: Row(children: [
              const SizedBox(width: 12),
              Icon(Icons.search_rounded, color: k.ink3, size: 18),
              const SizedBox(width: 8),
              Expanded(
                  child: TextField(
                controller: _ctrl,
                autofocus: true,
                style: _ks(14, c: k.ink),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  hintText: 'Digite o nome da empresa ou email',
                  hintStyle: _ks(13, c: k.ink3),
                ),
                onChanged: _search,
              )),
              if (_ctrl.text.isNotEmpty)
                IconButton(
                  icon: Icon(Icons.clear, color: k.ink3, size: 18),
                  onPressed: () {
                    _ctrl.clear();
                    _search('');
                  },
                ),
            ]),
          ),
        ),
        Divider(color: k.bord, height: 1),
        Expanded(
            child: _loading
                ? Center(
                    child: CircularProgressIndicator(
                        color: _kViolet, strokeWidth: 2))
                : _filtered.isEmpty
                    ? Center(
                        child:
                            Column(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.search_off_rounded, color: k.ink3, size: 40),
                        const SizedBox(height: 10),
                        Text(
                            _ctrl.text.isEmpty
                                ? 'Nenhum cliente cadastrado'
                                : 'Nenhum resultado',
                            style: _ks(13, c: k.ink3)),
                      ]))
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(0, 4, 0, 24),
                        itemCount: _filtered.length,
                        separatorBuilder: (_, __) =>
                            Divider(color: k.bord, height: 1),
                        itemBuilder: (_, i) {
                          final m = _filtered[i];
                          final nome = (m['nome'] ?? '').toString();
                          final em = (m['email'] ?? '').toString();
                          final foto = (m['foto'] ?? '').toString();
                          final os = (m['onesignal'] ?? '').toString();
                          final ini =
                              nome.isNotEmpty ? nome[0].toUpperCase() : '?';
                          return ListTile(
                            onTap: () => Navigator.pop(
                                context,
                                _CR(
                                    nome: nome,
                                    email: em,
                                    foto: foto,
                                    onesignal: os)),
                            leading: CircleAvatar(
                              radius: 20,
                              backgroundImage:
                                  foto.isNotEmpty ? NetworkImage(foto) : null,
                              backgroundColor: _kViolet.withOpacity(.18),
                              child: foto.isEmpty
                                  ? Text(ini,
                                      style: _ks(14, c: _kViolet, b: true))
                                  : null,
                            ),
                            title: Text(nome.isNotEmpty ? nome : em,
                                style: _ks(14, c: k.ink, b: true),
                                overflow: TextOverflow.ellipsis),
                            subtitle: em.isNotEmpty
                                ? Text(em,
                                    style: _ks(11, c: k.ink3),
                                    overflow: TextOverflow.ellipsis)
                                : null,
                            trailing: Icon(Icons.chevron_right,
                                color: k.ink3, size: 18),
                          );
                        },
                      )),
      ]),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }
}
