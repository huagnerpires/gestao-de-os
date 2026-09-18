import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'usuario_novo_model.dart';
export 'usuario_novo_model.dart';

/// Create a component  cadastrar novo usuario
///
class UsuarioNovoWidget extends StatefulWidget {
  const UsuarioNovoWidget({super.key});

  @override
  State<UsuarioNovoWidget> createState() => _UsuarioNovoWidgetState();
}

class _UsuarioNovoWidgetState extends State<UsuarioNovoWidget> {
  late UsuarioNovoModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => UsuarioNovoModel());

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
      decoration: BoxDecoration(
        color: Colors.transparent,
      ),
      child: Container(
        width: double.infinity,
        height: double.infinity,
        child: custom_widgets.GerenciarUsuariosWidget(
          width: double.infinity,
          height: double.infinity,
          imgbbApiKey: '69b75a9be0857deaa943296636aca90a',
        ),
      ),
    );
  }
}
