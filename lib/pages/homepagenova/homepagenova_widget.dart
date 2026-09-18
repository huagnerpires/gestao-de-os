import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/custom_code/widgets/index.dart' as custom_widgets;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'homepagenova_model.dart';
export 'homepagenova_model.dart';

class HomepagenovaWidget extends StatefulWidget {
  const HomepagenovaWidget({super.key});

  static String routeName = 'homepagenova';
  static String routePath = '/homepagenova';

  @override
  State<HomepagenovaWidget> createState() => _HomepagenovaWidgetState();
}

class _HomepagenovaWidgetState extends State<HomepagenovaWidget> {
  late HomepagenovaModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HomepagenovaModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: const Color(0xFF0B0F17),
        body: SafeArea(
          child: custom_widgets.HomePageCustomWidget(
            width: double.infinity,
            height: double.infinity,
          ),
        ),
      ),
    );
  }
}
