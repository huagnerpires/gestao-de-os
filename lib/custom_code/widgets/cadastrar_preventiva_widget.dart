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

import 'index.dart';
import '/custom_code/actions/index.dart';
import '/flutter_flow/custom_functions.dart';

import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'dart:convert';
import '/flutter_flow/uploaded_file.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:image/image.dart' as img;
import 'dart:async';
import 'dart:typed_data';

// ============================================================
// CACHE ESTÁTICO
// ============================================================
Uint8List? _cachedLogo;
Uint8List? _cachedAssinatura;
pw.Font? _cachedFontRegular;
pw.Font? _cachedFontBold;

const _urlLogo = 'https://i.ibb.co/VpqNsxXt/Imagem1.jpg';
const _urlAssinatura =
    'https://i.ibb.co/hRvtGhbK/3b004d07-a4a9-4568-9d8b-5abc281dbcee.png';

const _kTimeout = Duration(seconds: 5);
const _kJpegQualityFotos = 80;
const _kMaxWidthFotosGrandes = 1200;
const _kMaxWidthAssinatura = 800;
const _kQualityAssinatura = 90;

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
  final lowerUrl = url.toLowerCase();
  if (lowerUrl.contains('.webp') || lowerUrl.contains('webp')) return bytes;
  if (isPng) return _comprimirPNG(bytes, maxWidth: maxWidth, quality: quality);
  return _comprimirImagem(bytes, maxWidth: maxWidth, quality: quality);
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
    _cachedLogo != null ? Future.value(_cachedLogo!) : _fetchBytes(_urlLogo),
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

