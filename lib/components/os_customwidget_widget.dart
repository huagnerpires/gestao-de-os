import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'os_customwidget_model.dart';
export 'os_customwidget_model.dart';

class OsCustomwidgetWidget extends StatefulWidget {
  const OsCustomwidgetWidget({
    super.key,
    required this.status,
  });

  final String? status;

  @override
  State<OsCustomwidgetWidget> createState() => _OsCustomwidgetWidgetState();
}

class _OsCustomwidgetWidgetState extends State<OsCustomwidgetWidget> {
  late OsCustomwidgetModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => OsCustomwidgetModel());

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
      padding: EdgeInsets.only(
        top: 8.0,
        bottom: 8.0 + MediaQuery.of(context).padding.bottom,
      ),
      child: Container(
        width: double.infinity,
        height: double.infinity,
        child: custom_widgets.OsWidget(
          width: double.infinity,
          height: double.infinity,
          statusFiltro: widget!.status!,
        ),
      ),
    );
  }
}
