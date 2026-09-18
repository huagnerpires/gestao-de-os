import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'os_custom_e_x_c_l_u_i_r_model.dart';
export 'os_custom_e_x_c_l_u_i_r_model.dart';

class OsCustomEXCLUIRWidget extends StatefulWidget {
  const OsCustomEXCLUIRWidget({
    super.key,
    required this.status,
  });

  final String? status;

  @override
  State<OsCustomEXCLUIRWidget> createState() => _OsCustomEXCLUIRWidgetState();
}

class _OsCustomEXCLUIRWidgetState extends State<OsCustomEXCLUIRWidget> {
  late OsCustomEXCLUIRModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => OsCustomEXCLUIRModel());

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
      padding: EdgeInsetsDirectional.fromSTEB(0.0, 32.0, 0.0, 40.0),
      child: Container(
        width: double.infinity,
        height: double.infinity,
        child: custom_widgets.ExcluirOsWidget(
          width: double.infinity,
          height: double.infinity,
        ),
      ),
    );
  }
}
