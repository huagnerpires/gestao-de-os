import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'cadastrar_novo_sem_erro_model.dart';
export 'cadastrar_novo_sem_erro_model.dart';

class CadastrarNovoSemErroWidget extends StatefulWidget {
  const CadastrarNovoSemErroWidget({
    super.key,
    this.confirmado,
  });

  final double? confirmado;

  @override
  State<CadastrarNovoSemErroWidget> createState() =>
      _CadastrarNovoSemErroWidgetState();
}

class _CadastrarNovoSemErroWidgetState
    extends State<CadastrarNovoSemErroWidget> {
  late CadastrarNovoSemErroModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CadastrarNovoSemErroModel());

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
      padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 40.0),
      child: Container(
        width: double.infinity,
        height: double.infinity,
        child: custom_widgets.CadastrarOsWidget(
          width: double.infinity,
          height: double.infinity,
        ),
      ),
    );
  }
}
