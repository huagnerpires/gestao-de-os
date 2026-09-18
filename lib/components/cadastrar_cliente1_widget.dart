import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'cadastrar_cliente1_model.dart';
export 'cadastrar_cliente1_model.dart';

class CadastrarCliente1Widget extends StatefulWidget {
  const CadastrarCliente1Widget({super.key});

  @override
  State<CadastrarCliente1Widget> createState() =>
      _CadastrarCliente1WidgetState();
}

class _CadastrarCliente1WidgetState extends State<CadastrarCliente1Widget> {
  late CadastrarCliente1Model _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CadastrarCliente1Model());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
