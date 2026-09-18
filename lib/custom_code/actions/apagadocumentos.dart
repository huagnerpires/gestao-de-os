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

Future apagadocumentos() async {
  try {
    // Obtém referência da coleção SERVICOSREALIZADOS
    final collectionRef =
        FirebaseFirestore.instance.collection('SERVICOSREALIZADOS');

    // --- FILTRO APLICADO ---
    // Busca apenas documentos onde STATUS é exatamente igual a "CONCLUÍDA"
    final querySnapshot =
        await collectionRef.where('STATUS', isEqualTo: 'CONCLUÍDA').get();

    // Verifica se há documentos para deletar
    if (querySnapshot.docs.isEmpty) {
      print('Nenhum serviço com status "CONCLUÍDA" foi encontrado.');
      return;
    }

    // Deleta cada documento encontrado
    for (var doc in querySnapshot.docs) {
      await doc.reference.delete();
      print('Documento deletado: ${doc.id}');
    }

    print(
        '${querySnapshot.docs.length} documento(s) com status "CONCLUÍDA" foram deletados com sucesso.');
  } catch (e) {
    print('Erro ao deletar documentos: $e');
    throw Exception('Falha ao deletar coleção SERVICOSREALIZADOS: $e');
  }
}
