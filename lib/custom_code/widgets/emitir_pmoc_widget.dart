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
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:convert';

// ─────────────────────────────────────────────────────────────────────────────
//  CONSTANTES
// ─────────────────────────────────────────────────────────────────────────────
const _kVerdePmoc = Color(0xFF1A3C34);
const _kSenderEmail = 'equipe@hpsrefri.com.br';
const _kSenderName = 'HPS Refrigeração';
const _kBannerUrl =
    'https://firebasestorage.googleapis.com/v0/b/h-p-s-modificado-emdcp0.appspot.com/o/Gemini_Generated_Image_2xpdsd2xpdsd2xpd%20(1).png?alt=media&token=be3e052e-a0b8-4e8c-8151-b9365b507ed5';
const _kLogoUrl = 'https://i.ibb.co/VpqNsxXt/Imagem1.jpg';
const _kAssinaturaUrl =
    'https://i.ibb.co/hRvtGhbK/3b004d07-a4a9-4568-9d8b-5abc281dbcee.png';
const _kEmailHPS = 'hpsrefri@gmail.com';
const _kOsAppId = '7b01186f-cf76-4b5d-8354-87d83737d40c';
const _kOsApiKey = 'ZTdlNjIwZWItMjEyMC00M2RhLWJlZmYtMzc2NTBmNzNmMDdj';
const _kOsChannel = '577bba44-d1bf-4ac9-9d11-20d89e09a61a';

const List<String> _meses = [
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
//  HTTP
// ─────────────────────────────────────────────────────────────────────────────
Map<String, String> _hdr() => kIsWeb ? {} : {'User-Agent': 'Mozilla/5.0'};

Future<http.Response> _get(String? url,
    {Duration t = const Duration(seconds: 10)}) async {
  if (url == null || url.isEmpty || !url.startsWith('http'))
    return http.Response('', 400);
  try {
    return await http.get(Uri.parse(url), headers: _hdr()).timeout(t);
  } catch (_) {
    return http.Response('', 400);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  CACHE
// ─────────────────────────────────────────────────────────────────────────────
pw.ImageProvider? _cachedLogo;
pw.ImageProvider? _cachedAssin;
Future<void>? _assetFut;

Future<void> _ensureAssets() {
  _assetFut ??= _loadAssets();
  return _assetFut!;
}

Future<void> _loadAssets() async {
  try {
    final r = await _get(_kLogoUrl);
    if (r.statusCode == 200) _cachedLogo = pw.MemoryImage(r.bodyBytes);
  } catch (_) {}
  try {
    final r = await _get(_kAssinaturaUrl);
    if (r.statusCode == 200) _cachedAssin = pw.MemoryImage(r.bodyBytes);
  } catch (_) {}
}

// ─────────────────────────────────────────────────────────────────────────────
//  HELPERS
// ─────────────────────────────────────────────────────────────────────────────
String _hoje() {
  final d = DateTime.now();
  return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}

String _mesNome(int m) => _meses[m.clamp(1, 12)];

List<Map<String, String>> _calendario(int mi, int ai) {
  final l = <Map<String, String>>[];
  int m = mi, a = ai;
  for (int i = 0; i < 12; i++) {
    l.add({
      'mes': _mesNome(m),
      'ano': a.toString(),
      'abr': _mesNome(m).substring(0, 3)
    });
    m++;
    if (m > 12) {
      m = 1;
      a++;
    }
  }
  return l;
}

// ─────────────────────────────────────────────────────────────────────────────
//  FIREBASE / API
// ─────────────────────────────────────────────────────────────────────────────
Future<List<Map<String, dynamic>>> _buscarEquipamentos(String email) async {
  final s = await FirebaseFirestore.instance
      .collection('EQUIPAMENTOS_EMPRESA')
      .where('EMAIL', isEqualTo: email)
      .where('CONTRATO', isEqualTo: true)
      .get();
  return s.docs.map((d) => d.data()).toList();
}

Future<String> _buscarApiBrevo() async {
  try {
    final s = await FirebaseFirestore.instance
        .collection('USUARIOS')
        .where('email', isEqualTo: _kEmailHPS)
        .limit(1)
        .get();
    if (s.docs.isNotEmpty)
      return (s.docs.first.data()['apibrevo'] ?? '').toString().trim();
  } catch (_) {}
  return '';
}

Future<void> _sendEmail({
  required List<String> to,
  required String subject,
  required String html,
  required String apiKey,
}) async {
  if (apiKey.isEmpty) throw Exception('apibrevo nao configurado');
  final r = await http.post(
    Uri.parse('https://api.brevo.com/v3/smtp/email'),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'api-key': apiKey,
    },
    body: jsonEncode({
      'sender': {'name': _kSenderName, 'email': _kSenderEmail},
      'replyTo': {'name': _kSenderName, 'email': _kSenderEmail},
      'to': to.map((e) => {'email': e}).toList(),
      'subject': subject,
      'htmlContent': html,
    }),
  );
  if (r.statusCode != 200 && r.statusCode != 201)
    throw Exception('Brevo ${r.statusCode}: ${r.body}');
}

Future<void> _push({
  required String email,
  required String titulo,
  required String msg,
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
          {'field': 'tag', 'key': 'Email', 'relation': '=', 'value': email}
        ],
        'android_channel_id': _kOsChannel,
        'headings': {'en': titulo},
        'contents': {'en': msg},
        'priority': 10,
      }),
    );
  } catch (_) {}
}

Future<void> _notificacao({
  required String email,
  required String nome,
  required String vig,
}) async {
  if (email.isEmpty) return;
  try {
    await FirebaseFirestore.instance.collection('NOTIFICACAO').add({
      'email': email,
      'titulo': 'PMOC Emitido',
      'mensagem': 'PMOC de $nome (vigencia $vig) gerado e enviado.',
      'tipo': 'pmoc',
      'visto': false,
      'data': Timestamp.now(),
      'mes': _mesNome(DateTime.now().month),
      'ano': DateTime.now().year,
      'status': 'enviado',
      'os': '',
    });
  } catch (_) {}
}

// ─────────────────────────────────────────────────────────────────────────────
//  HTML E-MAIL
// ─────────────────────────────────────────────────────────────────────────────
String _htmlEmail({
  required String nome,
  required String vig,
  required int total,
  required String url,
}) =>
    '''
<!DOCTYPE html><html lang="pt-BR"><head><meta charset="UTF-8"></head>
<body style="margin:0;padding:0;background:#f4f6f8;font-family:Arial,sans-serif;">
<table width="100%" cellpadding="0" cellspacing="0" style="background:#f4f6f8;padding:20px 0;"><tr><td align="center">
<table width="600" cellpadding="0" cellspacing="0" style="background:#fff;border-radius:12px;overflow:hidden;max-width:1400px;">
<tr><td style="padding:0;line-height:0;"><img src="$_kBannerUrl" width="1400" style="display:block;width:100%;"/></td></tr>
<tr><td style="background:#1A3C34;padding:12px 24px;"><span style="background:#ffffff20;color:#fff;font-size:11px;font-weight:bold;padding:4px 10px;border-radius:20px;">PMOC - Documento Oficial</span></td></tr>
<tr><td style="padding:28px;color:#333;font-size:15px;line-height:1.7;">
<p>Prezados,</p>
<p>O <strong>PMOC</strong>${nome.isNotEmpty ? ' de <strong>$nome</strong>' : ''} referente a vigencia <strong>$vig</strong> foi gerado com <strong>$total equipamento${total != 1 ? 's' : ''}</strong>.</p>
<table width="100%" style="background:#f0fdf4;border-left:4px solid #1A3C34;border-radius:0 8px 8px 0;margin-bottom:16px;"><tr><td style="padding:14px;font-size:14px;color:#1A3C34;">Conforme <strong>Lei 13.589/2018</strong>, <strong>Portaria MS 3.523/98</strong> e <strong>ABNT NBR 13971</strong>.</td></tr></table>
<div style="text-align:center;"><a href="$url" style="background:#1A3C34;color:#fff;text-decoration:none;padding:12px 28px;border-radius:6px;font-weight:bold;font-size:14px;display:inline-block;">Baixar PMOC em PDF</a></div>
</td></tr>
<tr><td style="background:#f1f5f9;padding:14px;text-align:center;font-size:12px;color:#94a3b8;">&copy; 2026 HPS Refrigeracao</td></tr>
</table></td></tr></table></body></html>
''';

