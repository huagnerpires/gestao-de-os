// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import '/custom_code/actions/index.dart';
import '/flutter_flow/custom_functions.dart';

Future<String> verificartxt(
  String? dropDownEQUIPAMENTO,
  String? dropDownTipo,
  String? dropDownFLUIDO,
  String? marcaText,
  String? modeloText,
  String? patrimonioText,
  String? capacidadeText,
  String? tensaoText,
  String? campo6Text,
  String? salaText,
  String? campo8Text,
) async {
  if (dropDownEQUIPAMENTO == null || dropDownEQUIPAMENTO.isEmpty) {
    return 'Por favor, selecione um equipamento';
  }

  if (dropDownTipo == null || dropDownTipo.isEmpty) {
    return 'Por favor, selecione um tipo';
  }

  if (dropDownFLUIDO == null || dropDownFLUIDO.isEmpty) {
    return 'Por favor, selecione um fluido';
  }

  if (marcaText == null || marcaText.isEmpty) {
    return 'Por favor, preencha o campo Marca';
  }

  if (modeloText == null || modeloText.isEmpty) {
    return 'Por favor, preencha o campo Modelo';
  }

  if (patrimonioText == null || patrimonioText.isEmpty) {
    return 'Por favor, preencha o campo Patrimônio';
  }

  if (capacidadeText == null || capacidadeText.isEmpty) {
    return 'Por favor, preencha o campo Capacidade';
  }

  if (tensaoText == null || tensaoText.isEmpty) {
    return 'Por favor, preencha o campo Tensão';
  }

  if (campo6Text == null || campo6Text.isEmpty) {
    return 'Por favor, preencha o campo obrigatório';
  }

  if (salaText == null || salaText.isEmpty) {
    return 'Por favor, preencha o campo Sala';
  }

  if (campo8Text == null || campo8Text.isEmpty) {
    return 'Por favor, preencha o campo obrigatório';
  }

  return 'OK';
}
