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

Future<List<String>> calcularRanking(int valor1, int valor2, int valor3) async {
  // Cria uma lista com os valores e seus nomes
  List<Map<String, dynamic>> valores = [
    {'valor': valor1, 'nome': 'valor1'},
    {'valor': valor2, 'nome': 'valor2'},
    {'valor': valor3, 'nome': 'valor3'},
  ];

  // Ordena a lista em ordem decrescente com base no valor
  valores.sort((a, b) => b['valor'].compareTo(a['valor']));

  // Retorna o ranking formatado como uma lista de strings
  return [
    '1º Lugar: ${valores[0]["nome"]} (${valores[0]["valor"]})',
    '2º Lugar: ${valores[1]["nome"]} (${valores[1]["valor"]})',
    '3º Lugar: ${valores[2]["nome"]} (${valores[2]["valor"]})',
  ];
}
