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

Future<String?> filtrarSomarPontos(
  String? dados,
  String? nomeEquipamento,
  int? pontosPorTecnico,
) async {
  String filtrarSomarPontos(
      List<Map<String, dynamic>> dados, String nomeEquipamento) {
    // 1. Filtrar os dados pelo equipamento
    final filtrados = dados
        .where((doc) => doc['nome_equipamento'] == nomeEquipamento)
        .toList();

    // 2. Criar um mapa para armazenar os pontos por técnico
    final Map<String, double> pontosPorTecnico = {};

    for (var doc in filtrados) {
      final tecnico = doc['nome_tecnico'] as String;
      final pontos = (doc['pontos'] as num).toDouble();

      if (pontosPorTecnico.containsKey(tecnico)) {
        pontosPorTecnico[tecnico] = pontosPorTecnico[tecnico]! + pontos;
      } else {
        pontosPorTecnico[tecnico] = pontos;
      }
    }

    // 3. Gerar o texto formatado
    final resultado = pontosPorTecnico.entries
        .map(
            (entry) => '${entry.key}: ${entry.value.toStringAsFixed(2)} pontos')
        .join('\n');

    return resultado;
  }
}
