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

Future<bool> updateChatCollection(String emailArgument) async {
  try {
    // Referência para a coleção "chat"
    final collection = FirebaseFirestore.instance.collection('chat');

    // Consulta para verificar documentos onde adm=false e email_cliente está preenchido
    final querySnapshot = await collection
        .where('adm', isEqualTo: false)
        .where('email_cliente', isEqualTo: emailArgument)
        .get();

    // Verifica se há documentos correspondentes
    if (querySnapshot.docs.isEmpty) {
      return false; // Nenhuma atualização realizada
    }

    // Atualiza cada documento correspondente
    for (final doc in querySnapshot.docs) {
      await doc.reference.update({
        'lida_ou_nao': true, // Atualiza o campo "lida_ou_nao" para true
      });
    }

    return true; // Sucesso
  } catch (e) {
    print('Erro ao atualizar documentos: $e');
    return false; // Falha
  }
}
