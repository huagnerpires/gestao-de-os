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

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class RelatorioEquipamentosWidget extends StatefulWidget {
  const RelatorioEquipamentosWidget({
    Key? key,
    this.width,
    this.height,
  }) : super(key: key);
  final double? width;
  final double? height;
  @override
  State<RelatorioEquipamentosWidget> createState() =>
      _RelatorioEquipamentosWidgetState();
}

class _RelatorioEquipamentosWidgetState
    extends State<RelatorioEquipamentosWidget> with TickerProviderStateMixin {
  // ── Cores ──────────────────────────────────────────────────────────────────
  static const Color _primary = Color(0xFF1E40AF);
  static const Color _primaryDark = Color(0xFF0D47A1);

  // ── PDF cores ─────────────────────────────────────────────────────────────
  static final PdfColor _cp = PdfColor.fromHex('1E40AF');
  static final PdfColor _cpd = PdfColor.fromHex('0D47A1');
  static final PdfColor _ct = PdfColor.fromHex('0A1628');
  static final PdfColor _cs = PdfColor.fromHex('546E7A');
  static final PdfColor _cb = PdfColor.fromHex('EEF2F8');
  static final PdfColor _cd = PdfColor.fromHex('DDEAFF');
  static final PdfColor _w70 = PdfColor(1, 1, 1, 0.70);
  static final PdfColor _w24 = PdfColor(1, 1, 1, 0.24);

  // ── URLs ───────────────────────────────────────────────────────────────────
  static const String _urlLogo =
      'https://firebasestorage.googleapis.com/v0/b/h-p-s-modificado-emdcp0.appspot.com/o/Imagem1.jpg?alt=media&token=40b2f275-19ed-45c9-9f81-3d49d20d9020';
  static const String _urlBanner =
      'https://firebasestorage.googleapis.com/v0/b/h-p-s-modificado-emdcp0.appspot.com/o/logo%20email%20(1)%20(1)%20(1)%20(1).png?alt=media&token=5c018b59-c7be-4a7d-9736-f7d51f38d25e';

  // ── Estado principal ───────────────────────────────────────────────────────
  List<Map<String, dynamic>> _clientes = [];
  Map<String, dynamic>? _clienteSel;
  Map<String, dynamic>? _dadosCliente;
  List<Map<String, dynamic>> _equipamentos = [];
  bool _carregandoClientes = true;
  bool _carregandoEquip = false;
  bool _gerandoPdf = false;
  bool _gerandoContrato = false;
  String _busca = '';
  String _filtroT = 'TODOS';
  String _filtroS = 'TODOS';
  final TextEditingController _buscaCtrl = TextEditingController();
  StreamSubscription? _equipSub;
  late AnimationController _shimmer;

  // ── Estado do contrato (linhas dinâmicas) ─────────────────────────────────
  final List<TextEditingController> _cDescCtrls = [];
  final List<TextEditingController> _cValorCtrls = [];
  double _cTotal = 0.0;
  final TextEditingController _cVigenciaCtrl =
      TextEditingController(text: '12');
  final TextEditingController _cDataCtrl = TextEditingController();
  final TextEditingController _cPeriodicidadeCtrl =
      TextEditingController(text: 'MENSAL');
  final TextEditingController _cObjetoCtrl = TextEditingController();
  final TextEditingController _cObsCtrl = TextEditingController();

  // ── Getters filtro ─────────────────────────────────────────────────────────
  List<String> get _tipos {
    final t = _equipamentos
        .map((e) => e['TIPO']?.toString() ?? '')
        .where((s) => s.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    return ['TODOS', ...t];
  }

  List<String> get _setores {
    final s = _equipamentos
        .map((e) => e['SETOR']?.toString() ?? '')
        .where((s) => s.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    return ['TODOS', ...s];
  }

  List<Map<String, dynamic>> get _filtrados {
    return _equipamentos.where((e) {
      final q = _busca.toLowerCase();
      if (q.isNotEmpty) {
        final f = [
          e['EQUIPAMENTO'],
          e['NOME'],
          e['SALA'],
          e['SETOR'],
          e['PATRIMONIO'],
          e['MARCA'],
          e['MODELO'],
          e['TIPO'],
          e['RESPONSAVEL']
        ].map((v) => (v?.toString() ?? '').toLowerCase()).join(' ');
        if (!f.contains(q)) return false;
      }
      if (_filtroT != 'TODOS' && (e['TIPO']?.toString() ?? '') != _filtroT)
        return false;
      if (_filtroS != 'TODOS' && (e['SETOR']?.toString() ?? '') != _filtroS)
        return false;
      return true;
    }).toList()
      ..sort((a, b) =>
          (a['SALA'] ?? '').toString().compareTo((b['SALA'] ?? '').toString()));
  }

  // ── Tema ───────────────────────────────────────────────────────────────────
  bool get _dark => Theme.of(context).brightness == Brightness.dark;
  Color get _bg => _dark ? const Color(0xFF090F1A) : const Color(0xFFF0F3F8);
  Color get _card => _dark ? const Color(0xFF111827) : Colors.white;
  Color get _surf => _dark ? const Color(0xFF1A2235) : const Color(0xFFF5F7FB);
  Color get _textP => _dark ? const Color(0xFFE3EAF5) : const Color(0xFF0A1628);
  Color get _textS => _dark ? const Color(0xFF7B9CC8) : const Color(0xFF546E7A);
  Color get _divC => _dark ? const Color(0xFF1E2D45) : const Color(0xFFDDEAFF);

  @override
  void initState() {
    super.initState();
    _shimmer = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400))
      ..repeat();
    _cObjetoCtrl.text =
        'O presente contrato tem como objeto a prestação de serviços de manutenção preventiva em equipamentos de refrigeração e climatização, conforme relação de equipamentos constante no Anexo I.';
    final n = DateTime.now();
    _cDataCtrl.text =
        '${n.day.toString().padLeft(2, '0')}/${n.month.toString().padLeft(2, '0')}/${n.year}';
    _carregarClientes();
  }

  @override
  void dispose() {
    _shimmer.dispose();
    _buscaCtrl.dispose();
    _equipSub?.cancel();
    for (final c in _cDescCtrls) c.dispose();
    for (final c in _cValorCtrls) c.dispose();
    _cVigenciaCtrl.dispose();
    _cDataCtrl.dispose();
    _cPeriodicidadeCtrl.dispose();
    _cObjetoCtrl.dispose();
    _cObsCtrl.dispose();
    super.dispose();
  }

  // ── Carregar clientes ──────────────────────────────────────────────────────
  Future<void> _carregarClientes() async {
    setState(() => _carregandoClientes = true);
    try {
      final snap = await FirebaseFirestore.instance
          .collection('USUARIOS')
          .orderBy('display_name')
          .get();
      final lista = <Map<String, dynamic>>[];
      for (final doc in snap.docs) {
        final d = doc.data();
        final email = (d['email'] ?? '').toString();
        if (email.isEmpty) continue;
        lista.add({
          'id': doc.id,
          'email': email,
          'nome': (d['display_name'] ?? email).toString(),
          'photo_url': (d['photo_url'] ?? '').toString(),
        });
      }
      if (mounted)
        setState(() {
          _clientes = lista;
          _carregandoClientes = false;
        });
    } catch (_) {
      if (mounted) setState(() => _carregandoClientes = false);
    }
  }

  Future<void> _buscarDadosCliente(String email) async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('USUARIOS')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
      if (snap.docs.isNotEmpty && mounted)
        setState(() => _dadosCliente = snap.docs.first.data());
    } catch (_) {}
  }

  void _selecionarCliente(Map<String, dynamic> c) {
    _equipSub?.cancel();
    setState(() {
      _clienteSel = c;
      _dadosCliente = null;
      _equipamentos = [];
      _carregandoEquip = true;
      _busca = '';
      _buscaCtrl.clear();
      _filtroT = 'TODOS';
      _filtroS = 'TODOS';
    });
    _buscarDadosCliente(c['email']);
    _equipSub = FirebaseFirestore.instance
        .collection('EQUIPAMENTOS_EMPRESA')
        .where('EMAIL', isEqualTo: c['email'])
        .snapshots()
        .listen((snap) {
      if (!mounted) return;
      final lista = snap.docs.map((d) => {'_id': d.id, ...d.data()}).toList();
      lista.sort((a, b) =>
          (a['SALA'] ?? '').toString().compareTo((b['SALA'] ?? '').toString()));
      setState(() {
        _equipamentos = lista;
        _carregandoEquip = false;
      });
    }, onError: (_) {
      if (mounted) setState(() => _carregandoEquip = false);
    });
  }

  // ── Utilitários ────────────────────────────────────────────────────────────
  Color _tipoColor(String t) {
    final u = t.toUpperCase();
    if (u.contains('INVERTER')) return const Color(0xFF1E40AF);
    if (u.contains('CONVENC')) return const Color(0xFF5C6BC0);
    if (u.contains('SPLIT')) return const Color(0xFF1D4ED8);
    if (u.contains('CHILLER')) return const Color(0xFF0E7490);
    if (u.contains('VRF') || u.contains('VRV')) return const Color(0xFFC2410C);
    if (u.contains('CÂMARA') || u.contains('CAMARA'))
      return const Color(0xFF2E7D32);
    return const Color(0xFF607D8B);
  }

  IconData _equipIcon(String e) {
    final u = e.toUpperCase();
    if (u.contains('AR CONDICIONADO') || u.contains('SPLIT'))
      return Icons.ac_unit_rounded;
    if (u.contains('CÂMARA') || u.contains('CAMARA'))
      return Icons.kitchen_rounded;
    if (u.contains('CHILLER')) return Icons.device_thermostat_rounded;
    return Icons.thermostat_outlined;
  }

  String _dataFmt() {
    final n = DateTime.now();
    return '${n.day.toString().padLeft(2, '0')}/${n.month.toString().padLeft(2, '0')}/${n.year}';
  }

  String _mesAno() {
    const m = [
      '',
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
      'DEZEMBRO'
    ];
    final n = DateTime.now();
    return '${m[n.month]}_${n.year}';
  }

  // ── Contrato: controle das linhas ──────────────────────────────────────────
  void _contratoAddLinha() {
    setState(() {
      _cDescCtrls.add(TextEditingController());
      _cValorCtrls.add(TextEditingController());
    });
  }

  void _contratoRemoveLinha(int i) {
    _cDescCtrls[i].dispose();
    _cValorCtrls[i].dispose();
    _cDescCtrls.removeAt(i);
    _cValorCtrls.removeAt(i);
    _contratoCalcTotal();
  }

  void _contratoCalcTotal() {
    double t = 0;
    for (final c in _cValorCtrls) {
      t += double.tryParse(c.text.replaceAll(',', '.')) ?? 0;
    }
    setState(() => _cTotal = t);
  }

  void _contratoInit() {
    for (final c in _cDescCtrls) c.dispose();
    for (final c in _cValorCtrls) c.dispose();
    _cDescCtrls.clear();
    _cValorCtrls.clear();
    _cDescCtrls.add(TextEditingController());
    _cValorCtrls.add(TextEditingController());
    _cTotal = 0.0;
    _cVigenciaCtrl.text = '12';
    _cPeriodicidadeCtrl.text = 'MENSAL';
    _cObsCtrl.clear();
    final n = DateTime.now();
    _cDataCtrl.text =
        '${n.day.toString().padLeft(2, '0')}/${n.month.toString().padLeft(2, '0')}/${n.year}';
    _cObjetoCtrl.text =
        'O presente contrato tem como objeto a prestação de serviços de manutenção preventiva em equipamentos de refrigeração e climatização, conforme relação de equipamentos constante no Anexo I.';
  }

  // ── Aqui envolvemos o Dialog no StatefulBuilder ────────────────────────────
  void _abrirContrato() {
    _contratoInit();
    setState(() {}); // Atualiza parent, mas precisamos atualizar o Dialog tbm
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return _buildDialogContrato(setStateDialog);
        },
      ),
    );
  }

  // ── Dialog do contrato (Recebe setStateDialog) ─────────────────────────────
  Widget _buildDialogContrato(StateSetter setStateDialog) {
    final d = _dadosCliente ?? _clienteSel ?? {};
    final nome = d['display_name']?.toString() ?? d['nome']?.toString() ?? '';
    return Dialog(
      backgroundColor: _card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
      child: SizedBox(
        width: double.infinity,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [Color(0xFF0D47A1), Color(0xFF1E40AF)]),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(children: [
              const Icon(Icons.description_outlined,
                  color: Colors.white, size: 22),
              const SizedBox(width: 12),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    const Text('Contrato de Manutenção Preventiva',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w800)),
                    Text(nome,
                        style: TextStyle(
                            color: Colors.white.withAlpha(180), fontSize: 11)),
                  ])),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                        color: Colors.white.withAlpha(30),
                        shape: BoxShape.circle),
                    child: const Icon(Icons.close_rounded,
                        color: Colors.white, size: 18)),
              ),
            ]),
          ),
          // Corpo
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Vigência
                    _dlgSecao('VIGÊNCIA E PERIODICIDADE'),
                    const SizedBox(height: 10),
                    LayoutBuilder(builder: (ctx, constraints) {
                      final wide = constraints.maxWidth > 400;
                      if (wide) {
                        return Row(children: [
                          Expanded(
                              child: _dlgCampo('Data de Início', _cDataCtrl,
                                  Icons.calendar_today_outlined)),
                          const SizedBox(width: 10),
                          Expanded(
                              child: _dlgCampo('Vigência (meses)',
                                  _cVigenciaCtrl, Icons.timelapse_outlined,
                                  tipo: TextInputType.number)),
                          const SizedBox(width: 10),
                          Expanded(
                              child: _dlgCampo('Periodicidade',
                                  _cPeriodicidadeCtrl, Icons.repeat_outlined)),
                        ]);
                      }
                      return Column(children: [
                        _dlgCampo('Data de Início', _cDataCtrl,
                            Icons.calendar_today_outlined),
                        const SizedBox(height: 10),
                        Row(children: [
                          Expanded(
                              child: _dlgCampo('Vigência (meses)',
                                  _cVigenciaCtrl, Icons.timelapse_outlined,
                                  tipo: TextInputType.number)),
                          const SizedBox(width: 10),
                          Expanded(
                              child: _dlgCampo('Periodicidade',
                                  _cPeriodicidadeCtrl, Icons.repeat_outlined)),
                        ]),
                      ]);
                    }),
                    const SizedBox(height: 22),

                    // Valores (Corrigido o Overflow aqui com Expanded na Seção)
                    Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: _dlgSecao(
                                'DISCRIMINAÇÃO DOS SERVIÇOS / VALORES'),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                                color: _primary.withAlpha(15),
                                borderRadius: BorderRadius.circular(20),
                                border:
                                    Border.all(color: _primary.withAlpha(60))),
                            child: Text(
                                'Total: R\$ ${_cTotal.toStringAsFixed(2).replaceAll('.', ',')}',
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: _primary)),
                          ),
                        ]),
                    const SizedBox(height: 10),

                    // Cabeçalho colunas
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6, left: 30),
                      child: Row(children: [
                        Expanded(
                            flex: 3,
                            child: Text('DESCRIÇÃO / SETOR',
                                style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: _textS))),
                        const SizedBox(width: 6),
                        Expanded(
                            flex: 2,
                            child: Text('VALOR MENSAL (R\$)',
                                style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: _textS))),
                        const SizedBox(width: 36),
                      ]),
                    ),
                    // Linhas
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _cDescCtrls.length,
                      itemBuilder: (_, i) =>
                          _buildLinhaContrato(i, setStateDialog),
                    ),
                    const SizedBox(height: 8),
                    // Botão + (Agora usa o setStateDialog para refletir na tela)
                    GestureDetector(
                      onTap: () {
                        _contratoAddLinha();
                        setStateDialog(() {}); // Força o Dialog a redesenhar
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _primary.withAlpha(_dark ? 30 : 10),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: _primary.withAlpha(80), width: 1.5),
                        ),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                  width: 22,
                                  height: 22,
                                  decoration: const BoxDecoration(
                                      color: _primary, shape: BoxShape.circle),
                                  child: const Icon(Icons.add_rounded,
                                      color: Colors.white, size: 16)),
                              const SizedBox(width: 8),
                              const Text('Adicionar linha de serviço',
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: _primary)),
                            ]),
                      ),
                    ),
                    const SizedBox(height: 22),
                    // Objeto
                    _dlgSecao('OBJETO DO CONTRATO'),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                          color: _surf,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _divC)),
                      child: TextField(
                        controller: _cObjetoCtrl,
                        maxLines: 4,
                        style: TextStyle(fontSize: 13, color: _textP),
                        decoration: InputDecoration(
                            hintText: 'Descrição do objeto do contrato...',
                            hintStyle: TextStyle(fontSize: 13, color: _textS),
                            contentPadding: const EdgeInsets.all(14),
                            border: InputBorder.none),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Observações
                    _dlgSecao('OBSERVAÇÕES'),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                          color: _surf,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _divC)),
                      child: TextField(
                        controller: _cObsCtrl,
                        maxLines: 3,
                        style: TextStyle(fontSize: 13, color: _textP),
                        decoration: InputDecoration(
                            hintText: 'Observações adicionais (opcional)...',
                            hintStyle: TextStyle(fontSize: 13, color: _textS),
                            contentPadding: const EdgeInsets.all(14),
                            border: InputBorder.none),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ]),
            ),
          ),
          // Footer
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            decoration:
                BoxDecoration(border: Border(top: BorderSide(color: _divC))),
            child: Row(children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                        border: Border.all(color: _divC, width: 1.5),
                        borderRadius: BorderRadius.circular(12)),
                    child: Center(
                        child: Text('Cancelar',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: _textS))),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: GestureDetector(
                  onTap: _confirmarContrato,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [Color(0xFF0D47A1), Color(0xFF1E40AF)]),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                            color: _primary.withAlpha(80),
                            blurRadius: 12,
                            offset: const Offset(0, 4))
                      ],
                    ),
                    child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.save_rounded,
                              color: Colors.white, size: 18),
                          SizedBox(width: 8),
                          Text('GERAR E SALVAR CONTRATO',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800)),
                        ]),
                  ),
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _buildLinhaContrato(int i, StateSetter setStateDialog) {
    final red = _dark ? const Color(0xFFEF9A9A) : const Color(0xFFB91C1C);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        // Número da linha
        Container(
          width: 24,
          height: 24,
          margin: const EdgeInsets.only(right: 6),
          decoration: BoxDecoration(
              color: _primary.withAlpha(_dark ? 40 : 15),
              shape: BoxShape.circle),
          child: Center(
              child: Text('${i + 1}',
                  style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: _primary))),
        ),
        // Campo descrição
        Expanded(
          flex: 3,
          child: Container(
            height: 44,
            decoration: BoxDecoration(
                color: _surf,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _divC)),
            child: TextField(
              controller: _cDescCtrls[i],
              style: TextStyle(fontSize: 12, color: _textP),
              decoration: InputDecoration(
                hintText: 'Descrição / Setor',
                hintStyle: TextStyle(fontSize: 11, color: _textS),
                prefixIcon:
                    Icon(Icons.domain_outlined, size: 15, color: _textS),
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 13),
              ),
            ),
          ),
        ),
        const SizedBox(width: 6),
        // Campo valor
        Expanded(
          flex: 2,
          child: Container(
            height: 44,
            decoration: BoxDecoration(
                color: _surf,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _divC)),
            child: TextField(
              controller: _cValorCtrls[i],
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              onChanged: (_) {
                _contratoCalcTotal();
                setStateDialog(() {}); // Recalcula visualmente
              },
              style: TextStyle(
                  fontSize: 12, color: _textP, fontWeight: FontWeight.w700),
              decoration: InputDecoration(
                hintText: '0,00',
                hintStyle: TextStyle(fontSize: 12, color: _textS),
                prefixIcon:
                    Icon(Icons.attach_money_outlined, size: 15, color: _textS),
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 13),
              ),
            ),
          ),
        ),
        const SizedBox(width: 6),
        // Botão remover
        GestureDetector(
          onTap: _cDescCtrls.length > 1
              ? () {
                  _contratoRemoveLinha(i);
                  setStateDialog(() {}); // Força tela atualizar sem a linha
                }
              : null,
          child: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
                color: _cDescCtrls.length > 1
                    ? red.withAlpha(_dark ? 40 : 15)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: _cDescCtrls.length > 1 ? red.withAlpha(80) : _divC)),
            child: Icon(Icons.remove_rounded,
                size: 14, color: _cDescCtrls.length > 1 ? red : _textS),
          ),
        ),
      ]),
    );
  }

  // Corrigido para garantir que o texto não force telas pequenas a estourar
  Widget _dlgSecao(String t) {
    return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 3,
              height: 16,
              margin: const EdgeInsets.only(
                  top: 2), // Alinha certinho com a 1a linha
              decoration: BoxDecoration(
                  color: _primary, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 8),
          Flexible(
            child: Text(t,
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: _primary,
                    letterSpacing: 0.6)),
          ),
        ]);
  }

  Widget _dlgCampo(String label, TextEditingController ctrl, IconData icon,
      {TextInputType tipo = TextInputType.text}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style: TextStyle(
              fontSize: 10, fontWeight: FontWeight.w700, color: _textS)),
      const SizedBox(height: 5),
      Container(
        height: 44,
        decoration: BoxDecoration(
            color: _surf,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _divC)),
        child: TextField(
          controller: ctrl,
          keyboardType: tipo,
          style: TextStyle(fontSize: 13, color: _textP),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 16, color: _textS),
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 13),
          ),
        ),
      ),
    ]);
  }

  void _confirmarContrato() {
    final linhas = <String, Map<String, String>>{};
    for (int i = 0; i < _cDescCtrls.length; i++) {
      linhas['linha_$i'] = {
        'desc': _cDescCtrls[i].text,
        'valor': _cValorCtrls[i].text
      };
    }
    final vals = {
      'vigencia': _cVigenciaCtrl.text,
      'dataInicio': _cDataCtrl.text,
      'periodicidade': _cPeriodicidadeCtrl.text,
      'condicoes': _cObjetoCtrl.text,
      'observacoes': _cObsCtrl.text,
      'setorValores': linhas,
    };
    Navigator.pop(context);
    _gerarEsalvarContrato(vals);
  }

  // ── Gerar e salvar contrato ────────────────────────────────────────────────
  Future<void> _gerarEsalvarContrato(Map<String, dynamic> vals) async {
    setState(() => _gerandoContrato = true);
    try {
      final bytes = await _gerarPdfContrato(vals);
      final email = _clienteSel?['email'] ?? 'cliente';
      final mes = _mesAno();
      final path = '$email/CONTRATO/CONTRATO_PREVENTIVA_$mes.pdf';
      final ref = FirebaseStorage.instance.ref().child(path);
      await ref.putData(
          bytes, SettableMetadata(contentType: 'application/pdf'));
      await Printing.layoutPdf(
          onLayout: (_) => bytes, name: 'CONTRATO_PREVENTIVA_$mes.pdf');
      if (mounted)
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(const SnackBar(
            content: Text('✅ Contrato salvo no Storage!'),
            backgroundColor: _primary,
            duration: Duration(seconds: 3)));
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(SnackBar(
            content: Text('Erro: $e'),
            backgroundColor: const Color(0xFFB91C1C)));
    } finally {
      if (mounted) setState(() => _gerandoContrato = false);
    }
  }

  // ── Carregar imagem para PDF ───────────────────────────────────────────────
  Future<pw.ImageProvider?> _loadImg(String url) async {
    if (url.isEmpty) return null;
    try {
      final r =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 8));
      if (r.statusCode == 200) return pw.MemoryImage(r.bodyBytes);
    } catch (_) {}
    return null;
  }

  // ══════════════════════════════════════════════════════════════════════════
  // PDF HELPERS
  // ══════════════════════════════════════════════════════════════════════════
  pw.Widget _pdfTh(String t) => pw.Padding(
        padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 7),
        child: pw.Text(t,
            style: pw.TextStyle(
                color: PdfColors.white,
                fontSize: 7,
                fontWeight: pw.FontWeight.bold)),
      );

  pw.Widget _pdfTd(String t, PdfColor c,
          {bool bold = false, bool center = false}) =>
      pw.Padding(
        padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 6),
        child: pw.Text(t.isEmpty ? '-' : t,
            textAlign: center ? pw.TextAlign.center : pw.TextAlign.left,
            style: pw.TextStyle(
                fontSize: 7,
                color: c,
                fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal)),
      );

  pw.Widget _pdfTitulo(String t) => pw.Row(children: [
        pw.Container(width: 4, height: 14, color: _cpd),
        pw.SizedBox(width: 8),
        pw.Text(t,
            style: pw.TextStyle(
                fontSize: 10, fontWeight: pw.FontWeight.bold, color: _cpd)),
      ]);

  pw.Widget _pdfLinha(String label, String val, PdfColor bg) => pw.Container(
        color: bg,
        padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(label,
                  style: pw.TextStyle(
                      fontSize: 8, color: _cs, fontWeight: pw.FontWeight.bold)),
              pw.Flexible(
                  child: pw.Text(val.isEmpty ? '-' : val,
                      textAlign: pw.TextAlign.right,
                      style: pw.TextStyle(
                          fontSize: 8,
                          color: _ct,
                          fontWeight: pw.FontWeight.bold))),
            ]),
      );

  pw.Widget _pdfSecao(String titulo, List<pw.Widget> rows) => pw.Container(
        decoration: pw.BoxDecoration(
            borderRadius: pw.BorderRadius.circular(8),
            border: pw.Border.all(color: _cd, width: 0.5)),
        child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              pw.Container(
                padding:
                    const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: pw.BoxDecoration(
                    color: _cpd,
                    borderRadius: const pw.BorderRadius.vertical(
                        top: pw.Radius.circular(8))),
                child: pw.Text(titulo,
                    style: pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 9,
                        fontWeight: pw.FontWeight.bold)),
              ),
              ...rows,
            ]),
      );

  pw.Widget _pdfClausula(String num, String titulo, List<pw.Widget> items) =>
      pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(height: 10),
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: pw.BoxDecoration(
                color: _cpd, borderRadius: pw.BorderRadius.circular(6)),
            child: pw.Row(children: [
              pw.Container(
                  width: 20,
                  height: 20,
                  decoration:
                      pw.BoxDecoration(color: _w24, shape: pw.BoxShape.circle),
                  child: pw.Center(
                      child: pw.Text(num,
                          style: pw.TextStyle(
                              color: PdfColors.white,
                              fontSize: 8,
                              fontWeight: pw.FontWeight.bold)))),
              pw.SizedBox(width: 10),
              pw.Text(titulo,
                  style: pw.TextStyle(
                      color: PdfColors.white,
                      fontSize: 9,
                      fontWeight: pw.FontWeight.bold)),
            ]),
          ),
          pw.SizedBox(height: 6),
          ...items,
        ],
      );

  pw.Widget _pdfPar(String t) => pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 5),
        child: pw.Text(t,
            textAlign: pw.TextAlign.justify,
            style: pw.TextStyle(fontSize: 8.5, color: _ct, lineSpacing: 3.5)),
      );

  pw.Widget _pdfBullet(String t) => pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 3, left: 8),
        child:
            pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Container(
              width: 4,
              height: 4,
              margin: const pw.EdgeInsets.only(top: 4, right: 6),
              decoration:
                  pw.BoxDecoration(color: _cp, shape: pw.BoxShape.circle)),
          pw.Expanded(
              child: pw.Text(t,
                  style:
                      pw.TextStyle(fontSize: 8.5, color: _ct, lineSpacing: 3))),
        ]),
      );

  pw.Widget _pdfHeader(
      pw.ImageProvider? logo, pw.ImageProvider? banner, String numContrato) {
    return pw
        .Column(crossAxisAlignment: pw.CrossAxisAlignment.stretch, children: [
      // Banner 100% visível - contain preserva toda a imagem sem corte
      if (banner != null)
        pw.Container(
          width: double.infinity,
          child: pw.Image(banner,
              fit: pw.BoxFit.contain, alignment: pw.Alignment.topLeft),
        )
      else
        pw.Container(
          height: 8,
          decoration: pw.BoxDecoration(
            gradient: pw.LinearGradient(colors: [_cpd, _cp]),
          ),
        ),
      // Faixa azul com logo + número do contrato
      pw.Container(
        color: _cpd,
        padding: const pw.EdgeInsets.fromLTRB(24, 8, 24, 8),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.center, children: [
              if (logo != null)
                pw.Container(
                  width: 32,
                  height: 32,
                  decoration: pw.BoxDecoration(
                    color: PdfColors.white,
                    borderRadius: pw.BorderRadius.circular(6),
                  ),
                  child: pw.ClipRRect(
                    horizontalRadius: 6,
                    verticalRadius: 6,
                    child: pw.Image(logo, fit: pw.BoxFit.contain),
                  ),
                ),
              pw.SizedBox(width: 10),
              pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('HPS REFRIGERAÇÃO',
                        style: pw.TextStyle(
                            color: PdfColors.white,
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold)),
                    pw.Text('CNPJ: 28.340.152/0001-52',
                        style: pw.TextStyle(color: _w70, fontSize: 7)),
                    pw.Text('(77) 8819-4630 | hpsrefri@gmail.com',
                        style: pw.TextStyle(color: _w70, fontSize: 7)),
                  ]),
            ]),
            pw.Container(
              padding:
                  const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: pw.BoxDecoration(
                color: _w24,
                borderRadius: pw.BorderRadius.circular(12),
              ),
              child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text('CONTRATO Nº',
                        style: pw.TextStyle(color: _w70, fontSize: 6)),
                    pw.Text(numContrato,
                        style: pw.TextStyle(
                            color: PdfColors.white,
                            fontSize: 8,
                            fontWeight: pw.FontWeight.bold)),
                  ]),
            ),
          ],
        ),
      ),
    ]);
  }

  // ══════════════════════════════════════════════════════════════════════════
  // PDF GERAL
  // ══════════════════════════════════════════════════════════════════════════
  Future<Uint8List> _gerarPdfGeral(List<Map<String, dynamic>> equips) async {
    final pdf = pw.Document();
    final d = _dadosCliente ?? _clienteSel ?? {};
    final nome = (d['display_name'] ?? d['nome'] ?? '').toString();
    final photo =
        (d['photo_url'] ?? _clienteSel?['photo_url'] ?? '').toString();
    final cnpj = (d['CNPJ'] ?? '').toString();

    final Map<String, List<Map<String, dynamic>>> porSetor = {};
    for (final e in equips) {
      final s = e['SETOR']?.toString() ?? 'SEM SETOR';
      porSetor.putIfAbsent(s, () => []).add(e);
    }

    final logoF = _loadImg(_urlLogo);
    final bannerF = _loadImg(_urlBanner);
    final photoF = photo.isNotEmpty ? _loadImg(photo) : Future.value(null);
    final imgs = await Future.wait([logoF, bannerF, photoF]);
    final logo = imgs[0];
    final banner = imgs[1];
    final photoImg = imgs[2];

    // CAPA
    pdf.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(0),
      build: (ctx) => pw
          .Column(crossAxisAlignment: pw.CrossAxisAlignment.stretch, children: [
        // Banner 100% visível sem corte
        if (banner != null)
          pw.Container(
            width: double.infinity,
            child: pw.Image(banner,
                fit: pw.BoxFit.contain, alignment: pw.Alignment.topLeft),
          )
        else
          pw.Container(
              height: 6,
              decoration: pw.BoxDecoration(
                  gradient: pw.LinearGradient(colors: [_cpd, _cp]))),
        // Faixa com logo + chips
        pw.Container(
          decoration: pw.BoxDecoration(
              gradient: pw.LinearGradient(colors: [_cpd, _cp])),
          padding: const pw.EdgeInsets.fromLTRB(36, 14, 36, 14),
          child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      if (logo != null)
                        pw.Container(
                            width: 42,
                            height: 42,
                            decoration: pw.BoxDecoration(
                                color: PdfColors.white,
                                borderRadius: pw.BorderRadius.circular(8)),
                            child: pw.ClipRRect(
                                horizontalRadius: 8,
                                verticalRadius: 8,
                                child: pw.Image(logo, fit: pw.BoxFit.contain))),
                      pw.SizedBox(width: 12),
                      pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text('HPS REFRIGERAÇÃO',
                                style: pw.TextStyle(
                                    color: PdfColors.white,
                                    fontSize: 15,
                                    fontWeight: pw.FontWeight.bold,
                                    letterSpacing: 1.0)),
                            pw.Text('Relatório Geral de Equipamentos',
                                style: pw.TextStyle(color: _w70, fontSize: 9)),
                          ]),
                    ]),
                pw.Row(children: [
                  pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: pw.BoxDecoration(
                          color: PdfColors.white,
                          borderRadius: pw.BorderRadius.circular(20)),
                      child: pw.Text('${equips.length} EQUIPAMENTOS',
                          style: pw.TextStyle(
                              color: _cpd,
                              fontSize: 10,
                              fontWeight: pw.FontWeight.bold))),
                  pw.SizedBox(width: 8),
                  pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: pw.BoxDecoration(
                          color: _w24,
                          borderRadius: pw.BorderRadius.circular(20)),
                      child: pw.Text('${porSetor.length} SETORES',
                          style: pw.TextStyle(
                              color: PdfColors.white,
                              fontSize: 10,
                              fontWeight: pw.FontWeight.bold))),
                ]),
              ]),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.fromLTRB(36, 20, 36, 0),
          child: pw.Container(
            decoration: pw.BoxDecoration(
                color: PdfColors.white,
                borderRadius: pw.BorderRadius.circular(12),
                border: pw.Border.all(color: _cd)),
            padding: const pw.EdgeInsets.all(18),
            child: pw.Row(children: [
              pw.Container(
                  width: 48,
                  height: 48,
                  decoration: pw.BoxDecoration(
                      color: _cp, borderRadius: pw.BorderRadius.circular(10)),
                  child: photoImg != null
                      ? pw.ClipRRect(
                          horizontalRadius: 10,
                          verticalRadius: 10,
                          child: pw.Image(photoImg, fit: pw.BoxFit.cover))
                      : pw.Center(
                          child: pw.Text(
                              nome.isNotEmpty ? nome[0].toUpperCase() : 'C',
                              style: pw.TextStyle(
                                  color: PdfColors.white,
                                  fontSize: 20,
                                  fontWeight: pw.FontWeight.bold)))),
              pw.SizedBox(width: 16),
              pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('CLIENTE',
                        style: pw.TextStyle(
                            fontSize: 8, color: _cs, letterSpacing: 1.0)),
                    pw.SizedBox(height: 2),
                    pw.Text(nome,
                        style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                            color: _ct)),
                    if (cnpj.isNotEmpty)
                      pw.Text('CNPJ: $cnpj',
                          style: pw.TextStyle(fontSize: 8, color: _cs)),
                  ]),
              pw.Spacer(),
              pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text('DATA DE EMISSÃO',
                        style: pw.TextStyle(fontSize: 7, color: _cs)),
                    pw.SizedBox(height: 3),
                    pw.Text(_dataFmt(),
                        style: pw.TextStyle(
                            fontSize: 13,
                            fontWeight: pw.FontWeight.bold,
                            color: _ct)),
                  ]),
            ]),
          ),
        ),
        pw.SizedBox(height: 20),
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(horizontal: 36),
          child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _pdfTitulo('RESUMO POR SETOR'),
                pw.SizedBox(height: 8),
                pw.Table(
                  border: pw.TableBorder.all(color: _cd, width: 0.5),
                  columnWidths: {
                    0: const pw.FlexColumnWidth(4),
                    1: const pw.FlexColumnWidth(1)
                  },
                  children: [
                    pw.TableRow(
                        decoration: pw.BoxDecoration(color: _cpd),
                        children: [_pdfTh('SETOR'), _pdfTh('QTD')]),
                    ...porSetor.entries
                        .toList()
                        .asMap()
                        .entries
                        .map((e) => pw.TableRow(
                              decoration: pw.BoxDecoration(
                                  color: e.key.isEven ? _cb : PdfColors.white),
                              children: [
                                _pdfTd(e.value.key, _ct),
                                _pdfTd('${e.value.value.length}', _cp,
                                    bold: true, center: true)
                              ],
                            )),
                  ],
                ),
              ]),
        ),
      ]),
    ));

    // INVENTÁRIO
    pdf.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.fromLTRB(28, 24, 28, 28),
      header: (ctx) => pw.Container(
        decoration: pw.BoxDecoration(
            color: _cpd, borderRadius: pw.BorderRadius.circular(6)),
        padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        margin: const pw.EdgeInsets.only(bottom: 14),
        child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('HPS REFRIGERAÇÃO  |  Inventário de Equipamentos',
                  style: pw.TextStyle(
                      color: PdfColors.white,
                      fontSize: 9,
                      fontWeight: pw.FontWeight.bold)),
              pw.Text(nome, style: pw.TextStyle(color: _w70, fontSize: 8)),
            ]),
      ),
      footer: (ctx) => pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('hpsrefri.com.br',
                style: pw.TextStyle(fontSize: 7, color: _cs)),
            pw.Text('Página ${ctx.pageNumber} de ${ctx.pagesCount}',
                style: pw.TextStyle(fontSize: 7, color: _cs)),
          ]),
      build: (ctx) {
        final ws = <pw.Widget>[];
        for (final entry in porSetor.entries) {
          ws.add(_pdfTitulo('SETOR: ${entry.key}'));
          ws.add(pw.SizedBox(height: 8));
          ws.add(pw.Table(
            border: pw.TableBorder.all(color: _cd, width: 0.5),
            columnWidths: {
              0: const pw.FlexColumnWidth(2.8),
              1: const pw.FlexColumnWidth(1.2),
              2: const pw.FlexColumnWidth(1.5),
              3: const pw.FlexColumnWidth(1.0),
              4: const pw.FlexColumnWidth(1.0),
              5: const pw.FlexColumnWidth(0.9),
              6: const pw.FlexColumnWidth(0.9)
            },
            children: [
              pw.TableRow(decoration: pw.BoxDecoration(color: _cpd), children: [
                _pdfTh('EQUIPAMENTO'),
                _pdfTh('PATRIMÔNIO'),
                _pdfTh('SALA'),
                _pdfTh('MARCA'),
                _pdfTh('BTUs'),
                _pdfTh('FLUIDO'),
                _pdfTh('TENSÃO')
              ]),
              ...entry.value.asMap().entries.map((e) => pw.TableRow(
                    decoration: pw.BoxDecoration(
                        color: e.key.isEven ? _cb : PdfColors.white),
                    children: [
                      _pdfTd(
                          e.value['EQUIPAMENTO']?.toString() ??
                              e.value['NOME']?.toString() ??
                              '',
                          _ct),
                      _pdfTd(e.value['PATRIMONIO']?.toString() ?? '', _cp,
                          bold: true),
                      _pdfTd(e.value['SALA']?.toString() ?? '', _ct),
                      _pdfTd(e.value['MARCA']?.toString() ?? '', _ct),
                      _pdfTd(e.value['BTUS']?.toString() ?? '', _ct),
                      _pdfTd(e.value['FLUIDO']?.toString() ?? '', _ct),
                      _pdfTd(e.value['TENSAO']?.toString() ?? '', _ct),
                    ],
                  )),
            ],
          ));
          ws.add(pw.SizedBox(height: 18));
        }
        return ws;
      },
    ));
    return pdf.save();
  }

  // ══════════════════════════════════════════════════════════════════════════
  // PDF CONTRATO
  // ══════════════════════════════════════════════════════════════════════════
  Future<Uint8List> _gerarPdfContrato(Map<String, dynamic> vals) async {
    final pdf = pw.Document();
    final d = _dadosCliente ?? _clienteSel ?? {};
    const hpsCNPJ = '28.340.152/0001-52';
    const hpsRazao = 'H PIRES SANTOS MENDONÇA REFRIGERAÇÃO';
    const hpsEnd = 'Av. Pará, 486-B, Ibirapuera';
    const hpsCidade = 'Vitória da Conquista/BA - CEP 45075-262';
    const hpsEmail = 'hpsrefri@gmail.com';
    const hpsFone = '(77) 8819-4630';
    const hpsIM = '500200784';
    const hpsSite = 'www.hpsrefri.com.br';

    final clCNPJ = (d['CNPJ'] ?? '').toString();
    final clRazao =
        (d['razao_social'] ?? d['display_name'] ?? d['nome'] ?? '').toString();
    final clEnd = (d['ENDERECO'] ?? '').toString();
    final clCidade = (d['CIDADE'] ?? '').toString();
    final clCEP = (d['CEP'] ?? '').toString();
    final clEmail = (d['email'] ?? '').toString();
    final endFull = [clEnd, clCidade, clCEP.isNotEmpty ? 'CEP: $clCEP' : '']
        .where((s) => s.isNotEmpty)
        .join(' - ');

    final setorValores =
        vals['setorValores'] as Map<String, Map<String, String>>;
    final vigencia = vals['vigencia']?.toString() ?? '12';
    final dataInicio = vals['dataInicio']?.toString() ?? _dataFmt();
    final periodo = vals['periodicidade']?.toString() ?? 'MENSAL';
    final objeto = vals['condicoes']?.toString() ?? '';
    final obs = vals['observacoes']?.toString() ?? '';
    final numContrato =
        'HPS-${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}${DateTime.now().day.toString().padLeft(2, '0')}';

    double total = 0;
    for (final sv in setorValores.values)
      total += double.tryParse((sv['valor'] ?? '').replaceAll(',', '.')) ?? 0;
    final totalStr = 'R\$ ${total.toStringAsFixed(2).replaceAll('.', ',')}';

    DateTime? dataFim;
    final p = dataInicio.split('/');
    if (p.length == 3) {
      try {
        dataFim = DateTime(int.parse(p[2]),
            int.parse(p[1]) + int.parse(vigencia), int.parse(p[0]));
      } catch (_) {}
    }
    final dataFimStr = dataFim != null
        ? '${dataFim.day.toString().padLeft(2, '0')}/${dataFim.month.toString().padLeft(2, '0')}/${dataFim.year}'
        : '-';

    final Map<String, List<Map<String, dynamic>>> porSetor = {};
    for (final e in _equipamentos) {
      final s = e['SETOR']?.toString() ?? 'SEM SETOR';
      porSetor.putIfAbsent(s, () => []).add(e);
    }

    final logo = await _loadImg(_urlLogo);
    final banner = await _loadImg(_urlBanner);

    // CAPA
    pdf.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(0),
      build: (ctx) => pw
          .Column(crossAxisAlignment: pw.CrossAxisAlignment.stretch, children: [
        _pdfHeader(logo, banner, numContrato),
        pw.Container(
          color: _cb,
          padding: const pw.EdgeInsets.symmetric(horizontal: 36, vertical: 14),
          child: pw.Column(children: [
            pw.Container(
              padding:
                  const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: _cpd, width: 1.5),
                  borderRadius: pw.BorderRadius.circular(8)),
              child: pw.Column(children: [
                pw.Text('CONTRATO DE PRESTAÇÃO DE SERVIÇOS',
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(
                        fontSize: 13,
                        fontWeight: pw.FontWeight.bold,
                        color: _cpd,
                        letterSpacing: 1.0)),
                pw.SizedBox(height: 4),
                pw.Text(
                    'MANUTENÇÃO PREVENTIVA DE EQUIPAMENTOS DE REFRIGERAÇÃO E CLIMATIZAÇÃO',
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(fontSize: 9, color: _cs)),
              ]),
            ),
          ]),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.fromLTRB(36, 14, 36, 0),
          child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Expanded(
                          child: _pdfSecao('CONTRATADA - HPS REFRIGERAÇÃO', [
                        _pdfLinha('Razão Social', hpsRazao, _cb),
                        _pdfLinha('CNPJ', hpsCNPJ, PdfColors.white),
                        _pdfLinha('Insc. Municipal', hpsIM, _cb),
                        _pdfLinha('Endereço', hpsEnd, PdfColors.white),
                        _pdfLinha('Cidade/CEP', hpsCidade, _cb),
                        _pdfLinha('E-mail / Fone', '$hpsEmail | $hpsFone',
                            PdfColors.white),
                      ])),
                      pw.SizedBox(width: 14),
                      pw.Expanded(
                          child: _pdfSecao('CONTRATANTE', [
                        _pdfLinha('Razão Social', clRazao, _cb),
                        _pdfLinha('CNPJ', clCNPJ, PdfColors.white),
                        if (endFull.isNotEmpty)
                          _pdfLinha('Endereço', endFull, _cb),
                        _pdfLinha('E-mail', clEmail, PdfColors.white),
                      ])),
                    ]),
                pw.SizedBox(height: 12),
                _pdfSecao('VIGÊNCIA', [
                  _pdfLinha('Início', dataInicio, _cb),
                  _pdfLinha('Término', dataFimStr, PdfColors.white),
                  _pdfLinha('Duração', '$vigencia meses', _cb),
                  _pdfLinha('Periodicidade', periodo, PdfColors.white),
                  _pdfLinha('Valor Mensal Total', totalStr, _cb),
                ]),
                pw.SizedBox(height: 12),
                pw.Container(
                  decoration: pw.BoxDecoration(
                      borderRadius: pw.BorderRadius.circular(8),
                      border: pw.Border.all(color: _cd, width: 0.5)),
                  child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                      children: [
                        pw.Container(
                          padding: const pw.EdgeInsets.symmetric(
                              horizontal: 12, vertical: 7),
                          decoration: pw.BoxDecoration(
                              color: _cpd,
                              borderRadius: const pw.BorderRadius.vertical(
                                  top: pw.Radius.circular(8))),
                          child: pw.Text('OBJETO DO CONTRATO',
                              style: pw.TextStyle(
                                  color: PdfColors.white,
                                  fontSize: 9,
                                  fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Padding(
                            padding: const pw.EdgeInsets.all(12),
                            child: pw.Text(objeto,
                                style: pw.TextStyle(
                                    fontSize: 8.5,
                                    color: _ct,
                                    lineSpacing: 3.5))),
                      ]),
                ),
              ]),
        ),
        pw.Spacer(),
        pw.Container(
          color: _cpd,
          padding: const pw.EdgeInsets.symmetric(horizontal: 36, vertical: 8),
          child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('$hpsSite  |  $hpsEmail  |  $hpsFone',
                    style: pw.TextStyle(fontSize: 7, color: _w70)),
                pw.Text('Pág. 1 - $numContrato',
                    style: pw.TextStyle(fontSize: 7, color: _w70)),
              ]),
        ),
      ]),
    ));

    // CLÁUSULAS + ANEXOS + ASSINATURAS (Agora no final da MultiPage)
    pdf.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.fromLTRB(36, 28, 36, 28),
      header: (ctx) => pw.Container(
        margin: const pw.EdgeInsets.only(bottom: 12),
        padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: pw.BoxDecoration(
            color: _cpd, borderRadius: pw.BorderRadius.circular(6)),
        child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('HPS REFRIGERAÇÃO  |  Contrato de Manutenção Preventiva',
                  style: pw.TextStyle(
                      color: PdfColors.white,
                      fontSize: 8,
                      fontWeight: pw.FontWeight.bold)),
              pw.Text(clRazao, style: pw.TextStyle(color: _w70, fontSize: 7)),
            ]),
      ),
      footer: (ctx) => pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('$hpsSite  |  $numContrato',
                style: pw.TextStyle(fontSize: 7, color: _cs)),
            pw.Text('Página ${ctx.pageNumber} de ${ctx.pagesCount}',
                style: pw.TextStyle(fontSize: 7, color: _cs)),
          ]),
      build: (ctx) => [
        _pdfClausula('1', 'DO OBJETO E DA HPS REFRIGERAÇÃO', [
          _pdfPar(
              'A HPS REFRIGERAÇÃO, empresa com mais de 8 anos de consolidada atuação e excelência no mercado, tem por objeto neste contrato a prestação de serviços especializados de manutenção preventiva em equipamentos de refrigeração e climatização instalados nas dependências da CONTRATANTE (ar-condicionados Split, sistemas VRF/VRV, câmaras frigoríficas, chillers, etc., conforme Anexo I).'),
          _pdfPar(
              'A manutenção preventiva regular é de suma importância para garantir a máxima eficiência energética, prolongar significativamente a vida útil dos ativos, mitigar o risco de paradas repentinas e assegurar a Qualidade do Ar Interno (QAI) para a saúde dos ocupantes.'),
        ]),
        _pdfClausula('2', 'DO PRAZO', [
          _pdfPar(
              'Vigência de $vigencia meses: de $dataInicio a $dataFimStr. Renovação automática por igual período salvo comunicação escrita com 30 dias de antecedência.'),
        ]),
        _pdfClausula('3', 'DOS SERVIÇOS, PMOC E PERIODICIDADE', [
          _pdfPar('Periodicidade $periodo. Serviços incluídos:'),
          pw.SizedBox(height: 4),
          pw.Text('3.1 ELABORAÇÃO E GESTÃO DO PMOC',
              style: pw.TextStyle(
                  fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: _cpd)),
          pw.SizedBox(height: 3),
          _pdfBullet(
              'Elaboração, implantação e acompanhamento contínuo do PMOC (Plano de Manutenção, Operação e Controle), garantindo total conformidade com a Lei 13.589/2018 e resoluções da ANVISA.'),
          pw.SizedBox(height: 5),
          pw.Text('3.2 LIMPEZA E HIGIENIZAÇÃO',
              style: pw.TextStyle(
                  fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: _cpd)),
          pw.SizedBox(height: 3),
          _pdfBullet(
              'Limpeza das unidades evaporadoras: filtros, serpentinas, bandejas de condensado e carcaças.'),
          _pdfBullet(
              'Limpeza e higienização das unidades condensadoras: aletas, motor ventilador e gabinete.'),
          _pdfBullet(
              'Limpeza do sistema de drenagem e aplicação de bactericida/fungicida.'),
          pw.SizedBox(height: 5),
          pw.Text('3.3 VERIFICAÇÕES TÉCNICAS',
              style: pw.TextStyle(
                  fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: _cpd)),
          pw.SizedBox(height: 3),
          _pdfBullet(
              'Medição das pressões de sucção e descarga e verificação da carga de fluido refrigerante.'),
          _pdfBullet(
              'Aferição das temperaturas de operação (evaporação, condensação e diferencial de ar).'),
          _pdfBullet(
              'Inspeção elétrica: contactores, relés, capacitores, medição de corrente e tensão.'),
          _pdfBullet(
              'Inspeção de vazamentos de fluido refrigerante e estado do isolamento térmico.'),
          pw.SizedBox(height: 5),
          pw.Text('3.4 AJUSTES E REGULAGENS',
              style: pw.TextStyle(
                  fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: _cpd)),
          pw.SizedBox(height: 3),
          _pdfBullet(
              'Regulagem da válvula de expansão, pressostatos e termostatos.'),
          _pdfBullet(
              'Lubrificação de partes móveis, aperto de terminais e ajuste dos ventiladores.'),
          pw.SizedBox(height: 5),
          pw.Text('3.5 RELATÓRIO TÉCNICO',
              style: pw.TextStyle(
                  fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: _cpd)),
          pw.SizedBox(height: 3),
          _pdfBullet(
              'Fornecimento de relatório técnico por escrito após cada visita com atividades realizadas, condição dos equipamentos e recomendações.'),
        ]),
        _pdfClausula('4', 'DA TECNOLOGIA E APLICATIVO DE GESTÃO', [
          _pdfPar(
              'Como diferencial inovador, a CONTRATADA disponibiliza um aplicativo exclusivo de gestão técnica. Através do app, a CONTRATANTE terá acesso ao acompanhamento em tempo real do cronograma de manutenções, histórico detalhado de intervenções por equipamento (QR Code/Patrimônio), emissão de relatórios técnicos digitais (OS) e canal de comunicação direto. Essa tecnologia assegura absoluta transparência, controle de inventário na palma da mão e agilidade na tomada de decisões.'),
        ]),
        _pdfClausula('5', 'DO VALOR E PAGAMENTO', [
          _pdfPar(
              'Valor mensal total de $totalStr, conforme Anexo II. Pagamento até o dia 10 do mês subsequente. Atraso: multa de 2% + juros de 1% a.m. + IGPM. Reajuste anual pelo IPCA.'),
        ]),
        _pdfClausula('6', 'OBRIGAÇÕES DA CONTRATADA E SEGURANÇA DO TRABALHO', [
          _pdfBullet(
              'Disponibilizar equipe técnica altamente qualificada, devidamente uniformizada (fardamento completo) e munida de todos os Equipamentos de Proteção Individual (EPIs) necessários para a execução segura dos serviços.'),
          _pdfBullet(
              'Garantir e arcar com os custos de treinamentos e certificações (NR-10 e NR-35), além da elaboração e atualização do PGR e PCMSO, fornecendo toda a documentação exigida pelo departamento de SSMA da CONTRATANTE.'),
          _pdfBullet(
              'Disponibilizar 2 (dois) veículos exclusivos da empresa, devidamente identificados (adesivados com a logomarca da HPS), para agilidade e segurança logística do atendimento técnico.'),
          _pdfBullet(
              'Fornecer e arcar com todos os custos referentes a insumos, produtos químicos e materiais de limpeza/higienização estritamente utilizados na execução das manutenções preventivas.'),
          _pdfBullet(
              'Executar os serviços com qualidade técnica ímpar, observando rigorosamente as normas da ABNT (NBR 16401, NBR 7256) e boas práticas do setor.'),
          _pdfBullet(
              'Comunicar à CONTRATANTE qualquer anomalia detectada nos equipamentos durante as rotinas de manutenção.'),
          _pdfBullet(
              'Responsabilizar-se civil e criminalmente por danos causados aos equipamentos decorrentes de imperícia ou negligência comprovada de seus prepostos.'),
        ]),
        _pdfClausula('7', 'OBRIGAÇÕES DA CONTRATANTE', [
          _pdfBullet(
              'Permitir acesso dos técnicos nos horários agendados e providenciar desligamento quando solicitado.'),
          _pdfBullet(
              'Informar imediatamente qualquer anomalia, mau funcionamento ou falha nos equipamentos.'),
          _pdfBullet(
              'Não permitir intervenção de terceiros não autorizados nos equipamentos deste contrato.'),
          _pdfBullet(
              'Efetuar pagamentos nos prazos estipulados e comunicar remarcações com 48h de antecedência.'),
        ]),
        _pdfClausula('8', 'EXCLUSÕES', [
          _pdfBullet(
              'Substituição de peças e componentes (compressores, capacitores, plaquetas, motores, válvulas).'),
          _pdfBullet('Recarga de fluido refrigerante (cobrado separadamente).'),
          _pdfBullet(
              'Manutenção corretiva por mau uso, acidentes, vandalismo ou casos fortuitos.'),
          _pdfBullet(
              'Instalação, desinstalação, obras civis, elétricas ou hidráulicas.'),
        ]),
        _pdfClausula('9', 'GARANTIA', [
          _pdfPar(
              'A CONTRATADA garante a qualidade dos serviços por 30 dias após a execução, comprometendo-se a corrigir gratuitamente defeitos decorrentes de erro técnico comprovado.'),
        ]),
        _pdfClausula('10', 'RESCISÃO', [
          _pdfPar(
              'Rescisão com aviso prévio de 30 dias. Rescisão imediata em caso de inadimplemento, falência ou força maior. Rescisão antecipada sem justa causa pela CONTRATANTE: multa de 2 mensalidades.'),
        ]),
        _pdfClausula('11', 'FORO', [
          _pdfPar(
              'Fica eleito o Foro da Comarca de Vitória da Conquista - BA para dirimir quaisquer litígios, com renúncia a qualquer outro. Regido pelo Código Civil Brasileiro (Lei 10.406/2002).'),
        ]),
        if (obs.isNotEmpty) _pdfClausula('OBS', 'OBSERVAÇÕES', [_pdfPar(obs)]),
        pw.SizedBox(height: 18),

        // ANEXO I
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: pw.BoxDecoration(
              color: _cpd, borderRadius: pw.BorderRadius.circular(8)),
          child: pw.Text('ANEXO I - RELAÇÃO DE EQUIPAMENTOS',
              style: pw.TextStyle(
                  color: PdfColors.white,
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold)),
        ),
        pw.SizedBox(height: 10),
        ...porSetor.entries
            .map((entry) => pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Container(
                          margin: const pw.EdgeInsets.only(bottom: 4, top: 8),
                          padding: const pw.EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: pw.BoxDecoration(
                              color: PdfColor.fromHex('1A3A6E'),
                              borderRadius: pw.BorderRadius.circular(5)),
                          child: pw.Text('SETOR: ${entry.key}',
                              style: pw.TextStyle(
                                  color: PdfColors.white,
                                  fontSize: 8.5,
                                  fontWeight: pw.FontWeight.bold))),
                      pw.Table(
                        border: pw.TableBorder.all(color: _cd, width: 0.5),
                        columnWidths: {
                          0: const pw.FlexColumnWidth(2.5),
                          1: const pw.FlexColumnWidth(1.1),
                          2: const pw.FlexColumnWidth(1.4),
                          3: const pw.FlexColumnWidth(1.0),
                          4: const pw.FlexColumnWidth(1.0),
                          5: const pw.FlexColumnWidth(0.8),
                          6: const pw.FlexColumnWidth(0.8)
                        },
                        children: [
                          pw.TableRow(
                              decoration: pw.BoxDecoration(color: _cp),
                              children: [
                                _pdfTh('EQUIPAMENTO'),
                                _pdfTh('PATRIMÔNIO'),
                                _pdfTh('SALA'),
                                _pdfTh('MARCA'),
                                _pdfTh('BTUs'),
                                _pdfTh('FLUIDO'),
                                _pdfTh('TENSÃO')
                              ]),
                          ...entry.value.asMap().entries.map((e) => pw.TableRow(
                                decoration: pw.BoxDecoration(
                                    color:
                                        e.key.isEven ? _cb : PdfColors.white),
                                children: [
                                  _pdfTd(
                                      e.value['EQUIPAMENTO']?.toString() ??
                                          e.value['NOME']?.toString() ??
                                          '',
                                      _ct),
                                  _pdfTd(
                                      e.value['PATRIMONIO']?.toString() ?? '',
                                      _cp,
                                      bold: true),
                                  _pdfTd(
                                      e.value['SALA']?.toString() ?? '', _ct),
                                  _pdfTd(
                                      e.value['MARCA']?.toString() ?? '', _ct),
                                  _pdfTd(
                                      e.value['BTUS']?.toString() ?? '', _ct),
                                  _pdfTd(
                                      e.value['FLUIDO']?.toString() ?? '', _ct),
                                  _pdfTd(
                                      e.value['TENSAO']?.toString() ?? '', _ct),
                                ],
                              )),
                        ],
                      ),
                    ]))
            .toList(),
        pw.SizedBox(height: 18),

        // ANEXO II
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: pw.BoxDecoration(
              color: _cpd, borderRadius: pw.BorderRadius.circular(8)),
          child: pw.Text('ANEXO II - DISCRIMINAÇÃO DE SERVIÇOS E VALORES',
              style: pw.TextStyle(
                  color: PdfColors.white,
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold)),
        ),
        pw.SizedBox(height: 10),
        pw.Table(
          border: pw.TableBorder.all(color: _cd, width: 0.5),
          columnWidths: {
            0: const pw.FlexColumnWidth(4),
            1: const pw.FlexColumnWidth(1.5),
            2: const pw.FlexColumnWidth(1.5)
          },
          children: [
            pw.TableRow(decoration: pw.BoxDecoration(color: _cpd), children: [
              _pdfTh('DESCRIÇÃO'),
              _pdfTh('PERIODICIDADE'),
              _pdfTh('VALOR MENSAL (R\$)')
            ]),
            ...setorValores.entries.toList().asMap().entries.map((entry) {
              final sv = entry.value.value;
              return pw.TableRow(
                decoration: pw.BoxDecoration(
                    color: entry.key.isEven ? _cb : PdfColors.white),
                children: [
                  pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(
                          horizontal: 8, vertical: 7),
                      child: pw.Text(
                          sv['desc']?.isNotEmpty == true ? sv['desc']! : '-',
                          style: pw.TextStyle(fontSize: 8, color: _ct))),
                  pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(
                          horizontal: 8, vertical: 7),
                      child: pw.Text(periodo,
                          style: pw.TextStyle(fontSize: 8, color: _ct))),
                  pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(
                          horizontal: 8, vertical: 7),
                      child: pw.Text(
                          sv['valor']?.isNotEmpty == true
                              ? 'R\$ ${sv['valor']}'
                              : '-',
                          textAlign: pw.TextAlign.right,
                          style: pw.TextStyle(
                              fontSize: 8,
                              color: _cp,
                              fontWeight: pw.FontWeight.bold))),
                ],
              );
            }),
            pw.TableRow(decoration: pw.BoxDecoration(color: _cpd), children: [
              pw.Padding(
                  padding:
                      const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: pw.Text('TOTAL MENSAL',
                      style: pw.TextStyle(
                          fontSize: 9,
                          color: PdfColors.white,
                          fontWeight: pw.FontWeight.bold))),
              pw.Padding(
                  padding:
                      const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: pw.Text('')),
              pw.Padding(
                  padding:
                      const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: pw.Text(totalStr,
                      textAlign: pw.TextAlign.right,
                      style: pw.TextStyle(
                          fontSize: 9,
                          color: PdfColors.white,
                          fontWeight: pw.FontWeight.bold))),
            ]),
          ],
        ),

        pw.SizedBox(height: 40),

        // Assinaturas (Colocadas agora por último, forçando ficar na última página)
        pw.Container(
          padding: const pw.EdgeInsets.all(14),
          decoration: pw.BoxDecoration(
              color: _cb,
              borderRadius: pw.BorderRadius.circular(8),
              border: pw.Border.all(color: _cd, width: 0.5)),
          child: pw.Column(children: [
            pw.Text('Vitória da Conquista - BA, ${_dataFmt()}',
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(fontSize: 9, color: _cs)),
            pw.SizedBox(height: 24),
            pw.Row(children: [
              pw.Expanded(
                  child: pw.Column(children: [
                pw.Container(height: 0.8, color: _cpd),
                pw.SizedBox(height: 5),
                pw.Text('CONTRATADA',
                    style: pw.TextStyle(
                        fontSize: 8,
                        color: _cs,
                        fontWeight: pw.FontWeight.bold)),
                pw.Text(hpsRazao,
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(
                        fontSize: 7.5,
                        color: _ct,
                        fontWeight: pw.FontWeight.bold)),
                pw.Text('CNPJ: $hpsCNPJ',
                    style: pw.TextStyle(fontSize: 7, color: _cs)),
              ])),
              pw.SizedBox(width: 40),
              pw.Expanded(
                  child: pw.Column(children: [
                pw.Container(height: 0.8, color: _cpd),
                pw.SizedBox(height: 5),
                pw.Text('CONTRATANTE',
                    style: pw.TextStyle(
                        fontSize: 8,
                        color: _cs,
                        fontWeight: pw.FontWeight.bold)),
                pw.Text(clRazao,
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(
                        fontSize: 7.5,
                        color: _ct,
                        fontWeight: pw.FontWeight.bold)),
                pw.Text('CNPJ: $clCNPJ',
                    style: pw.TextStyle(fontSize: 7, color: _cs)),
              ])),
            ]),
            pw.SizedBox(height: 18),
            pw.Row(children: [
              pw.Expanded(
                  child: pw.Column(children: [
                pw.Container(height: 0.8, color: _cd),
                pw.SizedBox(height: 3),
                pw.Text('Testemunha 1 - Nome / CPF',
                    style: pw.TextStyle(fontSize: 7, color: _cs))
              ])),
              pw.SizedBox(width: 40),
              pw.Expanded(
                  child: pw.Column(children: [
                pw.Container(height: 0.8, color: _cd),
                pw.SizedBox(height: 3),
                pw.Text('Testemunha 2 - Nome / CPF',
                    style: pw.TextStyle(fontSize: 7, color: _cs))
              ])),
            ]),
          ]),
        ),
      ],
    ));
    return pdf.save();
  }

  // ══════════════════════════════════════════════════════════════════════════
  // PDF INDIVIDUAL
  // ══════════════════════════════════════════════════════════════════════════
  Future<Uint8List> _gerarPdfIndividual(Map<String, dynamic> equip) async {
    final pdf = pw.Document();
    final nome =
        equip['EQUIPAMENTO']?.toString() ?? equip['NOME']?.toString() ?? '-';
    final pat = equip['PATRIMONIO']?.toString() ?? '-';
    final logo = await _loadImg(_urlLogo);
    pdf.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.fromLTRB(28, 24, 28, 28),
      build: (ctx) => pw
          .Column(crossAxisAlignment: pw.CrossAxisAlignment.stretch, children: [
        pw.Container(
          decoration: pw.BoxDecoration(
              gradient: pw.LinearGradient(colors: [_cpd, _cp]),
              borderRadius: pw.BorderRadius.circular(10)),
          padding: const pw.EdgeInsets.fromLTRB(20, 14, 20, 14),
          child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Row(children: [
                  if (logo != null)
                    pw.Container(
                        width: 32,
                        height: 32,
                        decoration: pw.BoxDecoration(
                            color: PdfColors.white,
                            borderRadius: pw.BorderRadius.circular(6)),
                        child: pw.ClipRRect(
                            horizontalRadius: 6,
                            verticalRadius: 6,
                            child: pw.Image(logo, fit: pw.BoxFit.contain))),
                  pw.SizedBox(width: 10),
                  pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('HPS REFRIGERAÇÃO',
                            style: pw.TextStyle(
                                color: PdfColors.white,
                                fontSize: 13,
                                fontWeight: pw.FontWeight.bold)),
                        pw.Text(_clienteSel?['nome'] ?? '',
                            style: pw.TextStyle(color: _w70, fontSize: 8)),
                      ]),
                ]),
                pw.Container(
                    padding: const pw.EdgeInsets.symmetric(
                        horizontal: 12, vertical: 5),
                    decoration: pw.BoxDecoration(
                        color: PdfColors.white,
                        borderRadius: pw.BorderRadius.circular(20)),
                    child: pw.Text('PAT: $pat',
                        style: pw.TextStyle(
                            color: _cpd,
                            fontSize: 9,
                            fontWeight: pw.FontWeight.bold))),
              ]),
        ),
        pw.SizedBox(height: 16),
        pw.Table(
          border: pw.TableBorder.all(color: _cd, width: 0.5),
          columnWidths: {
            0: const pw.FlexColumnWidth(1.5),
            1: const pw.FlexColumnWidth(3)
          },
          children: [
            pw.TableRow(
                decoration: pw.BoxDecoration(color: _cpd),
                children: [_pdfTh('CAMPO'), _pdfTh('INFORMAÇÃO')]),
            _pdfRow2('Equipamento', nome, false),
            _pdfRow2('Patrimônio', pat, true),
            _pdfRow2('Sala', equip['SALA']?.toString() ?? '', false),
            _pdfRow2('Setor', equip['SETOR']?.toString() ?? '', true),
            _pdfRow2(
                'Responsável', equip['RESPONSAVEL']?.toString() ?? '', false),
            _pdfRow2('Tipo', equip['TIPO']?.toString() ?? '', true),
            _pdfRow2('Marca', equip['MARCA']?.toString() ?? '', false),
            _pdfRow2('Modelo', equip['MODELO']?.toString() ?? '', true),
            _pdfRow2('BTUs', equip['BTUS']?.toString() ?? '', false),
            _pdfRow2('Fluido', equip['FLUIDO']?.toString() ?? '', true),
            _pdfRow2('Tensão', equip['TENSAO']?.toString() ?? '', false),
          ],
        ),
        pw.Spacer(),
        pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
          pw.Text('hpsrefri.com.br  |  ${_dataFmt()}',
              style: pw.TextStyle(fontSize: 7, color: _cs)),
          pw.Text('© ${DateTime.now().year} HPS Refrigeração',
              style: pw.TextStyle(fontSize: 7, color: _cs)),
        ]),
      ]),
    ));
    return pdf.save();
  }

  pw.TableRow _pdfRow2(String label, String valor, bool alt) => pw.TableRow(
        decoration: pw.BoxDecoration(color: alt ? _cb : PdfColors.white),
        children: [
          pw.Padding(
              padding:
                  const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: pw.Text(label,
                  style: pw.TextStyle(
                      fontSize: 9,
                      color: _cs,
                      fontWeight: pw.FontWeight.bold))),
          pw.Padding(
              padding:
                  const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: pw.Text(valor.isEmpty ? '-' : valor,
                  style: pw.TextStyle(
                      fontSize: 9,
                      color: _ct,
                      fontWeight: pw.FontWeight.bold))),
        ],
      );

  // ── Abrir PDFs ──────────────────────────────────────────────────────────────
  Future<void> _abrirPdfIndividual(Map<String, dynamic> equip) async {
    if (_gerandoPdf) return;
    setState(() => _gerandoPdf = true);
    try {
      final bytes = await _gerarPdfIndividual(equip);
      await Printing.layoutPdf(
          onLayout: (_) => bytes,
          name: 'HPS_${equip['PATRIMONIO'] ?? 'equip'}.pdf');
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(SnackBar(
            content: Text('Erro PDF: $e'),
            backgroundColor: const Color(0xFFB91C1C)));
    } finally {
      if (mounted) setState(() => _gerandoPdf = false);
    }
  }

  Future<void> _abrirPdfGeral() async {
    if (_gerandoPdf) return;
    setState(() => _gerandoPdf = true);
    try {
      final bytes = await _gerarPdfGeral(_filtrados);
      await Printing.layoutPdf(
          onLayout: (_) => bytes,
          name: 'HPS_Relatorio_${_clienteSel?['nome'] ?? 'cliente'}.pdf');
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(SnackBar(
            content: Text('Erro PDF: $e'),
            backgroundColor: const Color(0xFFB91C1C)));
    } finally {
      if (mounted) setState(() => _gerandoPdf = false);
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // BUILD
  // ══════════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Material(
      color: _bg,
      child: SafeArea(
        child: SizedBox(
          width: widget.width ?? double.infinity,
          height: widget.height ?? double.infinity,
          child:
              Column(children: [_buildTopBar(), Expanded(child: _buildBody())]),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      color: _card,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Row(children: [
          GestureDetector(
            onTap: () => Navigator.maybePop(context),
            child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                    color: _surf,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _divC)),
                child: Icon(Icons.arrow_back_rounded, color: _textP, size: 22)),
          ),
          const SizedBox(width: 14),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text('Relatório de Equipamentos',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: _textP)),
                Text(
                    _clienteSel != null
                        ? '${_filtrados.length} equipamentos  |  ${_clienteSel!['nome']}'
                        : 'Selecione um cliente',
                    style: TextStyle(fontSize: 11, color: _textS)),
              ])),
          if (_clienteSel != null && _equipamentos.isNotEmpty) ...[
            const SizedBox(width: 8),
            _btnAcao(Icons.description_outlined, 'CONTRATO', _gerandoContrato,
                _abrirContrato),
            const SizedBox(width: 8),
            _btnAcao(Icons.picture_as_pdf_rounded, 'PDF', _gerandoPdf,
                _abrirPdfGeral),
          ],
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(flex: 2, child: _buildDropdown()),
          if (_clienteSel != null) ...[
            const SizedBox(width: 10),
            Expanded(flex: 3, child: _buildBusca())
          ],
        ]),
        if (_clienteSel != null && _equipamentos.isNotEmpty) ...[
          const SizedBox(height: 10),
          _buildFiltros()
        ],
      ]),
    );
  }

  Widget _btnAcao(
      IconData icon, String label, bool loading, VoidCallback onTap) {
    return GestureDetector(
      onTap: (loading || _gerandoPdf || _gerandoContrato) ? null : onTap,
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          gradient: (loading || _gerandoPdf || _gerandoContrato)
              ? null
              : const LinearGradient(
                  colors: [Color(0xFF0D47A1), Color(0xFF1E40AF)]),
          color: (loading || _gerandoPdf || _gerandoContrato)
              ? _primary.withAlpha(60)
              : null,
          borderRadius: BorderRadius.circular(12),
          boxShadow: (loading || _gerandoPdf || _gerandoContrato)
              ? null
              : [
                  BoxShadow(
                      color: _primary.withAlpha(80),
                      blurRadius: 8,
                      offset: const Offset(0, 3))
                ],
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          loading
              ? const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2))
              : Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 6),
          Text(label,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w800)),
        ]),
      ),
    );
  }

  Widget _buildDropdown() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
          color: _surf,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: _clienteSel != null ? _primary.withAlpha(80) : _divC,
              width: 1.5)),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonHideUnderline(
        child: _carregandoClientes
            ? Row(children: [
                const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                        color: _primary, strokeWidth: 2)),
                const SizedBox(width: 8),
                Text('Carregando...',
                    style: TextStyle(fontSize: 13, color: _textS)),
              ])
            : DropdownButton<Map<String, dynamic>>(
                value: _clienteSel,
                hint: Row(children: [
                  const Icon(Icons.people_alt_outlined,
                      color: _primary, size: 18),
                  const SizedBox(width: 8),
                  Text('Selecionar cliente',
                      style: TextStyle(fontSize: 13, color: _textS)),
                ]),
                isExpanded: true,
                icon: Icon(Icons.keyboard_arrow_down_rounded,
                    color: _textS, size: 20),
                dropdownColor: _card,
                style: TextStyle(
                    fontSize: 13, color: _textP, fontWeight: FontWeight.w600),
                items: _clientes
                    .map((c) => DropdownMenuItem<Map<String, dynamic>>(
                          value: c,
                          child: Row(children: [
                            Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                    color: _primary.withAlpha(30),
                                    shape: BoxShape.circle),
                                child: Center(
                                    child: Text(
                                        (c['nome'] as String).isNotEmpty
                                            ? (c['nome'] as String)[0]
                                                .toUpperCase()
                                            : '?',
                                        style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: _primary)))),
                            const SizedBox(width: 10),
                            Expanded(
                                child: Text(c['nome'],
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontSize: 13, color: _textP))),
                          ]),
                        ))
                    .toList(),
                onChanged: (c) {
                  if (c != null) _selecionarCliente(c);
                },
              ),
      ),
    );
  }

  Widget _buildBusca() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
          color: _surf,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: _busca.isNotEmpty ? _primary.withAlpha(80) : _divC,
              width: 1.5)),
      child: TextField(
        controller: _buscaCtrl,
        onChanged: (v) => setState(() => _busca = v.toLowerCase()),
        style: TextStyle(fontSize: 13, color: _textP),
        decoration: InputDecoration(
          hintText: 'Buscar equipamento...',
          hintStyle: TextStyle(fontSize: 13, color: _textS),
          prefixIcon:
              const Icon(Icons.search_rounded, color: _primary, size: 18),
          suffixIcon: _busca.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.close_rounded, size: 16, color: _textS),
                  onPressed: () {
                    _buscaCtrl.clear();
                    setState(() => _busca = '');
                  })
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildFiltros() {
    return SizedBox(
      height: 34,
      child: ListView(scrollDirection: Axis.horizontal, children: [
        ..._tipos.map((t) => _chip(
            t == 'TODOS' ? 'Todos tipos' : t,
            t == _filtroT,
            () => setState(() => _filtroT = t),
            Icons.category_outlined)),
        Container(
            width: 1,
            height: 24,
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            color: _divC),
        ..._setores.map((s) => _chip(
            s == 'TODOS' ? 'Todos setores' : s,
            s == _filtroS,
            () => setState(() => _filtroS = s),
            Icons.domain_outlined)),
      ]),
    );
  }

  Widget _chip(String label, bool ativo, VoidCallback onTap, IconData icon) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: ativo ? _primary : _surf,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: ativo ? _primary : _divC, width: ativo ? 1.5 : 1),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 11, color: ativo ? Colors.white : _textS),
          const SizedBox(width: 5),
          Text(label,
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: ativo ? Colors.white : _textS)),
        ]),
      ),
    );
  }

  Widget _buildBody() {
    if (_clienteSel == null) return _buildVazio();
    if (_carregandoEquip) return _buildShimmer();
    if (_equipamentos.isEmpty) return _buildSemEquip();
    return _buildLista();
  }

  Widget _buildVazio() => Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
                color: _primary.withAlpha(15), shape: BoxShape.circle),
            child: Icon(Icons.people_alt_outlined,
                size: 44, color: _primary.withAlpha(120))),
        const SizedBox(height: 18),
        Text('Selecione um cliente',
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w700, color: _textP)),
        const SizedBox(height: 6),
        Text(
            'Use o dropdown acima para escolher o cliente\ne visualizar seus equipamentos.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: _textS, height: 1.5)),
      ]));

  Widget _buildSemEquip() => Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.devices_outlined, size: 52, color: _textS.withAlpha(100)),
        const SizedBox(height: 14),
        Text('Nenhum equipamento cadastrado',
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w600, color: _textS)),
      ]));

  Widget _buildShimmer() {
    return AnimatedBuilder(
      animation: _shimmer,
      builder: (ctx, _) {
        final g = LinearGradient(
          colors: [
            _surf,
            _dark ? const Color(0xFF1E2D45) : const Color(0xFFE0E8F5),
            _surf
          ],
          stops: [
            (_shimmer.value - 0.3).clamp(0.0, 1.0),
            _shimmer.value.clamp(0.0, 1.0),
            (_shimmer.value + 0.3).clamp(0.0, 1.0)
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        );
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          itemCount: 6,
          itemBuilder: (_, i) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              height: 96,
              decoration: BoxDecoration(
                  gradient: g, borderRadius: BorderRadius.circular(16))),
        );
      },
    );
  }

  Widget _buildLista() {
    final equips = _filtrados;
    if (equips.isEmpty)
      return Center(
          child: Text('Nenhum resultado para os filtros.',
              style: TextStyle(fontSize: 13, color: _textS)));
    final isMobile = MediaQuery.of(context).size.width < 700;
    return Column(children: [
      Container(
        color: _card,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Row(children: [
          _statChip(
              Icons.devices_rounded, '${equips.length} equipamentos', _primary),
          const SizedBox(width: 8),
          _statChip(Icons.domain_outlined, '${_setores.length - 1} setores',
              _primaryDark),
        ]),
      ),
      Expanded(
        child: isMobile
            ? ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
                itemCount: equips.length,
                itemBuilder: (_, i) => _buildCard(equips[i]))
            : GridView.builder(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount:
                        MediaQuery.of(context).size.width > 1100 ? 3 : 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 2.2),
                itemCount: equips.length,
                itemBuilder: (_, i) => _buildCard(equips[i])),
      ),
    ]);
  }

  Widget _statChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
          color: color.withAlpha(15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withAlpha(60))),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 5),
        Text(label,
            style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w700, color: color)),
      ]),
    );
  }

  Widget _buildCard(Map<String, dynamic> equip) {
    final nome =
        equip['EQUIPAMENTO']?.toString() ?? equip['NOME']?.toString() ?? '-';
    final tipo = equip['TIPO']?.toString() ?? '';
    final tc = _tipoColor(tipo);
    final pat = equip['PATRIMONIO']?.toString() ?? '-';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: _dark
                  ? Colors.black.withAlpha(50)
                  : Colors.black.withAlpha(10),
              blurRadius: 12,
              offset: const Offset(0, 3))
        ],
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
            height: 4,
            decoration: BoxDecoration(
                color: tc,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)))),
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                    color: tc.withAlpha(_dark ? 50 : 20),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: tc.withAlpha(80))),
                child: Icon(_equipIcon(nome), color: tc, size: 22)),
            const SizedBox(width: 12),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Row(children: [
                    Expanded(
                        child: Text(nome,
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: _textP),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis)),
                    Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                            color: _primary.withAlpha(_dark ? 30 : 15),
                            borderRadius: BorderRadius.circular(6)),
                        child: Text(pat,
                            style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: _primary))),
                  ]),
                  const SizedBox(height: 4),
                  Row(children: [
                    Icon(Icons.location_on_outlined, size: 10, color: _textS),
                    const SizedBox(width: 3),
                    Flexible(
                        child: Text(
                            '${equip['SALA'] ?? '-'}  |  ${equip['SETOR'] ?? '-'}',
                            style: TextStyle(fontSize: 10, color: _textS),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis)),
                  ]),
                  const SizedBox(height: 4),
                  Row(children: [
                    if (tipo.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                            color: tc.withAlpha(_dark ? 40 : 18),
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(color: tc.withAlpha(60))),
                        child: Text(tipo,
                            style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: tc)),
                      ),
                    const SizedBox(width: 7),
                    Text(equip['MARCA']?.toString() ?? '',
                        style: TextStyle(
                            fontSize: 10,
                            color: _textS,
                            fontStyle: FontStyle.italic)),
                  ]),
                ])),
            GestureDetector(
              onTap: _gerandoPdf ? null : () => _abrirPdfIndividual(equip),
              child: Container(
                  width: 36,
                  height: 36,
                  margin: const EdgeInsets.only(left: 8),
                  decoration: BoxDecoration(
                      color: _primary.withAlpha(_dark ? 40 : 20),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: _primary.withAlpha(60))),
                  child: _gerandoPdf
                      ? const Center(
                          child: SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                  color: _primary, strokeWidth: 2)))
                      : const Icon(Icons.picture_as_pdf_rounded,
                          color: _primary, size: 18)),
            ),
          ]),
        ),
        Container(
          decoration: BoxDecoration(
              color: _surf,
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(16)),
              border: Border(top: BorderSide(color: _divC))),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(children: [
            _mini(Icons.thermostat_outlined, equip['BTUS']?.toString() ?? '-'),
            const SizedBox(width: 14),
            _mini(
                Icons.water_drop_outlined, equip['FLUIDO']?.toString() ?? '-'),
            const SizedBox(width: 14),
            _mini(Icons.bolt_outlined, equip['TENSAO']?.toString() ?? '-'),
            const Spacer(),
            Text(equip['MODELO']?.toString() ?? '',
                style: TextStyle(
                    fontSize: 10, color: _textS, fontStyle: FontStyle.italic),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ]),
        ),
      ]),
    );
  }

  Widget _mini(IconData icon, String label) =>
      Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 11, color: _primary),
        const SizedBox(width: 3),
        Text(label,
            style: TextStyle(
                fontSize: 10, fontWeight: FontWeight.w600, color: _textS),
            maxLines: 1,
            overflow: TextOverflow.ellipsis),
      ]);
}
