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

Future adicionarCampoContrato() async {
  // 1. Referência para a coleção exata que você mostrou na imagem
  final CollectionReference collectionRef =
      FirebaseFirestore.instance.collection('EQUIPAMENTOS_EMPRESA');

  // 2. Busca todos os documentos existentes nessa coleção
  final QuerySnapshot snapshot = await collectionRef.get();

  // 3. Cria um lote (batch) para gravações. Isso é mais rápido e econômico que atualizar um por um.
  WriteBatch batch = FirebaseFirestore.instance.batch();
  int count = 0;

  // 4. Loop através de cada documento encontrado
  for (final doc in snapshot.docs) {
    // Adiciona a instrução de atualização ao lote
    // 'merge: true' garante que não vamos apagar os outros campos, apenas adicionar/atualizar este.
    batch.set(
        doc.reference,
        {
          'CONTRATO': true, // O campo booleano solicitado
        },
        SetOptions(merge: true));

    count++;

    // O Firestore limita batches a 500 operações.
    // Se atingirmos 400 (margem de segurança), enviamos e limpamos o lote.
    if (count >= 400) {
      await batch.commit();
      batch = FirebaseFirestore.instance.batch();
      count = 0;
    }
  }

  // 5. Envia as operações restantes que sobraram no lote final
  if (count > 0) {
    await batch.commit();
  }

  // Opcional: Print no console para debug
  print('Atualização concluída com sucesso!');
}
