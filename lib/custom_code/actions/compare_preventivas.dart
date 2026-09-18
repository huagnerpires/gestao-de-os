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

// ============================================================
// CUSTOM FUNCTION: comparePreventivas
// ============================================================
// Compara a coleção "preventivas" no Firestore com os PDFs
// armazenados no Cloud Storage e retorna os patrimônios faltantes.
//
// COMO USAR NO FLUTTERFLOW:
// 1. Vá em "Custom Code" > "Custom Functions"
// 2. Crie uma nova função chamada "comparePreventivas"
// 3. Return Type: List<String> (ou JSON conforme preferir)
// 4. Cole o código abaixo
// 5. Adicione as dependências no pubspec:
//    - firebase_storage: ^11.6.0 (ou versão compatível)
//    - cloud_firestore (já incluído no FlutterFlow)
// ============================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

/// Retorna uma lista com os patrimônios que estão na coleção
/// "preventivas" do Firestore mas NÃO possuem PDF correspondente
/// no Cloud Storage, e vice-versa.
///
/// Parâmetros:
///   [mesAno] - String opcional no formato "YYYY/MM" (ex: "2026/Fevereiro")
///              Se não informado, usa o mês/ano atual.
///   [emailPath] - Caminho do email/pasta raiz no Storage
///                 (ex: "calçados@grupodass.com.br")
///
/// Retorna um JSON string com:
///   - "faltando_pdf": patrimônios no Firestore sem PDF no Storage
///   - "faltando_firestore": PDFs no Storage sem registro no Firestore
///   - "total_preventivas": total de registros no Firestore
///   - "total_pdfs": total de PDFs no Storage
///   - "encontrados": patrimônios que possuem ambos (PDF + Firestore)

Future<String> comparePreventivas(
  String emailPath, // ex: "calçados@grupodass.com.br"
  String ano, // ex: "2026"
  String mes, // ex: "Fevereiro"
) async {
  try {
    // -------------------------------------------------------
    // 1. BUSCAR PATRIMÔNIOS DA COLEÇÃO "preventivas" NO FIRESTORE
    // -------------------------------------------------------
    final firestore = FirebaseFirestore.instance;
    final querySnapshot = await firestore
        .collection('preventivas')
        .where('mes', isEqualTo: mes)
        .where('ano', isEqualTo: ano)
        .get();

    // Extrai os valores do campo "patrimonio" de cada documento
    final Set<String> patrimoniosFirestore = {};
    for (final doc in querySnapshot.docs) {
      final data = doc.data();
      // Tenta pegar o campo "patrimonio" (ajuste o nome do campo conforme seu schema)
      final patrimonio = data['patrimonio']?.toString().trim();
      if (patrimonio != null && patrimonio.isNotEmpty) {
        patrimoniosFirestore.add(patrimonio);
      }
    }

    // -------------------------------------------------------
    // 2. LISTAR PDFs NO CLOUD STORAGE
    // -------------------------------------------------------
    final storage = FirebaseStorage.instance;
    final storagePath = '$emailPath/$ano/$mes';
    final storageRef = storage.ref().child(storagePath);

    final ListResult result = await storageRef.listAll();

    // Extrai os nomes dos arquivos sem a extensão .pdf
    final Set<String> patrimoniosStorage = {};
    for (final item in result.items) {
      final fileName = item.name; // ex: "92743.pdf"
      // Remove a extensão .pdf para obter o número do patrimônio
      final patrimonio =
          fileName.replaceAll('.pdf', '').replaceAll('.PDF', '').trim();
      if (patrimonio.isNotEmpty) {
        patrimoniosStorage.add(patrimonio);
      }
    }

    // -------------------------------------------------------
    // 3. COMPARAR E ENCONTRAR FALTANTES
    // -------------------------------------------------------

    // Patrimônios que estão no Firestore mas NÃO têm PDF no Storage
    final List<String> faltandoPdf = patrimoniosFirestore
        .where((p) => !patrimoniosStorage.contains(p))
        .toList()
      ..sort();

    // PDFs no Storage que NÃO têm registro no Firestore
    final List<String> faltandoFirestore = patrimoniosStorage
        .where((p) => !patrimoniosFirestore.contains(p))
        .toList()
      ..sort();

    // Patrimônios que possuem ambos (match perfeito)
    final List<String> encontrados = patrimoniosFirestore
        .where((p) => patrimoniosStorage.contains(p))
        .toList()
      ..sort();

    // -------------------------------------------------------
    // 4. MONTAR RESULTADO
    // -------------------------------------------------------
    final resultado = {
      'faltando_pdf': faltandoPdf,
      'faltando_firestore': faltandoFirestore,
      'encontrados': encontrados,
      'total_preventivas_firestore': patrimoniosFirestore.length,
      'total_pdfs_storage': patrimoniosStorage.length,
      'total_faltando_pdf': faltandoPdf.length,
      'total_faltando_firestore': faltandoFirestore.length,
      'total_encontrados': encontrados.length,
      'storage_path': storagePath,
    };

    // Retorna como JSON string
    return jsonEncode(resultado);
  } catch (e) {
    return jsonEncode({
      'erro': e.toString(),
      'faltando_pdf': <String>[],
      'faltando_firestore': <String>[],
      'encontrados': <String>[],
    });
  }
}

