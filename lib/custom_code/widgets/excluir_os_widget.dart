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
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

// ══════════════════════════════════════════════════════════════
//  FORMATADOR DE MAIÚSCULAS
// ══════════════════════════════════════════════════════════════
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

bool _fotoValida(String? s) {
  final u = (s ?? '').trim();
  return u.startsWith('http://') || u.startsWith('https://')
      ? !u.contains('Erro:')
      : false;
}

// ══════════════════════════════════════════════════════════════
//  MAPEAMENTO DE BANCO DE DADOS (DB MAPPER)
// ══════════════════════════════════════════════════════════════
/// Resolve as diferenças de nomes de campos entre as coleções.
/// Ex: 'DEFEITO' na manutenção = 'SERVICO' em serviços realizados.
class _DbMapper {
  static String toDb(String k, String col) {
    if (col == 'MANUTENCAO') {
      switch (k) {
        case 'NUMERODAOS':
          return 'NUMERO_OS';
        case 'CADASTRO':
          return 'DATADAMANUTENÇÃO';
        case 'TECNICO':
          return 'TECNICORESPONSAVEL';
        case 'SERVICO':
          return 'DEFEITO';
        case 'DESCRICAO':
          return 'DESCRICAODOSERVICO';
        case 'PECA':
          return 'PREVISAODAPECA';
        case 'TERMINO':
          return 'DATA_TERMINO';
      }
    } else if (col == 'CORRETIVAS') {
      switch (k) {
        case 'NUMERODAOS':
          return 'NUMERO_OS';
        case 'CADASTRO':
          return 'DATADAMANUTENCAO';
        case 'TECNICO':
          return 'TECNICORESPONSAVEL';
        case 'SERVICO':
          return 'DEFEITO';
        case 'DESCRICAO':
          return 'DESCRICAODOSERVICO';
        case 'PECA':
          return 'PREVISAODAPECA';
        case 'TERMINO':
          return 'DATA_TERMINO';
      }
    }
    return k;
  }

  static String fromDb(Map<String, dynamic> data, String k) {
    // Tenta primeiro a chave canônica nativa
    final raw1 = data[k];
    if (raw1 != null && raw1.toString().trim().isNotEmpty) return _str(raw1);

    // Aliases para ler de outras coleções
    if (k == 'NUMERODAOS') return _str(data['NUMERO_OS']);
    if (k == 'CADASTRO')
      return _str(data['DATADAMANUTENÇÃO'] ??
          data['DATADAMANUTENCAO'] ??
          data['INICIO']);
    if (k == 'TECNICO') return _str(data['TECNICORESPONSAVEL']);
    if (k == 'SERVICO') return _str(data['DEFEITO']);
    if (k == 'DESCRICAO') return _str(data['DESCRICAODOSERVICO']);
    if (k == 'PECA') return _str(data['PREVISAODAPECA']);
    if (k == 'TERMINO') return _str(data['DATA_TERMINO']);

    return '';
  }

  static String _str(dynamic val) {
    if (val == null) return '';
    if (val is List) return val.join(', ');
    return val.toString().trim();
  }
}

// ══════════════════════════════════════════════════════════════
//  CORES & TEMA
// ══════════════════════════════════════════════════════════════
const _kViolet = Color(0xFF3730A3);
const _kCyan = Color(0xFF0F766E);
const _kRose = Color(0xFFB91C1C);
const _kAmber = Color(0xFFB45309);
const _kEmerald = Color(0xFF047857);
const _kSlate = Color(0xFF64748B);
const _kPurple = Color(0xFF3730A3);

class _K {
  _K(BuildContext c) : dark = Theme.of(c).brightness == Brightness.dark;
  final bool dark;
  Color get bg => dark ? const Color(0xFF0D1117) : const Color(0xFFFFFFFF);
  Color get card => dark ? const Color(0xFF131720) : const Color(0xFFF7F8FC);
  Color get surf => dark ? const Color(0xFF1A1F2E) : const Color(0xFFF1F4F8);
  Color get input => dark ? const Color(0xFF1A1F2E) : const Color(0xFFF1F4F8);
  Color get bord => dark ? const Color(0x20FFFFFF) : const Color(0xFFDDE1E7);
  Color get bord2 => dark ? const Color(0x35FFFFFF) : const Color(0xFFC5CAD2);
  Color get ink => dark ? const Color(0xFFF1F5F9) : const Color(0xFF14181B);
  Color get ink2 => dark ? const Color(0xFF94A3B8) : const Color(0xFF57636C);
  Color get ink3 => dark ? const Color(0xFF475569) : const Color(0xFF9EA8B3);
}

TextStyle _ks(double sz, {Color? c, bool b = false, double? ls, double? h}) =>
    TextStyle(
        fontSize: sz,
        color: c,
        fontWeight: b ? FontWeight.w700 : FontWeight.w400,
        letterSpacing: ls,
        height: h);

Color _statusColor(String s) {
  final v = s.toUpperCase();
  if (v.contains('AGUARDANDO')) return _kAmber;
  if (v.contains('INICIOU')) return _kCyan;
  if (v.contains('CONCLU')) return _kEmerald;
  if (v.contains('CANCELAD')) return _kRose;
  if (v.contains('INICIAR')) return _kSlate;
  if (v.contains('PASSAR')) return _kAmber;
  if (v.contains('APROVAD')) return _kEmerald;
  return _kSlate;
}

// ══════════════════════════════════════════════════════════════
//  COLEÇÕES
// ══════════════════════════════════════════════════════════════
class _Col {
  const _Col(
      {required this.nome,
      required this.campoNos,
      required this.cor,
      required this.icone,
      required this.label});
  final String nome, campoNos, label;
  final Color cor;
  final IconData icone;
}

const _colecoes = [
  _Col(
      nome: 'SERVICOSREALIZADOS',
      campoNos: 'NUMERODAOS',
      cor: _kRose,
      icone: Icons.build_circle_rounded,
      label: 'Serviços'),
  _Col(
      nome: 'MANUTENCAO',
      campoNos: 'NUMERO_OS',
      cor: _kAmber,
      icone: Icons.settings_rounded,
      label: 'Manutenção'),
  _Col(
      nome: 'CORRETIVAS',
      campoNos: 'NUMERODAOS',
      cor: _kViolet,
      icone: Icons.handyman_rounded,
      label: 'Corretivas'),
];

// ══════════════════════════════════════════════════════════════
//  CAMPOS COMPARÁVEIS & EDITÁVEIS (CHAVES CANÔNICAS)
// ══════════════════════════════════════════════════════════════
const _camposComparaveis = [
  ('CLIENTE', 'Cliente', Icons.person_rounded),
  ('EQUIPAMENTO', 'Equipamento', Icons.devices_other_rounded),
  ('TECNICO', 'Técnico / Resp.', Icons.engineering_rounded),
  ('TECNICO2', 'Técnico 2', Icons.engineering_rounded),
  ('TECNICO3', 'Técnico 3', Icons.engineering_rounded),
  ('TECNICO4', 'Técnico 4', Icons.engineering_rounded),
  ('STATUS', 'Status', Icons.info_outline_rounded),
  ('MES', 'Mês', Icons.calendar_month_rounded),
  ('ANO', 'Ano', Icons.calendar_today_rounded),
  ('PATRIMONIO', 'Patrimônio', Icons.tag_rounded),
  ('CADASTRO', 'Cadastro / Manut.', Icons.date_range_rounded),
  ('SETOR', 'Setor', Icons.business_rounded),
  ('SALA', 'Sala', Icons.meeting_room_rounded),
  ('EMAIL', 'Email', Icons.email_rounded),
  ('INICIO', 'Início', Icons.play_arrow_rounded),
  ('TERMINO', 'Término', Icons.flag_rounded),
  ('SERVICO', 'Serviço / Defeito', Icons.report_problem_rounded),
  ('SERVICOREALIZADO', 'Serviço Realizado', Icons.check_circle_rounded),
  ('DESCRICAO', 'Descrição / Info.', Icons.notes_rounded),
  ('PECAS', 'Peças', Icons.build_rounded),
  ('VALOR', 'Valor', Icons.attach_money_rounded),
  ('FLUIDO', 'Fluido', Icons.water_drop_rounded),
  ('QUANTIDADEGAS', 'Qtd. Gás', Icons.propane_rounded),
  ('MARCA', 'Marca', Icons.label_rounded),
  ('MODELO', 'Modelo', Icons.category_rounded),
  ('BTUS', 'BTUs', Icons.thermostat_rounded),
  ('TIPO', 'Tipo', Icons.devices_rounded),
  ('RESPONSAVEL', 'Responsável', Icons.person_outline_rounded),
  ('NOME', 'Nome', Icons.badge_rounded),
  ('QUANTIDADE', 'Quantidade', Icons.numbers_rounded),
  ('PONTOS', 'Pontos', Icons.score_rounded),
  ('PECA', 'Prev. Peça', Icons.inventory_2_rounded),
];

const _todosCampos = [
  ('NUMERODAOS', 'N° O.S', Icons.tag_rounded, 'id'),
  ('CLIENTE', 'Cliente', Icons.person_rounded, 'texto'),
  ('EMAIL', 'Email', Icons.email_rounded, 'email'),
  ('PATRIMONIO', 'Patrimônio', Icons.tag_rounded, 'numero'),
  ('SALA', 'Sala', Icons.meeting_room_rounded, 'texto'),
  ('SETOR', 'Setor', Icons.business_rounded, 'texto'),
  ('MES', 'Mês', Icons.calendar_month_rounded, 'texto'),
  ('ANO', 'Ano', Icons.calendar_today_rounded, 'texto'),
  ('CADASTRO', 'Cadastro / Manut.', Icons.date_range_rounded, 'data'),
  ('INICIO', 'Início', Icons.play_arrow_rounded, 'data'),
  ('TERMINO', 'Término', Icons.flag_rounded, 'data'),
  ('EQUIPAMENTO', 'Equipamento', Icons.devices_other_rounded, 'texto'),
  ('FLUIDO', 'Fluido', Icons.water_drop_rounded, 'texto'),
  ('QUANTIDADEGAS', 'Qtd. Gás', Icons.propane_rounded, 'numero'),
  ('MARCA', 'Marca', Icons.label_rounded, 'texto'),
  ('MODELO', 'Modelo', Icons.category_rounded, 'texto'),
  ('BTUS', 'BTUs', Icons.thermostat_rounded, 'texto'),
  ('TIPO', 'Tipo', Icons.devices_rounded, 'texto'),
  ('TECNICO', 'Técnico / Resp.', Icons.engineering_rounded, 'texto'),
  ('TECNICO2', 'Técnico 2', Icons.engineering_rounded, 'texto'),
  ('TECNICO3', 'Técnico 3', Icons.engineering_rounded, 'texto'),
  ('TECNICO4', 'Técnico 4', Icons.engineering_rounded, 'texto'),
  ('RESPONSAVEL', 'Responsável', Icons.person_outline_rounded, 'texto'),
  ('NOME', 'Nome', Icons.badge_rounded, 'texto'),
  ('QUANTIDADE', 'Qtd. Técnicos', Icons.numbers_rounded, 'numero'),
  ('PONTOS', 'Pontos', Icons.score_rounded, 'numero'),
  ('STATUS', 'Status', Icons.info_outline_rounded, 'texto'),
  ('SERVICO', 'Serviço / Defeito', Icons.report_problem_rounded, 'multiline'),
  (
    'SERVICOREALIZADO',
    'Serv. Realizado',
    Icons.check_circle_rounded,
    'multiline'
  ),
  ('DESCRICAO', 'Descrição / Obs.', Icons.notes_rounded, 'multiline'),
  ('PECA', 'Prev. Peça', Icons.inventory_2_rounded, 'data'),
];

const _sOpts = [
  'INICIAR AVALIAÇÃO',
  'INICIOU O SERVIÇO',
  'PASSAR ORÇAMENTO',
  'CANCELADA',
  'AGUARDANDO PEÇA',
  'AGUARDANDO APROVAÇÃO',
  'APROVADO',
  'CONCLUÍDA',
];

