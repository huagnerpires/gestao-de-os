import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'ia_hps_model.dart';
export 'ia_hps_model.dart';

class IaHpsWidget extends StatefulWidget {
  const IaHpsWidget({super.key});

  @override
  State<IaHpsWidget> createState() => _IaHpsWidgetState();
}

class _IaHpsWidgetState extends State<IaHpsWidget> {
  late IaHpsModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => IaHpsModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(),
        alignment: AlignmentDirectional(0.0, -1.0),
        child: Container(
          width: MediaQuery.sizeOf(context).width * 0.99,
          height: MediaQuery.sizeOf(context).height * 0.99,
          child: custom_widgets.FirebaseAiChatWidget(
            width: MediaQuery.sizeOf(context).width * 0.99,
            height: MediaQuery.sizeOf(context).height * 0.99,
            systemInstruction: '345retyg',
            titleText: 'Assistente Hps Refrigeração',
            subtitleText: 'Inteligencia artificial  para técnicos',
          ),
        ),
      ),
    );
  }
}
