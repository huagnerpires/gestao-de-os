import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'gerenciar_tecnicos_sheet_model.dart';
export 'gerenciar_tecnicos_sheet_model.dart';

/// Create a component  gerenciar tecnicos
///
class GerenciarTecnicosSheetWidget extends StatefulWidget {
  const GerenciarTecnicosSheetWidget({super.key});

  @override
  State<GerenciarTecnicosSheetWidget> createState() =>
      _GerenciarTecnicosSheetWidgetState();
}

class _GerenciarTecnicosSheetWidgetState
    extends State<GerenciarTecnicosSheetWidget> {
  late GerenciarTecnicosSheetModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => GerenciarTecnicosSheetModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Colors.transparent,
      ),
      child: Container(
        width: double.infinity,
        height: double.infinity,
        child: custom_widgets.GerenciarTecnicosWidget(
          width: double.infinity,
          height: double.infinity,
          imgbbApiKey: '69b75a9be0857deaa943296636aca90a',
        ),
      ),
    );
  }
}
