import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/upload_data.dart';
import 'dart:ui';
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'usuario_editar_widget.dart' show UsuarioEditarWidget;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:provider/provider.dart';

class UsuarioEditarModel extends FlutterFlowModel<UsuarioEditarWidget> {
  ///  State fields for stateful widgets in this component.

  bool isDataUploading_uploadDataQsf = false;
  FFUploadedFile uploadedLocalFile_uploadDataQsf =
      FFUploadedFile(bytes: Uint8List.fromList([]), originalFilename: '');

  // State field(s) for Checkbox widget.
  bool? checkboxValue;
  // State field(s) for TextFieldNOME widget.
  FocusNode? textFieldNOMEFocusNode;
  TextEditingController? textFieldNOMETextController;
  String? Function(BuildContext, String?)? textFieldNOMETextControllerValidator;
  // State field(s) for TextFieldCPF widget.
  FocusNode? textFieldCPFFocusNode1;
  TextEditingController? textFieldCPFTextController1;
  late MaskTextInputFormatter textFieldCPFMask1;
  String? Function(BuildContext, String?)? textFieldCPFTextController1Validator;
  // State field(s) for TextFieldCPF widget.
  FocusNode? textFieldCPFFocusNode2;
  TextEditingController? textFieldCPFTextController2;
  late MaskTextInputFormatter textFieldCPFMask2;
  String? Function(BuildContext, String?)? textFieldCPFTextController2Validator;
  // State field(s) for TextFieldcontrato widget.
  FocusNode? textFieldcontratoFocusNode;
  TextEditingController? textFieldcontratoTextController;
  String? Function(BuildContext, String?)?
      textFieldcontratoTextControllerValidator;
  // State field(s) for TextFieldEMAIL widget.
  FocusNode? textFieldEMAILFocusNode;
  TextEditingController? textFieldEMAILTextController;
  String? Function(BuildContext, String?)?
      textFieldEMAILTextControllerValidator;
  // State field(s) for TextFieldENDERECO widget.
  FocusNode? textFieldENDERECOFocusNode;
  TextEditingController? textFieldENDERECOTextController;
  String? Function(BuildContext, String?)?
      textFieldENDERECOTextControllerValidator;
  // State field(s) for TextFieldNUM widget.
  FocusNode? textFieldNUMFocusNode;
  TextEditingController? textFieldNUMTextController;
  String? Function(BuildContext, String?)? textFieldNUMTextControllerValidator;
  // State field(s) for TextFieldBAIRRO widget.
  FocusNode? textFieldBAIRROFocusNode;
  TextEditingController? textFieldBAIRROTextController;
  String? Function(BuildContext, String?)?
      textFieldBAIRROTextControllerValidator;
  // State field(s) for TextFieldCITY widget.
  FocusNode? textFieldCITYFocusNode;
  TextEditingController? textFieldCITYTextController;
  String? Function(BuildContext, String?)? textFieldCITYTextControllerValidator;
  // State field(s) for TextFieldPHONE widget.
  FocusNode? textFieldPHONEFocusNode;
  TextEditingController? textFieldPHONETextController;
  late MaskTextInputFormatter textFieldPHONEMask;
  String? Function(BuildContext, String?)?
      textFieldPHONETextControllerValidator;
  // State field(s) for TextFieldSENHA widget.
  FocusNode? textFieldSENHAFocusNode;
  TextEditingController? textFieldSENHATextController;
  late bool textFieldSENHAVisibility;
  String? Function(BuildContext, String?)?
      textFieldSENHATextControllerValidator;
  // State field(s) for TextFieldCONFIRMASENHA widget.
  FocusNode? textFieldCONFIRMASENHAFocusNode;
  TextEditingController? textFieldCONFIRMASENHATextController;
  late bool textFieldCONFIRMASENHAVisibility;
  String? Function(BuildContext, String?)?
      textFieldCONFIRMASENHATextControllerValidator;
  // Stores action output result for [Firestore Query - Query a collection] action in Button widget.
  UsuariosRecord? emailexiste;
  // Stores action output result for [Backend Call - Create Document] action in Button widget.
  UsuariosRecord? joj;

  @override
  void initState(BuildContext context) {
    textFieldSENHAVisibility = false;
    textFieldCONFIRMASENHAVisibility = false;
  }

  @override
  void dispose() {
    textFieldNOMEFocusNode?.dispose();
    textFieldNOMETextController?.dispose();

    textFieldCPFFocusNode1?.dispose();
    textFieldCPFTextController1?.dispose();

    textFieldCPFFocusNode2?.dispose();
    textFieldCPFTextController2?.dispose();

    textFieldcontratoFocusNode?.dispose();
    textFieldcontratoTextController?.dispose();

    textFieldEMAILFocusNode?.dispose();
    textFieldEMAILTextController?.dispose();

    textFieldENDERECOFocusNode?.dispose();
    textFieldENDERECOTextController?.dispose();

    textFieldNUMFocusNode?.dispose();
    textFieldNUMTextController?.dispose();

    textFieldBAIRROFocusNode?.dispose();
    textFieldBAIRROTextController?.dispose();

    textFieldCITYFocusNode?.dispose();
    textFieldCITYTextController?.dispose();

    textFieldPHONEFocusNode?.dispose();
    textFieldPHONETextController?.dispose();

    textFieldSENHAFocusNode?.dispose();
    textFieldSENHATextController?.dispose();

    textFieldCONFIRMASENHAFocusNode?.dispose();
    textFieldCONFIRMASENHATextController?.dispose();
  }
}