const _meses = [
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

// ══════════════════════════════════════════════════════════════
//  DOCUMENTO INDIVIDUAL
// ══════════════════════════════════════════════════════════════
class _Documento {
  _Documento({required this.docId, required this.col, required this.data});
  final String docId;
  final _Col col;
  final Map<String, dynamic> data;

  String get nos {
    final a = (data['NUMERODAOS'] ?? '').toString().trim();
    final b = (data['NUMERO_OS'] ?? '').toString().trim();
    return a.isNotEmpty ? a : b;
  }

  // Usa o Mapeador para devolver o valor correto independente da coleção
  String field(String k) => _DbMapper.fromDb(data, k);
}

// ══════════════════════════════════════════════════════════════
//  GRUPO
// ══════════════════════════════════════════════════════════════
class _GrupoOs {
  _GrupoOs({required this.nos, required this.docs});
  final String nos;
  final List<_Documento> docs;

  Set<String> get colesPresentes => docs.map((d) => d.col.nome).toSet();
  List<_Col> get colesAusentes =>
      _colecoes.where((c) => !colesPresentes.contains(c.nome)).toList();

  Set<String> get camposDivergentes {
    if (docs.length < 2) return {};
    final div = <String>{};
    for (final (chave, _, __) in _camposComparaveis) {
      final vals = docs.map((d) {
        if (chave == 'PECAS' || chave == 'VALOR') {
          final raw = d.data[chave];
          if (raw is List) return raw.join(', ').toLowerCase();
          return (raw ?? '').toString().trim().toLowerCase();
        }
        return d.field(chave).toLowerCase();
      }).toSet();
      if (vals.every((v) => v.isEmpty)) continue;
      if (vals.length > 1) div.add(chave);
    }
    return div;
  }
}

/// ══════════════════════════════════════════════════════════════ WIDGET
/// PRINCIPAL ══════════════════════════════════════════════════════════════
class ExcluirOsWidget extends StatefulWidget {
  const ExcluirOsWidget({super.key, this.width, this.height});
  final double? width;
  final double? height;
  @override
  State<ExcluirOsWidget> createState() => _ExcState();
}

class _ExcState extends State<ExcluirOsWidget> {
  final _db = FirebaseFirestore.instance;
  final _cBusca = TextEditingController();
  bool _buscando = false, _buscaFeita = false;
  String _erroMsg = '';
  List<_GrupoOs> _grupos = [];
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _cBusca.dispose();
    super.dispose();
  }

  void _onChanged(String v) {
    _debounce?.cancel();
    if (v.trim().length < 2) {
      setState(() {
        _buscaFeita = false;
        _grupos = [];
        _erroMsg = '';
      });
      return;
    }
    _debounce =
        Timer(const Duration(milliseconds: 700), () => _buscar(v.trim()));
  }

  Future<void> _buscar(String q) async {
    setState(() {
      _buscando = true;
      _buscaFeita = false;
      _grupos = [];
      _erroMsg = '';
    });
    try {
      final qLow = q.toLowerCase();
      final snaps =
          await Future.wait(_colecoes.map((c) => _db.collection(c.nome).get()));
      final todos = <_Documento>[];

      for (int i = 0; i < _colecoes.length; i++) {
        final col = _colecoes[i];
        for (final doc in snaps[i].docs) {
          todos.add(_Documento(
              docId: doc.id,
              col: col,
              data: Map<String, dynamic>.from(doc.data())));
        }
      }

      final filtrados = todos.where((d) {
        final nos = d.nos.toLowerCase();
        final cli = d.field('CLIENTE').toLowerCase();
        final tec = d.field('TECNICO').toLowerCase();
        return nos.contains(qLow) || cli.contains(qLow) || tec.contains(qLow);
      }).toList();

      final Map<String, List<_Documento>> porNos = {};
      for (final d in filtrados) porNos.putIfAbsent(d.nos, () => []).add(d);

      final grupos = porNos.entries
          .map((e) => _GrupoOs(nos: e.key, docs: e.value))
          .toList();
      grupos.sort((a, b) {
        final aEx = a.nos.toLowerCase() == qLow ? 0 : 1;
        final bEx = b.nos.toLowerCase() == qLow ? 0 : 1;
        if (aEx != bEx) return aEx.compareTo(bEx);
        return a.nos.compareTo(b.nos);
      });

      setState(() {
        _buscaFeita = true;
        _grupos = grupos;
        if (grupos.isEmpty) _erroMsg = 'Nenhuma O.S encontrada para "$q".';
      });
    } catch (e) {
      setState(() {
        _buscaFeita = true;
        _erroMsg = 'Erro: $e';
      });
    } finally {
      if (mounted) setState(() => _buscando = false);
    }
  }

  void _rebuscar() {
    final q = _cBusca.text.trim();
    if (q.length >= 2) _buscar(q);
  }

  void _snack(String msg) => ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 5)));

  void _abrirCadastro() {
    Navigator.of(context).push(PageRouteBuilder(
      pageBuilder: (_, a1, a2) =>
          CadastrarOsPage(db: _db, dadosIniciais: {}, onSalvo: _rebuscar),
      transitionsBuilder: (_, a, __, child) => SlideTransition(
        position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
            .animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
        child: child,
      ),
      transitionDuration: const Duration(milliseconds: 350),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final k = _K(context);
    return Container(
      width: widget.width ?? double.infinity,
      height: widget.height,
      decoration:
          BoxDecoration(color: k.bg, borderRadius: BorderRadius.circular(22)),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        _Header(
            k: k,
            onCadastrar: _abrirCadastro),
        Flexible(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SearchBar(
                      k: k,
                      ctrl: _cBusca,
                      loading: _buscando,
                      onChanged: _onChanged,
                      onClear: () {
                        _cBusca.clear();
                        _onChanged('');
                      }),
                  const SizedBox(height: 20),
                  if (_buscando)
                    _Loading(k: k)
                  else if (_buscaFeita && _erroMsg.isNotEmpty)
                    _NotFound(msg: _erroMsg, k: k)
                  else if (_grupos.isNotEmpty)
                    _ListaGrupos(
                        k: k,
                        grupos: _grupos,
                        db: _db,
                        onRebuscar: _rebuscar,
                        snack: _snack)
                  else
                    _Placeholder(k: k, onCadastrar: _abrirCadastro),
                ]),
          ),
        ),
        _Footer(k: k, onFechar: () => Navigator.pop(context)),
      ]),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  PÁGINA DE CADASTRO
// ══════════════════════════════════════════════════════════════
class CadastrarOsPage extends StatefulWidget {
  const CadastrarOsPage({
    required this.db,
    required this.dadosIniciais,
    required this.onSalvo,
    this.colecaoDestino,
    this.nosFixo,
  });
  final FirebaseFirestore db;
  final Map<String, dynamic> dadosIniciais;
  final VoidCallback onSalvo;
  final _Col? colecaoDestino;
  final String? nosFixo;

  @override
  State<CadastrarOsPage> createState() => _CadastrarOsPageState();
}

class _CadastrarOsPageState extends State<CadastrarOsPage> {
  late _Col _colSel;
  late Map<String, TextEditingController> _ctrls;
  List<Map<String, String>> _pecas = [];
  final _cPecaAdd = TextEditingController();
  final _cValorAdd = TextEditingController();
  List<String> _equips = [], _tecs = [], _servicos = [];
  Map<String, String> _tFotos = {};
  bool _salvando = false, _loading = true;
  final Set<String> _erros = {};
  bool _tentou = false;
  String? _status, _mes;

  String _hoje() {
    final n = DateTime.now();
    return '${n.day.toString().padLeft(2, '0')}/${n.month.toString().padLeft(2, '0')}/${n.year}';
  }

  // Busca inicial unificada através do DbMapper
  String _vd(String key) => _DbMapper.fromDb(widget.dadosIniciais, key).trim();

  @override
  void initState() {
    super.initState();
    _colSel = widget.colecaoDestino ?? _colecoes[0];
    _status = _vd('STATUS').isNotEmpty ? _vd('STATUS') : null;
    _mes = _vd('MES').isNotEmpty ? _vd('MES') : null;
    _ctrls = {};
    for (final (ch, _, __, ___) in _todosCampos) {
      final v = _vd(ch);
      _ctrls[ch] = TextEditingController(
        text: v.isNotEmpty
            ? v
            : (ch == 'CADASTRO' || ch == 'INICIO' || ch == 'TERMINO')
                ? _hoje()
                : '',
      );
    }
    final pecasRaw = widget.dadosIniciais['PECAS'];
    final valoresRaw = widget.dadosIniciais['VALOR'];
    if (pecasRaw is List) {
      final valores = valoresRaw is List ? valoresRaw : [];
      for (int i = 0; i < pecasRaw.length; i++) {
        _pecas.add({
          'nome': pecasRaw[i].toString(),
          'valor': i < valores.length ? valores[i].toString() : '0',
        });
      }
    }
    _load();
  }

