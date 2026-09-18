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

/// ADICIONAR SETOR QUE FALTA NO RELATÓRIO
Future syncSetorPreventivas() async {
  final firestore = FirebaseFirestore.instance;

  try {
    // 1. Busca todos os documentos da coleção EQUIPAMENTOS_EMPRESA
    final equipamentosSnapshot =
        await firestore.collection('EQUIPAMENTOS_EMPRESA').get();

    // 2. Cria um mapa (dicionário) para busca rápida: PATRIMONIO -> SETOR
    // Isso evita ter que pesquisar no banco de dados para cada item, economizando muitas leituras.
    Map<String, String> patrimonioSetorMap = {};
    for (var doc in equipamentosSnapshot.docs) {
      final data = doc.data();
      if (data.containsKey('PATRIMONIO') && data.containsKey('SETOR')) {
        // Salva o setor atrelado àquele patrimônio
        patrimonioSetorMap[data['PATRIMONIO'].toString()] =
            data['SETOR'].toString();
      }
    }

    // 3. Busca todos os documentos da coleção PREVENTIVAS
    final preventivasSnapshot = await firestore.collection('PREVENTIVAS').get();

    // 4. Prepara a atualização em lote (Firestore permite no máximo 500 operações por lote)
    WriteBatch batch = firestore.batch();
    int operationCount = 0;

    for (var prevDoc in preventivasSnapshot.docs) {
      final prevData = prevDoc.data();

      // Verifica se a preventiva tem um patrimônio cadastrado
      if (prevData.containsKey('PATRIMONIO')) {
        String patrimonioPreventiva = prevData['PATRIMONIO'].toString();

        // Se o mapa de equipamentos contém esse patrimônio (ou seja, deu "match")
        if (patrimonioSetorMap.containsKey(patrimonioPreventiva)) {
          // Adiciona/Atualiza o campo SETOR nesta preventiva específica
          batch.update(prevDoc.reference, {
            'SETOR': patrimonioSetorMap[patrimonioPreventiva],
          });

          operationCount++;

          // Se atingir o limite de 500 operações do Firebase, envia o lote e cria um novo
          if (operationCount == 500) {
            await batch.commit();
            batch = firestore.batch();
            operationCount = 0;
          }
        }
      }
    }

    // 5. Envia qualquer operação restante que não tenha completado um lote de 500
    if (operationCount > 0) {
      await batch.commit();
    }

    print("Sincronização concluída com sucesso!");
  } catch (e) {
    print("Erro ao sincronizar coleções: $e");
  }
}
