import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'i_a_h_p_s_copy_model.dart';
export 'i_a_h_p_s_copy_model.dart';

class IAHPSCopyWidget extends StatefulWidget {
  const IAHPSCopyWidget({super.key});

  @override
  State<IAHPSCopyWidget> createState() => _IAHPSCopyWidgetState();
}

class _IAHPSCopyWidgetState extends State<IAHPSCopyWidget> {
  late IAHPSCopyModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => IAHPSCopyModel());

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
      ),
    );
  }
}
