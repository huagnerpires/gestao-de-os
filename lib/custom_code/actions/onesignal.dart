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

import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:flutter/foundation.dart'
    show kIsWeb; // Importação essencial para detectar a Web

Future<void> onesignal(String? email, String? telefone, String? key,
    String? value, String? userId) async {
  // 1. TRAVA DE SEGURANÇA PARA WEB
  // Se o usuário abrir pelo site (hpsrefri.com.br), o app ignora este código
  // porque a web já está sendo gerenciada pelo script nas configurações (Custom Headers).
  if (kIsWeb) {
    print("OneSignal: Executando na Web. Ação ignorada com sucesso.");
    return; // Sai da função imediatamente sem dar erro
  }

  // 2. Inicializa o OneSignal (APENAS PARA O APLICATIVO MOBILE)
  OneSignal.initialize("7b01186f-cf76-4b5d-8354-87d83737d40c");
  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);

  // Pequeno delay para garantir inicialização
  await Future.delayed(const Duration(milliseconds: 500));

  try {
    // LÓGICA DE LOGIN / CRIAÇÃO
    if (userId != null && userId.isNotEmpty && userId != "null") {
      print("OneSignal: Executando Login para ID: $userId");
      OneSignal.login(userId);
    } else {
      print("OneSignal: ID vazio. Pulando login.");
    }

    // Adiciona Email
    if (email != null && email.isNotEmpty && email != "null") {
      print("OneSignal: Adicionando Email: $email");
      await OneSignal.User.addEmail(email);
    }

    // Adiciona Telefone
    if (telefone != null && telefone.isNotEmpty && telefone != "null") {
      print("OneSignal: Adicionando SMS: $telefone");
      await OneSignal.User.addSms(telefone);
    }

    // Adiciona Tags
    if (key != null && value != null && key.isNotEmpty && value.isNotEmpty) {
      OneSignal.User.addTagWithKey(key, value);
    }

    // Solicita permissão no celular
    await OneSignal.Notifications.requestPermission(true);
  } catch (e) {
    print("OneSignal Erro: $e");
  }
}
