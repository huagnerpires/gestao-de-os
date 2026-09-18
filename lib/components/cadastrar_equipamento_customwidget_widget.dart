import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'cadastrar_equipamento_customwidget_model.dart';
export 'cadastrar_equipamento_customwidget_model.dart';

class CadastrarEquipamentoCustomwidgetWidget extends StatefulWidget {
  const CadastrarEquipamentoCustomwidgetWidget({super.key});

  @override
  State<CadastrarEquipamentoCustomwidgetWidget> createState() =>
      _CadastrarEquipamentoCustomwidgetWidgetState();
}

class _CadastrarEquipamentoCustomwidgetWidgetState
    extends State<CadastrarEquipamentoCustomwidgetWidget> {
  late CadastrarEquipamentoCustomwidgetModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model =
        createModel(context, () => CadastrarEquipamentoCustomwidgetModel());

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
      child: custom_widgets.CadastrarEquipamentoWidget(
        width: double.infinity,
        height: double.infinity,
        imgbbApiKey: '69b75a9be0857deaa943296636aca90a',
      ),
    );
  }
}
