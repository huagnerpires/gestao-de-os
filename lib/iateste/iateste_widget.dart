import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/custom_code/widgets/index.dart' as custom_widgets;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'iateste_model.dart';
export 'iateste_model.dart';

class IatesteWidget extends StatefulWidget {
  const IatesteWidget({super.key});

  static String routeName = 'iateste';
  static String routePath = '/iateste';

  @override
  State<IatesteWidget> createState() => _IatesteWidgetState();
}

class _IatesteWidgetState extends State<IatesteWidget> {
  late IatesteModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => IatesteModel());

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
        body: SafeArea(
          top: true,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(
                  width: MediaQuery.sizeOf(context).width * 0.99,
                  height: MediaQuery.sizeOf(context).height * 0.99,
                  child: custom_widgets.FinanceDashboardWidget(
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
