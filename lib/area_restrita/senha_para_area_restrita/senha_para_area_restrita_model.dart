import '/components/escolha_novo_custom_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'senha_para_area_restrita_widget.dart' show SenhaParaAreaRestritaWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class SenhaParaAreaRestritaModel
    extends FlutterFlowModel<SenhaParaAreaRestritaWidget> {
  ///  State fields for stateful widgets in this component.

  // State field(s) for TextFielSENHAPONTOSetsat widget.
  FocusNode? textFielSENHAPONTOSetsatFocusNode;
  TextEditingController? textFielSENHAPONTOSetsatTextController;
  late bool textFielSENHAPONTOSetsatVisibility;
  String? Function(BuildContext, String?)?
      textFielSENHAPONTOSetsatTextControllerValidator;
  // State field(s) for TextFielSENHAPONTOS widget.
  FocusNode? textFielSENHAPONTOSFocusNode;
  TextEditingController? textFielSENHAPONTOSTextController;
  late bool textFielSENHAPONTOSVisibility;
  String? Function(BuildContext, String?)?
      textFielSENHAPONTOSTextControllerValidator;

  @override
  void initState(BuildContext context) {
    textFielSENHAPONTOSetsatVisibility = false;
    textFielSENHAPONTOSVisibility = false;
  }

  @override
  void dispose() {
    textFielSENHAPONTOSetsatFocusNode?.dispose();
    textFielSENHAPONTOSetsatTextController?.dispose();

    textFielSENHAPONTOSFocusNode?.dispose();
    textFielSENHAPONTOSTextController?.dispose();
  }
}