  Future<void> _load() async {
    try {
      final rs = await Future.wait([
        widget.db.collection('EQUIPAMENTOSCADASTRO').get(),
        widget.db.collection('PONTOS_POR_TECNICO').orderBy('TECNICO').get(),
        widget.db.collection('SERVICOSEPONTOS').orderBy('SERVICOS').get(),
      ]);
      final eqs = <String>[], tcs = <String>[], svs = <String>[];
      final fts = <String, String>{};
      for (final d in rs[0].docs) {
        final n = (d.data()['EQUIPAMENTOS'] ?? '').toString().trim();
        if (n.isNotEmpty) eqs.add(n);
      }
      for (final d in rs[1].docs) {
        final nm = (d.data()['TECNICO'] ?? '').toString().trim();
        final ft = (d.data()['FOTO'] ?? '').toString().trim();
        if (nm.isNotEmpty) {
          tcs.add(nm);
          if (_fotoValida(ft)) fts[nm] = ft;
        }
      }
      for (final d in rs[2].docs) {
        final nm = (d.data()['SERVICOS'] ?? '').toString().trim();
        if (nm.isNotEmpty) svs.add(nm);
      }
      if (mounted)
        setState(() {
          _equips = eqs;
          _tecs = tcs;
          _tFotos = fts;
          _servicos = svs;
          _loading = false;
        });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    for (final c in _ctrls.values) c.dispose();
    _cPecaAdd.dispose();
    _cValorAdd.dispose();
    super.dispose();
  }

  bool _validar() {
    final e = <String>{};
    if ((_ctrls['NUMERODAOS']?.text ?? '').trim().isEmpty &&
        widget.nosFixo == null) e.add('nos');
    if ((_ctrls['CLIENTE']?.text ?? '').trim().isEmpty) e.add('cli');
    setState(() {
      _tentou = true;
      _erros
        ..clear()
        ..addAll(e);
    });
    return e.isEmpty;
  }

  String _nos() {
    if (widget.nosFixo != null) return widget.nosFixo!;
    return (_ctrls['NUMERODAOS']?.text ?? '').trim();
  }

  Future<void> _salvar() async {
    if (!_validar()) return;
    setState(() => _salvando = true);
    try {
      final col = _colSel;
      final nos = _nos();
      final doc = <String, dynamic>{};

      // Mapeamento dinâmico via _DbMapper para a coleção destino
      for (final (ch, _, __, ___) in _todosCampos) {
        final dbKey = _DbMapper.toDb(ch, col.nome);
        final val = _ctrls[ch]?.text.trim() ?? '';

        if (ch == 'QUANTIDADE') {
          doc[dbKey] = double.tryParse(val) ?? 1.0;
        } else if (ch == 'PONTOS') {
          doc[dbKey] = double.tryParse(val) ?? 0.0;
        } else {
          doc[dbKey] = val;
        }
      }

      // Arrays e Fixos
      doc['STATUS'] = _status ?? '';
      doc['MES'] = _mes ?? '';
      doc['PECAS'] = _pecas.map((p) => p['nome'] ?? '').toList();
      doc['VALOR'] =
          _pecas.map((p) => double.tryParse(p['valor'] ?? '0') ?? 0.0).toList();
      doc['DATA'] = FieldValue.serverTimestamp();
      doc['CRIADO_MANUALMENTE'] = true;
      doc[col.campoNos] = nos;

      // Injeções Específicas por Coleção conforme lógica pré-estabelecida
      if (col.nome == 'MANUTENCAO') {
        doc['Empresa'] = true;
        doc['NOME'] = _ctrls['EQUIPAMENTO']?.text.trim() ?? '';
      } else if (col.nome == 'SERVICOSREALIZADOS') {
        doc['EMPRESA'] = true;
      }

      await widget.db.collection(col.nome).add(doc);
      widget.onSalvo();
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('✅  O.S #$nos cadastrada em ${col.label}!'),
          backgroundColor: _kEmerald,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ));
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('❌  Erro: $e'),
          backgroundColor: _kRose,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ));
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  void _adicionarPeca() {
    if (_cPecaAdd.text.trim().isEmpty) return;
    setState(() {
      _pecas.add({
        'nome': _cPecaAdd.text.trim(),
        'valor': _cValorAdd.text.trim().isEmpty ? '0' : _cValorAdd.text.trim()
      });
      _cPecaAdd.clear();
      _cValorAdd.clear();
    });
  }

  double get _totalPecas =>
      _pecas.fold(0, (s, p) => s + (double.tryParse(p['valor'] ?? '0') ?? 0));

  @override
  Widget build(BuildContext context) {
    final k = _K(context);
    final col = _colSel;
    final eCopia = widget.dadosIniciais.isNotEmpty;

    return Scaffold(
      backgroundColor: k.bg,
      appBar: AppBar(
        backgroundColor: k.card,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: k.surf,
                  border: Border.all(color: k.bord)),
              child: Icon(Icons.arrow_back_rounded, size: 18, color: k.ink2)),
        ),
        title: Row(children: [
          Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [col.cor, col.cor.withOpacity(.6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(11),
                  boxShadow: [
                    BoxShadow(
                        color: col.cor.withOpacity(.35),
                        blurRadius: 10,
                        offset: const Offset(0, 2))
                  ]),
              child: Icon(col.icone, color: Colors.white, size: 19)),
          const SizedBox(width: 12),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(eCopia ? 'COPIAR PARA COLEÇÃO' : 'CADASTRAR O.S',
                    style: _ks(15, c: k.ink, b: true)),
                Text(col.label, style: _ks(11, c: k.ink3)),
              ])),
        ]),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: Container(
              height: 2,
              decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                col.cor.withOpacity(.8),
                col.cor.withOpacity(.1)
              ]))),
        ),
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator(color: col.cor))
          : _buildForm(k, col, eCopia),
      bottomNavigationBar: _buildFooter(k, col),
    );
  }

  Widget _buildForm(_K k, _Col col, bool eCopia) => SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (eCopia) ...[
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                  color: col.cor.withOpacity(.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: col.cor.withOpacity(.3))),
              child: Row(children: [
                Icon(Icons.info_outline_rounded, color: col.cor, size: 16),
                const SizedBox(width: 8),
                Expanded(
                    child: Text(
                        'Dados pré-preenchidos. Edite o que precisar antes de salvar em ${col.label}.',
                        style: _ks(12, c: col.cor, h: 1.5))),
              ]),
            ),
          ],

          // Seletor de coleção
          if (widget.colecaoDestino == null)
            _Bloco(
                title: 'CADASTRAR EM',
                icon: Icons.storage_rounded,
                cor: _kCyan,
                k: k,
                children: [
                  Row(
                      children: _colecoes.map((c) {
                    final sel = c.nome == col.nome;
                    return Expanded(
                        child: Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: GestureDetector(
                        onTap: () => setState(() => _colSel = c),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: sel
                                ? c.cor.withOpacity(k.dark ? .18 : .1)
                                : k.surf,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: sel ? c.cor : k.bord,
                                width: sel ? 2 : 1),
                            boxShadow: sel
                                ? [
                                    BoxShadow(
                                        color: c.cor.withOpacity(.2),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2))
                                  ]
                                : [],
                          ),
                          child: Column(children: [
                            Icon(c.icone,
                                color: sel ? c.cor : k.ink3, size: 22),
                            const SizedBox(height: 6),
                            Text(c.label,
                                style: _ks(9, c: sel ? c.cor : k.ink3, b: sel),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis),
                            if (sel) ...[
                              const SizedBox(height: 4),
                              Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle, color: c.cor))
                            ],
                          ]),
                        ),
                      ),
                    ));
                  }).toList()),
                ]),

          // Identificação
          _Bloco(
              title: 'IDENTIFICAÇÃO',
              icon: Icons.assignment_rounded,
              cor: _kViolet,
              k: k,
              children: [
                _Row2(children: [
                  widget.nosFixo != null
                      ? _CampoReadOnly(
                          k: k,
                          label: 'N° O.S',
                          valor: widget.nosFixo!,
                          cor: _kViolet)
                      : _Campo(
                          k: k,
                          ctrl: _ctrls['NUMERODAOS']!,
                          label: 'N° O.S *',
                          cor: _kViolet,
                          erro: _erros.contains('nos'),
                          type: TextInputType.number),
                  _Campo(
                      k: k,
                      ctrl: _ctrls['CADASTRO']!,
                      label: 'Cadastro / Manut.',
                      cor: _kViolet,
                      mask: '##/##/####',
                      type: TextInputType.number),
                ]),
                _Campo(
                    k: k,
                    ctrl: _ctrls['CLIENTE']!,
                    label: 'Cliente *',
                    cor: _kViolet,
                    erro: _erros.contains('cli')),
                _Campo(
                    k: k,
                    ctrl: _ctrls['EMAIL']!,
                    label: 'Email',
                    cor: _kViolet,
                    type: TextInputType
                        .emailAddress), // EMAIL - sem maiúsculas forçadas
                _Row2(children: [
                  _Campo(
                      k: k,
                      ctrl: _ctrls['PATRIMONIO']!,
                      label: 'Patrimônio',
                      cor: _kViolet,
                      type: TextInputType.number),
                  _Campo(
                      k: k,
                      ctrl: _ctrls['SALA']!,
                      label: 'Sala',
                      cor: _kViolet),
                ]),
                _Row2(children: [
                  _Campo(
                      k: k,
                      ctrl: _ctrls['SETOR']!,
                      label: 'Setor',
                      cor: _kViolet),
                  _DropField(
                      k: k,
                      hint: 'Mês',
                      value: _mes,
                      items: _meses,
                      cor: _kViolet,
                      onChanged: (v) => setState(() => _mes = v)),
                ]),
                _Row2(children: [
                  _Campo(
                      k: k,
                      ctrl: _ctrls['INICIO']!,
                      label: 'Início',
                      cor: _kViolet,
                      mask: '##/##/####',
                      type: TextInputType.number),
                  _Campo(
                      k: k,
                      ctrl: _ctrls['TERMINO']!,
                      label: 'Término',
                      cor: _kViolet,
                      mask: '##/##/####',
                      type: TextInputType.number),
                ]),
              ]),

          // Equipamento
          _Bloco(
              title: 'EQUIPAMENTO',
              icon: Icons.devices_other_rounded,
              cor: col.cor,
              k: k,
              children: [
                _DropSearchField(
                    k: k,
                    hint: 'Equipamento',
                    cor: col.cor,
                    value: _ctrls['EQUIPAMENTO']!.text.isNotEmpty
                        ? _ctrls['EQUIPAMENTO']!.text
                        : null,
                    items: _equips,
                    onChanged: (v) =>
                        setState(() => _ctrls['EQUIPAMENTO']!.text = v ?? '')),
                _Row2(children: [
                  _Campo(
                      k: k,
                      ctrl: _ctrls['FLUIDO']!,
                      label: 'Fluido',
                      cor: col.cor),
                  _Campo(
                      k: k,
                      ctrl: _ctrls['QUANTIDADEGAS']!,
                      label: 'Qtd. Gás',
                      cor: col.cor,
                      type: TextInputType.number),
                ]),
                _Row2(children: [
                  _Campo(
                      k: k,
                      ctrl: _ctrls['MARCA']!,
                      label: 'Marca',
                      cor: col.cor),
                  _Campo(
                      k: k,
                      ctrl: _ctrls['MODELO']!,
                      label: 'Modelo',
                      cor: col.cor),
                ]),
                _Row2(children: [
                  _Campo(
                      k: k, ctrl: _ctrls['BTUS']!, label: 'BTUs', cor: col.cor),
                  _Campo(
                      k: k, ctrl: _ctrls['ANO']!, label: 'Ano', cor: col.cor),
                ]),
                _Campo(
                    k: k, ctrl: _ctrls['TIPO']!, label: 'Tipo', cor: col.cor),
              ]),

          // Técnico - Reduzido e Unificado
          _Bloco(
              title: 'TÉCNICO',
              icon: Icons.engineering_rounded,
              cor: _kCyan,
              k: k,
              children: [
                _DropSearchField(
                    k: k,
                    hint: 'Técnico / Responsável',
                    cor: _kCyan,
                    value: _ctrls['TECNICO']!.text.isNotEmpty
                        ? _ctrls['TECNICO']!.text
                        : null,
                    items: _tecs,
                    onChanged: (v) => setState(() {
                          _ctrls['TECNICO']!.text = v ?? '';
                        })),
                if (_ctrls['TECNICO']!.text.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  _TecPreview(
                      nome: _ctrls['TECNICO']!.text,
                      foto: _tFotos[_ctrls['TECNICO']!.text.trim()],
                      k: k),
                ],
                _Row2(children: [
                  _Campo(
                      k: k,
                      ctrl: _ctrls['TECNICO2']!,
                      label: 'Técnico 2',
                      cor: _kCyan),
                  _Campo(
                      k: k,
                      ctrl: _ctrls['TECNICO3']!,
                      label: 'Técnico 3',
                      cor: _kCyan),
                ]),
                _Row2(children: [
                  _Campo(
                      k: k,
                      ctrl: _ctrls['TECNICO4']!,
                      label: 'Técnico 4',
                      cor: _kCyan),
                  _Campo(
                      k: k,
                      ctrl: _ctrls['PONTOS']!,
                      label: 'Pontos',
                      cor: _kCyan,
                      type: TextInputType.number),
                ]),
                _Row2(children: [
                  _Campo(
                      k: k,
                      ctrl: _ctrls['RESPONSAVEL']!,
                      label: 'Responsável',
                      cor: _kCyan),
                  _Campo(
                      k: k, ctrl: _ctrls['NOME']!, label: 'Nome', cor: _kCyan),
                ]),
                _Campo(
                    k: k,
                    ctrl: _ctrls['QUANTIDADE']!,
                    label: 'Qtd. Técnicos',
                    cor: _kCyan,
                    type: TextInputType.number),
              ]),

          // Defeito / Serviço - Reduzido e Unificado
          _Bloco(
              title: 'DEFEITO / SERVIÇO',
              icon: Icons.report_problem_rounded,
              cor: _kAmber,
              k: k,
              children: [
                _Campo(
                    k: k,
                    ctrl: _ctrls['SERVICO']!,
                    label: 'Serviço Solicitado / Defeito',
                    cor: _kAmber,
                    maxLines: 2),
                _DropSearchField(
                    k: k,
                    hint: 'Serviço Realizado',
                    cor: _kEmerald,
                    value: _ctrls['SERVICOREALIZADO']!.text.isNotEmpty
                        ? _ctrls['SERVICOREALIZADO']!.text
                        : null,
                    items: _servicos,
                    onChanged: (v) => setState(
                        () => _ctrls['SERVICOREALIZADO']!.text = v ?? '')),
                _Campo(
                    k: k,
                    ctrl: _ctrls['DESCRICAO']!,
                    label: 'Descrição do Serviço / Obs.',
                    cor: _kAmber,
                    maxLines: 3),
              ]),

          // Status
          _Bloco(
              title: 'STATUS',
              icon: Icons.flag_rounded,
              cor: col.cor,
              k: k,
              children: [
                _DropField(
                    k: k,
                    hint: 'Status',
                    value: _status,
                    items: _sOpts,
                    cor: col.cor,
                    onChanged: (v) => setState(() => _status = v)),
                if (_status != null) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                        color: _statusColor(_status!).withOpacity(.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: _statusColor(_status!).withOpacity(.4))),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _statusColor(_status!))),
                      const SizedBox(width: 6),
                      Text(_status!,
                          style: _ks(11, c: _statusColor(_status!), b: true)),
                    ]),
                  ),
                ],
                const SizedBox(height: 6),
                _Campo(
                    k: k,
                    ctrl: _ctrls['PECA']!,
                    label: 'Previsão da Peça',
                    cor: _kPurple,
                    mask: '##/##/####',
                    type: TextInputType.number),
              ]),

          // Peças & Valores
          _Bloco(
              title: 'PEÇAS & VALORES',
              icon: Icons.build_rounded,
              cor: _kAmber,
              k: k,
              children: [
                if (_pecas.isNotEmpty) ...[
                  ..._pecas.asMap().entries.map((e) {
                    final idx = e.key;
                    final peca = e.value;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                          color: k.surf,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: _kAmber.withOpacity(.3))),
                      child: Row(children: [
                        Icon(Icons.build_rounded, color: _kAmber, size: 15),
                        const SizedBox(width: 10),
                        Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                              Text(peca['nome'] ?? '',
                                  style: _ks(12, c: k.ink, b: true)),
                              const SizedBox(height: 2),
                              Row(children: [
                                Icon(Icons.attach_money_rounded,
                                    color: _kEmerald, size: 13),
                                Text(
                                    'R\$ ${double.tryParse(peca['valor'] ?? '0')?.toStringAsFixed(2) ?? '0,00'}',
                                    style: _ks(11, c: _kEmerald, b: true)),
                              ]),
                            ])),
                        GestureDetector(
                            onTap: () => setState(() => _pecas.removeAt(idx)),
                            child: const Icon(Icons.close_rounded,
                                color: _kRose, size: 18)),
                      ]),
                    );
                  }),
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                        color: _kEmerald.withOpacity(.08),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: _kEmerald.withOpacity(.3))),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Total:', style: _ks(12, c: k.ink2, b: true)),
                          Text('R\$ ${_totalPecas.toStringAsFixed(2)}',
                              style: _ks(13, c: _kEmerald, b: true)),
                        ]),
                  ),
                ],
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: _kAmber.withOpacity(.05),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: _kAmber.withOpacity(.2))),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Adicionar peça / serviço',
                            style: _ks(11, c: _kAmber, b: true)),
                        const SizedBox(height: 8),
                        _Campo(
                            k: k,
                            ctrl: _cPecaAdd,
                            label: 'Nome da peça/serviço',
                            hint: 'Ex: INSTALAÇÃO DE AR CONDICIONADO',
                            cor: _kAmber),
                        _Campo(
                            k: k,
                            ctrl: _cValorAdd,
                            label: 'Valor (R\$)',
                            hint: '0.00',
                            type: const TextInputType.numberWithOptions(
                                decimal: true),
                            cor: _kAmber),
                        Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: _adicionarPeca,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                      colors: [_kAmber, Color(0xFFB45309)]),
                                  borderRadius: BorderRadius.circular(9),
                                  boxShadow: [
                                    BoxShadow(
                                        color: _kAmber.withOpacity(.3),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2))
                                  ]),
                              child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.add_rounded,
                                        color: Colors.white, size: 15),
                                    const SizedBox(width: 5),
                                    Text('ADICIONAR',
                                        style:
                                            _ks(11, c: Colors.white, b: true)),
                                  ]),
                            ),
                          ),
                        ),
                      ]),
                ),
              ]),

          if (_tentou && _erros.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                  color: _kRose.withOpacity(.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _kRose.withOpacity(.3))),
              child: Row(children: [
                const Icon(Icons.error_outline_rounded,
                    color: _kRose, size: 15),
                const SizedBox(width: 8),
                Text('Preencha os campos obrigatórios (*)',
                    style: _ks(12, c: _kRose)),
              ]),
            ),

          const SizedBox(height: 80),
        ]),
      );

  Widget _buildFooter(_K k, _Col col) => SafeArea(
        child: Container(
          padding: EdgeInsets.fromLTRB(
              16, 10, 16, 16 + MediaQuery.of(context).padding.bottom),
          decoration: BoxDecoration(
              color: k.card, border: Border(top: BorderSide(color: k.bord))),
          child: Row(children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                  height: 48,
                  width: 100,
                  decoration: BoxDecoration(
                      color: k.surf,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: k.bord2)),
                  child: Center(
                      child: Text('Cancelar',
                          style: _ks(13, c: k.ink2, b: true)))),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: _salvando ? null : _salvar,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 48,
                  decoration: BoxDecoration(
                      gradient: _salvando
                          ? null
                          : LinearGradient(
                              colors: [col.cor, col.cor.withOpacity(.75)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight),
                      color: _salvando ? k.bord : null,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: _salvando
                          ? []
                          : [
                              BoxShadow(
                                  color: col.cor.withOpacity(.35),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3))
                            ]),
                  child: Center(
                      child: _salvando
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2.5))
                          : Row(mainAxisSize: MainAxisSize.min, children: [
                              const Icon(Icons.save_rounded,
                                  color: Colors.white, size: 17),
                              const SizedBox(width: 8),
                              Text('SALVAR EM ${col.label.toUpperCase()}',
                                  style: _ks(13, c: Colors.white, b: true)),
                            ])),
                ),
              ),
            ),
          ]),
        ),
      );
}

