import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/custom_code/widgets/index.dart' as custom_widgets;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'tesssstetetetetetetete_model.dart';
export 'tesssstetetetetetetete_model.dart';

class TessssteteteteteteteteWidget extends StatefulWidget {
  const TessssteteteteteteteteWidget({super.key});

  static String routeName = 'tesssstetetetetetetete';
  static String routePath = '/tesssstetetetetetetete';

  @override
  State<TessssteteteteteteteteWidget> createState() =>
      _TessssteteteteteteteteWidgetState();
}

class _TessssteteteteteteteteWidgetState
    extends State<TessssteteteteteteteteWidget> {
  late TessssteteteteteteteteModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => TessssteteteteteteteteModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).primary,
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            tooltip: 'Voltar',
            onPressed: () async {
              context.safePop();
            },
          ),
          title: Text(
            'Relatório de Equipamentos',
            style: FlutterFlowTheme.of(context).headlineMedium.override(
                  font: GoogleFonts.interTight(
                    fontWeight:
                        FlutterFlowTheme.of(context).headlineMedium.fontWeight,
                    fontStyle:
                        FlutterFlowTheme.of(context).headlineMedium.fontStyle,
                  ),
                  color: Colors.white,
                  fontSize: 20.0,
                  letterSpacing: 0.0,
                  fontWeight:
                      FlutterFlowTheme.of(context).headlineMedium.fontWeight,
                  fontStyle:
                      FlutterFlowTheme.of(context).headlineMedium.fontStyle,
                ),
          ),
          actions: [],
          centerTitle: false,
          elevation: 0.0,
        ),
        body: SafeArea(
          top: true,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(
                  width: MediaQuery.sizeOf(context).width * 0.99,
                  height: MediaQuery.sizeOf(context).height * 0.99,
                  child: custom_widgets.RelatorioEquipamentosWidget(
                    width: MediaQuery.sizeOf(context).width * 0.99,
                    height: MediaQuery.sizeOf(context).height * 0.99,
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
