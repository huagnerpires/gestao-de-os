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

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

// ============================================================
// CACHE ESTÁTICO: logo e assinatura são baixados UMA VEZ
// e reutilizados em todas as chamadas seguintes da sessão.
// Isso acelera muito a geração em lote!
// ============================================================
Uint8List? _cachedLogo;
Uint8List? _cachedAssinatura;
pw.Font? _cachedFontRegular;
pw.Font? _cachedFontBold;

const _urlLogo = 'https://i.ibb.co/VpqNsxXt/Imagem1.jpg';
const _urlAssinatura =
    'https://i.ibb.co/hRvtGhbK/3b004d07-a4a9-4568-9d8b-5abc281dbcee.png';
const _kTimeout = Duration(seconds: 5);

Future<Uint8List?> _fetchBytes(String url) async {
  try {
    final resp = await http.get(Uri.parse(url),
        headers: {'User-Agent': 'Mozilla/5.0'}).timeout(_kTimeout);
    return resp.statusCode == 200 ? resp.bodyBytes : null;
  } catch (_) {
    return null;
  }
}

// ============================================================
// FUNÇÃO PRINCIPAL: SINCRONIZAR PDFs FALTANTES
// ============================================================
Future<void> sincronizarPDFs(String? emailCliente) async {
  print('=== INICIANDO SINCRONIZAÇÃO EM LOTE ===');

  final pastaEmail = (emailCliente != null && emailCliente.isNotEmpty)
      ? emailCliente.trim()
      : 'sem_email';

  final now = DateTime.now();
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

  // Tratamento para remover o "ç" de Março no nome da pasta
  final mesOriginal = listaMeses[now.month - 1]; // ex: "Março"
  final mesStorage = mesOriginal.replaceAll('ç', 'c'); // ex: "Marco"
  final mesFirestore = mesOriginal.toUpperCase(); // ex: "MARÇO"
  final anoStr = now.year.toString();

  final storagePath = '$pastaEmail/$anoStr/$mesStorage';
  print('Verificando pasta: $storagePath');

  // 1. Obter PDFs existentes no Storage
  Set<String> pdfsNoStorage = {};
  try {
    final listResult = await firebase_storage.FirebaseStorage.instance
        .ref(storagePath)
        .listAll();
    for (var item in listResult.items) {
      if (item.name.toLowerCase().endsWith('.pdf')) {
        // Remove a extensão .pdf para pegar só o patrimônio
        pdfsNoStorage.add(item.name
            .replaceAll(RegExp(r'\.pdf$', caseSensitive: false), '')
            .trim());
      }
    }
    print('Encontrados ${pdfsNoStorage.length} PDFs no Storage.');
  } catch (e) {
    print('Erro ao listar Storage (a pasta pode não existir ainda): $e');
  }

  // 2. Obter Patrimônios da coleção PREVENTIVAS (filtrando pelo mês atual)
  Set<String> patrimoniosFirestore = {};
  try {
    final prevQuery = await FirebaseFirestore.instance
        .collection('PREVENTIVAS')
        .where('MES', isEqualTo: mesFirestore)
        .get();

    for (var doc in prevQuery.docs) {
      final pat = doc.data()['PATRIMONIO']?.toString().trim();
      if (pat != null && pat.isNotEmpty) {
        patrimoniosFirestore.add(pat);
      }
    }
    print(
        'Encontrados ${patrimoniosFirestore.length} patrimônios no Firestore para o mês $mesFirestore.');
  } catch (e) {
    print('Erro ao consultar Firestore: $e');
    return;
  }

  // 3. Comparar e encontrar os faltantes
  final faltantes = patrimoniosFirestore.difference(pdfsNoStorage);

  if (faltantes.isEmpty) {
    print('=== TUDO SINCRONIZADO! Nenhum PDF faltando. ===');
    return;
  }

  print('Faltam ${faltantes.length} PDFs para gerar: $faltantes');

  // 4. Gerar os PDFs faltantes (chamando sua lógica original)
  for (String pat in faltantes) {
    print('>> Gerando PDF faltante: $pat');
    await _geraPDFPreventivaLogica(pat, emailCliente);
  }

  print('=== SINCRONIZAÇÃO EM LOTE CONCLUÍDA ===');
}