// ─────────────────────────────────────────────────────────────────────────────
//  GERACAO DO PDF
// ─────────────────────────────────────────────────────────────────────────────
Future<Uint8List> _gerarPmoc({
  required Map<String, dynamic> cliente,
  required List<Map<String, dynamic>> equips,
  required int mesIni,
  required int anoIni,
  required String tecnico,
  required String crea,
  required void Function(double, String) onProgress,
}) async {
  onProgress(0.05, 'Carregando assets...');
  await _ensureAssets();

  final nomeCliente = (cliente['display_name'] ?? '').toString().toUpperCase();
  final cnpjCliente = (cliente['CNPJ'] ?? cliente['cnpj'] ?? '').toString();
  final endCliente =
      (cliente['endereco'] ?? cliente['ENDERECO'] ?? '').toString();
  final telCliente =
      (cliente['telefone'] ?? cliente['TELEFONE'] ?? '').toString();
  final emailCliente = (cliente['email'] ?? '').toString();

  pw.ImageProvider? logoCliente;
  final photoUrl = cliente['photo_url']?.toString().trim();
  if (photoUrl != null && photoUrl.startsWith('http')) {
    final r = await _get(photoUrl);
    if (r.statusCode == 200) logoCliente = pw.MemoryImage(r.bodyBytes);
  }

  final cal = _calendario(mesIni, anoIni);
  final vigencia =
      '${cal.first['mes']!}/${cal.first['ano']!} a ${cal.last['mes']!}/${cal.last['ano']!}';

  // ── Paleta moderna ──────────────────────────────────────────────────────
  const cV = PdfColor.fromInt(0xFF1A3C34); // Verde HPS
  const cV2 = PdfColor.fromInt(0xFF2E7D52); // Verde medio
  const cVL = PdfColor.fromInt(0xFFE8F5E9); // Verde claro bg
  const cAc = PdfColor.fromInt(0xFF00897B); // Teal accent
  const cG0 = PdfColor.fromInt(0xFFF8FAFC); // Cinza 50
  const cG1 = PdfColor.fromInt(0xFFF1F5F9); // Cinza 100
  const cG2 = PdfColor.fromInt(0xFFE2E8F0); // Cinza borda
  const cG5 = PdfColor.fromInt(0xFF64748B); // Cinza texto
  const cDk = PdfColor.fromInt(0xFF0F172A); // Quase preto
  const cBr = PdfColors.white;
  const cAmb = PdfColor.fromInt(0xFFFFF3CD); // Amarelo bg
  const cAmbT = PdfColor.fromInt(0xFF856404); // Amarelo texto
  const cLa = PdfColor.fromInt(0xFFF59E0B); // Laranja
  const cRe = PdfColor.fromInt(0xFFDC2626); // Vermelho
  const cReB = PdfColor.fromInt(0xFFFDE8E8); // Vermelho bg
  const cBlB = PdfColor.fromInt(0xFFEFF6FF); // Azul bg
  const cBlT = PdfColor.fromInt(0xFF1D4ED8); // Azul texto
  const cGrB = PdfColor.fromInt(0xFFECFDF5); // Verde bg2
  const cGrT = PdfColor.fromInt(0xFF065F46); // Verde texto2

  // ── Typography ─────────────────────────────────────────────────────────
  pw.TextStyle ts(double sz, {PdfColor? c, bool b = false, bool it = false}) =>
      pw.TextStyle(
        fontSize: sz,
        color: c ?? cDk,
        fontWeight: b ? pw.FontWeight.bold : pw.FontWeight.normal,
        fontStyle: it ? pw.FontStyle.italic : pw.FontStyle.normal,
      );

  // ── Margens e formato ───────────────────────────────────────────────────
  const fmt = PdfPageFormat.a4;
  const marg = pw.EdgeInsets.fromLTRB(26, 16, 26, 16);

  final pdf = pw.Document();

  // ── Borda de tabela padrao ──────────────────────────────────────────────
  final bTbl = pw.TableBorder.all(color: cG2, width: 0.4);

  // ── Celulas ─────────────────────────────────────────────────────────────
  // Cabecalho verde escuro
  pw.Widget hC(String t, {pw.TextAlign al = pw.TextAlign.left}) => pw.Container(
        color: cV,
        padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 3),
        child: pw.Text(t, style: ts(6.5, c: cBr, b: true), textAlign: al),
      );

  // Dado normal
  pw.Widget dC(
    String t, {
    PdfColor? bg,
    PdfColor? tc,
    bool b = false,
    pw.TextAlign al = pw.TextAlign.left,
    double sz = 7,
  }) =>
      pw.Container(
        color: bg,
        padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 3),
        child: pw.Text(t, style: ts(sz, c: tc, b: b), textAlign: al),
      );

  // Label cinza
  pw.Widget lC(String t) => pw.Container(
        color: cG1,
        padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 3),
        child: pw.Text(t, style: ts(6.5, c: cG5, b: true)),
      );

  // ── Cabecalho de pagina ─────────────────────────────────────────────────
  pw.Widget pHdr(String sec, int pg) => pw.Column(children: [
        pw.Container(
          height: 34,
          color: cV,
          padding: const pw.EdgeInsets.symmetric(horizontal: 14),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              if (_cachedLogo != null)
                pw.Container(
                  width: 46,
                  height: 20,
                  child: pw.Image(_cachedLogo!, fit: pw.BoxFit.contain),
                )
              else
                pw.Text('HPS', style: ts(10, c: cBr, b: true)),
              pw.SizedBox(width: 8),
              pw.Container(
                  width: 0.5,
                  height: 18,
                  color: const PdfColor.fromInt(0x44FFFFFF)),
              pw.SizedBox(width: 8),
              pw.Text('HPS REFRIGERACAO', style: ts(8, c: cBr, b: true)),
              pw.Text('  CNPJ 28.340.152/0001-52',
                  style: ts(6.5, c: const PdfColor.fromInt(0x88FFFFFF))),
              pw.Spacer(),
              pw.Container(
                padding:
                    const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: pw.BoxDecoration(
                  color: const PdfColor.fromInt(0x22FFFFFF),
                  borderRadius: pw.BorderRadius.circular(3),
                ),
                child: pw.Text('PMOC', style: ts(10, c: cBr, b: true)),
              ),
              pw.SizedBox(width: 8),
              pw.Container(
                  width: 0.5,
                  height: 18,
                  color: const PdfColor.fromInt(0x44FFFFFF)),
              pw.SizedBox(width: 8),
              pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(sec, style: ts(7, c: cBr, b: true)),
                    pw.Text('Pag. $pg  Vigencia: $vigencia',
                        style: ts(5.5, c: const PdfColor.fromInt(0x88FFFFFF))),
                  ]),
            ],
          ),
        ),
        pw.Container(height: 2.5, color: cAc),
      ]);

  // ── Rodape ──────────────────────────────────────────────────────────────
  pw.Widget pFtr() => pw.Container(
        margin: const pw.EdgeInsets.only(top: 5),
        padding: const pw.EdgeInsets.symmetric(horizontal: 2, vertical: 3),
        decoration: pw.BoxDecoration(
          border: pw.Border(top: pw.BorderSide(color: cG2, width: 0.5)),
        ),
        child: pw.Row(children: [
          pw.Text('HPS Refrigeracao  (77) 98819-4630  equipe@hpsrefri.com.br',
              style: ts(6, c: cG5)),
          pw.Spacer(),
          pw.Text('Vigencia: $vigencia  Emitido: ${_hoje()}',
              style: ts(6, c: cG5)),
        ]),
      );

  // ── Titulo de secao ─────────────────────────────────────────────────────
  pw.Widget sTtl(String num, String txt) => pw.Container(
        margin: const pw.EdgeInsets.only(top: 7, bottom: 3),
        child:
            pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.center, children: [
          pw.Container(width: 3, height: 14, color: cAc),
          pw.SizedBox(width: 6),
          if (num.isNotEmpty) ...[
            pw.Container(
              width: 17,
              height: 17,
              decoration: pw.BoxDecoration(
                color: cV,
                borderRadius: pw.BorderRadius.circular(3),
              ),
              child: pw.Center(
                  child: pw.Text(num, style: ts(6.5, c: cBr, b: true))),
            ),
            pw.SizedBox(width: 5),
          ],
          pw.Text(txt.toUpperCase(), style: ts(8, c: cV, b: true)),
        ]),
      );

  // ── Badge de frequencia ─────────────────────────────────────────────────
  pw.Widget fBadge(String f) {
    PdfColor bg, fg;
    switch (f) {
      case 'MENSAL':
        bg = cVL;
        fg = cV;
        break;
      case 'BIMESTRAL':
        bg = cGrB;
        fg = cGrT;
        break;
      case 'TRIMESTRAL':
        bg = cAmb;
        fg = cAmbT;
        break;
      case 'SEMESTRAL':
        bg = cBlB;
        fg = cBlT;
        break;
      case 'ANUAL':
        bg = cReB;
        fg = cRe;
        break;
      default:
        bg = cG1;
        fg = cG5;
    }
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: pw.BoxDecoration(
          color: bg, borderRadius: pw.BorderRadius.circular(8)),
      child: pw.Text(f, style: ts(5.5, c: fg, b: true)),
    );
  }

  // ── Checkmark ──────────────────────────────────────────────────────────
  pw.Widget chk(bool on) => pw.Container(
        width: 9,
        height: 9,
        decoration: pw.BoxDecoration(
          color: on ? cV : cBr,
          border: pw.Border.all(color: on ? cV : cG2, width: on ? 0 : 0.5),
          borderRadius: pw.BorderRadius.circular(2),
        ),
        child: on
            ? pw.Center(child: pw.Text('v', style: ts(5, c: cBr, b: true)))
            : null,
      );

  // ── Badge tipo P/S ──────────────────────────────────────────────────────
  pw.Widget tpBg(String t) {
    final isS = t == 'S';
    return pw.Container(
      width: 14,
      height: 14,
      decoration: pw.BoxDecoration(
        color: isS ? cReB : cVL,
        border: pw.Border.all(color: isS ? cRe : cV2, width: 0.6),
        borderRadius: pw.BorderRadius.circular(3),
      ),
      child: pw.Center(
          child: pw.Text(t, style: ts(6.5, c: isS ? cRe : cV, b: true))),
    );
  }

  // ── Periodicidade ───────────────────────────────────────────────────────
  bool dF(String freq, int idx) {
    switch (freq) {
      case 'MENSAL':
        return true;
      case 'BIMESTRAL':
        return idx % 2 == 0;
      case 'TRIMESTRAL':
        return idx % 3 == 0;
      case 'SEMESTRAL':
        return idx % 6 == 0;
      case 'ANUAL':
        return idx == 0;
      default:
        return false;
    }
  }

  // ── Total BTU ───────────────────────────────────────────────────────────
  int _totalBtu() {
    int t = 0;
    for (final e in equips) {
      t += int.tryParse(
              (e['BTUS'] ?? '').toString().replaceAll(RegExp(r'[^0-9]'), '')) ??
          0;
    }
    return t;
  }

  String _btuStr() {
    final b = _totalBtu();
    if (b <= 0) return '-';
    return b.toString().replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.') +
        ' BTU/h';
  }

  // ── Atividades ──────────────────────────────────────────────────────────
  final aCond = [
    ['1', 'Verificar sujeira, danos, corrosao e fixacao', 'P'],
    ['2', 'Limpeza geral do conjunto (interno e externo)', 'P'],
    ['3', 'Eliminar focos de corrosao', 'S'],
    ['4', 'Verificar vibracoes e ruidos anormais', 'P'],
    ['5', 'Lubrificar mancais (quando aplicavel)', 'P'],
    ['6', 'Verificar vazamentos no sistema', 'P'],
    ['7', 'Verificar estado geral do gabinete', 'P'],
    ['8', 'Verificar borrachas e amortecedores', 'P'],
    ['9', 'Verificar estado do trocador de calor', 'P'],
    ['10', 'Limpeza do trocador (hidrojato ou escova)', 'P'],
    ['11', 'Verificar parte eletrica geral', 'P'],
    ['12', 'Medir tensao, corrente e aterramento', 'P'],
    ['13', 'Verificar isolamentos termicos', 'P'],
    ['14', 'Recompor isolamentos termicos', 'S'],
    ['15', 'Polimento e tratamento anticorrosivo', 'S'],
    ['16', 'Recompor carga de gas refrigerante', 'S'],
  ];

  final aEvap = [
    ['1', 'Verificar sujeira, danos, corrosao e fixacao', 'P'],
    ['2', 'Limpeza geral do conjunto (interno e externo)', 'P'],
    ['3', 'Higienizacao com bactericida registrado no MS', 'P'],
    ['4', 'Eliminar focos de corrosao', 'S'],
    ['5', 'Verificar vibracoes e ruidos anormais', 'P'],
    ['6', 'Verificar estado do filtro de ar', 'P'],
    ['7', 'Limpeza do filtro (agua corrente e sabao)', 'P'],
    ['8', 'Substituicao do filtro (quando necessario)', 'S'],
    ['9', 'Verificar direcionador de ar', 'P'],
    ['10', 'Verificar termostato e controle remoto', 'P'],
    ['11', 'Verificar e desobstruir sistema de drenagem', 'P'],
    ['12', 'Medir temperatura de descarga do ar', 'P'],
    ['13', 'Medir corrente eletrica (A)', 'P'],
    ['14', 'Medir tensao eletrica (V)', 'P'],
    ['15', 'Limpeza da carcaca (carenagem)', 'P'],
    ['16', 'Limpeza da turbina do ventilador', 'S'],
    ['17', 'Verificar mal cheiro', 'P'],
  ];

  final cron = [
    ['1', 'Limpeza dos filtros de ar', 'MENSAL'],
    ['2', 'Higienizacao com bactericida', 'MENSAL'],
    ['3', 'Verificar e limpar dreno', 'MENSAL'],
    ['4', 'Verificar ruidos e vibracoes', 'MENSAL'],
    ['5', 'Medir corrente eletrica (A)', 'MENSAL'],
    ['6', 'Medir tensao eletrica (V)', 'MENSAL'],
    ['7', 'Verificar controle remoto', 'MENSAL'],
    ['8', 'Verificar mal cheiro', 'MENSAL'],
    ['9', 'Limpeza da carcaca da evaporadora', 'BIMESTRAL'],
    ['10', 'Limpeza com jato de agua - evaporadora', 'BIMESTRAL'],
    ['11', 'Verificar fixacao e amortecedores', 'BIMESTRAL'],
    ['12', 'Limpeza do trocador - condensadora', 'TRIMESTRAL'],
    ['13', 'Verificar isolamento termico', 'TRIMESTRAL'],
    ['14', 'Verificar parte eletrica geral', 'TRIMESTRAL'],
    ['15', 'Verificar pressao do sistema (PSI)', 'SEMESTRAL'],
    ['16', 'Limpeza com hidrojato - condensadora', 'SEMESTRAL'],
    ['17', 'Limpeza da turbina da evaporadora', 'SEMESTRAL'],
    ['18', 'Analise da qualidade do ar (ANVISA)', 'SEMESTRAL'],
    ['19', 'Recompor isolamentos termicos', 'ANUAL'],
    ['20', 'Verificar vazamento de gas refrigerante', 'ANUAL'],
    ['21', 'Revisao geral completa do sistema', 'ANUAL'],
  ];

  // ════════════════════════════════════════════════════════════════════════════
  //  PAG 1 — IDENTIFICACAO
  // ════════════════════════════════════════════════════════════════════════════
  onProgress(0.1, 'Pagina 1 - Identificacao...');
  pdf.addPage(pw.Page(
    pageFormat: fmt,
    margin: marg,
    build: (ctx) => pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pHdr('IDENTIFICACAO', 1),
        pw.SizedBox(height: 10),

        // Titulo centralizado
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(vertical: 8),
          decoration: pw.BoxDecoration(
            color: cG0,
            border: pw.Border.all(color: cG2, width: 0.5),
            borderRadius: pw.BorderRadius.circular(4),
          ),
          child: pw.Column(children: [
            pw.Text('PLANO DE MANUTENCAO, OPERACAO E CONTROLE',
                style: ts(11.5, c: cV, b: true),
                textAlign: pw.TextAlign.center),
            pw.SizedBox(height: 2),
            pw.Container(width: 50, height: 1.5, color: cAc),
            pw.SizedBox(height: 3),
            pw.Text(
                'Lei Federal n. 13.589/2018  Portaria MS n. 3.523/1998  ABNT NBR 13971',
                style: ts(6.5, c: cG5),
                textAlign: pw.TextAlign.center),
          ]),
        ),
        pw.SizedBox(height: 8),

        // Bloco cliente + empresa lado a lado
        pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          // Coluna esquerda - cliente
          pw.Expanded(
            child: pw.Container(
              padding: const pw.EdgeInsets.all(9),
              decoration: pw.BoxDecoration(
                color: cVL,
                border: pw.Border.all(color: cG2, width: 0.5),
                borderRadius: pw.BorderRadius.circular(4),
              ),
              child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(children: [
                      pw.Container(width: 3, height: 12, color: cAc),
                      pw.SizedBox(width: 5),
                      pw.Text('IDENTIFICACAO DO ESTABELECIMENTO',
                          style: ts(7, c: cV, b: true)),
                      if (logoCliente != null) ...[
                        pw.Spacer(),
                        pw.Container(
                          height: 28,
                          width: 40,
                          child: pw.Image(logoCliente, fit: pw.BoxFit.contain),
                        ),
                      ],
                    ]),
                    pw.SizedBox(height: 6),
                    pw.Table(border: bTbl, columnWidths: const {
                      0: pw.FixedColumnWidth(90),
                      1: pw.FlexColumnWidth(),
                    }, children: [
                      pw.TableRow(children: [
                        lC('Empresa / Cliente:'),
                        dC(nomeCliente.isNotEmpty ? nomeCliente : '-',
                            b: true, tc: cV),
                      ]),
                      pw.TableRow(children: [
                        lC('CNPJ / CPF:'),
                        dC(cnpjCliente.isNotEmpty ? cnpjCliente : '-'),
                      ]),
                      pw.TableRow(children: [
                        lC('Endereco:'),
                        dC(endCliente.isNotEmpty ? endCliente : '-'),
                      ]),
                      pw.TableRow(children: [
                        lC('Telefone:'),
                        dC(telCliente.isNotEmpty ? telCliente : '-'),
                      ]),
                      pw.TableRow(children: [
                        lC('E-mail:'),
                        dC(emailCliente.isNotEmpty ? emailCliente : '-'),
                      ]),
                      pw.TableRow(children: [
                        lC('Atividade:'),
                        dC((cliente['atividade'] ?? 'Uso Coletivo / Comercial')
                            .toString()),
                      ]),
                    ]),
                  ]),
            ),
          ),
          pw.SizedBox(width: 8),

          // Coluna direita - empresa + vigencia + totais
          pw.SizedBox(
            width: 205,
            child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                children: [
                  // Empresa responsavel
                  pw.Container(
                    padding: const pw.EdgeInsets.all(9),
                    decoration: pw.BoxDecoration(
                      color: cBr,
                      border: pw.Border.all(color: cG2, width: 0.5),
                      borderRadius: pw.BorderRadius.circular(4),
                    ),
                    child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Row(children: [
                            pw.Container(width: 3, height: 12, color: cAc),
                            pw.SizedBox(width: 5),
                            pw.Text('EMPRESA RESPONSAVEL',
                                style: ts(7, c: cV, b: true)),
                            pw.Spacer(),
                            if (_cachedLogo != null)
                              pw.Container(
                                height: 18,
                                width: 36,
                                child: pw.Image(_cachedLogo!,
                                    fit: pw.BoxFit.contain),
                              ),
                          ]),
                          pw.SizedBox(height: 5),
                          pw.Table(border: bTbl, columnWidths: const {
                            0: pw.FixedColumnWidth(72),
                            1: pw.FlexColumnWidth(),
                          }, children: [
                            pw.TableRow(children: [
                              lC('Empresa:'),
                              dC('HPS REFRIGERACAO', b: true, tc: cV)
                            ]),
                            pw.TableRow(children: [
                              lC('CNPJ:'),
                              dC('28.340.152/0001-52')
                            ]),
                            pw.TableRow(children: [
                              lC('Resp. Tecnico:'),
                              dC(tecnico.isNotEmpty ? tecnico : 'Huagner Pires',
                                  b: true)
                            ]),
                            pw.TableRow(children: [
                              lC('CREA / CFT:'),
                              dC(crea.isNotEmpty ? crea : '-')
                            ]),
                            pw.TableRow(children: [
                              lC('Telefone:'),
                              dC('(77) 98819-4630')
                            ]),
                          ]),
                        ]),
                  ),
                  pw.SizedBox(height: 5),

                  // Vigencia
                  pw.Container(
                    padding: const pw.EdgeInsets.all(9),
                    decoration: pw.BoxDecoration(
                      color: cG0,
                      border: pw.Border.all(color: cG2, width: 0.5),
                      borderRadius: pw.BorderRadius.circular(4),
                    ),
                    child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Row(children: [
                            pw.Container(width: 3, height: 12, color: cAc),
                            pw.SizedBox(width: 5),
                            pw.Text('VIGENCIA E EMISSAO',
                                style: ts(7, c: cV, b: true)),
                          ]),
                          pw.SizedBox(height: 5),
                          pw.Table(border: bTbl, columnWidths: const {
                            0: pw.FixedColumnWidth(72),
                            1: pw.FlexColumnWidth(),
                          }, children: [
                            pw.TableRow(children: [
                              lC('Vigencia:'),
                              dC(vigencia, b: true, tc: cV)
                            ]),
                            pw.TableRow(
                                children: [lC('Emissao:'), dC(_hoje())]),
                            pw.TableRow(children: [
                              lC('Base legal:'),
                              dC('Lei 13.589/2018')
                            ]),
                            pw.TableRow(
                                children: [lC('Norma:'), dC('ABNT NBR 13971')]),
                          ]),
                        ]),
                  ),
                  pw.SizedBox(height: 5),

                  // Cards de totais
                  pw.Row(children: [
                    pw.Expanded(
                      child: pw.Container(
                        padding: const pw.EdgeInsets.symmetric(
                            horizontal: 8, vertical: 7),
                        decoration: pw.BoxDecoration(
                          color: cV,
                          borderRadius: pw.BorderRadius.circular(4),
                        ),
                        child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text('EQUIP.',
                                  style: ts(5.5,
                                      c: const PdfColor.fromInt(0x88FFFFFF),
                                      b: true)),
                              pw.Text('${equips.length}',
                                  style: ts(16, c: cBr, b: true)),
                              pw.Text('unidade${equips.length != 1 ? "s" : ""}',
                                  style: ts(6,
                                      c: const PdfColor.fromInt(0xBBFFFFFF))),
                            ]),
                      ),
                    ),
                    pw.SizedBox(width: 4),
                    pw.Expanded(
                      child: pw.Container(
                        padding: const pw.EdgeInsets.symmetric(
                            horizontal: 8, vertical: 7),
                        decoration: pw.BoxDecoration(
                          color: cAc,
                          borderRadius: pw.BorderRadius.circular(4),
                        ),
                        child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text('CARGA',
                                  style: ts(5.5,
                                      c: const PdfColor.fromInt(0x88FFFFFF),
                                      b: true)),
                              pw.Text(
                                  _totalBtu() > 0
                                      ? '${(_totalBtu() / 1000).round()}k'
                                      : '-',
                                  style: ts(16, c: cBr, b: true)),
                              pw.Text('BTU/h',
                                  style: ts(6,
                                      c: const PdfColor.fromInt(0xBBFFFFFF))),
                            ]),
                      ),
                    ),
                  ]),
                ]),
          ),
        ]),

        // Legislacao
        sTtl('3', 'Legislacao Aplicavel'),
        pw.Table(border: bTbl, columnWidths: const {
          0: pw.FixedColumnWidth(150),
          1: pw.FlexColumnWidth(),
        }, children: [
          pw.TableRow(children: [hC('NORMA / LEI'), hC('DESCRICAO')]),
          pw.TableRow(children: [
            dC('Lei n. 13.589/2018', b: true),
            dC('Manutencao de sistemas de climatizacao em edificios de uso coletivo')
          ]),
          pw.TableRow(children: [
            dC('Portaria MS n. 3.523/1998', b: true, bg: cG0),
            dC('Regulamento tecnico de procedimentos de manutencao e controle',
                bg: cG0)
          ]),
          pw.TableRow(children: [
            dC('ABNT NBR 13971', b: true),
            dC('Sistemas de refrigeracao e condicionamento de ar - Manutencao Programada')
          ]),
          pw.TableRow(children: [
            dC('ABNT NBR 16401', b: true, bg: cG0),
            dC('Instalacoes de ar condicionado - Sistemas centrais e unitarios',
                bg: cG0)
          ]),
          pw.TableRow(children: [
            dC('Lei n. 6.437/1977', b: true),
            dC('Infracoes a legislacao sanitaria - multas de R\$2.000 a R\$1.500.000')
          ]),
        ]),

        // Objetivo
        sTtl('4', 'Objetivo e Campo de Aplicacao'),
        pw.Container(
          padding: const pw.EdgeInsets.all(8),
          decoration: pw.BoxDecoration(
            color: cG0,
            border: pw.Border.all(color: cG2, width: 0.5),
            borderRadius: pw.BorderRadius.circular(3),
          ),
          child: pw.Text(
            'Estabelecer diretrizes para os sistemas de climatizacao de '
            '${nomeCliente.isNotEmpty ? nomeCliente : "[CLIENTE]"}, garantindo condicoes adequadas de limpeza, '
            'manutencao, operacao e controle, visando a prevencao de riscos a saude dos ocupantes. '
            'Aplica-se aos ${equips.length} equipamento${equips.length != 1 ? "s" : ""} com contrato ativo.',
            style: ts(7.5),
            textAlign: pw.TextAlign.justify,
          ),
        ),

        // Aviso legal
        pw.Container(
          margin: const pw.EdgeInsets.only(top: 7),
          padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: pw.BoxDecoration(
            color: cAmb,
            border: pw.Border.all(color: cLa, width: 0.5),
            borderRadius: pw.BorderRadius.circular(3),
          ),
          child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Container(
                    width: 3,
                    height: 12,
                    color: cLa,
                    margin: const pw.EdgeInsets.only(right: 7, top: 1)),
                pw.Expanded(
                  child: pw.RichText(
                      text: pw.TextSpan(children: [
                    pw.TextSpan(
                        text: 'OBRIGATORIEDADE: ',
                        style: ts(7, c: cAmbT, b: true)),
                    pw.TextSpan(
                      text:
                          'Este documento e obrigatorio conforme Lei 13.589/2018 e Portaria MS 3.523/98. '
                          'A ausencia sujeita o estabelecimento a multas de R\$2.000 a R\$1.500.000 (Lei 6.437/77).',
                      style: ts(7, c: cAmbT),
                    ),
                  ])),
                ),
              ]),
        ),

        pw.Spacer(),
        pFtr(),
      ],
    ),
  ));

  onProgress(0.2, 'Pagina 2 - Ambientes...');

  // ════════════════════════════════════════════════════════════════════════════
  //  PAG 2 — AMBIENTES CLIMATIZADOS + PARAMETROS QAR
  // ════════════════════════════════════════════════════════════════════════════
  pdf.addPage(pw.Page(
    pageFormat: fmt,
    margin: marg,
    build: (ctx) => pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pHdr('AMBIENTES CLIMATIZADOS', 2),
        sTtl('6', 'Relacao de Ambientes Climatizados'),

        pw.Table(border: bTbl, columnWidths: const {
          0: pw.FixedColumnWidth(16),
          1: pw.FixedColumnWidth(57),
          2: pw.FlexColumnWidth(2.0),
          3: pw.FlexColumnWidth(2.0),
          4: pw.FlexColumnWidth(1.8),
          5: pw.FlexColumnWidth(1.8),
          6: pw.FixedColumnWidth(46),
          7: pw.FixedColumnWidth(24),
          8: pw.FixedColumnWidth(36),
        }, children: [
          pw.TableRow(children: [
            hC('#', al: pw.TextAlign.center),
            hC('PATRIMONIO'),
            hC('EQUIPAMENTO'),
            hC('MODELO / MARCA'),
            hC('LOCALIZACAO'),
            hC('SETOR'),
            hC('BTU/h', al: pw.TextAlign.center),
            hC('GAS', al: pw.TextAlign.center),
            hC('TIPO', al: pw.TextAlign.center),
          ]),
          ...equips.asMap().entries.map((e) {
            final i = e.key;
            final eq = e.value;
            final bg = i % 2 == 0 ? cG0 : cBr;
            return pw.TableRow(children: [
              dC('${i + 1}', bg: bg, al: pw.TextAlign.center, sz: 6.5),
              dC((eq['PATRIMONIO'] ?? '-').toString(),
                  bg: bg, b: true, tc: cV, sz: 6.5),
              dC((eq['EQUIPAMENTO'] ?? '-').toString(), bg: bg, sz: 6.5),
              dC('${eq['MODELO'] ?? '-'} / ${eq['MARCA'] ?? '-'}',
                  bg: bg, sz: 6),
              dC((eq['SALA'] ?? '-').toString(), bg: bg, sz: 6.5),
              dC((eq['SETOR'] ?? '-').toString(), bg: bg, sz: 6.5),
              dC((eq['BTUS'] ?? '-').toString(),
                  bg: bg, al: pw.TextAlign.center, sz: 6.5),
              dC((eq['FLUIDO'] ?? '-').toString(),
                  bg: bg, al: pw.TextAlign.center, sz: 6.5),
              dC((eq['TIPO'] ?? '-').toString(),
                  bg: bg, al: pw.TextAlign.center, sz: 6),
            ]);
          }).toList(),
        ]),

        // Total BTU
        pw.Container(
          margin: const pw.EdgeInsets.only(top: 3),
          padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          color: cV,
          child: pw.Row(children: [
            pw.Text('CARGA TERMICA TOTAL INSTALADA',
                style: ts(7, c: cBr, b: true)),
            pw.Spacer(),
            pw.Text(_btuStr(), style: ts(8, c: cBr, b: true)),
          ]),
        ),

        // Parametros QAR
        sTtl('5', 'Padroes Referenciais de Qualidade do Ar Interior'),
        pw.Text('Conforme Portaria MS 3.523/1998 e ABNT NBR 17.037/2023:',
            style: ts(7, c: cG5)),
        pw.SizedBox(height: 4),
        pw.Table(border: bTbl, columnWidths: const {
          0: pw.FlexColumnWidth(3),
          1: pw.FlexColumnWidth(2),
        }, children: [
          pw.TableRow(children: [hC('PARAMETRO'), hC('VALOR DE REFERENCIA')]),
          pw.TableRow(children: [
            dC('Temperatura interna (verao)'),
            dC('23 a 26 graus C')
          ]),
          pw.TableRow(children: [
            dC('Umidade relativa do ar (verao)', bg: cG0),
            dC('40% a 65%', bg: cG0)
          ]),
          pw.TableRow(children: [
            dC('Taxa de renovacao do ar'),
            dC('27 m3/hora/pessoa ou mais')
          ]),
          pw.TableRow(children: [
            dC('Velocidade do ar (1,5 m do piso)', bg: cG0),
            dC('0,025 a 0,25 m/s', bg: cG0)
          ]),
          pw.TableRow(children: [
            dC('Dioxido de Carbono - CO2'),
            dC('1.000 ppm ou menos')
          ]),
          pw.TableRow(children: [
            dC('Fungos (relacao I/E)', bg: cG0),
            dC('750 UFC/m3 e I/E 1,5 ou menos', bg: cG0)
          ]),
          pw.TableRow(children: [
            dC('Material Particulado - Aerodispersoidos'),
            dC('80 ug/m3 ou menos')
          ]),
        ]),

        pw.Spacer(),
        pFtr(),
      ],
    ),
  ));

  onProgress(0.3, 'Pagina 3 - Atividades...');

  // ════════════════════════════════════════════════════════════════════════════
  //  PAG 3 — ATIVIDADES DE MANUTENCAO  (2 colunas lado a lado)
  // ════════════════════════════════════════════════════════════════════════════
  pdf.addPage(pw.Page(
    pageFormat: fmt,
    margin: marg,
    build: (ctx) => pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pHdr('ATIVIDADES DE MANUTENCAO', 3),
        sTtl('7', 'Atividades de Manutencao das Unidades'),

        // Legenda P/S
        pw.Container(
          margin: const pw.EdgeInsets.only(bottom: 5),
          padding: const pw.EdgeInsets.symmetric(horizontal: 9, vertical: 5),
          decoration: pw.BoxDecoration(
            color: cAmb,
            border: pw.Border.all(color: cLa, width: 0.5),
            borderRadius: pw.BorderRadius.circular(3),
          ),
          child: pw.Row(children: [
            pw.Container(
              width: 14,
              height: 14,
              margin: const pw.EdgeInsets.only(right: 5),
              decoration: pw.BoxDecoration(
                  color: cVL,
                  border: pw.Border.all(color: cV2, width: 0.6),
                  borderRadius: pw.BorderRadius.circular(3)),
              child:
                  pw.Center(child: pw.Text('P', style: ts(7, c: cV, b: true))),
            ),
            pw.Text('= Atividade periodica em intervalos regulares.',
                style: ts(7, c: cAmbT)),
            pw.SizedBox(width: 16),
            pw.Container(
              width: 14,
              height: 14,
              margin: const pw.EdgeInsets.only(right: 5),
              decoration: pw.BoxDecoration(
                  color: cReB,
                  border: pw.Border.all(color: cRe, width: 0.6),
                  borderRadius: pw.BorderRadius.circular(3)),
              child:
                  pw.Center(child: pw.Text('S', style: ts(7, c: cRe, b: true))),
            ),
            pw.Text('= Atividade suplementar conforme avaliacao em campo.',
                style: ts(7, c: cAmbT)),
          ]),
        ),

        // Tabelas lado a lado
        pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Expanded(
            child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                children: [
                  pw.Container(
                    color: cV,
                    padding: const pw.EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    child: pw.Text('7.1  UNIDADE CONDENSADORA',
                        style: ts(7.5, c: cBr, b: true)),
                  ),
                  pw.Table(border: bTbl, columnWidths: const {
                    0: pw.FixedColumnWidth(17),
                    1: pw.FlexColumnWidth(),
                    2: pw.FixedColumnWidth(18),
                  }, children: [
                    pw.TableRow(children: [
                      hC('No', al: pw.TextAlign.center),
                      hC('ATIVIDADE DE MANUTENCAO'),
                      hC('T', al: pw.TextAlign.center)
                    ]),
                    ...aCond.asMap().entries.map((e) {
                      final i = e.key;
                      final a = e.value;
                      final bg = i % 2 == 0 ? cG0 : cBr;
                      return pw.TableRow(children: [
                        dC(a[0], bg: bg, al: pw.TextAlign.center, sz: 6.5),
                        dC(a[1], bg: bg, sz: 6.5),
                        pw.Container(
                            color: bg,
                            padding: const pw.EdgeInsets.all(3),
                            alignment: pw.Alignment.center,
                            child: tpBg(a[2])),
                      ]);
                    }).toList(),
                  ]),
                ]),
          ),
          pw.SizedBox(width: 7),
          pw.Expanded(
            child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                children: [
                  pw.Container(
                    color: cV,
                    padding: const pw.EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    child: pw.Text('7.2  UNIDADE EVAPORADORA',
                        style: ts(7.5, c: cBr, b: true)),
                  ),
                  pw.Table(border: bTbl, columnWidths: const {
                    0: pw.FixedColumnWidth(17),
                    1: pw.FlexColumnWidth(),
                    2: pw.FixedColumnWidth(18),
                  }, children: [
                    pw.TableRow(children: [
                      hC('No', al: pw.TextAlign.center),
                      hC('ATIVIDADE DE MANUTENCAO'),
                      hC('T', al: pw.TextAlign.center)
                    ]),
                    ...aEvap.asMap().entries.map((e) {
                      final i = e.key;
                      final a = e.value;
                      final bg = i % 2 == 0 ? cG0 : cBr;
                      return pw.TableRow(children: [
                        dC(a[0], bg: bg, al: pw.TextAlign.center, sz: 6.5),
                        dC(a[1], bg: bg, sz: 6.5),
                        pw.Container(
                            color: bg,
                            padding: const pw.EdgeInsets.all(3),
                            alignment: pw.Alignment.center,
                            child: tpBg(a[2])),
                      ]);
                    }).toList(),
                  ]),
                ]),
          ),
        ]),

        pw.Spacer(),
        pFtr(),
      ],
    ),
  ));

  onProgress(0.45, 'Pagina 4 - Cronograma...');

  // ════════════════════════════════════════════════════════════════════════════
  //  PAG 4 — CRONOGRAMA ANUAL
  // ════════════════════════════════════════════════════════════════════════════
  pdf.addPage(pw.Page(
    pageFormat: fmt,
    margin: marg,
    build: (ctx) => pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pHdr('CRONOGRAMA ANUAL DE ATIVIDADES', 4),
        sTtl('', 'Cronograma Anual de Atividades'),
        pw.Container(
          margin: const pw.EdgeInsets.only(bottom: 5),
          padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: pw.BoxDecoration(
            color: cVL,
            border: pw.Border(left: pw.BorderSide(color: cAc, width: 3)),
          ),
          child: pw.Text(
            'Periodicidades conforme ABNT NBR 13971 e Portaria MS 3.523/98. '
            'v = Atividade prevista para o periodo.',
            style: ts(7, c: cV),
          ),
        ),
        pw.Table(border: bTbl, columnWidths: const {
          0: pw.FixedColumnWidth(15),
          1: pw.FlexColumnWidth(3.2),
          2: pw.FlexColumnWidth(1.6),
          3: pw.FixedColumnWidth(44),
          4: pw.FixedColumnWidth(17),
          5: pw.FixedColumnWidth(17),
          6: pw.FixedColumnWidth(17),
          7: pw.FixedColumnWidth(17),
          8: pw.FixedColumnWidth(17),
          9: pw.FixedColumnWidth(17),
          10: pw.FixedColumnWidth(17),
          11: pw.FixedColumnWidth(17),
          12: pw.FixedColumnWidth(17),
          13: pw.FixedColumnWidth(17),
          14: pw.FixedColumnWidth(17),
          15: pw.FixedColumnWidth(17),
        }, children: [
          pw.TableRow(children: [
            hC('No', al: pw.TextAlign.center),
            hC('ATIVIDADE / SERVICO'),
            hC('COMPONENTE'),
            hC('FREQ.', al: pw.TextAlign.center),
            ...List.generate(
                12,
                (i) => pw.Container(
                      color: cV,
                      padding: const pw.EdgeInsets.symmetric(
                          horizontal: 1, vertical: 2),
                      alignment: pw.Alignment.center,
                      child: pw.Column(
                          mainAxisAlignment: pw.MainAxisAlignment.center,
                          children: [
                            pw.Text(cal[i]['abr']!,
                                style: ts(5.5, c: cBr, b: true),
                                textAlign: pw.TextAlign.center),
                            pw.Text(cal[i]['ano']!.substring(2),
                                style: ts(4.5,
                                    c: const PdfColor.fromInt(0xAAFFFFFF)),
                                textAlign: pw.TextAlign.center),
                          ]),
                    )),
          ]),
          ...cron.asMap().entries.map((e) {
            final i = e.key;
            final a = e.value;
            final bg = i % 2 == 0 ? cG0 : cBr;
            return pw.TableRow(children: [
              dC(a[0], bg: bg, al: pw.TextAlign.center, sz: 6.5),
              dC(a[1], bg: bg, sz: 6.5),
              dC(a.length > 3 ? a[3] : '', bg: bg, sz: 6),
              pw.Container(
                  color: bg,
                  padding:
                      const pw.EdgeInsets.symmetric(horizontal: 2, vertical: 3),
                  alignment: pw.Alignment.center,
                  child: fBadge(a[2])),
              ...List.generate(
                  12,
                  (m) => pw.Container(
                        color: bg,
                        padding: const pw.EdgeInsets.all(4),
                        alignment: pw.Alignment.center,
                        child: chk(dF(a[2], m)),
                      )),
            ]);
          }).toList(),
        ]),
        pw.SizedBox(height: 8),
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 9, vertical: 6),
          decoration: pw.BoxDecoration(
            color: cG0,
            border: pw.Border.all(color: cG2, width: 0.5),
            borderRadius: pw.BorderRadius.circular(3),
          ),
          child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('LEGENDA DE FREQUENCIAS', style: ts(7, c: cV, b: true)),
                pw.SizedBox(height: 5),
                pw.Row(children: [
                  fBadge('MENSAL'),
                  pw.SizedBox(width: 4),
                  pw.Text('A cada mes', style: ts(6.5, c: cG5)),
                  pw.SizedBox(width: 10),
                  fBadge('BIMESTRAL'),
                  pw.SizedBox(width: 4),
                  pw.Text('A cada 2 meses', style: ts(6.5, c: cG5)),
                  pw.SizedBox(width: 10),
                  fBadge('TRIMESTRAL'),
                  pw.SizedBox(width: 4),
                  pw.Text('A cada 3 meses', style: ts(6.5, c: cG5)),
                  pw.SizedBox(width: 10),
                  fBadge('SEMESTRAL'),
                  pw.SizedBox(width: 4),
                  pw.Text('A cada 6 meses', style: ts(6.5, c: cG5)),
                  pw.SizedBox(width: 10),
                  fBadge('ANUAL'),
                  pw.SizedBox(width: 4),
                  pw.Text('Uma vez por ano', style: ts(6.5, c: cG5)),
                ]),
              ]),
        ),
        pw.Spacer(),
        pFtr(),
      ],
    ),
  ));

  onProgress(0.55, 'Pagina 5 - Planilhas...');

  // ════════════════════════════════════════════════════════════════════════════
  //  PAG 5 — PLANILHAS DE CONTROLE
  // ════════════════════════════════════════════════════════════════════════════
  pw.TableRow emR(int cols, int idx) => pw.TableRow(
        children: List.generate(
            cols,
            (_) => pw.Container(
                  height: 13,
                  color: idx % 2 == 0 ? cG0 : cBr,
                )),
      );

  pdf.addPage(pw.Page(
    pageFormat: fmt,
    margin: marg,
    build: (ctx) => pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pHdr('PLANILHAS DE CONTROLE', 5),
        sTtl('8', 'Planilhas de Controle'),
        pw.Container(
            color: cV2,
            padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: pw.Text(
                'PLANILHA 1 - Controle de Manutencao dos Equipamentos',
                style: ts(7.5, c: cBr, b: true))),
        pw.Table(border: bTbl, columnWidths: const {
          0: pw.FixedColumnWidth(46),
          1: pw.FixedColumnWidth(53),
          2: pw.FlexColumnWidth(2),
          3: pw.FlexColumnWidth(2),
          4: pw.FlexColumnWidth(2),
          5: pw.FixedColumnWidth(46),
        }, children: [
          pw.TableRow(children: [
            hC('DATA'),
            hC('PATRIMONIO'),
            hC('AMBIENTE / SALA'),
            hC('EMPRESA EXECUTORA'),
            hC('NOME DO TECNICO'),
            hC('PROXIMA DATA')
          ]),
          ...List.generate(
              13,
              (i) => pw.TableRow(children: [
                    pw.Container(height: 13, color: i % 2 == 0 ? cG0 : cBr),
                    pw.Container(height: 13, color: i % 2 == 0 ? cG0 : cBr),
                    pw.Container(height: 13, color: i % 2 == 0 ? cG0 : cBr),
                    dC('HPS Refrigeracao',
                        bg: i % 2 == 0 ? cG0 : cBr, sz: 6.5, tc: cG5),
                    pw.Container(height: 13, color: i % 2 == 0 ? cG0 : cBr),
                    pw.Container(height: 13, color: i % 2 == 0 ? cG0 : cBr),
                  ])),
        ]),
        pw.SizedBox(height: 8),
        pw.Container(
            color: cV2,
            padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: pw.Text('PLANILHA 2 - Controle da Limpeza dos Filtros',
                style: ts(7.5, c: cBr, b: true))),
        pw.Table(border: bTbl, columnWidths: const {
          0: pw.FixedColumnWidth(46),
          1: pw.FixedColumnWidth(53),
          2: pw.FlexColumnWidth(2),
          3: pw.FlexColumnWidth(2),
          4: pw.FixedColumnWidth(46),
          5: pw.FixedColumnWidth(53),
        }, children: [
          pw.TableRow(children: [
            hC('DATA'),
            hC('PATRIMONIO'),
            hC('AMBIENTE / SALA'),
            hC('RESPONSAVEL'),
            hC('PROX. LIMPEZA'),
            hC('OBSERVACAO')
          ]),
          ...List.generate(10, (i) => emR(6, i)),
        ]),
        pw.SizedBox(height: 8),
        pw.Container(
            color: cV2,
            padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: pw.Text('PLANILHA 3 - Registro de Medicoes Eletricas',
                style: ts(7.5, c: cBr, b: true))),
        pw.Table(border: bTbl, columnWidths: const {
          0: pw.FixedColumnWidth(46),
          1: pw.FixedColumnWidth(53),
          2: pw.FlexColumnWidth(2),
          3: pw.FixedColumnWidth(32),
          4: pw.FixedColumnWidth(32),
          5: pw.FixedColumnWidth(32),
          6: pw.FlexColumnWidth(2),
        }, children: [
          pw.TableRow(children: [
            hC('DATA'),
            hC('PATRIMONIO'),
            hC('EQUIPAMENTO'),
            hC('V', al: pw.TextAlign.center),
            hC('A', al: pw.TextAlign.center),
            hC('PSI', al: pw.TextAlign.center),
            hC('TECNICO')
          ]),
          ...List.generate(10, (i) => emR(7, i)),
        ]),
        pw.Spacer(),
        pFtr(),
      ],
    ),
  ));

  onProgress(0.65, 'Fichas individuais...');

  // ════════════════════════════════════════════════════════════════════════════
  //  PAG 6+ — FICHAS INDIVIDUAIS  (2 por pagina)
  // ════════════════════════════════════════════════════════════════════════════
  for (int pg = 0; pg < equips.length; pg += 2) {
    final eq1 = equips[pg];
    final eq2 = (pg + 1) < equips.length ? equips[pg + 1] : null;
    onProgress(
      0.65 + 0.25 * ((pg / 2) / ((equips.length + 1) / 2)),
      'Fichas ${pg + 1}-${(pg + 2).clamp(1, equips.length)} de ${equips.length}...',
    );

    // funcao local para montar uma ficha
    pw.Widget ficha(Map<String, dynamic> eq, int idx) {
      final pat = (eq['PATRIMONIO'] ?? '-').toString();
      final equi = (eq['EQUIPAMENTO'] ?? 'AR CONDICIONADO').toString();
      final mod = (eq['MODELO'] ?? '-').toString();
      final marc = (eq['MARCA'] ?? '-').toString();

      return pw.Container(
        margin: const pw.EdgeInsets.only(bottom: 7),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: cG2, width: 0.5),
          borderRadius: pw.BorderRadius.circular(4),
        ),
        child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              // Cabecalho verde
              pw.Container(
                decoration: pw.BoxDecoration(
                  color: cV,
                  borderRadius: const pw.BorderRadius.only(
                    topLeft: pw.Radius.circular(3),
                    topRight: pw.Radius.circular(3),
                  ),
                ),
                padding:
                    const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text('FICHA DE MANUTENCAO  No $pat',
                                style: ts(9, c: cBr, b: true)),
                            pw.SizedBox(height: 1),
                            pw.Text('$equi  $mod  $marc',
                                style: ts(6,
                                    c: const PdfColor.fromInt(0xBBFFFFFF))),
                          ]),
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: pw.BoxDecoration(
                          color: const PdfColor.fromInt(0x22FFFFFF),
                          borderRadius: pw.BorderRadius.circular(3),
                        ),
                        child: pw.Text('${idx + 1} / ${equips.length}',
                            style: ts(6.5, c: cBr)),
                      ),
                    ]),
              ),
              // Faixa accent
              pw.Container(height: 1.5, color: cAc),

              // Dados em 2 colunas
              pw.Container(
                color: cG0,
                padding:
                    const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Expanded(
                          child: pw.Table(border: bTbl, columnWidths: const {
                        0: pw.FixedColumnWidth(68),
                        1: pw.FlexColumnWidth(),
                      }, children: [
                        pw.TableRow(children: [
                          lC('PATRIMONIO'),
                          dC(pat, b: true, tc: cV)
                        ]),
                        pw.TableRow(children: [lC('EQUIPAMENTO'), dC(equi)]),
                        pw.TableRow(children: [lC('MODELO'), dC(mod)]),
                        pw.TableRow(children: [lC('MARCA'), dC(marc)]),
                      ])),
                      pw.SizedBox(width: 6),
                      pw.Expanded(
                          child: pw.Table(border: bTbl, columnWidths: const {
                        0: pw.FixedColumnWidth(68),
                        1: pw.FlexColumnWidth(),
                      }, children: [
                        pw.TableRow(children: [
                          lC('LOCALIZACAO'),
                          dC((eq['SALA'] ?? '-').toString())
                        ]),
                        pw.TableRow(children: [
                          lC('SETOR'),
                          dC((eq['SETOR'] ?? '-').toString())
                        ]),
                        pw.TableRow(children: [
                          lC('BTUs'),
                          dC((eq['BTUS'] ?? '-').toString())
                        ]),
                        pw.TableRow(children: [
                          lC('GAS / TENSAO'),
                          dC('${eq['FLUIDO'] ?? '-'}  ${eq['TENSAO'] ?? '-'} V')
                        ]),
                      ])),
                    ]),
              ),

              // Grade mensal
              pw.Container(
                color: cV2,
                padding:
                    const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                child: pw.Text('REGISTRO MENSAL DE MANUTENCAO',
                    style: ts(6.5, c: cBr, b: true)),
              ),
              pw.Table(border: bTbl, columnWidths: const {
                0: pw.FixedColumnWidth(50),
                1: pw.FlexColumnWidth(1),
                2: pw.FlexColumnWidth(1),
                3: pw.FlexColumnWidth(1),
                4: pw.FlexColumnWidth(1),
                5: pw.FlexColumnWidth(1),
                6: pw.FlexColumnWidth(1),
                7: pw.FlexColumnWidth(1),
                8: pw.FlexColumnWidth(1),
                9: pw.FlexColumnWidth(1),
                10: pw.FlexColumnWidth(1),
                11: pw.FlexColumnWidth(1),
                12: pw.FlexColumnWidth(1),
              }, children: [
                // Cabecalho meses
                pw.TableRow(children: [
                  pw.Container(color: cV, padding: const pw.EdgeInsets.all(3)),
                  ...List.generate(
                      12,
                      (m) => pw.Container(
                            color: cV,
                            padding: const pw.EdgeInsets.symmetric(
                                horizontal: 1, vertical: 2),
                            alignment: pw.Alignment.center,
                            child: pw.Column(
                                mainAxisAlignment: pw.MainAxisAlignment.center,
                                children: [
                                  pw.Text(cal[m]['abr']!,
                                      style: ts(5.5, c: cBr, b: true),
                                      textAlign: pw.TextAlign.center),
                                  pw.Text(cal[m]['ano']!.substring(2),
                                      style: ts(4.5,
                                          c: const PdfColor.fromInt(
                                              0xBBFFFFFF)),
                                      textAlign: pw.TextAlign.center),
                                ]),
                          )),
                ]),
                pw.TableRow(children: [
                  pw.Container(
                      color: cG1,
                      padding: const pw.EdgeInsets.symmetric(
                          horizontal: 5, vertical: 3),
                      child: pw.Text('Data', style: ts(6.5, c: cG5, b: true))),
                  ...List.generate(
                      12, (_) => pw.Container(height: 14, color: cBr)),
                ]),
                pw.TableRow(children: [
                  pw.Container(
                      color: cG1,
                      padding: const pw.EdgeInsets.symmetric(
                          horizontal: 5, vertical: 3),
                      child:
                          pw.Text('Tecnico', style: ts(6.5, c: cG5, b: true))),
                  ...List.generate(
                      12, (_) => pw.Container(height: 14, color: cG0)),
                ]),
                pw.TableRow(children: [
                  pw.Container(
                      color: cG1,
                      padding: const pw.EdgeInsets.symmetric(
                          horizontal: 5, vertical: 3),
                      child: pw.Text('Assinatura',
                          style: ts(6.5, c: cG5, b: true))),
                  ...List.generate(
                      12, (_) => pw.Container(height: 20, color: cBr)),
                ]),
                pw.TableRow(children: [
                  pw.Container(
                      color: cG1,
                      padding: const pw.EdgeInsets.symmetric(
                          horizontal: 5, vertical: 3),
                      child: pw.Text('Obs.', style: ts(6.5, c: cG5, b: true))),
                  ...List.generate(
                      12, (_) => pw.Container(height: 20, color: cG0)),
                ]),
              ]),
            ]),
      );
    }

    final pgN = 6 + (pg ~/ 2);
    pdf.addPage(pw.Page(
      pageFormat: fmt,
      margin: marg,
      build: (ctx) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          pHdr('FICHAS INDIVIDUAIS DE MANUTENCAO', pgN),
          pw.SizedBox(height: 7),
          ficha(eq1, pg),
          if (eq2 != null) ficha(eq2, pg + 1),
          pw.Spacer(),
          pFtr(),
        ],
      ),
    ));
  }

  onProgress(0.92, 'Ultima pagina - Assinaturas...');

  // ════════════════════════════════════════════════════════════════════════════
  //  ULTIMA PAG — EMERGENCIA + REFERENCIAS + ASSINATURAS
  // ════════════════════════════════════════════════════════════════════════════
  final ultPg = 6 + ((equips.length + 1) ~/ 2);
  pdf.addPage(pw.Page(
    pageFormat: fmt,
    margin: marg,
    build: (ctx) => pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pHdr('EMERGENCIA E ASSINATURAS', ultPg),

        sTtl('9', 'Recomendacoes em Situacoes de Falha e Emergencia'),
        pw.Container(
          padding: const pw.EdgeInsets.all(9),
          decoration: pw.BoxDecoration(
            color: cG0,
            border: pw.Border.all(color: cG2, width: 0.5),
            borderRadius: pw.BorderRadius.circular(3),
          ),
          child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                    'Em caso de falha ou emergencia, desligar e contactar pessoal habilitado (Portaria MS 3.523/98, Art. 6):',
                    style: ts(7.5, b: true, c: cV)),
                pw.SizedBox(height: 5),
                ...[
                  'Vazamento de gas: desligar o equipamento, ventilar o ambiente e acionar o responsavel tecnico.',
                  'Curto-circuito ou odor de queimado: desligar o disjuntor do equipamento imediatamente.',
                  'Gotejamento da evaporadora: verificar o dreno e acionar a equipe de manutencao.',
                  'Ruidos ou vibracoes anormais: desligar e registrar a ocorrencia para avaliacao tecnica.',
                  'Nao realizar reparos sem qualificacao tecnica (risco de choque eletrico e perda de garantia).',
                  'Contato emergencial HPS Refrigeracao: (77) 98819-4630 / (77) 98861-2447.',
                ]
                    .map((t) => pw.Padding(
                          padding: const pw.EdgeInsets.only(bottom: 4),
                          child: pw.Row(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Container(
                                  width: 4,
                                  height: 4,
                                  margin: const pw.EdgeInsets.only(
                                      right: 6, top: 2),
                                  decoration: pw.BoxDecoration(
                                      color: cV, shape: pw.BoxShape.circle),
                                ),
                                pw.Expanded(child: pw.Text(t, style: ts(7.5))),
                              ]),
                        ))
                    .toList(),
              ]),
        ),

        sTtl('10', 'Referencias Bibliograficas'),
        pw.Container(
          padding: const pw.EdgeInsets.all(9),
          decoration: pw.BoxDecoration(
            color: cG0,
            border: pw.Border.all(color: cG2, width: 0.5),
            borderRadius: pw.BorderRadius.circular(3),
          ),
          child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                ...[
                  'Lei Federal n. 13.589, de 4 de janeiro de 2018.',
                  'Portaria do Ministerio da Saude n. 3.523, de 28 de agosto de 1998.',
                  'ABNT NBR 13971 - Manutencao Programada para sistemas de refrigeracao e condicionamento de ar.',
                  'ABNT NBR 16401-1/2008 - Instalacoes de Ar Condicionado - Sistemas Centrais e Unitarios.',
                  'ABNT NBR 15848 - Procedimentos e requisitos de qualidade do ar interior (QAI).',
                  'ABNT NBR 17.037/2023 - Padrao referencial de qualidade do ar interior.',
                  'Lei Federal n. 6.437, de 20 de agosto de 1977 - Infracoes a legislacao sanitaria federal.',
                ]
                    .map((t) => pw.Padding(
                          padding: const pw.EdgeInsets.only(bottom: 3),
                          child: pw.Row(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text('>  ', style: ts(8, c: cAc, b: true)),
                                pw.Expanded(child: pw.Text(t, style: ts(7.5))),
                              ]),
                        ))
                    .toList(),
              ]),
        ),

        pw.Spacer(),

        // Assinaturas
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: pw.BoxDecoration(
            color: cG0,
            border: pw.Border.all(color: cG2, width: 0.5),
            borderRadius: pw.BorderRadius.circular(4),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              // HPS
              pw.SizedBox(
                  width: 210,
                  child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        if (_cachedAssin != null)
                          pw.Container(
                              height: 46,
                              child: pw.Image(_cachedAssin!,
                                  fit: pw.BoxFit.contain))
                        else
                          pw.SizedBox(height: 46),
                        pw.Container(
                            width: 210, height: 0.8, color: PdfColors.black),
                        pw.SizedBox(height: 4),
                        pw.Text('RESPONSAVEL TECNICO',
                            style: ts(6, c: cG5, b: true),
                            textAlign: pw.TextAlign.center),
                        pw.Text(tecnico.isNotEmpty ? tecnico : 'Huagner Pires',
                            style: ts(8.5, c: cV, b: true),
                            textAlign: pw.TextAlign.center),
                        pw.Text('HPS Refrigeracao',
                            style: ts(7, c: cG5),
                            textAlign: pw.TextAlign.center),
                        if (crea.isNotEmpty)
                          pw.Text('CREA/CFT: $crea',
                              style: ts(6.5, c: cG5),
                              textAlign: pw.TextAlign.center),
                        pw.SizedBox(height: 8),
                        pw.Text('Data: ___ / ___ / ______',
                            style: ts(7.5), textAlign: pw.TextAlign.center),
                      ])),

              pw.Container(width: 0.5, height: 80, color: cG2),

              // Cliente
              pw.SizedBox(
                  width: 210,
                  child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        if (logoCliente != null)
                          pw.Container(
                              height: 46,
                              child:
                                  pw.Image(logoCliente, fit: pw.BoxFit.contain))
                        else
                          pw.SizedBox(height: 46),
                        pw.Container(
                            width: 210, height: 0.8, color: PdfColors.black),
                        pw.SizedBox(height: 4),
                        pw.Text('RESPONSAVEL DO ESTABELECIMENTO',
                            style: ts(6, c: cG5, b: true),
                            textAlign: pw.TextAlign.center),
                        pw.Text(
                            nomeCliente.isNotEmpty ? nomeCliente : 'CLIENTE',
                            style: ts(8.5, c: cV, b: true),
                            textAlign: pw.TextAlign.center),
                        if (cnpjCliente.isNotEmpty)
                          pw.Text('CNPJ: $cnpjCliente',
                              style: ts(6.5, c: cG5),
                              textAlign: pw.TextAlign.center),
                        pw.SizedBox(height: 8),
                        pw.Text('Data: ___ / ___ / ______',
                            style: ts(7.5), textAlign: pw.TextAlign.center),
                      ])),
            ],
          ),
        ),

        pw.SizedBox(height: 6),
        pw.Center(
            child: pw.Text(
          'Este documento deve ser mantido no estabelecimento e apresentado as autoridades sanitarias quando solicitado (Portaria MS 3.523/98, Art. 6).',
          style: ts(6.5, c: cG5),
          textAlign: pw.TextAlign.center,
        )),
        pw.SizedBox(height: 8),
        pFtr(),
      ],
    ),
  ));

  onProgress(0.98, 'Finalizando PDF...');
  final bytes = await pdf.save();
  if (bytes.isEmpty) throw Exception('PDF PMOC vazio');
  onProgress(1.0, 'Concluido!');
  return Uint8List.fromList(bytes);
}