// ══════════════════════════════════════════════════════════════
//  CAMPO SOMENTE LEITURA
// ══════════════════════════════════════════════════════════════
class _CampoReadOnly extends StatelessWidget {
  const _CampoReadOnly(
      {required this.k,
      required this.label,
      required this.valor,
      required this.cor});
  final _K k;
  final String label, valor;
  final Color cor;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(Icons.tag_rounded, size: 11, color: k.ink3),
            const SizedBox(width: 4),
            Text(label, style: _ks(10, c: k.ink3)),
            const SizedBox(width: 6),
            Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                    color: k.bord2, borderRadius: BorderRadius.circular(4)),
                child: Text('fixo', style: _ks(8, c: k.ink3))),
          ]),
          const SizedBox(height: 4),
          Container(
              height: 48,
              decoration: BoxDecoration(
                  color: k.input.withOpacity(.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: k.bord)),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(children: [
                Expanded(child: Text(valor, style: _ks(14, c: k.ink3))),
                const Icon(Icons.lock_outline_rounded,
                    size: 14, color: _kSlate),
              ])),
        ]),
      );
}

// ══════════════════════════════════════════════════════════════
//  LISTA DE GRUPOS
// ══════════════════════════════════════════════════════════════
class _ListaGrupos extends StatelessWidget {
  const _ListaGrupos(
      {required this.k,
      required this.grupos,
      required this.db,
      required this.onRebuscar,
      required this.snack});
  final _K k;
  final List<_GrupoOs> grupos;
  final FirebaseFirestore db;
  final VoidCallback onRebuscar;
  final void Function(String) snack;

  @override
  Widget build(BuildContext context) {
    final totalDocs = grupos.fold(0, (s, g) => s + g.docs.length);
    final comDiverg =
        grupos.where((g) => g.camposDivergentes.isNotEmpty).length;
    final comAus = grupos.where((g) => g.colesAusentes.isNotEmpty).length;
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Wrap(spacing: 6, runSpacing: 6, children: [
            _Badge('${grupos.length} N° O.S', _kViolet),
            _Badge('$totalDocs registros', _kRose),
            if (comDiverg > 0) _Badge('$comDiverg com divergência', _kAmber),
            if (comAus > 0) _Badge('$comAus com ausência', _kSlate),
          ]),
          const SizedBox(height: 12),
          ...grupos.map((g) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _GrupoCard(
                    k: k,
                    grupo: g,
                    db: db,
                    onRebuscar: onRebuscar,
                    snack: snack),
              )),
        ]);
  }
}

// ══════════════════════════════════════════════════════════════
//  CARD DO GRUPO
// ══════════════════════════════════════════════════════════════
class _GrupoCard extends StatefulWidget {
  const _GrupoCard(
      {required this.k,
      required this.grupo,
      required this.db,
      required this.onRebuscar,
      required this.snack});
  final _K k;
  final _GrupoOs grupo;
  final FirebaseFirestore db;
  final VoidCallback onRebuscar;
  final void Function(String) snack;
  @override
  State<_GrupoCard> createState() => _GrupoCardState();
}

class _GrupoCardState extends State<_GrupoCard> {
  bool _expandido = false;

  void _abrirCopia(BuildContext ctx, _Col colDestino) {
    final dadosMesclados = <String, dynamic>{};
    for (final doc in widget.grupo.docs) {
      for (final (ch, _, __, ___) in _todosCampos) {
        final val = doc.field(ch);
        if (val.isNotEmpty) dadosMesclados[ch] = val;
      }
      if (doc.data['PECAS'] != null)
        dadosMesclados['PECAS'] = doc.data['PECAS'];
      if (doc.data['VALOR'] != null)
        dadosMesclados['VALOR'] = doc.data['VALOR'];
    }

    Navigator.of(ctx).push(PageRouteBuilder(
      pageBuilder: (_, a1, a2) => CadastrarOsPage(
          db: widget.db,
          dadosIniciais: dadosMesclados,
          colecaoDestino: colDestino,
          nosFixo: widget.grupo.nos,
          onSalvo: widget.onRebuscar),
      transitionsBuilder: (_, a, __, child) => SlideTransition(
          position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
              .animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
          child: child),
      transitionDuration: const Duration(milliseconds: 350),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final k = widget.k;
    final grupo = widget.grupo;
    final docs = grupo.docs;
    final dupl = docs.length > 1;
    final ausent = grupo.colesAusentes;
    final diverg = grupo.camposDivergentes;
    final ref = docs.first;

    Color bordaCor = k.bord;
    if (diverg.isNotEmpty)
      bordaCor = _kAmber;
    else if (ausent.isNotEmpty)
      bordaCor = _kSlate.withOpacity(.6);
    else if (dupl) bordaCor = _kCyan.withOpacity(.4);

    return Container(
      decoration: BoxDecoration(
          color: k.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: bordaCor, width: 1.5),
          boxShadow: [
            BoxShadow(
                color:
                    k.dark ? const Color(0x30000000) : const Color(0x0C000000),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Cabeçalho
        GestureDetector(
          onTap: () => setState(() => _expandido = !_expandido),
          child: Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            decoration: BoxDecoration(
                color:
                    k.dark ? const Color(0xFF1A1F2E) : const Color(0xFFF1F4F8),
                borderRadius: _expandido
                    ? const BorderRadius.vertical(top: Radius.circular(16))
                    : BorderRadius.circular(16),
                border: _expandido
                    ? Border(bottom: BorderSide(color: k.bord))
                    : null),
            child: Row(children: [
              Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [_kViolet, _kCyan],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight),
                      borderRadius: BorderRadius.circular(8)),
                  child: Text('O.S #${grupo.nos}',
                      style: _ks(13, c: Colors.white, b: true, ls: .3))),
              const SizedBox(width: 8),
              Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                  decoration: BoxDecoration(
                      color: (dupl ? _kAmber : _kEmerald).withOpacity(.13),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                          color: (dupl ? _kAmber : _kEmerald).withOpacity(.4))),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(
                        dupl
                            ? Icons.copy_all_rounded
                            : Icons.check_circle_rounded,
                        size: 11,
                        color: dupl ? _kAmber : _kEmerald),
                    const SizedBox(width: 4),
                    Text(dupl ? '${docs.length} reg.' : '1 reg.',
                        style: _ks(10, c: dupl ? _kAmber : _kEmerald, b: true)),
                  ])),
              const SizedBox(width: 6),
              ...grupo.colesPresentes.map((nome) {
                final col = _colecoes.firstWhere((c) => c.nome == nome);
                return Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                            color: col.cor.withOpacity(.12),
                            borderRadius: BorderRadius.circular(5),
                            border:
                                Border.all(color: col.cor.withOpacity(.35))),
                        child: Text(col.label,
                            style: _ks(8, c: col.cor, b: true))));
              }),
              if (diverg.isNotEmpty) ...[
                const SizedBox(width: 4),
                Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                        color: _kAmber.withOpacity(.15),
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(color: _kAmber.withOpacity(.4))),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.compare_arrows_rounded,
                          size: 10, color: _kAmber),
                      const SizedBox(width: 3),
                      Text('${diverg.length} dif.',
                          style: _ks(8, c: _kAmber, b: true)),
                    ])),
              ],
              if (ausent.isNotEmpty) ...[
                const SizedBox(width: 4),
                Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                        color: _kSlate.withOpacity(.12),
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(color: _kSlate.withOpacity(.35))),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.warning_amber_rounded,
                          size: 10, color: _kSlate),
                      const SizedBox(width: 3),
                      Text('${ausent.length} aus.',
                          style: _ks(8, c: k.ink3, b: true)),
                    ])),
              ],
              const Spacer(),
              AnimatedRotation(
                  turns: _expandido ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(Icons.keyboard_arrow_down_rounded,
                      color: k.ink3, size: 22)),
            ]),
          ),
        ),

        // Resumo recolhido
        if (!_expandido)
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Icon(Icons.person_rounded, size: 13, color: k.ink3),
                const SizedBox(width: 5),
                Expanded(
                    child: Text(ref.field('CLIENTE'),
                        style: _ks(12, c: k.ink, b: true),
                        overflow: TextOverflow.ellipsis)),
                const SizedBox(width: 10),
                Icon(Icons.engineering_rounded, size: 13, color: k.ink3),
                const SizedBox(width: 5),
                Expanded(
                    child: Text(ref.field('TECNICO'),
                        style: _ks(12, c: k.ink),
                        overflow: TextOverflow.ellipsis)),
              ]),
              if (diverg.isNotEmpty) ...[
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => setState(() => _expandido = true),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    decoration: BoxDecoration(
                        color: _kAmber.withOpacity(.08),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: _kAmber.withOpacity(.3))),
                    child: Row(children: [
                      const Icon(Icons.compare_arrows_rounded,
                          size: 13, color: _kAmber),
                      const SizedBox(width: 6),
                      Expanded(
                          child: Text(
                              'Campos diferentes: ${diverg.map((ch) {
                                final c = _camposComparaveis.firstWhere(
                                    (x) => x.$1 == ch,
                                    orElse: () =>
                                        (ch, ch, Icons.info_outline_rounded));
                                return c.$2;
                              }).join(", ")}',
                              style: _ks(10, c: _kAmber))),
                      const Icon(Icons.arrow_forward_ios_rounded,
                          size: 10, color: _kAmber),
                    ]),
                  ),
                ),
              ],
              if (ausent.isNotEmpty) ...[
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: () => setState(() => _expandido = true),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    decoration: BoxDecoration(
                        color: _kSlate.withOpacity(.07),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: _kSlate.withOpacity(.3))),
                    child: Row(children: [
                      Icon(Icons.warning_amber_rounded,
                          size: 13, color: k.ink3),
                      const SizedBox(width: 6),
                      Expanded(
                          child: Text(
                              'Ausente em: ${ausent.map((c) => c.label).join(", ")}',
                              style: _ks(10, c: k.ink3))),
                      Icon(Icons.arrow_forward_ios_rounded,
                          size: 10, color: k.ink3),
                    ]),
                  ),
                ),
              ],
            ]),
          ),

        // Expandido
        if (_expandido) ...[
          const SizedBox(height: 8),

          // Painel comparação (com edição inline)
          if (diverg.isNotEmpty && docs.length > 1)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              child: _PainelComparacao(k: k, grupo: grupo, divergentes: diverg),
            ),

          // Seção registros
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 6),
            child: Row(children: [
              _BarraLateral(cor1: _kViolet, cor2: _kCyan),
              const SizedBox(width: 8),
              Text('REGISTROS', style: _ks(10, c: k.ink3, b: true, ls: .4)),
              const SizedBox(width: 8),
              _Badge('${docs.length}', _kViolet),
            ]),
          ),

          ...docs.asMap().entries.map((entry) {
            final idx = entry.key;
            final doc = entry.value;
            return Padding(
              padding: EdgeInsets.fromLTRB(
                  10, 0, 10, idx == docs.length - 1 ? 10 : 6),
              child: _DocCard(
                  k: k,
                  doc: doc,
                  indice: idx + 1,
                  totalDocs: docs.length,
                  db: widget.db,
                  camposDivergentes: diverg,
                  onExcluido: () {
                    widget.snack('✅  Registro excluído.');
                    widget.onRebuscar();
                  },
                  onSalvo: () {
                    widget.snack('✅  Registro atualizado.');
                    widget.onRebuscar();
                  },
                  onCopiar: (col) => _abrirCopia(context, col),
                  snack: widget.snack),
            );
          }),

          // Ausentes
          if (ausent.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 6),
              child: Row(children: [
                _BarraLateral(cor1: _kSlate, cor2: _kSlate.withOpacity(.4)),
                const SizedBox(width: 8),
                Text('AUSENTE EM', style: _ks(10, c: k.ink3, b: true, ls: .4)),
                const SizedBox(width: 8),
                _Badge('${ausent.length}', _kSlate),
              ]),
            ),
            ...ausent.map((col) => Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 8),
                  child: _AusenteCard(
                      k: k,
                      col: col,
                      grupo: grupo,
                      onCriarCopia: () => _abrirCopia(context, col)),
                )),
          ],

          if (ausent.isEmpty && diverg.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
              child: _Banner(
                  icon: Icons.verified_rounded,
                  cor: _kEmerald,
                  msg:
                      'Todos os registros são consistentes e a O.S está em todas as coleções.'),
            ),
        ],
      ]),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  PAINEL DE COMPARAÇÃO — com edição inline e salvar por coleção
// ══════════════════════════════════════════════════════════════
class _PainelComparacao extends StatefulWidget {
  const _PainelComparacao(
      {required this.k, required this.grupo, required this.divergentes});
  final _K k;
  final _GrupoOs grupo;
  final Set<String> divergentes;
  @override
  State<_PainelComparacao> createState() => _PainelComparacaoState();
}

class _PainelComparacaoState extends State<_PainelComparacao> {
  late Map<String, Map<String, TextEditingController>> _ctrls;
  final Map<String, bool> _salvando = {};
  final Set<String> _editando = {};

  @override
  void initState() {
    super.initState();
    _ctrls = {};
    for (final doc in widget.grupo.docs) {
      _ctrls[doc.docId] = {};
      _salvando[doc.docId] = false;
      for (final (ch, _, __) in _camposComparaveis) {
        String v;
        if (ch == 'PECAS' || ch == 'VALOR') {
          final raw = doc.data[ch];
          v = raw is List ? raw.join(', ') : (raw ?? '').toString().trim();
        } else {
          v = doc.field(ch);
        }
        _ctrls[doc.docId]![ch] = TextEditingController(text: v);
      }
    }
  }

  @override
  void dispose() {
    for (final m in _ctrls.values) for (final c in m.values) c.dispose();
    super.dispose();
  }

  bool _celEditando(String docId, String campo) =>
      _editando.contains('$docId:$campo');

  void _toggleEdit(String docId, String campo) {
    setState(() {
      final key = '$docId:$campo';
      if (_editando.contains(key))
        _editando.remove(key);
      else
        _editando.add(key);
    });
  }

