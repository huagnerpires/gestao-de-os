// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart' hide HpsUi, HpsGridBackground, HpsCloseButton, showHpsSheet; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'dart:async';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'hps_sheet.dart';

import '/flutter_flow/nav/nav.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/index.dart';

import '/components/os_customwidget_widget.dart';
import '/components/os_custom_e_x_c_l_u_i_r_widget.dart';
import '/components/cadastrar_novo_sem_erro_widget.dart';
import '/components/cadastrar_equipamento_customwidget_widget.dart';
import '/components/usuario_novo_widget.dart';
import '/components/gerenciar_tecnicos_sheet_widget.dart';
import '/custom_code/widgets/enviar_email_livre_widget.dart';
import '/components/ia_hps_widget.dart';
import '/area_restrita/senha_para_area_restrita/senha_para_area_restrita_widget.dart';
import '/custom_code/widgets/notificacao_bell_widget.dart';
import '/custom_code/widgets/os_abrir.dart';
import '/custom_code/widgets/os_table_widget.dart';
import '/custom_code/widgets/os_tempo.dart';
import '/custom_code/widgets/sla_painel_widget.dart';
import '/custom_code/widgets/compartilhar_os_widget.dart';
import '/components/teste_preventivas_widget.dart';
import '/components/email_novo_widget.dart';
import '/components/email_nova_widget.dart';
import '/components/preventivas_penden_widget.dart';
import '/components/imagens_widget.dart';
import '/components/editar_preventiva_widget.dart';
import '/components/enviar_notas_widget.dart';
import '/components/formulario_widget.dart';

// ─── Paleta de Status Operacionais ───────────────────────────────────────────
class _St {
  final String status, label;
  final IconData icon;
  final Color accent;
  const _St(this.status, this.label, this.icon, this.accent);
}

const _kSt = <_St>[
  _St('AGUARDANDO AVALIAÇÃO', 'Pendentes', Icons.assignment_outlined,
      Color(0xFF1D4ED8)),
  _St('INICIAR AVALIAÇÃO', 'Testes', Icons.science_outlined,
      Color(0xFF3730A3)),
  _St('PASSAR ORÇAMENTO', 'Orçamento', Icons.request_quote_outlined,
      Color(0xFF0F766E)),
  _St('AGUARDANDO APROVAÇÃO', 'Ag. Aprovação', Icons.hourglass_top_outlined,
      Color(0xFFC2410C)),
  _St('AGUARDANDO PEÇA', 'Ag. Peça', Icons.inventory_2_outlined,
      Color(0xFFA16207)),
  _St('CANCELADA', 'Canceladas', Icons.cancel_outlined,
      Color(0xFFB91C1C)),
  _St('APROVADO', 'Aprovadas', Icons.verified_outlined,
      Color(0xFF047857)),
  _St('INICIOU O SERVIÇO', 'Em Andamento', Icons.handyman_outlined,
      Color(0xFF0369A1)),
  _St('CONCLUÍDA', 'Concluídas', Icons.check_circle_outline_rounded,
      Color(0xFF047857)),
];

// ─── Tokens de Cores Modernizados (Clean / Dark Mode) ─────────────────────────
class _C {
  // Escuro — Dark Slate Moderno de Alto Contraste
  static const dkBg = Color(0xFF0B0F17);
  static const dkSurface = Color(0xFF131B2E);
  static const dkSurface2 = Color(0xFF1E293B);
  static const dkTopBar = Color(0xFF0F172A);
  static const dkBorder = Color(0x1AFFFFFF); // white 10%
  static const dkText = Colors.white;
  static const dkSubtext = Color(0xFF94A3B8);

  // Claro — Executivo Ultra Clean
  static const ltBg = Color(0xFFF1F5F9);
  static const ltSurface = Color(0xFFFFFFFF);
  static const ltSurface2 = Color(0xFFF8FAFC);
  static const ltTopBar = Color(0xFF1E293B);
  static const ltBorder = Color(0xFFE2E8F0);
  static const ltText = Color(0xFF0F172A);
  static const ltSubtext = Color(0xFF64748B);
}

/// ─── Widget Principal: HomePageCustomWidget ──────────────────────────────────
class HomePageCustomWidget extends StatefulWidget {
  const HomePageCustomWidget({super.key, this.width, this.height});
  final double? width;
  final double? height;