/// ─────────────────────────────────────────────────────────────────────────────
/// WIDGET PRINCIPAL
/// ─────────────────────────────────────────────────────────────────────────────
class EmitirPmocWidget extends StatefulWidget {
  const EmitirPmocWidget({super.key, this.width, this.height, this.onCancelar});
  final double? width;
  final double? height;
  final Future<dynamic> Function()? onCancelar;

  @override
  State<EmitirPmocWidget> createState() => _EmitirPmocWidgetState();
}

class _EmitirPmocWidgetState extends State<EmitirPmocWidget>
    with TickerProviderStateMixin {
  List<Map<String, dynamic>> _usuarios = [];
  bool _loadingUsuarios = true;
  String? _emailSel;
  List<String> _emailsExtras = [];
  List<String> _emailsDest = [];
  Map<String, dynamic>? _dadosCliente;
  int _mesIni = DateTime.now().month;
  int _anoIni = DateTime.now().year;
  bool _enviando = false, _enviado = false;
  double _prog = 0;
  String _label = '';
  late final AnimationController _ac;
  late final Animation<double> _an;
  final _tCtrl = TextEditingController(text: 'Huagner Pires');
  final _cCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _ac = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _an = CurvedAnimation(parent: _ac, curve: Curves.elasticOut);
    _load();
  }

  @override
  void dispose() {
    _ac.dispose();
    _tCtrl.dispose();
    _cCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final s = await FirebaseFirestore.instance.collection('USUARIOS').get();
      final l = <Map<String, dynamic>>[];
      for (final d in s.docs) {
        final data = d.data();
        final em = data['email']?.toString().trim() ?? '';
        if (em.isEmpty) continue;
        final extras = <String>[];
        final f = data['emailteste'];
        if (f is List) {
          for (final e in f) {
            final s = e?.toString().trim() ?? '';
            if (s.isNotEmpty) extras.add(s);
          }
        } else if (f is String && f.trim().isNotEmpty) {
          extras.add(f.trim());
        }
        l.add({
          'email': em,
          'nome': data['display_name']?.toString().trim() ?? em,
          'extras': extras,
          'dados': data,
        });
      }
      if (mounted)
        setState(() {
          _usuarios = l;
          _loadingUsuarios = false;
        });
    } catch (_) {
      if (mounted) setState(() => _loadingUsuarios = false);
    }
  }

  void _selUser(String? em) {
    if (em == null) return;
    final u = _usuarios.firstWhere((u) => u['email'] == em, orElse: () => {});
    final ex = List<String>.from(u['extras'] ?? []);
    if (!ex.contains(em)) ex.insert(0, em);
    setState(() {
      _emailSel = em;
      _dadosCliente = u['dados'] as Map<String, dynamic>?;
      _emailsExtras = ex;
      _emailsDest = [];
    });
  }

  Future<void> _emitir() async {
    if (_emailSel == null) {
      _toast('Selecione o cliente');
      return;
    }
    if (_emailsDest.isEmpty) {
      _toast('Selecione pelo menos um e-mail');
      return;
    }
    final tecnico =
        _tCtrl.text.trim().isNotEmpty ? _tCtrl.text.trim() : 'Huagner Pires';
    final crea = _cCtrl.text.trim();
    setState(() {
      _enviando = true;
      _prog = 0;
      _label = 'Buscando equipamentos...';
    });
    try {
      await _step(0.05, 'Buscando equipamentos...');
      final equips = await _buscarEquipamentos(_emailSel!);
      if (equips.isEmpty) {
        setState(() => _enviando = false);
        _toast('Nenhum equipamento com contrato ativo');
        return;
      }

      await _step(0.08, 'Gerando PDF do PMOC...');
      final pdfBytes = await _gerarPmoc(
        cliente: _dadosCliente ?? {},
        equips: equips,
        mesIni: _mesIni,
        anoIni: _anoIni,
        tecnico: tecnico,
        crea: crea,
        onProgress: (v, l) {
          if (mounted)
            setState(() {
              _prog = 0.08 + v * 0.55;
              _label = l;
            });
        },
      );

      await _step(0.65, 'Salvando na nuvem...');
      final mn = _meses[_mesIni];
      final mesStr = mn[0] + mn.substring(1).toLowerCase();
      final ref = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('$_emailSel/PMOC/PMOC_${mesStr}_$_anoIni.pdf');
      await ref.putData(pdfBytes,
          firebase_storage.SettableMetadata(contentType: 'application/pdf'));
      final url = await ref.getDownloadURL();

      await _step(0.75, 'Buscando API...');
      final apiKey = await _buscarApiBrevo();

      await _step(0.80, 'Enviando e-mail...');
      final cal = _calendario(_mesIni, _anoIni);
      final vig =
          '${cal.first['mes']!}/${cal.first['ano']!} a ${cal.last['mes']!}/${cal.last['ano']!}';
      final nome = (_dadosCliente?['display_name'] ?? _emailSel!)
          .toString()
          .toUpperCase();
      await _sendEmail(
        to: _emailsDest,
        subject: 'PMOC $nome Vigencia $vig',
        html: _htmlEmail(nome: nome, vig: vig, total: equips.length, url: url),
        apiKey: apiKey,
      );

      await _step(0.90, 'Enviando push...');
      await Future.wait([
        _push(
            email: _emailSel!,
            titulo: 'PMOC Emitido',
            msg:
                'PMOC gerado com ${equips.length} equipamentos vigencia $vig.'),
        _push(
            email: _kEmailHPS,
            titulo: 'PMOC Emitido',
            msg:
                'PMOC de $nome ($vig) com ${equips.length} equipamentos enviado.'),
      ]);

      await _step(0.96, 'Salvando notificacao...');
      await Future.wait([
        _notificacao(email: _emailSel!, nome: nome, vig: vig),
        _notificacao(email: _kEmailHPS, nome: nome, vig: vig),
      ]);

      await _step(1.0, 'Concluido!');
      if (!mounted) return;
      setState(() {
        _enviado = true;
        _enviando = false;
      });
      _ac.forward();
      await Future.delayed(const Duration(milliseconds: 3500));
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        setState(() {
          _enviando = false;
          _prog = 0;
        });
        _toast('Erro: $e');
      }
    }
  }

  Future<void> _step(double a, String l) async {
    if (!mounted) return;
    setState(() => _label = l);
    final ini = _prog;
    final d = a - ini;
    for (int i = 1; i <= 15; i++) {
      await Future.delayed(const Duration(milliseconds: 18));
      if (!mounted) return;
      setState(() => _prog = ini + d * (i / 15));
    }
  }

  void _toast(String m) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(m), duration: const Duration(seconds: 3)),
    );
  }

  InputDecoration _inp(String hint, bool dark) => InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: dark ? Colors.white54 : Colors.black54),
        filled: true,
        fillColor: dark ? const Color(0xFF252D3A) : const Color(0xFFF4F6F8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: dark ? Colors.white12 : Colors.black12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: dark ? Colors.white12 : Colors.black12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _kVerdePmoc, width: 1.8),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      );

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = dark ? const Color(0xFF1E2530) : Colors.white;
    final border = dark ? Colors.white12 : Colors.black12;
    final tc = dark ? Colors.white : Colors.black87;
    final anos = [
      DateTime.now().year - 1,
      DateTime.now().year,
      DateTime.now().year + 1
    ];

    // ── Tela de sucesso ──────────────────────────────────────────────────────
    if (_enviado) {
      return Container(
        width: widget.width,
        padding: const EdgeInsets.all(36),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withAlpha(25), blurRadius: 20)
          ],
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ScaleTransition(
            scale: _an,
            child: Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.green.shade300, width: 3),
              ),
              child: const Icon(Icons.description_rounded,
                  color: Colors.green, size: 46),
            ),
          ),
          const SizedBox(height: 22),
          const Text('PMOC emitido com sucesso!',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green)),
          const SizedBox(height: 10),
          Text('Enviado para:\n${_emailsDest.join("\n")}',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 13,
                  color: dark ? Colors.white54 : Colors.black54,
                  height: 1.6)),
          const SizedBox(height: 16),
          Row(mainAxisSize: MainAxisSize.min, children: [
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
        ]),
      );
    }

    // ── Formulario ───────────────────────────────────────────────────────────
    final form = Container(
      width: widget.width,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(dark ? 100 : 20),
            blurRadius: 20,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                _kBannerUrl,
                width: double.infinity,
                height: 100,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 60,
                  decoration: BoxDecoration(
                      color: _kVerdePmoc,
                      borderRadius: BorderRadius.circular(12)),
                  child: const Center(
                      child: Text('HPS Refrigeracao',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18))),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Titulo
            Row(children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                    color: _kVerdePmoc, borderRadius: BorderRadius.circular(8)),
                child: const Text('PMOC',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13)),
              ),
              const SizedBox(width: 10),
              Expanded(
                  child: Text('Plano de Manutencao, Operacao e Controle',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: tc))),
            ]),
            const SizedBox(height: 3),
            Text('Lei 13.589/2018  Portaria MS 3.523/98  ABNT NBR 13971',
                style: TextStyle(
                    fontSize: 11,
                    color: dark ? Colors.white38 : Colors.black38)),
            const SizedBox(height: 14),
            Divider(color: border),
            const SizedBox(height: 10),

            // Cliente
            Text('Cliente / Empresa',
                style: TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 14, color: tc)),
            const SizedBox(height: 8),
            _loadingUsuarios
                ? const Center(
                    child: Padding(
                        padding: EdgeInsets.all(12),
                        child: CircularProgressIndicator(strokeWidth: 2)))
                : DropdownButtonFormField<String>(
                    value: _emailSel,
                    hint: Text('Selecione o cliente',
                        style: TextStyle(
                            color: dark ? Colors.white54 : Colors.black54)),
                    isExpanded: true,
                    decoration: _inp('Selecione o cliente', dark),
                    dropdownColor:
                        dark ? const Color(0xFF252D3A) : Colors.white,
                    style: TextStyle(color: tc),
                    items: _usuarios.map((u) {
                      final em = u['email']?.toString() ?? '';
                      final nm = u['nome']?.toString() ?? em;
                      return DropdownMenuItem<String>(
                        value: em,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(nm,
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: tc),
                                overflow: TextOverflow.ellipsis),
                            Text(em,
                                style: TextStyle(
                                    fontSize: 12,
                                    color: dark
                                        ? Colors.white54
                                        : Colors.grey.shade500),
                                overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: _selUser,
                  ),
            const SizedBox(height: 16),

            // Destinatarios
            if (_emailSel != null) ...[
              Row(children: [
                Text('Destinatarios',
                    style: TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14, color: tc)),
                const SizedBox(width: 8),
                if (_emailsDest.isNotEmpty)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                        color: _kVerdePmoc,
                        borderRadius: BorderRadius.circular(10)),
                    child: Text('+${_emailsDest.length}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600)),
                  ),
              ]),
              const SizedBox(height: 8),
              _emailsExtras.isEmpty
                  ? Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: dark
                            ? const Color(0xFF252D3A)
                            : const Color(0xFFF4F6F8),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: border),
                      ),
                      child: const Text('Nenhum e-mail adicional cadastrado',
                          style: TextStyle(fontSize: 13, color: Colors.grey)),
                    )
                  : Container(
                      decoration: BoxDecoration(
                        color: dark
                            ? const Color(0xFF252D3A)
                            : const Color(0xFFF4F6F8),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: border),
                      ),
                      child: Column(
                        children: List.generate(_emailsExtras.length, (idx) {
                          final em = _emailsExtras[idx];
                          final sel = _emailsDest.contains(em);
                          return Column(children: [
                            if (idx > 0) Divider(height: 1, color: border),
                            InkWell(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(idx == 0 ? 10 : 0),
                                topRight: Radius.circular(idx == 0 ? 10 : 0),
                                bottomLeft: Radius.circular(
                                    idx == _emailsExtras.length - 1 ? 10 : 0),
                                bottomRight: Radius.circular(
                                    idx == _emailsExtras.length - 1 ? 10 : 0),
                              ),
                              onTap: () => setState(() {
                                if (sel)
                                  _emailsDest.remove(em);
                                else
                                  _emailsDest.add(em);
                              }),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 11),
                                child: Row(children: [
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    width: 22,
                                    height: 22,
                                    decoration: BoxDecoration(
                                      color: sel
                                          ? _kVerdePmoc
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: sel
                                            ? _kVerdePmoc
                                            : (dark
                                                ? Colors.white30
                                                : Colors.grey.shade400),
                                        width: 2,
                                      ),
                                    ),
                                    child: sel
                                        ? const Icon(Icons.check,
                                            color: Colors.white, size: 14)
                                        : null,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                      child: Text(em,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: sel
                                                ? FontWeight.w600
                                                : FontWeight.normal,
                                            color: sel ? _kVerdePmoc : tc,
                                          ))),
                                ]),
                              ),
                            ),
                          ]);
                        }),
                      ),
                    ),
              const SizedBox(height: 16),
            ],

            // Vigencia
            Text('Inicio da Vigencia (12 meses)',
                style: TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 14, color: tc)),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(
                  child: DropdownButtonFormField<int>(
                value: _mesIni,
                isExpanded: true,
                decoration: _inp('Mes', dark),
                dropdownColor: dark ? const Color(0xFF252D3A) : Colors.white,
                style: TextStyle(color: tc),
                items: List.generate(
                    12,
                    (i) => DropdownMenuItem<int>(
                          value: i + 1,
                          child: Text(_meses[i + 1],
                              style: TextStyle(fontSize: 13, color: tc)),
                        )),
                onChanged: (v) {
                  if (v != null) setState(() => _mesIni = v);
                },
              )),
              const SizedBox(width: 10),
              Expanded(
                  child: DropdownButtonFormField<int>(
                value: _anoIni,
                isExpanded: true,
                decoration: _inp('Ano', dark),
                dropdownColor: dark ? const Color(0xFF252D3A) : Colors.white,
                style: TextStyle(color: tc),
                items: anos
                    .map((a) => DropdownMenuItem<int>(
                          value: a,
                          child: Text(a.toString(),
                              style: TextStyle(fontSize: 13, color: tc)),
                        ))
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _anoIni = v);
                },
              )),
            ]),
            const SizedBox(height: 16),

            // Tecnico
            Text('Responsavel Tecnico',
                style: TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 14, color: tc)),
            const SizedBox(height: 8),
            TextField(
                controller: _tCtrl,
                decoration: _inp('Nome do tecnico responsavel', dark),
                style: TextStyle(color: tc, fontSize: 14)),
            const SizedBox(height: 10),
            TextField(
                controller: _cCtrl,
                decoration: _inp('CREA / CFT (opcional)', dark),
                style: TextStyle(color: tc, fontSize: 14)),
            const SizedBox(height: 16),

            // Preview
            if (_emailSel != null) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _kVerdePmoc.withAlpha(dark ? 38 : 15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _kVerdePmoc.withAlpha(60)),
                ),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(children: [
                        Icon(Icons.preview_outlined,
                            size: 15, color: _kVerdePmoc),
                        SizedBox(width: 6),
                        Text('Resumo',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _kVerdePmoc)),
                      ]),
                      const SizedBox(height: 8),
                      _pr(
                          'Cliente',
                          (_dadosCliente?['display_name'] ?? _emailSel!)
                              .toString(),
                          dark),
                      _pr('Vigencia', () {
                        final c = _calendario(_mesIni, _anoIni);
                        return '${c.first['mes']!}/${c.first['ano']!} a ${c.last['mes']!}/${c.last['ano']!}';
                      }(), dark),
                      _pr(
                          'Para',
                          _emailsDest.isNotEmpty
                              ? _emailsDest.join(', ')
                              : 'Nenhum selecionado',
                          dark),
                      _pr(
                          'Conteudo',
                          'Identificacao  Ambientes  Atividades  Cronograma  Planilhas  Fichas  Assinaturas',
                          dark),
                    ]),
              ),
              const SizedBox(height: 16),
            ],

            // Botoes
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
                  side:
                      BorderSide(color: dark ? Colors.white24 : Colors.black26),
                ),
                child: Text('Cancelar', style: TextStyle(color: tc)),
              )),
              const SizedBox(width: 12),
              Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.description_rounded,
                        size: 16, color: Colors.white),
                    label: const Text('Emitir PMOC',
                        style: TextStyle(color: Colors.white)),
                    onPressed: _enviando ? null : _emitir,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _kVerdePmoc,
                      elevation: 1,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  )),
            ]),
          ],
        ),
      ),
    );

    // ── Overlay de progresso ─────────────────────────────────────────────────
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
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withAlpha(76), blurRadius: 24)
                ],
              ),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Container(
                  width: 66,
                  height: 66,
                  decoration: BoxDecoration(
                      color: _kVerdePmoc.withAlpha(30), shape: BoxShape.circle),
                  child: const Icon(Icons.description_rounded,
                      color: _kVerdePmoc, size: 34),
                ),
                const SizedBox(height: 16),
                Text('Gerando PMOC',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: dark ? Colors.white : Colors.black87)),
                const SizedBox(height: 6),
                Text(_label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 13,
                        color: dark ? Colors.white54 : Colors.black54)),
                const SizedBox(height: 20),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: _prog,
                    minHeight: 10,
                    backgroundColor:
                        dark ? Colors.white12 : Colors.grey.shade200,
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(_kVerdePmoc),
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '${(_prog * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(
                          fontSize: 12,
                          color: _kVerdePmoc,
                          fontWeight: FontWeight.bold),
                    )),
              ]),
            )),
          ),
        )),
      ]);
    }

    return form;
  }

  Widget _pr(String l, String v, bool dark) => Padding(
        padding: const EdgeInsets.only(bottom: 5),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(
              width: 62,
              child: Text('$l:',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: dark ? Colors.white54 : Colors.black54))),
          Expanded(
              child: Text(v,
                  style: TextStyle(
                      fontSize: 12,
                      color: dark ? Colors.white70 : Colors.black87))),
        ]),
      );
}
