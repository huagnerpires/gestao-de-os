import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'imagem_lista_vazia_widget.dart' show ImagemListaVaziaWidget;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ImagemListaVaziaModel extends FlutterFlowModel<ImagemListaVaziaWidget> {
  ///  State fields for stateful widgets in this component.

  // State field(s) for TextFieldEDITAROS widget.
  FocusNode? textFieldEDITAROSFocusNode;
  TextEditingController? textFieldEDITAROSTextController;
  String? Function(BuildContext, String?)?
      textFieldEDITAROSTextControllerValidator;
  // Stores action output result for [Firestore Query - Query a collection] action in Button widget.
  ServicosrealizadosRecord? obterdadosparaeditar;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    textFieldEDITAROSFocusNode?.dispose();
    textFieldEDITAROSTextController?.dispose();
  }
}
