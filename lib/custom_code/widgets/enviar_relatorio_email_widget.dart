// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'index.dart'; // Imports other custom widgets

import '/custom_code/widgets/index.dart';

import '/custom_code/actions/index.dart';

import '/flutter_flow/custom_functions.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;

// ─────────────────────────────────────────────────────────────────────────────
//  CONSTANTES
// ─────────────────────────────────────────────────────────────────────────────
// NOTA: _kBrevoApiKey removida — a chave é buscada dinamicamente do Firestore
//       no campo 'apibrevo' do documento hpsrefri@gmail.com em USUARIOS.
const _kSenderEmail = 'equipe@hpsrefri.com.br';
const _kSenderName = 'HPS Refrigeração';
const _kBannerUrl =
    'https://firebasestorage.googleapis.com/v0/b/h-p-s-modificado-emdcp0.appspot.com/o/Gemini_Generated_Image_2xpdsd2xpdsd2xpd%20(1).png?alt=media&token=be3e052e-a0b8-4e8c-8151-b9365b507ed5';
const _kLogoUrl = 'https://i.ibb.co/VpqNsxXt/Imagem1.jpg';
const _kAssinaturaUrl =
    'https://i.ibb.co/hRvtGhbK/3b004d07-a4a9-4568-9d8b-5abc281dbcee.png';
const _kImgTopoUrl = 'https://i.ibb.co/v481FdX8/9491f9c633ca.png';

const _kVerde = Color(0xFF1A3C34);

// ── OneSignal ─────────────────────────────────────────────────────────────────
const _kOsAppId = '7b01186f-cf76-4b5d-8354-87d83737d40c';
const _kOsApiKey = 'ZTdlNjIwZWItMjEyMC00M2RhLWJlZmYtMzc2NTBmNzNmMDdj';
const _kOsChannel = '577bba44-d1bf-4ac9-9d11-20d89e09a61a';
const _kEmailHPS = 'hpsrefri@gmail.com';

const List<String> _ptMonths = [
  '',
  'JANEIRO',
  'FEVEREIRO',
  'MARÇO',
  'ABRIL',
  'MAIO',
  'JUNHO',
  'JULHO',
  'AGOSTO',
  'SETEMBRO',
  'OUTUBRO',
  'NOVEMBRO',
  'DEZEMBRO',
];

// ─────────────────────────────────────────────────────────────────────────────
//  HTTP helpers
// ─────────────────────────────────────────────────────────────────────────────
Map<String, String> _safeHeaders() =>
    kIsWeb ? {} : {'User-Agent': 'Mozilla/5.0'};

Future<http.Response> _safeGet(String? url,
    {Duration timeout = const Duration(seconds: 8)}) async {
  if (url == null || url.isEmpty || !url.startsWith('http')) {
    return http.Response('', 400);
  }
  try {
    return await http
        .get(Uri.parse(url), headers: _safeHeaders())
        .timeout(timeout);
  } catch (_) {
    return http.Response('', 400);
  }
}

Future<http.Response> _safeGetWithRetry(String? url) async {
  if (url == null || url.isEmpty || !url.startsWith('http')) {
    return http.Response('', 400);
  }
  final timeouts = [
    const Duration(seconds: 10),
    const Duration(seconds: 18),
    const Duration(seconds: 25),
  ];
  for (int attempt = 0; attempt < timeouts.length; attempt++) {
    try {
      final resp = await http
          .get(Uri.parse(url), headers: _safeHeaders())
          .timeout(timeouts[attempt]);
      if (resp.statusCode == 200 && resp.bodyBytes.isNotEmpty) return resp;
    } catch (_) {}
    if (attempt < timeouts.length - 1) {
      await Future.delayed(const Duration(milliseconds: 400));
    }
  }
  return http.Response('', 400);
}

// ─────────────────────────────────────────────────────────────────────────────
//  Cache de assets PDF
// ─────────────────────────────────────────────────────────────────────────────
pw.ImageProvider? _cachedLogo;
pw.ImageProvider? _cachedAssinatura;
pw.ImageProvider? _cachedImgTopo;
Future<void>? _assetsFuture;

Future<void> _ensureAssets() {
  _assetsFuture ??= _loadAssets();
  return _assetsFuture!;
}

Future<void> _loadAssets() async {
  try {
    final r = await _safeGet(_kLogoUrl);
    if (r.statusCode == 200) _cachedLogo = pw.MemoryImage(r.bodyBytes);
  } catch (_) {}
  try {
    final r = await _safeGet(_kAssinaturaUrl);
    if (r.statusCode == 200) _cachedAssinatura = pw.MemoryImage(r.bodyBytes);
  } catch (_) {}
  try {
    final r = await _safeGet(_kImgTopoUrl);
    if (r.statusCode == 200) _cachedImgTopo = pw.MemoryImage(r.bodyBytes);
  } catch (_) {}
}

// ─────────────────────────────────────────────────────────────────────────────
//  Normalização de texto
// ─────────────────────────────────────────────────────────────────────────────
String _normalizarTexto(String texto) {
  const comAcento = 'àáâãäåæçèéêëìíîïðñòóôõöùúûüýÿÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖÙÚÛÜÝ';
  const semAcento =
      'aaaaaaaceeeeiiiidnoooooouuuuyyAAAAAAACEEEEIIIIDNOOOOOUUUUY';
  var resultado = texto.toLowerCase().trim();
  for (int i = 0; i < comAcento.length; i++) {
    resultado = resultado.replaceAll(comAcento[i], semAcento[i]);
  }
  return resultado.replaceAll(RegExp(r'\s+'), ' ');
}

bool _mesIgual(String docMes, String filtroMes) =>
    _normalizarTexto(docMes) == _normalizarTexto(filtroMes);

String _normPat(dynamic v) =>
    (v ?? '').toString().toLowerCase().trim().replaceAll(RegExp(r'\s+'), ' ');

