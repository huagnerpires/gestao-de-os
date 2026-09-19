// Automatic FlutterFlow imports
import '/backend/backend.dart';

import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'dart:ui';

import 'package:google_fonts/google_fonts.dart';
import '/custom_code/widgets/hps_sheet.dart';

// ── Paleta de Cores e Tema (canvas do login) ─────────────────
class _DashTheme {
  _DashTheme(BuildContext context);

  Color get bg => HpsUi.bg;
  Color get card => HpsUi.surface.withOpacity(0.85);
  Color get cardElevated => HpsUi.inputFill;
  Color get border => Colors.white.withOpacity(0.10);
  Color get textPrimary => HpsUi.textPrimary;
  Color get textSecondary => HpsUi.textSecondary;
  Color get textMuted => HpsUi.textMuted;
  Color get shadow => Colors.black.withOpacity(0.4);
}

// Cores temáticas para Pódio e Indicadores
const _colorGold = Color(0xFFB45309);
const _colorSilver = Color(0xFF94A3B8);
const _colorBronze = Color(0xFFB45309);
const _colorPrimary = HpsUi.accent;
const _colorAccent = Color(0xFF3730A3);
const _colorSuccess = Color(0xFF047857);
const _colorCyan = Color(0xFF0F766E);

// ── Asset e ícone por equipamento ──────────────────────────────
String _getEquipmentAsset(String eq) {
  final key = eq.toUpperCase().trim();
  if (key.contains('BEBEDOURO')) return 'assets/images/pngegg.png';
  if (key.contains('LAVADORA')) return 'assets/images/pngegg(1).png';
  if (key.contains('AR CONDICIONADO') || key.contains('AR COND')) {
    return 'assets/images/AR.png';
  }
  if (key.contains('TANQUINHO')) return 'assets/images/TANQUI.png';
  if (key.contains('FREEZER')) return 'assets/images/FREEZER.png';
  if (key.contains('LAVA E SECA')) return 'assets/images/LV_S.png';
  if (key.contains('REFRIGERADOR')) return 'assets/images/REFRI.png';
  if (key.contains('MICRO')) return 'assets/images/MICRO.png';
  return '';
}

IconData _getEquipmentIcon(String eq) {
  final key = eq.toUpperCase().trim();
  if (key.contains('BEBEDOURO')) return Icons.water_drop_outlined;
  if (key.contains('LAVADORA')) return Icons.local_laundry_service_outlined;
  if (key.contains('AR')) return Icons.ac_unit_rounded;
  if (key.contains('TANQUINHO')) return Icons.bathtub_outlined;
  if (key.contains('FREEZER')) return Icons.kitchen_outlined;
  if (key.contains('LAVA')) return Icons.dry_cleaning_outlined;
  if (key.contains('REFRIGERADOR')) return Icons.kitchen_rounded;
  if (key.contains('MICRO')) return Icons.microwave_outlined;
  return Icons.devices_other_outlined;
}

bool _fotoValida(String? s) {
  final u = (s ?? '').trim();
  return u.startsWith('http://') || u.startsWith('https://')
      ? !u.contains('Erro:')
      : false;
}

String _formatEquipmentLabel(String eq) {
  final key = eq.toUpperCase().trim();
  if (key.contains('AR CONDICIONADO')) return 'AR COND.';
  if (key.contains('REFRIGERADOR')) return 'REFRIGER.';
  if (key.contains('LAVA E SECA')) return 'LAVA/SECA';
  if (key.length > 10) return eq.split(' ').first;
  return eq;
}

String _formatPoints(double v) {
  if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}k';
  return v.toStringAsFixed(0);
}

/// ═══════════════════════════════════════════════════════════════
/// WIDGET PRINCIPAL: RankingDashWidget
/// ═══════════════════════════════════════════════════════════════
class RankingDashWidget extends StatefulWidget {
  const RankingDashWidget({super.key, this.width, this.height});
  final double? width;
  final double? height;

  @override
  State<RankingDashWidget> createState() => _RankingDashWidgetState();
}

class _RankingDashWidgetState extends State<RankingDashWidget> {
  final _db = FirebaseFirestore.instance;
  final _searchController = TextEditingController();

  List<Map<String, dynamic>> _ranking = [];
  List<String> _equips = [];
  // Map: técnico -> (equipamento -> quantidade de O.S concluídas)
  Map<String, Map<String, int>> _stats = {};
  // Map: técnico -> total geral de O.S
  Map<String, int> _tecTotals = {};
  // Map: equipamento -> total geral de O.S em todos os técnicos
  Map<String, int> _eqTotals = {};

  int _grandTotalOS = 0;
  double _totalPoints = 0.0;
  String _topEquipment = '';
  int _topEquipmentCount = 0;

