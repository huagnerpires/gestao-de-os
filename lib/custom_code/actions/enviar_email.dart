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

Future<bool> enviarEmail(
  String toEmail,
  String subject,
  String message,
) async {
  // 🔐 API KEY BREVO
  const String apiKey =
      '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';

  const String senderEmail = 'equipe@hpsrefri.com.br';
  const String senderName = 'Hps Refrigeração';

  final Uri url = Uri.parse(
    'https://api.brevo.com/v3/smtp/email',
  );

  // 📧 HTML DO EMAIL
  final String htmlBody = '''
<!DOCTYPE html>
<html lang="pt-BR">
<head>
  <meta charset="UTF-8">
  <title>$subject</title>
</head>

<body style="margin:0;padding:0;background-color:#f4f6f8;font-family:Arial,Helvetica,sans-serif;">
  <table width="100%" cellpadding="0" cellspacing="0" style="padding:6px;">
    <tr>
      <td align="center">

        <!-- CONTAINER -->
        <table width="800" cellpadding="0" cellspacing="0"
          style="background:#ffffff;border-radius:14px;overflow:hidden;max-width:100%;">

          <!-- TOPO COM IMAGEM FULL -->
          <tr>
            <td style="padding:0;margin:0;">
              <img
                src="https://i.ibb.co/dsHkVn3x/Gemini-Generated-Image-apxs3aapxs3aapxs.png"
                alt="HPS Refrigeração"
                style="
                  width:100%;
                  max-width:800px;
                  height:auto;
                  display:block;
                  border:0;
                  outline:none;
                  text-decoration:none;
                "
              />
            </td>
          </tr>

          <!-- CONTEÚDO -->
          <tr>
            <td style="padding:22px;color:#333333;font-size:15px;line-height:1.6;">
              $message

              <br><br>
              Atenciosamente,<br>
              <strong>Equipe Hps Refrigeração</strong><br>
              <span style="font-size:13px;color:#555555;">
                Especialistas em soluções de climatização
              </span>
            </td>
          </tr>

          <!-- RODAPÉ -->
          <tr>
            <td style="background:#f1f5f9;padding:10px;text-align:center;font-size:12px;color:#64748b;">
              © 2026 Hps Refrigeração · Todos os direitos reservados<br>
              Esta é uma mensagem automática, por favor não responda.
            </td>
          </tr>

        </table>

      </td>
    </tr>
  </table>
</body>
</html>
''';

  final Map<String, dynamic> body = {
    "sender": {"name": senderName, "email": senderEmail},
    "replyTo": {"name": senderName, "email": senderEmail},
    "to": [
      {"email": toEmail}
    ],
    "subject": subject,
    "htmlContent": htmlBody,
  };

  final response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'api-key': apiKey,
    },
    body: jsonEncode(body),
  );

  if (response.statusCode == 200 || response.statusCode == 201) {
    return true;
  } else {
    throw Exception(
      'Erro ao enviar email: ${response.statusCode} - ${response.body}',
    );
  }
}
