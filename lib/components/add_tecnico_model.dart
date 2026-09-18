import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/upload_data.dart';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import 'add_tecnico_widget.dart' show AddTecnicoWidget;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class AddTecnicoModel extends FlutterFlowModel<AddTecnicoWidget> {
  ///  Local state fields for this component.

  FFUploadedFile? teste;

  ///  State fields for stateful widgets in this component.

  final addTecnicoShortcutsFocusNode = FocusNode();
  bool isDataUploading_uploadData64 = false;
  FFUploadedFile uploadedLocalFile_uploadData64 =
      FFUploadedFile(bytes: Uint8List.fromList([]), originalFilename: '');

  // Stores action output result for [Custom Action - uploadedFileToBase64] action in Container widget.
  String? imagem69;
  // Stores action output result for [Custom Action - uploadImageToImgBB] action in Container widget.
  String? linkImagem;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode;
  TextEditingController? textController;
  String? Function(BuildContext, String?)? textControllerValidator;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    addTecnicoShortcutsFocusNode.dispose();
    textFieldFocusNode?.dispose();
    textController?.dispose();
  }
}
