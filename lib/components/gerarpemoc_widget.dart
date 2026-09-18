import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'gerarpemoc_model.dart';
export 'gerarpemoc_model.dart';

class GerarpemocWidget extends StatefulWidget {
  const GerarpemocWidget({super.key});

  @override
  State<GerarpemocWidget> createState() => _GerarpemocWidgetState();
}

class _GerarpemocWidgetState extends State<GerarpemocWidget> {
  late GerarpemocModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => GerarpemocModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional(0.0, 0.0),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 800.0,
        ),
        decoration: BoxDecoration(),
        child: Align(
          alignment: AlignmentDirectional(0.0, 0.0),
          child: Container(
            width: double.infinity,
            height: double.infinity,
            child: custom_widgets.EmitirPmocWidget(
              width: double.infinity,
              height: double.infinity,
              onCancelar: () async {},
            ),
          ),
        ),
      ),
    );
  }
}