// ============================================================
// VERSÃO ALTERNATIVA - RETORNA APENAS A LISTA DE FALTANTES
// ============================================================
// Use esta versão se preferir algo mais simples que retorna
// apenas os patrimônios que não possuem PDF.
// ============================================================

Future<List<String>> getPatrimoniosSemPdf(
  String emailPath,
  String ano,
  String mes,
) async {
  try {
    final firestore = FirebaseFirestore.instance;

    // Busca preventivas no Firestore
    final querySnapshot = await firestore
        .collection('preventivas')
        .where('mes', isEqualTo: mes)
        .where('ano', isEqualTo: ano)
        .get();

    final Set<String> patrimoniosFirestore = {};
    for (final doc in querySnapshot.docs) {
      final patrimonio = doc.data()['patrimonio']?.toString().trim();
      if (patrimonio != null && patrimonio.isNotEmpty) {
        patrimoniosFirestore.add(patrimonio);
      }
    }

    // Lista PDFs no Storage
    final storage = FirebaseStorage.instance;
    final storageRef = storage.ref().child('$emailPath/$ano/$mes');
    final ListResult result = await storageRef.listAll();

    final Set<String> patrimoniosStorage = {};
    for (final item in result.items) {
      patrimoniosStorage.add(
        item.name
            .replaceAll(RegExp(r'\.pdf$', caseSensitive: false), '')
            .trim(),
      );
    }

    // Retorna apenas os faltantes
    return patrimoniosFirestore
        .where((p) => !patrimoniosStorage.contains(p))
        .toList()
      ..sort();
  } catch (e) {
    return ['ERRO: ${e.toString()}'];
  }
}

// ============================================================
// VERSÃO PARA QUERY SEM FILTRO DE MÊS/ANO
// ============================================================
// Use esta versão se a sua coleção "preventivas" não tem
// campos "mes" e "ano", e você quer comparar TODOS os
// patrimônios da coleção com os PDFs de um mês específico.
// ============================================================

Future<String> comparePreventivaSemFiltro(
  String emailPath,
  String ano,
  String mes,
  String
      campoPatrimonio, // nome do campo no Firestore, ex: "patrimonio", "numero", "cod"
) async {
  try {
    final firestore = FirebaseFirestore.instance;

    // Busca TODOS os documentos da coleção preventivas
    final querySnapshot = await firestore.collection('preventivas').get();

    final Set<String> patrimoniosFirestore = {};
    for (final doc in querySnapshot.docs) {
      final patrimonio = doc.data()[campoPatrimonio]?.toString().trim();
      if (patrimonio != null && patrimonio.isNotEmpty) {
        patrimoniosFirestore.add(patrimonio);
      }
    }

    // Lista PDFs no Storage
    final storage = FirebaseStorage.instance;
    final storageRef = storage.ref().child('$emailPath/$ano/$mes');
    final ListResult result = await storageRef.listAll();

    final Set<String> patrimoniosStorage = {};
    for (final item in result.items) {
      patrimoniosStorage.add(
        item.name
            .replaceAll(RegExp(r'\.pdf$', caseSensitive: false), '')
            .trim(),
      );
    }

    final faltandoPdf = patrimoniosFirestore
        .where((p) => !patrimoniosStorage.contains(p))
        .toList()
      ..sort();

    final faltandoFirestore = patrimoniosStorage
        .where((p) => !patrimoniosFirestore.contains(p))
        .toList()
      ..sort();

    return jsonEncode({
      'faltando_pdf': faltandoPdf,
      'faltando_firestore': faltandoFirestore,
      'total_preventivas': patrimoniosFirestore.length,
      'total_pdfs': patrimoniosStorage.length,
      'total_faltando_pdf': faltandoPdf.length,
      'total_faltando_firestore': faltandoFirestore.length,
    });
  } catch (e) {
    return jsonEncode({'erro': e.toString()});
  }
}

// ============================================================
// IMPORT NECESSÁRIO (adicione no topo do arquivo no FlutterFlow)
// ============================================================
// import 'dart:convert'; // para jsonEncode
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart';
