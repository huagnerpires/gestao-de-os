import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'visualizar_equipamento_widget.dart' show VisualizarEquipamentoWidget;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class VisualizarEquipamentoModel
    extends FlutterFlowModel<VisualizarEquipamentoWidget> {
  ///  Local state fields for this component.

  bool confirmar = false;

  ///  State fields for stateful widgets in this component.

  final visualizarEquipamentoShortcutsFocusNode = FocusNode();

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    visualizarEquipamentoShortcutsFocusNode.dispose();
  }
}