// ─────────────────────────────────────────────────────────────────────────────
//  Envio de email via Brevo
//  A apiKey é buscada do campo 'apibrevo' do documento hpsrefri@gmail.com
//  na coleção USUARIOS — nunca hardcoded.
// ─────────────────────────────────────────────────────────────────────────────
Future<void> _sendEmail({
  required List<String> toEmails,
  required String subject,
  required String htmlBody,
}) async {
  // ── Busca apibrevo do Firestore ──────────────────────────────
  String apiKey = '';
  try {
    final snap = await FirebaseFirestore.instance
        .collection('USUARIOS')
        .where('email', isEqualTo: 'hpsrefri@gmail.com')
        .limit(1)
        .get();
    if (snap.docs.isNotEmpty) {
      apiKey = (snap.docs.first.data()['apibrevo'] ?? '').toString().trim();
    }
  } catch (e) {
    debugPrint('Erro ao buscar apibrevo: $e');
  }
  if (apiKey.isEmpty) throw Exception('apibrevo não configurado');

  final body = <String, dynamic>{
    'sender': {'name': _kSenderName, 'email': _kSenderEmail},
    'replyTo': {'name': _kSenderName, 'email': _kSenderEmail},
    'to': toEmails.map((e) => {'email': e}).toList(),
    'subject': subject,
    'htmlContent': htmlBody,
  };

  final resp = await http.post(
    Uri.parse('https://api.brevo.com/v3/smtp/email'),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'api-key': apiKey,
    },
    body: jsonEncode(body),
  );
  if (resp.statusCode != 200 && resp.statusCode != 201) {
    throw Exception('Brevo ${resp.statusCode}: ${resp.body}');
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Push OneSignal
// ─────────────────────────────────────────────────────────────────────────────
Future<void> _enviarPushOneSignal({
  required String email,
  required String titulo,
  required String mensagem,
}) async {
  if (email.isEmpty) return;
  try {
    await http.post(
      Uri.parse('https://onesignal.com/api/v1/notifications'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Basic $_kOsApiKey',
      },
      body: jsonEncode({
        'app_id': _kOsAppId,
        'filters': [
          {'field': 'tag', 'key': 'Email', 'relation': '=', 'value': email},
        ],
        'android_channel_id': _kOsChannel,
        'headings': {'en': titulo},
        'contents': {'en': mensagem},
        'priority': 10,
      }),
    );
  } catch (e) {
    debugPrint('OneSignal erro: $e');
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Notificação Firebase
// ─────────────────────────────────────────────────────────────────────────────
Future<void> _criarNotificacaoFirebase({
  required String email,
  required String mes,
  required String ano,
  required int totalPreventivas,
  required int totalPendencias,
}) async {
  if (email.isEmpty) return;
  try {
    final msgPend = totalPendencias > 0
        ? ' $totalPendencias pendência${totalPendencias != 1 ? "s" : ""} encontrada${totalPendencias != 1 ? "s" : ""}.'
        : '';
    final mesIdx =
        _ptMonths.indexWhere((m) => m.toUpperCase() == mes.toUpperCase());
    final mesNum = mesIdx > 0 ? mesIdx : DateTime.now().month;

    await FirebaseFirestore.instance.collection('NOTIFICACAO').add({
      'email': email,
      'titulo': '📊 Relatório de Preventivas Disponível',
      'mensagem': 'Relatório de manutenções preventivas de $mes/$ano com '
          '$totalPreventivas preventiva${totalPreventivas != 1 ? "s" : ""} '
          'foi enviado por e-mail.$msgPend',
      'tipo': 'preventiva',
      'visto': false,
      'data': Timestamp.now(),
      'mes': mes,
      'ano': int.tryParse(ano) ?? DateTime.now().year,
      'status': 'enviado',
      'os': '',
    });
  } catch (e) {
    debugPrint('Erro ao criar notificação Firebase: $e');
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  HTML do email
// ─────────────────────────────────────────────────────────────────────────────
String _buildHtmlEmail({
  required String nomeCliente,
  required String mes,
  required String ano,
  required int total,
  required String downloadUrl,
  String? downloadUrlPendencias,
  int totalPendencias = 0,
}) {
  final blocoPreventivas = '''
<table width="100%" cellpadding="0" cellspacing="0" border="0"
       style="background:#f0fdf4;border-left:4px solid #1A3C34;border-radius:0 8px 8px 0;margin-bottom:16px;">
  <tr>
    <td style="padding:14px 18px;font-size:14px;color:#1A3C34;line-height:1.6;">
      📋 &nbsp;<strong>$total equipamento${total != 1 ? 's' : ''}</strong>
      com manutenção realizada no período.
    </td>
  </tr>
</table>
<div style="text-align:center;margin-bottom:16px;">
  <a href="$downloadUrl" target="_blank"
     style="background-color:#1A3C34;color:#ffffff;text-decoration:none;
            padding:12px 24px;border-radius:6px;font-weight:bold;
            font-size:14px;display:inline-block;">
    📥 Baixar Relatório de Preventivas em PDF
  </a>
</div>
''';

  final blocoPendencias = downloadUrlPendencias != null && totalPendencias > 0
      ? '''
<table width="100%" cellpadding="0" cellspacing="0" border="0"
       style="background:#fff5f5;border-left:4px solid #c0392b;border-radius:0 8px 8px 0;margin-bottom:16px;">
  <tr>
    <td style="padding:14px 18px;font-size:14px;color:#c0392b;line-height:1.6;">
      ⚠️ &nbsp;<strong>$totalPendencias equipamento${totalPendencias != 1 ? 's' : ''}</strong>
      com manutenção pendente no período.
    </td>
  </tr>
</table>
<div style="text-align:center;margin-bottom:16px;">
  <a href="$downloadUrlPendencias" target="_blank"
     style="background-color:#c0392b;color:#ffffff;text-decoration:none;
            padding:12px 24px;border-radius:6px;font-weight:bold;
            font-size:14px;display:inline-block;">
    ⚠️ Baixar Relatório de Pendências em PDF
  </a>
</div>
'''
      : '';

  return '''
<!DOCTYPE html>
<html lang="pt-BR">
<head><meta charset="UTF-8"><title>Relatório de Manutenções</title></head>
<body style="margin:0;padding:0;background-color:#f4f6f8;font-family:Arial,Helvetica,sans-serif;">
  <table width="100%" cellpadding="0" cellspacing="0" border="0"
         style="background-color:#f4f6f8;padding:20px 0;">
    <tr><td align="center">
      <table width="600" cellpadding="0" cellspacing="0" border="0"
             style="background:#ffffff;border-radius:12px;overflow:hidden;
                    max-width:1400px;width:100%;">
        <tr>
          <td style="padding:0;margin:0;line-height:0;">
            <img src="$_kBannerUrl" alt="HPS Refrigeração" width="600"
                 style="display:block;width:100%;max-width:1400px;height:auto;border:0;"/>
          </td>
        </tr>
        <tr>
          <td style="background-color:#1A3C34;padding:12px 24px;">
            <span style="background:#ffffff20;color:#ffffff;font-size:11px;
                         font-weight:bold;padding:4px 10px;border-radius:20px;">
              Relatório Automático
            </span>
          </td>
        </tr>
        <tr>
          <td style="padding:28px;color:#333333;font-size:15px;line-height:1.7;">
            <p style="margin:0 0 16px 0;">Prezados,</p>
            <p style="margin:0 0 16px 0;">
              O <strong>Relatório de Manutenções Preventivas</strong>
              referente ao período de <strong>$mes / $ano</strong>
              ${nomeCliente.isNotEmpty ? 'para <strong>$nomeCliente</strong>' : ''}
              já está disponível.
            </p>
            $blocoPreventivas
            $blocoPendencias
          </td>
        </tr>
        <tr>
          <td style="padding:0 28px;">
            <hr style="border:none;border-top:1px solid #e8ecf0;margin:0;">
          </td>
        </tr>
        <tr>
          <td style="padding:20px 28px;">
            <table cellpadding="0" cellspacing="0" border="0">
              <tr>
                <td style="width:44px;vertical-align:top;">
                  <div style="width:40px;height:40px;background:#1A3C34;
                              border-radius:50%;text-align:center;line-height:40px;">
                    <span style="color:#ffffff;font-size:18px;font-weight:bold;">H</span>
                  </div>
                </td>
                <td style="padding-left:12px;vertical-align:top;">
                  <span style="font-size:15px;font-weight:bold;color:#1A3C34;">
                    Huagner Pires
                  </span><br>
                  <span style="font-size:13px;color:#555555;">
                    Especialista em Refrigeração
                  </span><br>
                  <span style="font-size:12px;color:#888888;">hpsrefri.com.br</span>
                </td>
              </tr>
            </table>
          </td>
        </tr>
        <tr>
          <td style="background:#f1f5f9;padding:14px 28px;text-align:center;
                     font-size:12px;color:#94a3b8;border-top:1px solid #e2e8f0;">
            &copy; 2026 HPS Refrigeração &middot; Todos os direitos reservados<br>
            <span style="font-size:11px;">
              Esta é uma mensagem automática, por favor não responda diretamente.
            </span>
          </td>
        </tr>
      </table>
    </td></tr>
  </table>
</body>
</html>
''';
}

// ─────────────────────────────────────────────────────────────────────────────
//  Busca de pendências
// ─────────────────────────────────────────────────────────────────────────────
Future<List<Map<String, dynamic>>> _buscarPendenciasParaPdf({
  required String emailCliente,
  required String mes,
  required String ano,
}) async {
  final db = FirebaseFirestore.instance;
  final int? anoFiltro = int.tryParse(ano);
  final String mesFiltroRaw = mes.trim();

  final equipDocs = (await db
          .collection('EQUIPAMENTOS_EMPRESA')
          .where('CONTRATO', isEqualTo: true)
          .where('EMAIL', isEqualTo: emailCliente)
          .get())
      .docs;

  final Map<String, Map<String, dynamic>> equipPorPat = {};
  for (final doc in equipDocs) {
    final d = doc.data();
    final pat = _normPat(d['PATRIMONIO']);
    if (pat.isNotEmpty) equipPorPat[pat] = d;
  }

  if (equipPorPat.isEmpty) return [];

  final pendDocsAll = (await db
          .collection('PENDENCIAS')
          .where('emailPrincipal', isEqualTo: emailCliente)
          .get())
      .docs;

  final List<Map<String, dynamic>> resultado = [];

  for (final doc in pendDocsAll) {
    final d = doc.data();

    if (anoFiltro != null && mesFiltroRaw.isNotEmpty) {
      bool dentroDoFiltro = false;

      final tsVisita = d['timestampVisita'];
      if (tsVisita != null && tsVisita is Timestamp) {
        final dt = tsVisita.toDate();
        final mesDoc = _ptMonths[dt.month];
        if (dt.year == anoFiltro && _mesIgual(mesDoc, mesFiltroRaw)) {
          dentroDoFiltro = true;
        }
      }

      if (!dentroDoFiltro) {
        final tsCriado = d['criadoEm'];
        if (tsCriado != null && tsCriado is Timestamp) {
          final dt = tsCriado.toDate();
          final mesDoc = _ptMonths[dt.month];
          if (dt.year == anoFiltro && _mesIgual(mesDoc, mesFiltroRaw)) {
            dentroDoFiltro = true;
          }
        }
      }

      if (!dentroDoFiltro) continue;
    }

    final patPend = _normPat(d['patrimonio']);
    if (patPend.isEmpty || !equipPorPat.containsKey(patPend)) continue;

    final eq = equipPorPat[patPend]!;
    resultado.add({
      'EQUIPAMENTO':
          eq['EQUIPAMENTO']?.toString() ?? d['equipamento']?.toString() ?? '',
      'MODELO': eq['MODELO']?.toString() ?? d['modelo']?.toString() ?? '',
      'SALA': eq['SALA']?.toString() ?? d['sala']?.toString() ?? '',
      'PATRIMONIO':
          eq['PATRIMONIO']?.toString() ?? d['patrimonio']?.toString() ?? '',
      'SETOR': eq['SETOR']?.toString() ?? d['setor']?.toString() ?? '',
      'MOTIVO': d['motivo']?.toString() ?? '',
      'STATUS': d['status']?.toString() ?? 'pendente',
      'TENTATIVAS': d['tentativas']?.toString() ?? '',
      'RESPONSAVEL': d['responsavel']?.toString() ?? '',
      'DATA_VISITA': d['dataVisitaFormatada']?.toString() ?? '',
      'HORARIO_VISITA': d['horarioVisitaFormatado']?.toString() ?? '',
    });
  }

  return resultado;
}

// ─────────────────────────────────────────────────────────────────────────────
//  Geração do PDF de Pendências
// ─────────────────────────────────────────────────────────────────────────────
Future<Uint8List> _gerarPdfPendencias({
  required List<Map<String, dynamic>> pendencias,
  required String nomeCliente,
  required String mes,
  required String ano,
  required void Function(double, String) onProgress,
}) async {
  onProgress(0.1, 'Carregando assets para pendências...');
  await _ensureAssets();

  onProgress(0.5, 'Montando PDF de pendências...');

  final pdf = pw.Document();
  final localImgTopo = _cachedImgTopo;
  final localAssinatura = _cachedAssinatura;

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(14),
      footer: (ctx) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            pw.Divider(thickness: 0.5, color: PdfColors.grey400),
            pw.SizedBox(height: 3),
            pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        if (localAssinatura != null)
                          pw.Container(
                              width: 150,
                              height: 50,
                              child: pw.Image(localAssinatura,
                                  fit: pw.BoxFit.contain))
                        else
                          pw.SizedBox(height: 20),
                        pw.Container(
                            width: 150, height: 0.5, color: PdfColors.black),
                        pw.SizedBox(height: 2),
                        pw.Text('HPS REFRIGERAÇÃO',
                            style: pw.TextStyle(
                                fontSize: 8, fontWeight: pw.FontWeight.bold)),
                        pw.Text('CNPJ: 28.340.152/0001-52',
                            style: const pw.TextStyle(fontSize: 7)),
                      ]),
                  pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        pw.SizedBox(height: 20),
                        pw.Container(
                            width: 150, height: 0.5, color: PdfColors.black),
                        pw.SizedBox(height: 2),
                        pw.Text(
                            nomeCliente.isNotEmpty ? nomeCliente : 'CLIENTE',
                            style: pw.TextStyle(
                                fontSize: 8, fontWeight: pw.FontWeight.bold)),
                      ]),
                ]),
            pw.SizedBox(height: 3),
            pw.Center(
                child: pw.Text(
                    'Tel: (77) 98819-4630 / 98861-2447 - www.hpsrefri.com.br',
                    style: const pw.TextStyle(fontSize: 7))),
          ]),
      build: (ctx) => [
        if (localImgTopo != null) ...[
          pw.Container(
              width: double.infinity,
              height: 220,
              child: pw.Image(localImgTopo, fit: pw.BoxFit.fill)),
          pw.SizedBox(height: 8),
        ],
        pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
          pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
            pw.Text('RELATÓRIO DE PENDÊNCIAS',
                style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.red700)),
            if (nomeCliente.isNotEmpty)
              pw.Text(nomeCliente,
                  style: const pw.TextStyle(
                      fontSize: 9, color: PdfColors.grey700)),
            if (mes.isNotEmpty || ano.isNotEmpty)
              pw.Text('Período: $mes / $ano',
                  style: const pw.TextStyle(
                      fontSize: 9, color: PdfColors.grey700)),
          ]),
          pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.end, children: [
            pw.Text(
                '${pendencias.length} '
                'equipamento${pendencias.length != 1 ? 's' : ''} '
                'pendente${pendencias.length != 1 ? 's' : ''}',
                style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.red700)),
            pw.Text(
                'Gerado em: '
                '${DateTime.now().day.toString().padLeft(2, '0')}/'
                '${DateTime.now().month.toString().padLeft(2, '0')}/'
                '${DateTime.now().year}',
                style:
                    const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
          ]),
        ]),
        pw.SizedBox(height: 4),
        pw.Divider(thickness: 1, color: PdfColors.red200),
        pw.SizedBox(height: 4),
        pw.Container(
          color: PdfColors.red700,
          padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          child: pw.Row(children: [
            pw.Expanded(
                flex: 1,
                child: pw.Text('#',
                    style: pw.TextStyle(
                        fontSize: 7,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white))),
            pw.Expanded(
                flex: 3,
                child: pw.Text('EQUIPAMENTO',
                    style: pw.TextStyle(
                        fontSize: 7,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white))),
            pw.Expanded(
                flex: 2,
                child: pw.Text('MODELO',
                    style: pw.TextStyle(
                        fontSize: 7,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white))),
            pw.Expanded(
                flex: 2,
                child: pw.Text('LOCALIZAÇÃO',
                    style: pw.TextStyle(
                        fontSize: 7,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white))),
            pw.Expanded(
                flex: 2,
                child: pw.Text('PATRIMÔNIO',
                    style: pw.TextStyle(
                        fontSize: 7,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white))),
            pw.Expanded(
                flex: 3,
                child: pw.Text('SETOR',
                    style: pw.TextStyle(
                        fontSize: 7,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white))),
            pw.Expanded(
                flex: 3,
                child: pw.Text('RESPONSÁVEL',
                    style: pw.TextStyle(
                        fontSize: 7,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white))),
            pw.Expanded(
                flex: 2,
                child: pw.Text('MOTIVO',
                    style: pw.TextStyle(
                        fontSize: 7,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white))),
            pw.Expanded(
                flex: 2,
                child: pw.Text('DATA/HORA',
                    style: pw.TextStyle(
                        fontSize: 7,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white))),
          ]),
        ),
        pw.Table(
          border: pw.TableBorder(
            left: const pw.BorderSide(width: 0.5, color: PdfColors.grey300),
            right: const pw.BorderSide(width: 0.5, color: PdfColors.grey300),
            bottom: const pw.BorderSide(width: 0.5, color: PdfColors.grey300),
            horizontalInside:
                const pw.BorderSide(width: 0.5, color: PdfColors.grey200),
            verticalInside:
                const pw.BorderSide(width: 0.5, color: PdfColors.grey200),
          ),
          columnWidths: const {
            0: pw.FlexColumnWidth(1),
            1: pw.FlexColumnWidth(3),
            2: pw.FlexColumnWidth(2),
            3: pw.FlexColumnWidth(2),
            4: pw.FlexColumnWidth(2),
            5: pw.FlexColumnWidth(3),
            6: pw.FlexColumnWidth(3),
            7: pw.FlexColumnWidth(2),
            8: pw.FlexColumnWidth(2),
          },
          children: pendencias.asMap().entries.map((entry) {
            final i = entry.key;
            final item = entry.value;
            final isEven = i % 2 == 0;
            final dataHora = (item['DATA_VISITA'] ?? '').isNotEmpty
                ? '${item['DATA_VISITA']}'
                    '${(item['HORARIO_VISITA'] ?? '').isNotEmpty ? ' ${item['HORARIO_VISITA']}' : ''}'
                : '-';
            return pw.TableRow(
              decoration: pw.BoxDecoration(
                  color: isEven ? PdfColors.grey50 : PdfColors.white),
              children: [
                pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text('${i + 1}',
                        style: const pw.TextStyle(
                            fontSize: 7, color: PdfColors.grey600))),
                pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text(item['EQUIPAMENTO']?.toString() ?? '-',
                        style: pw.TextStyle(
                            fontSize: 7, fontWeight: pw.FontWeight.bold))),
                pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text(item['MODELO']?.toString() ?? '-',
                        style: const pw.TextStyle(fontSize: 7))),
                pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text(item['SALA']?.toString() ?? '-',
                        style: const pw.TextStyle(fontSize: 7))),
                pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text(item['PATRIMONIO']?.toString() ?? '-',
                        style: pw.TextStyle(
                            fontSize: 7,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.red700))),
                pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text(item['SETOR']?.toString() ?? '-',
                        style: const pw.TextStyle(fontSize: 7))),
                pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text(item['RESPONSAVEL']?.toString() ?? '-',
                        style: const pw.TextStyle(fontSize: 7))),
                pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text(item['MOTIVO']?.toString() ?? '-',
                        style: const pw.TextStyle(fontSize: 7))),
                pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text(dataHora,
                        style: const pw.TextStyle(fontSize: 7))),
              ],
            );
          }).toList(),
        ),
        pw.SizedBox(height: 16),
        pw.Container(
          padding: const pw.EdgeInsets.all(8),
          decoration: pw.BoxDecoration(
              color: PdfColors.red50,
              border: pw.Border.all(color: PdfColors.red200, width: 0.5)),
          child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Total de equipamentos com pendência:',
                    style: pw.TextStyle(
                        fontSize: 8, fontWeight: pw.FontWeight.bold)),
                pw.Text(
                    '${pendencias.length} '
                    'equipamento${pendencias.length != 1 ? 's' : ''}',
                    style: pw.TextStyle(
                        fontSize: 8,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.red700)),
              ]),
        ),
      ],
    ),
  );

  onProgress(0.85, 'Finalizando PDF de pendências...');
  final bytes = await pdf.save();
  if (bytes.isEmpty) throw Exception('PDF de pendências está vazio');
  onProgress(1.0, 'Concluído!');
  return Uint8List.fromList(bytes);
}

