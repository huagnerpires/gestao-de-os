import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'pdf_que_falta_model.dart';
export 'pdf_que_falta_model.dart';

/// Create a component buscar email
///
class PdfQueFaltaWidget extends StatefulWidget {
  const PdfQueFaltaWidget({super.key});

  @override
  State<PdfQueFaltaWidget> createState() => _PdfQueFaltaWidgetState();
}

class _PdfQueFaltaWidgetState extends State<PdfQueFaltaWidget> {
  late PdfQueFaltaModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PdfQueFaltaModel());

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
        width: double.infinity,
        height: double.infinity,
        child: custom_widgets.SincronizarPDFsWidget(
          width: double.infinity,
          height: double.infinity,
        ),
      ),
    );
  }
}