  // ── Auto ajusta UM campo com confirmação interativa ─────
  Future<void> _autoAjustarCampo(String chave) async {
    final docs = widget.grupo.docs;
    if (docs.length < 2) return;

    final meta = _camposComparaveis.firstWhere((c) => c.$1 == chave,
        orElse: () => (chave, chave, Icons.info));

    final Map<String, List<String>> origemDosValores = {};
    final Set<String> valoresUnicos = {};

    for (final doc in docs) {
      final val = _ctrls[doc.docId]![chave]!.text.trim();
      if (val.isNotEmpty) {
        if (origemDosValores[val] == null) {
          origemDosValores[val] = [];
        }
        origemDosValores[val]!.add(doc.col.label);
        valoresUnicos.add(val);
      }
    }

    if (valoresUnicos.isEmpty) {
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(SnackBar(
        content: const Text(
            '⚠️  Nenhuma das abas possui informação neste campo para ser copiada.'),
        backgroundColor: _kAmber,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ));
      return;
    }

    String valorSelecionado = valoresUnicos.first;

    final confirmar = await showDialog<String>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            backgroundColor: widget.k.card,
            surfaceTintColor: Colors.transparent,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                const Icon(Icons.auto_fix_high_rounded,
                    color: _kCyan, size: 24),
                const SizedBox(width: 10),
                Expanded(
                    child: Text('Igualar ${meta.$2}',
                        style: _ks(16, c: widget.k.ink, b: true))),
              ],
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        'Qual informação você deseja manter para todas as abas?',
                        style: _ks(13, c: widget.k.ink3, h: 1.4)),
                    const SizedBox(height: 16),
                    ...valoresUnicos.map((val) {
                      final colecoesOrigem = origemDosValores[val]!.join(' / ');
                      final isSelected = valorSelecionado == val;

                      return GestureDetector(
                        onTap: () {
                          setStateDialog(() {
                            valorSelecionado = val;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? _kCyan.withOpacity(.1)
                                : widget.k.input,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected ? _kCyan : widget.k.bord,
                              width: isSelected ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Icon(
                                  isSelected
                                      ? Icons.radio_button_checked_rounded
                                      : Icons.radio_button_unchecked_rounded,
                                  color: isSelected ? _kCyan : widget.k.ink3,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(val,
                                        style: _ks(14,
                                            c: widget.k.ink, b: isSelected)),
                                    const SizedBox(height: 4),
                                    Text('Presente em: $colecoesOrigem',
                                        style: _ks(10, c: widget.k.ink3)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                    GestureDetector(
                      onTap: () {
                        setStateDialog(() {
                          valorSelecionado = '';
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        margin: const EdgeInsets.only(top: 4, bottom: 4),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: valorSelecionado == ''
                              ? _kCyan.withOpacity(.1)
                              : widget.k.input,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color:
                                valorSelecionado == '' ? _kCyan : widget.k.bord,
                            width: valorSelecionado == '' ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              valorSelecionado == ''
                                  ? Icons.radio_button_checked_rounded
                                  : Icons.radio_button_unchecked_rounded,
                              color: valorSelecionado == ''
                                  ? _kCyan
                                  : widget.k.ink3,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text('Deixar campo vazio',
                                  style: _ks(14,
                                      c: widget.k.ink3,
                                      b: valorSelecionado == '')),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, null),
                child:
                    Text('Cancelar', style: _ks(13, c: widget.k.ink2, b: true)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kCyan,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                onPressed: () => Navigator.pop(ctx, valorSelecionado),
                child:
                    Text('Confirmar', style: _ks(13, c: Colors.white, b: true)),
              ),
            ],
          );
        },
      ),
    );

    if (confirmar == null) return;

    setState(() {
      for (final doc in docs) {
        _ctrls[doc.docId]![chave]!.text = confirmar;
      }
    });

    ScaffoldMessenger.maybeOf(context)?.showSnackBar(SnackBar(
      content: const Text(
          '⚡  Campo igualado em todas as abas. Revise e clique em SALVAR.'),
      backgroundColor: _kCyan,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 3),
    ));
  }

  Future<void> _salvarColuna(_Documento doc) async {
    setState(() => _salvando[doc.docId] = true);
    try {
      final db = FirebaseFirestore.instance;
      final updates = <String, dynamic>{};

      for (final (ch, _, __) in _camposComparaveis) {
        final val = _ctrls[doc.docId]![ch]!.text.trim();
        if (ch == 'PECAS') {
          updates[ch] = val
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList();
        } else if (ch == 'VALOR') {
          updates[ch] = val
              .split(',')
              .map((e) => double.tryParse(e.trim()) ?? 0.0)
              .toList();
        } else {
          // Usa o mapeamento na hora de salvar
          final dbKey = _DbMapper.toDb(ch, doc.col.nome);
          updates[dbKey] = val;
        }
      }
      updates['ATUALIZADO_EM'] = FieldValue.serverTimestamp();
      await db.collection(doc.col.nome).doc(doc.docId).update(updates);
      _editando.removeWhere((k) => k.startsWith('${doc.docId}:'));
      if (mounted) {
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(SnackBar(
          content: Text('✅  ${doc.col.label} atualizada!'),
          backgroundColor: _kEmerald,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        ));
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(SnackBar(
          content: Text('❌  Erro: $e'),
          backgroundColor: _kRose,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ));
    } finally {
      if (mounted) setState(() => _salvando[doc.docId] = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final k = widget.k;
    final docs = widget.grupo.docs;

    return Container(
      decoration: BoxDecoration(
        color: _kAmber.withOpacity(k.dark ? .08 : .04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kAmber.withOpacity(.4), width: 1.5),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header
        Container(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          decoration: BoxDecoration(
            color: _kAmber.withOpacity(k.dark ? .12 : .07),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
          ),
          child: Row(children: [
            Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                    color: _kAmber.withOpacity(.2),
                    borderRadius: BorderRadius.circular(7)),
                child: const Icon(Icons.compare_arrows_rounded,
                    color: _kAmber, size: 15)),
            const SizedBox(width: 8),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text('COMPARAÇÃO DE CAMPOS',
                      style: _ks(11, c: _kAmber, b: true, ls: .3)),
                  Text(
                      '${widget.divergentes.length} campo${widget.divergentes.length > 1 ? "s" : ""} '
                      'divergentes — ✏ editar · ⚡ igualar por linha',
                      style: _ks(9, c: _kAmber)),
                ])),
          ]),
        ),

        Padding(
          padding: const EdgeInsets.all(10),
          child: Column(children: [
            // Cabeçalho da tabela
            Row(children: [
              SizedBox(
                  width: 90,
                  child: Text('Campo', style: _ks(9, c: k.ink3, b: true))),
              ...docs.map((doc) => Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(left: 4),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 4),
                      decoration: BoxDecoration(
                        color: doc.col.cor.withOpacity(.12),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: doc.col.cor.withOpacity(.3)),
                      ),
                      child: Column(children: [
                        Icon(doc.col.icone, size: 11, color: doc.col.cor),
                        const SizedBox(height: 2),
                        Text(doc.col.label,
                            style: _ks(8, c: doc.col.cor, b: true),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis),
                      ]),
                    ),
                  )),
            ]),

            const SizedBox(height: 8),

            // Todas as linhas
            ..._camposComparaveis.map((meta) {
              final chave = meta.$1;
              final isDiverg = widget.divergentes.contains(chave);

              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Label + botão ⚡ por linha
                      SizedBox(
                          width: 90,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(children: [
                                  Icon(meta.$3,
                                      size: 11,
                                      color: isDiverg ? _kAmber : k.ink3),
                                  const SizedBox(width: 4),
                                  Flexible(
                                      child: Text(meta.$2,
                                          style: _ks(9,
                                              c: isDiverg ? _kAmber : k.ink3,
                                              b: isDiverg),
                                          overflow: TextOverflow.ellipsis)),
                                ]),
                                // Botão AUTO AJUSTAR por linha
                                if (isDiverg) ...[
                                  const SizedBox(height: 4),
                                  GestureDetector(
                                    onTap: () => _autoAjustarCampo(chave),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 5, vertical: 3),
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [Color(0xFF0369A1), _kCyan],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(5),
                                        boxShadow: [
                                          BoxShadow(
                                              color: _kCyan.withOpacity(.25),
                                              blurRadius: 4,
                                              offset: const Offset(0, 1))
                                        ],
                                      ),
                                      child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                                Icons.auto_fix_high_rounded,
                                                color: Colors.white,
                                                size: 9),
                                            const SizedBox(width: 3),
                                            Text('IGUALAR',
                                                style: _ks(7,
                                                    c: Colors.white, b: true)),
                                          ]),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          )),

                      // Células editáveis
                      ...docs.map((doc) {
                        final ctrl = _ctrls[doc.docId]![chave]!;
                        final editing = _celEditando(doc.docId, chave);
                        final valorAtual = ctrl.text;
                        final outrosVals =
                            docs.where((d) => d.docId != doc.docId).map((d) {
                          if (chave == 'PECAS' || chave == 'VALOR') {
                            final raw = d.data[chave];
                            return (raw is List
                                    ? raw.join(', ')
                                    : (raw ?? '').toString().trim())
                                .toLowerCase();
                          }
                          return d.field(chave).toLowerCase();
                        }).toSet();
                        final difere = isDiverg &&
                            !outrosVals.contains(valorAtual.toLowerCase());

                        return Expanded(
                          child: GestureDetector(
                            onTap: () => _toggleEdit(doc.docId, chave),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              margin: const EdgeInsets.only(left: 4),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 6, vertical: editing ? 2 : 5),
                              decoration: BoxDecoration(
                                color: editing
                                    ? doc.col.cor
                                        .withOpacity(k.dark ? .12 : .06)
                                    : difere
                                        ? _kAmber.withOpacity(k.dark ? .18 : .1)
                                        : k.input,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: editing
                                      ? doc.col.cor
                                      : difere
                                          ? _kAmber.withOpacity(.5)
                                          : k.bord,
                                  width: editing || difere ? 1.5 : 1,
                                ),
                              ),
                              child: editing
                                  ? TextField(
                                      controller: ctrl,
                                      style: _ks(9, c: k.ink),
                                      cursorColor: doc.col.cor,
                                      maxLines: null,
                                      inputFormatters: [
                                        if (chave != 'EMAIL' &&
                                            chave != 'VALOR' &&
                                            chave != 'QUANTIDADE' &&
                                            chave != 'QUANTIDADEGAS')
                                          UpperCaseTextFormatter()
                                      ],
                                      textCapitalization: chave != 'EMAIL'
                                          ? TextCapitalization.characters
                                          : TextCapitalization.none,
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        isDense: true,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 2, vertical: 4),
                                        suffixIcon: GestureDetector(
                                            onTap: () =>
                                                _toggleEdit(doc.docId, chave),
                                            child: Icon(Icons.check_rounded,
                                                size: 14, color: doc.col.cor)),
                                      ),
                                      onSubmitted: (_) =>
                                          _toggleEdit(doc.docId, chave),
                                    )
                                  : Row(children: [
                                      if (difere) ...[
                                        const Icon(Icons.priority_high_rounded,
                                            size: 10, color: _kAmber),
                                        const SizedBox(width: 3),
                                      ],
                                      Flexible(
                                          child: Text(
                                              valorAtual.isEmpty
                                                  ? '—'
                                                  : valorAtual,
                                              style: _ks(9,
                                                  c: difere ? _kAmber : k.ink,
                                                  b: difere),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 2)),
                                      const SizedBox(width: 4),
                                      Icon(Icons.edit_rounded,
                                          size: 9,
                                          color: k.ink3.withOpacity(.4)),
                                    ]),
                            ),
                          ),
                        );
                      }),
                    ]),
              );
            }),

            // Legenda + botões salvar
            const SizedBox(height: 8),
            const Divider(height: 1),
            const SizedBox(height: 10),

            Row(children: [
              Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                      color: _kAmber.withOpacity(.2),
                      borderRadius: BorderRadius.circular(3),
                      border: Border.all(color: _kAmber.withOpacity(.5)))),
              const SizedBox(width: 5),
              Text('Valor diferente', style: _ks(9, c: k.ink3)),
              const SizedBox(width: 12),
              Icon(Icons.edit_rounded, size: 10, color: k.ink3.withOpacity(.5)),
              const SizedBox(width: 4),
              Text('Toque para editar', style: _ks(9, c: k.ink3)),
            ]),

            const SizedBox(height: 10),

            // Botão SALVAR por coluna
            Row(children: [
              const SizedBox(width: 94),
              ...docs.map((doc) {
                final salvando = _salvando[doc.docId] ?? false;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: GestureDetector(
                      onTap: salvando ? null : () => _salvarColuna(doc),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: 36,
                        decoration: BoxDecoration(
                            gradient: salvando
                                ? null
                                : LinearGradient(
                                    colors: [
                                        doc.col.cor,
                                        doc.col.cor.withOpacity(.7)
                                      ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight),
                            color: salvando ? k.bord : null,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: salvando
                                ? []
                                : [
                                    BoxShadow(
                                        color: doc.col.cor.withOpacity(.3),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2))
                                  ]),
                        child: Center(
                            child: salvando
                                ? const SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(
                                        color: Colors.white, strokeWidth: 2))
                                : Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                        const Icon(Icons.save_rounded,
                                            color: Colors.white, size: 12),
                                        const SizedBox(width: 4),
                                        Text('SALVAR',
                                            style: _ks(9,
                                                c: Colors.white, b: true)),
                                      ])),
                      ),
                    ),
                  ),
                );
              }),
            ]),
          ]),
        ),
      ]),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  CARD DE COLEÇÃO AUSENTE
// ══════════════════════════════════════════════════════════════
class _AusenteCard extends StatelessWidget {
  const _AusenteCard(
      {required this.k,
      required this.col,
      required this.grupo,
      required this.onCriarCopia});
  final _K k;
  final _Col col;
  final _GrupoOs grupo;
  final VoidCallback onCriarCopia;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        decoration: BoxDecoration(
            color: k.input.withOpacity(.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _kSlate.withOpacity(.3), width: 1.5)),
        child: Row(children: [
          Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                  color: col.cor.withOpacity(.15),
                  borderRadius: BorderRadius.circular(9)),
              child: Icon(col.icone, color: col.cor, size: 17)),
          const SizedBox(width: 10),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(col.nome, style: _ks(12, c: k.ink, b: true)),
                Text('${col.label} — não cadastrada',
                    style: _ks(10, c: k.ink3)),
              ])),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onCriarCopia,
            child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [col.cor, col.cor.withOpacity(.75)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight),
                    borderRadius: BorderRadius.circular(9),
                    boxShadow: [
                      BoxShadow(
                          color: col.cor.withOpacity(.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2))
                    ]),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.edit_note_rounded,
                      size: 14, color: Colors.white),
                  const SizedBox(width: 5),
                  Text('CADASTRAR & EDITAR',
                      style: _ks(10, c: Colors.white, b: true)),
                ])),
          ),
        ]),
      );
}

