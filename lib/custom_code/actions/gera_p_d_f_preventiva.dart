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

import 'index.dart';
import '/custom_code/actions/index.dart';
import '/flutter_flow/custom_functions.dart';
// Begin custom widget code

import 'package:image_picker/image_picker.dart';
import '/flutter_flow/uploaded_file.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:image/image.dart' as img;
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

// ============================================================
// CONSTANTES DO EMAIL BREVO
// ============================================================
const _kBrevoApiKey =
    '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';
const _kSenderEmail = 'equipe@hpsrefri.com.br';
const _kSenderName = 'HPS Refrigeração';
const _kBannerUrl =
    'https://firebasestorage.googleapis.com/v0/b/h-p-s-modificado-emdcp0.appspot.com/o/Gemini_Generated_Image_2xpdsd2xpdsd2xpd%20(1).png?alt=media&token=be3e052e-a0b8-4e8c-8151-b9365b507ed5';

// ============================================================
// CACHE ESTÁTICO: logo, assinatura e fontes são baixados UMA VEZ
// ============================================================
Uint8List? _cachedLogo;
Uint8List? _cachedAssinatura;
pw.Font? _cachedFontRegular;
pw.Font? _cachedFontBold;

const _urlLogo = 'https://i.ibb.co/VpqNsxXt/Imagem1.jpg';
const _urlAssinatura =
    'https://i.ibb.co/hRvtGhbK/3b004d07-a4a9-4568-9d8b-5abc281dbcee.png';

const _kTimeout = Duration(seconds: 5);

const _kJpegQualityFotos = 40;
const _kJpegQualityAssets = 50;
const _kMaxWidthFotosGrandes = 400;
const _kMaxWidthPequenas = 200;
const _kMaxWidthAssinatura = 500;
const _kQualityAssinatura = 80;

Uint8List? _comprimirImagem(Uint8List? bytes,
    {int maxWidth = 400, int quality = 40}) {
  if (bytes == null || bytes.isEmpty) return null;
  try {
    final decoded = img.decodeImage(bytes);
    if (decoded == null) return null;
    img.Image resized = decoded.width > maxWidth
        ? img.copyResize(decoded, width: maxWidth)
        : decoded;
    return Uint8List.fromList(img.encodeJpg(resized, quality: quality));
  } catch (e) {
    return bytes;
  }
}

Uint8List? _comprimirPNG(Uint8List? bytes,
    {int maxWidth = 200, int quality = 50}) {
  if (bytes == null || bytes.isEmpty) return null;
  try {
    final decoded = img.decodeImage(bytes);
    if (decoded == null) return null;
    img.Image resized = decoded.width > maxWidth
        ? img.copyResize(decoded, width: maxWidth)
        : decoded;
    return Uint8List.fromList(img.encodePng(resized, level: 9));
  } catch (e) {
    return bytes;
  }
}

Future<Uint8List?> _fetchBytes(String url) async {
  try {
    final resp = await http.get(Uri.parse(url),
        headers: {'User-Agent': 'Mozilla/5.0'}).timeout(_kTimeout);
    return resp.statusCode == 200 ? resp.bodyBytes : null;
  } catch (_) {
    return null;
  }
}

Future<Uint8List?> _fetchAndCompress(String url,
    {int maxWidth = 400, int quality = 40, bool isPng = false}) async {
  final bytes = await _fetchBytes(url);
  if (bytes == null) return null;
  return isPng
      ? _comprimirPNG(bytes, maxWidth: maxWidth, quality: quality)
      : _comprimirImagem(bytes, maxWidth: maxWidth, quality: quality);
}

Future<void> preCarregarAssetsPDF() async {
  if (_cachedFontRegular != null &&
      _cachedFontBold != null &&
      _cachedLogo != null &&
      _cachedAssinatura != null) return;
  final results = await Future.wait([
    _cachedFontRegular != null
        ? Future.value(_cachedFontRegular!)
        : PdfGoogleFonts.openSansRegular(),
    _cachedFontBold != null
        ? Future.value(_cachedFontBold!)
        : PdfGoogleFonts.openSansBold(),
    _cachedLogo != null
        ? Future.value(_cachedLogo!)
        : _fetchAndCompress(_urlLogo,
            maxWidth: _kMaxWidthPequenas, quality: _kJpegQualityAssets),
    _cachedAssinatura != null
        ? Future.value(_cachedAssinatura!)
        : _fetchAndCompress(_urlAssinatura,
            maxWidth: _kMaxWidthAssinatura,
            quality: _kQualityAssinatura,
            isPng: true),
  ]);
  _cachedFontRegular = results[0] as pw.Font;
  _cachedFontBold = results[1] as pw.Font;
  final logo = results[2] as Uint8List?;
  final assinatura = results[3] as Uint8List?;
  if (logo != null) _cachedLogo = logo;
  if (assinatura != null) _cachedAssinatura = assinatura;
}

// ============================================================
// FUNÇÃO DE ENVIO DE EMAIL
// ============================================================
Future<void> _enviarEmailComPDF({
  required List<String> toEmails,
  required String nomeCliente,
  required String mes,
  required String ano,
  required Uint8List pdfBytes,
  required String patrimonio,
}) async {
  final subject = 'Relatório de Manutenção Preventiva - $mes/$ano';

  final htmlBody = '''
<!DOCTYPE html>
<html lang="pt-BR">
<head><meta charset="UTF-8"><title>Relatório de Manutenções</title></head>
<body style="margin:0;padding:0;background-color:#f4f6f8;font-family:Arial,Helvetica,sans-serif;">
  <table width="100%" cellpadding="0" cellspacing="0" border="0" style="background-color:#f4f6f8;padding:20px 0;">
    <tr><td align="center">
      <table width="600" cellpadding="0" cellspacing="0" border="0"
             style="background:#ffffff;border-radius:12px;overflow:hidden;max-width:600px;width:100%;">
        <tr>
          <td style="padding:0;margin:0;line-height:0;">
            <img src="$_kBannerUrl" alt="HPS Refrigeração" width="600"
                 style="display:block;width:100%;max-width:600px;height:auto;border:0;"/>
          </td>
        </tr>
        <tr>
          <td style="background-color:#1A3C34;padding:12px 24px;">
            <span style="background:#ffffff20;color:#ffffff;font-size:11px;font-weight:bold;
                         padding:4px 10px;border-radius:20px;">Relatório Automático</span>
          </td>
        </tr>
        <tr>
          <td style="padding:28px;color:#333333;font-size:15px;line-height:1.7;">
            <p style="margin:0 0 16px 0;">Prezados,</p>
            <p style="margin:0 0 16px 0;">
              Segue em anexo o <strong>Relatório de Manutenção Preventiva</strong>
              referente ao período de <strong>$mes / $ano</strong>
              ${nomeCliente.isNotEmpty ? 'para <strong>$nomeCliente</strong>' : ''}.
            </p>
            <table width="100%" cellpadding="0" cellspacing="0" border="0"
                   style="background:#f0fdf4;border-left:4px solid #1A3C34;border-radius:0 8px 8px 0;margin-bottom:20px;">
              <tr>
                <td style="padding:14px 18px;font-size:14px;color:#1A3C34;line-height:1.6;">
                  📋 &nbsp;<strong>Equipamento (Patrimônio: $patrimonio)</strong>
                  com manutenção realizada no período.
                </td>
              </tr>
            </table>
            <p style="margin:0 0 10px 0;">
              O arquivo PDF com o laudo está em anexo a este email.
              Qualquer dúvida, entre em contato conosco.
            </p>
          </td>
        </tr>
        <tr><td style="padding:0 28px;"><hr style="border:none;border-top:1px solid #e8ecf0;margin:0;"></td></tr>
        <tr>
          <td style="padding:20px 28px;">
            <table cellpadding="0" cellspacing="0" border="0">
              <tr>
                <td style="width:44px;vertical-align:top;">
                  <div style="width:40px;height:40px;background:#1A3C34;border-radius:50%;
                              text-align:center;line-height:40px;">
                    <span style="color:#ffffff;font-size:18px;font-weight:bold;">H</span>
                  </div>
                </td>
                <td style="padding-left:12px;vertical-align:top;">
                  <span style="font-size:15px;font-weight:bold;color:#1A3C34;">Huagner Pires</span><br>
                  <span style="font-size:13px;color:#555555;">Especialista em Refrigeração</span><br>
                  <span style="font-size:12px;color:#888888;">hpsrefri.com.br</span>
                </td>
              </tr>
            </table>
          </td>
        </tr>
        <tr>
          <td style="background:#f1f5f9;padding:14px 28px;text-align:center;font-size:12px;
                     color:#94a3b8;border-top:1px solid #e2e8f0;">
            &copy; 2026 HPS Refrigeração &middot; Todos os direitos reservados<br>
            <span style="font-size:11px;">Esta é uma mensagem automática, por favor não responda diretamente.</span>
          </td>
        </tr>
      </table>
    </td></tr>
  </table>
</body>
</html>
''';

  final body = <String, dynamic>{
    'sender': {'name': _kSenderName, 'email': _kSenderEmail},
    'replyTo': {'name': _kSenderName, 'email': _kSenderEmail},
    'to': toEmails.map((e) => {'email': e}).toList(),
    'cc': [
      {'email': _kSenderEmail}
    ], // Envia cópia para equipe
    'subject': subject,
    'htmlContent': htmlBody,
    'attachment': [
      {
        'content': base64Encode(pdfBytes),
        'name': '${patrimonio.trim()}_preventiva.pdf'
      }
    ]
  };

  final response = await http.post(
    Uri.parse('https://api.brevo.com/v3/smtp/email'),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'api-key': _kBrevoApiKey,
    },
    body: jsonEncode(body),
  );

  if (response.statusCode != 200 && response.statusCode != 201) {
    throw Exception('Brevo Erro ${response.statusCode}: ${response.body}');
  }
}