  @override
  State<HomePageCustomWidget> createState() => _HomePageCustomWidgetState();
}

class _HomePageCustomWidgetState extends State<HomePageCustomWidget>
    with SingleTickerProviderStateMixin {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final Map<String, int> _counts = {};
  final List<StreamSubscription<QuerySnapshot>> _subs = [];
  int _chatUnread = 0;
  StreamSubscription<QuerySnapshot>? _chatSub;
  Timer? _clockTimer;
  DateTime _now = DateTime.now();
  DateTime? _calDate;
  double? _avgDays;
  List<OsStaleItem> _stale = [];
  bool _osTempoReady = false;

  @override
  void initState() {
    super.initState();
    _listenCounts();
    _listenChat();
    _loadOsTempoOnce();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _now = DateTime.now());
    });
  }

  Future<void> _loadOsTempoOnce() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('SERVICOSREALIZADOS')
          .limit(500)
          .get();
      final rows = snap.docs
          .map((d) => <String, dynamic>{
                ...d.data(),
                '_id': d.id,
              })
          .toList();
      final stats = computeOsTempo(rows);
      if (!mounted) return;
      setState(() {
        _avgDays = stats.avgDays;
        _stale = stats.stale;
        _osTempoReady = true;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        maybeShowOsStaleDialog(context, stats.stale, onOpen: _openOsFromStale);
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _osTempoReady = true);
    }
  }

  void _listenCounts() {
    for (final s in _kSt) {
      _subs.add(FirebaseFirestore.instance
          .collection('SERVICOSREALIZADOS')
          .where('STATUS', isEqualTo: s.status)
          .snapshots()
          .listen((snap) {
        if (!mounted) return;
        setState(() => _counts[s.status] = snap.docs.length);
      }));
    }
  }

  void _listenChat() {
    _chatSub = FirebaseFirestore.instance
        .collection('CHAT')
        .where('lida_ou_nao', isEqualTo: false)
        .where('adm', isEqualTo: false)
        .snapshots()
        .listen((snap) {
      if (!mounted) return;
      setState(() => _chatUnread = snap.docs.length);
    });
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    for (final s in _subs) {
      s.cancel();
    }
    _chatSub?.cancel();
    super.dispose();
  }

  void _openOsSheet(String status) =>
      _sheet(OsCustomwidgetWidget(status: status));

  void _openOsFromStale(Map<String, dynamic> row) {
    openOsEditarSheet(
      context,
      row,
      FirebaseFirestore.instance,
      () {
        _loadOsTempoOnce();
      },
    );
  }

  void _sheet(Widget child) {
    showHpsSheet(context, child: child);
  }

  String _fmtClock(DateTime d, {required bool phone}) {
    final hh = d.hour.toString().padLeft(2, '0');
    final mm = d.minute.toString().padLeft(2, '0');
    final ss = d.second.toString().padLeft(2, '0');
    if (phone) return '$hh:$mm:$ss';
    final dd = d.day.toString().padLeft(2, '0');
    final mo = d.month.toString().padLeft(2, '0');
    return '$dd/$mo/${d.year}  $hh:$mm:$ss';
  }

  String _fmtDate(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mo = d.month.toString().padLeft(2, '0');
    return '$dd/$mo/${d.year}';
  }

  Future<void> _openCalendar() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _calDate ?? _now,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF1D4ED8),
              onPrimary: Colors.white,
              surface: Color(0xFF131B2E),
              onSurface: Colors.white,
            ),
            dialogTheme: const DialogThemeData(
              backgroundColor: Color(0xFF0B0F17),
            ),
            datePickerTheme: DatePickerThemeData(
              backgroundColor: const Color(0xFF0B0F17),
              surfaceTintColor: Colors.transparent,
              headerBackgroundColor: const Color(0xFF131B2E),
              headerForegroundColor: Colors.white,
              dayForegroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return Colors.white;
                }
                return Colors.white;
              }),
              dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return const Color(0xFF1D4ED8);
                }
                return Colors.transparent;
              }),
              todayForegroundColor:
                  WidgetStateProperty.all(const Color(0xFF1D4ED8)),
              todayBorder: const BorderSide(color: Color(0xFF1D4ED8)),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked == null || !mounted) return;
    setState(() => _calDate = picked);
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.70),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 360),
          padding: const EdgeInsets.fromLTRB(22, 20, 22, 16),
          decoration: BoxDecoration(
            color: const Color(0xFF131B2E),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.10)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Data selecionada',
                style: GoogleFonts.interTight(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _fmtDate(picked),
                style: GoogleFonts.inter(
                  color: const Color(0xFF94A3B8),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(
                    'OK',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF1D4ED8),
                      fontWeight: FontWeight.w700,
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

  Future<void> _openAreaRestrita() async {
    await showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.70),
      builder: (ctx) => CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.escape): () =>
              Navigator.pop(ctx),
        },
        child: Focus(
          autofocus: true,
          child: Dialog(
            backgroundColor: Colors.transparent,
            insetPadding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Stack(
              alignment: Alignment.topRight,
              children: [
                const SenhaParaAreaRestritaWidget(),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: HpsCloseButton(onPressed: () => Navigator.pop(ctx)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildClockAndCalendar() {
    final phone = _isPhone;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _fmtClock(_now, phone: phone),
              style: GoogleFonts.interTight(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: phone ? 12 : 13.5,
                letterSpacing: 0.2,
              ),
            ),
            if (!phone)
              Text(
                _calDate != null
                    ? 'Calendário: ${_fmtDate(_calDate!)}'
                    : 'Horário local',
                style: GoogleFonts.inter(
                  color: const Color(0xFF94A3B8),
                  fontSize: 10,
                ),
              ),
          ],
        ),
        IconButton(
          tooltip: 'Calendário',
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
          icon: const Icon(
            Icons.calendar_month_rounded,
            size: 20,
            color: Color(0xFF94A3B8),
          ),
          onPressed: _openCalendar,
        ),
      ],
    );
  }

  void _toggleTheme() {
    final dark = Theme.of(context).brightness == Brightness.dark;
    setDarkModeSetting(context, dark ? ThemeMode.light : ThemeMode.dark);
  }

  bool get _isPhone => MediaQuery.sizeOf(context).width < 700;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final w = MediaQuery.sizeOf(context).width;

    final content = SafeArea(
      child: _isPhone
          ? CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _buildTopBar(theme, isDark)),
                SliverToBoxAdapter(
                    child: _buildStatusStrip(theme, isDark, true)),
                SliverToBoxAdapter(child: _buildPhoneOsTempoRow()),
                SliverToBoxAdapter(child: _buildActionGrid(theme, w, isDark)),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
              ],
            )
          : Column(
              children: [
                _buildTopBar(theme, isDark),
                _buildStatusStrip(theme, isDark, false),
                _buildActionGrid(theme, w, isDark),
                Expanded(child: _buildOsTable(theme, isDark)),
              ],
            ),
    );

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: isDark ? _C.dkBg : _C.ltBg,
      drawer: _buildDrawer(theme, isDark),
      body: isDark ? HpsGridBackground(child: content) : content,
    );
  }

  // ── TOP BAR CORPORATIVA PREMIUM ───────────────────────────────────────────
  Widget _buildTopBar(FlutterFlowTheme theme, bool isDark) {
    final topBg = isDark
        ? HpsUi.surface.withOpacity(0.85)
        : _C.ltTopBar;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 18,
        vertical: _isPhone ? 10 : 12,
      ),
      decoration: BoxDecoration(
        color: topBg,
        border: Border(
          bottom: BorderSide(
            color: isDark
                ? Colors.white.withOpacity(0.10)
                : const Color(0xFF26334D),
            width: 1.0,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.28 : 0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Botão Menu Hambúrguer
          _IconBtn(
            icon: Icons.menu_rounded,
            onTap: () => _scaffoldKey.currentState!.openDrawer(),
            color: Colors.white,
          ),
          const SizedBox(width: 12),

          // Logo com Badge Moderno
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1D4ED8), Color(0xFF1D4ED8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1D4ED8).withOpacity(0.35),
                  blurRadius: 8,
                ),
              ],
            ),
            child: const Icon(
              Icons.ac_unit_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),

          // Nome do Sistema e Subtítulo
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      'HPS Refrigeração',
                      style: GoogleFonts.interTight(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        letterSpacing: -0.2,
                      ),
                    ),
                    if (!_isPhone) ...[
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF047857).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: const Color(0xFF047857).withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFF047857),
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'SISTEMA ONLINE',
                              style: GoogleFonts.inter(
                                color: const Color(0xFF047857),
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Gestão Inteligente de Ordens de Serviço',
                  style: GoogleFonts.inter(
                    color: Colors.white70,
                    fontSize: 11,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),

          _buildClockAndCalendar(),
          const SizedBox(width: 6),

          // Sino de Notificações
          SizedBox(
            width: 34,
            height: 34,
            child: NotificacaoBellWidget(width: 34, height: 34),
          ),
          const SizedBox(width: 10),

          // Badge de Chat
          _chatBadge(),
          const SizedBox(width: 10),

          // Toggle de Tema
          _themeToggle(isDark),
        ],
      ),
    );
  }

  Widget _chatBadge() {
    return GestureDetector(
      onTap: () => _sheet(const ChatListaWidget()),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white.withOpacity(0.15)),
            ),
            child: const Icon(
              Icons.chat_bubble_outline_rounded,
              size: 18,
              color: Colors.white,
            ),
          ),
          if (_chatUnread > 0)
            Positioned(
              top: -4,
              right: -4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFB91C1C),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFB91C1C).withOpacity(0.4),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Text(
                  '$_chatUnread',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 9.0,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _themeToggle(bool isDark) {
    return GestureDetector(
      onTap: _toggleTheme,
      child: Container(
        width: 44,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withOpacity(0.15)),
        ),
        child: Icon(
          isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
          size: 18,
          color: isDark ? const Color(0xFFB45309) : Colors.white,
        ),
      ),
    );
  }

  // ── STATUS STRIP MODERNO (CARDS DE MÉTRICAS) ──────────────────────────────
  Widget _buildPhoneOsTempoRow() {
    if (!_osTempoReady) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 6,
        children: [
          _phoneOsTempoChip(
            label: 'Média: ${formatOsAvgDays(_avgDays)}',
            color: const Color(0xFF1D4ED8),
          ),
          if (_stale.isNotEmpty)
            _phoneOsTempoChip(
              label: '${_stale.length} O.S. +5 dias',
              color: const Color(0xFFB91C1C),
              onTap: () => maybeShowOsStaleDialog(
                context,
                _stale,
                force: true,
                onOpen: _openOsFromStale,
              ),
            ),
        ],
      ),
    );
  }

  Widget _phoneOsTempoChip({
    required String label,
    required Color color,
    VoidCallback? onTap,
  }) {
    final child = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.16),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.40)),
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

  Widget _buildStatusStrip(FlutterFlowTheme theme, bool isDark, bool small) {
    final stripBg = isDark ? Colors.transparent : _C.ltBg;

    return Container(
      color: stripBg,
      height: small ? 104.0 : 120.0,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        itemCount: _kSt.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) => _statusCard(_kSt[i], isDark, small),
      ),
    );
  }

  Widget _statusCard(_St s, bool isDark, bool small) {
    final count = _counts[s.status] ?? 0;
    final cardW = small ? 92.0 : 112.0;
    final bg = isDark ? HpsUi.surface.withOpacity(0.85) : _C.ltSurface;
    final border = isDark ? Colors.white.withOpacity(0.10) : _C.ltBorder;
    final hasActive = count > 0;
    const radius = 22.0;

    Widget card = Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(radius),
        onTap: () => _openOsSheet(s.status),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: cardW,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: hasActive
                  ? s.accent.withOpacity(isDark ? 0.55 : 0.4)
                  : border,
              width: hasActive ? 1.5 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: hasActive
                    ? s.accent.withOpacity(isDark ? 0.22 : 0.10)
                    : Colors.black.withOpacity(isDark ? 0.25 : 0.03),
                blurRadius: hasActive ? 10 : 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: small ? 24 : 28,
                    height: small ? 24 : 28,
                    decoration: BoxDecoration(
                      color: s.accent.withOpacity(isDark ? 0.20 : 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      s.icon,
                      color: s.accent,
                      size: small ? 14 : 16,
                    ),
                  ),
                  if (hasActive)
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: s.accent,
                        boxShadow: [
                          BoxShadow(
                            color: s.accent.withOpacity(0.8),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text(
                  '$count',
                  style: GoogleFonts.interTight(
                    color: isDark ? _C.dkText : _C.ltText,
                    fontSize: small ? 18 : 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              Text(
                s.label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  color: isDark ? _C.dkSubtext : _C.ltSubtext,
                  fontSize: small ? 9.5 : 10.5,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (!isDark) return card;
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: card,
      ),
    );
  }

  // ── ACTION GRID COM GRADIENTES E ELEVAÇÃO ──────────────────────────────────
  Widget _buildActionGrid(FlutterFlowTheme theme, double w, bool isDark) {
    final isPhone = w < 700;

    final coreActions = <_ActionItem>[
      _ActionItem(
        label: '+ Nova Ordem',
        icon: Icons.add_circle_outline_rounded,
        gradient: const LinearGradient(
          colors: [Color(0xFF1D4ED8), Color(0xFF1D4ED8)],
        ),
        shadowColor: const Color(0xFF1D4ED8),
        onTap: () => _sheet(const CadastrarNovoSemErroWidget()),
      ),
      _ActionItem(
        label: 'Dashboard & Ranking',
        icon: Icons.bar_chart_rounded,
        gradient: const LinearGradient(
          colors: [Color(0xFF3730A3), Color(0xFF4C1D95)],
        ),
        shadowColor: const Color(0xFF3730A3),
        onTap: () => context.pushNamed(DashboardWidget.routeName),
      ),
      _ActionItem(
        label: 'Excluir Ordem',
        icon: Icons.delete_outline_rounded,
        gradient: const LinearGradient(
          colors: [Color(0xFFB91C1C), Color(0xFF991B1B)],
        ),
        shadowColor: const Color(0xFFB91C1C),
        onTap: () => _sheet(const OsCustomEXCLUIRWidget(status: '')),
      ),
      _ActionItem(
        label: 'Assistente IA',
        icon: Icons.smart_toy_outlined,
        gradient: const LinearGradient(
          colors: [Color(0xFF0369A1), Color(0xFF0369A1)],
        ),
        shadowColor: const Color(0xFF0369A1),
        onTap: () => _sheet(const IaHpsWidget()),
      ),
      _ActionItem(
        label: 'SLA / Alertas',
        icon: Icons.timer_outlined,
        gradient: const LinearGradient(
          colors: [Color(0xFF0F766E), Color(0xFF0F766E)],
        ),
        shadowColor: const Color(0xFF0F766E),
        onTap: () => _sheet(const SlaPainelWidget()),
      ),
      _ActionItem(
        label: 'Compartilhar O.S.',
        icon: Icons.share_outlined,
        gradient: const LinearGradient(
          colors: [Color(0xFF475569), Color(0xFF334155)],
        ),
        shadowColor: const Color(0xFF475569),
        onTap: () => _sheet(const CompartilharOsWidget()),
      ),
    ];

    final mobileExtras = <_ActionItem>[
      _ActionItem(
        label: 'Preventiva',
        icon: Icons.list_alt_rounded,
        gradient: const LinearGradient(
          colors: [Color(0xFF0369A1), Color(0xFF075985)],
        ),
        shadowColor: const Color(0xFF0369A1),
        onTap: () => _sheet(const TestePreventivasWidget()),
      ),
      _ActionItem(
        label: 'Cad. Equipamento',
        icon: Icons.precision_manufacturing_outlined,
        gradient: const LinearGradient(
          colors: [Color(0xFF047857), Color(0xFF047857)],
        ),
        shadowColor: const Color(0xFF047857),
        onTap: () => _sheet(const CadastrarEquipamentoCustomwidgetWidget())),
      _ActionItem(
        label: 'Cad. Usuário',
        icon: Icons.person_outline_rounded,
        gradient: const LinearGradient(
          colors: [Color(0xFF1D4ED8), Color(0xFF1E40AF)],
        ),
        shadowColor: const Color(0xFF1D4ED8),
        onTap: () => _sheet(const UsuarioNovoWidget())),
      _ActionItem(
        label: 'Técnicos',
        icon: Icons.engineering_rounded,
        gradient: const LinearGradient(
          colors: [Color(0xFF0369A1), Color(0xFF0369A1)],
        ),
        shadowColor: const Color(0xFF0369A1),
        onTap: () => _sheet(const GerenciarTecnicosSheetWidget())),
      _ActionItem(
        label: 'Notificações',
        icon: Icons.notifications_none_rounded,
        gradient: const LinearGradient(
          colors: [Color(0xFF3730A3), Color(0xFF4C1D95)],
        ),
        shadowColor: const Color(0xFF3730A3),
        onTap: () => _sheet(const EmailNovoWidget())),
      _ActionItem(
        label: 'Enviar Relatório',
        icon: Icons.send_outlined,
        gradient: const LinearGradient(
          colors: [Color(0xFF0F766E), Color(0xFF0E7490)],
        ),
        shadowColor: const Color(0xFF0F766E),
        onTap: () => _sheet(const EmailNovaWidget())),
      _ActionItem(
        label: 'Verif. Preventivas',
        icon: Icons.domain_verification_outlined,
        gradient: const LinearGradient(
          colors: [Color(0xFFC2410C), Color(0xFFC2410C)],
        ),
        shadowColor: const Color(0xFFC2410C),
        onTap: () => _sheet(const PreventivasPendenWidget())),
      _ActionItem(
        label: 'Verif. Imagens',
        icon: Icons.image_search_outlined,
        gradient: const LinearGradient(
          colors: [Color(0xFF0369A1), Color(0xFF075985)],
        ),
        shadowColor: const Color(0xFF0369A1),
        onTap: () => _sheet(const ImagensWidget())),
      _ActionItem(
        label: 'Editar Preventiva',
        icon: Icons.edit_note_outlined,
        gradient: const LinearGradient(
          colors: [Color(0xFF047857), Color(0xFF047857)],
        ),
        shadowColor: const Color(0xFF047857),
        onTap: () => _sheet(const EditarPreventivaWidget())),
      _ActionItem(
        label: 'Enviar Notas',
        icon: Icons.description_outlined,
        gradient: const LinearGradient(
          colors: [Color(0xFF475569), Color(0xFF334155)],
        ),
        shadowColor: const Color(0xFF475569),
        onTap: () => _sheet(const EnviarNotasWidget())),
      _ActionItem(
        label: 'Formulário',
        icon: Icons.format_align_left_outlined,
        gradient: const LinearGradient(
          colors: [Color(0xFF475569), Color(0xFF1E293B)],
        ),
        shadowColor: const Color(0xFF475569),
        onTap: () => _sheet(const FormularioWidget())),
    ];

    final actions = isPhone ? [...coreActions, ...mobileExtras] : coreActions;
    final sectionBg = isDark ? Colors.transparent : _C.ltBg;

    if (!isPhone) {
      return Container(
        color: sectionBg,
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
        child: Row(
          children: actions
              .map((a) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: _buildActionButton(a, isDark),
                    ),
                  ))
              .toList(),
        ),
      );
    }

    return Container(
      color: sectionBg,
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: actions.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 1.15,
        ),
        itemBuilder: (_, i) => _buildActionCardMobile(actions[i], isDark),
      ),
    );
  }

  Widget _buildActionButton(_ActionItem a, bool isDark) {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: a.gradient,
        border: Border.all(
          color: Colors.white.withOpacity(0.18),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: a.shadowColor.withOpacity(0.16),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: a.onTap,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(a.icon, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  a.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.interTight(
                    color: Colors.white,
                    fontSize: 13.0,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionCardMobile(_ActionItem a, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: a.gradient,
        boxShadow: [
          BoxShadow(
            color: a.shadowColor.withOpacity(0.14),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: a.onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(a.icon, color: Colors.white, size: 20),
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  a.label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.interTight(
                    color: Colors.white,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── CONTAINER DA TABELA DE O.S ────────────────────────────────────────────
  Widget _buildOsTable(FlutterFlowTheme theme, bool isDark) {
    final radius = BorderRadius.circular(isDark ? 22 : 20);
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      decoration: BoxDecoration(
        color: isDark ? HpsUi.surface : _C.ltSurface,
        borderRadius: radius,
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.10) : _C.ltBorder,
        ),
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: OsTableWidget(
          width: double.infinity,
          height: double.infinity,
        ),
      ),
    );
  }

  // ── MENU LATERAL (DRAWER) ──────────────────────────────────────────────────
  Widget _buildDrawer(FlutterFlowTheme theme, bool isDark) {
    final drawerBg = isDark ? _C.dkSurface : _C.ltSurface;
    final divColor = isDark ? _C.dkBorder : _C.ltBorder;

    return SizedBox(
      width: _isPhone ? 280 : 320,
      child: Drawer(
        backgroundColor: drawerBg,
        child: SafeArea(
          child: Column(
            children: [
              _drawerHeader(theme, isDark),
              Divider(height: 1, color: divColor),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: [
                    _DTile(
                      Icons.precision_manufacturing_outlined,
                      'Cadastrar/Editar Equipamento',
                      () {
                        Navigator.pop(context);
                        _sheet(const CadastrarEquipamentoCustomwidgetWidget());
                      },
                      isDark: isDark,
                    ),
                    _DTile(
                      Icons.person_outline_rounded,
                      'Cadastrar/Editar Usuário',
                      () {
                        Navigator.pop(context);
                        _sheet(const UsuarioNovoWidget());
                      },
                      isDark: isDark,
                    ),
                    _DTile(
                      Icons.engineering_rounded,
                      'Gerenciar Técnicos',
                      () {
                        Navigator.pop(context);
                        _sheet(const GerenciarTecnicosSheetWidget());
                      },
                      isDark: isDark,
                    ),
                    _DTile(
                      Icons.mail_outline_rounded,
                      'Enviar E-mail',
                      () {
                        Navigator.pop(context);
                        _sheet(EnviarEmailLivreWidget(
                          onCancelar: () async => Navigator.of(context).pop(),
                        ));
                      },
                      isDark: isDark,
                    ),
                    Divider(indent: 16, endIndent: 16, color: divColor),
                    _DTile(
                      Icons.lock_outline_rounded,
                      'Área Restrita',
                      () async {
                        Navigator.pop(context);
                        await _openAreaRestrita();
                        if (!mounted) return;
                        FFAppState().SOMAR2 = 0;
                        setState(() {});
                      },
                      iconColor: const Color(0xFFB91C1C),
                      labelColor: const Color(0xFFB91C1C),
                      isDark: isDark,
                    ),
                  ],
                ),
              ),
              _drawerFooter(theme, isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _drawerHeader(FlutterFlowTheme theme, bool isDark) {
    final headerBg = isDark ? _C.dkTopBar : _C.ltTopBar;

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 18),
      color: headerBg,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1D4ED8), Color(0xFF1D4ED8)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.ac_unit_rounded,
                color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'HPS Refrigeração',
                  style: GoogleFonts.interTight(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                Text(
                  'Gestão de O.S • Operacional',
                  style: GoogleFonts.inter(
                    color: Colors.white60,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _drawerFooter(FlutterFlowTheme theme, bool isDark) {
    final label = currentUserDisplayName.isNotEmpty
        ? currentUserDisplayName
        : (currentUserEmail.isNotEmpty ? currentUserEmail : 'Operador');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border:
            Border(top: BorderSide(color: isDark ? _C.dkBorder : _C.ltBorder)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: const Color(0xFF1D4ED8).withOpacity(0.15),
            child: const Icon(Icons.person_outline_rounded,
                color: Color(0xFF1D4ED8), size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                color: isDark ? _C.dkSubtext : _C.ltSubtext,
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded,
                color: Color(0xFFB91C1C), size: 18),
            onPressed: () async {
              Navigator.pop(context);
              GoRouter.of(context).prepareAuthEvent();
              await authManager.signOut();
              GoRouter.of(context).clearRedirectLocation();
              if (!mounted) return;
              context.goNamedAuth(LoginWidget.routeName, context.mounted);
            },
          ),
        ],
      ),
    );
  }
}

// ── Item de Ação ─────────────────────────────────────────────────────────────
class _ActionItem {
  final String label;
  final IconData icon;
  final LinearGradient gradient;
  final Color shadowColor;
  final VoidCallback onTap;

  const _ActionItem({
    required this.label,
    required this.icon,
    required this.gradient,
    required this.shadowColor,
    required this.onTap,
  });
}

class _IconBtn extends StatelessWidget {
  const _IconBtn(
      {required this.icon, required this.onTap, required this.color});
  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, color: color, size: 22),
        ),
      );
}

class _DTile extends StatelessWidget {
  const _DTile(this.icon, this.label, this.onTap,
      {this.iconColor, this.labelColor, required this.isDark});
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? labelColor;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: iconColor ?? (isDark ? _C.dkSubtext : _C.ltSubtext),
        size: 20,
      ),
      title: Text(
        label,
        style: GoogleFonts.inter(
          color: labelColor ?? (isDark ? _C.dkText : _C.ltText),
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
      dense: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onTap: onTap,
    );
  }
}
