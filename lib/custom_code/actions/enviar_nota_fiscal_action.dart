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

// A LINHA PROBLEMÁTICA FOI REMOVIDA DAQUI

import 'package:firebase_storage/firebase_storage.dart';

Future<String> enviarNotaFiscalAction(
  FFUploadedFile file,
  String email,
  String? ano,
  String? mes,
) async {
  // Verifica se o arquivo é válido
  if (file.bytes == null) {
    return 'Erro: Arquivo inválido ou corrompido.';
  }

  try {
    // 1. Define Ano e Mês (Usa data atual se os parâmetros vierem vazios)
    final now = DateTime.now();

    String anoRef = (ano != null && ano.isNotEmpty) ? ano : now.year.toString();

    String mesRef;
    if (mes != null && mes.isNotEmpty) {
      // Formata para primeira letra maiúscula (ex: fevereiro -> Fevereiro)
      mesRef = mes[0].toUpperCase() + mes.substring(1).toLowerCase();
    } else {
      // Lista de fallback para o mês atual
      const meses = [
        'Janeiro',
        'Fevereiro',
        'Março',
        'Abril',
        'Maio',
        'Junho',
        'Julho',
        'Agosto',
        'Setembro',
        'Outubro',
        'Novembro',
        'Dezembro'
      ];
      mesRef = meses[now.month - 1];
    }

    // 2. Monta o caminho exato: email/Ano/Mês/NOTAS FISCAIS/NomeArquivo
    // Ex: calcados@grupodass.com.br/2026/Fevereiro/NOTAS FISCAIS/nota01.pdf
    String storagePath = '$email/$anoRef/$mesRef/NOTAS FISCAIS/${file.name}';

    // 3. Executa o Upload para o Firebase Storage
    final ref = FirebaseStorage.instance.ref().child(storagePath);
    await ref.putData(file.bytes!);

    // 4. Retorna a URL de download (sucesso)
    String downloadUrl = await ref.getDownloadURL();
    return downloadUrl;
  } catch (e) {
    // Retorna mensagem de erro para tratar no FlutterFlow se necessário
    return 'Erro ao enviar: $e';
  }
}