// ALTERADO: Adicionado os parâmetros mesSelecionado e anoSelecionado
Future<void> geraPDFPreventiva(String patrimonio, String? emailCliente,
    int mesSelecionado, int anoSelecionado) async {
  pw.TableRow buildIdentRow(
      String label1, String value1, String label2, String value2) {
    return pw.TableRow(children: [
      pw.Container(
        padding: pw.EdgeInsets.symmetric(vertical: 2, horizontal: 4),
        child: pw.RichText(
            text: pw.TextSpan(children: [
          pw.TextSpan(
              text: '$label1 ',
              style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold)),
          pw.TextSpan(text: value1, style: pw.TextStyle(fontSize: 7)),
        ])),
      ),
      pw.Container(
        decoration: pw.BoxDecoration(
            border: pw.Border(left: pw.BorderSide(width: 0.5))),
        padding: pw.EdgeInsets.symmetric(vertical: 2, horizontal: 4),
        child: pw.RichText(
            text: pw.TextSpan(children: [
          pw.TextSpan(
              text: '$label2 ',
              style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold)),
          pw.TextSpan(text: value2, style: pw.TextStyle(fontSize: 7)),
        ])),
      ),
    ]);
  }

  pw.TableRow buildCheckRow(String num, String label, bool checked) {
    return pw.TableRow(children: [
      pw.Container(
        padding: pw.EdgeInsets.all(2),
        decoration: pw.BoxDecoration(
            border: pw.Border(right: pw.BorderSide(width: 0.5))),
        child: pw.Center(child: pw.Text(num, style: pw.TextStyle(fontSize: 6))),
      ),
      pw.Container(
        padding: pw.EdgeInsets.only(left: 4, top: 2, bottom: 2),
        child: pw.Text(label, style: pw.TextStyle(fontSize: 6)),
      ),
      pw.Container(
        padding: pw.EdgeInsets.all(2),
        decoration: pw.BoxDecoration(
            border: pw.Border(left: pw.BorderSide(width: 0.5))),
        child: pw.Center(
            child: pw.Text(checked ? 'OK' : '',
                style:
                    pw.TextStyle(fontSize: 6, fontWeight: pw.FontWeight.bold))),
      ),
    ]);
  }

  pw.TableRow buildValueRow(String num, String label, String value) {
    return pw.TableRow(children: [
      pw.Container(
        padding: pw.EdgeInsets.all(2),
        decoration: pw.BoxDecoration(
            border: pw.Border(right: pw.BorderSide(width: 0.5))),
        child: pw.Center(child: pw.Text(num, style: pw.TextStyle(fontSize: 6))),
      ),
      pw.Container(
        padding: pw.EdgeInsets.only(left: 4, top: 2, bottom: 2),
        child: pw.Text(label, style: pw.TextStyle(fontSize: 6)),
      ),
      pw.Container(
        padding: pw.EdgeInsets.all(2),
        decoration: pw.BoxDecoration(
            border: pw.Border(left: pw.BorderSide(width: 0.5))),
        child: pw.Center(
            child: pw.Text(value,
                style:
                    pw.TextStyle(fontSize: 6, fontWeight: pw.FontWeight.bold))),
      ),
    ]);
  }

  String formatarData(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

  try {
    final pastaEmail = (emailCliente != null && emailCliente.isNotEmpty)
        ? emailCliente.trim()
        : 'sem_email';

    final bool precisaAssets = _cachedFontRegular == null ||
        _cachedFontBold == null ||
        _cachedLogo == null ||
        _cachedAssinatura == null;

    final List<Future> todasFutures = [
      FirebaseFirestore.instance
          .collection('PREVENTIVAS')
          .where('PATRIMONIO', isEqualTo: patrimonio)
          .get(),
      FirebaseFirestore.instance
          .collection('IMAGENS')
          .where('PATRIMONIO', isEqualTo: patrimonio)
          .limit(1)
          .get(),
      (emailCliente != null && emailCliente.isNotEmpty)
          ? FirebaseFirestore.instance
              .collection('USUARIOS')
              .where('email', isEqualTo: emailCliente.trim())
              .limit(1)
              .get()
          : Future.value(null),
    ];

    if (precisaAssets) {
      todasFutures.addAll([
        _cachedFontRegular != null
            ? Future.value(_cachedFontRegular!)
            : PdfGoogleFonts.openSansRegular(),
        _cachedFontBold != null
            ? Future.value(_cachedFontBold!)
            : PdfGoogleFonts.openSansBold(),
        _cachedLogo != null
            ? Future.value(_cachedLogo!)
            : _fetchAndCompress(_urlLogo,
                maxWidth: _kMaxWidthPequenas, quality: _kJpegQualityAssets),
        _cachedAssinatura != null
            ? Future.value(_cachedAssinatura!)
            : _fetchAndCompress(_urlAssinatura,
                maxWidth: _kMaxWidthAssinatura,
                quality: _kQualityAssinatura,
                isPng: true),
      ]);
    }

    final results = await Future.wait(todasFutures);

    final prevQuery = results[0] as QuerySnapshot<Map<String, dynamic>>;
    final imgQuery = results[1] as QuerySnapshot<Map<String, dynamic>>;
    final usuariosQuery = results[2] as QuerySnapshot<Map<String, dynamic>>?;

    if (precisaAssets) {
      _cachedFontRegular = results[3] as pw.Font;
      _cachedFontBold = results[4] as pw.Font;
      final logo = results[5] as Uint8List?;
      final assinatura = results[6] as Uint8List?;
      if (logo != null) _cachedLogo = logo;
      if (assinatura != null) _cachedAssinatura = assinatura;
    }

    final fontRegular = _cachedFontRegular!;
    final fontBold = _cachedFontBold!;
    final logoBytes = _cachedLogo;
    final assinaturaBytes = _cachedAssinatura;

    if (prevQuery.docs.isEmpty) return;

    final listaDocs = prevQuery.docs.toList()
      ..sort((a, b) {
        final dataA = (a.data()['DATADAMANUTENCAO'] as Timestamp?)?.toDate();
        final dataB = (b.data()['DATADAMANUTENCAO'] as Timestamp?)?.toDate();
        if (dataA == null) return 1;
        if (dataB == null) return -1;
        return dataB.compareTo(dataA);
      });

    final data = listaDocs.first.data();

    String nomeClienteRodape = '';
    String cnpjClienteRodape = '';
    String? fotoClienteUrl;
    List<String> emailsAdicionais =
        []; // E-mails adicionais do cadastro do cliente

    if (usuariosQuery != null && usuariosQuery.docs.isNotEmpty) {
      final userData = usuariosQuery.docs.first.data();
      nomeClienteRodape =
          (userData['display_name'] ?? '').toString().toUpperCase();
      cnpjClienteRodape =
          (userData['CNPJ'] ?? userData['cnpj'] ?? '').toString();
      final photoUrl = userData['photo_url']?.toString().trim();
      if (photoUrl != null && photoUrl.startsWith('http')) {
        fotoClienteUrl = photoUrl;
      }

      // Resgata os e-mails adicionais do campo 'emailteste'
      final fieldTeste = userData['emailteste'];
      if (fieldTeste is List) {
        emailsAdicionais = fieldTeste
            .map((e) => e.toString().trim())
            .where((e) => e.isNotEmpty)
            .toList();
      } else if (fieldTeste is String && fieldTeste.trim().isNotEmpty) {
        emailsAdicionais.add(fieldTeste.trim());
      }
    }

    String? imgEvaporadoraUrl;
    if (imgQuery.docs.isNotEmpty) {
      final url = imgQuery.docs.first.data()['IMAGEM']?.toString().trim();
      if (url != null && url.startsWith('http')) imgEvaporadoraUrl = url;
    }

    String? urlTermo;
    for (final key in ['IMAGEM', 'FOTO', 'foto', 'imagem']) {
      final v = data[key]?.toString().trim();
      if (v != null && v.isNotEmpty) {
        urlTermo = v;
        break;
      }
    }

    final imageResults = await Future.wait([
      fotoClienteUrl != null
          ? _fetchAndCompress(fotoClienteUrl,
              maxWidth: _kMaxWidthPequenas, quality: _kJpegQualityFotos)
          : Future.value(null),
      imgEvaporadoraUrl != null
          ? _fetchAndCompress(imgEvaporadoraUrl,
              maxWidth: _kMaxWidthFotosGrandes, quality: _kJpegQualityFotos)
          : Future.value(null),
      (urlTermo != null && urlTermo.startsWith('http'))
          ? _fetchAndCompress(urlTermo,
              maxWidth: _kMaxWidthFotosGrandes, quality: _kJpegQualityFotos)
          : Future.value(null),
    ]);

    final imagemCliente =
        imageResults[0] != null ? pw.MemoryImage(imageResults[0]!) : null;
    final imagemEvaporadora =
        imageResults[1] != null ? pw.MemoryImage(imageResults[1]!) : null;
    final imagemTermografia =
        imageResults[2] != null ? pw.MemoryImage(imageResults[2]!) : null;
    final logoEmpresa = logoBytes != null ? pw.MemoryImage(logoBytes) : null;
    final assinaturaHPS =
        assinaturaBytes != null ? pw.MemoryImage(assinaturaBytes) : null;

    bool checkLimpezaCompressor = false;
    const tentativasChave = [
      'LIMPEZAELUBRIFICAODOCOMPRESSO',
      'LIMPEZAELUBRIFICAODOCOMPRESSOR',
      'LIMPEZACOMPRESSOR'
    ];
    for (final key in tentativasChave) {
      if (data[key] == true) {
        checkLimpezaCompressor = true;
        break;
      }
    }
    if (!checkLimpezaCompressor) {
      for (final key in data.keys) {
        final k = key.toUpperCase().replaceAll(' ', '');
        if (k.contains('LUBRIFICA') &&
            (k.contains('COMPRESS') || k.contains('MOTOR')) &&
            data[key] == true) {
          checkLimpezaCompressor = true;
          break;
        }
      }
    }

    final dataInicio = data['DATADAMANUTENCAO'] != null
        ? formatarData((data['DATADAMANUTENCAO'] as Timestamp).toDate())
        : '';
    final textoObservacao = (data['OBSERVACAO'] ?? '').toString().trim();

    const listaItensServico = [
      'Higienização: Aplicar produtos bactericidas específicos para eliminar microrganismos.',
      'Filtros de Ar: Remover, lavar com água corrente e sabão neutro, secar completamente.',
      'Medir e informar tensão elétrica',
      'Medir e informar corrente elétrica',
      'Limpar carenagem da evaporadora. Verificar ruídos, vazamentos e mau cheiro.',
    ];

    const tableBorder = pw.TableBorder(
      left: pw.BorderSide(width: 0.5),
      right: pw.BorderSide(width: 0.5),
      top: pw.BorderSide(width: 0.5),
      bottom: pw.BorderSide(width: 0.5),
      horizontalInside: pw.BorderSide(width: 0.5),
      verticalInside: pw.BorderSide(width: 0.5),
    );

    final pdf = pw.Document(
        theme: pw.ThemeData.withFont(base: fontRegular, bold: fontBold),
        compress: true);

    pdf.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.all(20),
      build: (context) =>
          pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        // CABEÇALHO
        pw.Container(
            height: 50,
            decoration: pw.BoxDecoration(border: pw.Border.all(width: 1)),
            child: pw.Row(children: [
              pw.Expanded(
                  flex: 3,
                  child: pw.Padding(
                      padding: pw.EdgeInsets.all(4),
                      child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          mainAxisAlignment: pw.MainAxisAlignment.center,
                          children: [
                            pw.Text('FORNECEDOR',
                                style: pw.TextStyle(
                                    fontSize: 8,
                                    fontWeight: pw.FontWeight.bold)),
                            if (logoEmpresa != null)
                              pw.Container(
                                  height: 30,
                                  alignment: pw.Alignment.centerLeft,
                                  child: pw.Image(logoEmpresa,
                                      fit: pw.BoxFit.contain, dpi: 72)),
                          ]))),
              pw.Expanded(
                  flex: 2,
                  child: pw.Column(
                      mainAxisAlignment: pw.MainAxisAlignment.center,
                      children: [
                        pw.Text('DATA DA MANUTENÇÃO',
                            style: pw.TextStyle(
                                fontSize: 6, fontWeight: pw.FontWeight.bold)),
                        pw.Text(dataInicio,
                            style: pw.TextStyle(
                                fontSize: 9, fontWeight: pw.FontWeight.bold)),
                      ])),
              pw.Expanded(
                  flex: 2,
                  child: pw.Container(
                      padding: pw.EdgeInsets.all(4),
                      child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.end,
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text('CLIENTE',
                                style: pw.TextStyle(
                                    fontSize: 8,
                                    fontWeight: pw.FontWeight.bold)),
                            if (imagemCliente != null)
                              pw.Container(
                                  height: 30,
                                  width: 80,
                                  alignment: pw.Alignment.bottomRight,
                                  child: pw.Image(imagemCliente,
                                      fit: pw.BoxFit.contain, dpi: 72))
                            else
                              pw.Text(nomeClienteRodape,
                                  style: pw.TextStyle(
                                      fontSize: 7,
                                      fontWeight: pw.FontWeight.bold)),
                          ]))),
            ])),
        pw.SizedBox(height: 5),

        // IDENTIFICAÇÃO
        pw.Container(
            decoration: pw.BoxDecoration(border: pw.Border.all(width: 0.5)),
            child: pw.Column(children: [
              pw.Container(
                  width: double.infinity,
                  color: PdfColors.grey200,
                  padding: pw.EdgeInsets.symmetric(vertical: 2),
                  child: pw.Center(
                      child: pw.Text('IDENTIFICAÇÃO',
                          style: pw.TextStyle(
                              fontSize: 8, fontWeight: pw.FontWeight.bold)))),
              pw.Divider(height: 1, thickness: 0.5),
              pw.Table(
                  border: pw.TableBorder.symmetric(
                      inside: pw.BorderSide(width: 0.5)),
                  columnWidths: {
                    0: pw.FlexColumnWidth(1),
                    1: pw.FlexColumnWidth(1)
                  },
                  children: [
                    buildIdentRow(
                        'APARELHO:',
                        data['NOME'] ??
                            data['EQUIPAMENTO'] ??
                            'AR CONDICIONADO',
                        'VOLTAGEM:',
                        data['TENSAO'] ?? ''),
                    buildIdentRow('MODELO:', data['MODELO'] ?? '', 'GÁS:',
                        data['FLUIDO'] ?? ''),
                    buildIdentRow('TIPO:', data['TIPO'] ?? '', 'POTÊNCIA:',
                        data['BTUS'] ?? ''),
                    buildIdentRow('FABRICANTE:', data['MARCA'] ?? '', 'PRÉDIO:',
                        data['SETOR'] ?? ''),
                    buildIdentRow('PATRIMÔNIO:', data['PATRIMONIO'] ?? '',
                        'LOCALIZAÇÃO:', data['SALA'] ?? ''),
                    buildIdentRow('TÉCNICO:', data['TECNICORESPONSAVEL'] ?? '',
                        'MANUTENÇÃO:', data['TIPOMANUTENCAO'] ?? 'PREVENTIVA'),
                  ]),
            ])),
        pw.SizedBox(height: 5),

        // BLOCO 1 — Imagem + Verificação Evaporadora
        pw.Container(
            height: 140,
            child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                children: [
                  pw.Expanded(
                      flex: 4,
                      child: pw.Container(
                          decoration: pw.BoxDecoration(
                              border: pw.Border.all(width: 0.5)),
                          child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                              children: [
                                pw.Container(
                                    color: PdfColors.grey200,
                                    padding:
                                        pw.EdgeInsets.symmetric(vertical: 2),
                                    child: pw.Center(
                                        child: pw.Text('IMAGENS DO APARELHO',
                                            style: pw.TextStyle(
                                                fontSize: 7,
                                                fontWeight:
                                                    pw.FontWeight.bold)))),
                                pw.Divider(height: 1, thickness: 0.5),
                                pw.Expanded(
                                    child: imagemEvaporadora != null
                                        ? pw.Image(imagemEvaporadora,
                                            fit: pw.BoxFit.cover, dpi: 96)
                                        : pw.Center(
                                            child: pw.Text('SEM IMAGEM',
                                                style: pw.TextStyle(
                                                    fontSize: 8)))),
                              ]))),
                  pw.SizedBox(width: 5),
                  pw.Expanded(
                      flex: 6,
                      child: pw.Container(
                          decoration: pw.BoxDecoration(
                              border: pw.Border.all(width: 0.5)),
                          child: pw.Column(children: [
                            pw.Container(
                                width: double.infinity,
                                color: PdfColors.grey200,
                                padding: pw.EdgeInsets.symmetric(vertical: 2),
                                child: pw.Center(
                                    child: pw.Text('CONDIÇÃO E VERIFICAÇÃO',
                                        style: pw.TextStyle(
                                            fontSize: 7,
                                            fontWeight: pw.FontWeight.bold)))),
                            pw.Table(border: tableBorder, columnWidths: {
                              0: pw.FixedColumnWidth(15),
                              1: pw.FlexColumnWidth(),
                              2: pw.FixedColumnWidth(25)
                            }, children: [
                              buildCheckRow(
                                  '1',
                                  'LIMPEZA DA EVAPORADORA INTERNA:',
                                  data['LIMPEZAEVAPORADORAINTERNA'] ?? false),
                              buildCheckRow('2', 'LIMPEZA DO FILTRO:',
                                  data['LIMPEZAFILTRO'] ?? false),
                              buildCheckRow('3', 'LIMPEZA COM BACTERICIDA:',
                                  data['LIMPEZABACTERICIDA'] ?? false),
                              buildCheckRow(
                                  '4',
                                  'VERIFICAÇÃO DO CONTROLE E PILHAS:',
                                  data['VERIFICAODOCONTROLPILHAS'] ?? false),
                              buildCheckRow('5', 'VERIFICAR RUÍDOS:',
                                  data['VERIFICAODERUIDOS'] ?? false),
                              buildCheckRow('6', 'VERIFICAR MAL CHEIRO:',
                                  data['VERIFICAOMALCHEIRO'] ?? false),
                              buildValueRow('7', 'CORRENTE ELÉTRICA (A):',
                                  data['AMPERAGEM'] ?? ''),
                              buildValueRow('8', 'TENSÃO ELÉTRICA (V):',
                                  data['TENSAO'] ?? ''),
                            ]),
                          ]))),
                ])),
        pw.SizedBox(height: 5),

        // BLOCO 2 — Termografia + Condensadora/Adicionais
        pw.Container(
            height: 195,
            child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                children: [
                  pw.Expanded(
                      flex: 4,
                      child: pw.Container(
                          decoration: pw.BoxDecoration(
                              border: pw.Border.all(width: 0.5)),
                          child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                              children: [
                                pw.Container(
                                    color: PdfColors.grey200,
                                    padding:
                                        pw.EdgeInsets.symmetric(vertical: 2),
                                    child: pw.Center(
                                        child: pw.Text('TERMOGRAFIA',
                                            style: pw.TextStyle(
                                                fontSize: 7,
                                                fontWeight:
                                                    pw.FontWeight.bold)))),
                                pw.Divider(height: 1, thickness: 0.5),
                                pw.Expanded(
                                    child: imagemTermografia != null
                                        ? pw.Image(imagemTermografia,
                                            fit: pw.BoxFit.cover, dpi: 96)
                                        : pw.Center(
                                            child: pw.Text('',
                                                style: pw.TextStyle(
                                                    fontSize: 20)))),
                              ]))),
                  pw.SizedBox(width: 5),
                  pw.Expanded(
                      flex: 6,
                      child: pw.Container(
                          decoration: pw.BoxDecoration(
                              border: pw.Border.all(width: 0.5)),
                          child: pw.Table(border: tableBorder, columnWidths: {
                            0: pw.FixedColumnWidth(15),
                            1: pw.FlexColumnWidth(),
                            2: pw.FixedColumnWidth(25)
                          }, children: [
                            buildCheckRow('1', 'VERIFICAR DRENO:',
                                data['VERIFICAODODRENO'] ?? false),
                            buildCheckRow('2', 'VERIFICAR PRESSÃO (PSI):',
                                data['VERIFICAODAPRESSAO'] ?? false),
                            buildCheckRow('3', 'POLIR CONDENSADORA:',
                                data['POLIRCONDENSADORA'] ?? false),
                            buildCheckRow('4', 'VERIFICAR PARTE ELÉTRICA:',
                                data['VERIFICAODAPARTEELETRICA'] ?? false),
                            buildCheckRow('5', 'VERIFICAR ISOLAMENTO TÉRMICO:',
                                data['VERIFICAODOISOLAMENTOTRMICO'] ?? false),
                            buildCheckRow('6', 'JATEAMENTO DA CONDENSADORA:',
                                data['JATEAMENTOCONDENSADORA'] ?? false),
                            buildCheckRow('7', 'JATEAMENTO DA EVAPORADORA:',
                                data['JATEAMENTOEVAPORADORA'] ?? false),
                            buildCheckRow('8', 'LAVAGEM DO DRENO:',
                                data['LAVAGEMDRENO'] ?? false),
                            buildCheckRow(
                                '9',
                                'LAVAGEM DA CARCAÇA EVAPORADORA:',
                                data['LAVAGEMCARCACAEVAP'] ?? false),
                            buildCheckRow(
                                '10',
                                'LAVAGEM DA CARCAÇA CONDENSADORA:',
                                data['LAVAGEMCARCACACOND'] ?? false),
                            buildCheckRow(
                                '11',
                                'LIMPEZA E LUBRIFICAÇÃO DO COMPRESSOR:',
                                checkLimpezaCompressor),
                            buildCheckRow(
                                '12',
                                'LAVAGEM DA TURBINA EVAPORADORA:',
                                data['LAVAGEMTURBINAEVAP'] ?? false),
                            buildCheckRow('13', 'VERIFICAR PÉS DE BORRACHA:',
                                data['VERIFICAODOSPEDEBORRACHA'] ?? false),
                          ]))),
                ])),
        pw.SizedBox(height: 5),

        // TABELA SERVIÇOS
        pw.Container(
            decoration: pw.BoxDecoration(border: pw.Border.all(width: 0.5)),
            child: pw.Table(border: tableBorder, columnWidths: {
              0: pw.FixedColumnWidth(25),
              1: pw.FlexColumnWidth(),
              2: pw.FixedColumnWidth(40)
            }, children: [
              pw.TableRow(
                  decoration: pw.BoxDecoration(color: PdfColors.grey200),
                  children: [
                    pw.Padding(
                        padding: pw.EdgeInsets.all(2),
                        child: pw.Center(
                            child: pw.Text('ITEM',
                                style: pw.TextStyle(
                                    fontSize: 7,
                                    fontWeight: pw.FontWeight.bold)))),
                    pw.Padding(
                        padding: pw.EdgeInsets.all(2),
                        child: pw.Text('DESCRIÇÃO SERVIÇO',
                            style: pw.TextStyle(
                                fontSize: 7, fontWeight: pw.FontWeight.bold))),
                    pw.Padding(
                        padding: pw.EdgeInsets.all(2),
                        child: pw.Center(
                            child: pw.Text('STATUS',
                                style: pw.TextStyle(
                                    fontSize: 7,
                                    fontWeight: pw.FontWeight.bold)))),
                  ]),
              for (int i = 0; i < 5; i++)
                pw.TableRow(children: [
                  pw.Padding(
                      padding: pw.EdgeInsets.all(2),
                      child: pw.Center(
                          child: pw.Text('${i + 1}',
                              style: pw.TextStyle(fontSize: 7)))),
                  pw.Padding(
                      padding: pw.EdgeInsets.all(2),
                      child: pw.Text(listaItensServico[i],
                          style: pw.TextStyle(fontSize: 7))),
                  pw.Padding(
                      padding: pw.EdgeInsets.all(2),
                      child: pw.Center(
                          child: pw.Text('OK',
                              style: pw.TextStyle(
                                  fontSize: 7,
                                  fontWeight: pw.FontWeight.bold)))),
                ]),
            ])),
        pw.SizedBox(height: 5),

        // OBSERVAÇÕES
        pw.Container(
            width: double.infinity,
            height: 80,
            decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.black, width: 0.5)),
            padding: pw.EdgeInsets.all(5),
            child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('INFORMAÇÕES ADICIONAIS',
                      style: pw.TextStyle(
                          fontSize: 7, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 2),
                  if (textoObservacao.isNotEmpty)
                    pw.Text(textoObservacao, style: pw.TextStyle(fontSize: 7)),
                ])),

        pw.Spacer(),

        // ASSINATURAS
        pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Container(
                        height: 40,
                        width: 150,
                        alignment: pw.Alignment.bottomCenter,
                        child: assinaturaHPS != null
                            ? pw.Image(assinaturaHPS,
                                fit: pw.BoxFit.contain, dpi: 150)
                            : null),
                    pw.Container(
                        width: 150, height: 0.5, color: PdfColors.black),
                    pw.SizedBox(height: 2),
                    pw.Text('HPS REFRIGERAÇÃO',
                        style: pw.TextStyle(
                            fontSize: 7, fontWeight: pw.FontWeight.bold)),
                    pw.Text('CNPJ: 28.340.152/0001-52',
                        style: pw.TextStyle(fontSize: 6)),
                  ]),
              pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Container(
                        height: 40,
                        width: 150,
                        alignment: pw.Alignment.bottomCenter),
                    pw.Container(
                        width: 150, height: 0.5, color: PdfColors.black),
                    pw.SizedBox(height: 2),
                    pw.Text(
                        nomeClienteRodape.isNotEmpty
                            ? nomeClienteRodape
                            : 'CLIENTE',
                        style: pw.TextStyle(
                            fontSize: 7, fontWeight: pw.FontWeight.bold)),
                    if (cnpjClienteRodape.isNotEmpty)
                      pw.Text('CNPJ: $cnpjClienteRodape',
                          style: pw.TextStyle(fontSize: 6)),
                  ]),
            ]),
        pw.SizedBox(height: 10),

        // RODAPÉ
        pw.Center(
            child: pw.Column(children: [
          pw.Text('AV PARÁ 486 IBIRAPUERA VITÓRIA DA CONQUISTA- BA',
              style: pw.TextStyle(fontSize: 6, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 2),
          pw.Text('Tel: (77) 98819-4630 / 98861-2447  -  www.hpsrefri.com.br',
              style: pw.TextStyle(fontSize: 6)),
        ])),
      ]),
    ));

    // LISTA SEM Ç para o storage
    const listaMesesPasta = [
      'Janeiro',
      'Fevereiro',
      'Marco',
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

    final storagePath =
        '$pastaEmail/$anoSelecionado/${listaMesesPasta[mesSelecionado - 1]}/${patrimonio.trim()}.pdf';

    final Uint8List pdfUint8 = Uint8List.fromList(await pdf.save());

    // ── Upload para o Firebase Storage
    final uploadFuture = firebase_storage.FirebaseStorage.instance
        .ref()
        .child(storagePath)
        .putData(pdfUint8,
            firebase_storage.SettableMetadata(contentType: 'application/pdf'));

    // ── Envio de e-mail via Brevo (Novo!)
    if (emailCliente != null && emailCliente.contains('@')) {
      try {
        final toEmails = [emailCliente.trim(), ...emailsAdicionais];
        await _enviarEmailComPDF(
          toEmails: toEmails,
          nomeCliente: nomeClienteRodape,
          mes: listaMesesPasta[mesSelecionado - 1],
          ano: anoSelecionado.toString(),
          pdfBytes: pdfUint8,
          patrimonio: patrimonio,
        );
        print('Email enviado com sucesso!');
      } catch (e) {
        print('Erro no envio de email: $e');
      }
    }

    // ── Chamada nativa de impressão
    Printing.layoutPdf(
        onLayout: (_) async => pdfUint8,
        name: '${patrimonio.trim()}_preventiva.pdf');

    await uploadFuture;
  } catch (e) {
    print('Erro PDF: $e');
  }
}

