import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'relatorio_financeiro_model.dart';
export 'relatorio_financeiro_model.dart';

class RelatorioFinanceiroWidget extends StatefulWidget {
  const RelatorioFinanceiroWidget({super.key});

  @override
  State<RelatorioFinanceiroWidget> createState() =>
      _RelatorioFinanceiroWidgetState();
}

class _RelatorioFinanceiroWidgetState extends State<RelatorioFinanceiroWidget> {
  late RelatorioFinanceiroModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => RelatorioFinanceiroModel());

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
      child: custom_widgets.RelatorioCard(
        width: double.infinity,
        height: double.infinity,
        email: 'calçaos@grupodass.com.br',
        mes: 'fevereiro',
        ano: '2026',
      ),
    );
  }
}
