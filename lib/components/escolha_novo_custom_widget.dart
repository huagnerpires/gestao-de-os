import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'escolha_novo_custom_model.dart';
export 'escolha_novo_custom_model.dart';

class EscolhaNovoCustomWidget extends StatefulWidget {
  const EscolhaNovoCustomWidget({super.key});

  @override
  State<EscolhaNovoCustomWidget> createState() =>
      _EscolhaNovoCustomWidgetState();
}

class _EscolhaNovoCustomWidgetState extends State<EscolhaNovoCustomWidget> {
  late EscolhaNovoCustomModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => EscolhaNovoCustomModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.expand(
      child: custom_widgets.EscolhaAtualCustomWidget(),
    );
  }
}
