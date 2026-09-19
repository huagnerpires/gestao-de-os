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

import 'dart:async';
import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:google_fonts/google_fonts.dart';

import 'os_abrir.dart';
import 'os_tempo.dart';

// ── Cores de Acento Modernas ────────────────────────────────────────────────
const _emerald = Color(0xFF047857);
const _cyan = Color(0xFF0F766E);
const _blue = Color(0xFF1D4ED8);
const _loginAccent = Color(0xFF1D4ED8);
const _rose = Color(0xFFB91C1C);
const _amber = Color(0xFFB45309);
const _violet = Color(0xFF3730A3);
const _orange = Color(0xFFC2410C);

// ── Tema Global — Clean Light / Modern Dark Slate (Login Match) ──────────────
class _Th {
  _Th(this.isDark);
  final bool isDark;
  bool get d => isDark;

  Color get bg => d ? const Color(0xFF0B0F17) : const Color(0xFFF1F5F9);
  Color get surf => d ? const Color(0xFF131B2E) : const Color(0xFFFFFFFF);
  Color get surf2 => d ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC);
  Color get surf3 => d ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9);
  Color get head => d ? const Color(0xFF131B2E) : const Color(0xFFF8FAFC);
  Color get border => d ? Colors.white.withOpacity(0.10) : const Color(0xFFE2E8F0);
  Color get border2 => d ? Colors.white.withOpacity(0.14) : const Color(0xFFCBD5E1);
  Color get shadow => d ? const Color(0x40000000) : const Color(0x0A000000);
  Color get ink => d ? Colors.white : const Color(0xFF0F172A);
  Color get ink2 => d ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
  Color get ink3 => d ? const Color(0xFF64748B) : const Color(0xFF94A3B8);
  Color get hink => d ? const Color(0xFFCBD5E1) : const Color(0xFF334155);
  Color get input => d ? const Color(0xFF0F172A) : const Color(0xFFFFFFFF);
  Color get filter => d ? const Color(0xFF0F172A) : const Color(0xFFFFFFFF);
  Color get row1 => d ? const Color(0xFF0D131F) : const Color(0xFFFFFFFF);
  Color get row2 => d ? const Color(0xFF111827) : const Color(0xFFF8FAFC);
  Color get card => d ? const Color(0xFF131B2E) : const Color(0xFFFFFFFF);
}

// ── Funções Auxiliares Globais ───────────────────────────────────────────────
String _v(dynamic v) => (v ?? '').toString();

bool _fotoValida(String? s) {
  final u = (s ?? '').trim();
  return u.startsWith('http://') || u.startsWith('https://')
      ? !u.contains('Erro:')
      : false;
}

Color _sColor(String s) {
  switch (s.trim().toUpperCase()) {
    case 'CONCLUÍDA':
      return _emerald;
    case 'CANCELADA':
      return _rose;
    case 'INICIOU O SERVIÇO':
      return _blue;
    case 'AGUARDANDO AVALIAÇÃO':
      return _orange;
    case 'AGUARDANDO PEÇA':
      return _amber;
    case 'INICIAR AVALIAÇÃO':
      return _violet;
    case 'PASSAR ORÇAMENTO':
      return _cyan;
    case 'AGUARDANDO APROVAÇÃO':
      return const Color(0xFFC2410C);
    case 'APROVADO':
      return const Color(0xFF047857);
    default:
      return const Color(0xFF64748B);
  }
}

IconData _sIcon(String s) {
  switch (s.trim().toUpperCase()) {
    case 'CONCLUÍDA':
      return Icons.check_circle_rounded;
    case 'CANCELADA':
      return Icons.cancel_rounded;
    case 'INICIOU O SERVIÇO':
      return Icons.play_circle_filled_rounded;
    case 'AGUARDANDO AVALIAÇÃO':
      return Icons.hourglass_empty_rounded;
    case 'AGUARDANDO PEÇA':
      return Icons.inventory_2_rounded;
    case 'INICIAR AVALIAÇÃO':
      return Icons.science_rounded;
    case 'PASSAR ORÇAMENTO':
      return Icons.request_quote_rounded;
    case 'AGUARDANDO APROVAÇÃO':
      return Icons.pending_actions_rounded;
    case 'APROVADO':
      return Icons.verified_rounded;
    default:
      return Icons.info_rounded;
  }
}

IconData _eqIcon(String eq) {
  final key = eq.toUpperCase().trim();
  if (key.contains('AR CONDICIONADO') || key.contains('AR COND')) {
    return Icons.ac_unit_rounded;
  }
  if (key.contains('LAVADORA') || key.contains('LAVA')) {
    return Icons.local_laundry_service_rounded;
  }
  if (key.contains('REFRIGERADOR') || key.contains('FREEZER')) {
    return Icons.kitchen_rounded;
  }
  if (key.contains('BEBEDOURO')) return Icons.water_drop_rounded;
  if (key.contains('MICRO')) return Icons.microwave_rounded;
  return Icons.devices_other_rounded;
}

// ═══════════════════════════════════════════════════════════════════════════════
//  WIDGET PRINCIPAL: TABELA DE O.S MODERNA
// ═══════════════════════════════════════════════════════════════════════════════
enum _C { nos, equip, tec, desc, status, inicio, termino, cliente, pontos }

const _kLabel = {
  _C.nos: 'NÚMERO DA O.S',
  _C.equip: 'EQUIPAMENTO',
  _C.tec: 'TÉCNICO',
  _C.desc: 'DESCRIÇÃO',
  _C.status: 'STATUS',
  _C.inicio: 'INÍCIO',
  _C.termino: 'TÉRMINO',
  _C.cliente: 'CLIENTE',
  _C.pontos: 'PONTOS',
};

double _cw(_C c) {
  switch (c) {
    case _C.nos:
      return 130;
    case _C.equip:
      return 160;
    case _C.tec:
      return 180;
    case _C.desc:
      return 210;
    case _C.status:
      return 175;
    case _C.inicio:
      return 115;
    case _C.termino:
      return 115;
    case _C.cliente:
      return 175;
    case _C.pontos:
      return 95;
  }
}

int _cf(_C c) {
  switch (c) {
    case _C.nos:
      return 13;
    case _C.equip:
      return 16;
    case _C.tec:
      return 18;
    case _C.desc:
      return 21;
    case _C.status:
      return 17;
    case _C.inicio:
      return 11;
    case _C.termino:
      return 11;
    case _C.cliente:
      return 17;
    case _C.pontos:
      return 10;
  }
}

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
  'DEZEMBRO'
];

const double _kTableMinWidth = 1355.0;
const int _kKanbanCap = 250;

const _kViewIcons = [
  Icons.table_chart_rounded,
  Icons.grid_view_rounded,
  Icons.view_agenda_rounded,
  Icons.view_kanban_rounded,
];
const _kViewLabels = ['Tabela', 'Cards', 'Compacta', 'Kanban'];

const _kStatusOrder = [
  'AGUARDANDO AVALIAÇÃO',
  'INICIAR AVALIAÇÃO',
  'PASSAR ORÇAMENTO',
  'AGUARDANDO APROVAÇÃO',
  'AGUARDANDO PEÇA',
  'CANCELADA',
  'APROVADO',
  'INICIOU O SERVIÇO',
  'CONCLUÍDA',
];

const _kStatusShort = {
  'AGUARDANDO AVALIAÇÃO': 'Pendentes',
  'INICIAR AVALIAÇÃO': 'Testes',
  'PASSAR ORÇAMENTO': 'Orçamento',
  'AGUARDANDO APROVAÇÃO': 'Ag. Aprovação',
  'AGUARDANDO PEÇA': 'Ag. Peça',
  'CANCELADA': 'Canceladas',
  'APROVADO': 'Aprovadas',
  'INICIOU O SERVIÇO': 'Em Andamento',
  'CONCLUÍDA': 'Concluídas',
};

String _statusColumnTitle(String status) {
  return _kStatusShort[status.trim().toUpperCase()] ?? status;
}

class OsTableWidget extends StatefulWidget {
  const OsTableWidget({super.key, this.width, this.height});
  final double? width;
  final double? height;

  @override
  State<OsTableWidget> createState() => _OsTableState();
}

class _OsTableState extends State<OsTableWidget> {
  final _db = FirebaseFirestore.instance;