// ─────────────────────────────────────────────────────────────────────────────
//  Geração de PDF de preventivas
// ─────────────────────────────────────────────────────────────────────────────
Future<Uint8List> _gerarPdfRelatorio({
  required List<Map<String, dynamic>> preventivas,
  required Map<String, dynamic> dadosCliente,
  required String mes,
  required String ano,
  required void Function(double, String) onProgress,
}) async {
  onProgress(0.05, 'Carregando assets...');
  await _ensureAssets();

  final nomeCliente =
      dadosCliente['display_name']?.toString().toUpperCase() ?? '';
  final cnpjCliente =
      (dadosCliente['CNPJ'] ?? dadosCliente['cnpj'] ?? '').toString();

  pw.ImageProvider? logoCliente;
  final photoUrl = dadosCliente['photo_url']?.toString().trim();
  if (photoUrl != null && photoUrl.startsWith('http')) {
    final r = await _safeGet(photoUrl);
    if (r.statusCode == 200) logoCliente = pw.MemoryImage(r.bodyBytes);
  }

  onProgress(0.15, 'Buscando imagens dos equipamentos...');

  final patrimonios =
      preventivas.map((p) => p['PATRIMONIO']?.toString() ?? '').toList();

  final imgEvapFutures = patrimonios.map((pat) async {
    if (pat.isEmpty) return null;
    try {
      final snap = await FirebaseFirestore.instance
          .collection('IMAGENS')
          .where('PATRIMONIO', isEqualTo: pat)
          .limit(1)
          .get();
      if (snap.docs.isEmpty) return null;
      return snap.docs.first.data()['IMAGEM']?.toString().trim();
    } catch (_) {
      return null;
    }
  });

  final urlsEvap = await Future.wait(imgEvapFutures);

  final urlsTermo = preventivas.map((p) {
    for (final k in ['IMAGEM', 'THAGEM', 'TMAGEM', 'FOTO', 'foto', 'imagem']) {
      final v = p[k]?.toString().trim();
      if (v != null && v.isNotEmpty && v.startsWith('http')) return v;
    }
    return null;
  }).toList();

  onProgress(0.25, 'Baixando imagens...');

  final resEvap = await Future.wait(
    urlsEvap.map((u) => _safeGet(u, timeout: const Duration(seconds: 12))),
  );

  final resTermo = <http.Response>[];
  for (int i = 0; i < urlsTermo.length; i++) {
    final resp = await _safeGetWithRetry(urlsTermo[i]);
    resTermo.add(resp);
  }

  onProgress(0.40, 'Montando PDF...');

  final pdf = pw.Document();

  for (int i = 0; i < preventivas.length; i++) {
    final data = preventivas[i];
    final patrimonio = patrimonios[i];

    onProgress(
      0.40 + 0.30 * (i / preventivas.length),
      'Página ${i + 1}/${preventivas.length} · $patrimonio',
    );

    pw.ImageProvider? imgEvap, imgTermo;
    if (resEvap[i].statusCode == 200 && resEvap[i].bodyBytes.isNotEmpty) {
      imgEvap = pw.MemoryImage(resEvap[i].bodyBytes);
    }
    if (resTermo[i].statusCode == 200 && resTermo[i].bodyBytes.isNotEmpty) {
      imgTermo = pw.MemoryImage(resTermo[i].bodyBytes);
    }

    String dataInicio = '';
    final ts = data['datacadastro'] ?? data['DATADAMANUTENCAO'];
    if (ts != null && ts is Timestamp) {
      final d = ts.toDate();
      dataInicio =
          '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
    }

    pdf.addPage(_buildPdfPage(
      data: data,
      patrimonio: patrimonio,
      dataInicio: dataInicio,
      observacao: data['OBSERVACAO']?.toString().trim() ?? '',
      logoEmpresa: _cachedLogo,
      assinatura: _cachedAssinatura,
      logoCliente: logoCliente,
      imgEvap: imgEvap,
      imgTermo: imgTermo,
      nomeCliente: nomeCliente,
      cnpjCliente: cnpjCliente,
    ));
  }

  onProgress(0.72, 'Finalizando PDF...');
  final bytes = await pdf.save();
  if (bytes.isEmpty) throw Exception('PDF gerado está vazio');
  return Uint8List.fromList(bytes);
}

