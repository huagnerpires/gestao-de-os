import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'email_nova_model.dart';
export 'email_nova_model.dart';

class EmailNovaWidget extends StatefulWidget {
  const EmailNovaWidget({super.key});

  @override
  State<EmailNovaWidget> createState() => _EmailNovaWidgetState();
}

class _EmailNovaWidgetState extends State<EmailNovaWidget> {
  late EmailNovaModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => EmailNovaModel());

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
      decoration: BoxDecoration(),
      child: Container(
        width: double.infinity,
        height: double.infinity,
        child: custom_widgets.EnviarRelatorioEmailWidget(
          width: double.infinity,
          height: double.infinity,
          onCancelar: () async {},
        ),
      ),
    );
  }
}
