import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'enviar_notas_model.dart';
export 'enviar_notas_model.dart';

class EnviarNotasWidget extends StatefulWidget {
  const EnviarNotasWidget({super.key});

  @override
  State<EnviarNotasWidget> createState() => _EnviarNotasWidgetState();
}

class _EnviarNotasWidgetState extends State<EnviarNotasWidget> {
  late EnviarNotasModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => EnviarNotasModel());

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
      child: custom_widgets.UploadModerno(
        width: double.infinity,
        height: double.infinity,
        larguraEmail: 1400.0,
      ),
    );
  }
}
