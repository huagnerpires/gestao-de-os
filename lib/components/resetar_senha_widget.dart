import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'resetar_senha_model.dart';
export 'resetar_senha_model.dart';

class ResetarSenhaWidget extends StatefulWidget {
  const ResetarSenhaWidget({super.key});

  @override
  State<ResetarSenhaWidget> createState() => _ResetarSenhaWidgetState();
}

class _ResetarSenhaWidgetState extends State<ResetarSenhaWidget> {
  late ResetarSenhaModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ResetarSenhaModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          child: custom_widgets.AdminResetSenhaWidget(
            width: double.infinity,
            height: double.infinity,
          ),
        ),
      ),
    );
  }
}