// ══════════════════════════════════════════════════════════════
//  DOC CARD
// ══════════════════════════════════════════════════════════════
class _DocCard extends StatefulWidget {
  const _DocCard(
      {required this.k,
      required this.doc,
      required this.indice,
      required this.totalDocs,
      required this.db,
      required this.camposDivergentes,
      required this.onExcluido,
      required this.onSalvo,
      required this.onCopiar,
      required this.snack});
  final _K k;
  final _Documento doc;
  final int indice, totalDocs;
  final FirebaseFirestore db;
  final Set<String> camposDivergentes;
  final VoidCallback onExcluido, onSalvo;
  final void Function(_Col) onCopiar;
  final void Function(String) snack;
  @override
  State<_DocCard> createState() => _DocCardState();
}

class _DocCardState extends State<_DocCard> {
  bool _editando = false,
      _salvando = false,
      _excluindo = false,
      _confirmando = false;
  late Map<String, TextEditingController> _ctrls;
  List<Map<String, String>> _pecas = [];
  final _cPecaAdd = TextEditingController();
  final _cValorAdd = TextEditingController();

  @override
  void initState() {
    super.initState();
    _inicializarCtrls();
  }

  void _inicializarCtrls() {
    _ctrls = {};
    for (final (ch, _, __, ___) in _todosCampos) {
      _ctrls[ch] =
          TextEditingController(text: widget.doc.field(ch)); // Via DbMapper
    }
    _pecas.clear();
    final pecasRaw = widget.doc.data['PECAS'];
    final valoresRaw = widget.doc.data['VALOR'];
    if (pecasRaw is List) {
      final valores = valoresRaw is List ? valoresRaw : [];
      for (int i = 0; i < pecasRaw.length; i++) {
        _pecas.add({
          'nome': pecasRaw[i].toString(),
          'valor': i < valores.length ? valores[i].toString() : '0',
        });
      }
    }
  }

  @override
  void dispose() {
    for (final c in _ctrls.values) c.dispose();
    _cPecaAdd.dispose();
    _cValorAdd.dispose();
    super.dispose();
  }

  void _adicionarPeca() {
    if (_cPecaAdd.text.trim().isEmpty) return;
    setState(() {
      _pecas.add({
        'nome': _cPecaAdd.text.trim(),
        'valor': _cValorAdd.text.trim().isEmpty ? '0' : _cValorAdd.text.trim()
      });
      _cPecaAdd.clear();
      _cValorAdd.clear();
    });
  }

  Future<void> _salvar() async {
    setState(() => _salvando = true);
    try {
      final updates = <String, dynamic>{};
      for (final (ch, _, __, ___) in _todosCampos) {
        final dbKey = _DbMapper.toDb(ch, widget.doc.col.nome);
        final val = _ctrls[ch]!.text.trim();

        if (ch == 'QUANTIDADE') {
          updates[dbKey] = double.tryParse(val) ?? 1.0;
        } else if (ch == 'PONTOS') {
          updates[dbKey] = double.tryParse(val) ?? 0.0;
        } else {
          updates[dbKey] = val;
        }
      }
      updates['PECAS'] = _pecas.map((p) => p['nome'] ?? '').toList();
      updates['VALOR'] =
          _pecas.map((p) => double.tryParse(p['valor'] ?? '0') ?? 0.0).toList();
      updates['ATUALIZADO_EM'] = FieldValue.serverTimestamp();
      await widget.db
          .collection(widget.doc.col.nome)
          .doc(widget.doc.docId)
          .update(updates);
      setState(() => _editando = false);
      widget.onSalvo();
    } catch (e) {
      widget.snack('Erro: $e');
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  Future<void> _excluir() async {
    setState(() => _excluindo = true);
    try {
      await widget.db
          .collection(widget.doc.col.nome)
          .doc(widget.doc.docId)
          .delete();
      widget.onExcluido();
    } catch (e) {
      widget.snack('Erro: $e');
      if (mounted) setState(() => _excluindo = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final k = widget.k;
    final doc = widget.doc;
    final col = doc.col;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      decoration: BoxDecoration(
          color: _editando ? col.cor.withOpacity(k.dark ? .1 : .04) : k.bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color:
                  _editando ? col.cor.withOpacity(.6) : col.cor.withOpacity(.3),
              width: _editando ? 2 : 1.5)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Cabeçalho
        Container(
          padding: const EdgeInsets.fromLTRB(12, 9, 12, 9),
          decoration: BoxDecoration(
              color: col.cor.withOpacity(k.dark ? .12 : .06),
              borderRadius: BorderRadius.circular(10)),
          child: Row(children: [
            Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                    color: col.cor.withOpacity(.2),
                    borderRadius: BorderRadius.circular(8)),
                child: Icon(col.icone, color: col.cor, size: 15)),
            const SizedBox(width: 8),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Row(children: [
                    Text(col.label, style: _ks(12, c: col.cor, b: true)),
                    const SizedBox(width: 6),
                    if (widget.totalDocs > 1)
                      Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                              color: _kAmber.withOpacity(.15),
                              borderRadius: BorderRadius.circular(4),
                              border:
                                  Border.all(color: _kAmber.withOpacity(.4))),
                          child: Text(
                              'reg. ${widget.indice}/${widget.totalDocs}',
                              style: _ks(8, c: _kAmber, b: true))),
                    if (widget.camposDivergentes.isNotEmpty) ...[
                      const SizedBox(width: 4),
                      Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                              color: _kAmber.withOpacity(.12),
                              borderRadius: BorderRadius.circular(4),
                              border:
                                  Border.all(color: _kAmber.withOpacity(.3))),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            const Icon(Icons.compare_arrows_rounded,
                                size: 9, color: _kAmber),
                            const SizedBox(width: 3),
                            Text('ver comparação', style: _ks(8, c: _kAmber)),
                          ])),
                    ],
                  ]),
                  Text('ID: ${doc.docId}',
                      style: _ks(9, c: k.ink3),
                      overflow: TextOverflow.ellipsis),
                ])),
            Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                    color: _statusColor(doc.field('STATUS')).withOpacity(.13),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                        color:
                            _statusColor(doc.field('STATUS')).withOpacity(.4))),
                child: Text(
                    doc.field('STATUS').length > 10
                        ? '${doc.field('STATUS').substring(0, 9)}…'
                        : doc.field('STATUS'),
                    style:
                        _ks(9, c: _statusColor(doc.field('STATUS')), b: true))),
          ]),
        ),

        // Preview ou Formulário
        if (!_editando)
          _PreviewDoc(
              k: k, doc: doc, camposDivergentes: widget.camposDivergentes)
        else
          _FormularioDoc(
              k: k,
              col: col,
              ctrls: _ctrls,
              salvando: _salvando,
              nosValue: doc.nos,
              camposDivergentes: widget.camposDivergentes,
              pecas: _pecas,
              cPecaAdd: _cPecaAdd,
              cValorAdd: _cValorAdd,
              onAddPeca: _adicionarPeca,
              onRemovePeca: (idx) => setState(() => _pecas.removeAt(idx)),
              onSalvar: _salvar,
              onCancelar: () => setState(() {
                    _editando = false;
                    _inicializarCtrls();
                  })),

        // Barra de ações
        if (!_confirmando)
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 4, 10, 10),
            child: Row(children: [
              Expanded(
                child: GestureDetector(
                  onTap: _excluindo
                      ? null
                      : () => setState(() {
                            _editando = !_editando;
                            _confirmando = false;
                            if (!_editando) _inicializarCtrls();
                          }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    height: 38,
                    decoration: BoxDecoration(
                        color: _editando
                            ? k.bord2
                            : col.cor.withOpacity(k.dark ? .15 : .08),
                        borderRadius: BorderRadius.circular(9),
                        border: Border.all(
                            color:
                                _editando ? k.bord : col.cor.withOpacity(.4))),
                    child: Center(
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(_editando ? Icons.close_rounded : Icons.edit_rounded,
                          size: 14, color: _editando ? k.ink2 : col.cor),
                      const SizedBox(width: 5),
                      Text(_editando ? 'Cancelar' : 'Editar',
                          style: _ks(11,
                              c: _editando ? k.ink2 : col.cor, b: true)),
                    ])),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (_editando)
                Expanded(
                    flex: 2,
                    child: GestureDetector(
                      onTap: _salvando ? null : _salvar,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: 38,
                        decoration: BoxDecoration(
                            gradient: _salvando
                                ? null
                                : LinearGradient(
                                    colors: [col.cor, col.cor.withOpacity(.7)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight),
                            color: _salvando ? k.bord : null,
                            borderRadius: BorderRadius.circular(9),
                            boxShadow: _salvando
                                ? []
                                : [
                                    BoxShadow(
                                        color: col.cor.withOpacity(.3),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2))
                                  ]),
                        child: Center(
                            child: _salvando
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                        color: Colors.white, strokeWidth: 2))
                                : Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                        const Icon(Icons.save_rounded,
                                            color: Colors.white, size: 14),
                                        const SizedBox(width: 5),
                                        Text('SALVAR',
                                            style: _ks(11,
                                                c: Colors.white, b: true)),
                                      ])),
                      ),
                    ))
              else
                GestureDetector(
                  onTap: _excluindo
                      ? null
                      : () => setState(() => _confirmando = true),
                  child: Container(
                    height: 38,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                        color: _kRose.withOpacity(k.dark ? .12 : .07),
                        borderRadius: BorderRadius.circular(9),
                        border: Border.all(color: _kRose.withOpacity(.4))),
                    child: Center(
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.delete_outline_rounded,
                          size: 14, color: _kRose),
                      const SizedBox(width: 5),
                      Text('Excluir', style: _ks(11, c: _kRose, b: true)),
                    ])),
                  ),
                ),
            ]),
          )
        else
          _ConfirmacaoExclusao(
              k: k,
              col: col,
              excluindo: _excluindo,
              onConfirmar: _excluir,
              onCancelar: () => setState(() => _confirmando = false)),
      ]),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  PREVIEW
// ══════════════════════════════════════════════════════════════
class _PreviewDoc extends StatelessWidget {
  const _PreviewDoc(
      {required this.k, required this.doc, required this.camposDivergentes});
  final _K k;
  final _Documento doc;
  final Set<String> camposDivergentes;

  @override
  Widget build(BuildContext context) {
    final visiveis = _camposComparaveis.where((c) {
      final v = doc.field(c.$1);
      return v.isNotEmpty && v != '—';
    }).toList();
    if (visiveis.isEmpty) return const SizedBox(height: 8);

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Wrap(
          spacing: 6,
          runSpacing: 6,
          children: visiveis.map((c) {
            final valor = doc.field(c.$1);
            final diverg = camposDivergentes.contains(c.$1);
            return Container(
              constraints: const BoxConstraints(maxWidth: 240),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                  color: diverg
                      ? _kAmber.withOpacity(k.dark ? .15 : .08)
                      : k.input,
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(
                      color: diverg ? _kAmber.withOpacity(.5) : k.bord,
                      width: diverg ? 1.5 : 1)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                if (diverg) ...[
                  const Icon(Icons.priority_high_rounded,
                      size: 10, color: _kAmber),
                  const SizedBox(width: 3),
                ],
                Icon(c.$3, size: 11, color: diverg ? _kAmber : k.ink3),
                const SizedBox(width: 5),
                Flexible(
                    child: RichText(
                  overflow: TextOverflow.ellipsis,
                  text: TextSpan(children: [
                    TextSpan(
                        text: '${c.$2}: ',
                        style: _ks(10, c: diverg ? _kAmber : k.ink3)),
                    TextSpan(
                        text: valor,
                        style: _ks(10, c: diverg ? _kAmber : k.ink, b: true)),
                  ]),
                )),
              ]),
            );
          }).toList()),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  FORMULÁRIO DE EDIÇÃO INLINE
