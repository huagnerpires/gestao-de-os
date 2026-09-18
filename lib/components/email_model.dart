import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/components/b_u_s_c_a_r_c_l_i_e_n_t_e_real_notificao_widget.dart';
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import 'email_widget.dart' show EmailWidget;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class EmailModel extends FlutterFlowModel<EmailWidget> {
  ///  State fields for stateful widgets in this component.

  // State field(s) for patrimonio widget.
  FocusNode? patrimonioFocusNode;
  TextEditingController? patrimonioTextController;
  String? Function(BuildContext, String?)? patrimonioTextControllerValidator;
  // Stores action output result for [Firestore Query - Query a collection] action in patrimonio widget.
  EquipamentosEmpresaRecord? patttt;
  // State field(s) for DropDown widget.
  String? dropDownValue;
  FormFieldController<String>? dropDownValueController;
  // State field(s) for assunto widget.
  FocusNode? assuntoFocusNode;
  TextEditingController? assuntoTextController;
  String? Function(BuildContext, String?)? assuntoTextControllerValidator;
  // State field(s) for mensagem widget.
  FocusNode? mensagemFocusNode;
  TextEditingController? mensagemTextController;
  String? Function(BuildContext, String?)? mensagemTextControllerValidator;
  // Stores action output result for [Custom Action - enviarEmail] action in Button widget.
  bool? respostaenviaremail;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    patrimonioFocusNode?.dispose();
    patrimonioTextController?.dispose();

    assuntoFocusNode?.dispose();
    assuntoTextController?.dispose();

    mensagemFocusNode?.dispose();
    mensagemTextController?.dispose();
  }
}