  bool _loading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      // 1. Carregar lista de equipamentos
      final eqSnap = await _db.collection('EQUIPAMENTOSCADASTRO').get();
      final equips = <String>[];
      for (final d in eqSnap.docs) {
        final name =
            (d.data()['EQUIPAMENTOS'] ?? '').toString().trim().toUpperCase();
        if (name.isNotEmpty && !equips.contains(name)) {
          equips.add(name);
        }
      }

      // 2. Carregar Ranking de técnicos ordenado por PONTOS desc
      final rSnap = await _db
          .collection('PONTOS_POR_TECNICO')
          .orderBy('PONTOS', descending: true)
          .get();

      final ranking = <Map<String, dynamic>>[];
      double totalPts = 0.0;
      for (final d in rSnap.docs) {
        final m = d.data();
        final pts = (m['PONTOS'] is num) ? (m['PONTOS'] as num).toDouble() : 0.0;
        totalPts += pts;
        final rawFoto = (m['FOTO'] ?? '').toString().trim();
        ranking.add({
          'tecnico': (m['TECNICO'] ?? '').toString().trim(),
          'foto': _fotoValida(rawFoto) ? rawFoto : '',
          'pontos': pts,
        });
      }

      // 3. Carregar serviços concluídos agrupados por TECNICO e EQUIPAMENTO
      final sSnap = await _db
          .collection('SERVICOSREALIZADOS')
          .where('STATUS', isEqualTo: 'CONCLUÍDA')
          .get();

      final stats = <String, Map<String, int>>{};
      final tecTotals = <String, int>{};
      final eqTotals = <String, int>{};
      int totalOS = 0;

      for (final d in sSnap.docs) {
        final m = d.data();
        final tec = (m['TECNICO'] ?? '').toString().trim();
        final eq = (m['EQUIPAMENTO'] ?? '').toString().trim().toUpperCase();
        if (tec.isEmpty || eq.isEmpty) continue;

        stats[tec] ??= {};
        stats[tec]![eq] = (stats[tec]![eq] ?? 0) + 1;
        tecTotals[tec] = (tecTotals[tec] ?? 0) + 1;
        eqTotals[eq] = (eqTotals[eq] ?? 0) + 1;
        totalOS++;

        if (!equips.contains(eq)) {
          equips.add(eq);
        }
      }

      // Ordenar equipamentos: primeiro os que mais tiveram ordens
      equips.sort((a, b) {
        final countB = eqTotals[b] ?? 0;
        final countA = eqTotals[a] ?? 0;
        final diff = countB.compareTo(countA);
        if (diff != 0) return diff;
        return a.compareTo(b);
      });

      // Identificar equipamento campeão
      String topEq = 'N/A';
      int topEqCount = 0;
      if (equips.isNotEmpty) {
        topEq = equips.first;
        topEqCount = eqTotals[topEq] ?? 0;
      }