// ══════════════════════════════════════════════════════════════
class _FormularioDoc extends StatelessWidget {
  const _FormularioDoc(
      {required this.k,
      required this.col,
      required this.ctrls,
      required this.salvando,
      required this.nosValue,
      required this.camposDivergentes,
      required this.pecas,
      required this.cPecaAdd,
      required this.cValorAdd,
      required this.onAddPeca,
      required this.onRemovePeca,
      required this.onSalvar,
      required this.onCancelar});
  final _K k;
  final _Col col;
  final Map<String, TextEditingController> ctrls;
  final bool salvando;
  final String nosValue;
  final Set<String> camposDivergentes;
  final List<Map<String, String>> pecas;
  final TextEditingController cPecaAdd, cValorAdd;
  final VoidCallback onAddPeca;
  final void Function(int) onRemovePeca;
  final VoidCallback onSalvar, onCancelar;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 6, 10, 4),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // N° O.S somente leitura
        Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
              color: k.input.withOpacity(.5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: k.bord)),
          child: Row(children: [
            Icon(Icons.tag_rounded, size: 12, color: k.ink3),
            const SizedBox(width: 6),
            Text('N° O.S: ', style: _ks(11, c: k.ink3)),
            Text(nosValue, style: _ks(11, c: k.ink, b: true)),
            const Spacer(),
            const Icon(Icons.lock_outline_rounded, size: 13, color: _kSlate),
          ]),
        ),

        // Campos em grid 2 colunas
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _todosCampos
              .where((c) => c.$1 != 'NUMERODAOS' && c.$1 != 'NUMERO_OS')
              .map((c) {
            final ctrl = ctrls[c.$1];
            if (ctrl == null) return const SizedBox.shrink();
            final diverg = camposDivergentes.contains(c.$1);
            final multi = c.$4 == 'multiline';

            return SizedBox(
              width: multi
                  ? double.infinity
                  : (MediaQuery.of(context).size.width - 110) / 2,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Icon(c.$3, size: 11, color: diverg ? _kAmber : col.cor),
                      const SizedBox(width: 4),
                      Text(c.$2, style: _ks(10, c: k.ink, b: true)),
                      if (diverg) ...[
                        const SizedBox(width: 4),
                        Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                                color: _kAmber.withOpacity(.15),
                                borderRadius: BorderRadius.circular(3)),
                            child: Text('divergente',
                                style: _ks(7, c: _kAmber, b: true))),
                      ],
                    ]),
                    const SizedBox(height: 4),
                    Container(
                      constraints: BoxConstraints(minHeight: multi ? 70 : 36),
                      decoration: BoxDecoration(
                          color: diverg
                              ? _kAmber.withOpacity(k.dark ? .1 : .05)
                              : k.input,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: diverg
                                  ? _kAmber.withOpacity(.5)
                                  : col.cor.withOpacity(.35),
                              width: 1.5)),
                      child: TextField(
                        controller: ctrl,
                        maxLines: multi ? 3 : 1,
                        style: _ks(12, c: k.ink),
                        cursorColor: diverg ? _kAmber : col.cor,
                        inputFormatters: [
                          if (c.$1 != 'EMAIL' &&
                              c.$1 != 'VALOR' &&
                              c.$1 != 'QUANTIDADE' &&
                              c.$1 != 'QUANTIDADEGAS')
                            UpperCaseTextFormatter()
                        ],
                        textCapitalization: c.$1 != 'EMAIL'
                            ? TextCapitalization.characters
                            : TextCapitalization.none,
                        decoration: const InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 8)),
                      ),
                    ),
                  ]),
            );
          }).toList(),
        ),

        const SizedBox(height: 12),

        _Bloco(
            title: 'PEÇAS & VALORES',
            icon: Icons.build_rounded,
            cor: _kAmber,
            k: k,
            children: [
              if (pecas.isNotEmpty) ...[
                ...pecas.asMap().entries.map((e) {
                  final idx = e.key;
                  final peca = e.value;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                        color: k.surf,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: _kAmber.withOpacity(.3))),
                    child: Row(children: [
                      Icon(Icons.build_rounded, color: _kAmber, size: 15),
                      const SizedBox(width: 10),
                      Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            Text(peca['nome'] ?? '',
                                style: _ks(12, c: k.ink, b: true)),
                            const SizedBox(height: 2),
                            Row(children: [
                              Icon(Icons.attach_money_rounded,
                                  color: _kEmerald, size: 13),
                              Text(
                                  'R\$ ${double.tryParse(peca['valor'] ?? '0')?.toStringAsFixed(2) ?? '0,00'}',
                                  style: _ks(11, c: _kEmerald, b: true)),
                            ]),
                          ])),
                      GestureDetector(
                          onTap: () => onRemovePeca(idx),
                          child: const Icon(Icons.close_rounded,
                              color: _kRose, size: 18)),
                    ]),
                  );
                }),
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                      color: _kEmerald.withOpacity(.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _kEmerald.withOpacity(.3))),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total:', style: _ks(12, c: k.ink2, b: true)),
                        Text(
                            'R\$ ${pecas.fold<double>(0, (s, p) => s + (double.tryParse(p['valor'] ?? '0') ?? 0)).toStringAsFixed(2)}',
                            style: _ks(13, c: _kEmerald, b: true)),
                      ]),
                ),
              ],
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: _kAmber.withOpacity(.05),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _kAmber.withOpacity(.2))),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Adicionar peça / serviço',
                          style: _ks(11, c: _kAmber, b: true)),
                      const SizedBox(height: 8),
                      _Campo(
                          k: k,
                          ctrl: cPecaAdd,
                          label: 'Nome da peça/serviço',
                          hint: 'Ex: INSTALAÇÃO DE AR CONDICIONADO',
                          cor: _kAmber),
                      _Campo(
                          k: k,
                          ctrl: cValorAdd,
                          label: 'Valor (R\$)',
                          hint: '0.00',
                          type: const TextInputType.numberWithOptions(
                              decimal: true),
                          cor: _kAmber),
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: onAddPeca,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                    colors: [_kAmber, Color(0xFFB45309)]),
                                borderRadius: BorderRadius.circular(9),
                                boxShadow: [
                                  BoxShadow(
                                      color: _kAmber.withOpacity(.3),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2))
                                ]),
                            child:
                                Row(mainAxisSize: MainAxisSize.min, children: [
                              const Icon(Icons.add_rounded,
                                  color: Colors.white, size: 15),
                              const SizedBox(width: 5),
                              Text('ADICIONAR',
                                  style: _ks(11, c: Colors.white, b: true)),
                            ]),
                          ),
                        ),
                      ),
                    ]),
              ),
            ]),

        const Divider(height: 1),
        const SizedBox(height: 10),

        Row(children: [
          Expanded(
              child: GestureDetector(
                  onTap: onCancelar,
                  child: Container(
                      height: 38,
                      decoration: BoxDecoration(
                          color: k.card,
                          borderRadius: BorderRadius.circular(9),
                          border: Border.all(color: k.bord2)),
                      child: Center(
                          child: Text('Cancelar',
                              style: _ks(12, c: k.ink2, b: true)))))),
          const SizedBox(width: 8),
          Expanded(
              flex: 2,
              child: GestureDetector(
                  onTap: salvando ? null : onSalvar,
                  child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: 38,
                      decoration: BoxDecoration(
                          gradient: salvando
                              ? null
                              : LinearGradient(
                                  colors: [col.cor, col.cor.withOpacity(.75)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight),
                          color: salvando ? k.bord : null,
                          borderRadius: BorderRadius.circular(9),
                          boxShadow: salvando
                              ? []
                              : [
                                  BoxShadow(
                                      color: col.cor.withOpacity(.3),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2))
                                ]),
                      child: Center(
                          child: salvando
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2))
                              : Row(mainAxisSize: MainAxisSize.min, children: [
                                  const Icon(Icons.save_rounded,
                                      color: Colors.white, size: 14),
                                  const SizedBox(width: 5),
                                  Text('SALVAR ALTERAÇÕES',
                                      style: _ks(11, c: Colors.white, b: true)),
                                ]))))),
        ]),
        const SizedBox(height: 2),
      ]),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  CONFIRMAÇÃO EXCLUSÃO
// ══════════════════════════════════════════════════════════════
class _ConfirmacaoExclusao extends StatelessWidget {
  const _ConfirmacaoExclusao(
      {required this.k,
      required this.col,
      required this.excluindo,
      required this.onConfirmar,
      required this.onCancelar});
  final _K k;
  final _Col col;
  final bool excluindo;
  final VoidCallback onConfirmar, onCancelar;
  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.fromLTRB(10, 4, 10, 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: _kRose.withOpacity(k.dark ? .12 : .06),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _kRose.withOpacity(.4))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.warning_rounded, color: _kRose, size: 15),
            const SizedBox(width: 6),
            Expanded(
                child: Text(
                    'Excluir este registro de ${col.label}? Ação irreversível.',
                    style: _ks(11, c: _kRose))),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(
                child: GestureDetector(
                    onTap: onCancelar,
                    child: Container(
                        height: 36,
                        decoration: BoxDecoration(
                            color: k.card,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: k.bord2)),
                        child: Center(
                            child: Text('Cancelar',
                                style: _ks(12, c: k.ink2, b: true)))))),
            const SizedBox(width: 8),
            Expanded(
                child: GestureDetector(
                    onTap: excluindo ? null : onConfirmar,
                    child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: 36,
                        decoration: BoxDecoration(
                            gradient: excluindo
                                ? null
                                : const LinearGradient(
                                    colors: [_kRose, Color(0xFFFF6B6B)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight),
                            color: excluindo ? k.bord : null,
                            borderRadius: BorderRadius.circular(8)),
                        child: Center(
                            child: excluindo
                                ? const SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(
                                        color: Colors.white, strokeWidth: 2))
                                : Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                        const Icon(Icons.delete_forever_rounded,
                                            color: Colors.white, size: 13),
                                        const SizedBox(width: 4),
                                        Text('CONFIRMAR',
                                            style: _ks(11,
                                                c: Colors.white, b: true)),
                                      ]))))),
          ]),
        ]),
      );
}

// ══════════════════════════════════════════════════════════════
//  COMPONENTES DE FORMULÁRIO
// ══════════════════════════════════════════════════════════════
class _Bloco extends StatelessWidget {
  const _Bloco(
      {required this.title,
      required this.icon,
      required this.cor,
      required this.k,
      required this.children});
  final String title;
  final IconData icon;
  final Color cor;
  final _K k;
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
            color: k.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: k.bord)),
        clipBehavior: Clip.hardEdge,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
              padding: const EdgeInsets.fromLTRB(14, 11, 14, 11),
              decoration: BoxDecoration(
                  color: cor.withOpacity(k.dark ? .08 : .05),
                  border: Border(bottom: BorderSide(color: k.bord))),
              child: Row(children: [
                Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                        color: cor.withOpacity(.15),
                        borderRadius: BorderRadius.circular(7)),
                    child: Icon(icon, size: 13, color: cor)),
                const SizedBox(width: 10),
                Text(title, style: _ks(9, c: k.ink3, ls: 1.4, b: true)),
              ])),
          Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: children)),
        ]),
      );
}

class _Row2 extends StatelessWidget {
  const _Row2({required this.children});
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => Row(
      children: children
          .asMap()
          .entries
          .map((e) => Expanded(
              child: Padding(
                  padding: EdgeInsets.only(
                      right: e.key < children.length - 1 ? 8 : 0),
                  child: e.value)))
          .toList());
}

class _Campo extends StatefulWidget {
  const _Campo(
      {required this.k,
      required this.ctrl,
      required this.label,
      this.hint,
      this.maxLines = 1,
      this.type,
      this.mask,
      this.cor,
      this.erro = false,
      this.onChanged});
  final _K k;
  final TextEditingController ctrl;
  final String label;
  final String? hint;
  final int maxLines;
  final TextInputType? type;
  final String? mask;
  final Color? cor;
  final bool erro;
  final void Function(String)? onChanged;
  @override
  State<_Campo> createState() => _CampoState();
}

class _CampoState extends State<_Campo> {
  bool _focus = false;
  @override
  Widget build(BuildContext context) {
    final k = widget.k;
    final ac = widget.cor ?? _kCyan;
    final err = widget.erro;

    List<TextInputFormatter> formatters = [];
    if (widget.mask != null) {
      formatters.add(MaskTextInputFormatter(mask: widget.mask!));
    }
    // Aplica letras maiúsculas automaticamente em todos os campos exceto email
    if (widget.type != TextInputType.emailAddress) {
      formatters.add(UpperCaseTextFormatter());
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Focus(
        onFocusChange: (v) => setState(() => _focus = v),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          constraints: BoxConstraints(minHeight: widget.maxLines > 1 ? 72 : 48),
          decoration: BoxDecoration(
              color: err
                  ? _kRose.withOpacity(.05)
                  : _focus
                      ? ac.withOpacity(k.dark ? .06 : .04)
                      : k.input,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: err
                      ? _kRose
                      : _focus
                          ? ac
                          : k.bord,
                  width: err || _focus ? 1.5 : 1)),
          child: TextFormField(
            controller: widget.ctrl,
            maxLines: widget.maxLines,
            keyboardType: widget.type,
            inputFormatters: formatters.isNotEmpty ? formatters : null,
            textCapitalization: widget.type != TextInputType.emailAddress
                ? TextCapitalization.characters
                : TextCapitalization.none,
            style: _ks(14, c: k.ink),
            onChanged: widget.onChanged,
            cursorColor: ac,
            decoration: InputDecoration(
                isDense: true,
                labelText: widget.label,
                labelStyle: _ks(12,
                    c: err
                        ? _kRose
                        : _focus
                            ? ac
                            : k.ink3),
                hintText: widget.hint,
                hintStyle: _ks(13, c: k.ink3),
                filled: true,
                fillColor: Colors.transparent,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                suffixIcon: err
                    ? const Icon(Icons.error_outline_rounded,
                        color: _kRose, size: 18)
                    : null),
          ),
        ),
      ),
    );
  }
}

class _DropField extends StatelessWidget {
  const _DropField(
      {required this.k,
      required this.hint,
      required this.value,
      required this.items,
      required this.onChanged,
      this.cor,
      this.erro = false});
  final _K k;
  final String hint;
  final String? value;
  final List<String> items;
  final void Function(String?) onChanged;
  final Color? cor;
  final bool erro;
  @override
  Widget build(BuildContext context) {
    final ac = cor ?? _kCyan;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: () => showModalBottomSheet(
            context: context,
            backgroundColor: Colors.transparent,
            isScrollControlled: true,
            isDismissible: true,
            enableDrag: true,
            useSafeArea: true,
            builder: (_) => _SheetPicker(
                k: k,
                hint: hint,
                value: value,
                items: items,
                onChanged: onChanged,
                cor: ac,
                searchable: false)),
        child: Container(
            height: 48,
            decoration: BoxDecoration(
                color: erro ? _kRose.withOpacity(.05) : k.input,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: erro ? _kRose : k.bord)),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(children: [
              Expanded(
                  child: Text(value ?? hint,
                      style: _ks(14,
                          c: value != null
                              ? k.ink
                              : erro
                                  ? _kRose.withOpacity(.7)
                                  : k.ink3),
                      overflow: TextOverflow.ellipsis)),
              Icon(Icons.keyboard_arrow_down_rounded, color: k.ink3, size: 22),
            ])),
      ),
    );
  }
}

