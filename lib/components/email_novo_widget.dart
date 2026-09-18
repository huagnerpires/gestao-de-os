import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'email_novo_model.dart';
export 'email_novo_model.dart';

class EmailNovoWidget extends StatefulWidget {
  const EmailNovoWidget({super.key});

  @override
  State<EmailNovoWidget> createState() => _EmailNovoWidgetState();
}

class _EmailNovoWidgetState extends State<EmailNovoWidget> {
  late EmailNovoModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => EmailNovoModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 50.0),
      child: Container(
        width: double.infinity,
        height: double.infinity,
        child: custom_widgets.EnviarEmailWidget(
          width: double.infinity,
          height: double.infinity,
          onCancelar: () async {},
        ),
      ),
    );
  }
}