      if (mounted) {
        setState(() {
          _ranking = ranking;
          _equips = equips;
          _stats = stats;
          _tecTotals = tecTotals;
          _eqTotals = eqTotals;
          _grandTotalOS = totalOS;
          _totalPoints = totalPts;
          _topEquipment = topEq;
          _topEquipmentCount = topEqCount;
          _loading = false;
        });
      }
    } catch (e) {
      debugPrint('Erro ao carregar dados do RankingDash: $e');
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = _DashTheme(context);

    if (_loading) {
      return Container(
        width: widget.width ?? double.infinity,
        height: widget.height,
        color: Colors.transparent,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 36.0,
                height: 36.0,
                child: CircularProgressIndicator(
                  color: _colorPrimary,
                  strokeWidth: 3.0,
                ),
              ),
              const SizedBox(height: 16.0),
              Text(
                'Carregando indicadores operacionais...',
                style: GoogleFonts.inter(
                  color: theme.textSecondary,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Filtragem por busca
    final filteredRanking = _ranking.where((r) {
      if (_searchQuery.isEmpty) return true;
      final name = (r['tecnico'] ?? '').toString().toLowerCase();
      return name.contains(_searchQuery.toLowerCase());
    }).toList();

    return Container(
      width: widget.width ?? double.infinity,
      height: widget.height,
      color: Colors.transparent,
      child: RefreshIndicator(
        onRefresh: _loadData,
        color: _colorPrimary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
              16.0, 20.0, 16.0, 24.0 + MediaQuery.of(context).padding.bottom),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. CARDS DE KPIS EXECUTIVOS
              _buildKpisRow(theme),
              const SizedBox(height: 24.0),

              // 2. BARRA DE PESQUISA RÁPIDA DE TÉCNICOS
              _buildSearchBar(theme),
              const SizedBox(height: 20.0),

              // 3. PÓDIO DOS LÍDERES
              _buildPodiumCard(theme, filteredRanking),
              const SizedBox(height: 24.0),

              // 4. LISTA EXPANSÍVEL DOS DEMAIS TÉCNICOS (se houver mais de 3)
              if (filteredRanking.length > 3) ...[
                _buildRemainingTechnicians(theme, filteredRanking),
                const SizedBox(height: 24.0),
              ],

              // 5. MATRIZ DE SERVIÇOS POR EQUIPAMENTO (COM TOTAIS)
              _buildStatsMatrixCard(theme, filteredRanking),
            ],
          ),
        ),
      ),
    );
  }

  Widget _glassCard({
    required Widget child,
    double radius = 24,
    EdgeInsets? padding,
  }) {
    final theme = _DashTheme(context);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        boxShadow: HpsUi.cardShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: theme.card,
              borderRadius: BorderRadius.circular(radius),
              border: Border.all(color: theme.border),
            ),
            child: child,
          ),
        ),
      ),
    );
  }

  /// 1. CARDS DE KPIS EXECUTIVOS NO TOPO
  Widget _buildKpisRow(_DashTheme theme) {
    final leaderName = _ranking.isNotEmpty ? _ranking[0]['tecnico'] : '—';
    final leaderPoints = _ranking.isNotEmpty
        ? (_ranking[0]['pontos'] as num).toDouble()
        : 0.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 900;
        final cardWidth = isDesktop
            ? (constraints.maxWidth - 48.0) / 4
            : (constraints.maxWidth - 12.0) / 2;

        return Wrap(
          spacing: 12.0,
          runSpacing: 12.0,
          children: [
            // KPI 1: Líder em Pontos
            _buildKpiCard(
              theme: theme,
              width: cardWidth,
              icon: Icons.emoji_events_rounded,
              iconColor: _colorGold,
              iconBgColor: _colorGold.withOpacity(0.15),
              title: 'LÍDER ATUAL',
              value: leaderName.split(' ').first,
              subvalue: '${_formatPoints(leaderPoints)} pts',
              badgeText: '#1 RANKING',
              badgeColor: _colorGold,
            ),

            // KPI 2: Total de O.S Concluídas
            _buildKpiCard(
              theme: theme,
              width: cardWidth,
              icon: Icons.task_alt_rounded,
              iconColor: _colorSuccess,
              iconBgColor: _colorSuccess.withOpacity(0.15),
              title: 'TOTAL DE O.S',
              value: '$_grandTotalOS',
              subvalue: 'Concluídas com sucesso',
              badgeText: '100% OK',
              badgeColor: _colorSuccess,
            ),

            // KPI 3: Equipamento Campeão
            _buildKpiCard(
              theme: theme,
              width: cardWidth,
              icon: Icons.build_circle_rounded,
              iconColor: _colorCyan,
              iconBgColor: _colorCyan.withOpacity(0.15),
              title: 'MAIOR DEMANDA',
              value: _formatEquipmentLabel(_topEquipment),
              subvalue: '$_topEquipmentCount manutenções',
              badgeText: 'DESTAQUE',
              badgeColor: _colorCyan,
            ),

            // KPI 4: Total de Pontos do Time
            _buildKpiCard(
              theme: theme,
              width: cardWidth,
              icon: Icons.military_tech_rounded,
              iconColor: _colorAccent,
              iconBgColor: _colorAccent.withOpacity(0.15),
              title: 'PONTUAÇÃO TOTAL',
              value: _formatPoints(_totalPoints),
              subvalue: '${_ranking.length} técnicos ativos',
              badgeText: 'TIME HPS',
              badgeColor: _colorAccent,
            ),
          ],
        );
      },
    );
  }

  Widget _buildKpiCard({
    required _DashTheme theme,
    required double width,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String value,
    required String subvalue,
    required String badgeText,
    required Color badgeColor,
  }) {
    return SizedBox(
      width: width,
      child: _glassCard(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 38.0,
                  height: 38.0,
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Icon(icon, color: iconColor, size: 20.0),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7.0, vertical: 3.0),
                  decoration: BoxDecoration(
                    color: badgeColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6.0),
                    border: Border.all(color: badgeColor.withOpacity(0.25)),
                  ),
                  child: Text(
                    badgeText,
                    style: GoogleFonts.inter(
                      color: badgeColor,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12.0),
            Text(
              title,
              style: GoogleFonts.inter(
                color: theme.textMuted,
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(height: 4.0),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.interTight(
                color: theme.textPrimary,
                fontSize: 20.0,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 2.0),
            Text(
              subvalue,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                color: theme.textSecondary,
                fontSize: 11.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 2. BARRA DE PESQUISA RÁPIDA
  Widget _buildSearchBar(_DashTheme theme) {
    return Container(
      decoration: BoxDecoration(
        color: HpsUi.inputFill.withOpacity(0.7),
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(color: theme.border),
      ),
      child: TextField(
        controller: _searchController,
        style: GoogleFonts.inter(color: theme.textPrimary, fontSize: 13.5),
        onChanged: (val) {
          setState(() => _searchQuery = val.trim());
        },
        decoration: InputDecoration(
          hintText: 'Pesquisar técnico no ranking...',
          hintStyle:
              GoogleFonts.inter(color: theme.textMuted, fontSize: 13.5),
          prefixIcon: Icon(Icons.search_rounded,
              color: theme.textSecondary, size: 20.0),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close_rounded, size: 18.0),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        ),
      ),
    );
  }

  /// 3. PÓDIO DOS 3 LÍDERES
  Widget _buildPodiumCard(
      _DashTheme theme, List<Map<String, dynamic>> ranking) {
    if (ranking.isEmpty) {
      return SizedBox(
        width: double.infinity,
        child: _glassCard(
          padding: const EdgeInsets.all(32.0),
          child: Center(
            child: Text(
              'Nenhum técnico encontrado para o filtro.',
              style: GoogleFonts.inter(color: theme.textSecondary),
            ),
          ),
        ),
      );
    }

    final leaderPoints = (ranking[0]['pontos'] as num).toDouble();

    return SizedBox(
      width: double.infinity,
      child: _glassCard(
        padding: const EdgeInsets.all(22.0),
        child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 36.0,
                    height: 36.0,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [_colorGold, Color(0xFFC2410C)],
                      ),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: const Icon(Icons.emoji_events_rounded,
                        color: Colors.white, size: 18.0),
                  ),
                  const SizedBox(width: 10.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pódio dos Melhores Técnicos',
                        style: GoogleFonts.interTight(
                          color: theme.textPrimary,
                          fontSize: 17.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Destaques de produtividade e qualidade',
                        style: GoogleFonts.inter(
                          color: theme.textSecondary,
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 9.0, vertical: 4.0),
                decoration: BoxDecoration(
                  color: _colorPrimary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text(
                  'TOP 3',
                  style: GoogleFonts.inter(
                    color: _colorPrimary,
                    fontSize: 11.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32.0),

          // PÓDIO: 2º Lugar | 1º Lugar | 3º Lugar
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 2º Lugar
              if (ranking.length > 1)
                Expanded(
                  child: _buildPodiumCol(
                    theme: theme,
                    data: ranking[1],
                    place: 2,
                    avatarSize: 72.0,
                    leaderPoints: leaderPoints,
                    accentColor: _colorSilver,
                    medalEmoji: '🥈',
                  ),
                )
              else
                const Spacer(),

              const SizedBox(width: 10.0),

              // 1º Lugar (Campeão)
              Expanded(
                child: _buildPodiumCol(
                  theme: theme,
                  data: ranking[0],
                  place: 1,
                  avatarSize: 94.0,
                  leaderPoints: leaderPoints,
                  accentColor: _colorGold,
                  medalEmoji: '👑',
                  isFirst: true,
                ),
              ),

              const SizedBox(width: 10.0),

              // 3º Lugar
              if (ranking.length > 2)
                Expanded(
                  child: _buildPodiumCol(
                    theme: theme,
                    data: ranking[2],
                    place: 3,
                    avatarSize: 72.0,
                    leaderPoints: leaderPoints,
                    accentColor: _colorBronze,
                    medalEmoji: '🥉',
                  ),
                )
              else
                const Spacer(),
            ],
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildPodiumCol({
    required _DashTheme theme,
    required Map<String, dynamic> data,
    required int place,
    required double avatarSize,
    required double leaderPoints,
    required Color accentColor,
    required String medalEmoji,
    bool isFirst = false,
  }) {
    final name = (data['tecnico'] ?? '').toString();
    final foto = (data['foto'] ?? '').toString();
    final points = (data['pontos'] as num).toDouble();
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    final progress = leaderPoints > 0 ? (points / leaderPoints).clamp(0.0, 1.0) : 1.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            Container(
              width: avatarSize,
              height: avatarSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: accentColor,
                  width: isFirst ? 3.5 : 2.5,
                ),
                color: accentColor.withOpacity(0.12),
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withOpacity(isFirst ? 0.4 : 0.2),
                    blurRadius: isFirst ? 20.0 : 10.0,
                    spreadRadius: isFirst ? 3.0 : 0.0,
                  ),
                ],
              ),
              child: ClipOval(
                child: _fotoValida(foto)
                    ? Image.network(
                        foto,
                        fit: BoxFit.cover,
                        webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
                        errorBuilder: (_, __, ___) => Center(
                          child: Text(
                            initial,
                            style: GoogleFonts.inter(
                              color: accentColor,
                              fontSize: isFirst ? 32.0 : 24.0,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      )
                    : Center(
                        child: Text(
                          initial,
                          style: GoogleFonts.inter(
                            color: accentColor,
                            fontSize: isFirst ? 32.0 : 24.0,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
              ),
            ),
            Positioned(
              top: isFirst ? -18.0 : -12.0,
              child: Text(
                medalEmoji,
                style: TextStyle(fontSize: isFirst ? 24.0 : 18.0),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10.0),

        // Lugar e Nome
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
          decoration: BoxDecoration(
            color: accentColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(6.0),
          ),
          child: Text(
            '$place° Lugar',
            style: GoogleFonts.inter(
              color: accentColor,
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 6.0),

        Text(
          name.split(' ').first,
          style: GoogleFonts.interTight(
            color: theme.textPrimary,
            fontSize: isFirst ? 14.5 : 13.0,
            fontWeight: FontWeight.w700,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4.0),

        // Pontos em destaque
        Text(
          '${_formatPoints(points)} pts',
          style: GoogleFonts.inter(
            color: accentColor,
            fontSize: isFirst ? 14.0 : 12.5,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8.0),

        // Barra de progresso comparativa com o líder
        ClipRRect(
          borderRadius: BorderRadius.circular(4.0),
          child: SizedBox(
            width: isFirst ? 80.0 : 64.0,
            height: 4.0,
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: theme.border,
              valueColor: AlwaysStoppedAnimation<Color>(accentColor),
            ),
          ),
        ),
      ],
    );
  }

  /// 4. DEMAIS TÉCNICOS (#4 EM DIANTE)
  Widget _buildRemainingTechnicians(
      _DashTheme theme, List<Map<String, dynamic>> ranking) {
    final others = ranking.skip(3).toList();
    if (others.isEmpty) return const SizedBox.shrink();

    return _glassCard(
      padding: const EdgeInsets.all(18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.format_list_numbered_rounded,
                  color: theme.textSecondary, size: 20.0),
              const SizedBox(width: 8.0),
              Text(
                'Classificação Geral (${ranking.length} técnicos)',
                style: GoogleFonts.interTight(
                  color: theme.textPrimary,
                  fontSize: 15.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14.0),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: others.length,
            separatorBuilder: (_, __) => Divider(color: theme.border, height: 1.0),
            itemBuilder: (context, idx) {
              final item = others[idx];
              final place = idx + 4;
              final nome = (item['tecnico'] ?? '').toString();
              final foto = (item['foto'] ?? '').toString();
              final pts = (item['pontos'] as num).toDouble();
              final initial = nome.isNotEmpty ? nome[0].toUpperCase() : '?';

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Row(
                  children: [
                    Container(
                      width: 28.0,
                      height: 28.0,
                      decoration: BoxDecoration(
                        color: theme.cardElevated,
                        borderRadius: BorderRadius.circular(6.0),
                        border: Border.all(color: theme.border),
                      ),
                      child: Center(
                        child: Text(
                          '#$place',
                          style: GoogleFonts.inter(
                            color: theme.textSecondary,
                            fontSize: 11.0,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12.0),
                    Container(
                      width: 36.0,
                      height: 36.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: theme.cardElevated,
                        border: Border.all(color: theme.border),
                      ),
                      child: ClipOval(
                        child: _fotoValida(foto)
                            ? Image.network(
                                foto,
                                fit: BoxFit.cover,
                                webHtmlElementStrategy:
                                    WebHtmlElementStrategy.prefer,
                                errorBuilder: (_, __, ___) => Center(
                                  child: Text(
                                    initial,
                                    style: GoogleFonts.inter(
                                      color: theme.textSecondary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              )
                            : Center(
                                child: Text(
                                  initial,
                                  style: GoogleFonts.inter(
                                    color: theme.textSecondary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: Text(
                        nome,
                        style: GoogleFonts.inter(
                          color: theme.textPrimary,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10.0,
                        vertical: 4.0,
                      ),
                      decoration: BoxDecoration(
                        color: theme.cardElevated,
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(color: theme.border),
                      ),
                      child: Text(
                        '${_formatPoints(pts)} pts',
                        style: GoogleFonts.inter(
                          color: theme.textPrimary,
                          fontSize: 12.0,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// 5. MATRIZ DE SERVIÇOS POR EQUIPAMENTO COM TOTAIS
  Widget _buildStatsMatrixCard(
      _DashTheme theme, List<Map<String, dynamic>> ranking) {
    const colWidth = 92.0;
    const tecColWidth = 140.0;
    const totalColWidth = 100.0;

    final tecs = ranking.map((r) => r['tecnico'] as String).toList();

    return SizedBox(
      width: double.infinity,
      child: _glassCard(
        padding: const EdgeInsets.all(22.0),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabeçalho da Seção de Estatísticas
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 36.0,
                    height: 36.0,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [_colorPrimary, _colorCyan],
                      ),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: const Icon(Icons.table_chart_rounded,
                        color: Colors.white, size: 18.0),
                  ),
                  const SizedBox(width: 10.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Matriz de O.S por Equipamento',
                        style: GoogleFonts.interTight(
                          color: theme.textPrimary,
                          fontSize: 17.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Toque no número para ver a lista de ordens detalhadas',
                        style: GoogleFonts.inter(
                          color: theme.textSecondary,
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                decoration: BoxDecoration(
                  color: _colorSuccess.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(color: _colorSuccess.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle_rounded,
                        color: _colorSuccess, size: 12.0),
                    const SizedBox(width: 4.0),
                    Text(
                      'CONCLUÍDAS',
                      style: GoogleFonts.inter(
                        color: _colorSuccess,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24.0),

          // Tabela com Scroll Horizontal
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Linha de Cabeçalho das Colunas ─────────────────
                Row(
                  children: [
                    // Coluna 1: Técnico
                    SizedBox(
                      width: tecColWidth,
                      child: Text(
                        'TÉCNICO',
                        style: GoogleFonts.inter(
                          color: theme.textMuted,
                          fontSize: 11.0,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),

                    // Coluna 2: Total Geral de O.S (NOVIDADE)
                    Container(
                      width: totalColWidth,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 6.0,
                      ),
                      decoration: BoxDecoration(
                        color: _colorPrimary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(
                          color: _colorPrimary.withOpacity(0.25),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'TOTAL O.S',
                          style: GoogleFonts.inter(
                            color: _colorPrimary,
                            fontSize: 11.0,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),

                    // Colunas dos Equipamentos
                    for (final eq in _equips)
                      SizedBox(
                        width: colWidth,
                        child: Column(
                          children: [
                            _buildEquipmentHeaderIcon(eq, theme),
                            const SizedBox(height: 6.0),
                            Text(
                              _formatEquipmentLabel(eq),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                color: theme.textSecondary,
                                fontSize: 10.0,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8.0),
                Container(
                  height: 1.0,
                  width: tecColWidth + totalColWidth + (_equips.length * colWidth),
                  color: theme.border,
                ),
                const SizedBox(height: 8.0),

                // ── Linhas por Técnico ────────────────────────────
                for (int i = 0; i < tecs.length; i++)
                  _buildTechnicianRow(
                    theme: theme,
                    technician: tecs[i],
                    index: i,
                    tecColWidth: tecColWidth,
                    totalColWidth: totalColWidth,
                    colWidth: colWidth,
                  ),

                // ── Linha de TOTAL GERAL no Rodapé ────────────────
                const SizedBox(height: 8.0),
                Container(
                  height: 1.5,
                  width: tecColWidth + totalColWidth + (_equips.length * colWidth),
                  color: theme.border,
                ),
                const SizedBox(height: 8.0),
                _buildTotalFooterRow(
                  theme: theme,
                  tecColWidth: tecColWidth,
                  totalColWidth: totalColWidth,
                  colWidth: colWidth,
                ),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildEquipmentHeaderIcon(String eq, _DashTheme theme) {
    final asset = _getEquipmentAsset(eq);
    return Container(
      width: 40.0,
      height: 40.0,
      decoration: BoxDecoration(
        color: theme.cardElevated,
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: theme.border),
      ),
      child: asset.isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.asset(
                asset,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Icon(
                  _getEquipmentIcon(eq),
                  color: theme.textSecondary,
                  size: 20.0,
                ),
              ),
            )
          : Icon(
              _getEquipmentIcon(eq),
              color: theme.textSecondary,
              size: 20.0,
            ),
    );
  }

  Widget _buildTechnicianRow({
    required _DashTheme theme,
    required String technician,
    required int index,
    required double tecColWidth,
    required double totalColWidth,
    required double colWidth,
  }) {
    final tecTotal = _tecTotals[technician] ?? 0;
    final tecStats = _stats[technician] ?? {};
    final isEven = index.isEven;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2.0),
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: isEven ? theme.cardElevated.withOpacity(0.5) : Colors.transparent,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        children: [
          // Nome do Técnico
          SizedBox(
            width: tecColWidth,
            child: Row(
              children: [
                Container(
                  width: 6.0,
                  height: 6.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index == 0
                        ? _colorGold
                        : index == 1
                            ? _colorSilver
                            : index == 2
                                ? _colorBronze
                                : theme.textMuted,
                  ),
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: Text(
                    technician.split(' ').first.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      color: theme.textPrimary,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Total de O.S do Técnico
          SizedBox(
            width: totalColWidth,
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                decoration: BoxDecoration(
                  color: _colorPrimary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(color: _colorPrimary.withOpacity(0.25)),
                ),
                child: Text(
                  '$tecTotal O.S',
                  style: GoogleFonts.inter(
                    color: _colorPrimary,
                    fontSize: 12.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),

          // Células de cada equipamento
          for (final eq in _equips)
            SizedBox(
              width: colWidth,
              child: Center(
                child: _buildCountCell(
                  theme: theme,
                  technician: technician,
                  equipment: eq,
                  count: tecStats[eq] ?? 0,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCountCell({
    required _DashTheme theme,
    required String technician,
    required String equipment,
    required int count,
  }) {
    if (count == 0) {
      return Text(
        '—',
        style: GoogleFonts.inter(
          color: theme.textMuted.withOpacity(0.5),
          fontSize: 13.0,
        ),
      );
    }

    return InkWell(
      borderRadius: BorderRadius.circular(8.0),
      onTap: () {
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (_, a1, a2) => _DetailedServicesPage(
              technician: technician,
              equipment: equipment,
              count: count,
              theme: theme,
            ),
            transitionsBuilder: (_, a, __, child) => SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: a,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            ),
            transitionDuration: const Duration(milliseconds: 280),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9.0, vertical: 4.0),
        decoration: BoxDecoration(
          color: _colorAccent.withOpacity(0.12),
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: _colorAccent.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$count',
              style: GoogleFonts.inter(
                color: _colorAccent,
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 2.0),
            Icon(
              Icons.chevron_right_rounded,
              color: _colorAccent.withOpacity(0.7),
              size: 13.0,
            ),
          ],
        ),
      ),
    );
  }

  /// Linha de rodapé com o Total Geral por Equipamento
  Widget _buildTotalFooterRow({
    required _DashTheme theme,
    required double tecColWidth,
    required double totalColWidth,
    required double colWidth,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: _colorSuccess.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        children: [
          SizedBox(
            width: tecColWidth,
            child: Text(
              '  TOTAL GERAL',
              style: GoogleFonts.inter(
                color: _colorSuccess,
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ),
          SizedBox(
            width: totalColWidth,
            child: Center(
              child: Text(
                '$_grandTotalOS O.S',
                style: GoogleFonts.inter(
                  color: _colorSuccess,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          for (final eq in _equips)
            SizedBox(
              width: colWidth,
              child: Center(
                child: Text(
                  '${_eqTotals[eq] ?? 0}',
                  style: GoogleFonts.inter(
                    color: _colorSuccess,
                    fontSize: 12.0,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// ═══════════════════════════════════════════════════════════════
/// PÁGINA DE DETALHES DAS ORDENS DE SERVIÇO CONCLUÍDAS
/// ═══════════════════════════════════════════════════════════════
class _DetailedServicesPage extends StatefulWidget {
  const _DetailedServicesPage({
    required this.technician,
    required this.equipment,
    required this.count,
    required this.theme,
  });

  final String technician;
  final String equipment;
  final int count;
  final _DashTheme theme;

  @override
  State<_DetailedServicesPage> createState() => _DetailedServicesPageState();
}

class _DetailedServicesPageState extends State<_DetailedServicesPage> {
  final _db = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _services = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchServices();
  }

  Future<void> _fetchServices() async {
    try {
      final snap = await _db
          .collection('SERVICOSREALIZADOS')
          .where('TECNICO', isEqualTo: widget.technician)
          .where('EQUIPAMENTO', isEqualTo: widget.equipment)
          .where('STATUS', isEqualTo: 'CONCLUÍDA')
          .orderBy('DATA', descending: true)
          .get();

      if (mounted) {
        setState(() {
          _services = snap.docs.map((d) => {...d.data(), '_id': d.id}).toList();
          _loading = false;
        });
      }
    } catch (_) {
      try {
        final snap = await _db
            .collection('SERVICOSREALIZADOS')
            .where('TECNICO', isEqualTo: widget.technician)
            .where('EQUIPAMENTO', isEqualTo: widget.equipment)
            .where('STATUS', isEqualTo: 'CONCLUÍDA')
            .get();

        if (mounted) {
          setState(() {
            _services = snap.docs.map((d) => {...d.data(), '_id': d.id}).toList();
            _loading = false;
          });
        }
      } catch (e) {
        debugPrint('Erro ao buscar serviços detalhados: $e');
        if (mounted) {
          setState(() => _loading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.theme;

    return Scaffold(
      backgroundColor: HpsUi.bg,
      appBar: AppBar(
        backgroundColor: t.card,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_rounded, color: t.textPrimary),
        ),
        title: Row(
          children: [
            Container(
              width: 36.0,
              height: 36.0,
              decoration: BoxDecoration(
                color: _colorPrimary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Icon(
                _getEquipmentIcon(widget.equipment),
                color: _colorPrimary,
                size: 20.0,
              ),
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.technician,
                    style: GoogleFonts.interTight(
                      color: t.textPrimary,
                      fontSize: 15.0,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    widget.equipment,
                    style: GoogleFonts.inter(
                      color: t.textSecondary,
                      fontSize: 11.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                decoration: BoxDecoration(
                  color: _colorSuccess.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text(
                  '${widget.count} O.S',
                  style: GoogleFonts.inter(
                    color: _colorSuccess,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: HpsGridBackground(
        child: SafeArea(
        child: _loading
          ? const Center(
              child: CircularProgressIndicator(
                color: _colorPrimary,
                strokeWidth: 2.5,
              ),
            )
          : _services.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.inventory_2_outlined,
                          color: t.textMuted, size: 48.0),
                      const SizedBox(height: 12.0),
                      Text(
                        'Nenhuma ordem de serviço encontrada',
                        style: GoogleFonts.inter(
                          color: t.textSecondary,
                          fontSize: 14.0,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: EdgeInsets.fromLTRB(
                      16.0, 16.0, 16.0, 16.0 + MediaQuery.of(context).padding.bottom),
                  itemCount: _services.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12.0),
                  itemBuilder: (context, i) {
                    final item = _services[i];
                    return _buildServiceItemCard(t, item);
                  },
                ),
      ),
      ),
    );
  }

  Widget _buildServiceItemCard(_DashTheme t, Map<String, dynamic> item) {
    final osNumber = (item['NUMERODAOS'] ?? '—').toString();
    final cliente = (item['CLIENTE'] ?? '—').toString();
    final servico = (item['SERVICO'] ?? '—').toString();
    final dataConclusao = (item['TERMINO'] ?? item['DATA'] ?? '—').toString();
    final pts = (item['PONTOS'] is num) ? (item['PONTOS'] as num).toDouble() : 0.0;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.0),
        boxShadow: HpsUi.cardShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.0),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            decoration: BoxDecoration(
              color: t.card,
              borderRadius: BorderRadius.circular(24.0),
              border: Border.all(color: t.border),
            ),
            child: Column(
          children: [
            Container(height: 3.0, color: _colorSuccess),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 4.0),
                        decoration: BoxDecoration(
                          color: _colorPrimary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6.0),
                        ),
                        child: Text(
                          'O.S #$osNumber',
                          style: GoogleFonts.inter(
                            color: _colorPrimary,
                            fontSize: 12.0,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 4.0),
                        decoration: BoxDecoration(
                          color: _colorSuccess.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6.0),
                        ),
                        child: Text(
                          'CONCLUÍDA',
                          style: GoogleFonts.inter(
                            color: _colorSuccess,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12.0),

                  // Cliente
                  if (cliente != '—')
                    Row(
                      children: [
                        Icon(Icons.person_outline_rounded,
                            size: 15.0, color: t.textSecondary),
                        const SizedBox(width: 6.0),
                        Expanded(
                          child: Text(
                            cliente,
                            style: GoogleFonts.inter(
                              color: t.textPrimary,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),

                  // Descrição do Serviço
                  if (servico != '—') ...[
                    const SizedBox(height: 8.0),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.description_outlined,
                            size: 15.0, color: t.textMuted),
                        const SizedBox(width: 6.0),
                        Expanded(
                          child: Text(
                            servico,
                            style: GoogleFonts.inter(
                              color: t.textSecondary,
                              fontSize: 12.5,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 12.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.event_available_rounded,
                              size: 14.0, color: _colorSuccess),
                          const SizedBox(width: 4.0),
                          Text(
                            dataConclusao,
                            style: GoogleFonts.inter(
                              color: t.textSecondary,
                              fontSize: 11.5,
                            ),
                          ),
                        ],
                      ),
                      if (pts > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 3.0),
                          decoration: BoxDecoration(
                            color: _colorGold.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(6.0),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.star_rounded,
                                  color: _colorGold, size: 14.0),
                              const SizedBox(width: 4.0),
                              Text(
                                '${pts.toStringAsFixed(1)} pts',
                                style: GoogleFonts.inter(
                                  color: _colorGold,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
          ),
        ),
      ),
    );
  }
}
