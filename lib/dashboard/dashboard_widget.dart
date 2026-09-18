import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/custom_code/widgets/hps_sheet.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dashboard_model.dart';
export 'dashboard_model.dart';

class DashboardWidget extends StatefulWidget {
  const DashboardWidget({super.key});

  static String routeName = 'DASHBOARD';
  static String routePath = '/dashboard';

  @override
  State<DashboardWidget> createState() => _DashboardWidgetState();
}

class _DashboardWidgetState extends State<DashboardWidget> {
  late DashboardModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  Key _refreshKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DashboardModel());
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  void _refreshDashboard() {
    safeSetState(() {
      _refreshKey = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFF0B0F17);
    final borderColor = Colors.white.withOpacity(0.10);
    const textColor = Colors.white;
    const subtextColor = Color(0xFF94A3B8);

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: bgColor,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(68.0),
          child: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16.0, sigmaY: 16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF131B2E).withOpacity(0.85),
                  border: Border(
                    bottom: BorderSide(
                      color: borderColor,
                      width: 1.0,
                    ),
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                    // Botão Voltar / Início Ergonômico
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14.0),
                        onTap: () => context.safePop(),
                        child: Container(
                          width: 42.0,
                          height: 42.0,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(14.0),
                            border: Border.all(
                              color: borderColor,
                            ),
                          ),
                          child: Icon(
                            Icons.arrow_back_rounded,
                            color: subtextColor,
                            size: 20.0,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14.0),

                    // Ícone e Título da Página
                    Container(
                      width: 40.0,
                      height: 40.0,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF2563EB),
                            Color(0xFF7C3AED),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(10.0),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF2563EB).withOpacity(0.3),
                            blurRadius: 10.0,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.dashboard_rounded,
                        color: Colors.white,
                        size: 20.0,
                      ),
                    ),
                    const SizedBox(width: 12.0),

                    // Textos do Cabeçalho
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Dashboard & Ranking',
                                style: GoogleFonts.interTight(
                                  color: textColor,
                                  fontSize: 17.5,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              const SizedBox(width: 8.0),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                  vertical: 2.0,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10B981).withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(6.0),
                                  border: Border.all(
                                    color: const Color(0xFF10B981).withOpacity(0.3),
                                  ),
                                ),
                                child: Text(
                                  'AO VIVO',
                                  style: GoogleFonts.inter(
                                    color: const Color(0xFF10B981),
                                    fontSize: 10.0,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            'Desempenho operacional e matriz de serviços',
                            style: GoogleFonts.inter(
                              color: subtextColor,
                              fontSize: 12.0,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Botão Recarregar Dados
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14.0),
                        onTap: _refreshDashboard,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12.0,
                            vertical: 8.0,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(14.0),
                            border: Border.all(
                              color: borderColor,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.refresh_rounded,
                                color: subtextColor,
                                size: 18.0,
                              ),
                              const SizedBox(width: 6.0),
                              Text(
                                'Atualizar',
                                style: GoogleFonts.inter(
                                  color: subtextColor,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        body: HpsGridBackground(
          child: SafeArea(
            child: custom_widgets.RankingDashWidget(
              key: _refreshKey,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
        ),
      ),
    );
  }
}
