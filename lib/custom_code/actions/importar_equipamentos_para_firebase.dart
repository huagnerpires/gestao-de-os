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

/// CUSTOM ACTION - IMPORTAR EQUIPAMENTOS Coleção: EQUIPAMENTOS_EMPRESA Todos
/// os campos em MAIÚSCULAS Lista de 11 equipamentos já incluída no código NÃO
/// PRECISA PASSAR PARÂMETROS!
Future<String> importarEquipamentosParaFirebase() async {
  // Referência para a coleção EQUIPAMENTOS_EMPRESA
  final CollectionReference equipamentosCollection =
      FirebaseFirestore.instance.collection('EQUIPAMENTOS_EMPRESA');

  // LISTA DE EQUIPAMENTOS HARDCODED
  final List<Map<String, dynamic>> equipamentos = [
    {
      "EQUIPAMENTO": "CÂMARA DE CONGELAMENTO",
      "PATRIMONIO": "70153",
      "MARCA": "DANFOSS",
      "TENSÃO": "380V/220V",
      "FLUIDO": "R404A",
      "SETOR": "REFETÓRIO",
      "SALA": "COZINHA",
      "RESPONSAVEL": "GEANE",
      "EMAIL": "hpsrefri@gmail.com"
    },
    {
      "EQUIPAMENTO": "CÂMARA DE CARNE",
      "PATRIMONIO": "70769",
      "MARCA": "DANFOSS",
      "TENSÃO": "380V",
      "FLUIDO": "R404A",
      "SETOR": "REFETÓRIO",
      "SALA": "COZINHA",
      "RESPONSAVEL": "GEANE",
      "EMAIL": "hpsrefri@gmail.com"
    },
    {
      "EQUIPAMENTO": "CÂMARA DE SOBREMESAS",
      "PATRIMONIO": "70781",
      "MARCA": "DANFOSS",
      "TENSÃO": "380V",
      "FLUIDO": "R404",
      "SETOR": "REFETÓRIO",
      "SALA": "COZINHA",
      "RESPONSAVEL": "GEANE",
      "EMAIL": "hpsrefri@gmail.com"
    },
    {
      "EQUIPAMENTO": "CÂMARA DE HORTIFRUTI",
      "PATRIMONIO": "70127",
      "MARCA": "DANFOSS",
      "TENSÃO": "380V",
      "FLUIDO": "R404",
      "SETOR": "REFETÓRIO",
      "SALA": "COZINHA",
      "RESPONSAVEL": "GEANE",
      "EMAIL": "hpsrefri@gmail.com"
    },
    {
      "EQUIPAMENTO": "PREPARO DE SOBREMESAS",
      "PATRIMONIO": "70768",
      "MARCA": "DANFOSS",
      "TENSÃO": "380V",
      "FLUIDO": "R404A",
      "SETOR": "REFETÓRIO",
      "SALA": "COZINHA",
      "RESPONSAVEL": "GEANE",
      "EMAIL": "hpsrefri@gmail.com"
    },
    {
      "EQUIPAMENTO": "PRÉ-PREPARO DE CARNES",
      "PATRIMONIO": "70872",
      "MARCA": "DANFOSS",
      "TENSÃO": "380V",
      "FLUIDO": "R404A",
      "SETOR": "REFETÓRIO",
      "SALA": "COZINHA",
      "RESPONSAVEL": "GEANE",
      "EMAIL": "hpsrefri@gmail.com"
    },
    {
      "EQUIPAMENTO": "CÂMARA LIXO",
      "PATRIMONIO": "70873",
      "MARCA": "DANFOSS",
      "TENSÃO": "380V",
      "FLUIDO": "R404A",
      "SETOR": "REFETÓRIO",
      "SALA": "COZINHA",
      "RESPONSAVEL": "GEANE",
      "EMAIL": "hpsrefri@gmail.com"
    },
    {
      "EQUIPAMENTO": "PASSTHROUGH",
      "PATRIMONIO": "32050",
      "MARCA": "ELGIN",
      "TENSÃO": "220V",
      "FLUIDO": "R404A",
      "SETOR": "REFETÓRIO",
      "SALA": "COZINHA",
      "RESPONSAVEL": "GEANE",
      "EMAIL": "hpsrefri@gmail.com"
    },
    {
      "EQUIPAMENTO": "GELADEIRA INDUSTRIAL",
      "PATRIMONIO": "89971",
      "MARCA": "ELGIN",
      "TENSÃO": "220V",
      "FLUIDO": "R22",
      "SETOR": "REFETÓRIO",
      "SALA": "COZINHA",
      "RESPONSAVEL": "GEANE",
      "EMAIL": "hpsrefri@gmail.com"
    },
    {
      "EQUIPAMENTO": "GELADEIRA INDUSTRIAL",
      "PATRIMONIO": "89970",
      "MARCA": "ELGIN",
      "TENSÃO": "220V",
      "FLUIDO": "R22",
      "SETOR": "REFETÓRIO",
      "SALA": "COZINHA",
      "RESPONSAVEL": "GEANE",
      "EMAIL": "hpsrefri@gmail.com"
    },
    {
      "EQUIPAMENTO": "GELADEIRA INDUSTRIAL",
      "PATRIMONIO": "31973",
      "MARCA": "ELGIN",
      "TENSÃO": "220V",
      "FLUIDO": "R22",
      "SETOR": "REFETÓRIO",
      "SALA": "COZINHA",
      "RESPONSAVEL": "GEANE",
      "EMAIL": "hpsrefri@gmail.com"
    }
  ];

  int adicionados = 0;
  int duplicatas = 0;
  int erros = 0;

  List<String> equipamentosAdicionados = [];
  List<String> equipamentosDuplicados = [];

  try {
    for (var equipamento in equipamentos) {
      String patrimonio = equipamento['PATRIMONIO'] ?? '';
      String nomeEquipamento = equipamento['EQUIPAMENTO'] ?? 'Sem nome';

      try {
        // Verifica se já existe equipamento com esse patrimônio
        QuerySnapshot query = await equipamentosCollection
            .where('PATRIMONIO', isEqualTo: patrimonio)
            .limit(1)
            .get();

        if (query.docs.isEmpty) {
          // NÃO EXISTE - ADICIONA COM TODOS OS CAMPOS EM MAIÚSCULAS
          await equipamentosCollection.add({
            'EQUIPAMENTO': equipamento['EQUIPAMENTO'] ?? '',
            'PATRIMONIO': patrimonio,
            'MARCA': equipamento['MARCA'] ?? '',
            'TENSÃO': equipamento['TENSÃO'] ?? '',
            'FLUIDO': equipamento['FLUIDO'] ?? '',
            'SETOR': equipamento['SETOR'] ?? '',
            'SALA': equipamento['SALA'] ?? '',
            'RESPONSAVEL': equipamento['RESPONSAVEL'] ?? '',
            'EMAIL': equipamento['EMAIL'] ?? '',
            'DATA_CADASTRO': FieldValue.serverTimestamp(),
          });

          adicionados++;
          equipamentosAdicionados.add('$nomeEquipamento (Pat: $patrimonio)');
          print('✓ Adicionado: $nomeEquipamento');
        } else {
          // JÁ EXISTE
          duplicatas++;
          equipamentosDuplicados.add('$nomeEquipamento (Pat: $patrimonio)');
          print('⚠ Duplicata: $nomeEquipamento');
        }
      } catch (e) {
        erros++;
        print('✗ Erro: $nomeEquipamento - $e');
      }
    }

    // RELATÓRIO FINAL
    String relatorio = '''
════════════════════════════════════════
📊 IMPORTAÇÃO CONCLUÍDA
════════════════════════════════════════

📋 RESUMO:
• Total: ${equipamentos.length} equipamentos
• ✓ Adicionados: $adicionados
• ⚠ Duplicatas: $duplicatas
• ✗ Erros: $erros

''';

    if (adicionados > 0) {
      relatorio += '''
✓ EQUIPAMENTOS ADICIONADOS ($adicionados):
${equipamentosAdicionados.map((e) => '  • $e').join('\n')}

''';
    }

    if (duplicatas > 0) {
      relatorio += '''
⚠ EQUIPAMENTOS JÁ EXISTENTES ($duplicatas):
${equipamentosDuplicados.map((e) => '  • $e').join('\n')}

''';
    }

    relatorio += '''
🗂️ Coleção: EQUIPAMENTOS_EMPRESA
📅 Data: ${DateTime.now().toString().split('.')[0]}
════════════════════════════════════════
''';

    print(relatorio);
    return relatorio;
  } catch (e) {
    String erro = 'Erro geral ao importar: $e';
    print(erro);
    return erro;
  }
}