// ─────────────────────────────────────────────────────────────────────────────
//  _buildPdfPage
// ─────────────────────────────────────────────────────────────────────────────
pw.Page _buildPdfPage({
  required Map<String, dynamic> data,
  required String patrimonio,
  required String dataInicio,
  required String observacao,
  pw.ImageProvider? logoEmpresa,
  pw.ImageProvider? assinatura,
  pw.ImageProvider? logoCliente,
  pw.ImageProvider? imgEvap,
  pw.ImageProvider? imgTermo,
  required String nomeCliente,
  required String cnpjCliente,
}) {
  const cBlue = PdfColor.fromInt(0xFF64B5F6);
  const cBlueDk = PdfColor.fromInt(0xFF42A5F5);
  const cBlueSoft = PdfColor.fromInt(0xFFE3F2FD);
  const cGrey100 = PdfColor.fromInt(0xFFEEF2F7);
  const cGrey200 = PdfColor.fromInt(0xFFE2E8F0);
  const cGrey600 = PdfColor.fromInt(0xFF64748B);
  const cGrey800 = PdfColor.fromInt(0xFF1E293B);
  const cOk = PdfColor.fromInt(0xFF16A34A);
  const cOkBg = PdfColor.fromInt(0xFFDCFCE7);

  pw.TextStyle bold(double sz, {PdfColor? c}) => pw.TextStyle(
      fontSize: sz, fontWeight: pw.FontWeight.bold, color: c ?? cGrey800);
  pw.TextStyle norm(double sz, {PdfColor? c}) =>
      pw.TextStyle(fontSize: sz, color: c ?? cGrey800);

  pw.Widget secHdr(String t) => pw.Container(
        width: double.infinity,
        color: cBlue,
        padding: const pw.EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        child: pw.Text(t,
            style: pw.TextStyle(
                fontSize: 7.5,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
                letterSpacing: 0.4)),
      );

  pw.TableRow identRow(String l1, dynamic v1, String l2, dynamic v2) =>
      pw.TableRow(children: [
        pw.Container(
            color: cGrey100,
            padding:
                const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 2.5),
            child: pw.Text(l1, style: bold(6.5, c: cGrey600))),
        pw.Container(
            padding:
                const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 2.5),
            child: pw.Text(v1?.toString() ?? '-', style: norm(6.5))),
        pw.Container(
            color: cGrey100,
            padding:
                const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 2.5),
            child: pw.Text(l2, style: bold(6.5, c: cGrey600))),
        pw.Container(
            padding:
                const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 2.5),
            child: pw.Text(v2?.toString() ?? '-', style: norm(6.5))),
      ]);

  pw.Widget chkItem(String n, String lbl, dynamic v, {bool isVal = false}) {
    final ok = v == true || v?.toString().toLowerCase() == 'true';
    final val = v?.toString() ?? '';
    final showOk = !isVal && ok;
    final showVal = isVal &&
        val.isNotEmpty &&
        val != 'null' &&
        val != 'true' &&
        val != 'false';
    return pw.Container(
      decoration: pw.BoxDecoration(
          border:
              pw.Border(bottom: pw.BorderSide(width: 0.3, color: cGrey200))),
      child: pw.Row(children: [
        pw.Container(
            width: 16,
            alignment: pw.Alignment.center,
            padding: const pw.EdgeInsets.symmetric(vertical: 2.5),
            child: pw.Text(n, style: norm(6, c: cGrey600))),
        pw.Container(width: 0.3, color: cGrey200),
        pw.Expanded(
            child: pw.Padding(
                padding:
                    const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 2.5),
                child: pw.Text(lbl, style: norm(6.5)))),
        pw.Container(width: 0.3, color: cGrey200),
        pw.Container(
          width: 28,
          alignment: pw.Alignment.center,
          padding: const pw.EdgeInsets.symmetric(vertical: 2.5),
          child: showOk
              ? pw.Container(
                  padding:
                      const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: pw.BoxDecoration(
                      color: cOkBg, borderRadius: pw.BorderRadius.circular(8)),
                  child: pw.Text('OK', style: bold(6, c: cOk)))
              : showVal
                  ? pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                          horizontal: 3, vertical: 1),
                      decoration: pw.BoxDecoration(
                          color: cBlueSoft,
                          borderRadius: pw.BorderRadius.circular(8)),
                      child: pw.Text(val, style: bold(6, c: cBlueDk)))
                  : pw.Text('-', style: norm(6, c: cGrey600)),
        ),
      ]),
    );
  }

  pw.Widget imgBox(pw.ImageProvider? img) => img != null
      ? pw.Image(img, fit: pw.BoxFit.cover)
      : pw.Center(child: pw.Text('SEM IMAGEM', style: norm(7, c: cGrey600)));

  pw.Widget bordered(pw.Widget child) => pw.Container(
        decoration: pw.BoxDecoration(
            border: pw.Border.all(width: 0.4, color: cGrey200)),
        child: child,
      );

  return pw.Page(
    pageFormat: PdfPageFormat.a4,
    margin: const pw.EdgeInsets.all(14),
    build: (pw.Context ctx) => pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        bordered(pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Padding(
                padding: const pw.EdgeInsets.all(7),
                child: logoEmpresa != null
                    ? pw.Container(
                        width: 70,
                        height: 32,
                        child: pw.Image(logoEmpresa, fit: pw.BoxFit.contain))
                    : pw.Text('HPS REFRIGERAÇÃO', style: bold(9, c: cBlue))),
            pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Text('DATA DA MANUTENÇÃO', style: bold(6, c: cBlue)),
                  pw.SizedBox(height: 2),
                  pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                          horizontal: 12, vertical: 3),
                      decoration: pw.BoxDecoration(
                          color: cBlueSoft,
                          borderRadius: pw.BorderRadius.circular(4),
                          border: pw.Border.all(width: 0.5, color: cBlue)),
                      child: pw.Text(dataInicio.isEmpty ? '-' : dataInicio,
                          style: bold(10, c: cBlueDk))),
                ]),
            pw.Padding(
                padding: const pw.EdgeInsets.all(7),
                child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      logoCliente != null
                          ? pw.Container(
                              width: 38,
                              height: 38,
                              child:
                                  pw.Image(logoCliente, fit: pw.BoxFit.contain))
                          : pw.Container(
                              width: 38,
                              height: 38,
                              decoration: pw.BoxDecoration(
                                  border: pw.Border.all(
                                      width: 0.4, color: cGrey200)),
                              child: pw.Center(
                                  child:
                                      pw.Text('Sem Logo', style: norm(5.5)))),
                    ])),
          ],
        )),
        pw.SizedBox(height: 4),
        bordered(pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              secHdr('IDENTIFICAÇÃO'),
              pw.Table(
                border: pw.TableBorder(
                  horizontalInside: pw.BorderSide(width: 0.3, color: cGrey200),
                  verticalInside: pw.BorderSide(width: 0.3, color: cGrey200),
                ),
                columnWidths: const {
                  0: pw.FixedColumnWidth(70),
                  1: pw.FlexColumnWidth(),
                  2: pw.FixedColumnWidth(70),
                  3: pw.FlexColumnWidth(),
                },
                children: [
                  identRow('APARELHO:', data['EQUIPAMENTO'] ?? '-', 'VOLTAGEM:',
                      data['TENSAO'] ?? '-'),
                  identRow('MODELO:', data['MODELO'] ?? '-', 'GÁS:',
                      data['FLUIDO'] ?? '-'),
                  identRow('TIPO:', data['TIPO'] ?? '-', 'POTÊNCIA:',
                      data['BTUS'] ?? '-'),
                  identRow('FABRICANTE:', data['MARCA'] ?? '-', 'PRÉDIO:',
                      data['SETOR']?.toString() ?? '-'),
                  identRow('PATRIMÔNIO:', patrimonio, 'LOCALIZAÇÃO:',
                      data['SALA'] ?? '-'),
                  identRow(
                      'TÉCNICO:',
                      data['TECNICORESPONSAVEL'] ?? '-',
                      'MANUTENÇÃO:',
                      data['TIPOMANUTENCAO'] ??
                          data['DESCRICAODOSERVICO']?.toString() ??
                          '-'),
                ],
              ),
            ])),
        pw.SizedBox(height: 4),
        pw.SizedBox(
            height: 190,
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                pw.Expanded(
                    flex: 4,
                    child: bordered(pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                      children: [
                        secHdr('EVAPORADORA'),
                        pw.Expanded(child: imgBox(imgEvap)),
                      ],
                    ))),
                pw.SizedBox(width: 4),
                pw.Expanded(
                    flex: 6,
                    child: bordered(pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                      children: [
                        secHdr('CONDIÇÃO E VERIFICAÇÃO'),
                        chkItem('1', 'Limpeza evaporadora interna',
                            data['LIMPEZAEVAPORADORAINTERNA']),
                        chkItem(
                            '2', 'Limpeza do filtro', data['LIMPEZAFILTRO']),
                        chkItem('3', 'Limpeza com bactericida',
                            data['LIMPEZABACTERICIDA']),
                        chkItem(
                            '4',
                            'Controle e pilhas',
                            data['VERIFICAODOCONTROLPILHAS'] ??
                                data['VERIFICADOCONTROLPILHAS']),
                        chkItem(
                            '5',
                            'Verificar ruídos',
                            data['VERIFICAODERUIDOS'] ??
                                data['VERIFICADODERUIDOS']),
                        chkItem(
                            '6',
                            'Verificar mal cheiro',
                            data['VERIFICAOMALCHEIRO'] ??
                                data['VERIFICACAOMALCHEIRO']),
                        chkItem('7', 'Corrente elétrica (A)', data['AMPERAGEM'],
                            isVal: true),
                        chkItem('8', 'Tensão elétrica (V)', data['TENSAO'],
                            isVal: true),
                      ],
                    ))),
              ],
            )),
        pw.SizedBox(height: 4),
        pw.SizedBox(
            height: 215,
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                pw.Expanded(
                    flex: 4,
                    child: bordered(pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                      children: [
                        secHdr('TERMOGRAFIA'),
                        pw.Expanded(child: imgBox(imgTermo)),
                      ],
                    ))),
                pw.SizedBox(width: 4),
                pw.Expanded(
                    flex: 6,
                    child: bordered(pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                      children: [
                        secHdr('VERIFICAÇÕES'),
                        chkItem(
                            '1',
                            'Verificar dreno',
                            data['VERIFICAODODRENO'] ??
                                data['VERIFICADODRENO']),
                        chkItem(
                            '2',
                            'Verificar pressão (PSI)',
                            data['VERIFICAODAPRESSAO'] ??
                                data['VERIFICADAPRESSAO']),
                        chkItem('3', 'Polir condensadora',
                            data['POLIRCONDENSADORA']),
                        chkItem(
                            '4',
                            'Parte elétrica',
                            data['VERIFICAODAPARTEELETRICA'] ??
                                data['VERIFICADAPARTEELETRICA']),
                        chkItem(
                            '5',
                            'Isolamento térmico',
                            data['VERIFICAODOISOLAMENTOTRMICO'] ??
                                data['VERIFICADOISOLAMENTOTRMICO']),
                        chkItem('6', 'Jateamento condensadora',
                            data['JATEAMENTOCONDENSADORA']),
                        chkItem('7', 'Jateamento evaporadora',
                            data['JATEAMENTOEVAPORADORA']),
                        chkItem('8', 'Lavagem do dreno', data['LAVAGEMDRENO']),
                        chkItem('9', 'Carcaça evaporadora',
                            data['LAVAGEMCARCACAEVAP']),
                        chkItem('10', 'Carcaça condensadora',
                            data['LAVAGEMCARCACACOND']),
                        chkItem('11', 'Limpeza do compressor',
                            data['LIMPEZACOMPRESSOR']),
                        chkItem('12', 'Turbina evaporadora',
                            data['LAVAGEMTURBINAEVAP']),
                        chkItem(
                            '13',
                            'Pés de borracha',
                            data['VERIFICAODOSPEDEBORRACHA'] ??
                                data['VERIFICADOSPEDEBORRACHA']),
                      ],
                    ))),
              ],
            )),
        pw.SizedBox(height: 4),
        pw.Expanded(
            child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            pw.Expanded(
                flex: 6,
                child: bordered(pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                  children: [
                    secHdr('SERVIÇOS REALIZADOS'),
                    chkItem(
                        '1', 'Higienização com produtos bactericidas', true),
                    chkItem(
                        '2',
                        'Filtros: lavar com água corrente e sabão, secar',
                        true),
                    chkItem('3', 'Medir e informar tensão elétrica', true),
                    chkItem('4', 'Medir e informar corrente elétrica', true),
                    chkItem('5', 'Limpar carenagem da evaporadora', true),
                    chkItem(
                        '6', 'Verificar ruídos, vazamentos e mau cheiro', true),
                  ],
                ))),
            pw.SizedBox(width: 4),
            pw.Expanded(
                flex: 4,
                child: bordered(pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                  children: [
                    secHdr('INFORMAÇÕES ADICIONAIS'),
                    pw.Expanded(
                        child: pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text(
                        observacao.isNotEmpty ? observacao : 'Sem observações.',
                        style: norm(7,
                            c: observacao.isNotEmpty ? cGrey800 : cGrey600),
                      ),
                    )),
                  ],
                ))),
          ],
        )),
        pw.SizedBox(height: 4),
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: pw.BoxDecoration(
              color: cBlueDk, borderRadius: pw.BorderRadius.circular(3)),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('HPS REFRIGERAÇÃO',
                        style: bold(7.5, c: PdfColors.white)),
                    pw.Text('CNPJ: 28.340.152/0001-52',
                        style:
                            norm(6.5, c: const PdfColor.fromInt(0xB3FFFFFF))),
                    pw.Text('(77) 98819-4630 / 98861-2447',
                        style:
                            norm(6.5, c: const PdfColor.fromInt(0xB3FFFFFF))),
                  ]),
              pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(nomeCliente.isNotEmpty ? nomeCliente : 'CLIENTE',
                        style: bold(7.5, c: PdfColors.white)),
                    if (cnpjCliente.isNotEmpty)
                      pw.Text('CNPJ: $cnpjCliente',
                          style:
                              norm(6.5, c: const PdfColor.fromInt(0xB3FFFFFF))),
                  ]),
            ],
          ),
        ),
      ],
    ),
  );
}