class _DropSearchField extends StatelessWidget {
  const _DropSearchField(
      {required this.k,
      required this.hint,
      required this.value,
      required this.items,
      required this.onChanged,
      this.cor});
  final _K k;
  final String hint;
  final String? value;
  final List<String> items;
  final void Function(String?) onChanged;
  final Color? cor;
  @override
  Widget build(BuildContext context) {
    final ac = cor ?? _kCyan;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: () => showModalBottomSheet(
            context: context,
            backgroundColor: Colors.transparent,
            isScrollControlled: true,
            isDismissible: true,
            enableDrag: true,
            useSafeArea: true,
            builder: (_) => _SheetPicker(
                k: k,
                hint: hint,
                value: value,
                items: items,
                onChanged: onChanged,
                cor: ac,
                searchable: true)),
        child: Container(
            height: 48,
            decoration: BoxDecoration(
                color: k.input,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: k.bord)),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(children: [
              Expanded(
                  child: Text(value ?? hint,
                      style: _ks(14, c: value != null ? k.ink : k.ink3),
                      overflow: TextOverflow.ellipsis)),
              Icon(Icons.keyboard_arrow_down_rounded, color: k.ink3, size: 22),
            ])),
      ),
    );
  }
}

class _SheetPicker extends StatefulWidget {
  const _SheetPicker(
      {required this.k,
      required this.hint,
      required this.value,
      required this.items,
      required this.onChanged,
      required this.searchable,
      required this.cor});
  final _K k;
  final String hint;
  final String? value;
  final List<String> items;
  final void Function(String?) onChanged;
  final bool searchable;
  final Color cor;
  @override
  State<_SheetPicker> createState() => _SheetPickerState();
}

class _SheetPickerState extends State<_SheetPicker> {
  List<String> _filt = [];
  final _sc = TextEditingController();
  @override
  void initState() {
    super.initState();
    _filt = widget.items;
  }

  @override
  void dispose() {
    _sc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final k = widget.k;
    return Container(
      decoration: BoxDecoration(
          color: k.card,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
          border: Border(top: BorderSide(color: k.bord))),
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: .55,
        maxChildSize: .92,
        shouldCloseOnMinExtent: true,
        builder: (_, ctrl) => Column(children: [
          Center(
              child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                      color: k.bord2, borderRadius: BorderRadius.circular(2)))),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Text(widget.hint, style: _ks(14, c: k.ink2, b: true))),
          if (widget.searchable)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
              child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                      color: k.input,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: k.bord)),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(children: [
                    Icon(Icons.search_rounded, color: k.ink3, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                        child: TextField(
                            controller: _sc,
                            style: _ks(13, c: k.ink),
                            cursorColor: widget.cor,
                            inputFormatters: [UpperCaseTextFormatter()],
                            textCapitalization: TextCapitalization.characters,
                            decoration: InputDecoration(
                                border: InputBorder.none,
                                isDense: true,
                                hintText: 'Pesquisar...',
                                hintStyle: _ks(13, c: k.ink3),
                                contentPadding: EdgeInsets.zero),
                            onChanged: (q) => setState(() {
                                  _filt = widget.items
                                      .where((i) => i
                                          .toLowerCase()
                                          .contains(q.toLowerCase()))
                                      .toList();
                                }))),
                  ])),
            ),
          Divider(height: 1, color: k.bord),
          Expanded(
              child: ListView.builder(
                  controller: ctrl,
                  itemCount: _filt.length,
                  itemBuilder: (_, i) {
                    final item = _filt[i];
                    final sel = item == widget.value;
                    return ListTile(
                        tileColor: sel
                            ? widget.cor.withOpacity(k.dark ? .1 : .06)
                            : null,
                        title: Text(item,
                            style:
                                _ks(14, c: sel ? widget.cor : k.ink, b: sel)),
                        trailing: sel
                            ? Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: widget.cor.withOpacity(.15),
                                    border: Border.all(
                                        color: widget.cor.withOpacity(.5))),
                                child: Icon(Icons.check_rounded,
                                    color: widget.cor, size: 13))
                            : null,
                        onTap: () {
                          widget.onChanged(item);
                          Navigator.pop(context);
                        });
                  })),
        ]),
      ),
    );
  }
}

class _TecPreview extends StatelessWidget {
  const _TecPreview({required this.nome, this.foto, required this.k});
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
    return Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
            color: k.surf,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: k.bord)),
        child: Row(children: [
          Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: url == null
                      ? const LinearGradient(
                          colors: [_kViolet, _kCyan],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight)
                      : null,
                  border:
                      Border.all(color: _kCyan.withOpacity(.35), width: 1.5)),
              child: ClipOval(
                  child: url != null
                      ? Image.network(url,
                          width: 34,
                          height: 34,
                          fit: BoxFit.cover,
                          webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
                          errorBuilder: (_, __, ___) => _Initials(ini: _ini))
                      : _Initials(ini: _ini))),
          const SizedBox(width: 10),
          Expanded(
              child: Text(nome,
                  style: _ks(13, c: k.ink, b: true),
                  overflow: TextOverflow.ellipsis)),
        ]),
      );
  }
}

class _Initials extends StatelessWidget {
  const _Initials({required this.ini});
  final String ini;
  @override
  Widget build(BuildContext context) => Container(
      decoration: const BoxDecoration(
          gradient: LinearGradient(
              colors: [_kViolet, _kCyan],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight)),
      child:
          Center(child: Text(ini, style: _ks(11, c: Colors.white, b: true))));
}

// ══════════════════════════════════════════════════════════════
//  COMPONENTES COMPARTILHADOS
// ══════════════════════════════════════════════════════════════
class _BarraLateral extends StatelessWidget {
  const _BarraLateral({required this.cor1, required this.cor2});
  final Color cor1, cor2;
  @override
  Widget build(BuildContext context) => Container(
      width: 3,
      height: 14,
      decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [cor1, cor2],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter),
          borderRadius: BorderRadius.circular(2)));
}

class _Badge extends StatelessWidget {
  const _Badge(this.label, this.cor);
  final String label;
  final Color cor;
  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
          color: cor.withOpacity(.12),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: cor.withOpacity(.3))),
      child: Text(label, style: _ks(9, c: cor, b: true)));
}

class _Banner extends StatelessWidget {
  const _Banner({required this.icon, required this.cor, required this.msg});
  final IconData icon;
  final Color cor;
  final String msg;
  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
          color: cor.withOpacity(.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: cor.withOpacity(.3))),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: cor, size: 15),
        const SizedBox(width: 8),
        Expanded(child: Text(msg, style: _ks(11, c: cor))),
      ]));
}

class _Header extends StatelessWidget {
  const _Header({required this.k, required this.onCadastrar});
  final _K k;
  final VoidCallback onCadastrar;
  @override
  Widget build(BuildContext context) =>
      Column(mainAxisSize: MainAxisSize.min, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 20, 14, 16),
          child: Row(children: [
            Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [_kRose, Color(0xFFFF6B6B)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                          color: _kRose.withOpacity(.35),
                          blurRadius: 10,
                          offset: const Offset(0, 3))
                    ]),
                child: const Icon(Icons.delete_forever_rounded,
                    color: Colors.white, size: 22)),
            const SizedBox(width: 12),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text('EXCLUIR / AUDITAR O.S',
                      style: _ks(16, c: k.ink, b: true)),
                  Text('Todos os registros das 3 coleções',
                      style: _ks(11, c: k.ink3)),
                ])),
            GestureDetector(
                onTap: onCadastrar,
                child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                        gradient: const LinearGradient(
                            colors: [_kEmerald, Color(0xFF047857)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight),
                        borderRadius: BorderRadius.circular(9),
                        boxShadow: [
                          BoxShadow(
                              color: _kEmerald.withOpacity(.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2))
                        ]),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.add_rounded,
                          color: Colors.white, size: 15),
                      const SizedBox(width: 4),
                      Text('Cadastrar',
                          style: _ks(11, c: Colors.white, b: true)),
                    ]))),
          ]),
        ),
        Container(
            height: 2,
            decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [_kRose, Color(0xFFFF6B6B)]))),
      ]);
}

class _SearchBar extends StatefulWidget {
  const _SearchBar(
      {required this.k,
      required this.ctrl,
      required this.loading,
      required this.onChanged,
      required this.onClear});
  final _K k;
  final TextEditingController ctrl;
  final bool loading;
  final void Function(String) onChanged;
  final VoidCallback onClear;
  @override
  State<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<_SearchBar> {
  bool _focus = false;
  @override
  Widget build(BuildContext context) {
    final k = widget.k;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Wrap(spacing: 6, children: [
        _Pill(Icons.tag_rounded, 'N° O.S', _kViolet),
        _Pill(Icons.person_rounded, 'Cliente', _kCyan),
        _Pill(Icons.engineering_rounded, 'Técnico', _kEmerald),
        _Pill(Icons.storage_rounded, '3 coleções', _kAmber),
      ]),
      const SizedBox(height: 8),
      Focus(
        onFocusChange: (v) => setState(() => _focus = v),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 54,
          decoration: BoxDecoration(
              color: _focus ? _kRose.withOpacity(k.dark ? .06 : .03) : k.input,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: _focus ? _kRose.withOpacity(.6) : k.bord,
                  width: _focus ? 1.5 : 1),
              boxShadow: _focus
                  ? [
                      BoxShadow(
                          color: _kRose.withOpacity(.1),
                          blurRadius: 12,
                          offset: const Offset(0, 3))
                    ]
                  : []),
          child: Row(children: [
            const SizedBox(width: 14),
            Icon(Icons.search_rounded,
                color: _focus ? _kRose : k.ink3, size: 22),
            const SizedBox(width: 10),
            Expanded(
                child: TextFormField(
                    controller: widget.ctrl,
                    style: _ks(15, c: k.ink),
                    onChanged: widget.onChanged,
                    inputFormatters: [UpperCaseTextFormatter()],
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        hintText: 'N° O.S, cliente ou técnico...',
                        hintStyle: _ks(13, c: k.ink3),
                        contentPadding: EdgeInsets.zero),
                    cursorColor: _kRose)),
            if (widget.loading)
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: _kRose, strokeWidth: 2.2)))
            else if (widget.ctrl.text.isNotEmpty)
              GestureDetector(
                  onTap: widget.onClear,
                  child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle, color: k.bord2),
                          child: Icon(Icons.close, color: k.ink2, size: 14)))),
          ]),
        ),
      ),
      const SizedBox(height: 5),
      Text('Busca em SERVICOSREALIZADOS · MANUTENCAO · CORRETIVAS',
          style: _ks(10, c: k.ink3)),
    ]);
  }
}

class _Pill extends StatelessWidget {
  const _Pill(this.icon, this.label, this.color);
  final IconData icon;
  final String label;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
          color: color.withOpacity(.1),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color.withOpacity(.3))),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 11, color: color),
        const SizedBox(width: 4),
        Text(label, style: _ks(10, c: color, b: true)),
      ]));
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.k, required this.onCadastrar});
  final _K k;
  final VoidCallback onCadastrar;
  @override
  Widget build(BuildContext context) => Center(
      child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 28),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                    color: k.card,
                    shape: BoxShape.circle,
                    border: Border.all(color: k.bord2)),
                child:
                    Icon(Icons.manage_search_rounded, color: k.ink3, size: 34)),
            const SizedBox(height: 14),
            Text('Nenhuma busca realizada', style: _ks(14, c: k.ink, b: true)),
            const SizedBox(height: 6),
            Text('Busca simultânea nas 3 coleções', style: _ks(12, c: k.ink3)),
            const SizedBox(height: 16),
            GestureDetector(
                onTap: onCadastrar,
                child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                        gradient: const LinearGradient(
                            colors: [_kEmerald, Color(0xFF047857)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                              color: _kEmerald.withOpacity(.3),
                              blurRadius: 10,
                              offset: const Offset(0, 3))
                        ]),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.add_circle_rounded,
                          color: Colors.white, size: 18),
                      const SizedBox(width: 8),
                      Text('CADASTRAR NOVA O.S',
                          style: _ks(13, c: Colors.white, b: true)),
                    ]))),
            const SizedBox(height: 12),
            Wrap(
                spacing: 6,
                runSpacing: 4,
                alignment: WrapAlignment.center,
                children: [
                  _Pill(Icons.build_circle_rounded, 'Serviços', _kRose),
                  _Pill(Icons.settings_rounded, 'Manutenção', _kAmber),
                  _Pill(Icons.handyman_rounded, 'Corretivas', _kViolet),
                ]),
          ])));
}

class _NotFound extends StatelessWidget {
  const _NotFound({required this.msg, required this.k});
  final String msg;
  final _K k;
  @override
  Widget build(BuildContext context) => Center(
      child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                    color: _kRose.withOpacity(.09),
                    shape: BoxShape.circle,
                    border: Border.all(color: _kRose.withOpacity(.3))),
                child: const Icon(Icons.search_off_rounded,
                    color: _kRose, size: 30)),
            const SizedBox(height: 12),
            Text('Nenhuma O.S encontrada', style: _ks(14, c: k.ink, b: true)),
            const SizedBox(height: 4),
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(msg,
                    style: _ks(12, c: k.ink3), textAlign: TextAlign.center)),
          ])));
}

class _Loading extends StatelessWidget {
  const _Loading({required this.k});
  final _K k;
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
        const CircularProgressIndicator(color: _kRose, strokeWidth: 2.5),
        const SizedBox(height: 14),
        Text('Buscando todos os registros...', style: _ks(13, c: k.ink3)),
        const SizedBox(height: 4),
        Text('SERVICOSREALIZADOS · MANUTENCAO · CORRETIVAS',
            style: _ks(10, c: k.ink3)),
      ])));
}

class _Footer extends StatelessWidget {
  const _Footer({required this.k, required this.onFechar});
  final _K k;
  final VoidCallback onFechar;
  @override
  Widget build(BuildContext context) => Container(
      padding: EdgeInsets.fromLTRB(
          16, 12, 16, 16 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
          color: k.bg, border: Border(top: BorderSide(color: k.bord))),
      child: GestureDetector(
          onTap: onFechar,
          child: Container(
              height: 48,
              width: double.infinity,
              decoration: BoxDecoration(
                  color: k.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: k.bord2)),
              child: Center(
                  child: Text('Fechar', style: _ks(14, c: k.ink2, b: true))))));
}
