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

import 'dart:convert';

import 'package:http/http.dart' as http;

Future<String?> uploadImageToImgBB(String apiKey, String imagemBase64) async {
  final String url =
      'https://api.imgbb.com/1/upload?key=$apiKey'; // Sem o expiration

  try {
    // Prepara o corpo da requisição

    final Map<String, String> formData = {
      'image': imagemBase64, // Aqui o imagemPath é agora o Base64 diretamente
    };

    // Envia a requisição POST

    final response = await http.post(
      Uri.parse(url),
      body: formData,
    );

    // Verifica a resposta

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final imageUrl = responseData['data']?['url']?.toString();
      if (imageUrl != null && imageUrl.trim().isNotEmpty) {
        return imageUrl;
      }
      return null;
    } else {
      return null;
    }
  } catch (e) {
    return null;
  }
}