/// ─────────────────────────────────────────────────────────────────────────────
/// WIDGET PRINCIPAL
/// ─────────────────────────────────────────────────────────────────────────────
class EnviarRelatorioEmailWidget extends StatefulWidget {
  const EnviarRelatorioEmailWidget({
    super.key,
    this.width,
    this.height,
    this.onCancelar,
  });

  final double? width;
  final double? height;
  final Future<dynamic> Function()? onCancelar;

  @override
  State<EnviarRelatorioEmailWidget> createState() =>
      _EnviarRelatorioEmailWidgetState();
}

class _EnviarRelatorioEmailWidgetState extends State<EnviarRelatorioEmailWidget>
    with TickerProviderStateMixin {
  List<Map<String, dynamic>> _usuarios = [];
  bool _loadingUsuarios = true;

  String? _emailPrincipal;
  List<String> _emailsAdicionais = [];
  List<String> _emailsExtraSelecionados = [];
  Map<String, dynamic>? _dadosCliente;

  List<Map<String, String>> _periodosDisponiveis = [];
  bool _loadingPeriodos = false;
  String? _mesSelecionado;
  String? _anoSelecionado;

  bool _enviando = false;
  bool _enviado = false;
  double _progresso = 0.0;
  String _progressoLabel = '';

  late final AnimationController _successCtrl;
  late final Animation<double> _successAnim;

  @override
  void initState() {
    super.initState();
    _successCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _successAnim =
        CurvedAnimation(parent: _successCtrl, curve: Curves.elasticOut);
    _carregarUsuarios();
  }

  @override
  void dispose() {
    _successCtrl.dispose();
    super.dispose();
  }

  Future<void> _carregarUsuarios() async {
    try {
      final snap =
          await FirebaseFirestore.instance.collection('USUARIOS').get();
      final lista = <Map<String, dynamic>>[];
      for (final doc in snap.docs) {
        final d = doc.data();
        final email = d['email']?.toString().trim() ?? '';
        if (email.isEmpty) continue;
        final nome = d['display_name']?.toString().trim() ?? email;

        final extras = <String>[];
        final field = d['emailteste'];
        if (field is List) {
          for (final e in field) {
            final s = e?.toString().trim() ?? '';
            if (s.isNotEmpty) extras.add(s);
          }
        } else if (field is String && field.trim().isNotEmpty) {
          extras.add(field.trim());
        }

        lista.add({
          'email': email,
          'nome': nome,
          'emailteste': extras,
          'dados': d,
        });
      }
      if (mounted) {
        setState(() {
          _usuarios = lista;
          _loadingUsuarios = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingUsuarios = false);
    }
  }

  Future<void> _selecionarUsuario(String? email) async {
    if (email == null) return;
    final u =
        _usuarios.firstWhere((u) => u['email'] == email, orElse: () => {});

    final extras = List<String>.from(u['emailteste'] ?? []);
    if (!extras.contains(email)) extras.insert(0, email);

    setState(() {
      _emailPrincipal = email;
      _dadosCliente = u['dados'] as Map<String, dynamic>?;
      _emailsAdicionais = extras;
      _emailsExtraSelecionados = [];
      _mesSelecionado = null;
      _anoSelecionado = null;
      _periodosDisponiveis = [];
      _loadingPeriodos = true;
    });
    await _carregarPeriodos(email);
  }

  Future<void> _carregarPeriodos(String email) async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('PREVENTIVAS')
          .where('EMAIL', isEqualTo: email)
          .get();

      final Set<String> periodos = {};
      for (final doc in snap.docs) {
        final d = doc.data();
        final mes = d['MES']?.toString().trim() ?? '';
        final ano = d['ANO']?.toString().trim() ?? '';
        if (mes.isNotEmpty && ano.isNotEmpty) periodos.add('$mes|$ano');
      }

      final lista = periodos.map((p) {
        final parts = p.split('|');
        return {'mes': parts[0], 'ano': parts[1]};
      }).toList();

      lista.sort((a, b) {
        final aAno = int.tryParse(a['ano']!) ?? 0;
        final bAno = int.tryParse(b['ano']!) ?? 0;
        if (aAno != bAno) return bAno.compareTo(aAno);
        final aMes = _ptMonths.indexOf(a['mes']!.toUpperCase());
        final bMes = _ptMonths.indexOf(b['mes']!.toUpperCase());
        return bMes.compareTo(aMes);
      });

      if (mounted) {
        setState(() {
          _periodosDisponiveis = lista;
          _loadingPeriodos = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingPeriodos = false);
    }
  }

  void _selecionarPeriodo(String? valor) {
    if (valor == null) return;
    final parts = valor.split('|');
    setState(() {
      _mesSelecionado = parts[0];
      _anoSelecionado = parts[1];
    });
  }

  Future<List<Map<String, dynamic>>> _buscarPreventivas() async {
    final snap = await FirebaseFirestore.instance
        .collection('PREVENTIVAS')
        .where('EMAIL', isEqualTo: _emailPrincipal)
        .where('MES', isEqualTo: _mesSelecionado)
        .where('ANO',
            isEqualTo: int.tryParse(_anoSelecionado ?? '') ??
                int.parse(_anoSelecionado!))
        .get();

    final lista = snap.docs.map((d) => d.data()).toList();
    lista.sort((a, b) {
      DateTime? da, db;
      try {
        da = ((a['datacadastro'] ?? a['DATADAMANUTENCAO']) as Timestamp?)
            ?.toDate();
      } catch (_) {}
      try {
        db = ((b['datacadastro'] ?? b['DATADAMANUTENCAO']) as Timestamp?)
            ?.toDate();
      } catch (_) {}
      if (da == null) return 1;
      if (db == null) return -1;
      return db.compareTo(da);
    });
    return lista;
  }

  Future<void> _enviar() async {
    if (_emailPrincipal == null) {
      _toast('Selecione o cliente / empresa');
      return;
    }
    if (_mesSelecionado == null || _anoSelecionado == null) {
      _toast('Selecione o mês e ano');
      return;
    }
    if (_emailsExtraSelecionados.isEmpty) {
      _toast('Marque pelo menos um e-mail na lista de Emails Adicionais');
      return;
    }

    setState(() {
      _enviando = true;
      _progresso = 0.0;
      _progressoLabel = 'Buscando preventivas...';
    });

    try {
      await _step(0.05, 'Buscando preventivas...');
      final preventivas = await _buscarPreventivas();

      if (preventivas.isEmpty) {
        setState(() => _enviando = false);
        _toast('Nenhuma preventiva encontrada para esse período');
        return;
      }

      await _step(0.08, 'Buscando pendências...');
      final pendencias = await _buscarPendenciasParaPdf(
        emailCliente: _emailPrincipal!,
        mes: _mesSelecionado!,
        ano: _anoSelecionado!,
      );

      await _step(0.10, 'Gerando PDF de preventivas...');
      final pdfBytesPreventivas = await _gerarPdfRelatorio(
        preventivas: preventivas,
        dadosCliente: _dadosCliente ?? {},
        mes: _mesSelecionado!,
        ano: _anoSelecionado!,
        onProgress: (v, label) {
          if (mounted) {
            setState(() {
              _progresso = 0.10 + v * 0.42;
              _progressoLabel = label;
            });
          }
        },
      );

      Uint8List? pdfBytesPendencias;
      if (pendencias.isNotEmpty) {
        await _step(0.53, 'Gerando PDF de pendências...');
        final nomeCliente =
            _dadosCliente?['display_name']?.toString().toUpperCase() ?? '';
        pdfBytesPendencias = await _gerarPdfPendencias(
          pendencias: pendencias,
          nomeCliente: nomeCliente,
          mes: _mesSelecionado!,
          ano: _anoSelecionado!,
          onProgress: (v, label) {
            if (mounted) {
              setState(() {
                _progresso = 0.53 + v * 0.15;
                _progressoLabel = label;
              });
            }
          },
        );
      }

      await _step(0.70, 'Salvando relatório de preventivas na nuvem...');
      final pastaEmail = _emailPrincipal!.trim();
      String mesFormatado = _mesSelecionado!.toLowerCase();
      if (mesFormatado.isNotEmpty) {
        mesFormatado =
            mesFormatado[0].toUpperCase() + mesFormatado.substring(1);
      }

      final refPreventivas = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('$pastaEmail/$_anoSelecionado/$mesFormatado/'
              'Relatorio_${_mesSelecionado}_${_anoSelecionado}.pdf');

      await refPreventivas.putData(
        pdfBytesPreventivas,
        firebase_storage.SettableMetadata(contentType: 'application/pdf'),
      );
      final urlPreventivas = await refPreventivas.getDownloadURL();

      String? urlPendencias;
      if (pdfBytesPendencias != null) {
        await _step(0.80, 'Salvando relatório de pendências na nuvem...');
        final refPendencias = firebase_storage.FirebaseStorage.instance
            .ref()
            .child('$pastaEmail/$_anoSelecionado/$mesFormatado/'
                'Pendencias_${_mesSelecionado}_${_anoSelecionado}.pdf');

        await refPendencias.putData(
          pdfBytesPendencias,
          firebase_storage.SettableMetadata(contentType: 'application/pdf'),
        );
        urlPendencias = await refPendencias.getDownloadURL();
      }

      await _step(0.88, 'Preparando e-mail...');
      final nomeCliente = _dadosCliente?['display_name']?.toString() ?? '';
      final assunto =
          'Relatório de Manutenções Preventivas – $_mesSelecionado/$_anoSelecionado';

      final htmlBody = _buildHtmlEmail(
        nomeCliente: nomeCliente,
        mes: _mesSelecionado!,
        ano: _anoSelecionado!,
        total: preventivas.length,
        downloadUrl: urlPreventivas,
        downloadUrlPendencias: urlPendencias,
        totalPendencias: pendencias.length,
      );

      await _step(0.92, 'Enviando e-mail...');
      await _sendEmail(
        toEmails: _emailsExtraSelecionados,
        subject: assunto,
        htmlBody: htmlBody,
      );

      await _step(0.94, 'Enviando notificações push...');
      final pushMsg =
          'Relatório de manutenções de $_mesSelecionado/$_anoSelecionado '
          'com ${preventivas.length} preventiva${preventivas.length != 1 ? "s" : ""} '
          'foi enviado por e-mail.';

      await Future.wait([
        _enviarPushOneSignal(
          email: _emailPrincipal!,
          titulo: '📊 Relatório Disponível',
          mensagem: pushMsg,
        ),
        _enviarPushOneSignal(
          email: _kEmailHPS,
          titulo: '📊 Relatório Enviado ao Cliente',
          mensagem: 'Relatório de $_mesSelecionado/$_anoSelecionado para '
              '${nomeCliente.isNotEmpty ? nomeCliente : _emailPrincipal} '
              'foi enviado com ${preventivas.length} preventiva${preventivas.length != 1 ? "s" : ""}.',
        ),
      ]);

      await _step(0.97, 'Salvando notificações...');
      await Future.wait([
        _criarNotificacaoFirebase(
          email: _emailPrincipal!,
          mes: _mesSelecionado!,
          ano: _anoSelecionado!,
          totalPreventivas: preventivas.length,
          totalPendencias: pendencias.length,
        ),
        _criarNotificacaoFirebase(
          email: _kEmailHPS,
          mes: _mesSelecionado!,
          ano: _anoSelecionado!,
          totalPreventivas: preventivas.length,
          totalPendencias: pendencias.length,
        ),
      ]);

      await _step(1.0, 'Concluído!');

      if (!mounted) return;
      setState(() {
        _enviado = true;
        _enviando = false;
      });
      _successCtrl.forward();

      await Future.delayed(const Duration(milliseconds: 3000));
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        setState(() {
          _enviando = false;
          _progresso = 0.0;
        });
        _toast('Erro: $e');
      }
    }
  }

  Future<void> _step(double alvo, String label) async {
    if (!mounted) return;
    setState(() => _progressoLabel = label);
    final ini = _progresso;
    final delta = alvo - ini;
    for (int i = 1; i <= 15; i++) {
      await Future.delayed(const Duration(milliseconds: 18));
      if (!mounted) return;
      setState(() => _progresso = ini + delta * (i / 15));
    }
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), duration: const Duration(seconds: 3)));
  }

  InputDecoration _input(String hint, bool isDark) {
    final border = isDark ? Colors.white12 : Colors.black12;
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: isDark ? Colors.white54 : Colors.black54),
      filled: true,
      fillColor: isDark ? const Color(0xFF252D3A) : const Color(0xFFF4F6F8),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: border)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: border)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _kVerde, width: 1.8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E2530) : Colors.white;
    final borderColor = isDark ? Colors.white12 : Colors.black12;
    final primaryTextColor = isDark ? Colors.white : Colors.black87;

    if (_enviado) {
      final enviados = List<String>.from(_emailsExtraSelecionados);
      return Container(
        width: widget.width,
        padding: const EdgeInsets.all(36),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withAlpha(25), blurRadius: 20)
          ],
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ScaleTransition(
            scale: _successAnim,
            child: Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.green.shade300, width: 3)),
              child: const Icon(Icons.mark_email_read_rounded,
                  color: Colors.green, size: 46),
            ),
          ),
          const SizedBox(height: 22),
          const Text('Relatório enviado com sucesso!',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green)),
          const SizedBox(height: 10),
          Text(
            'Enviado para:\n${enviados.join("\n")}',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.white54 : Colors.black54,
                height: 1.6),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
                color: Colors.green.withAlpha(20),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.green.shade600)),
              const SizedBox(width: 10),
              Text('Fechando automaticamente...',
                  style: TextStyle(
                      fontSize: 13,
                      color: Colors.green.shade600,
                      fontWeight: FontWeight.w500)),
            ]),
          ),
        ]),
      );
    }

    final form = Container(
      width: widget.width,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withAlpha(isDark ? 100 : 20),
              blurRadius: 20,
              offset: const Offset(0, 4))
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                _kBannerUrl,
                width: double.infinity,
                height: 110,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 70,
                  decoration: BoxDecoration(
                      color: _kVerde, borderRadius: BorderRadius.circular(12)),
                  child: const Center(
                      child: Text('HPS Refrigeração',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18))),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                  color: _kVerde.withAlpha(isDark ? 38 : 18),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _kVerde.withAlpha(46))),
              child: Row(children: [
                CircleAvatar(
                    radius: 18,
                    backgroundColor: _kVerde,
                    child: const Text('H',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15))),
                const SizedBox(width: 10),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Huagner Pires',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: primaryTextColor)),
                  Text('equipe@hpsrefri.com.br',
                      style: TextStyle(
                          fontSize: 12,
                          color:
                              isDark ? Colors.white54 : Colors.grey.shade500)),
                ]),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                      color: _kVerde, borderRadius: BorderRadius.circular(12)),
                  child: const Text('Remetente',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600)),
                ),
              ]),
            ),
            const SizedBox(height: 14),
            Center(
                child: Text('Envio de Relatório de Manutenções',
                    style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white54 : Colors.black54))),
            const SizedBox(height: 14),
            Divider(color: borderColor),
            const SizedBox(height: 14),
            Text('Cliente',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: primaryTextColor)),
            const SizedBox(height: 4),
            const Text('Selecione para carregar os relatórios deste cliente',
                style: TextStyle(fontSize: 11, color: Colors.grey)),
            const SizedBox(height: 8),
            _loadingUsuarios
                ? const Center(
                    child: Padding(
                        padding: EdgeInsets.all(12),
                        child: CircularProgressIndicator(strokeWidth: 2)))
                : DropdownButtonFormField<String>(
                    value: _emailPrincipal,
                    hint: Text('Selecione o cliente',
                        style: TextStyle(
                            color: isDark ? Colors.white54 : Colors.black54)),
                    isExpanded: true,
                    decoration: _input('Selecione o cliente', isDark),
                    dropdownColor:
                        isDark ? const Color(0xFF252D3A) : Colors.white,
                    style: TextStyle(color: primaryTextColor),
                    items: _usuarios.map((u) {
                      final email = u['email']?.toString() ?? '';
                      final nome = u['nome']?.toString() ?? email;
                      return DropdownMenuItem<String>(
                        value: email,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(nome,
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: primaryTextColor),
                                overflow: TextOverflow.ellipsis),
                            Text(email,
                                style: TextStyle(
                                    fontSize: 12,
                                    color: isDark
                                        ? Colors.white54
                                        : Colors.grey.shade500),
                                overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: _selecionarUsuario,
                  ),
            const SizedBox(height: 16),
            if (_emailPrincipal != null) ...[
              Row(children: [
                Text('Destinatários (Para)',
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: primaryTextColor)),
                const SizedBox(width: 8),
                if (_emailsExtraSelecionados.isNotEmpty)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                        color: _kVerde,
                        borderRadius: BorderRadius.circular(10)),
                    child: Text('+${_emailsExtraSelecionados.length}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600)),
                  ),
              ]),
              const SizedBox(height: 4),
              const Text('Marque os e-mails que vão receber o relatório',
                  style: TextStyle(fontSize: 11, color: Colors.grey)),
              const SizedBox(height: 8),
              _emailsAdicionais.isEmpty
                  ? Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF252D3A)
                              : const Color(0xFFF4F6F8),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: borderColor)),
                      child: const Text('Nenhum email adicional cadastrado',
                          style: TextStyle(fontSize: 13, color: Colors.grey)),
                    )
                  : Container(
                      decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF252D3A)
                              : const Color(0xFFF4F6F8),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: borderColor)),
                      child: Column(
                        children: List.generate(
                          _emailsAdicionais.length,
                          (idx) {
                            final email = _emailsAdicionais[idx];
                            final sel =
                                _emailsExtraSelecionados.contains(email);
                            final isFirst = idx == 0;
                            final isLast = idx == _emailsAdicionais.length - 1;
                            return Column(children: [
                              if (!isFirst)
                                Divider(height: 1, color: borderColor),
                              InkWell(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(isFirst ? 10 : 0),
                                  topRight: Radius.circular(isFirst ? 10 : 0),
                                  bottomLeft: Radius.circular(isLast ? 10 : 0),
                                  bottomRight: Radius.circular(isLast ? 10 : 0),
                                ),
                                onTap: () => setState(() {
                                  if (sel) {
                                    _emailsExtraSelecionados.remove(email);
                                  } else {
                                    _emailsExtraSelecionados.add(email);
                                  }
                                }),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 11),
                                  child: Row(children: [
                                    AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 200),
                                      width: 22,
                                      height: 22,
                                      decoration: BoxDecoration(
                                        color:
                                            sel ? _kVerde : Colors.transparent,
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                            color: sel
                                                ? _kVerde
                                                : (isDark
                                                    ? Colors.white30
                                                    : Colors.grey.shade400),
                                            width: 2),
                                      ),
                                      child: sel
                                          ? const Icon(Icons.check,
                                              color: Colors.white, size: 14)
                                          : null,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                        child: Text(email,
                                            style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: sel
                                                    ? FontWeight.w600
                                                    : FontWeight.normal,
                                                color: sel
                                                    ? _kVerde
                                                    : primaryTextColor))),
                                  ]),
                                ),
                              ),
                            ]);
                          },
                        ),
                      ),
                    ),
              const SizedBox(height: 16),
            ],
            Text('Período do Relatório',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: primaryTextColor)),
            const SizedBox(height: 4),
            const Text('Meses com preventivas cadastradas para o cliente',
                style: TextStyle(fontSize: 11, color: Colors.grey)),
            const SizedBox(height: 8),
            if (_emailPrincipal == null)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF252D3A)
                        : const Color(0xFFF4F6F8),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: borderColor)),
                child: Row(children: [
                  Icon(Icons.info_outline,
                      size: 16,
                      color: isDark ? Colors.white38 : Colors.black38),
                  const SizedBox(width: 8),
                  Text('Selecione um cliente para ver os períodos',
                      style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.white38 : Colors.black38)),
                ]),
              )
            else if (_loadingPeriodos)
              const Center(
                  child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: _kVerde)))
            else if (_periodosDisponiveis.isEmpty)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF252D3A)
                        : const Color(0xFFF4F6F8),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: borderColor)),
                child: Row(children: [
                  const Icon(Icons.search_off, size: 16, color: Colors.orange),
                  const SizedBox(width: 8),
                  Text('Nenhuma preventiva encontrada para este cliente',
                      style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.white54 : Colors.black54)),
                ]),
              )
            else
              DropdownButtonFormField<String>(
                value: (_mesSelecionado != null && _anoSelecionado != null)
                    ? '$_mesSelecionado|$_anoSelecionado'
                    : null,
                hint: Text('Selecione o período',
                    style: TextStyle(
                        color: isDark ? Colors.white54 : Colors.black54)),
                isExpanded: true,
                decoration: _input('Selecione o período', isDark),
                dropdownColor: isDark ? const Color(0xFF252D3A) : Colors.white,
                style: TextStyle(color: primaryTextColor),
                items: _periodosDisponiveis.map((p) {
                  final mes = p['mes']!;
                  final ano = p['ano']!;
                  return DropdownMenuItem<String>(
                    value: '$mes|$ano',
                    child: Text('$mes / $ano',
                        style:
                            TextStyle(fontSize: 14, color: primaryTextColor)),
                  );
                }).toList(),
                onChanged: _selecionarPeriodo,
              ),
            const SizedBox(height: 24),
            if (_emailPrincipal != null && _mesSelecionado != null) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                    color: _kVerde.withAlpha(isDark ? 38 : 15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _kVerde.withAlpha(60))),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        const Icon(Icons.preview_outlined,
                            size: 15, color: _kVerde),
                        const SizedBox(width: 6),
                        const Text('Resumo do envio',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _kVerde)),
                      ]),
                      const SizedBox(height: 8),
                      _previewRow(
                          'Assunto',
                          'Relatório de Manutenções – '
                              '$_mesSelecionado/$_anoSelecionado',
                          isDark),
                      _previewRow(
                          'Para',
                          _emailsExtraSelecionados.isNotEmpty
                              ? _emailsExtraSelecionados.join(', ')
                              : 'Selecione pelo menos um e-mail acima',
                          isDark),
                      _previewRow(
                          'Anexos',
                          'PDF de Preventivas + PDF de Pendências '
                              '(caso existam)',
                          isDark),
                    ]),
              ),
              const SizedBox(height: 16),
            ],
            Row(children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.onCancelar != null
                      ? () => widget.onCancelar!()
                      : null,
                  style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      side: BorderSide(
                          color: isDark ? Colors.white24 : Colors.black26)),
                  child: Text('Cancelar',
                      style: TextStyle(color: primaryTextColor)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.send_rounded,
                      size: 16, color: Colors.white),
                  label: const Text('Enviar Relatório',
                      style: TextStyle(color: Colors.white)),
                  onPressed: _enviando ? null : _enviar,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: _kVerde,
                      elevation: 1,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10))),
                ),
              ),
            ]),
          ],
        ),
      ),
    );

    if (_enviando) {
      return Stack(children: [
        form,
        Positioned.fill(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              color: Colors.black.withAlpha(140),
              child: Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 32),
                  padding: const EdgeInsets.all(26),
                  decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withAlpha(76), blurRadius: 24)
                      ]),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Container(
                      width: 66,
                      height: 66,
                      decoration: BoxDecoration(
                          color: _kVerde.withAlpha(30), shape: BoxShape.circle),
                      child: const Icon(Icons.picture_as_pdf,
                          color: _kVerde, size: 34),
                    ),
                    const SizedBox(height: 16),
                    Text('Gerando e enviando',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: primaryTextColor)),
                    const SizedBox(height: 6),
                    Text(_progressoLabel,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 13,
                            color: isDark ? Colors.white54 : Colors.black54)),
                    const SizedBox(height: 20),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: _progresso,
                        minHeight: 10,
                        backgroundColor:
                            isDark ? Colors.white12 : Colors.grey.shade200,
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(_kVerde),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '${(_progresso * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(
                            fontSize: 12,
                            color: _kVerde,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ]),
                ),
              ),
            ),
          ),
        ),
      ]);
    }

    return form;
  }

  Widget _previewRow(String label, String valor, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
          width: 56,
          child: Text('$label:',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white54 : Colors.black54)),
        ),
        Expanded(
            child: Text(valor,
                style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white70 : Colors.black87))),
      ]),
    );
  }
}
