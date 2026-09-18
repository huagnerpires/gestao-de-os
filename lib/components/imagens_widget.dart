import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'imagens_model.dart';
export 'imagens_model.dart';

class ImagensWidget extends StatefulWidget {
  const ImagensWidget({super.key});

  @override
  State<ImagensWidget> createState() => _ImagensWidgetState();
}

class _ImagensWidgetState extends State<ImagensWidget> {
  late ImagensModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ImagensModel());

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
      padding: EdgeInsetsDirectional.fromSTEB(0.0, 30.0, 0.0, 40.0),
      child: Container(
        width: double.infinity,
        height: double.infinity,
        child: custom_widgets.GerenciarImagensWidget(
          width: double.infinity,
          height: double.infinity,
        ),
      ),
    );
  }
}