// ============================================================
// WIDGET PRINCIPAL
// ============================================================
class CadastrarPreventivaWidget extends StatefulWidget {
  const CadastrarPreventivaWidget({
    super.key,
    this.width,
    this.height,
    this.tipoManutencaoList,
    this.onSalvar,
  });

  final double? width;
  final double? height;
  final List<String>? tipoManutencaoList;
  final Future Function()? onSalvar;

  @override
  State<CadastrarPreventivaWidget> createState() =>
      _CadastrarPreventivaWidgetState();
}

class _CadastrarPreventivaWidgetState extends State<CadastrarPreventivaWidget> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;
  bool _isGerandoPDF = false;
  double _progressoPDF = 0.0;
  String _statusPDF = '';

  // ── Busca por patrimônio ──────────────────────────────────────────────────
  bool _isBuscando = false;
  bool _equipamentoEncontrado = false;
  bool _equipamentoNaoEncontrado = false;
  String? _equipamentoDocId;
  Timer? _debounce;

  // ── Controladores de texto ────────────────────────────────────────────────
  final _patrimonioCtrl = TextEditingController();
  final _marcaCtrl = TextEditingController();
  final _modeloCtrl = TextEditingController();
  final _equipamentoCtrl = TextEditingController();
  final _btusCtrl = TextEditingController();
  final _fluidoCtrl = TextEditingController();
  final _salaCtrl = TextEditingController();
  final _setorCtrl = TextEditingController();
  final _tensaoCtrl = TextEditingController();
  final _amperagemCtrl = TextEditingController();
  final _responsavelCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _tipoCtrl = TextEditingController();
  final _obsCtrl = TextEditingController();

  // ── FocusNodes ────────────────────────────────────────────────────────────
  final _tensaoFocus = FocusNode();
  final _amperagemFocus = FocusNode();

  // ── Dropdowns ─────────────────────────────────────────────────────────────
  String? _tecnico;
  String? _tipoManutencao;

  // ── Data ──────────────────────────────────────────────────────────────────
  int _mesSelecionado = DateTime.now().month;
  int _anoSelecionado = DateTime.now().year;
  static const List<String> _meses = [
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
    'Dezembro',
  ];

  // ── Foto ──────────────────────────────────────────────────────────────────
  FFUploadedFile? _fotoFile;
  final _picker = ImagePicker();

  // ── Técnicos do Firestore ─────────────────────────────────────────────────
  List<String> _tecnicosFirestore = [];
  bool _carregandoTecnicos = true;

  // ═══════════════════════════════════════════════════════════════════════════
  // CHECKBOXES — organizados conforme o PDF
  // ═══════════════════════════════════════════════════════════════════════════

  // EVAPORADORA (8 itens)
  bool _limpezaEvapInterna = false;
  bool _limpezaFiltro = false;
  bool _limpezaBactericida = false;
  bool _verControlePilhas = false;
  bool _verRuidos = false;
  bool _verMalCheiro = false;
  bool _medicaoCorrente = false;
  bool _medicaoTensaoEletrica = false;

  // CONDENSADORA (5 itens)
  bool _verDreno = false;
  bool _verPressao = false;
  bool _polirCondensadora = false;
  bool _verParteEletrica = false;
  bool _verIsolamento = false;

  // SERVIÇOS ADICIONAIS (9 itens)
  bool _jateamentoCondensadora = false;
  bool _jateamentoEvaporadora = false;
  bool _lavagemDreno = false;
  bool _lavagemCarcacaEvap = false;
  bool _lavagemCarcacaCond = false;
  bool _limpezaCompressor = false;
  bool _lavagemTurbinaEvap = false;
  bool _verPesBorracha = false;

  // ── Cores ─────────────────────────────────────────────────────────────────
  Color get _primary => const Color(0xFF0F766E);
  Color get _red => const Color(0xFFB91C1C);
  Color get _green => const Color(0xFF388E3C);
  Color get _orange => const Color(0xFFC2410C);
  Color get _bg => const Color(0xFF1A1A2E);
  Color get _card => const Color(0xFF16213E);
  Color get _border => const Color(0xFF0F766E).withOpacity(0.5);
  Color get _textColor => Colors.white;
  Color get _hintColor => Colors.white54;

  // ═══════════════════════════════════════════════════════════════════════════
  // INIT / DISPOSE
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  void initState() {
    super.initState();
    _patrimonioCtrl.addListener(_onPatrimonioChanged);
    _tensaoFocus.addListener(_onTensaoFocus);
    _amperagemFocus.addListener(_onAmperagemFocus);
    _buscarTecnicos();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _patrimonioCtrl.removeListener(_onPatrimonioChanged);
    _tensaoFocus.removeListener(_onTensaoFocus);
    _amperagemFocus.removeListener(_onAmperagemFocus);
    for (final c in [
      _patrimonioCtrl,
      _marcaCtrl,
      _modeloCtrl,
      _equipamentoCtrl,
      _btusCtrl,
      _fluidoCtrl,
      _salaCtrl,
      _setorCtrl,
      _tensaoCtrl,
      _amperagemCtrl,
      _responsavelCtrl,
      _emailCtrl,
      _tipoCtrl,
      _obsCtrl,
    ]) {
      c.dispose();
    }
    _tensaoFocus.dispose();
    _amperagemFocus.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // BUSCA PATRIMÔNIO — debounce 600ms, mínimo 1 caractere
  // ═══════════════════════════════════════════════════════════════════════════

  void _onPatrimonioChanged() {
    final valor = _patrimonioCtrl.text.trim();
    if (valor.isEmpty) {
      _debounce?.cancel();
      _limparCamposEquipamento();
      return;
    }
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 600), () {
      _buscarEquipamento(valor);
    });
  }

  Future<void> _buscarEquipamento(String patrimonio) async {
    if (!mounted) return;
    setState(() {
      _isBuscando = true;
      _equipamentoEncontrado = false;
      _equipamentoNaoEncontrado = false;
    });

    try {
      QuerySnapshot? snap;
      for (final campo in [
        'patrimonio',
        'PATRIMONIO',
        'patrimônio',
        'PATRIMÔNIO'
      ]) {
        snap = await FirebaseFirestore.instance
            .collection('EQUIPAMENTOS_EMPRESA')
            .where(campo, isEqualTo: patrimonio)
            .limit(1)
            .get();
        if (snap.docs.isNotEmpty) break;
      }
      if (!mounted) return;

      if (snap != null && snap.docs.isNotEmpty) {
        final doc = snap.docs.first;
        _equipamentoDocId = doc.id;
        _preencherCampos(doc.data() as Map<String, dynamic>);
        setState(() {
          _isBuscando = false;
          _equipamentoEncontrado = true;
          _equipamentoNaoEncontrado = false;
        });
      } else {
        setState(() {
          _isBuscando = false;
          _equipamentoEncontrado = false;
          _equipamentoNaoEncontrado = true;
        });
      }
    } catch (_) {
      if (mounted)
        setState(() {
          _isBuscando = false;
        });
    }
  }

  void _preencherCampos(Map<String, dynamic> data) {
    String get(List<String> keys) {
      for (final k in keys) {
        if (data.containsKey(k) && data[k] != null) {
          return data[k].toString().trim();
        }
      }
      return '';
    }

    setState(() {
      _equipamentoCtrl.text = get([
        'equipamento',
        'EQUIPAMENTO',
        'aparelho',
        'APARELHO',
        'nome',
        'NOME'
      ]);
      _marcaCtrl.text = get(['marca', 'MARCA', 'fabricante', 'FABRICANTE']);
      _modeloCtrl.text = get(['modelo', 'MODELO']);
      _salaCtrl.text = get(['sala', 'SALA']);
      _setorCtrl.text = get(
          ['setor', 'SETOR', 'localizacao', 'localização', 'local', 'LOCAL']);
      _responsavelCtrl.text =
          get(['responsavel', 'RESPONSAVEL', 'responsável', 'RESPONSÁVEL']);
      _emailCtrl.text = get(['email', 'EMAIL', 'Email', 'e_mail', 'E_MAIL']);
      _btusCtrl.text =
          get(['btus', 'BTUS', 'potencia', 'potência', 'POTENCIA', 'POTÊNCIA']);
      _fluidoCtrl.text =
          get(['fluido', 'FLUIDO', 'fluído', 'FLUÍDO', 'gas', 'GAS']);
      _tensaoCtrl.text =
          get(['tensao', 'TENSAO', 'tensão', 'TENSÃO', 'voltagem', 'VOLTAGEM']);
      _amperagemCtrl.text =
          get(['amperagem', 'AMPERAGEM', 'corrente', 'CORRENTE']);

      // Tipo
      final tipoRaw = get(['tipo', 'TIPO', 'tpo', 'TPO']);
      if (tipoRaw.isNotEmpty) {
        const aliases = <String, String>{
          'split': 'CONVENCIONAL',
          'convencional': 'CONVENCIONAL',
          'inverter': 'INVERTER',
          'janela': 'JANELA',
          'piso teto': 'PISO TETO',
          'piso': 'PISO TETO',
          'cassete': 'CONVENCIONAL',
          'k7': 'K7',
        };
        _tipoCtrl.text =
            aliases[tipoRaw.toLowerCase()] ?? tipoRaw.toUpperCase();
      }
    });
  }

  void _limparCamposEquipamento() {
    setState(() {
      _isBuscando = false;
      _equipamentoEncontrado = false;
      _equipamentoNaoEncontrado = false;
      _equipamentoDocId = null;
    });
    for (final c in [
      _marcaCtrl,
      _modeloCtrl,
      _equipamentoCtrl,
      _tipoCtrl,
      _btusCtrl,
      _fluidoCtrl,
      _salaCtrl,
      _setorCtrl,
      _tensaoCtrl,
      _amperagemCtrl,
      _responsavelCtrl,
      _emailCtrl,
    ]) {
      c.clear();
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // AUTO-SELEÇÃO DE CHECKBOXES POR TIPO DE MANUTENÇÃO
  // ═══════════════════════════════════════════════════════════════════════════

  void _aplicarChecksPorTipo(String? tipo) {
    if (tipo == null) return;
    final t = tipo.toUpperCase();

    // Mensal — itens básicos
    final mensal = t.contains('MENSAL');
    final trimestral = t.contains('TRIMESTRAL');
    final semestral = t.contains('SEMESTRAL');
    final anual = t.contains('ANUAL');

    // Hierarquia: ANUAL ⊃ SEMESTRAL ⊃ TRIMESTRAL ⊃ MENSAL
    final isM = mensal || trimestral || semestral || anual;
    final isT = trimestral || semestral || anual;
    final isS = semestral || anual;
    final isA = anual;

    setState(() {
      // ── EVAPORADORA ──────────────────────────────────────────────────────
      _limpezaEvapInterna = isM;
      _limpezaFiltro = isM;
      _limpezaBactericida = isM;
      _verControlePilhas = isM;
      _verRuidos = isM;
      _verMalCheiro = isM;
      _medicaoCorrente = isM;
      _medicaoTensaoEletrica = isM;

      // ── CONDENSADORA ─────────────────────────────────────────────────────
      _verDreno = isM;
      _verPressao = isM;
      _verParteEletrica = isM;
      _verIsolamento = isM;
      _polirCondensadora = isT; // a partir do trimestral

      // ── SERVIÇOS ADICIONAIS ───────────────────────────────────────────────
      _lavagemTurbinaEvap = isS; // semestral em diante
      _jateamentoCondensadora = isS;
      _jateamentoEvaporadora = isS;
      _lavagemDreno = isS;
      _lavagemCarcacaEvap = isA; // apenas anual
      _lavagemCarcacaCond = isA;
      _limpezaCompressor = isA;
      _verPesBorracha = isA;
    });
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // FORMATAÇÃO TENSÃO / AMPERAGEM
  // ═══════════════════════════════════════════════════════════════════════════

  void _onTensaoFocus() {
    if (_tensaoFocus.hasFocus) {
      final raw = _tensaoCtrl.text.replaceAll(RegExp(r'[^0-9]'), '');
      _tensaoCtrl.value = TextEditingValue(
          text: raw, selection: TextSelection.collapsed(offset: raw.length));
    } else {
      final raw = _tensaoCtrl.text.replaceAll(RegExp(r'[^0-9]'), '');
      if (raw.isNotEmpty) {
        _tensaoCtrl.value = TextEditingValue(
            text: '${raw}V',
            selection: TextSelection.collapsed(offset: raw.length + 1));
      }
    }
  }

  void _onAmperagemFocus() {
    if (_amperagemFocus.hasFocus) {
      final raw = _amperagemCtrl.text.replaceAll(RegExp(r'[^0-9.,]'), '');
      _amperagemCtrl.value = TextEditingValue(
          text: raw, selection: TextSelection.collapsed(offset: raw.length));
    } else {
      final raw = _amperagemCtrl.text.replaceAll(RegExp(r'[^0-9.,]'), '');
      if (raw.isNotEmpty) {
        _amperagemCtrl.value = TextEditingValue(
            text: '${raw}A',
            selection: TextSelection.collapsed(offset: raw.length + 1));
      }
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // TÉCNICOS DO FIRESTORE — coleção PONTOS_POR_TECNICO
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> _buscarTecnicos() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('PONTOS_POR_TECNICO')
          .get();
      final nomes = snap.docs
          .map((doc) {
            final d = doc.data();
            return (d['nome'] ??
                    d['NOME'] ??
                    d['tecnico'] ??
                    d['TECNICO'] ??
                    doc.id)
                .toString()
                .trim();
          })
          .where((n) => n.isNotEmpty)
          .toList()
        ..sort();
      if (mounted)
        setState(() {
          _tecnicosFirestore = nomes;
          _carregandoTecnicos = false;
        });
    } catch (_) {
      if (mounted) setState(() => _carregandoTecnicos = false);
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // GERAR PDF COM PROGRESSO E ENVIO DE EMAIL
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> _gerarPDF() async {
    final patrimonio = _patrimonioCtrl.text.trim();
    final email = _emailCtrl.text.trim();

    if (patrimonio.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Informe o patrimônio antes de gerar o PDF'),
        backgroundColor: _red,
      ));
      return;
    }

    setState(() {
      _isGerandoPDF = true;
      _progressoPDF = 0.0;
      _statusPDF = 'Iniciando...';
    });

    try {
      // ── ETAPA 1: Pré-carregar fontes e assets estáticos ─────────────
      setState(() {
        _progressoPDF = 0.10;
        _statusPDF = 'Carregando fontes e logo...';
      });
      await preCarregarAssetsPDF();

      // ── ETAPA 2: Buscando dados no Firestore ─────────────────────────
      setState(() {
        _progressoPDF = 0.25;
        _statusPDF = 'Buscando dados do Firestore...';
      });
      await Future.delayed(const Duration(milliseconds: 50));

      // ── ETAPA 3: Baixando imagens dinâmicas ──────────────────────────
      setState(() {
        _progressoPDF = 0.45;
        _statusPDF = 'Baixando imagens do equipamento...';
      });
      await Future.delayed(const Duration(milliseconds: 50));

      // ── ETAPA 4: Montando layout do PDF ──────────────────────────────
      setState(() {
        _progressoPDF = 0.65;
        _statusPDF = 'Montando layout do PDF...';
      });

      // ── ETAPA 5: Gera o PDF, sobe pro Storage e envia E-MAIL ─────────
      setState(() {
        _progressoPDF = 0.85;
        _statusPDF = 'Enviando para o servidor e e-mail...';
      });

      await geraPDFPreventiva(patrimonio, email.isNotEmpty ? email : null,
          _mesSelecionado, _anoSelecionado);

      // ── ETAPA 6: Concluído ────────────────────────────────────────────
      setState(() {
        _progressoPDF = 1.0;
        _statusPDF = 'PDF e E-mail enviados com sucesso! ✓';
      });
      await Future.delayed(const Duration(milliseconds: 800));

      // Fechar o bottom sheet
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        setState(() {
          _isGerandoPDF = false;
          _statusPDF = '';
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Erro ao gerar PDF: $e'),
          backgroundColor: _red,
          duration: const Duration(seconds: 4),
        ));
      }
    } finally {
      if (mounted)
        setState(() {
          _isGerandoPDF = false;
          _statusPDF = '';
        });
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // FOTO
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> _pickFoto() async {
    // imageQuality: 50 = compressão ~50% sem lib externa, funciona na Web e Mobile
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
      maxWidth: 800,
      maxHeight: 800,
    );
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() => _fotoFile = FFUploadedFile(
            name: picked.name,
            bytes: bytes,
          ));
    }
  }

  Future<String?> _uploadFoto() async {
    if (_fotoFile == null) return null;
    try {
      // 1. Converte para base64 usando a custom action do FlutterFlow
      final base64Image = uploadedFileToBase64(_fotoFile!);
      // 2. Envia ao ImgBB usando a custom action do FlutterFlow
      const apiKey = 'SUA_API_KEY_AQUI'; // ← substitua pela sua chave ImgBB
      final url = await uploadImageToImgBB(apiKey, base64Image);
      return url;
    } catch (_) {
      return null;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SALVAR
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> _salvar() async {
    // ── Validação do formulário ──────────────────────────────────────────
    if (!_formKey.currentState!.validate()) return;

    // ── Campos obrigatórios extras (não cobertos pelo Form) ──────────────
    final camposFaltando = <String>[];
    if (_equipamentoCtrl.text.trim().isEmpty) camposFaltando.add('Equipamento');
    if (_marcaCtrl.text.trim().isEmpty) camposFaltando.add('Marca');
    if (_modeloCtrl.text.trim().isEmpty) camposFaltando.add('Modelo');
    if (_salaCtrl.text.trim().isEmpty) camposFaltando.add('Sala');
    if (_setorCtrl.text.trim().isEmpty) camposFaltando.add('Setor');
    if (_responsavelCtrl.text.trim().isEmpty) camposFaltando.add('Responsável');
    if (_tensaoCtrl.text.replaceAll(RegExp(r'[^0-9]'), '').isEmpty)
      camposFaltando.add('Tensão');
    if (_tecnico == null) camposFaltando.add('Técnico');
    if (_tipoManutencao == null) camposFaltando.add('Tipo da Manutenção');
    if (_fotoFile == null) camposFaltando.add('Foto do equipamento');

    if (camposFaltando.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Preencha os campos obrigatórios:',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 4),
            Text('• ${camposFaltando.join('\n• ')}',
                style: const TextStyle(color: Colors.white, fontSize: 13)),
          ],
        ),
        backgroundColor: _red,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }

    setState(() => _isSaving = true);
    try {
      final patrimonio = _patrimonioCtrl.text.trim();
      // Upload para ImgBB — somente após validação completa
      final fotoUrl = await _uploadFoto();

      await FirebaseFirestore.instance.collection('PREVENTIVAS').add({
        'NOME': _equipamentoCtrl.text.trim(),
        'OBSERVACAO': _obsCtrl.text.trim(),
        'PATRIMONIO': patrimonio,
        'RESPONSAVEL': _responsavelCtrl.text.trim(),
        'SALA': _salaCtrl.text.trim(),
        'SETOR': _setorCtrl.text.trim(),
        'TECNICORESPONSAVEL': _tecnico,
        'TENSAO': _tensaoCtrl.text.trim(),
        'AMPERAGEM': _amperagemCtrl.text.trim(),
        'TIPO': _tipoCtrl.text.trim(),
        'VERIFICAODERUIDOS': _verRuidos,
        'VERIFICAODODRENO': _verDreno,
        'VERIFICAODOISOLAMENTOTRMICO': _verIsolamento,
        'VERIFICAODOSACABAMENTOS': false,
        'MES': _meses[_mesSelecionado - 1].toUpperCase(), // ex: FEVEREIRO
        'ANO': _anoSelecionado,
        'TIPOMANUTENCAO': _tipoManutencao,
        'EMAIL': _emailCtrl.text.trim(),
        'IMAGEM': fotoUrl,
        'LIMPEZAEVAPORADORAINTERNA': _limpezaEvapInterna,
        'LIMPEZAFILTRO': _limpezaFiltro,
        'LIMPEZABACTERICIDA': _limpezaBactericida,
        'VERIFICAODOCONTROLPILHAS': _verControlePilhas,
        'VERIFICAOMALCHEIRO': _verMalCheiro,
        'MEDICAOCORRENTE': _medicaoCorrente,
        'MEDICAOTENSAOELETRICA': _medicaoTensaoEletrica,
        'VERIFICAODAPRESSAO': _verPressao,
        'POLIRCONDENSADORA': _polirCondensadora,
        'VERIFICAODAPARTEELETRICA': _verParteEletrica,
        'JATEAMENTOCONDENSADORA': _jateamentoCondensadora,
        'JATEAMENTOEVAPORADORA': _jateamentoEvaporadora,
        'LAVAGEMDRENO': _lavagemDreno,
        'LAVAGEMCARCACAEVAP': _lavagemCarcacaEvap,
        'LAVAGEMCARCACACOND': _lavagemCarcacaCond,
        'LIMPEZACOMPRESSOR': _limpezaCompressor,
        'LAVAGEMTURBINAEVAP': _lavagemTurbinaEvap,
        'VERIFICAODOSPEDEBORRACHA': _verPesBorracha,
        'datacadastro': FieldValue.serverTimestamp(),
        'status': 'concluida',
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Preventiva cadastrada com sucesso!'),
          backgroundColor: _green,
        ));
      }
      widget.onSalvar?.call();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Erro ao salvar: $e'),
          backgroundColor: _red,
        ));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // HELPERS DE UI
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _sectionTitle(String title) => Padding(
        padding: const EdgeInsets.only(top: 20, bottom: 10),
        child: Row(children: [
          Container(
              width: 4,
              height: 20,
              color: _primary,
              margin: const EdgeInsets.only(right: 10)),
          Text(title,
              style: TextStyle(
                  color: _textColor,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1)),
        ]),
      );

  InputDecoration _dec(String label,
          {bool isRed = false, bool readOnly = false}) =>
      InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: isRed ? _red : _hintColor,
          fontSize: 13,
          fontWeight: isRed ? FontWeight.bold : FontWeight.normal,
        ),
        filled: true,
        fillColor: readOnly ? _card.withOpacity(0.6) : _card,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
              BorderSide(color: readOnly ? _green.withOpacity(0.5) : _border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: _primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: _red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: _red, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        suffixIcon:
            readOnly ? Icon(Icons.auto_awesome, color: _green, size: 16) : null,
      );

  Widget _field(
    TextEditingController ctrl,
    String label, {
    bool isRed = false,
    bool readOnly = false,
    TextInputType? keyboardType,
    bool required = false,
  }) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextFormField(
          controller: ctrl,
          style: TextStyle(color: _textColor, fontSize: 14),
          keyboardType: keyboardType,
          readOnly: readOnly,
          decoration: _dec(label, isRed: isRed, readOnly: readOnly),
          validator: required
              ? (v) => (v == null || v.isEmpty) ? 'Obrigatório' : null
              : null,
        ),
      );

  Widget _sufixField(
    TextEditingController ctrl,
    String label,
    String suffix, {
    FocusNode? focusNode,
    bool isRed = false,
  }) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextFormField(
          controller: ctrl,
          focusNode: focusNode,
          style: TextStyle(color: _textColor, fontSize: 14),
          keyboardType: TextInputType.number,
          decoration: _dec(label, isRed: isRed).copyWith(
            suffixText: suffix,
            suffixStyle: TextStyle(
                color: _primary, fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ),
      );

  Widget _checkItem(String label, bool value, ValueChanged<bool?> onChanged) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(children: [
          SizedBox(
            width: 24,
            height: 24,
            child: Checkbox(
              value: value,
              onChanged: onChanged,
              activeColor: _primary,
              checkColor: Colors.black,
              side: BorderSide(color: _border),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                children: label.split(' ').asMap().entries.map((e) {
                  final word = e.value;
                  final bold = word == word.toUpperCase() && word.isNotEmpty;
                  final last = e.key == label.split(' ').length - 1;
                  return TextSpan(
                    text: last ? word : '$word ',
                    style: TextStyle(
                      fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                      color: bold ? _textColor : _hintColor,
                      fontSize: 13,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ]),
      );

  // ── Campo Patrimônio com status visual ────────────────────────────────────
  Widget _patrimonioField() {
    Color borderColor = _border;
    Widget? suffix;
    Widget? statusWidget;

    if (_isBuscando) {
      borderColor = _primary;
      suffix = Padding(
          padding: const EdgeInsets.all(14),
          child: SizedBox(
              width: 18,
              height: 18,
              child:
                  CircularProgressIndicator(strokeWidth: 2, color: _primary)));
      statusWidget = _statusRow(
          Icons.search, 'Buscando em EQUIPAMENTOS_EMPRESA...', _primary);
    } else if (_equipamentoEncontrado) {
      borderColor = _green;
      suffix = Icon(Icons.check_circle_rounded, color: _green, size: 22);
      statusWidget = _statusRow(Icons.check_circle_outline,
          'Equipamento encontrado — campos preenchidos', _green,
          trailing: GestureDetector(
              onTap: () {
                _patrimonioCtrl.clear();
                _limparCamposEquipamento();
              },
              child: Text('Limpar',
                  style: TextStyle(
                      color: _green,
                      fontSize: 11,
                      decoration: TextDecoration.underline,
                      decorationColor: _green))));
    } else if (_equipamentoNaoEncontrado) {
      borderColor = _orange;
      suffix = Icon(Icons.warning_amber_rounded, color: _orange, size: 22);
      statusWidget = _statusRow(Icons.info_outline,
          'Patrimônio não encontrado — preencha manualmente', _orange,
          trailing: GestureDetector(
              onTap: () => _buscarEquipamento(_patrimonioCtrl.text.trim()),
              child: Text('Tentar novamente',
                  style: TextStyle(
                      color: _orange,
                      fontSize: 11,
                      decoration: TextDecoration.underline,
                      decorationColor: _orange))));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _patrimonioCtrl,
          style: TextStyle(color: _textColor, fontSize: 14),
          textCapitalization: TextCapitalization.characters,
          decoration: InputDecoration(
            labelText: 'PATRIMÔNIO: *',
            labelStyle: TextStyle(color: _hintColor, fontSize: 13),
            filled: true,
            fillColor: _card,
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: borderColor, width: 1.5)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: _primary, width: 2)),
            errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: _red)),
            focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: _red, width: 1.5)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            suffixIcon: suffix,
          ),
          validator: (v) =>
              (v == null || v.isEmpty) ? 'Informe o patrimônio' : null,
        ),
        if (statusWidget != null)
          Padding(padding: const EdgeInsets.only(top: 6), child: statusWidget),
      ],
    );
  }

  Widget _statusRow(IconData icon, String text, Color color,
          {Widget? trailing}) =>
      Row(children: [
        Icon(icon, color: color, size: 14),
        const SizedBox(width: 5),
        Expanded(
            child: Text(text, style: TextStyle(color: color, fontSize: 11.5))),
        if (trailing != null) trailing,
      ]);

  // ── Dropdown técnico ──────────────────────────────────────────────────────
  Widget _tecnicoDropdown() => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _carregandoTecnicos
            ? Container(
                height: 52,
                decoration: BoxDecoration(
                    color: _card,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _border)),
                child: Row(children: [
                  const SizedBox(width: 16),
                  SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: _primary)),
                  const SizedBox(width: 12),
                  Text('Carregando técnicos...',
                      style: TextStyle(color: _hintColor, fontSize: 13)),
                ]))
            : DropdownButtonFormField<String>(
                value: _tecnico,
                dropdownColor: _card,
                style: TextStyle(color: _textColor, fontSize: 14),
                decoration: _dec('TÉCNICO:', isRed: true),
                hint: Text('Selecione o técnico',
                    style: TextStyle(color: _hintColor, fontSize: 13)),
                items: _tecnicosFirestore
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) => setState(() => _tecnico = v),
              ),
      );

  // ═══════════════════════════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final tiposMan = widget.tipoManutencaoList ??
        [
          'PREVENTIVA MENSAL',
          'PREVENTIVA TRIMESTRAL',
          'PREVENTIVA SEMESTRAL',
          'PREVENTIVA ANUAL'
        ];
    final auto = _equipamentoEncontrado;

    return Container(
      width: widget.width ?? double.infinity,
      color: _bg,
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── CABEÇALHO ─────────────────────────────────────────────
              Center(
                  child: Text('CADASTRAR PREVENTIVA',
                      style: TextStyle(
                          color: _textColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5))),
              Center(
                  child: Text('formulário para adicionar nova preventiva',
                      style: TextStyle(color: _hintColor, fontSize: 12))),
              const SizedBox(height: 16),

              // ── FOTO ──────────────────────────────────────────────────
              GestureDetector(
                onTap: _pickFoto,
                child: Container(
                  height: 160,
                  width: double.infinity,
                  decoration: BoxDecoration(
                      color: _card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _border)),
                  child: _fotoFile != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.memory(_fotoFile!.bytes!,
                              fit: BoxFit.cover))
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                              Icon(Icons.add_photo_alternate_outlined,
                                  color: _primary, size: 40),
                              const SizedBox(height: 8),
                              Text('add foto',
                                  style: TextStyle(color: _hintColor)),
                            ]),
                ),
              ),
              const SizedBox(height: 12),

              // ── QR CODE ───────────────────────────────────────────────
              OutlinedButton.icon(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content:
                            const Text('Use a action de scan do FlutterFlow'),
                        backgroundColor: _primary)),
                icon: Icon(Icons.qr_code_2, color: _primary),
                label:
                    Text('LER HPS CODE', style: TextStyle(color: _textColor)),
                style: OutlinedButton.styleFrom(
                    side: BorderSide(color: _border),
                    backgroundColor: _card,
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10))),
              ),
              const SizedBox(height: 12),

              // ── PATRIMÔNIO ────────────────────────────────────────────
              _patrimonioField(),
              const SizedBox(height: 12),

              // ── MÊS / ANO ─────────────────────────────────────────────
              Row(children: [
                Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<int>(
                      value: _mesSelecionado,
                      dropdownColor: _card,
                      style: TextStyle(color: _textColor, fontSize: 14),
                      decoration: _dec('MÊS'),
                      items: List.generate(
                          12,
                          (i) => DropdownMenuItem(
                              value: i + 1, child: Text(_meses[i]))),
                      onChanged: (v) =>
                          setState(() => _mesSelecionado = v ?? 1),
                    )),
                const SizedBox(width: 10),
                Expanded(
                    child: DropdownButtonFormField<int>(
                  value: _anoSelecionado,
                  dropdownColor: _card,
                  style: TextStyle(color: _textColor, fontSize: 14),
                  decoration: _dec('ANO'),
                  items: List.generate(
                      5,
                      (i) => DropdownMenuItem(
                          value: 2024 + i, child: Text('${2024 + i}'))),
                  onChanged: (v) => setState(() => _anoSelecionado = v ?? 2026),
                )),
              ]),

              // ── IDENTIFICAÇÃO ─────────────────────────────────────────
              _sectionTitle('IDENTIFICAÇÃO'),
              if (auto)
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                      color: _green.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _green.withOpacity(0.35))),
                  child: Row(children: [
                    Icon(Icons.auto_awesome, color: _green, size: 15),
                    const SizedBox(width: 8),
                    Expanded(
                        child: Text(
                            'Campos preenchidos automaticamente. Toque para editar.',
                            style: TextStyle(color: _green, fontSize: 11.5))),
                  ]),
                ),

              _field(_marcaCtrl, 'MARCA:', readOnly: auto),
              _field(_modeloCtrl, 'MODELO:', readOnly: auto),
              _field(_equipamentoCtrl, 'EQUIPAMENTO:', readOnly: auto),
              _field(_tipoCtrl, 'TIPO:', readOnly: auto),
              _field(_btusCtrl, 'BTUs:',
                  keyboardType: TextInputType.number, readOnly: auto),
              _field(_fluidoCtrl, 'FLUÍDO:', readOnly: auto),
              _field(_salaCtrl, 'SALA:', readOnly: auto),
              _field(_setorCtrl, 'SETOR:', readOnly: auto),
              _sufixField(_tensaoCtrl, 'TENSÃO:', 'V',
                  focusNode: _tensaoFocus, isRed: true),
              _sufixField(_amperagemCtrl, 'AMPERAGEM:', 'A',
                  focusNode: _amperagemFocus, isRed: true),
              _field(_responsavelCtrl, 'RESPONSÁVEL:', readOnly: auto),
              _field(_emailCtrl, 'EMAIL:', readOnly: auto),
              _tecnicoDropdown(),

              // ── TIPO DA MANUTENÇÃO (com auto-seleção de checks) ───────
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: DropdownButtonFormField<String>(
                  value: _tipoManutencao,
                  dropdownColor: _card,
                  style: TextStyle(color: _textColor, fontSize: 14),
                  decoration: _dec('TIPO DA MANUTENÇÃO:', isRed: true),
                  hint: Text('Selecione',
                      style: TextStyle(color: _hintColor, fontSize: 13)),
                  items: tiposMan
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) {
                    setState(() => _tipoManutencao = v);
                    _aplicarChecksPorTipo(v); // ← auto-seleção aqui
                  },
                ),
              ),

              // ── BANNER INFO AUTO-SELEÇÃO ──────────────────────────────
              if (_tipoManutencao != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                      color: _primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _primary.withOpacity(0.35))),
                  child: Row(children: [
                    Icon(Icons.info_outline, color: _primary, size: 15),
                    const SizedBox(width: 8),
                    Expanded(
                        child: Text(
                            'Itens pré-selecionados conforme $_tipoManutencao. Ajuste se necessário.',
                            style: TextStyle(color: _primary, fontSize: 11.5))),
                  ]),
                ),

              // ── EVAPORADORA ───────────────────────────────────────────
              _sectionTitle('EVAPORADORA'),
              _checkItem('LIMPEZA DA EVAPORADORA INTERNA:', _limpezaEvapInterna,
                  (v) => setState(() => _limpezaEvapInterna = v ?? false)),
              _checkItem('LIMPEZA DO FILTRO:', _limpezaFiltro,
                  (v) => setState(() => _limpezaFiltro = v ?? false)),
              _checkItem('LIMPEZA COM BACTERICIDA:', _limpezaBactericida,
                  (v) => setState(() => _limpezaBactericida = v ?? false)),
              _checkItem(
                  'VERIFICAÇÃO DO CONTROLE E PILHAS:',
                  _verControlePilhas,
                  (v) => setState(() => _verControlePilhas = v ?? false)),
              _checkItem('VERIFICAR RUÍDOS:', _verRuidos,
                  (v) => setState(() => _verRuidos = v ?? false)),
              _checkItem('VERIFICAR MAL CHEIRO:', _verMalCheiro,
                  (v) => setState(() => _verMalCheiro = v ?? false)),
              _checkItem(
                  'FAZER MEDIÇÃO E INFORMAR A CORRENTE ELÉTRICA:',
                  _medicaoCorrente,
                  (v) => setState(() => _medicaoCorrente = v ?? false)),
              _checkItem(
                  'FAZER MEDIÇÃO E INFORMAR A TENSÃO ELÉTRICA:',
                  _medicaoTensaoEletrica,
                  (v) => setState(() => _medicaoTensaoEletrica = v ?? false)),

              // ── CONDENSADORA ──────────────────────────────────────────
              _sectionTitle('CONDENSADORA'),
              _checkItem('VERIFICAR DRENO:', _verDreno,
                  (v) => setState(() => _verDreno = v ?? false)),
              _checkItem('VERIFICAR PRESSÃO (PSI):', _verPressao,
                  (v) => setState(() => _verPressao = v ?? false)),
              _checkItem('POLIR CONDENSADORA:', _polirCondensadora,
                  (v) => setState(() => _polirCondensadora = v ?? false)),
              _checkItem('VERIFICAR PARTE ELÉTRICA:', _verParteEletrica,
                  (v) => setState(() => _verParteEletrica = v ?? false)),
              _checkItem('VERIFICAR ISOLAMENTO TÉRMICO:', _verIsolamento,
                  (v) => setState(() => _verIsolamento = v ?? false)),

              // ── SERVIÇOS ADICIONAIS ────────────────────────────────────
              _sectionTitle('SERVIÇOS ADICIONAIS'),
              _checkItem('JATEAMENTO DA CONDENSADORA:', _jateamentoCondensadora,
                  (v) => setState(() => _jateamentoCondensadora = v ?? false)),
              _checkItem('JATEAMENTO DA EVAPORADORA:', _jateamentoEvaporadora,
                  (v) => setState(() => _jateamentoEvaporadora = v ?? false)),
              _checkItem('LAVAGEM DO DRENO:', _lavagemDreno,
                  (v) => setState(() => _lavagemDreno = v ?? false)),
              _checkItem('LAVAGEM DA CARCAÇA EVAPORADORA:', _lavagemCarcacaEvap,
                  (v) => setState(() => _lavagemCarcacaEvap = v ?? false)),
              _checkItem(
                  'LAVAGEM DA CARCAÇA CONDENSADORA:',
                  _lavagemCarcacaCond,
                  (v) => setState(() => _lavagemCarcacaCond = v ?? false)),
              _checkItem(
                  'LIMPEZA E LUBRIFICAÇÃO DO COMPRESSOR:',
                  _limpezaCompressor,
                  (v) => setState(() => _limpezaCompressor = v ?? false)),
              _checkItem('LAVAGEM DA TURBINA EVAPORADORA:', _lavagemTurbinaEvap,
                  (v) => setState(() => _lavagemTurbinaEvap = v ?? false)),
              _checkItem('VERIFICAR PÉS DE BORRACHA:', _verPesBorracha,
                  (v) => setState(() => _verPesBorracha = v ?? false)),

              // ── OBS ───────────────────────────────────────────────────
              _sectionTitle('OBSERVAÇÕES'),
              TextFormField(
                controller: _obsCtrl,
                style: TextStyle(color: _textColor, fontSize: 13),
                maxLines: 3,
                decoration: _dec('OBS:'),
              ),

              // ── SALVAR ────────────────────────────────────────────────
              const SizedBox(height: 24),
              // ── BOTÃO SALVAR ──────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: (_isSaving || _isGerandoPDF) ? null : _salvar,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: _primary,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 4),
                  child: _isSaving
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                              color: Colors.black, strokeWidth: 2))
                      : const Text('SALVAR PREVENTIVA',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              letterSpacing: 1.2)),
                ),
              ),
              const SizedBox(height: 12),

              // ── BOTÃO GERAR PDF + PROGRESSO ───────────────────────────
              if (_isGerandoPDF) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _primary.withOpacity(0.4)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: _primary),
                        ),
                        const SizedBox(width: 10),
                        Text(_statusPDF,
                            style: TextStyle(
                                color: _primary,
                                fontSize: 13,
                                fontWeight: FontWeight.w500)),
                      ]),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: _progressoPDF,
                          backgroundColor: _border.withOpacity(0.3),
                          valueColor: AlwaysStoppedAnimation<Color>(_primary),
                          minHeight: 6,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text('${(_progressoPDF * 100).toInt()}%',
                          style: TextStyle(color: _hintColor, fontSize: 11)),
                    ],
                  ),
                ),
              ] else
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: _isSaving ? null : _gerarPDF,
                    icon: Icon(Icons.picture_as_pdf, color: _primary),
                    label: const Text('GERAR PDF E ENVIAR EMAIL',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            letterSpacing: 1.2)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _primary,
                      side: BorderSide(color: _primary, width: 1.5),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