// ============================================================
// LÓGICA ORIGINAL DE GERAÇÃO (Transformada em função interna)
// ============================================================
Future<void> _geraPDFPreventivaLogica(
    String patrimonio, String? emailCliente) async {
  pw.TableRow _buildIdentRow(
      String label1, String value1, String label2, String value2) {
    return pw.TableRow(children: [
      pw.Container(
        padding: pw.EdgeInsets.symmetric(vertical: 2, horizontal: 4),
        child: pw.RichText(
          text: pw.TextSpan(children: [
            pw.TextSpan(
                text: '$label1 ',
                style:
                    pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold)),
            pw.TextSpan(text: value1, style: pw.TextStyle(fontSize: 7)),
          ]),
        ),
      ),
      pw.Container(
        decoration: pw.BoxDecoration(
            border: pw.Border(left: pw.BorderSide(width: 0.5))),
        padding: pw.EdgeInsets.symmetric(vertical: 2, horizontal: 4),
        child: pw.RichText(
          text: pw.TextSpan(children: [
            pw.TextSpan(
                text: '$label2 ',
                style:
                    pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold)),
            pw.TextSpan(text: value2, style: pw.TextStyle(fontSize: 7)),
          ]),
        ),
      ),
    ]);
  }

  pw.TableRow _buildCheckRow(String num, String label, bool checked) {
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

  pw.TableRow _buildValueRow(String num, String label, String value) {
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

  String _formatarData(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  try {
    final pastaEmail = (emailCliente != null && emailCliente.isNotEmpty)
        ? emailCliente.trim()
        : 'sem_email';

    final results = await Future.wait([
      _cachedFontRegular != null
          ? Future.value(_cachedFontRegular!)
          : PdfGoogleFonts.openSansRegular(),
      _cachedFontBold != null
          ? Future.value(_cachedFontBold!)
          : PdfGoogleFonts.openSansBold(),
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
      _cachedLogo != null ? Future.value(_cachedLogo!) : _fetchBytes(_urlLogo),
      _cachedAssinatura != null
          ? Future.value(_cachedAssinatura!)
          : _fetchBytes(_urlAssinatura),
    ]);

    _cachedFontRegular = results[0] as pw.Font;
    _cachedFontBold = results[1] as pw.Font;
    final logoBytes = results[5] as Uint8List?;
    final assinaturaBytes = results[6] as Uint8List?;
    if (logoBytes != null) _cachedLogo = logoBytes;
    if (assinaturaBytes != null) _cachedAssinatura = assinaturaBytes;

    final fontRegular = _cachedFontRegular!;
    final fontBold = _cachedFontBold!;
    final prevQuery = results[2] as QuerySnapshot<Map<String, dynamic>>;
    final imgQuery = results[3] as QuerySnapshot<Map<String, dynamic>>;
    final usuariosQuery = results[4] as QuerySnapshot<Map<String, dynamic>>?;

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

    String? urlTermo;
    for (final key in const [
      'IMAGEM',
      'THAGEM',
      'TMAGEM',
      'FOTO',
      'foto',
      'imagem'
    ]) {
      final v = data[key]?.toString().trim();
      if (v != null && v.isNotEmpty) {
        urlTermo = v;
        break;
      }
    }

    final imageResults = await Future.wait([
      fotoClienteUrl != null ? _fetchBytes(fotoClienteUrl) : Future.value(null),
      imgEvaporadoraUrl != null
          ? _fetchBytes(imgEvaporadoraUrl)
          : Future.value(null),
      (urlTermo != null && urlTermo.startsWith('http'))
          ? _fetchBytes(urlTermo)
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
      'LIMPEZAELUBRIFICAODOCOMPRESS',
      'LIMPEZAELUBRIFICAODOMOTOR',
      'LIMPEZAELUBRIFICACAODOCOMPRESSOR',
      'LIMPEZAELUBRIFICACAODOCOMPRESSO',
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
        ? _formatarData((data['DATADAMANUTENCAO'] as Timestamp).toDate())
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
        theme: pw.ThemeData.withFont(base: fontRegular, bold: fontBold));

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(20),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
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
                                  fontSize: 8, fontWeight: pw.FontWeight.bold)),
                          if (logoEmpresa != null)
                            pw.Container(
                                height: 30,
                                alignment: pw.Alignment.centerLeft,
                                child: pw.Image(logoEmpresa,
                                    fit: pw.BoxFit.contain)),
                        ],
                      ),
                    ),
                  ),
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
                      ],
                    ),
                  ),
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
                                  fontSize: 8, fontWeight: pw.FontWeight.bold)),
                          if (imagemCliente != null)
                            pw.Container(
                                height: 30,
                                width: 80,
                                alignment: pw.Alignment.bottomRight,
                                child: pw.Image(imagemCliente,
                                    fit: pw.BoxFit.contain))
                          else
                            pw.Text(nomeClienteRodape,
                                style: pw.TextStyle(
                                    fontSize: 7,
                                    fontWeight: pw.FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ]),
              ),
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
                                  fontSize: 8,
                                  fontWeight: pw.FontWeight.bold)))),
                  pw.Divider(height: 1, thickness: 0.5),
                  pw.Table(
                    border: pw.TableBorder.symmetric(
                        inside: pw.BorderSide(width: 0.5)),
                    columnWidths: {
                      0: pw.FlexColumnWidth(1),
                      1: pw.FlexColumnWidth(1)
                    },
                    children: [
                      _buildIdentRow(
                          'APARELHO:',
                          data['EQUIPAMENTO'] ?? 'AR CONDICIONADO',
                          'VOLTAGEM:',
                          data['TENSAO'] ?? '220V'),
                      _buildIdentRow('MODELO:', data['MODELO'] ?? 'SPLIT',
                          'GÁS:', data['FLUIDO'] ?? 'R410A'),
                      _buildIdentRow('TIPO:', data['TIPO'] ?? 'INVERTER',
                          'POTÊNCIA:', data['BTUS'] ?? '12K BTUS'),
                      _buildIdentRow('FABRICANTE:', data['MARCA'] ?? 'LG',
                          'PRÉDIO:', data['SETOR'] ?? ''),
                      _buildIdentRow('PATRIMÔNIO:', data['PATRIMONIO'] ?? '',
                          'LOCALIZAÇÃO:', data['SALA'] ?? ''),
                      _buildIdentRow(
                          'TÉCNICO:',
                          data['TECNICORESPONSAVEL'] ?? 'JONATHAN',
                          'MANUTENÇÃO:',
                          'PREVENTIVA MENSAL'),
                    ],
                  ),
                ]),
              ),
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
                                crossAxisAlignment:
                                    pw.CrossAxisAlignment.stretch,
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
                                              fit: pw.BoxFit.cover)
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
                                              fontWeight:
                                                  pw.FontWeight.bold)))),
                              pw.Table(border: tableBorder, columnWidths: {
                                0: pw.FixedColumnWidth(15),
                                1: pw.FlexColumnWidth(),
                                2: pw.FixedColumnWidth(25)
                              }, children: [
                                _buildCheckRow(
                                    '1',
                                    'LIMPEZA DA EVAPORADORA INTERNA:',
                                    data['LIMPEZADAEVAPORADORA'] ?? false),
                                _buildCheckRow('2', 'LIMPEZA DO FILTRO:',
                                    data['LAVAGEMDOFILTRO'] ?? false),
                                _buildCheckRow('3', 'LIMPEZA COM BACTERICIDA:',
                                    data['LIMPEZACOMBACTERICIDA'] ?? false),
                                _buildCheckRow('4',
                                    'VERIFICAÇÃO DO CONTROLE E PILHAS:', true),
                                _buildCheckRow('5', 'VERIFICAR RUÍDOS:',
                                    data['VERIFICAODERUIDOS'] ?? false),
                                _buildCheckRow(
                                    '6', 'VERIFICAR MAL CHEIRO:', true),
                                _buildValueRow('7', 'CORRENTE ELÉTRICA (A):',
                                    data['AMPERAGEM'] ?? ''),
                                _buildValueRow('8', 'TENSÃO ELÉTRICA (V):',
                                    data['TENSAO'] ?? '220V'),
                              ]),
                            ]))),
                  ],
                ),
              ),
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
                                crossAxisAlignment:
                                    pw.CrossAxisAlignment.stretch,
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
                                              fit: pw.BoxFit.cover)
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
                              _buildCheckRow('1', 'VERIFICAR DRENO:',
                                  data['VERIFICAODODRENO'] ?? false),
                              _buildCheckRow(
                                  '2', 'VERIFICAR PRESSÃO (PSI):', true),
                              _buildCheckRow('3', 'POLIR CONDENSADORA:',
                                  data['LAVAGEMDACONDENSADORA'] ?? false),
                              _buildCheckRow(
                                  '4', 'VERIFICAR PARTE ELÉTRICA:', true),
                              _buildCheckRow(
                                  '5',
                                  'VERIFICAR ISOLAMENTO TÉRMICO:',
                                  data['VERIFICAODOISOLAMENTOTRMICO'] ?? false),
                              _buildCheckRow('6', 'JATEAMENTO DA CONDENSADORA:',
                                  data['JATEAMENTODACONDENSADOR'] ?? false),
                              _buildCheckRow('7', 'JATEAMENTO DA EVAPORADORA:',
                                  data['JATEAMENTODAEVAPORADORA'] ?? false),
                              _buildCheckRow('8', 'LAVAGEM DO DRENO:',
                                  data['LAVAGEMDODRENO'] ?? false),
                              _buildCheckRow(
                                  '9',
                                  'LAVAGEM DA CARCAÇA EVAPORADORA:',
                                  data['LAVAGEMDACARCAAEVAPORADORA'] ?? false),
                              _buildCheckRow(
                                  '10',
                                  'LAVAGEM DA CARCAÇA CONDENSADORA:',
                                  data['LAVAGEMDACARCAACONDENSADORA'] ??
                                      data['LAVAGEMDACARCAACONDENSADOR'] ??
                                      false),
                              _buildCheckRow(
                                  '11',
                                  'LIMPEZA E LUBRIFICAÇÃO DO COMPRESSOR:',
                                  checkLimpezaCompressor),
                              _buildCheckRow(
                                  '12',
                                  'LAVAGEM DA TURBINA EVAPORADORA:',
                                  data['LAVAGEMDATURBINA'] ?? false),
                              _buildCheckRow('13', 'VERIFICAR PÉS DE BORRACHA:',
                                  data['VERIFICAODOSACABAMENTOS'] ?? false),
                            ]))),
                  ],
                ),
              ),
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
                                    fontSize: 7,
                                    fontWeight: pw.FontWeight.bold))),
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
                ]),
              ),
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
                      pw.Text(textoObservacao, style: pw.TextStyle(fontSize: 7))
                  ],
                ),
              ),
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
                            ? pw.Image(assinaturaHPS, fit: pw.BoxFit.contain)
                            : null,
                      ),
                      pw.Container(
                          width: 150, height: 0.5, color: PdfColors.black),
                      pw.SizedBox(height: 2),
                      pw.Text('HPS REFRIGERAÇÃO',
                          style: pw.TextStyle(
                              fontSize: 7, fontWeight: pw.FontWeight.bold)),
                      pw.Text('CNPJ: 28.340.152/0001-52',
                          style: pw.TextStyle(fontSize: 6)),
                    ],
                  ),
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
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 10),
              pw.Center(
                  child: pw.Column(children: [
                pw.Text('AV PARÁ 486 IBIRAPUERA VITÓRIA DA CONQUISTA- BA',
                    style: pw.TextStyle(
                        fontSize: 6, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 2),
                pw.Text(
                    'Tel: (77) 98819-4630 / 98861-2447  -  www.hpsrefri.com.br',
                    style: pw.TextStyle(fontSize: 6)),
              ])),
            ],
          );
        },
      ),
    );

    final pdfBytes = await pdf.save();

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
    // Tratamento para remover o "ç" de Março na hora de salvar o PDF especificamente
    final mesStorage = listaMeses[now.month - 1].replaceAll('ç', 'c');

    final storagePath =
        '$pastaEmail/${now.year}/$mesStorage/${patrimonio.trim()}.pdf';

    await firebase_storage.FirebaseStorage.instance
        .ref()
        .child(storagePath)
        .putData(
          pdfBytes,
          firebase_storage.SettableMetadata(contentType: 'application/pdf'),
        );
  } catch (e) {
    print('Erro CRÍTICO no upload do Patrimonio $patrimonio: $e');
  }
}
