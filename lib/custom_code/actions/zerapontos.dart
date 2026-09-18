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

import 'package:cloud_firestore/cloud_firestore.dart';

Future zerapontos() async {
  try {
    // Obtém referência da coleção PONTOS_POR_TECNICO
    final collectionRef =
        FirebaseFirestore.instance.collection('PONTOS_POR_TECNICO');

    // Busca todos os documentos da coleção
    final querySnapshot = await collectionRef.get();

    // Verifica se há documentos para atualizar
    if (querySnapshot.docs.isEmpty) {
      print('Nenhum documento encontrado na coleção PONTOS_POR_TECNICO');
      return;
    }

    // Atualiza o campo PONTOS para 0 em cada documento
    for (var doc in querySnapshot.docs) {
      await doc.reference.update({'PONTOS': 0});
      print('Pontos zerados para o documento: ${doc.id}');
    }

    print(
        '${querySnapshot.docs.length} documento(s) atualizado(s) - PONTOS zerados na coleção PONTOS_POR_TECNICO');
  } catch (e) {
    print('Erro ao zerar pontos: $e');
    throw Exception('Falha ao zerar pontos da coleção PONTOS_POR_TECNICO: $e');
  }
}