Future<void> geraPDFPreventiva(String patrimonio, String? emailCliente) async {
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
            : _fetchBytes(_urlLogo),
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
        final dataA = (a.data()['datacadastro'] as Timestamp?)?.toDate();
        final dataB = (b.data()['datacadastro'] as Timestamp?)?.toDate();
        if (dataA == null) return 1;
        if (dataB == null) return -1;
        return dataB.compareTo(dataA);
      });

    final data = listaDocs.first.data();

    String nomeClienteRodape = '';
    String cnpjClienteRodape = '';
    String? fotoClienteUrl;

    if (usuariosQuery != null && usuariosQuery.docs.isNotEmpty) {
      final userData = usuariosQuery.docs.first.data();
      nomeClienteRodape =
          (userData['display_name'] ?? '').toString().toUpperCase();
      cnpjClienteRodape =
          (userData['CNPJ'] ?? userData['cnpj'] ?? '').toString();
      final photoUrl = userData['photo_url']?.toString().trim();
      if (photoUrl != null && photoUrl.startsWith('http'))
        fotoClienteUrl = photoUrl;
    }

    String? imgEvaporadoraUrl;
    if (imgQuery.docs.isNotEmpty) {
      final url = imgQuery.docs.first.data()['IMAGEM']?.toString().trim();
      if (url != null && url.startsWith('http')) imgEvaporadoraUrl = url;
    }

    final urlTermo = data['IMAGEM']?.toString().trim();

    final imageResults = await Future.wait([
      fotoClienteUrl != null ? _fetchBytes(fotoClienteUrl) : Future.value(null),
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

    final bool checkLimpezaCompressor = data['LIMPEZACOMPRESSOR'] == true;

    final dataInicio = data['datacadastro'] != null
        ? formatarData((data['datacadastro'] as Timestamp).toDate())
        : '';
    final textoObservacao = (data['OBSERVACAO'] ?? '').toString().trim();

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
                                      fit: pw.BoxFit.contain, dpi: 300)),
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
                                      fit: pw.BoxFit.contain, dpi: 300))
                            else
                              pw.Text(nomeClienteRodape,
                                  style: pw.TextStyle(
                                      fontSize: 7,
                                      fontWeight: pw.FontWeight.bold)),
                          ]))),
            ])),
        pw.SizedBox(height: 5),
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
                    buildIdentRow('APARELHO:', (data['NOME'] ?? '').toString(),
                        'VOLTAGEM:', (data['TENSAO'] ?? '').toString()),
                    buildIdentRow('MODELO:', (data['MODELO'] ?? '').toString(),
                        'GÁS:', (data['FLUIDO'] ?? '').toString()),
                    buildIdentRow('TIPO:', (data['TIPO'] ?? '').toString(),
                        'POTÊNCIA:', (data['BTUS'] ?? '').toString()),
                    buildIdentRow(
                        'FABRICANTE:',
                        (data['MARCA'] ?? '').toString(),
                        'PRÉDIO:',
                        (data['SETOR'] ?? '').toString()),
                    buildIdentRow(
                        'PATRIMÔNIO:',
                        (data['PATRIMONIO'] ?? '').toString(),
                        'LOCALIZAÇÃO:',
                        (data['SALA'] ?? '').toString()),
                    buildIdentRow(
                        'TÉCNICO:',
                        (data['TECNICORESPONSAVEL'] ?? '').toString(),
                        'MANUTENÇÃO:',
                        (data['TIPOMANUTENCAO'] ?? '').toString()),
                  ]),
            ])),
        pw.SizedBox(height: 5),
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
                                            fit: pw.BoxFit.cover, dpi: 150)
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
                                  data['LIMPEZAEVAPORADORAINTERNA'] == true),
                              buildCheckRow('2', 'LIMPEZA DO FILTRO:',
                                  data['LIMPEZAFILTRO'] == true),
                              buildCheckRow('3', 'LIMPEZA COM BACTERICIDA:',
                                  data['LIMPEZABACTERICIDA'] == true),
                              buildCheckRow(
                                  '4',
                                  'VERIFICAÇÃO DO CONTROLE E PILHAS:',
                                  data['VERIFICAODOCONTROLPILHAS'] == true),
                              buildCheckRow('5', 'VERIFICAR RUÍDOS:',
                                  data['VERIFICAODERUIDOS'] == true),
                              buildCheckRow('6', 'VERIFICAR MAL CHEIRO:',
                                  data['VERIFICAOMALCHEIRO'] == true),
                              buildValueRow('7', 'CORRENTE ELÉTRICA (A):',
                                  (data['AMPERAGEM'] ?? '').toString()),
                              buildValueRow('8', 'TENSÃO ELÉTRICA (V):',
                                  (data['TENSAO'] ?? '').toString()),
                            ]),
                          ]))),
                ])),
        pw.SizedBox(height: 5),
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
                                            fit: pw.BoxFit.cover, dpi: 150)
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
                                data['VERIFICAODODRENO'] == true),
                            buildCheckRow('2', 'VERIFICAR PRESSÃO (PSI):',
                                data['VERIFICAODAPRESSAO'] == true),
                            buildCheckRow('3', 'POLIR CONDENSADORA:',
                                data['POLIRCONDENSADORA'] == true),
                            buildCheckRow('4', 'VERIFICAR PARTE ELÉTRICA:',
                                data['VERIFICAODAPARTEELETRICA'] == true),
                            buildCheckRow('5', 'VERIFICAR ISOLAMENTO TÉRMICO:',
                                data['VERIFICAODOISOLAMENTOTRMICO'] == true),
                            buildCheckRow('6', 'JATEAMENTO DA CONDENSADORA:',
                                data['JATEAMENTOCONDENSADORA'] == true),
                            buildCheckRow('7', 'JATEAMENTO DA EVAPORADORA:',
                                data['JATEAMENTOEVAPORADORA'] == true),
                            buildCheckRow('8', 'LAVAGEM DO DRENO:',
                                data['LAVAGEMDRENO'] == true),
                            buildCheckRow(
                                '9',
                                'LAVAGEM DA CARCAÇA EVAPORADORA:',
                                data['LAVAGEMCARCACAEVAP'] == true),
                            buildCheckRow(
                                '10',
                                'LAVAGEM DA CARCAÇA CONDENSADORA:',
                                data['LAVAGEMCARCACACOND'] == true),
                            buildCheckRow(
                                '11',
                                'LIMPEZA E LUBRIFICAÇÃO DO COMPRESSOR:',
                                checkLimpezaCompressor),
                            buildCheckRow(
                                '12',
                                'LAVAGEM DA TURBINA EVAPORADORA:',
                                data['LAVAGEMTURBINAEVAP'] == true),
                            buildCheckRow('13', 'VERIFICAR PÉS DE BORRACHA:',
                                data['VERIFICAODOSPEDEBORRACHA'] == true),
                          ]))),
                ])),
        pw.SizedBox(height: 5),
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
                      child: pw.Text(
                          [
                            'Higienização: Aplicar produtos bactericidas específicos para eliminar microrganismos.',
                            'Filtros de Ar: Remover, lavar com água corrente e sabão neutro, secar completamente.',
                            'Medir e informar tensão elétrica',
                            'Medir e informar corrente elétrica',
                            'Limpar carenagem da evaporadora. Verificar ruídos, vazamentos e mau cheiro.',
                          ][i],
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

    const listaMeses = [
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
    final now = DateTime.now();
    final storagePath =
        '$pastaEmail/${now.year}/${listaMeses[now.month - 1]}/${patrimonio.trim()}.pdf';
    final Uint8List pdfUint8 = Uint8List.fromList(await pdf.save());

    final uploadFuture = firebase_storage.FirebaseStorage.instance
        .ref()
        .child(storagePath)
        .putData(pdfUint8,
            firebase_storage.SettableMetadata(contentType: 'application/pdf'));

    Printing.layoutPdf(
        onLayout: (_) async => pdfUint8,
        name: '${patrimonio.trim()}_preventiva.pdf');

    await uploadFuture;
  } catch (e) {
    print('Erro PDF: $e');
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// HELPERS GLOBAIS PARA PENDÊNCIA
// ══════════════════════════════════════════════════════════════════════════════

Future<String?> _buscarPendenciaId(String patrimonio, int mes, int ano) async {
  DateTime? toDateTime(dynamic raw) {
    if (raw == null) return null;
    if (raw is Timestamp) return raw.toDate().toLocal();
    if (raw is DateTime) return raw.toLocal();
    return null;
  }

  const camposPatrimonio = [
    'patrimonio',
    'PATRIMONIO',
    'patrimônio',
    'PATRIMÔNIO'
  ];
  const camposData = [
    'criadoEm',
    'timestampVisita',
    'atualizadoEm',
    'dataVisita'
  ];

  for (final campo in camposPatrimonio) {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('PENDENCIAS')
          .where(campo, isEqualTo: patrimonio)
          .get();
      if (snap.docs.isEmpty) continue;
      for (final doc in snap.docs) {
        final d = doc.data();
        final status = (d['status'] ?? '').toString().toLowerCase();
        if (status != 'pendente') continue;
        DateTime? dataDoc;
        for (final cd in camposData) {
          dataDoc = toDateTime(d[cd]);
          if (dataDoc != null) break;
        }
        if (dataDoc == null) continue;
        if (dataDoc.month == mes && dataDoc.year == ano) return doc.id;
      }
    } catch (e) {
      print('⚠️ Erro ao buscar pendência com campo "$campo": $e');
    }
  }
  return null;
}

Future<bool> _deletarPendencia(String docId) async {
  try {
    await FirebaseFirestore.instance
        .collection('PENDENCIAS')
        .doc(docId)
        .delete();
    return true;
  } catch (e) {
    print('❌ Erro ao deletar pendência $docId: $e');
    return false;
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// EMAIL — notifica cliente que a pendência foi resolvida e a manutenção
// foi realizada com sucesso. Layout idêntico ao EnviarEmailWidget.
// ══════════════════════════════════════════════════════════════════════════════
Future<bool> _sendEmailPreventivaRealizada({
  required String toEmail,
  required String equipamento,
  required String patrimonio,
  required String sala,
  required String setor,
  required String dataRealizacao,
  required String tipoManutencao,
}) async {
  const apiKey =
      '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';
  const senderEmail = 'equipe@hpsrefri.com.br';
  const senderName = 'HPS Refrigeração';
  const imgUrl =
      'https://firebasestorage.googleapis.com/v0/b/h-p-s-modificado-emdcp0.appspot.com/o/Gemini_Generated_Image_2xpdsd2xpdsd2xpd%20(1).png?alt=media&token=be3e052e-a0b8-4e8c-8151-b9365b507ed5';

  const subject = 'Manutenção Preventiva Concluída com Sucesso ✅';

  final htmlBody = '''
<!DOCTYPE html>
<html lang="pt-BR">
<head>
  <meta charset="UTF-8">
  <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
  <title>$subject</title>
</head>
<body style="margin:0;padding:0;background-color:#f4f6f8;font-family:Arial,Helvetica,sans-serif;">
  <table width="100%" cellpadding="0" cellspacing="0" border="0" style="background-color:#f4f6f8;padding:20px 0;">
    <tr><td align="center">
      <table width="600" cellpadding="0" cellspacing="0" border="0"
             style="background:#ffffff;border-radius:12px;overflow:hidden;max-width:600px;width:100%;">

        <!-- BANNER -->
        <tr>
          <td style="padding:0;margin:0;line-height:0;">
            <img src="$imgUrl" alt="HPS Refrigeração" width="600"
                 style="display:block;width:100%;max-width:600px;height:auto;border:0;"/>
          </td>
        </tr>

        <!-- BARRA VERDE -->
        <tr>
          <td style="background-color:#1A3C34;padding:12px 24px;">
            <table width="100%" cellpadding="0" cellspacing="0" border="0">
              <tr>
                <td></td>
                <td align="right">
                  <span style="background:#ffffff20;color:#ffffff;font-size:11px;font-weight:bold;padding:4px 10px;border-radius:20px;font-family:Arial,sans-serif;">
                    Notificação Automática
                  </span>
                </td>
              </tr>
            </table>
          </td>
        </tr>

        <!-- ÍCONE + TÍTULO -->
        <tr>
          <td style="padding:32px 28px 12px 28px;text-align:center;">
            <div style="display:inline-block;background:#f0fdf4;border-radius:50%;width:72px;height:72px;line-height:72px;text-align:center;border:2px solid #86efac;">
              <span style="font-size:36px;">✅</span>
            </div>
            <h1 style="margin:16px 0 4px 0;font-size:22px;font-weight:bold;color:#1A3C34;font-family:Arial,sans-serif;">
              Manutenção Realizada com Sucesso!
            </h1>
            <p style="margin:0;font-size:13px;color:#64748b;font-family:Arial,sans-serif;">
              A pendência de manutenção foi resolvida e o equipamento está em pleno funcionamento.
            </p>
          </td>
        </tr>

        <!-- CORPO -->
        <tr>
          <td style="padding:20px 28px;color:#333333;font-size:15px;line-height:1.7;font-family:Arial,Helvetica,sans-serif;">

            <p style="margin:0 0 16px 0;font-size:15px;color:#1f2937;line-height:1.7;">Prezados,</p>

            <p style="margin:0 0 20px 0;font-size:15px;color:#374151;line-height:1.7;">
              É com satisfação que informamos que a <strong>manutenção preventiva</strong>
              do equipamento <strong>$equipamento</strong> (Patrimônio:&nbsp;<strong>$patrimonio</strong>),
              localizado na <strong>sala $sala</strong>, setor <strong>$setor</strong>,
              foi <span style="color:#16a34a;font-weight:bold;">concluída com êxito</span>
              em&nbsp;<strong>$dataRealizacao</strong>.
            </p>

            <!-- DESTAQUE VERDE -->
            <table width="100%" cellpadding="0" cellspacing="0" border="0"
                   style="background:#f0fdf4;border-left:4px solid #1A3C34;border-radius:0 8px 8px 0;margin-bottom:24px;">
              <tr>
                <td style="padding:14px 16px;font-size:14px;color:#14532d;line-height:1.6;font-family:Arial,sans-serif;">
                  🔧&nbsp;&nbsp;Nossa equipe técnica executou todos os procedimentos previstos
                  no plano de manutenção <strong>$tipoManutencao</strong>, garantindo o desempenho
                  ideal e a vida útil prolongada do seu equipamento.
                </td>
              </tr>
            </table>

            <!-- TABELA DE DETALHES -->
            <table width="100%" cellpadding="0" cellspacing="0" border="0"
                   style="border-collapse:collapse;border-radius:8px;overflow:hidden;border:1px solid #e2e8f0;margin-bottom:24px;font-size:14px;font-family:Arial,sans-serif;">
              <tr>
                <td colspan="2" style="background:#1A3C34;padding:10px 14px;">
                  <span style="color:#ffffff;font-size:13px;font-weight:bold;letter-spacing:0.5px;">DETALHES DA MANUTENÇÃO</span>
                </td>
              </tr>
              <tr style="background:#f8fafc;">
                <td style="padding:10px 14px;font-weight:bold;color:#374151;width:160px;border-bottom:1px solid #e2e8f0;">Equipamento</td>
                <td style="padding:10px 14px;color:#1f2937;border-bottom:1px solid #e2e8f0;">$equipamento</td>
              </tr>
              <tr>
                <td style="padding:10px 14px;font-weight:bold;color:#374151;border-bottom:1px solid #e2e8f0;">Patrimônio</td>
                <td style="padding:10px 14px;color:#1f2937;border-bottom:1px solid #e2e8f0;">$patrimonio</td>
              </tr>
              <tr style="background:#f8fafc;">
                <td style="padding:10px 14px;font-weight:bold;color:#374151;border-bottom:1px solid #e2e8f0;">Sala</td>
                <td style="padding:10px 14px;color:#1f2937;border-bottom:1px solid #e2e8f0;">$sala</td>
              </tr>
              <tr>
                <td style="padding:10px 14px;font-weight:bold;color:#374151;border-bottom:1px solid #e2e8f0;">Setor</td>
                <td style="padding:10px 14px;color:#1f2937;border-bottom:1px solid #e2e8f0;">$setor</td>
              </tr>
              <tr style="background:#f8fafc;">
                <td style="padding:10px 14px;font-weight:bold;color:#374151;border-bottom:1px solid #e2e8f0;">Tipo de Manutenção</td>
                <td style="padding:10px 14px;color:#1f2937;border-bottom:1px solid #e2e8f0;">$tipoManutencao</td>
              </tr>
              <tr>
                <td style="padding:10px 14px;font-weight:bold;color:#374151;border-bottom:1px solid #e2e8f0;">Data de Realização</td>
                <td style="padding:10px 14px;color:#1f2937;border-bottom:1px solid #e2e8f0;">$dataRealizacao</td>
              </tr>
              <tr style="background:#f8fafc;">
                <td style="padding:10px 14px;font-weight:bold;color:#374151;">Status</td>
                <td style="padding:10px 14px;">
                  <span style="background:#dcfce7;color:#16a34a;font-weight:bold;font-size:12px;padding:3px 10px;border-radius:12px;">
                    ✔ CONCLUÍDA
                  </span>
                </td>
              </tr>
            </table>

            <p style="margin:0 0 8px 0;font-size:14px;color:#64748b;line-height:1.6;">
              Caso tenha alguma dúvida ou necessite de suporte adicional, nossa equipe está
              à disposição para atendê-lo.
            </p>

          </td>
        </tr>

        <!-- DIVISOR -->
        <tr><td style="padding:0 28px;"><hr style="border:none;border-top:1px solid #e8ecf0;margin:0;"></td></tr>

        <!-- ASSINATURA -->
        <tr>
          <td style="padding:20px 28px;font-family:Arial,Helvetica,sans-serif;">
            <table cellpadding="0" cellspacing="0" border="0">
              <tr>
                <td style="width:44px;vertical-align:top;">
                  <div style="width:40px;height:40px;background:#1A3C34;border-radius:50%;text-align:center;line-height:40px;">
                    <span style="color:#ffffff;font-size:18px;font-weight:bold;font-family:Arial,sans-serif;">H</span>
                  </div>
                </td>
                <td style="padding-left:12px;vertical-align:top;">
                  <span style="font-size:15px;font-weight:bold;color:#1A3C34;font-family:Arial,sans-serif;">Huagner Pires</span><br>
                  <span style="font-size:13px;color:#555555;font-family:Arial,sans-serif;">Especialista em Refrigeração</span><br>
                  <span style="font-size:12px;color:#888888;font-family:Arial,sans-serif;">hpsrefri.com.br</span>
                </td>
              </tr>
            </table>
          </td>
        </tr>

        <!-- RODAPÉ -->
        <tr>
          <td style="background:#f1f5f9;padding:14px 28px;text-align:center;font-size:12px;color:#94a3b8;font-family:Arial,Helvetica,sans-serif;border-top:1px solid #e2e8f0;">
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

  try {
    final response = await http.post(
      Uri.parse('https://api.brevo.com/v3/smtp/email'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'api-key': apiKey,
      },
      body: jsonEncode({
        'sender': {'name': senderName, 'email': senderEmail},
        'replyTo': {'name': senderName, 'email': senderEmail},
        'to': [
          {'email': toEmail}
        ],
        'subject': subject,
        'htmlContent': htmlBody,
      }),
    );
    return response.statusCode == 200 || response.statusCode == 201;
  } catch (e) {
    print('❌ Erro ao enviar e-mail: $e');
    return false;
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// WIDGET PRINCIPAL
// ══════════════════════════════════════════════════════════════════════════════

class CadastrarPreventivaWidget extends StatefulWidget {
  const CadastrarPreventivaWidget({
    super.key,
    this.width,
    this.height,
    this.tipoManutencaoList,
    this.onSalvar,
    this.patrimonio,
  });

  final double? width;
  final double? height;
  final List<String>? tipoManutencaoList;
  final Future Function()? onSalvar;
  final String? patrimonio;

  @override
  State<CadastrarPreventivaWidget> createState() =>
      _CadastrarPreventivaWidgetState();
}

class _CadastrarPreventivaWidgetState extends State<CadastrarPreventivaWidget> {
  final _formKey = GlobalKey<FormState>();
  bool _isGerandoPDF = false;
  double _progressoPDF = 0.0;
  String _statusPDF = '';

  bool _isBuscando = false;
  bool _equipamentoEncontrado = false;
  bool _equipamentoNaoEncontrado = false;
  String? _equipamentoDocId;
  String? _pendenciaDocId;

  // ── NOVO: controle de preventiva duplicada ──────────────────────────────
  String? _preventivaExistenteId;
  Map<String, dynamic>? _preventivaExistenteData;

  // Flag: bloqueia o listener do patrimônio após carregar dados para edição
  // evita que o preenchimento automático dos campos dispare nova busca/popup
  bool _ignorarProximaBusca = false;

  // Último patrimônio efetivamente buscado — evita rebuscar o mesmo valor
  String _ultimoPatrimonioBuscado = '';

  Timer? _debounce;
  final _scrollController = ScrollController();

  final _keyFoto = GlobalKey();
  final _keyPatrimonio = GlobalKey();
  final _keyMarca = GlobalKey();
  final _keyModelo = GlobalKey();
  final _keyEquipamento = GlobalKey();
  final _keySala = GlobalKey();
  final _keySetor = GlobalKey();
  final _keyResponsavel = GlobalKey();
  final _keyTensao = GlobalKey();
  final _keyTecnico = GlobalKey();
  final _keyTipoManutencao = GlobalKey();

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

  final _tensaoFocus = FocusNode();
  final _amperagemFocus = FocusNode();

  String? _tecnico;
  String? _tipoManutencao;

  int _mesSelecionado = DateTime.now().month;
  int _anoSelecionado = DateTime.now().year;

  // Data de realização da manutenção — editável pelo usuário
  DateTime _dataCadastro = DateTime.now();

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

  FFUploadedFile? _fotoFile;
  String? _fotoUrlExistente; // URL da imagem já salva (modo edição)
  final _picker = ImagePicker();

  List<String> _tecnicosFirestore = [];
  bool _carregandoTecnicos = true;

  // ── Checkboxes ─────────────────────────────────────────────────────────────
  bool _limpezaEvapInterna = false;
  bool _limpezaFiltro = false;
  bool _limpezaBactericida = false;
  bool _verControlePilhas = false;
  bool _verRuidos = false;
  bool _verMalCheiro = false;
  bool _medicaoCorrente = false;
  bool _medicaoTensaoEletrica = false;
  bool _verDreno = false;
  bool _verPressao = false;
  bool _polirCondensadora = false;
  bool _verParteEletrica = false;
  bool _verIsolamento = false;
  bool _jateamentoCondensadora = false;
  bool _jateamentoEvaporadora = false;
  bool _lavagemDreno = false;
  bool _lavagemCarcacaEvap = false;
  bool _lavagemCarcacaCond = false;
  bool _limpezaCompressor = false;
  bool _lavagemTurbinaEvap = false;
  bool _verPesBorracha = false;

  // ── Cores ──────────────────────────────────────────────────────────────────
  Color _primary(BuildContext ctx) => FlutterFlowTheme.of(ctx).primary;
  Color _error(BuildContext ctx) => FlutterFlowTheme.of(ctx).error;
  Color _bg(BuildContext ctx) => const Color(0xFF0B0F17);
  Color _card(BuildContext ctx) => const Color(0xFF131B2E);
  Color _textColor(BuildContext ctx) => Colors.white;
  Color _hintColor(BuildContext ctx) => const Color(0xFF94A3B8);
  Color _border(BuildContext ctx) =>
      FlutterFlowTheme.of(ctx).primary.withAlpha(128);
  static const Color _green = Color(0xFF388E3C);
  static const Color _orange = Color(0xFFC2410C);
  static const Color _red = Color(0xFFB91C1C);

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

    final patInicial = (widget.patrimonio ?? '').trim();
    if (patInicial.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _patrimonioCtrl.text = patInicial;
        _buscarEquipamento(patInicial);
      });
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scrollController.dispose();
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

  void _onPatrimonioChanged() {
    if (_ignorarProximaBusca) {
      _ignorarProximaBusca = false;
      return;
    }
    final valor = _patrimonioCtrl.text.trim();
    if (valor.isEmpty) {
      _debounce?.cancel();
      _ultimoPatrimonioBuscado = '';
      _limparCamposEquipamento();
      return;
    }
    if (valor == _ultimoPatrimonioBuscado) return;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 600), () {
      _buscarEquipamento(valor);
    });
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // BUSCA EQUIPAMENTO + PREVENTIVA EXISTENTE NO MÊS
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> _buscarEquipamento(String patrimonio) async {
    if (!mounted) return;
    _ultimoPatrimonioBuscado = patrimonio;
    setState(() {
      _isBuscando = true;
      _equipamentoEncontrado = false;
      _equipamentoNaoEncontrado = false;
      _pendenciaDocId = null;
      _preventivaExistenteId = null;
      _preventivaExistenteData = null;
    });

    try {
      final futures = await Future.wait([
        FirebaseFirestore.instance
            .collection('EQUIPAMENTOS_EMPRESA')
            .where('PATRIMONIO', isEqualTo: patrimonio)
            .limit(1)
            .get(),
        _buscarPendenciaId(patrimonio, _mesSelecionado, _anoSelecionado),
        _buscarPreventivaExistente(
            patrimonio, _mesSelecionado, _anoSelecionado),
      ]);

      QuerySnapshot<Map<String, dynamic>> snap =
          futures[0] as QuerySnapshot<Map<String, dynamic>>;
      _pendenciaDocId = futures[1] as String?;
      final prevExistente = futures[2] as Map<String, dynamic>?;

      if (snap.docs.isEmpty) {
        for (final campo in ['patrimonio', 'patrimônio', 'PATRIMÔNIO']) {
          final s = await FirebaseFirestore.instance
              .collection('EQUIPAMENTOS_EMPRESA')
              .where(campo, isEqualTo: patrimonio)
              .limit(1)
              .get();
          if (s.docs.isNotEmpty) {
            snap = s;
            break;
          }
        }
      }

      if (!mounted) return;

      if (snap.docs.isNotEmpty) {
        final doc = snap.docs.first;
        _equipamentoDocId = doc.id;
        _preencherCampos(doc.data());
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

      if (prevExistente != null && mounted) {
        setState(() {
          _preventivaExistenteId = prevExistente['__id__'] as String?;
          _preventivaExistenteData = prevExistente;
        });
        await Future.delayed(const Duration(milliseconds: 300));
        if (mounted) {
          _mostrarPopupPreventivaExistente(prevExistente);
        }
      }
    } catch (e) {
      print('Erro _buscarEquipamento: $e');
      if (mounted) setState(() => _isBuscando = false);
    }
  }

  Future<Map<String, dynamic>?> _buscarPreventivaExistente(
      String patrimonio, int mes, int ano) async {
    try {
      final mesSalvo = _meses[mes - 1].toUpperCase();
      final snap = await FirebaseFirestore.instance
          .collection('PREVENTIVAS')
          .where('PATRIMONIO', isEqualTo: patrimonio)
          .where('MES', isEqualTo: mesSalvo)
          .where('ANO', isEqualTo: ano)
          .limit(1)
          .get();
      if (snap.docs.isEmpty) return null;
      final data = Map<String, dynamic>.from(snap.docs.first.data());
      data['__id__'] = snap.docs.first.id;
      return data;
    } catch (_) {
      return null;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // POPUP PREVENTIVA EXISTENTE — layout moderno
  // ═══════════════════════════════════════════════════════════════════════════

  void _mostrarPopupPreventivaExistente(Map<String, dynamic> data) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final docId = data['__id__'] as String? ?? '';

    String formatTs(dynamic raw) {
      if (raw == null) return '—';
      if (raw is Timestamp) {
        final d = raw.toDate();
        return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
      }
      return raw.toString();
    }

    bool getBool(String key) => data[key] == true;
    String getStr(String key) => (data[key] ?? '').toString().trim();

    final checksEvap = [
      ('Limpeza Evaporadora Interna', getBool('LIMPEZAEVAPORADORAINTERNA')),
      ('Limpeza do Filtro', getBool('LIMPEZAFILTRO')),
      ('Limpeza com Bactericida', getBool('LIMPEZABACTERICIDA')),
      ('Verificação Controle e Pilhas', getBool('VERIFICAODOCONTROLPILHAS')),
      ('Verificar Ruídos', getBool('VERIFICAODERUIDOS')),
      ('Verificar Mal Cheiro', getBool('VERIFICAOMALCHEIRO')),
      ('Medição Corrente Elétrica', getBool('MEDICAOCORRENTE')),
      ('Medição Tensão Elétrica', getBool('MEDICAOTENSAOELETRICA')),
    ];
    final checksCond = [
      ('Verificar Dreno', getBool('VERIFICAODODRENO')),
      ('Verificar Pressão (PSI)', getBool('VERIFICAODAPRESSAO')),
      ('Polir Condensadora', getBool('POLIRCONDENSADORA')),
      ('Verificar Parte Elétrica', getBool('VERIFICAODAPARTEELETRICA')),
      ('Verificar Isolamento Térmico', getBool('VERIFICAODOISOLAMENTOTRMICO')),
    ];
    final checksAdic = [
      ('Jateamento Condensadora', getBool('JATEAMENTOCONDENSADORA')),
      ('Jateamento Evaporadora', getBool('JATEAMENTOEVAPORADORA')),
      ('Lavagem do Dreno', getBool('LAVAGEMDRENO')),
      ('Lavagem Carcaça Evaporadora', getBool('LAVAGEMCARCACAEVAP')),
      ('Lavagem Carcaça Condensadora', getBool('LAVAGEMCARCACACOND')),
      ('Limpeza/Lubrificação Compressor', getBool('LIMPEZACOMPRESSOR')),
      ('Lavagem Turbina Evaporadora', getBool('LAVAGEMTURBINAEVAP')),
      ('Verificar Pés de Borracha', getBool('VERIFICAODOSPEDEBORRACHA')),
    ];

    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withAlpha(160),
      builder: (ctx) {
        final bg = isDark ? const Color(0xFF0F1923) : const Color(0xFFF0F4F8);
        final cardBg = isDark ? const Color(0xFF1A2535) : Colors.white;
        final txt = isDark ? Colors.white : const Color(0xFF0D1B2A);
        final sub = isDark ? Colors.white54 : const Color(0xFF64748B);
        const accent = Color(0xFF0369A1);
        const accentDark = Color(0xFF0369A1);

        Widget buildSection(
            String title, IconData icon, List<(String, bool)> items) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Row(children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: accent.withAlpha(30),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: accent, size: 14),
                ),
                const SizedBox(width: 8),
                Text(title,
                    style: TextStyle(
                        color: txt,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8)),
              ]),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF0D1520)
                      : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: isDark
                          ? Colors.white.withAlpha(15)
                          : const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: items.asMap().entries.map((e) {
                    final idx = e.key;
                    final label = e.value.$1;
                    final ok = e.value.$2;
                    return Container(
                      decoration: BoxDecoration(
                        border: idx < items.length - 1
                            ? Border(
                                bottom: BorderSide(
                                    color: isDark
                                        ? Colors.white.withAlpha(10)
                                        : const Color(0xFFE2E8F0),
                                    width: 0.5))
                            : null,
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      child: Row(children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color:
                                ok ? _green.withAlpha(30) : Colors.transparent,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: ok
                                  ? _green
                                  : (isDark
                                      ? Colors.white24
                                      : const Color(0xFFCBD5E1)),
                              width: 1.5,
                            ),
                          ),
                          child: ok
                              ? const Icon(Icons.check_rounded,
                                  color: _green, size: 13)
                              : null,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(label,
                              style: TextStyle(
                                  color: ok ? txt : sub,
                                  fontSize: 12,
                                  fontWeight: ok
                                      ? FontWeight.w600
                                      : FontWeight.normal)),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: ok
                                ? _green.withAlpha(25)
                                : (isDark
                                    ? Colors.white.withAlpha(8)
                                    : const Color(0xFFF1F5F9)),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            ok ? 'OK' : '—',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: ok ? _green : sub,
                            ),
                          ),
                        ),
                      ]),
                    );
                  }).toList(),
                ),
              ),
            ],
          );
        }

        Widget buildInfoChip(String label, String value) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0D1520) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: isDark
                      ? Colors.white.withAlpha(15)
                      : const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        color: sub,
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5)),
                const SizedBox(height: 2),
                Text(value.isEmpty ? '—' : value,
                    style: TextStyle(
                        color: txt, fontSize: 12, fontWeight: FontWeight.w600)),
              ],
            ),
          );
        }

        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
          child: Container(
            width: double.infinity,
            constraints: BoxConstraints(
                maxHeight: MediaQuery.of(ctx).size.height * 0.88),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(80),
                  blurRadius: 32,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 20, 16, 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [accentDark, accent.withAlpha(180)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Row(children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(30),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.find_in_page_rounded,
                          color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('PREVENTIVA JÁ CADASTRADA',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5)),
                          Text(
                            '${getStr('MES')} / ${getStr('ANO')} — Pat. ${getStr('PATRIMONIO')}',
                            style: TextStyle(
                                color: Colors.white.withAlpha(200),
                                fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      icon:
                          const Icon(Icons.close_rounded, color: Colors.white),
                    ),
                  ]),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: _green.withAlpha(25),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: _green.withAlpha(80)),
                            ),
                            child:
                                Row(mainAxisSize: MainAxisSize.min, children: [
                              const Icon(Icons.check_circle_rounded,
                                  color: _green, size: 13),
                              const SizedBox(width: 5),
                              Text('CONCLUÍDA',
                                  style: TextStyle(
                                      color: _green,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.5)),
                            ]),
                          ),
                          const SizedBox(width: 8),
                          Text(
                              'Cadastrada em ${formatTs(data['datacadastro'])}',
                              style: TextStyle(color: sub, fontSize: 11)),
                        ]),
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: isDark
                                    ? Colors.white.withAlpha(15)
                                    : const Color(0xFFE2E8F0)),
                          ),
                          child: Column(children: [
                            Row(children: [
                              Expanded(
                                  child: buildInfoChip(
                                      'EQUIPAMENTO', getStr('NOME'))),
                              const SizedBox(width: 8),
                              Expanded(
                                  child: buildInfoChip(
                                      'PATRIMÔNIO', getStr('PATRIMONIO'))),
                            ]),
                            const SizedBox(height: 8),
                            Row(children: [
                              Expanded(
                                  child:
                                      buildInfoChip('MARCA', getStr('MARCA'))),
                              const SizedBox(width: 8),
                              Expanded(
                                  child: buildInfoChip(
                                      'MODELO', getStr('MODELO'))),
                            ]),
                            const SizedBox(height: 8),
                            Row(children: [
                              Expanded(
                                  child: buildInfoChip('SALA', getStr('SALA'))),
                              const SizedBox(width: 8),
                              Expanded(
                                  child:
                                      buildInfoChip('SETOR', getStr('SETOR'))),
                            ]),
                            const SizedBox(height: 8),
                            Row(children: [
                              Expanded(
                                  child: buildInfoChip(
                                      'TÉCNICO', getStr('TECNICORESPONSAVEL'))),
                              const SizedBox(width: 8),
                              Expanded(
                                  child: buildInfoChip('TIPO MANUTENÇÃO',
                                      getStr('TIPOMANUTENCAO'))),
                            ]),
                            const SizedBox(height: 8),
                            Row(children: [
                              Expanded(
                                  child: buildInfoChip(
                                      'TENSÃO', getStr('TENSAO'))),
                              const SizedBox(width: 8),
                              Expanded(
                                  child: buildInfoChip(
                                      'AMPERAGEM', getStr('AMPERAGEM'))),
                            ]),
                          ]),
                        ),
                        Builder(builder: (_) {
                          final imgUrl = getStr('IMAGEM');
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 16),
                              Row(children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: accent.withAlpha(30),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.photo_camera_rounded,
                                      color: accent, size: 14),
                                ),
                                const SizedBox(width: 8),
                                Text('FOTO DA MANUTENÇÃO',
                                    style: TextStyle(
                                        color: txt,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.8)),
                              ]),
                              const SizedBox(height: 10),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: imgUrl.isNotEmpty
                                    ? Image.network(
                                        imgUrl,
                                        width: double.infinity,
                                        height: 200,
                                        fit: BoxFit.cover,
                                        loadingBuilder: (ctx, child, progress) {
                                          if (progress == null) return child;
                                          return Container(
                                            width: double.infinity,
                                            height: 200,
                                            decoration: BoxDecoration(
                                              color: isDark
                                                  ? const Color(0xFF0D1520)
                                                  : const Color(0xFFF1F5F9),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  CircularProgressIndicator(
                                                    value: progress
                                                                .expectedTotalBytes !=
                                                            null
                                                        ? progress
                                                                .cumulativeBytesLoaded /
                                                            progress
                                                                .expectedTotalBytes!
                                                        : null,
                                                    color: accent,
                                                    strokeWidth: 2,
                                                  ),
                                                  const SizedBox(height: 10),
                                                  Text('Carregando imagem...',
                                                      style: TextStyle(
                                                          color: sub,
                                                          fontSize: 11)),
                                                ]),
                                          );
                                        },
                                        errorBuilder: (ctx, _, __) => Container(
                                          width: double.infinity,
                                          height: 120,
                                          decoration: BoxDecoration(
                                            color: isDark
                                                ? const Color(0xFF0D1520)
                                                : const Color(0xFFF1F5F9),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            border: Border.all(
                                                color: isDark
                                                    ? Colors.white.withAlpha(15)
                                                    : const Color(0xFFE2E8F0)),
                                          ),
                                          child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                    Icons.broken_image_outlined,
                                                    color: sub,
                                                    size: 32),
                                                const SizedBox(height: 6),
                                                Text('Erro ao carregar imagem',
                                                    style: TextStyle(
                                                        color: sub,
                                                        fontSize: 11)),
                                              ]),
                                        ),
                                      )
                                    : Container(
                                        width: double.infinity,
                                        height: 100,
                                        decoration: BoxDecoration(
                                          color: isDark
                                              ? const Color(0xFF0D1520)
                                              : const Color(0xFFF1F5F9),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                              color: isDark
                                                  ? Colors.white.withAlpha(15)
                                                  : const Color(0xFFE2E8F0)),
                                        ),
                                        child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                  Icons
                                                      .image_not_supported_outlined,
                                                  color: sub,
                                                  size: 28),
                                              const SizedBox(height: 6),
                                              Text('Sem foto cadastrada',
                                                  style: TextStyle(
                                                      color: sub,
                                                      fontSize: 11)),
                                            ]),
                                      ),
                              ),
                            ],
                          );
                        }),
                        buildSection(
                            'EVAPORADORA', Icons.air_rounded, checksEvap),
                        buildSection('CONDENSADORA',
                            Icons.device_thermostat_rounded, checksCond),
                        buildSection('SERVIÇOS ADICIONAIS',
                            Icons.build_circle_rounded, checksAdic),
                        if (getStr('OBSERVACAO').isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF0D1520)
                                  : const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: isDark
                                      ? Colors.white.withAlpha(15)
                                      : const Color(0xFFE2E8F0)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('OBSERVAÇÕES',
                                    style: TextStyle(
                                        color: sub,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.5)),
                                const SizedBox(height: 6),
                                Text(getStr('OBSERVACAO'),
                                    style: TextStyle(
                                        color: txt, fontSize: 13, height: 1.5)),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(20)),
                    border: Border(
                        top: BorderSide(
                            color: isDark
                                ? Colors.white.withAlpha(15)
                                : const Color(0xFFE2E8F0))),
                  ),
                  child: Column(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: _orange.withAlpha(20),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: _orange.withAlpha(80)),
                      ),
                      child: Row(children: [
                        const Icon(Icons.warning_amber_rounded,
                            color: _orange, size: 15),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Já existe uma preventiva para este equipamento no mês selecionado.',
                            style: TextStyle(
                                color: _orange, fontSize: 11, height: 1.4),
                          ),
                        ),
                      ]),
                    ),
                    const SizedBox(height: 12),
                    Row(children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            Navigator.of(ctx).pop();
                            await _confirmarExclusaoPreventiva(docId);
                          },
                          icon: const Icon(Icons.delete_outline_rounded,
                              size: 16, color: _red),
                          label: const Text('EXCLUIR',
                              style: TextStyle(
                                  color: _red,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: _red),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(ctx).pop();
                            _carregarDadosParaEdicao(data, docId);
                          },
                          icon: const Icon(Icons.edit_rounded,
                              size: 16, color: Colors.black),
                          label: const Text('EDITAR',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accent,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ]),
                  ]),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Confirmação de exclusão ────────────────────────────────────────────────
  Future<void> _confirmarExclusaoPreventiva(String docId) async {
    final confirmar = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withAlpha(160),
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        final cardBg = isDark ? const Color(0xFF1A2535) : Colors.white;
        final txt = isDark ? Colors.white : const Color(0xFF0D1B2A);
        final sub = isDark ? Colors.white54 : const Color(0xFF64748B);
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: Colors.black.withAlpha(80), blurRadius: 24)
              ],
            ),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _red.withAlpha(20),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.delete_forever_rounded,
                    color: _red, size: 36),
              ),
              const SizedBox(height: 16),
              Text('Excluir Preventiva?',
                  style: TextStyle(
                      color: txt, fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Text(
                'Esta ação não pode ser desfeita. O registro será removido permanentemente.',
                textAlign: TextAlign.center,
                style: TextStyle(color: sub, fontSize: 13, height: 1.5),
              ),
              const SizedBox(height: 24),
              Row(children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(ctx).pop(false),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                          color: isDark
                              ? Colors.white24
                              : const Color(0xFFCBD5E1)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text('CANCELAR',
                        style:
                            TextStyle(color: sub, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(ctx).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _red,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                    child: const Text('EXCLUIR',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w700)),
                  ),
                ),
              ]),
            ]),
          ),
        );
      },
    );

    if (confirmar == true && docId.isNotEmpty) {
      try {
        await FirebaseFirestore.instance
            .collection('PREVENTIVAS')
            .doc(docId)
            .delete();
        if (mounted) {
          setState(() {
            _preventivaExistenteId = null;
            _preventivaExistenteData = null;
          });
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('✅ Preventiva excluída com sucesso!'),
            backgroundColor: _green,
          ));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('❌ Erro ao excluir: $e'),
            backgroundColor: _red,
          ));
        }
      }
    }
  }

  // ── Carregar dados para edição ─────────────────────────────────────────────
  void _carregarDadosParaEdicao(Map<String, dynamic> data, String docId) {
    String getStr(String key) => (data[key] ?? '').toString().trim();
    bool getBool(String key) => data[key] == true;

    _debounce?.cancel();
    _ignorarProximaBusca = true;

    setState(() {
      _preventivaExistenteId = docId;
      _equipamentoCtrl.text = getStr('NOME');
      _marcaCtrl.text = getStr('MARCA');
      _modeloCtrl.text = getStr('MODELO');
      _tipoCtrl.text = getStr('TIPO');
      _btusCtrl.text = getStr('BTUS');
      _fluidoCtrl.text = getStr('FLUIDO');
      _salaCtrl.text = getStr('SALA');
      _setorCtrl.text = getStr('SETOR');
      _tensaoCtrl.text = getStr('TENSAO');
      _amperagemCtrl.text = getStr('AMPERAGEM');
      _responsavelCtrl.text = getStr('RESPONSAVEL');
      _emailCtrl.text = getStr('EMAIL');
      _obsCtrl.text = getStr('OBSERVACAO');
      _tecnico = getStr('TECNICORESPONSAVEL').isEmpty
          ? null
          : getStr('TECNICORESPONSAVEL');
      _tipoManutencao =
          getStr('TIPOMANUTENCAO').isEmpty ? null : getStr('TIPOMANUTENCAO');

      final imgUrl = getStr('IMAGEM');
      _fotoFile = null;
      _fotoUrlExistente = imgUrl.isNotEmpty ? imgUrl : null;

      final rawData = data['datacadastro'];
      if (rawData is Timestamp) {
        _dataCadastro = rawData.toDate().toLocal();
      } else {
        _dataCadastro = DateTime.now();
      }

      _limpezaEvapInterna = getBool('LIMPEZAEVAPORADORAINTERNA');
      _limpezaFiltro = getBool('LIMPEZAFILTRO');
      _limpezaBactericida = getBool('LIMPEZABACTERICIDA');
      _verControlePilhas = getBool('VERIFICAODOCONTROLPILHAS');
      _verRuidos = getBool('VERIFICAODERUIDOS');
      _verMalCheiro = getBool('VERIFICAOMALCHEIRO');
      _medicaoCorrente = getBool('MEDICAOCORRENTE');
      _medicaoTensaoEletrica = getBool('MEDICAOTENSAOELETRICA');
      _verDreno = getBool('VERIFICAODODRENO');
      _verPressao = getBool('VERIFICAODAPRESSAO');
      _polirCondensadora = getBool('POLIRCONDENSADORA');
      _verParteEletrica = getBool('VERIFICAODAPARTEELETRICA');
      _verIsolamento = getBool('VERIFICAODOISOLAMENTOTRMICO');
      _jateamentoCondensadora = getBool('JATEAMENTOCONDENSADORA');
      _jateamentoEvaporadora = getBool('JATEAMENTOEVAPORADORA');
      _lavagemDreno = getBool('LAVAGEMDRENO');
      _lavagemCarcacaEvap = getBool('LAVAGEMCARCACAEVAP');
      _lavagemCarcacaCond = getBool('LAVAGEMCARCACACOND');
      _limpezaCompressor = getBool('LIMPEZACOMPRESSOR');
      _lavagemTurbinaEvap = getBool('LAVAGEMTURBINAEVAP');
      _verPesBorracha = getBool('VERIFICAODOSPEDEBORRACHA');
    });

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content:
          Text('✏️ Dados carregados para edição. Faça as alterações e salve.'),
      backgroundColor: Color(0xFF0369A1),
      duration: Duration(seconds: 4),
    ));

    _scrollController.animateTo(0,
        duration: const Duration(milliseconds: 400), curve: Curves.easeOut);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // PREENCHER CAMPOS DO EQUIPAMENTO
  // ═══════════════════════════════════════════════════════════════════════════

  void _preencherCampos(Map<String, dynamic> data) {
    debugPrint('🔍 Chaves Firestore: ${data.keys.toList()}');

    String get(List<String> keys) {
      for (final k in keys) {
        if (data.containsKey(k) && data[k] != null) {
          final v = data[k].toString().trim();
          if (v.isNotEmpty) return v;
        }
      }
      return '';
    }

    setState(() {
      final nomeEquip = get([
        'NOME',
        'nome',
        'EQUIPAMENTO',
        'equipamento',
        'APARELHO',
        'aparelho',
        'DESCRICAO',
        'descricao',
        'DESCRIÇÃO',
        'descrição',
      ]);
      _equipamentoCtrl.text = nomeEquip;

      _marcaCtrl.text = get(['MARCA', 'marca', 'FABRICANTE', 'fabricante']);
      _modeloCtrl.text = get(['MODELO', 'modelo']);
      _salaCtrl.text = get(['SALA', 'sala']);
      _setorCtrl.text = get([
        'SETOR',
        'setor',
        'LOCALIZACAO',
        'localizacao',
        'LOCALIZAÇÃO',
        'localização',
        'LOCAL',
        'local',
        'PREDIO',
        'predio'
      ]);
      _responsavelCtrl.text =
          get(['RESPONSAVEL', 'responsavel', 'RESPONSÁVEL', 'responsável']);
      _emailCtrl.text = get(['EMAIL', 'email', 'Email', 'E_MAIL', 'e_mail']);
      _btusCtrl.text = get([
        'BTUS',
        'btus',
        'POTENCIA',
        'potencia',
        'POTÊNCIA',
        'potência',
        'BTU',
        'btu'
      ]);
      _fluidoCtrl.text = get(
          ['FLUIDO', 'fluido', 'FLUÍDO', 'fluído', 'GAS', 'gas', 'GÁS', 'gás']);
      _amperagemCtrl.text =
          get(['AMPERAGEM', 'amperagem', 'CORRENTE', 'corrente']);

      final tensaoRaw =
          get(['TENSAO', 'tensao', 'TENSÃO', 'tensão', 'VOLTAGEM', 'voltagem']);
      if (tensaoRaw.isNotEmpty) {
        final numericOnly = tensaoRaw.replaceAll(RegExp(r'[^0-9]'), '');
        _tensaoCtrl.text =
            numericOnly.isNotEmpty ? '${numericOnly}V' : tensaoRaw;
      }

      final tipoRaw = get(['TIPO', 'tipo', 'TPO', 'tpo']);
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
      _pendenciaDocId = null;
      _preventivaExistenteId = null;
      _preventivaExistenteData = null;
      _ultimoPatrimonioBuscado = '';
      _fotoFile = null;
      _fotoUrlExistente = null;
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
      _amperagemCtrl,
      _responsavelCtrl,
      _emailCtrl,
    ]) {
      c.clear();
    }
  }

  void _aplicarChecksPorTipo(String? tipo) {
    if (tipo == null) return;
    final t = tipo.toUpperCase();
    final isM = t.contains('MENSAL') ||
        t.contains('TRIMESTRAL') ||
        t.contains('SEMESTRAL') ||
        t.contains('ANUAL');
    final isT = t.contains('TRIMESTRAL') ||
        t.contains('SEMESTRAL') ||
        t.contains('ANUAL');
    final isS = t.contains('SEMESTRAL') || t.contains('ANUAL');
    final isA = t.contains('ANUAL');
    setState(() {
      _limpezaEvapInterna = isM;
      _limpezaFiltro = isM;
      _limpezaBactericida = isM;
      _verControlePilhas = isM;
      _verRuidos = isM;
      _verMalCheiro = isM;
      _medicaoCorrente = isM;
      _medicaoTensaoEletrica = isM;
      _verDreno = isM;
      _verPressao = isM;
      _verParteEletrica = isM;
      _verIsolamento = isM;
      _polirCondensadora = isT;
      _lavagemTurbinaEvap = isS;
      _jateamentoCondensadora = isS;
      _jateamentoEvaporadora = isS;
      _lavagemDreno = isS;
      _lavagemCarcacaEvap = isA;
      _lavagemCarcacaCond = isA;
      _limpezaCompressor = isA;
      _verPesBorracha = isA;
    });
  }

  void _onTensaoFocus() {
    if (_tensaoFocus.hasFocus) {
      final raw = _tensaoCtrl.text.replaceAll(RegExp(r'[^0-9]'), '');
      _tensaoCtrl.value = TextEditingValue(
          text: raw, selection: TextSelection.collapsed(offset: raw.length));
    } else {
      final raw = _tensaoCtrl.text.replaceAll(RegExp(r'[^0-9]'), '');
      if (raw.isNotEmpty)
        _tensaoCtrl.value = TextEditingValue(
            text: '${raw}V',
            selection: TextSelection.collapsed(offset: raw.length + 1));
    }
  }

  void _onAmperagemFocus() {
    if (_amperagemFocus.hasFocus) {
      final raw = _amperagemCtrl.text.replaceAll(RegExp(r'[^0-9.,]'), '');
      _amperagemCtrl.value = TextEditingValue(
          text: raw, selection: TextSelection.collapsed(offset: raw.length));
    } else {
      final raw = _amperagemCtrl.text.replaceAll(RegExp(r'[^0-9.,]'), '');
      if (raw.isNotEmpty)
        _amperagemCtrl.value = TextEditingValue(
            text: '${raw}A',
            selection: TextSelection.collapsed(offset: raw.length + 1));
    }
  }

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

  static const String _oneSignalAppId = '7b01186f-cf76-4b5d-8354-87d83737d40c';
  static const String _oneSignalApiKey =
      'ZTdlNjIwZWItMjEyMC00M2RhLWJlZmYtMzc2NTBmNzNmMDdj';

  Future<void> _enviarNotificacao({
    required String email,
    required String sala,
    required String setor,
    required String patrimonio,
  }) async {
    if (email.isEmpty) return;
    try {
      await http.post(
        Uri.parse('https://onesignal.com/api/v1/notifications'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Basic $_oneSignalApiKey',
        },
        body: jsonEncode({
          'app_id': _oneSignalAppId,
          'filters': [
            {'field': 'tag', 'key': 'Email', 'relation': '=', 'value': email},
          ],
          'headings': {'en': 'PREVENTIVA REALIZADA'},
          'contents': {
            'en':
                'Manutenção Preventiva realizada na Sala: $sala, Setor: $setor, Patrimônio: $patrimonio'
          },
          'android_channel_id': '577bba44-d1bf-4ac9-9d11-20d89e09a61a',
          'priority': 10,
        }),
      );
    } catch (_) {}
  }

  Future<void> _criarNotificacaoFirebase({
    required String email,
    required String patrimonio,
    required String equipamento,
    required String sala,
    required String setor,
    required String mesSalvo,
    required int anoSalvo,
  }) async {
    if (email.isEmpty) return;
    try {
      await FirebaseFirestore.instance.collection('NOTIFICACAO').add({
        'email': email,
        'titulo': '🔧 Preventiva Realizada',
        'mensagem':
            'Manutenção preventiva realizada no equipamento $equipamento — Sala: $sala, Setor: $setor, Patrimônio: $patrimonio.',
        'tipo': 'preventiva',
        'visto': false,
        'data': Timestamp.now(),
        'mes': mesSalvo,
        'ano': anoSalvo,
        'status': 'concluida',
        'os': '',
      });
    } catch (e) {
      debugPrint('Erro ao criar notificação Firebase: $e');
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // FOTO
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> _pickFoto() async {
    final source = await _mostrarDialogoOrigem();
    if (source == null) return;
    final picked = await _picker.pickImage(
        source: source, imageQuality: 90, maxWidth: 1920, maxHeight: 1920);
    if (picked == null) return;

    // ── Pergunta se quer recortar ou usar a imagem original ──
    if (!mounted) return;
    final desejaRecortar = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withAlpha(160),
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        final cardBg = isDark ? const Color(0xFF1A2535) : Colors.white;
        final txt = isDark ? Colors.white : const Color(0xFF0D1B2A);
        final sub = isDark ? Colors.white54 : const Color(0xFF64748B);
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: Colors.black.withAlpha(80), blurRadius: 24),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Ícone
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: _primary(context).withAlpha(25),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.crop_rounded,
                      color: _primary(context), size: 32),
                ),
                const SizedBox(height: 16),
                Text(
                  'Usar imagem como?',
                  style: TextStyle(
                      color: txt, fontSize: 17, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Text(
                  'Deseja recortar a foto antes de usar\nou prefere usar a imagem original?',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: sub, fontSize: 13, height: 1.5),
                ),
                const SizedBox(height: 24),
                // Botão RECORTAR
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.of(ctx).pop(true),
                    icon: const Icon(Icons.crop_rounded,
                        size: 18, color: Colors.black),
                    label: const Text(
                      'RECORTAR FOTO',
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w700,
                          fontSize: 14),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primary(context),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Botão USAR ORIGINAL
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.of(ctx).pop(false),
                    icon: Icon(Icons.check_circle_outline_rounded,
                        size: 18, color: _primary(context)),
                    label: Text(
                      'USAR ORIGINAL',
                      style: TextStyle(
                          color: _primary(context),
                          fontWeight: FontWeight.w700,
                          fontSize: 14),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: _primary(context)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Botão CANCELAR
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(null),
                  child: Text(
                    'Cancelar',
                    style: TextStyle(color: sub, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    // null = cancelou
    if (desejaRecortar == null) return;

    try {
      Uint8List finalBytes;

      if (desejaRecortar) {
        // ── Fluxo com recorte ──
        final croppedFile = await ImageCropper().cropImage(
          sourcePath: picked.path,
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle: 'Recortar Foto',
              toolbarColor: _primary(context),
              toolbarWidgetColor: Colors.white,
              activeControlsWidgetColor: _primary(context),
              backgroundColor: Colors.black,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: false,
              hideBottomControls: false,
              showCropGrid: true,
              aspectRatioPresets: [
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio16x9,
              ],
            ),
            IOSUiSettings(
              title: 'Recortar Foto',
              cancelButtonTitle: 'Cancelar',
              doneButtonTitle: 'Confirmar',
              aspectRatioPresets: [
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio16x9,
              ],
            ),
          ],
        );
        if (croppedFile == null) return;
        final bytes = await croppedFile.readAsBytes();
        finalBytes = bytes;
        try {
          final decoded = img.decodeImage(bytes);
          if (decoded != null)
            finalBytes =
                Uint8List.fromList(img.encodeJpg(decoded, quality: 85));
        } catch (_) {}
      } else {
        // ── Fluxo sem recorte — apenas comprime ──
        final bytes = await picked.readAsBytes();
        finalBytes = bytes;
        try {
          final decoded = img.decodeImage(bytes);
          if (decoded != null)
            finalBytes =
                Uint8List.fromList(img.encodeJpg(decoded, quality: 85));
        } catch (_) {}
      }

      if (!mounted) return;
      setState(() =>
          _fotoFile = FFUploadedFile(name: picked.name, bytes: finalBytes));
    } catch (e) {
      print('Erro ao processar imagem: $e');
    }
  }

  Future<ImageSource?> _mostrarDialogoOrigem() => showDialog<ImageSource>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: _card(context),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Selecionar foto',
              style: TextStyle(
                  color: _textColor(context),
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            ListTile(
                leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: _primary(context).withAlpha(20),
                        borderRadius: BorderRadius.circular(8)),
                    child: Icon(Icons.camera_alt_rounded,
                        color: _primary(context))),
                title: Text('Tirar foto',
                    style: TextStyle(color: _textColor(context), fontSize: 14)),
                subtitle: Text('Usar a câmera agora',
                    style: TextStyle(color: _hintColor(context), fontSize: 12)),
                onTap: () => Navigator.of(ctx).pop(ImageSource.camera)),
            ListTile(
                leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: _primary(context).withAlpha(20),
                        borderRadius: BorderRadius.circular(8)),
                    child: Icon(Icons.photo_library_rounded,
                        color: _primary(context))),
                title: Text('Galeria',
                    style: TextStyle(color: _textColor(context), fontSize: 14)),
                subtitle: Text('Escolher da galeria',
                    style: TextStyle(color: _hintColor(context), fontSize: 12)),
                onTap: () => Navigator.of(ctx).pop(ImageSource.gallery)),
          ]),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(ctx).pop(null),
                child: Text('CANCELAR',
                    style: TextStyle(color: _hintColor(context)))),
          ],
        ),
      );

  Future<String?> _uploadFoto() async {
    if (_fotoFile == null) return null;
    try {
      Uint8List bytes = _fotoFile!.bytes!;
      try {
        final decoded = img.decodeImage(bytes);
        if (decoded != null)
          bytes = Uint8List.fromList(img.encodeJpg(decoded, quality: 85));
      } catch (_) {}
      final mes = _meses[_mesSelecionado - 1].toUpperCase();
      final ano = _anoSelecionado.toString();
      final patrimonio = _patrimonioCtrl.text.trim();
      final nome = '$patrimonio-$mes-$ano';
      final base64Image = base64Encode(bytes);
      const apiKey = '69b75a9be0857deaa943296636aca90a';
      final response = await http.post(
        Uri.parse('https://api.imgbb.com/1/upload?key=$apiKey&name=$nome'),
        body: {'image': base64Image},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data']['url'] as String?;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<void> _scrollToKey(GlobalKey key) async {
    final ctx = key.currentContext;
    if (ctx == null) return;
    await Scrollable.ensureVisible(ctx,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOut,
        alignment: 0.12);
  }

  Future<bool> _mostrarDialogoConfirmacao(
      List<({String label, GlobalKey key, bool opcional})> itens) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: _card(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        contentPadding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
        actionsPadding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        title: Row(children: [
          Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                  color: _orange.withAlpha(38),
                  borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.warning_amber_rounded,
                  color: _orange, size: 22)),
          const SizedBox(width: 10),
          Expanded(
              child: Text('Campos incompletos',
                  style: TextStyle(
                      color: _textColor(context),
                      fontSize: 16,
                      fontWeight: FontWeight.bold))),
        ]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            Text('Os itens abaixo estão vazios ou não preenchidos:',
                style: TextStyle(color: _hintColor(context), fontSize: 13)),
            const SizedBox(height: 12),
            ...itens.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Icon(
                              item.opcional
                                  ? Icons.info_outline
                                  : Icons.radio_button_unchecked,
                              size: 14,
                              color: item.opcional
                                  ? _hintColor(context)
                                  : _error(context))),
                      const SizedBox(width: 8),
                      Expanded(
                          child: RichText(
                              text: TextSpan(children: [
                        TextSpan(
                            text: item.label,
                            style: TextStyle(
                                color: item.opcional
                                    ? _hintColor(context)
                                    : _textColor(context),
                                fontSize: 13,
                                fontWeight: item.opcional
                                    ? FontWeight.normal
                                    : FontWeight.bold)),
                        if (item.opcional)
                          TextSpan(
                              text: '  (opcional)',
                              style: TextStyle(
                                  color: _hintColor(context),
                                  fontSize: 11,
                                  fontStyle: FontStyle.italic)),
                      ]))),
                    ]))),
            const SizedBox(height: 8),
            Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                    color: _primary(context).withAlpha(20),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _primary(context).withAlpha(64))),
                child: Text('Deseja prosseguir mesmo assim?',
                    style: TextStyle(
                        color: _primary(context),
                        fontSize: 13,
                        fontWeight: FontWeight.w500))),
            const SizedBox(height: 4),
          ],
        ),
        actions: [
          OutlinedButton.icon(
              onPressed: () => Navigator.of(ctx).pop(false),
              icon:
                  Icon(Icons.edit_outlined, size: 16, color: _primary(context)),
              label: Text('CORRIGIR',
                  style: TextStyle(
                      color: _primary(context), fontWeight: FontWeight.bold)),
              style: OutlinedButton.styleFrom(
                  side: BorderSide(color: _primary(context)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)))),
          ElevatedButton.icon(
              onPressed: () => Navigator.of(ctx).pop(true),
              icon: const Icon(Icons.save_alt_rounded,
                  size: 16, color: Colors.black),
              label: const Text('PROSSEGUIR',
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                  backgroundColor: _primary(context),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)))),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _mostrarDialogoEmailPendencia({
    required String idPendencia,
    required String patrimonio,
    required String dataRealizacao,
  }) async {
    final emailEquip = _emailCtrl.text.trim();
    String emailPrincipal = emailEquip;
    List<String> emailsAdicionais = [];
    List<String> emailsSelecionados = [];

    if (emailEquip.isNotEmpty) {
      try {
        final snap = await FirebaseFirestore.instance
            .collection('USUARIOS')
            .where('email', isEqualTo: emailEquip)
            .limit(1)
            .get();
        if (snap.docs.isNotEmpty) {
          final d = snap.docs.first.data();
          final field = d['emailteste'];
          if (field is List) {
            for (final e in field) {
              final s = e?.toString().trim() ?? '';
              if (s.isNotEmpty) emailsAdicionais.add(s);
            }
          } else if (field is String && field.trim().isNotEmpty) {
            emailsAdicionais.add(field.trim());
          }
        }
      } catch (_) {}
    }

    if (emailPrincipal.isNotEmpty) emailsSelecionados = [emailPrincipal];

    final equipNome = _equipamentoCtrl.text.trim();
    final sala = _salaCtrl.text.trim();
    const verde = Color(0xFF1A3C34);

    final bool enviou = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => StatefulBuilder(
            builder: (ctx, setStateDialog) {
              final isDark = Theme.of(ctx).brightness == Brightness.dark;
              final cardColor = isDark ? const Color(0xFF1E2530) : Colors.white;
              final textColor = isDark ? Colors.white : Colors.black87;
              final hintColor = isDark ? Colors.white54 : Colors.black54;
              final borderColor = isDark ? Colors.white12 : Colors.black12;

              return AlertDialog(
                backgroundColor: cardColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                contentPadding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                actionsPadding: const EdgeInsets.fromLTRB(12, 10, 12, 14),
                title: Row(children: [
                  Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: verde.withAlpha(25),
                          borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.mark_email_read_rounded,
                          color: verde, size: 22)),
                  const SizedBox(width: 10),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text('Notificar Cliente',
                            style: TextStyle(
                                color: textColor,
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                        Text('pendência será encerrada',
                            style: TextStyle(color: hintColor, fontSize: 11)),
                      ])),
                ]),
                content: SingleChildScrollView(
                  child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                                color: verde.withAlpha(18),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: verde.withAlpha(51))),
                            child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.info_outline,
                                      color: verde, size: 16),
                                  const SizedBox(width: 8),
                                  Expanded(
                                      child: Text(
                                          'Uma pendência de ${_meses[_mesSelecionado - 1]}/$_anoSelecionado foi encontrada. Deseja notificar o cliente?',
                                          style: TextStyle(
                                              color: textColor,
                                              fontSize: 12.5,
                                              height: 1.5))),
                                ])),
                        const SizedBox(height: 14),
                        if (emailPrincipal.isEmpty)
                          Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  color: _orange.withAlpha(18),
                                  borderRadius: BorderRadius.circular(8),
                                  border:
                                      Border.all(color: _orange.withAlpha(76))),
                              child: Row(children: [
                                const Icon(Icons.warning_amber_rounded,
                                    color: _orange, size: 16),
                                const SizedBox(width: 8),
                                Expanded(
                                    child: Text('Sem e-mail cadastrado.',
                                        style: TextStyle(
                                            color: _orange, fontSize: 12))),
                              ]))
                        else ...[
                          _emailCheckTile(
                              email: emailPrincipal,
                              badge: 'Principal',
                              badgeColor: verde,
                              selected:
                                  emailsSelecionados.contains(emailPrincipal),
                              isDark: isDark,
                              onTap: () => setStateDialog(() {
                                    if (emailsSelecionados
                                        .contains(emailPrincipal))
                                      emailsSelecionados.remove(emailPrincipal);
                                    else
                                      emailsSelecionados.add(emailPrincipal);
                                  })),
                          ...emailsAdicionais.map((email) => _emailCheckTile(
                              email: email,
                              badge: 'Adicional',
                              badgeColor: Colors.blueGrey,
                              selected: emailsSelecionados.contains(email),
                              isDark: isDark,
                              onTap: () => setStateDialog(() {
                                    if (emailsSelecionados.contains(email))
                                      emailsSelecionados.remove(email);
                                    else
                                      emailsSelecionados.add(email);
                                  }))),
                        ],
                        const SizedBox(height: 6),
                      ]),
                ),
                actions: [
                  OutlinedButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      style: OutlinedButton.styleFrom(
                          side: BorderSide(color: borderColor),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8))),
                      child: Text('Pular', style: TextStyle(color: hintColor))),
                  ElevatedButton.icon(
                      onPressed: emailsSelecionados.isEmpty
                          ? null
                          : () => Navigator.of(ctx).pop(true),
                      icon: const Icon(Icons.send_rounded,
                          size: 15, color: Colors.white),
                      label: Text(
                          emailsSelecionados.isEmpty
                              ? 'Selecione'
                              : 'Enviar (${emailsSelecionados.length})',
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                          backgroundColor:
                              emailsSelecionados.isEmpty ? Colors.grey : verde,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)))),
                ],
              );
            },
          ),
        ) ??
        false;

    if (enviou && emailsSelecionados.isNotEmpty) {
      setState(() => _statusPDF = 'Enviando e-mail de atualização...');
      for (final email in emailsSelecionados) {
        await _sendEmailPreventivaRealizada(
            toEmail: email,
            equipamento: equipNome,
            patrimonio: patrimonio,
            sala: sala,
            setor: _setorCtrl.text.trim(),
            dataRealizacao: dataRealizacao,
            tipoManutencao: _tipoManutencao ?? '');
      }
    }

    setState(() {
      _progressoPDF = 0.50;
      _statusPDF = 'Removendo pendência...';
    });
    await _deletarPendencia(idPendencia);
    _pendenciaDocId = null;
  }

  Widget _emailCheckTile({
    required String email,
    required String badge,
    required Color badgeColor,
    required bool selected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    const verde = Color(0xFF1A3C34);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
            color: selected
                ? verde.withAlpha(18)
                : (isDark ? const Color(0xFF252D3A) : const Color(0xFFF4F6F8)),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
                color: selected ? verde.withAlpha(128) : Colors.transparent,
                width: 1.4)),
        child: Row(children: [
          AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                  color: selected ? verde : Colors.transparent,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                      color: selected
                          ? verde
                          : (isDark ? Colors.white30 : Colors.grey.shade400),
                      width: 1.8)),
              child: selected
                  ? const Icon(Icons.check, color: Colors.white, size: 13)
                  : null),
          const SizedBox(width: 10),
          Expanded(
              child: Text(email,
                  style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.white : Colors.black87,
                      fontWeight:
                          selected ? FontWeight.w600 : FontWeight.normal))),
          const SizedBox(width: 6),
          Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                  color: badgeColor.withAlpha(25),
                  borderRadius: BorderRadius.circular(4)),
              child: Text(badge,
                  style: TextStyle(
                      fontSize: 10,
                      color: badgeColor,
                      fontWeight: FontWeight.w600))),
        ]),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SALVAR / ATUALIZAR
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    final itensVazios = <({String label, GlobalKey key, bool opcional})>[];
    if (_fotoFile == null)
      itensVazios
          .add((label: 'Foto do equipamento', key: _keyFoto, opcional: true));
    if (_equipamentoCtrl.text.trim().isEmpty)
      itensVazios
          .add((label: 'Equipamento', key: _keyEquipamento, opcional: false));
    if (_marcaCtrl.text.trim().isEmpty)
      itensVazios.add((label: 'Marca', key: _keyMarca, opcional: false));
    if (_modeloCtrl.text.trim().isEmpty)
      itensVazios.add((label: 'Modelo', key: _keyModelo, opcional: false));
    if (_salaCtrl.text.trim().isEmpty)
      itensVazios.add((label: 'Sala', key: _keySala, opcional: false));
    if (_setorCtrl.text.trim().isEmpty)
      itensVazios.add((label: 'Setor', key: _keySetor, opcional: false));
    if (_responsavelCtrl.text.trim().isEmpty)
      itensVazios
          .add((label: 'Responsável', key: _keyResponsavel, opcional: false));
    if (_tensaoCtrl.text.trim().isEmpty)
      itensVazios.add((label: 'Tensão', key: _keyTensao, opcional: false));
    if (_tecnico == null)
      itensVazios.add((label: 'Técnico', key: _keyTecnico, opcional: false));
    if (_tipoManutencao == null)
      itensVazios.add((
        label: 'Tipo da Manutenção',
        key: _keyTipoManutencao,
        opcional: false
      ));

    if (itensVazios.isNotEmpty) {
      final prosseguir = await _mostrarDialogoConfirmacao(itensVazios);
      if (!prosseguir) {
        final primeiro = itensVazios.firstWhere((e) => !e.opcional,
            orElse: () => itensVazios.first);
        await _scrollToKey(primeiro.key);
        return;
      }
    }

    setState(() {
      _isGerandoPDF = true;
      _progressoPDF = 0.0;
      _statusPDF = 'Iniciando...';
    });

    try {
      final patrimonio = _patrimonioCtrl.text.trim();
      final email = _emailCtrl.text.trim();
      final mesSalvo = _meses[_mesSelecionado - 1].toUpperCase();
      final anoSalvo = _anoSelecionado;
      final now = DateTime.now();
      final dataSalva = DateTime(
        _dataCadastro.year,
        _dataCadastro.month,
        _dataCadastro.day,
        now.hour,
        now.minute,
        now.second,
      );
      final dataRealizacao =
          '${_dataCadastro.day.toString().padLeft(2, '0')}/${_dataCadastro.month.toString().padLeft(2, '0')}/${_dataCadastro.year}';

      final nomeEquipamento = _equipamentoCtrl.text.trim().isNotEmpty
          ? _equipamentoCtrl.text.trim()
          : (_marcaCtrl.text.trim().isNotEmpty
              ? '${_marcaCtrl.text.trim()} ${_modeloCtrl.text.trim()}'.trim()
              : 'SEM NOME');

      setState(() {
        _progressoPDF = 0.08;
        _statusPDF = 'Enviando foto...';
      });
      final fotoUrl =
          _fotoFile != null ? await _uploadFoto() : _fotoUrlExistente;

      setState(() {
        _progressoPDF = 0.18;
        _statusPDF = 'Verificando pendências...';
      });

      String? idParaDeletar = _pendenciaDocId;
      if (idParaDeletar == null) {
        idParaDeletar = await _buscarPendenciaId(
            patrimonio, _mesSelecionado, _anoSelecionado);
      }

      if (idParaDeletar != null) {
        setState(() => _isGerandoPDF = false);
        await _mostrarDialogoEmailPendencia(
            idPendencia: idParaDeletar,
            patrimonio: patrimonio,
            dataRealizacao: dataRealizacao);
        if (!mounted) return;
        setState(() {
          _isGerandoPDF = true;
          _progressoPDF = 0.38;
          _statusPDF = 'Salvando dados...';
        });
      } else {
        setState(() {
          _progressoPDF = 0.28;
          _statusPDF = 'Salvando dados...';
        });
      }

      final dadosPreventiva = {
        'NOME': nomeEquipamento,
        'OBSERVACAO': _obsCtrl.text.trim(),
        'PATRIMONIO': patrimonio,
        'RESPONSAVEL': _responsavelCtrl.text.trim(),
        'SALA': _salaCtrl.text.trim(),
        'SETOR': _setorCtrl.text.trim(),
        'TECNICORESPONSAVEL': _tecnico,
        'TENSAO': _tensaoCtrl.text.trim(),
        'AMPERAGEM': _amperagemCtrl.text.trim(),
        'TIPO': _tipoCtrl.text.trim(),
        'MARCA': _marcaCtrl.text.trim(),
        'MODELO': _modeloCtrl.text.trim(),
        'BTUS': _btusCtrl.text.trim(),
        'FLUIDO': _fluidoCtrl.text.trim(),
        'VERIFICAODERUIDOS': _verRuidos,
        'VERIFICAODODRENO': _verDreno,
        'VERIFICAODOISOLAMENTOTRMICO': _verIsolamento,
        'VERIFICAODOSACABAMENTOS': false,
        'MES': mesSalvo,
        'ANO': anoSalvo,
        'TIPOMANUTENCAO': _tipoManutencao,
        'EMAIL': email,
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
        'datacadastro': Timestamp.fromDate(dataSalva),
        'status': 'concluida',
      };

      if (_preventivaExistenteId != null &&
          _preventivaExistenteId!.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('PREVENTIVAS')
            .doc(_preventivaExistenteId!)
            .update(dadosPreventiva);
      } else {
        await FirebaseFirestore.instance
            .collection('PREVENTIVAS')
            .add(dadosPreventiva);
      }

      setState(() {
        _progressoPDF = 0.55;
        _statusPDF = 'Enviando notificação push...';
      });
      await _enviarNotificacao(
          email: email,
          sala: _salaCtrl.text.trim(),
          setor: _setorCtrl.text.trim(),
          patrimonio: patrimonio);

      setState(() {
        _progressoPDF = 0.60;
        _statusPDF = 'Criando notificação...';
      });
      await _criarNotificacaoFirebase(
        email: email,
        patrimonio: patrimonio,
        equipamento: nomeEquipamento,
        sala: _salaCtrl.text.trim(),
        setor: _setorCtrl.text.trim(),
        mesSalvo: mesSalvo,
        anoSalvo: anoSalvo,
      );

      setState(() {
        _progressoPDF = 0.65;
        _statusPDF = 'Carregando fontes e logo...';
      });
      await preCarregarAssetsPDF();

      setState(() {
        _progressoPDF = 0.80;
        _statusPDF = 'Gerando PDF...';
      });
      await geraPDFPreventiva(patrimonio, email.isNotEmpty ? email : null);

      setState(() {
        _progressoPDF = 1.0;
        _statusPDF = 'Tudo pronto! ✓';
      });
      widget.onSalvar?.call();
      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        setState(() {
          _isGerandoPDF = false;
          _statusPDF = '';
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Erro: $e'),
            backgroundColor: _error(context),
            duration: const Duration(seconds: 5)));
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
  // HELPERS UI
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _sectionTitle(BuildContext ctx, String title) => Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 10),
      child: Row(children: [
        Container(
            width: 4,
            height: 20,
            color: _primary(ctx),
            margin: const EdgeInsets.only(right: 10)),
        Text(title,
            style: TextStyle(
                color: _textColor(ctx),
                fontSize: 15,
                fontWeight: FontWeight.bold,
                letterSpacing: 1)),
      ]));

  InputDecoration _dec(BuildContext ctx, String label,
          {bool isRed = false, bool readOnly = false}) =>
      InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
            color: isRed ? _error(ctx) : _hintColor(ctx),
            fontSize: 13,
            fontWeight: isRed ? FontWeight.bold : FontWeight.normal),
        filled: true,
        fillColor: readOnly ? _card(ctx).withAlpha(153) : _card(ctx),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
                color: readOnly ? _green.withAlpha(128) : _border(ctx))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: _primary(ctx), width: 1.5)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: _error(ctx))),
        focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: _error(ctx), width: 1.5)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        suffixIcon:
            readOnly ? Icon(Icons.auto_awesome, color: _green, size: 16) : null,
      );

  Widget _field(BuildContext ctx, TextEditingController ctrl, String label,
          {GlobalKey? fieldKey,
          bool isRed = false,
          bool readOnly = false,
          TextInputType? keyboardType,
          bool required = false}) =>
      Padding(
          key: fieldKey,
          padding: const EdgeInsets.only(bottom: 12),
          child: TextFormField(
              controller: ctrl,
              style: TextStyle(color: _textColor(ctx), fontSize: 14),
              keyboardType: keyboardType,
              readOnly: readOnly,
              decoration: _dec(ctx, label, isRed: isRed, readOnly: readOnly),
              validator: required
                  ? (v) => (v == null || v.isEmpty) ? 'Obrigatório' : null
                  : null));

  Widget _sufixField(BuildContext ctx, TextEditingController ctrl, String label,
          String suffix,
          {GlobalKey? fieldKey, FocusNode? focusNode, bool isRed = false}) =>
      Padding(
          key: fieldKey,
          padding: const EdgeInsets.only(bottom: 12),
          child: TextFormField(
              controller: ctrl,
              focusNode: focusNode,
              style: TextStyle(color: _textColor(ctx), fontSize: 14),
              keyboardType: TextInputType.number,
              decoration: _dec(ctx, label, isRed: isRed).copyWith(
                  suffixText: suffix,
                  suffixStyle: TextStyle(
                      color: _primary(ctx),
                      fontWeight: FontWeight.bold,
                      fontSize: 14))));

  Widget _checkItem(BuildContext ctx, String label, bool value,
          ValueChanged<bool?> onChanged) =>
      Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Row(children: [
            SizedBox(
                width: 24,
                height: 24,
                child: Checkbox(
                    value: value,
                    onChanged: onChanged,
                    activeColor: _primary(ctx),
                    checkColor: Colors.black,
                    side: BorderSide(color: _border(ctx)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4)))),
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
                      color: bold ? _textColor(ctx) : _hintColor(ctx),
                      fontSize: 13));
            }).toList()))),
          ]));

  Widget _patrimonioField(BuildContext ctx) {
    Color borderColor = _border(ctx);
    Widget? suffix;
    Widget? statusWidget;

    if (_isBuscando) {
      borderColor = _primary(ctx);
      suffix = Padding(
          padding: const EdgeInsets.all(14),
          child: SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: _primary(ctx))));
      statusWidget = _statusRow(ctx, Icons.search,
          'Buscando equipamento e pendências...', _primary(ctx));
    } else if (_equipamentoEncontrado) {
      borderColor = _green;
      suffix = const Icon(Icons.check_circle_rounded, color: _green, size: 22);
      statusWidget =
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _statusRow(ctx, Icons.check_circle_outline,
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
                        decorationColor: _green)))),
        if (_pendenciaDocId != null)
          Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                      color: _orange.withAlpha(30),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: _orange.withAlpha(128))),
                  child: Row(children: [
                    const Icon(Icons.warning_amber_rounded,
                        color: _orange, size: 14),
                    const SizedBox(width: 6),
                    Expanded(
                        child: Text(
                            '⚠️ Pendência de ${_meses[_mesSelecionado - 1]}/$_anoSelecionado encontrada — será encerrada ao salvar.',
                            style: TextStyle(
                                color: _orange,
                                fontSize: 11,
                                fontWeight: FontWeight.w500))),
                  ]))),
        if (_preventivaExistenteId != null)
          Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                      color: const Color(0xFF0369A1).withAlpha(30),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                          color: const Color(0xFF0369A1).withAlpha(128))),
                  child: Row(children: [
                    const Icon(Icons.edit_rounded,
                        color: Color(0xFF0369A1), size: 14),
                    const SizedBox(width: 6),
                    const Expanded(
                        child: Text(
                            '✏️ Modo edição — alterações salvas sobre o registro existente.',
                            style: TextStyle(
                                color: Color(0xFF0369A1),
                                fontSize: 11,
                                fontWeight: FontWeight.w500))),
                  ]))),
      ]);
    } else if (_equipamentoNaoEncontrado) {
      borderColor = _orange;
      suffix =
          const Icon(Icons.warning_amber_rounded, color: _orange, size: 22);
      statusWidget = _statusRow(ctx, Icons.info_outline,
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
        key: _keyPatrimonio,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
              controller: _patrimonioCtrl,
              style: TextStyle(color: _textColor(ctx), fontSize: 14),
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                  labelText: 'PATRIMÔNIO: *',
                  labelStyle: TextStyle(color: _hintColor(ctx), fontSize: 13),
                  filled: true,
                  fillColor: _card(ctx),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: borderColor, width: 1.5)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: _primary(ctx), width: 2)),
                  errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: _error(ctx))),
                  focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: _error(ctx), width: 1.5)),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  suffixIcon: suffix),
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Informe o patrimônio' : null),
          if (statusWidget != null)
            Padding(
                padding: const EdgeInsets.only(top: 6), child: statusWidget),
        ]);
  }

  Widget _statusRow(BuildContext ctx, IconData icon, String text, Color color,
          {Widget? trailing}) =>
      Row(children: [
        Icon(icon, color: color, size: 14),
        const SizedBox(width: 5),
        Expanded(
            child: Text(text, style: TextStyle(color: color, fontSize: 11.5))),
        if (trailing != null) trailing,
      ]);

  Widget _tecnicoDropdown(BuildContext ctx, {GlobalKey? fieldKey}) => Padding(
      key: fieldKey,
      padding: const EdgeInsets.only(bottom: 12),
      child: _carregandoTecnicos
          ? Container(
              height: 52,
              decoration: BoxDecoration(
                  color: _card(ctx),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _border(ctx))),
              child: Row(children: [
                const SizedBox(width: 16),
                SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: _primary(ctx))),
                const SizedBox(width: 12),
                Text('Carregando técnicos...',
                    style: TextStyle(color: _hintColor(ctx), fontSize: 13)),
              ]))
          : DropdownButtonFormField<String>(
              value: _tecnico,
              dropdownColor: _card(ctx),
              style: TextStyle(color: _textColor(ctx), fontSize: 14),
              decoration: _dec(ctx, 'TÉCNICO:', isRed: true),
              hint: Text('Selecione o técnico',
                  style: TextStyle(color: _hintColor(ctx), fontSize: 13)),
              items: _tecnicosFirestore
                  .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                  .toList(),
              onChanged: (v) => setState(() => _tecnico = v)));

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
    final modoEdicao = _preventivaExistenteId != null;

    return SafeArea(
      child: Container(
      width: widget.width ?? double.infinity,
      color: _bg(context),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: EdgeInsets.fromLTRB(
              16, 16, 16, 16 + MediaQuery.of(context).padding.bottom),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                  child: Text(
                      modoEdicao ? 'EDITAR PREVENTIVA' : 'CADASTRAR PREVENTIVA',
                      style: TextStyle(
                          color: modoEdicao
                              ? const Color(0xFF0369A1)
                              : _textColor(context),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5))),
              Center(
                  child: Text(
                      modoEdicao
                          ? 'editando registro existente'
                          : 'formulário para adicionar nova preventiva',
                      style:
                          TextStyle(color: _hintColor(context), fontSize: 12))),
              const SizedBox(height: 16),

              // ── Área de foto ──────────────────────────────────────────────
              GestureDetector(
                onTap: _pickFoto,
                child: Container(
                  key: _keyFoto,
                  height: 160,
                  width: double.infinity,
                  decoration: BoxDecoration(
                      color: _card(context),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _border(context))),
                  child: _fotoFile != null
                      ? Stack(children: [
                          ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.memory(_fotoFile!.bytes!,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity)),
                          Positioned(
                              bottom: 8,
                              right: 8,
                              child: GestureDetector(
                                  onTap: _pickFoto,
                                  child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                          color: Colors.black54,
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.photo_library_outlined,
                                                color: Colors.white, size: 14),
                                            SizedBox(width: 4),
                                            Text('Trocar foto',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 11)),
                                          ])))),
                        ])
                      : _fotoUrlExistente != null
                          ? Stack(children: [
                              ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(_fotoUrlExistente!,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity,
                                      loadingBuilder: (ctx, child, progress) {
                                        if (progress == null) return child;
                                        return Container(
                                          color: _card(context),
                                          child: Center(
                                            child: CircularProgressIndicator(
                                              value: progress
                                                          .expectedTotalBytes !=
                                                      null
                                                  ? progress
                                                          .cumulativeBytesLoaded /
                                                      progress
                                                          .expectedTotalBytes!
                                                  : null,
                                              color: _primary(context),
                                              strokeWidth: 2,
                                            ),
                                          ),
                                        );
                                      },
                                      errorBuilder: (ctx, _, __) => Center(
                                            child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                      Icons
                                                          .broken_image_outlined,
                                                      color:
                                                          _hintColor(context),
                                                      size: 32),
                                                  const SizedBox(height: 6),
                                                  Text(
                                                      'Erro ao carregar imagem',
                                                      style: TextStyle(
                                                          color: _hintColor(
                                                              context),
                                                          fontSize: 11)),
                                                ]),
                                          ))),
                              Positioned(
                                  top: 8,
                                  left: 8,
                                  child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                          color: Colors.black54,
                                          borderRadius:
                                              BorderRadius.circular(6)),
                                      child: const Text('foto atual',
                                          style: TextStyle(
                                              color: Colors.white70,
                                              fontSize: 10)))),
                              Positioned(
                                  bottom: 8,
                                  right: 8,
                                  child: GestureDetector(
                                      onTap: _pickFoto,
                                      child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 6),
                                          decoration: BoxDecoration(
                                              color: Colors.black54,
                                              borderRadius:
                                                  BorderRadius.circular(8)),
                                          child: const Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                    Icons
                                                        .photo_library_outlined,
                                                    color: Colors.white,
                                                    size: 14),
                                                SizedBox(width: 4),
                                                Text('Trocar foto',
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 11)),
                                              ])))),
                            ])
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                  Icon(Icons.add_photo_alternate_outlined,
                                      color: _primary(context), size: 40),
                                  const SizedBox(height: 8),
                                  Text('add foto',
                                      style: TextStyle(
                                          color: _hintColor(context))),
                                  const SizedBox(height: 4),
                                  Text('(câmera ou galeria)',
                                      style: TextStyle(
                                          color: _hintColor(context),
                                          fontSize: 11)),
                                ]),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content:
                              const Text('Use a action de scan do FlutterFlow'),
                          backgroundColor: _primary(context))),
                  icon: Icon(Icons.qr_code_2, color: _primary(context)),
                  label: Text('LER HPS CODE',
                      style: TextStyle(color: _textColor(context))),
                  style: OutlinedButton.styleFrom(
                      side: BorderSide(color: _border(context)),
                      backgroundColor: _card(context),
                      minimumSize: const Size(double.infinity, 52),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)))),
              const SizedBox(height: 12),

              _patrimonioField(context),
              const SizedBox(height: 12),

              Row(children: [
                Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<int>(
                        value: _mesSelecionado,
                        dropdownColor: _card(context),
                        style:
                            TextStyle(color: _textColor(context), fontSize: 14),
                        decoration: _dec(context, 'MÊS'),
                        items: List.generate(
                            12,
                            (i) => DropdownMenuItem(
                                value: i + 1, child: Text(_meses[i]))),
                        onChanged: (v) {
                          final novoMes = v ?? 1;
                          setState(() {
                            _mesSelecionado = novoMes;
                            _preventivaExistenteId = null;
                            _preventivaExistenteData = null;
                          });
                          final pat = _patrimonioCtrl.text.trim();
                          if (pat.isNotEmpty) {
                            Future.wait([
                              _buscarPendenciaId(pat, novoMes, _anoSelecionado),
                              _buscarPreventivaExistente(
                                  pat, novoMes, _anoSelecionado),
                            ]).then((results) {
                              if (!mounted) return;
                              setState(() =>
                                  _pendenciaDocId = results[0] as String?);
                              final prev = results[1] as Map<String, dynamic>?;
                              if (prev != null) {
                                setState(() {
                                  _preventivaExistenteId =
                                      prev['__id__'] as String?;
                                  _preventivaExistenteData = prev;
                                });
                                _mostrarPopupPreventivaExistente(prev);
                              }
                            });
                          }
                        })),
                const SizedBox(width: 10),
                Expanded(
                    child: DropdownButtonFormField<int>(
                        value: _anoSelecionado,
                        dropdownColor: _card(context),
                        style:
                            TextStyle(color: _textColor(context), fontSize: 14),
                        decoration: _dec(context, 'ANO'),
                        items: List.generate(
                            5,
                            (i) => DropdownMenuItem(
                                value: 2024 + i, child: Text('${2024 + i}'))),
                        onChanged: (v) {
                          final novoAno = v ?? 2026;
                          setState(() {
                            _anoSelecionado = novoAno;
                            _preventivaExistenteId = null;
                            _preventivaExistenteData = null;
                          });
                          final pat = _patrimonioCtrl.text.trim();
                          if (pat.isNotEmpty) {
                            Future.wait([
                              _buscarPendenciaId(pat, _mesSelecionado, novoAno),
                              _buscarPreventivaExistente(
                                  pat, _mesSelecionado, novoAno),
                            ]).then((results) {
                              if (!mounted) return;
                              setState(() =>
                                  _pendenciaDocId = results[0] as String?);
                              final prev = results[1] as Map<String, dynamic>?;
                              if (prev != null) {
                                setState(() {
                                  _preventivaExistenteId =
                                      prev['__id__'] as String?;
                                  _preventivaExistenteData = prev;
                                });
                                _mostrarPopupPreventivaExistente(prev);
                              }
                            });
                          }
                        })),
              ]),

              const SizedBox(height: 16),
              GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _dataCadastro,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                    locale: const Locale('pt', 'BR'),
                    builder: (ctx, child) => Theme(
                      data: Theme.of(ctx).copyWith(
                        colorScheme: ColorScheme.dark(
                          primary: _primary(context),
                          onPrimary: Colors.black,
                          surface: _card(context),
                          onSurface: _textColor(context),
                        ),
                        dialogBackgroundColor: _card(context),
                      ),
                      child: child!,
                    ),
                  );
                  if (picked != null) {
                    setState(() {
                      _dataCadastro = picked;
                      _mesSelecionado = picked.month;
                      _anoSelecionado = picked.year;
                    });
                    final pat = _patrimonioCtrl.text.trim();
                    if (pat.isNotEmpty) {
                      Future.wait([
                        _buscarPendenciaId(pat, picked.month, picked.year),
                        _buscarPreventivaExistente(
                            pat, picked.month, picked.year),
                      ]).then((results) {
                        if (!mounted) return;
                        setState(() => _pendenciaDocId = results[0] as String?);
                        final prev = results[1] as Map<String, dynamic>?;
                        if (prev != null) {
                          setState(() {
                            _preventivaExistenteId = prev['__id__'] as String?;
                            _preventivaExistenteData = prev;
                          });
                          _mostrarPopupPreventivaExistente(prev);
                        }
                      });
                    }
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: _card(context),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _border(context)),
                  ),
                  child: Row(children: [
                    Icon(Icons.calendar_today_rounded,
                        color: _primary(context), size: 18),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('DATA DA MANUTENÇÃO',
                              style: TextStyle(
                                  color: _hintColor(context),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.4)),
                          const SizedBox(height: 2),
                          Text(
                            '${_dataCadastro.day.toString().padLeft(2, '0')}/'
                            '${_dataCadastro.month.toString().padLeft(2, '0')}/'
                            '${_dataCadastro.year}',
                            style: TextStyle(
                                color: _textColor(context),
                                fontSize: 15,
                                fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _primary(context).withAlpha(30),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text('ALTERAR',
                          style: TextStyle(
                              color: _primary(context),
                              fontSize: 11,
                              fontWeight: FontWeight.w700)),
                    ),
                  ]),
                ),
              ),
              const SizedBox(height: 20),
              if (auto)
                Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                        color: _green.withAlpha(20),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: _green.withAlpha(89))),
                    child: Row(children: [
                      const Icon(Icons.auto_awesome, color: _green, size: 15),
                      const SizedBox(width: 8),
                      Expanded(
                          child: Text(
                              'Campos preenchidos automaticamente. Toque para editar.',
                              style: TextStyle(color: _green, fontSize: 11.5))),
                    ])),

              _field(context, _marcaCtrl, 'MARCA:',
                  fieldKey: _keyMarca, readOnly: auto),
              _field(context, _modeloCtrl, 'MODELO:',
                  fieldKey: _keyModelo, readOnly: auto),
              _field(context, _equipamentoCtrl, 'EQUIPAMENTO:',
                  fieldKey: _keyEquipamento, readOnly: auto),
              _field(context, _tipoCtrl, 'TIPO:', readOnly: auto),
              _field(context, _btusCtrl, 'BTUs:',
                  keyboardType: TextInputType.number, readOnly: auto),
              _field(context, _fluidoCtrl, 'FLUÍDO:', readOnly: auto),
              _field(context, _salaCtrl, 'SALA:',
                  fieldKey: _keySala, readOnly: auto),
              _field(context, _setorCtrl, 'SETOR:',
                  fieldKey: _keySetor, readOnly: auto),
              _sufixField(context, _tensaoCtrl, 'TENSÃO:', 'V',
                  fieldKey: _keyTensao, focusNode: _tensaoFocus, isRed: true),
              _sufixField(context, _amperagemCtrl, 'AMPERAGEM:', 'A',
                  focusNode: _amperagemFocus),
              _field(context, _responsavelCtrl, 'RESPONSÁVEL:',
                  fieldKey: _keyResponsavel, readOnly: auto),
              _field(context, _emailCtrl, 'EMAIL:', readOnly: auto),
              _tecnicoDropdown(context, fieldKey: _keyTecnico),
              Padding(
                  key: _keyTipoManutencao,
                  padding: const EdgeInsets.only(bottom: 12),
                  child: DropdownButtonFormField<String>(
                      value: _tipoManutencao,
                      dropdownColor: _card(context),
                      style:
                          TextStyle(color: _textColor(context), fontSize: 14),
                      decoration:
                          _dec(context, 'TIPO DA MANUTENÇÃO:', isRed: true),
                      hint: Text('Selecione',
                          style: TextStyle(
                              color: _hintColor(context), fontSize: 13)),
                      items: tiposMan
                          .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (v) {
                        setState(() => _tipoManutencao = v);
                        _aplicarChecksPorTipo(v);
                      })),
              if (_tipoManutencao != null)
                Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                        color: _primary(context).withAlpha(20),
                        borderRadius: BorderRadius.circular(8),
                        border:
                            Border.all(color: _primary(context).withAlpha(89))),
                    child: Row(children: [
                      Icon(Icons.info_outline,
                          color: _primary(context), size: 15),
                      const SizedBox(width: 8),
                      Expanded(
                          child: Text(
                              'Itens pré-selecionados conforme $_tipoManutencao. Ajuste se necessário.',
                              style: TextStyle(
                                  color: _primary(context), fontSize: 11.5))),
                    ])),

              _sectionTitle(context, 'EVAPORADORA'),
              _checkItem(
                  context,
                  'LIMPEZA DA EVAPORADORA INTERNA:',
                  _limpezaEvapInterna,
                  (v) => setState(() => _limpezaEvapInterna = v ?? false)),
              _checkItem(context, 'LIMPEZA DO FILTRO:', _limpezaFiltro,
                  (v) => setState(() => _limpezaFiltro = v ?? false)),
              _checkItem(
                  context,
                  'LIMPEZA COM BACTERICIDA:',
                  _limpezaBactericida,
                  (v) => setState(() => _limpezaBactericida = v ?? false)),
              _checkItem(
                  context,
                  'VERIFICAÇÃO DO CONTROLE E PILHAS:',
                  _verControlePilhas,
                  (v) => setState(() => _verControlePilhas = v ?? false)),
              _checkItem(context, 'VERIFICAR RUÍDOS:', _verRuidos,
                  (v) => setState(() => _verRuidos = v ?? false)),
              _checkItem(context, 'VERIFICAR MAL CHEIRO:', _verMalCheiro,
                  (v) => setState(() => _verMalCheiro = v ?? false)),
              _checkItem(
                  context,
                  'FAZER MEDIÇÃO E INFORMAR A CORRENTE ELÉTRICA:',
                  _medicaoCorrente,
                  (v) => setState(() => _medicaoCorrente = v ?? false)),
              _checkItem(
                  context,
                  'FAZER MEDIÇÃO E INFORMAR A TENSÃO ELÉTRICA:',
                  _medicaoTensaoEletrica,
                  (v) => setState(() => _medicaoTensaoEletrica = v ?? false)),

              _sectionTitle(context, 'CONDENSADORA'),
              _checkItem(context, 'VERIFICAR DRENO:', _verDreno,
                  (v) => setState(() => _verDreno = v ?? false)),
              _checkItem(context, 'VERIFICAR PRESSÃO (PSI):', _verPressao,
                  (v) => setState(() => _verPressao = v ?? false)),
              _checkItem(context, 'POLIR CONDENSADORA:', _polirCondensadora,
                  (v) => setState(() => _polirCondensadora = v ?? false)),
              _checkItem(
                  context,
                  'VERIFICAR PARTE ELÉTRICA:',
                  _verParteEletrica,
                  (v) => setState(() => _verParteEletrica = v ?? false)),
              _checkItem(
                  context,
                  'VERIFICAR ISOLAMENTO TÉRMICO:',
                  _verIsolamento,
                  (v) => setState(() => _verIsolamento = v ?? false)),

              _sectionTitle(context, 'SERVIÇOS ADICIONAIS'),
              _checkItem(
                  context,
                  'JATEAMENTO DA CONDENSADORA:',
                  _jateamentoCondensadora,
                  (v) => setState(() => _jateamentoCondensadora = v ?? false)),
              _checkItem(
                  context,
                  'JATEAMENTO DA EVAPORADORA:',
                  _jateamentoEvaporadora,
                  (v) => setState(() => _jateamentoEvaporadora = v ?? false)),
              _checkItem(context, 'LAVAGEM DO DRENO:', _lavagemDreno,
                  (v) => setState(() => _lavagemDreno = v ?? false)),
              _checkItem(
                  context,
                  'LAVAGEM DA CARCAÇA EVAPORADORA:',
                  _lavagemCarcacaEvap,
                  (v) => setState(() => _lavagemCarcacaEvap = v ?? false)),
              _checkItem(
                  context,
                  'LAVAGEM DA CARCAÇA CONDENSADORA:',
                  _lavagemCarcacaCond,
                  (v) => setState(() => _lavagemCarcacaCond = v ?? false)),
              _checkItem(
                  context,
                  'LIMPEZA E LUBRIFICAÇÃO DO COMPRESSOR:',
                  _limpezaCompressor,
                  (v) => setState(() => _limpezaCompressor = v ?? false)),
              _checkItem(
                  context,
                  'LAVAGEM DA TURBINA EVAPORADORA:',
                  _lavagemTurbinaEvap,
                  (v) => setState(() => _lavagemTurbinaEvap = v ?? false)),
              _checkItem(context, 'VERIFICAR PÉS DE BORRACHA:', _verPesBorracha,
                  (v) => setState(() => _verPesBorracha = v ?? false)),

              _sectionTitle(context, 'OBSERVAÇÕES'),
              TextFormField(
                  controller: _obsCtrl,
                  style: TextStyle(color: _textColor(context), fontSize: 13),
                  maxLines: 3,
                  decoration: _dec(context, 'OBS:')),
              const SizedBox(height: 24),

              if (_isGerandoPDF) ...[
                Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                        color: _card(context),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: _primary(context).withAlpha(102))),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: _primary(context))),
                            const SizedBox(width: 10),
                            Expanded(
                                child: Text(_statusPDF,
                                    style: TextStyle(
                                        color: _primary(context),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500))),
                            Text('${(_progressoPDF * 100).toInt()}%',
                                style: TextStyle(
                                    color: _primary(context),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold)),
                          ]),
                          const SizedBox(height: 10),
                          ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                  value: _progressoPDF,
                                  backgroundColor:
                                      _border(context).withAlpha(76),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      _primary(context)),
                                  minHeight: 8)),
                        ])),
                const SizedBox(height: 12),
              ],

              SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                      onPressed: _isGerandoPDF ? null : _salvar,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: _isGerandoPDF
                              ? _primary(context).withAlpha(102)
                              : (modoEdicao
                                  ? const Color(0xFF0369A1)
                                  : _primary(context)),
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: _isGerandoPDF ? 0 : 4),
                      child: _isGerandoPDF
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                  const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                          color: Colors.black54,
                                          strokeWidth: 2)),
                                  const SizedBox(width: 10),
                                  Text('PROCESSANDO...',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          letterSpacing: 1.0,
                                          color: Colors.black54)),
                                ])
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                  Icon(
                                      modoEdicao
                                          ? Icons.update_rounded
                                          : Icons.save_alt_rounded,
                                      size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                      modoEdicao
                                          ? 'SALVAR EDIÇÃO'
                                          : 'SALVAR PREVENTIVA',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          letterSpacing: 1.2)),
                                ]))),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    ),
    );
  }
}