  List<Map<String, dynamic>> _all = [];
  List<Map<String, dynamic>> _filt = [];
  List<String> _tecList = [];
  Map<String, String> _tecFotos = {};
  bool _loading = true;
  StreamSubscription? _sub;
  double? _avgDays;
  int _staleCount = 0;
  List<OsStaleItem> _stale = [];

  String? _filtMes;
  String? _filtAno;
  String? _filtTec;
  final _searchCtrl = TextEditingController();
  final _scrollController = ScrollController();
  String _query = '';
  _C _sortCol = _C.nos;
  bool _sortAsc = true;
  int _page = 0;
  int _perPage = 50;
  int _viewMode = 3;

  @override
  void initState() {
    super.initState();
    _subscribe();
  }

  @override
  void dispose() {
    _sub?.cancel();
    _searchCtrl.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _subscribe() {
    _sub?.cancel();
    if (mounted) setState(() => _loading = true);
    _loadTecFotos();

    Stream<QuerySnapshot> stream;
    try {
      stream = _db
          .collection('SERVICOSREALIZADOS')
          .orderBy('CADASTRO', descending: true)
          .snapshots();
    } catch (_) {
      stream = _db.collection('SERVICOSREALIZADOS').snapshots();
    }

    _sub = stream.listen((snap) {
      final list = snap.docs
          .map((d) => <String, dynamic>{
                ...d.data() as Map<String, dynamic>,
                '_id': d.id
              })
          .toList();
      final tecs = list
          .map((r) => (r['TECNICO'] ?? '').toString().trim())
          .where((t) => t.isNotEmpty)
          .toSet()
          .toList()
        ..sort();
      if (!mounted) return;
      final stats = computeOsTempo(list);
      final firstLoad = _loading;
      setState(() {
        _all = list;
        _tecList = tecs;
        _loading = false;
        _avgDays = stats.avgDays;
        _staleCount = stats.stale.length;
        _stale = stats.stale;
      });
      _applyFilters();
      if (firstLoad) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          maybeShowOsStaleDialog(context, stats.stale, onOpen: _openOs);
        });
      }
    });
  }

  void _refresh() => _subscribe();

  Future<void> _loadTecFotos() async {
    try {
      final snap = await _db.collection('PONTOS_POR_TECNICO').get();
      final map = <String, String>{};
      for (final d in snap.docs) {
        final data = d.data();
        final nome = (data['TECNICO'] ?? '').toString().trim();
        final foto = (data['FOTO'] ?? '').toString().trim();
        if (nome.isNotEmpty && _fotoValida(foto)) map[nome] = foto;
      }
      if (!mounted) return;
      setState(() => _tecFotos = map);
    } catch (_) {}
  }

  void _applyFilters() {
    var result = _all.toList();
    if (_filtMes != null && _filtMes!.isNotEmpty) {
      result = result
          .where((r) =>
              (r['MES'] ?? '').toString().toUpperCase() ==
              _filtMes!.toUpperCase())
          .toList();
    }
    if (_filtAno != null && _filtAno!.isNotEmpty) {
      result = result.where((r) {
        final ano = (r['ANO'] ?? r['CADASTRO'] ?? '').toString();
        return ano.contains(_filtAno!);
      }).toList();
    }
    if (_filtTec != null && _filtTec!.isNotEmpty) {
      result = result
          .where((r) => (r['TECNICO'] ?? '').toString().trim() == _filtTec)
          .toList();
    }
    if (_query.isNotEmpty) {
      result = result.where((r) {
        return _C.values
            .map((c) => _cv(r, c).toLowerCase())
            .any((v) => v.contains(_query));
      }).toList();
    }
    setState(() {
      _filt = result;
      _page = 0;
    });
    _applySort();
  }

  void _onSearch(String q) {
    _query = q.toLowerCase().trim();
    _applyFilters();
  }

  void _sort(_C col) {
    setState(() {
      _sortAsc = _sortCol == col ? !_sortAsc : true;
      _sortCol = col;
      _page = 0;
    });
    _applySort();
  }

  void _applySort() {
    _filt.sort((a, b) {
      final va = _cv(a, _sortCol).toLowerCase();
      final vb = _cv(b, _sortCol).toLowerCase();
      return _sortAsc ? va.compareTo(vb) : vb.compareTo(va);
    });
    if (mounted) setState(() {});
  }

  void _clearFilters() {
    setState(() {
      _filtMes = null;
      _filtAno = null;
      _filtTec = null;
      _query = '';
      _page = 0;
      _searchCtrl.clear();
    });
    _applyFilters();
  }

  String _cv(Map<String, dynamic> r, _C c) {
    switch (c) {
      case _C.nos:
        return (r['NUMERODAOS'] ?? '').toString();
      case _C.equip:
        return (r['EQUIPAMENTO'] ?? '').toString();
      case _C.tec:
        return (r['TECNICO'] ?? '').toString();
      case _C.desc:
        return (r['SERVICO'] ?? '').toString();
      case _C.status:
        return (r['STATUS'] ?? '').toString();
      case _C.inicio:
        return (r['INICIO'] ?? '').toString();
      case _C.termino:
        return (r['TERMINO'] ?? '').toString();
      case _C.cliente:
        return (r['CLIENTE'] ?? '').toString();
      case _C.pontos:
        return (r['PONTOS'] ?? '').toString();
    }
  }

  List<Map<String, dynamic>> get _pageData {
    final s = _page * _perPage;
    final e = (s + _perPage).clamp(0, _filt.length);
    if (s >= _filt.length) return [];
    return _filt.sublist(s, e);
  }

  int get _pages => _filt.isEmpty ? 1 : ((_filt.length - 1) ~/ _perPage) + 1;
  bool get _hasFilters =>
      _filtMes != null || _filtAno != null || _filtTec != null;

  List<String> get _anoList {
    final anos = _all
        .map((r) {
          final cad = (r['CADASTRO'] ?? '').toString();
          if (cad.length >= 4) {
            final parts = cad.split('/');
            if (parts.length >= 3) return parts.last.substring(0, 4);
            if (cad.length == 4) return cad;
          }
          return '';
        })
        .where((a) => a.isNotEmpty && a.length == 4)
        .toSet()
        .toList()
      ..sort();
    return anos.reversed.toList();
  }

  void _openOs(Map<String, dynamic> row) {
    openOsEditarSheet(context, row, _db, _refresh);
  }

  @override
  Widget build(BuildContext context) {
    final th = _Th(Theme.of(context).brightness == Brightness.dark);
    final double defaultHeight = MediaQuery.of(context).size.height * 0.85;

    if (_loading) {
      return Container(
        width: widget.width ?? double.infinity,
        height: widget.height ?? defaultHeight,
        color: th.bg,
        child: const Center(
          child: CircularProgressIndicator(color: _blue, strokeWidth: 2.5),
        ),
      );
    }

    return LayoutBuilder(builder: (context, constraints) {
      final bool isPhone = constraints.maxWidth < 700;
      final bool useFlexLayout = constraints.maxWidth >= _kTableMinWidth;

      return Container(
        width: widget.width ?? double.infinity,
        height: widget.height ?? defaultHeight,
        color: th.bg,
        child: Column(children: [
          _FilterBar(
            th: th,
            isPhone: isPhone,
            filtMes: _filtMes,
            filtAno: _filtAno,
            filtTec: _filtTec,
            tecList: _tecList,
            anoList: _anoList,
            hasFilters: _hasFilters,
            total: _filt.length,
            totalAll: _all.length,
            searchCtrl: _searchCtrl,
            onMes: (v) {
              setState(() => _filtMes = v);
              _applyFilters();
            },
            onAno: (v) {
              setState(() => _filtAno = v);
              _applyFilters();
            },
            onTec: (v) {
              setState(() => _filtTec = v);
              _applyFilters();
            },
            onSearch: _onSearch,
            onClear: _clearFilters,
            onRefresh: _refresh,
            viewMode: _viewMode,
            onViewMode: (v) => setState(() => _viewMode = v),
            avgDays: _avgDays,
            staleCount: _staleCount,
            onStaleTap: () => maybeShowOsStaleDialog(
              context,
              _stale,
              force: true,
              onOpen: _openOs,
            ),
          ),
          Expanded(
            child: _buildViewBody(th, isPhone, useFlexLayout),
          ),
          if (_viewMode != 3)
            _Pagination(
              th: th,
              isPhone: isPhone,
              page: _page,
              total: _pages,
              perPage: _perPage,
              count: _filt.length,
              onPrev: _page > 0 ? () => setState(() => _page--) : null,
              onNext: _page < _pages - 1 ? () => setState(() => _page++) : null,
              onPerPage: (v) => setState(() {
                _perPage = v;
                _page = 0;
              }),
            ),
        ]),
      );
    });
  }

  List<Map<String, dynamic>> get _kanbanData {
    if (_filt.length <= _kKanbanCap) return _filt;
    return _filt.sublist(0, _kKanbanCap);
  }

  Widget _buildViewBody(_Th th, bool isPhone, bool useFlexLayout) {
    final empty = _EmptyState(
      th: th,
      hasFilters: _hasFilters,
      onClear: _clearFilters,
    );

    switch (_viewMode) {
      case 1:
        if (_pageData.isEmpty) return empty;
        return _CardsGrid(
          rows: _pageData,
          th: th,
          tecFotos: _tecFotos,
          onOpen: _openOs,
        );
      case 2:
        if (_pageData.isEmpty) return empty;
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          itemCount: _pageData.length,
          separatorBuilder: (_, __) => const SizedBox(height: 6),
          itemBuilder: (_, i) => _CompactRow(
            row: _pageData[i],
            th: th,
            fotoUrl: _tecFotos[_v(_pageData[i]['TECNICO']).trim()],
            onTap: () => _openOs(_pageData[i]),
          ),
        );
      case 3:
        if (_kanbanData.isEmpty) return empty;
        return _KanbanView(
          rows: _kanbanData,
          th: th,
          tecFotos: _tecFotos,
          onOpen: _openOs,
        );
      default:
        return Container(
          margin: EdgeInsets.fromLTRB(isPhone ? 12 : 16, 6, isPhone ? 12 : 16, 0),
          decoration: BoxDecoration(
            color: th.head,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            border: Border.all(
              color: th.d ? Colors.white.withOpacity(0.10) : th.border,
            ),
            boxShadow: [
              BoxShadow(
                color: th.shadow,
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          clipBehavior: Clip.hardEdge,
          child: useFlexLayout
              ? _buildDesktopTable(th, true)
              : _buildScrollableTable(th),
        );
    }
  }

  Widget _buildDesktopTable(_Th th, bool useFlex) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _HeadRow(
            th: th,
            sortCol: _sortCol,
            sortAsc: _sortAsc,
            onSort: _sort,
            useFlex: useFlex),
        Expanded(
          child: _pageData.isEmpty
              ? _EmptyState(
                  th: th, hasFilters: _hasFilters, onClear: _clearFilters)
              : ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: _pageData.length,
                  itemBuilder: (_, i) => _DataRow(
                    row: _pageData[i],
                    idx: i,
                    th: th,
                    cv: _cv,
                    useFlex: useFlex,
                    tecFotos: _tecFotos,
                    onTap: () => _openOs(_pageData[i]),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildScrollableTable(_Th th) {
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(
        dragDevices: {
          PointerDeviceKind.touch,
          PointerDeviceKind.mouse,
          PointerDeviceKind.trackpad
        },
      ),
      child: Scrollbar(
        controller: _scrollController,
        thumbVisibility: true,
        trackVisibility: true,
        thickness: 6,
        radius: const Radius.circular(10),
        child: SingleChildScrollView(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          child: SizedBox(
              width: _kTableMinWidth, child: _buildDesktopTable(th, false)),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// COMPONENTES DE FILTRO E BARRA DE FERRAMENTAS
// ─────────────────────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState(
      {required this.th, required this.hasFilters, required this.onClear});
  final _Th th;
  final bool hasFilters;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off_rounded, size: 48, color: th.ink3),
          const SizedBox(height: 12),
          Text(
            'Nenhuma ordem de serviço encontrada',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: th.ink2,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (hasFilters) ...[
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: onClear,
              icon: const Icon(Icons.filter_alt_off_rounded, size: 16),
              label: const Text('Limpar Filtros'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MobileCard extends StatelessWidget {
  const _MobileCard({
    required this.row,
    required this.th,
    required this.onTap,
    this.fotoUrl,
  });
  final Map<String, dynamic> row;
  final _Th th;
  final VoidCallback onTap;
  final String? fotoUrl;

  @override
  Widget build(BuildContext context) {
    final status = _v(row['STATUS']).trim();
    final osNum = _v(row['NUMERODAOS']);
    final equip = _v(row['EQUIPAMENTO']);
    final tec = _v(row['TECNICO']);
    final inicio = _v(row['INICIO']);
    final cliente = _v(row['CLIENTE']);
    final corStatus = _sColor(status);
    final pts = (row['PONTOS'] is num) ? (row['PONTOS'] as num).toDouble() : 0.0;
    final String? foto = _fotoValida(fotoUrl) ? fotoUrl! : null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: th.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: th.border),
            boxShadow: [
              BoxShadow(
                color: th.shadow,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _blue.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _blue.withOpacity(0.3)),
                    ),
                    child: Text(
                      '#$osNum',
                      style: GoogleFonts.interTight(
                        fontSize: 13,
                        color: const Color(0xFF1D4ED8),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: corStatus.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: corStatus.withOpacity(0.35)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: corStatus,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          status.isEmpty ? 'AGUARDANDO' : status,
                          style: GoogleFonts.inter(
                            fontSize: 10.5,
                            color: corStatus,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(_eqIcon(equip), size: 16, color: _cyan),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      equip.isEmpty ? 'Equipamento não informado' : equip,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: th.ink,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  SizedBox(
                    width: 22,
                    height: 22,
                    child: foto != null
                        ? ClipOval(
                            child: Image.network(
                              foto,
                              width: 22,
                              height: 22,
                              fit: BoxFit.cover,
                              webHtmlElementStrategy:
                                  WebHtmlElementStrategy.prefer,
                              errorBuilder: (_, __, ___) => Icon(
                                Icons.person_outline_rounded,
                                size: 14,
                                color: th.ink3,
                              ),
                            ),
                          )
                        : Icon(Icons.person_outline_rounded,
                            size: 14, color: th.ink3),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      tec.isEmpty ? 'Técnico não atribuído' : tec,
                      style: GoogleFonts.inter(fontSize: 12.5, color: th.ink2),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Divider(color: th.border, height: 1),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(Icons.business_rounded, size: 13, color: th.ink3),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            cliente.isEmpty ? '—' : cliente,
                            style: GoogleFonts.inter(
                                fontSize: 11.5, color: th.ink2),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (inicio.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.calendar_today_rounded,
                            size: 12, color: th.ink3),
                        const SizedBox(width: 4),
                        Text(
                          'Início: $inicio',
                          style: GoogleFonts.inter(
                              fontSize: 11, color: th.ink3),
                        ),
                      ],
                    ),
                  ],
                  if (pts > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _amber.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '⭐ ${pts.toStringAsFixed(1)} pts',
                        style: GoogleFonts.inter(
                          color: _amber,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardsGrid extends StatelessWidget {
  const _CardsGrid({
    required this.rows,
    required this.th,
    required this.tecFotos,
    required this.onOpen,
  });

  final List<Map<String, dynamic>> rows;
  final _Th th;
  final Map<String, String> tecFotos;
  final void Function(Map<String, dynamic>) onOpen;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final w = c.maxWidth;
      final cols = w >= 1200 ? 3 : w >= 700 ? 2 : 1;
      return GridView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: cols,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          mainAxisExtent: cols == 1 ? 188 : 200,
        ),
        itemCount: rows.length,
        itemBuilder: (_, i) {
          final row = rows[i];
          return _MobileCard(
            row: row,
            th: th,
            fotoUrl: tecFotos[_v(row['TECNICO']).trim()],
            onTap: () => onOpen(row),
          );
        },
      );
    });
  }
}

class _CompactRow extends StatelessWidget {
  const _CompactRow({
    required this.row,
    required this.th,
    required this.onTap,
    this.fotoUrl,
  });

  final Map<String, dynamic> row;
  final _Th th;
  final VoidCallback onTap;
  final String? fotoUrl;

  @override
  Widget build(BuildContext context) {
    final status = _v(row['STATUS']).trim();
    final osNum = _v(row['NUMERODAOS']);
    final cliente = _v(row['CLIENTE']);
    final tec = _v(row['TECNICO']).trim();
    final cor = _sColor(status);
    final String? foto = _fotoValida(fotoUrl) ? fotoUrl : null;
    final initial = tec.isNotEmpty ? tec[0].toUpperCase() : '?';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: th.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: th.border),
          ),
          child: Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _blue.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _blue.withOpacity(0.28)),
                ),
                child: Text(
                  '#$osNum',
                  style: GoogleFonts.interTight(
                    fontSize: 12.5,
                    color: const Color(0xFF1D4ED8),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  cliente.isEmpty ? '—' : cliente,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: th.ink,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: cor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: cor.withOpacity(0.35)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration:
                          BoxDecoration(shape: BoxShape.circle, color: cor),
                    ),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        status.isEmpty ? 'AGUARDANDO' : status,
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          color: cor,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              ),
              const SizedBox(width: 8),
              Tooltip(
                message: tec.isEmpty ? 'Técnico não atribuído' : tec,
                child: SizedBox(
                  width: 28,
                  height: 28,
                  child: ClipOval(
                    child: foto != null
                        ? Image.network(
                            foto,
                            width: 28,
                            height: 28,
                            fit: BoxFit.cover,
                            webHtmlElementStrategy:
                                WebHtmlElementStrategy.prefer,
                            errorBuilder: (_, __, ___) => ColoredBox(
                              color: _blue.withOpacity(0.2),
                              child: Center(
                                child: Text(
                                  initial,
                                  style: GoogleFonts.inter(
                                    color: const Color(0xFF64748B),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          )
                        : ColoredBox(
                            color: _blue.withOpacity(0.2),
                            child: Center(
                              child: Text(
                                initial,
                                style: GoogleFonts.inter(
                                  color: const Color(0xFF64748B),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _KanbanView extends StatelessWidget {
  const _KanbanView({
    required this.rows,
    required this.th,
    required this.tecFotos,
    required this.onOpen,
  });

  final List<Map<String, dynamic>> rows;
  final _Th th;
  final Map<String, String> tecFotos;
  final void Function(Map<String, dynamic>) onOpen;

  Map<String, List<Map<String, dynamic>>> _group() {
    final map = <String, List<Map<String, dynamic>>>{};
    for (final r in rows) {
      var s = _v(r['STATUS']).trim();
      if (s.isEmpty) s = 'SEM STATUS';
      map.putIfAbsent(s, () => []).add(r);
    }
    return map;
  }

  List<String> _orderedKeys(Map<String, List<Map<String, dynamic>>> map) {
    final remaining = map.keys.toList();
    final out = <String>[];
    for (final wanted in _kStatusOrder) {
      String? match;
      for (final k in remaining) {
        if (k.toUpperCase() == wanted) {
          match = k;
          break;
        }
      }
      if (match != null) {
        out.add(match);
        remaining.remove(match);
      }
    }
    remaining.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    out.addAll(remaining);
    return out;
  }

  Widget _column(
    Map<String, List<Map<String, dynamic>>> grouped,
    List<String> keys,
    int i,
    double width,
  ) {
    final status = keys[i];
    final items = grouped[status]!;
    final cor = _sColor(status == 'SEM STATUS' ? '' : status);
    return _KanbanColumn(
      th: th,
      status: status,
      color: cor,
      items: items,
      tecFotos: tecFotos,
      onOpen: onOpen,
      width: width,
    );
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _group();
    final keys = _orderedKeys(grouped);

    return LayoutBuilder(
      builder: (context, constraints) {
        if (keys.isEmpty) {
          return const SizedBox.shrink();
        }

        final maxWidth = constraints.maxWidth;
        final usable = math.max(0.0, maxWidth - 32);
        const gap = 12.0;
        final n = math.max(keys.length, 1);

        final int colsForBreakpoint;
        if (maxWidth < 700) {
          colsForBreakpoint = 1;
        } else if (maxWidth < 1100) {
          colsForBreakpoint = 2;
        } else if (maxWidth < 1400) {
          colsForBreakpoint = 3;
        } else if (maxWidth < 1800) {
          colsForBreakpoint = 4;
        } else {
          colsForBreakpoint = math.min(n, 6);
        }

        final visible = math.min(n, colsForBreakpoint);
        var colWidth =
            (usable - gap * (visible - 1)) / math.max(visible, 1);
        colWidth = colWidth.clamp(200.0, 420.0);

        final isPhone = maxWidth < 700;
        if (isPhone && keys.length > 1) {
          // Almost full width, with a slight peek of the next column.
          colWidth = (usable - 12).clamp(200.0, 420.0);
        }

        final fitsWithoutScroll =
            n * (colWidth + gap) - gap <= usable + 1;

        Widget board;
        if (fitsWithoutScroll) {
          final fillWidth = (usable - gap * (n - 1)) / n;
          board = Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < keys.length; i++) ...[
                  if (i > 0) const SizedBox(width: gap),
                  Expanded(
                    child: _column(grouped, keys, i, fillWidth),
                  ),
                ],
              ],
            ),
          );
        } else {
          board = ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: isPhone
                ? const BouncingScrollPhysics(
                    parent: PageScrollPhysics(),
                  )
                : const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            itemCount: keys.length,
            separatorBuilder: (_, __) => const SizedBox(width: gap),
            itemBuilder: (_, i) => _column(grouped, keys, i, colWidth),
          );
        }

        return ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(
            dragDevices: {
              PointerDeviceKind.touch,
              PointerDeviceKind.mouse,
              PointerDeviceKind.trackpad,
            },
          ),
          child: board,
        );
      },
    );
  }
}

class _KanbanColumn extends StatelessWidget {
  const _KanbanColumn({
    required this.th,
    required this.status,
    required this.color,
    required this.items,
    required this.tecFotos,
    required this.onOpen,
    required this.width,
  });

  final _Th th;
  final String status;
  final Color color;
  final List<Map<String, dynamic>> items;
  final Map<String, String> tecFotos;
  final void Function(Map<String, dynamic>) onOpen;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Container(
        decoration: BoxDecoration(
          color: th.surf,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: th.border),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.10),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
                border: Border(
                  bottom: BorderSide(color: color.withOpacity(0.28)),
                ),
              ),
              child: Row(
                children: [
                  Icon(_sIcon(status == 'SEM STATUS' ? '' : status),
                      size: 16, color: color),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _statusColumnTitle(status),
                      style: GoogleFonts.interTight(
                        fontSize: 12.5,
                        color: color,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.16),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${items.length}',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: color,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) {
                  final row = items[i];
                  return _KanbanCard(
                    row: row,
                    th: th,
                    accent: color,
                    fotoUrl: tecFotos[_v(row['TECNICO']).trim()],
                    onTap: () => onOpen(row),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _KanbanCard extends StatelessWidget {
  const _KanbanCard({
    required this.row,
    required this.th,
    required this.accent,
    required this.onTap,
    this.fotoUrl,
  });

  final Map<String, dynamic> row;
  final _Th th;
  final Color accent;
  final VoidCallback onTap;
  final String? fotoUrl;

  @override
  Widget build(BuildContext context) {
    final osNum = _v(row['NUMERODAOS']);
    final cliente = _v(row['CLIENTE']);
    final equip = _v(row['EQUIPAMENTO']);
    final tec = _v(row['TECNICO']).trim();
    final String? foto = _fotoValida(fotoUrl) ? fotoUrl : null;
    final initial = tec.isNotEmpty ? tec[0].toUpperCase() : '?';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: th.surf2,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: th.border),
            boxShadow: [
              BoxShadow(
                color: th.shadow,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 3,
                    height: 16,
                    decoration: BoxDecoration(
                      color: accent,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '#$osNum',
                    style: GoogleFonts.interTight(
                      fontSize: 13,
                      color: const Color(0xFF1D4ED8),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: 22,
                    height: 22,
                    child: ClipOval(
                      child: foto != null
                          ? Image.network(
                              foto,
                              width: 22,
                              height: 22,
                              fit: BoxFit.cover,
                              webHtmlElementStrategy:
                                  WebHtmlElementStrategy.prefer,
                              errorBuilder: (_, __, ___) => ColoredBox(
                                color: _blue.withOpacity(0.2),
                                child: Center(
                                  child: Text(
                                    initial,
                                    style: GoogleFonts.inter(
                                      color: const Color(0xFF64748B),
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : ColoredBox(
                              color: _blue.withOpacity(0.2),
                              child: Center(
                                child: Text(
                                  initial,
                                  style: GoogleFonts.inter(
                                    color: const Color(0xFF64748B),
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                cliente.isEmpty ? '—' : cliente,
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  color: th.ink,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (equip.isNotEmpty) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(_eqIcon(equip), size: 12, color: _cyan),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        equip,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: th.ink2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({
    required this.th,
    required this.isPhone,
    required this.filtMes,
    required this.filtAno,
    required this.filtTec,
    required this.tecList,
    required this.anoList,
    required this.hasFilters,
    required this.total,
    required this.totalAll,
    required this.searchCtrl,
    required this.onMes,
    required this.onAno,
    required this.onTec,
    required this.onSearch,
    required this.onClear,
    required this.onRefresh,
    required this.viewMode,
    required this.onViewMode,
    this.avgDays,
    this.staleCount = 0,
    this.onStaleTap,
  });

  final _Th th;
  final bool isPhone;
  final String? filtMes, filtAno, filtTec;
  final List<String> tecList, anoList;
  final bool hasFilters;
  final int total, totalAll;
  final TextEditingController searchCtrl;
  final void Function(String?) onMes, onAno, onTec;
  final void Function(String) onSearch;
  final VoidCallback onClear, onRefresh;
  final int viewMode;
  final ValueChanged<int> onViewMode;
  final double? avgDays;
  final int staleCount;
  final VoidCallback? onStaleTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isPhone) ...[
            Row(
              children: [
                Expanded(
                  child: _SearchBox(
                    th: th,
                    ctrl: searchCtrl,
                    onSearch: onSearch,
                    isExpanded: true,
                  ),
                ),
                const SizedBox(width: 8),
                _ViewModeToggle(
                  th: th,
                  viewMode: viewMode,
                  onChanged: onViewMode,
                  compact: true,
                ),
                const SizedBox(width: 8),
                _RefreshBtn(th: th, onRefresh: onRefresh),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _FilterDrop(
                    th: th,
                    hint: 'MÊS',
                    icon: Icons.calendar_month_rounded,
                    value: filtMes,
                    items: _kMeses,
                    color: _cyan,
                    onChanged: onMes,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _FilterDrop(
                    th: th,
                    hint: 'ANO',
                    icon: Icons.date_range_rounded,
                    value: filtAno,
                    items: anoList,
                    color: _violet,
                    onChanged: onAno,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _FilterDrop(
                    th: th,
                    hint: 'TÉCNICO',
                    icon: Icons.engineering_rounded,
                    value: filtTec,
                    items: tecList,
                    color: _emerald,
                    onChanged: onTec,
                  ),
                ),
                if (hasFilters) ...[
                  const SizedBox(width: 8),
                  _ClearBtn(onClear: onClear),
                ],
              ],
            ),
          ] else ...[
            Row(
              children: [
                Expanded(
                  child: _FilterDrop(
                    th: th,
                    hint: 'MÊS',
                    icon: Icons.calendar_month_rounded,
                    value: filtMes,
                    items: _kMeses,
                    color: _cyan,
                    onChanged: onMes,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _FilterDrop(
                    th: th,
                    hint: 'ANO',
                    icon: Icons.date_range_rounded,
                    value: filtAno,
                    items: anoList,
                    color: _violet,
                    onChanged: onAno,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: _FilterDrop(
                    th: th,
                    hint: 'TÉCNICO',
                    icon: Icons.engineering_rounded,
                    value: filtTec,
                    items: tecList,
                    color: _emerald,
                    onChanged: onTec,
                  ),
                ),
                const SizedBox(width: 8),
                _SearchBox(
                  th: th,
                  ctrl: searchCtrl,
                  onSearch: onSearch,
                  isExpanded: false,
                ),
                const SizedBox(width: 8),
                _RefreshBtn(th: th, onRefresh: onRefresh),
                const SizedBox(width: 8),
                _ViewModeToggle(
                  th: th,
                  viewMode: viewMode,
                  onChanged: onViewMode,
                  compact: false,
                ),
                if (hasFilters) ...[
                  const SizedBox(width: 8),
                  _ClearBtn(onClear: onClear),
                ],
              ],
            ),
          ],
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _OsStatChip(
                label: 'Média: ${formatOsAvgDays(avgDays)}',
                color: _loginAccent,
              ),
              if (staleCount > 0)
                _OsStatChip(
                  label: '$staleCount O.S. +5 dias',
                  color: _rose,
                  onTap: onStaleTap,
                ),
              if (hasFilters && filtMes != null)
                _ActiveChip(
                  label: 'Mês: $filtMes',
                  color: _cyan,
                  onRemove: () => onMes(null),
                ),
              if (hasFilters && filtAno != null)
                _ActiveChip(
                  label: 'Ano: $filtAno',
                  color: _violet,
                  onRemove: () => onAno(null),
                ),
              if (hasFilters && filtTec != null)
                _ActiveChip(
                  label: 'Técnico: ${filtTec!.split(' ').first}',
                  color: _emerald,
                  onRemove: () => onTec(null),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ViewModeToggle extends StatelessWidget {
  const _ViewModeToggle({
    required this.th,
    required this.viewMode,
    required this.onChanged,
    required this.compact,
  });

  final _Th th;
  final int viewMode;
  final ValueChanged<int> onChanged;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final kanbanOn = viewMode == 3;
    final secondaryOn = viewMode < 3;
    final chipH = compact ? 40.0 : 44.0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Tooltip(
          message: 'Kanban',
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () => onChanged(3),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                height: chipH,
                padding: EdgeInsets.symmetric(horizontal: compact ? 10 : 12),
                decoration: BoxDecoration(
                  color: kanbanOn
                      ? _loginAccent
                      : _loginAccent.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: kanbanOn
                        ? _loginAccent
                        : _loginAccent.withOpacity(0.40),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.view_kanban_rounded,
                      size: 18,
                      color: kanbanOn ? Colors.white : _loginAccent,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Kanban',
                      style: GoogleFonts.inter(
                        fontSize: compact ? 12 : 13,
                        fontWeight: FontWeight.w700,
                        color: kanbanOn ? Colors.white : _loginAccent,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 6),
        PopupMenuButton<int>(
          tooltip: 'Mais vistas',
          offset: const Offset(0, 48),
          color: th.surf,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: th.border),
          ),
          onSelected: onChanged,
          itemBuilder: (_) => [
            for (var i = 0; i < 3; i++)
              PopupMenuItem<int>(
                value: i,
                child: Row(
                  children: [
                    Icon(
                      _kViewIcons[i],
                      size: 18,
                      color: viewMode == i ? _loginAccent : th.ink2,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _kViewLabels[i],
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: viewMode == i ? _loginAccent : th.ink,
                        fontWeight:
                            viewMode == i ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
          ],
          child: Container(
            width: chipH,
            height: chipH,
            decoration: BoxDecoration(
              color: secondaryOn
                  ? _loginAccent.withOpacity(0.10)
                  : th.input,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: secondaryOn
                    ? _loginAccent.withOpacity(0.40)
                    : th.border,
              ),
            ),
            child: Icon(
              secondaryOn ? _kViewIcons[viewMode] : Icons.more_horiz_rounded,
              color: secondaryOn ? _loginAccent : th.ink2,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }
}

class _ClearBtn extends StatelessWidget {
  const _ClearBtn({required this.onClear});
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onClear,
        child: Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: _rose.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _rose.withOpacity(0.35)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.filter_alt_off_rounded, color: _rose, size: 16),
              const SizedBox(width: 6),
              Text(
                'Limpar',
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  color: _rose,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RefreshBtn extends StatefulWidget {
  const _RefreshBtn({required this.th, required this.onRefresh});
  final _Th th;
  final VoidCallback onRefresh;

  @override
  State<_RefreshBtn> createState() => _RefreshBtnState();
}

class _RefreshBtnState extends State<_RefreshBtn>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _tap() {
    _ctrl.forward(from: 0);
    widget.onRefresh();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: _tap,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: _blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _blue.withOpacity(0.3)),
          ),
          child: AnimatedBuilder(
            animation: _ctrl,
            builder: (_, child) => Transform.rotate(
              angle: _ctrl.value * 6.28318,
              child: child,
            ),
            child: const Icon(
              Icons.refresh_rounded,
              color: Color(0xFF1D4ED8),
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}

class _SearchBox extends StatelessWidget {
  const _SearchBox({
    required this.th,
    required this.ctrl,
    required this.onSearch,
    required this.isExpanded,
  });

  final _Th th;
  final TextEditingController ctrl;
  final void Function(String) onSearch;
  final bool isExpanded;

  @override
  Widget build(BuildContext context) => Container(
        width: isExpanded ? null : 220,
        height: 44,
        decoration: BoxDecoration(
          color: th.input,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: th.border),
        ),
        child: Row(
          children: [
            const SizedBox(width: 12),
            Icon(Icons.search_rounded, color: _cyan, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: ctrl,
                style: GoogleFonts.inter(color: th.ink, fontSize: 13),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  hintText: 'Pesquisar ordens...',
                  hintStyle:
                      GoogleFonts.inter(color: th.ink3, fontSize: 13),
                ),
                onChanged: onSearch,
              ),
            ),
            if (ctrl.text.isNotEmpty)
              GestureDetector(
                onTap: () {
                  ctrl.clear();
                  onSearch('');
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Icon(Icons.close_rounded, color: th.ink3, size: 16),
                ),
              ),
          ],
        ),
      );
}

class _FilterDrop extends StatelessWidget {
  const _FilterDrop({
    required this.th,
    required this.hint,
    required this.icon,
    required this.value,
    required this.items,
    required this.color,
    required this.onChanged,
  });

  final _Th th;
  final String hint;
  final IconData icon;
  final String? value;
  final List<String> items;
  final Color color;
  final void Function(String?) onChanged;

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => _openSheet(context),
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              color: value != null
                  ? color.withOpacity(0.12)
                  : th.filter,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: value != null ? color.withOpacity(0.4) : th.border,
                width: value != null ? 1.5 : 1,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                Icon(icon, size: 16, color: value != null ? color : th.ink3),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    value ?? hint,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: value != null ? color : th.ink3,
                      fontWeight: value != null ? FontWeight.w700 : FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 18,
                  color: value != null ? color : th.ink3,
                ),
              ],
            ),
          ),
        ),
      );

  void _openSheet(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width >= 700;

    if (isDesktop) {
      showDialog(
        context: context,
        barrierColor: Colors.black.withOpacity(0.55),
        builder: (dlgCtx) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420, maxHeight: 520),
            child: Container(
              decoration: BoxDecoration(
                color: th.card,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: color.withOpacity(0.4),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 16, 12),
                    child: Row(
                      children: [
                        Icon(icon, color: color, size: 20),
                        const SizedBox(width: 10),
                        Text(
                          hint,
                          style: GoogleFonts.interTight(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: th.ink,
                          ),
                        ),
                        const Spacer(),
                        if (value != null)
                          TextButton(
                            onPressed: () {
                              Navigator.pop(dlgCtx);
                              onChanged(null);
                            },
                            child: Text(
                              'Limpar',
                              style: GoogleFonts.inter(
                                color: color,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, size: 20),
                          color: th.ink3,
                          onPressed: () => Navigator.pop(dlgCtx),
                        ),
                      ],
                    ),
                  ),
                  Divider(color: th.border, height: 1),
                  Flexible(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      itemCount: items.length,
                      itemBuilder: (_, i) {
                        final item = items[i];
                        final sel = item == value;
                        return ListTile(
                          tileColor: sel ? color.withOpacity(0.1) : null,
                          leading: Icon(
                            icon,
                            color: sel ? color : th.ink3,
                            size: 18,
                          ),
                          title: Text(
                            item,
                            style: GoogleFonts.inter(
                              fontSize: 13.5,
                              color: sel ? color : th.ink,
                              fontWeight:
                                  sel ? FontWeight.w700 : FontWeight.w500,
                            ),
                          ),
                          trailing: sel
                              ? Icon(Icons.check_rounded, color: color, size: 20)
                              : null,
                          onTap: () {
                            Navigator.pop(dlgCtx);
                            onChanged(item);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    } else {
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (_) => Container(
          decoration: BoxDecoration(
            color: th.card,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            border: Border(
              top: BorderSide(color: color.withOpacity(0.5), width: 2),
            ),
          ),
          child: DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.5,
            maxChildSize: 0.85,
            builder: (_, ctrl) => Column(
              children: [
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 10, bottom: 8),
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                  child: Row(
                    children: [
                      Icon(icon, color: color, size: 20),
                      const SizedBox(width: 10),
                      Text(
                        hint,
                        style: GoogleFonts.interTight(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: th.ink,
                        ),
                      ),
                      const Spacer(),
                      if (value != null)
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            onChanged(null);
                          },
                          child: Text(
                            'Limpar',
                            style: GoogleFonts.inter(
                              color: color,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Divider(color: th.border, height: 1),
                Expanded(
                  child: ListView.builder(
                    controller: ctrl,
                    itemCount: items.length,
                    itemBuilder: (_, i) {
                      final item = items[i];
                      final sel = item == value;
                      return ListTile(
                        tileColor: sel ? color.withOpacity(0.1) : null,
                        leading: Icon(
                          icon,
                          color: sel ? color : th.ink3,
                          size: 18,
                        ),
                        title: Text(
                          item,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: sel ? color : th.ink,
                            fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                        trailing: sel
                            ? Icon(Icons.check_rounded, color: color, size: 20)
                            : null,
                        onTap: () {
                          Navigator.pop(context);
                          onChanged(item);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
}

class _OsStatChip extends StatelessWidget {
  const _OsStatChip({
    required this.label,
    required this.color,
    this.onTap,
  });

  final String label;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final child = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.16),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.40)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.14),
            blurRadius: 10,
          ),
        ],
      ),
      child: Text(
        label,
        style: GoogleFonts.interTight(
          fontSize: 11.5,
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
    if (onTap == null) return child;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: child,
      ),
    );
  }
}

class _ActiveChip extends StatelessWidget {
  const _ActiveChip({
    required this.label,
    required this.color,
    required this.onRemove,
  });

  final String label;
  final Color color;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11.5,
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: onRemove,
              child: Icon(Icons.close_rounded, size: 14, color: color),
            ),
          ],
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// COMPONENTES DA TABELA DESKTOP
// ─────────────────────────────────────────────────────────────────────────────
class _HeadRow extends StatelessWidget {
  const _HeadRow({
    required this.th,
    required this.sortCol,
    required this.sortAsc,
    required this.onSort,
    required this.useFlex,
  });

  final _Th th;
  final _C sortCol;
  final bool sortAsc;
  final void Function(_C) onSort;
  final bool useFlex;

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: th.head,
          border: Border(
            bottom: BorderSide(color: th.border, width: 1.5),
          ),
        ),
        child: Row(children: [for (final col in _C.values) _headCell(col)]),
      );

  Widget _headCell(_C col) {
    final inner = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onSort(col),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  _kLabel[col] ?? '',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: sortCol == col ? _cyan : th.hink,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                sortCol == col
                    ? (sortAsc
                        ? Icons.arrow_upward_rounded
                        : Icons.arrow_downward_rounded)
                    : Icons.unfold_more_rounded,
                size: 13,
                color: sortCol == col ? _cyan : th.hink.withOpacity(0.4),
              ),
            ],
          ),
        ),
      ),
    );
    return useFlex
        ? Expanded(flex: _cf(col), child: inner)
        : SizedBox(width: _cw(col), child: inner);
  }
}

class _DataRow extends StatefulWidget {
  const _DataRow({
    required this.row,
    required this.idx,
    required this.th,
    required this.cv,
    required this.useFlex,
    required this.onTap,
    required this.tecFotos,
  });

  final Map<String, dynamic> row;
  final int idx;
  final _Th th;
  final String Function(Map<String, dynamic>, _C) cv;
  final bool useFlex;
  final VoidCallback onTap;
  final Map<String, String> tecFotos;

  @override
  State<_DataRow> createState() => _DataRowState();
}

class _DataRowState extends State<_DataRow> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) => MouseRegion(
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            decoration: BoxDecoration(
              color: _hover
                  ? _blue.withOpacity(widget.th.d ? 0.12 : 0.06)
                  : (widget.idx.isEven ? widget.th.row1 : widget.th.row2),
              border: Border(
                bottom: BorderSide(color: widget.th.border.withOpacity(0.6)),
                left: BorderSide(
                  color: _hover ? const Color(0xFF0369A1) : Colors.transparent,
                  width: 3.0,
                ),
              ),
            ),
            child: Row(
              children: [
                for (final col in _C.values)
                  _Cell(
                    col: col,
                    val: widget.cv(widget.row, col),
                    th: widget.th,
                    useFlex: widget.useFlex,
                    fotoUrl: col == _C.tec
                        ? widget.tecFotos[_v(widget.row['TECNICO']).trim()]
                        : null,
                  ),
              ],
            ),
          ),
        ),
      );
}

class _Cell extends StatelessWidget {
  const _Cell({
    required this.col,
    required this.val,
    required this.th,
    required this.useFlex,
    this.fotoUrl,
  });

  final _C col;
  final String val;
  final _Th th;
  final bool useFlex;
  final String? fotoUrl;

  @override
  Widget build(BuildContext context) {
    Widget content;

    if (col == _C.status && val.isNotEmpty) {
      final cor = _sColor(val);
      content = Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(
          color: cor.withOpacity(0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: cor.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: cor,
              ),
            ),
            const SizedBox(width: 5),
            Text(
              val,
              style: GoogleFonts.inter(
                fontSize: 10.5,
                color: cor,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    } else if (col == _C.nos) {
      content = Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: _blue.withOpacity(0.12),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: _blue.withOpacity(0.25)),
        ),
        child: Text(
          '#$val',
          style: GoogleFonts.interTight(
            fontSize: 12,
            color: const Color(0xFF1D4ED8),
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    } else if (col == _C.equip) {
      content = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_eqIcon(val), size: 14, color: _cyan),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              val,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: th.ink,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      );
    } else if (col == _C.tec) {
      final isUndefined = val.isEmpty || val.toUpperCase().contains('NÃO DEFINIDO');
      if (isUndefined) {
        content = Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: th.surf3,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            'Não atribuído',
            style: GoogleFonts.inter(
              fontSize: 11,
              color: th.ink3,
              fontStyle: FontStyle.italic,
            ),
          ),
        );
      } else {
        final initial = val[0].toUpperCase();
        final initialText = Text(
          initial,
          style: GoogleFonts.inter(
            color: const Color(0xFF64748B),
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        );
        final String? foto = _fotoValida(fotoUrl) ? fotoUrl! : null;
        content = Row(
          children: [
            SizedBox(
              width: 22,
              height: 22,
              child: ClipOval(
                child: foto != null
                    ? Image.network(
                        foto,
                        width: 22,
                        height: 22,
                        fit: BoxFit.cover,
                        webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
                        errorBuilder: (_, __, ___) => Center(child: initialText),
                      )
                    : ColoredBox(
                        color: _blue.withOpacity(0.2),
                        child: Center(child: initialText),
                      ),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                val,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: th.ink,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        );
      }
    } else if (col == _C.pontos) {
      final pts = double.tryParse(val.replaceAll(',', '.')) ?? 0.0;
      content = pts > 0
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: _amber.withOpacity(0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '⭐ ${pts.toStringAsFixed(1)}',
                style: GoogleFonts.inter(
                  fontSize: 11.5,
                  color: _amber,
                  fontWeight: FontWeight.w700,
                ),
              ),
            )
          : Text(
              '—',
              style: GoogleFonts.inter(fontSize: 13, color: th.ink3),
              textAlign: TextAlign.center,
            );
    } else {
      content = Text(
        val.isEmpty ? '—' : val,
        style: GoogleFonts.inter(
          fontSize: 12,
          color: val.isEmpty ? th.ink3 : th.ink,
          fontWeight: FontWeight.w500,
        ),
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
        maxLines: 2,
      );
    }

    final inner = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: col == _C.tec
          ? SizedBox(width: double.infinity, child: content)
          : Center(child: content),
    );

    return useFlex
        ? Expanded(flex: _cf(col), child: inner)
        : SizedBox(width: _cw(col), child: inner);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PAGINAÇÃO RESPONSIVA
// ─────────────────────────────────────────────────────────────────────────────
class _Pagination extends StatelessWidget {
  const _Pagination({
    required this.th,
    required this.isPhone,
    required this.page,
    required this.total,
    required this.perPage,
    required this.count,
    required this.onPrev,
    required this.onNext,
    required this.onPerPage,
  });

  final _Th th;
  final bool isPhone;
  final int page, total, perPage, count;
  final VoidCallback? onPrev, onNext;
  final void Function(int) onPerPage;

  @override
  Widget build(BuildContext context) {
    final s = count == 0 ? 0 : page * perPage + 1;
    final e = ((page + 1) * perPage).clamp(0, count);

    return Container(
      margin: EdgeInsets.fromLTRB(16, 0, 16, isPhone ? 16 : 0),
      padding: EdgeInsets.fromLTRB(16, 10, 16, isPhone ? 10 : 12),
      decoration: BoxDecoration(
        color: isPhone ? Colors.transparent : th.head,
        border: isPhone ? null : Border(top: BorderSide(color: th.border)),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: Row(
        children: [
          Text(
            '$s–$e de $count ordens',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: th.ink2,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          if (!isPhone) ...[
            Row(
              children: [
                Text(
                  'Linhas por página: ',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: th.ink3,
                  ),
                ),
                for (final n in [10, 20, 50])
                  GestureDetector(
                    onTap: () => onPerPage(n),
                    child: Container(
                      margin: const EdgeInsets.only(left: 6),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: perPage == n
                            ? _blue.withOpacity(0.18)
                            : th.surf3,
                        borderRadius: BorderRadius.circular(7),
                        border: Border.all(
                          color: perPage == n
                              ? _blue.withOpacity(0.5)
                              : th.border,
                        ),
                      ),
                      child: Text(
                        '$n',
                        style: GoogleFonts.inter(
                          fontSize: 11.5,
                          color: perPage == n
                              ? const Color(0xFF1D4ED8)
                              : th.ink2,
                          fontWeight:
                              perPage == n ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),
          ],
          _PBtn(
            icon: Icons.chevron_left_rounded,
            on: onPrev != null,
            th: th,
            onTap: onPrev,
          ),
          const SizedBox(width: 8),
          Text(
            '${page + 1} / $total',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: th.ink,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          _PBtn(
            icon: Icons.chevron_right_rounded,
            on: onNext != null,
            th: th,
            onTap: onNext,
          ),
        ],
      ),
    );
  }
}

class _PBtn extends StatelessWidget {
  const _PBtn({
    required this.icon,
    required this.on,
    required this.th,
    required this.onTap,
  });

  final IconData icon;
  final bool on;
  final _Th th;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: on ? _blue.withOpacity(0.12) : th.surf3,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: on ? _blue.withOpacity(0.3) : th.border,
            ),
          ),
          child: Icon(
            icon,
            size: 18,
            color: on ? const Color(0xFF1D4ED8) : th.ink3,
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
//  TELA DE DETALHES DA O.S
// ═══════════════════════════════════════════════════════════════════════════════
void openOsDetails(
  BuildContext context,
  Map<String, dynamic> row, {
  FirebaseFirestore? db,
}) {
  Navigator.of(context).push(PageRouteBuilder(
    pageBuilder: (_, a1, a2) => OsDetailsPage(
      os: row,
      db: db ?? FirebaseFirestore.instance,
    ),
    transitionsBuilder: (_, a, __, child) => SlideTransition(
      position: Tween<Offset>(begin: const Offset(1.0, 0.0), end: Offset.zero)
          .animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
      child: child,
    ),
    transitionDuration: const Duration(milliseconds: 320),
  ));
}

class OsDetailsPage extends StatefulWidget {
  const OsDetailsPage({super.key, required this.os, required this.db});
  final Map<String, dynamic> os;
  final FirebaseFirestore db;

  @override
  State<OsDetailsPage> createState() => _OsDetailsPageState();
}

class _OsDetailsPageState extends State<OsDetailsPage> {
  bool _loading = true;
  String? _fotoUrl;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    var tec = _v(widget.os['TECNICO']).trim();
    if (tec.isEmpty) tec = _v(widget.os['TECNICORESPONSAVEL']).trim();
    if (tec.isNotEmpty) {
      try {
        final snap = await widget.db
            .collection('PONTOS_POR_TECNICO')
            .where('TECNICO', isEqualTo: tec)
            .limit(1)
            .get();
        String? foto;
        if (snap.docs.isNotEmpty) {
          foto = _v(snap.docs.first.data()['FOTO']);
        } else {
          final all = await widget.db.collection('PONTOS_POR_TECNICO').get();
          final tecLower = tec.toLowerCase();
          for (final d in all.docs) {
            if (_v(d.data()['TECNICO']).trim().toLowerCase() == tecLower) {
              foto = _v(d.data()['FOTO']);
              break;
            }
          }
        }
        if (_fotoValida(foto)) _fotoUrl = foto;
      } catch (_) {}
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final th = _Th(Theme.of(context).brightness == Brightness.dark);
    String status = _v(widget.os['STATUS']);
    if (status.isEmpty) status = 'AGUARDANDO AVALIAÇÃO';
    final cor = _sColor(status);
    String def = _v(widget.os['DEFEITO']);
    if (def.isEmpty) def = _v(widget.os['SERVICO']);

    return Scaffold(
      backgroundColor: th.bg,
      appBar: AppBar(
        backgroundColor: th.surf,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_rounded, color: th.ink),
        ),
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: cor.withOpacity(0.15),
                border: Border.all(color: cor.withOpacity(0.35)),
              ),
              child: Icon(_sIcon(status), color: cor, size: 18),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'DETALHES DA ORDEM DE SERVIÇO',
                  style: GoogleFonts.interTight(
                    fontSize: 15,
                    color: th.ink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '#${_v(widget.os["NUMERODAOS"])}',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: th.ink2,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: _loading
          ? Center(
              child: CircularProgressIndicator(color: cor, strokeWidth: 2.5),
            )
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 880),
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                      16, 16, 16, 32 + MediaQuery.of(context).padding.bottom),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Bloco(
                    title: 'INFORMAÇÕES DO EQUIPAMENTO',
                    icon: Icons.devices_other_rounded,
                    accent: _cyan,
                    th: th,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _InfoField(
                              th: th,
                              label: 'Patrimônio / N° Série',
                              value: _v(widget.os['PATRIMONIO']),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _InfoField(
                              th: th,
                              label: 'SALA',
                              value: _v(widget.os['SALA']),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _InfoField(
                              th: th,
                              label: 'SETOR',
                              value: _v(widget.os['SETOR']),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _InfoField(
                              th: th,
                              label: 'N° da O.S',
                              value: _v(widget.os['NUMERODAOS']),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _InfoField(
                        th: th,
                        label: 'Cliente',
                        value: _v(widget.os['CLIENTE']),
                      ),
                      const SizedBox(height: 10),
                      _InfoField(
                        th: th,
                        label: 'Equipamento',
                        value: _v(widget.os['EQUIPAMENTO']),
                      ),
                    ],
                  ),
                  _Bloco(
                    title: 'TÉCNICO RESPONSÁVEL',
                    icon: Icons.engineering_rounded,
                    accent: _blue,
                    th: th,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: th.surf3,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: th.border),
                        ),
                        child: _v(widget.os['TECNICO']).isEmpty
                            ? Row(
                                children: [
                                  Icon(Icons.person_off_rounded,
                                      color: th.ink3, size: 22),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Nenhum técnico definido',
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      color: th.ink3,
                                    ),
                                  ),
                                ],
                              )
                            : _TecAvatar(
                                nome: _v(widget.os['TECNICO']),
                                fotoUrl: _fotoUrl,
                                th: th,
                                size: 40,
                              ),
                      ),
                    ],
                  ),
                  _Bloco(
                    title: 'STATUS E DATAS',
                    icon: Icons.flag_rounded,
                    accent: cor,
                    th: th,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: cor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: cor.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            Icon(_sIcon(status), color: cor, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                status,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: cor,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _InfoField(
                              th: th,
                              label: 'DATA DE INÍCIO',
                              value: _v(widget.os['INICIO']),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _InfoField(
                              th: th,
                              label: 'DATA DE TÉRMINO',
                              value: _v(widget.os['TERMINO']),
                            ),
                          ),
                        ],
                      ),
                      if (status == 'AGUARDANDO PEÇA' &&
                          _v(widget.os['PREVISAODAPECA']).isNotEmpty) ...[
                        const SizedBox(height: 10),
                        _InfoField(
                          th: th,
                          label: 'PREVISÃO DA PEÇA',
                          value: _v(widget.os['PREVISAODAPECA']),
                        ),
                      ],
                    ],
                  ),
                  _Bloco(
                    title: 'INFORMAÇÕES ADICIONAIS',
                    icon: Icons.notes_rounded,
                    accent: _violet,
                    th: th,
                    children: [
                      _InfoField(th: th, label: 'Defeito Relatado', value: def),
                      const SizedBox(height: 10),
                      _InfoField(
                        th: th,
                        label: 'Serviço Realizado',
                        value: _v(widget.os['SERVICOREALIZADO']),
                      ),
                      if (_v(widget.os['PONTOS']).isNotEmpty &&
                          _v(widget.os['PONTOS']) != '0' &&
                          _v(widget.os['PONTOS']) != '0.0') ...[
                        const SizedBox(height: 10),
                        _InfoField(
                          th: th,
                          label: 'Pontos do Serviço',
                          value: '⭐ ${_v(widget.os['PONTOS'])} pts',
                        ),
                      ],
                      const SizedBox(height: 10),
                      _InfoField(
                        th: th,
                        label: 'Mês de Referência',
                        value: _v(widget.os['MES']),
                      ),
                      const SizedBox(height: 10),
                      _InfoField(
                        th: th,
                        label: 'Observações Gerais',
                        value: _v(widget.os['DESCRICAO']),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoField extends StatelessWidget {
  const _InfoField({
    required this.th,
    required this.label,
    required this.value,
  });

  final _Th th;
  final String label, value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: GoogleFonts.inter(
            fontSize: 10,
            color: th.ink3,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: th.surf3,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: th.border),
          ),
          child: Text(
            value.trim().isEmpty ? '—' : value,
            style: GoogleFonts.inter(
              fontSize: 13.5,
              color: th.ink,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _Bloco extends StatelessWidget {
  const _Bloco({
    required this.title,
    required this.icon,
    required this.th,
    required this.children,
    this.accent,
  });

  final String title;
  final IconData icon;
  final _Th th;
  final List<Widget> children;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final ac = accent ?? _blue;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: th.surf2,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: th.border),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
            decoration: BoxDecoration(
              color: th.surf3,
              border: Border(bottom: BorderSide(color: th.border)),
            ),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: ac.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(icon, size: 13, color: ac),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    color: th.ink3,
                    letterSpacing: 0.8,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }
}

class _IniBox extends StatelessWidget {
  const _IniBox({required this.ini});
  final String ini;

  @override
  Widget build(BuildContext context) => Container(
        color: _blue,
        alignment: Alignment.center,
        child: Text(
          ini,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
}

class _TecAvatar extends StatelessWidget {
  const _TecAvatar({
    required this.nome,
    this.fotoUrl,
    required this.th,
    this.size = 38,
  });

  final String nome;
  final String? fotoUrl;
  final _Th th;
  final double size;

  @override
  Widget build(BuildContext context) {
    final ini = nome
        .split(' ')
        .take(2)
        .map((w) => w.isNotEmpty ? w[0] : '')
        .join()
        .toUpperCase();
    final String? foto = _fotoValida(fotoUrl) ? fotoUrl! : null;

    return Row(
      children: [
        SizedBox(
          width: size,
          height: size,
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: th.border),
            ),
            child: ClipOval(
              child: foto != null
                  ? Image.network(
                      foto,
                      width: size,
                      height: size,
                      fit: BoxFit.cover,
                      webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
                      errorBuilder: (_, __, ___) => _IniBox(ini: ini),
                    )
                  : _IniBox(ini: ini),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            nome,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: th.ink,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
