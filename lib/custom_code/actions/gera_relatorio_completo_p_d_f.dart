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
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

Future<String> geraRelatorioCompletoPDF(
  String? emailCliente,
  String? mes,
  String? ano,
  String? emailDestinatario,
) async {
  try {
    print('=== RELATÓRIO COMPLETO ($mes/$ano) + EMAIL RESPONSIVO ===');

    if (emailCliente == null || emailCliente.isEmpty) {
      return 'Erro: Email do cliente não informado.';
    }
    if (emailDestinatario == null || emailDestinatario.isEmpty) {
      return 'Erro: Email de destino não informado.';
    }
    if (mes == null || mes.isEmpty || ano == null || ano.isEmpty) {
      return 'Erro: Mês ou Ano não informados.';
    }

    // ── 0. PREPARAR RECURSOS ──────────────────────────────────────────────
    final fontRegular = await PdfGoogleFonts.openSansRegular();
    final fontBold = await PdfGoogleFonts.openSansBold();

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

    int mesNumero = -1;
    if (listaMeses.contains(mes)) {
      mesNumero = listaMeses.indexOf(mes) + 1;
    } else {
      mesNumero = int.tryParse(mes) ?? -1;
    }
    if (mesNumero == -1) return 'Erro: Mês inválido ($mes).';

    // Logo
    pw.ImageProvider? logoEmpresa;
    try {
      final response =
          await http.get(Uri.parse('https://i.ibb.co/VpqNsxXt/Imagem1.jpg'));
      if (response.statusCode == 200)
        logoEmpresa = pw.MemoryImage(response.bodyBytes);
    } catch (e) {}

    // Assinatura
    pw.ImageProvider? assinaturaHPS;
    try {
      final response = await http.get(Uri.parse(
          'https://i.ibb.co/hRvtGhbK/3b004d07-a4a9-4568-9d8b-5abc281dbcee.png'));
      if (response.statusCode == 200)
        assinaturaHPS = pw.MemoryImage(response.bodyBytes);
    } catch (e) {}

    // Imagem topo pendências
    pw.ImageProvider? imgTopoPendentes;
    try {
      final response = await http.get(
          Uri.parse('https://i.ibb.co/v481FdX8/9491f9c633ca.png'),
          headers: {'User-Agent': 'Mozilla/5.0'});
      if (response.statusCode == 200)
        imgTopoPendentes = pw.MemoryImage(response.bodyBytes);
    } catch (e) {}

    // ── 1. BUSCAR DADOS DO CLIENTE ────────────────────────────────────────
    pw.ImageProvider? imagemCliente;
    String nomeClienteRodape = 'CLIENTE';
    String cnpjClienteRodape = '';
    String nomeClienteArquivo = 'Cliente';

    final usuariosQuery = await FirebaseFirestore.instance
        .collection('USUARIOS')
        .where('email', isEqualTo: emailCliente.trim())
        .limit(1)
        .get();

    if (usuariosQuery.docs.isNotEmpty) {
      final userData = usuariosQuery.docs.first.data();
      if (userData['display_name'] != null) {
        nomeClienteRodape = userData['display_name'].toString().toUpperCase();
        nomeClienteArquivo = userData['display_name'].toString();
      }
      if (userData['CNPJ'] != null)
        cnpjClienteRodape = userData['CNPJ'].toString();
      else if (userData['cnpj'] != null)
        cnpjClienteRodape = userData['cnpj'].toString();

      String? photoUrl = userData['photo_url']?.toString().trim();
      if (photoUrl != null && photoUrl.startsWith('http')) {
        try {
          final response = await http
              .get(Uri.parse(photoUrl), headers: {'User-Agent': 'Mozilla/5.0'});
          if (response.statusCode == 200)
            imagemCliente = pw.MemoryImage(response.bodyBytes);
        } catch (e) {}
      }
    }

    // ── 2. BUSCAR TODAS AS PREVENTIVAS DO EMAIL ───────────────────────────
    final querySnapshot = await FirebaseFirestore.instance
        .collection('PREVENTIVAS')
        .where('EMAIL', isEqualTo: emailCliente.trim())
        .get();

    if (querySnapshot.docs.isEmpty) {
      return 'Nenhuma preventiva encontrada para este cliente.';
    }

    // ── 3. FILTRAR: UMA POR PATRIMÔNIO + FILTRO DE MÊS/ANO ───────────────
    Map<String, QueryDocumentSnapshot> mapaPreventivas = {};

    for (var doc in querySnapshot.docs) {
      var data = doc.data() as Map<String, dynamic>;
      if (data['DATADAMANUTENCAO'] == null) continue;

      DateTime dataDoc = (data['DATADAMANUTENCAO'] as Timestamp).toDate();
      if (dataDoc.year.toString() != ano) continue;
      if (dataDoc.month != mesNumero) continue;

      String? pat = data['PATRIMONIO']?.toString().trim();
      if (pat != null && pat.isNotEmpty) {
        if (mapaPreventivas.containsKey(pat)) {
          DateTime? dataGuardada;
          try {
            dataGuardada = (mapaPreventivas[pat]!.data()
                    as Map<String, dynamic>)['DATADAMANUTENCAO']
                ?.toDate();
          } catch (e) {}
          if (dataDoc.isAfter(dataGuardada ?? DateTime(1900))) {
            mapaPreventivas[pat] = doc;
          }
        } else {
          mapaPreventivas[pat] = doc;
        }
      }
    }

    List<QueryDocumentSnapshot> listaFinalDocs =
        mapaPreventivas.values.toList();

    if (listaFinalDocs.isEmpty) {
      return 'Não existem relatórios para $mes de $ano.';
    }

    // ── 4. CALCULAR PENDENTES ─────────────────────────────────────────────
    // Busca equipamentos com contrato ativo do cliente
    final equipQuery = await FirebaseFirestore.instance
        .collection('EQUIPAMENTOS_EMPRESA')
        .where('CONTRATO', isEqualTo: true)
        .where('EMAIL', isEqualTo: emailCliente.trim())
        .get();

    // Set dos patrimônios que já têm preventiva no período
    final Set<String> patFeitos = mapaPreventivas.keys
        .map((p) => p.toLowerCase().trim().replaceAll(RegExp(r'\s+'), ' '))
        .toSet();

    // Cruza para achar pendentes
    List<Map<String, dynamic>> listaPendentes = [];
    final Set<String> patConsumido = {};

    for (final doc in equipQuery.docs) {
      final d = doc.data();
      final pat = (d['PATRIMONIO'] ?? '')
          .toString()
          .toLowerCase()
          .trim()
          .replaceAll(RegExp(r'\s+'), ' ');

      if (pat.isNotEmpty &&
          patFeitos.contains(pat) &&
          !patConsumido.contains(pat)) {
        patConsumido.add(pat);
      } else {
        listaPendentes.add(d);
      }
    }

    print(
        'Preventivas: ${listaFinalDocs.length} | Pendentes: ${listaPendentes.length}');

    // ── 5. CRIAR O PDF ────────────────────────────────────────────────────
    final pdf = pw.Document(
      theme: pw.ThemeData.withFont(base: fontRegular, bold: fontBold),
    );

    const tableBorder = pw.TableBorder(
      left: pw.BorderSide(width: 0.9),
      right: pw.BorderSide(width: 0.9),
      top: pw.BorderSide(width: 0.9),
      bottom: pw.BorderSide(width: 0.9),
      horizontalInside: pw.BorderSide(width: 0.9),
      verticalInside: pw.BorderSide(width: 0.9),
    );

    // ── 6. PÁGINAS DE PREVENTIVAS ─────────────────────────────────────────
    for (var doc in listaFinalDocs) {
      final data = doc.data() as Map<String, dynamic>;
      String patrimonioAtual = data['PATRIMONIO']?.toString().trim() ?? '';

      pw.ImageProvider? imagemEvaporadora;
      try {
        final imgQuery = await FirebaseFirestore.instance
            .collection('IMAGENS')
            .where('PATRIMONIO', isEqualTo: patrimonioAtual)
            .limit(1)
            .get();
        if (imgQuery.docs.isNotEmpty) {
          final imgUrl =
              imgQuery.docs.first.data()['IMAGEM']?.toString().trim();
          if (imgUrl != null && imgUrl.startsWith('http')) {
            final resp = await http
                .get(Uri.parse(imgUrl), headers: {'User-Agent': 'Mozilla/5.0'});
            if (resp.statusCode == 200)
              imagemEvaporadora = pw.MemoryImage(resp.bodyBytes);
          }
        }
      } catch (e) {}

      pw.ImageProvider? imagemTermografia;
      List<String> colunasImg = [
        'IMAGEM',
        'THAGEM',
        'TMAGEM',
        'FOTO',
        'foto',
        'imagem'
      ];
      String? urlTermo;
      for (String key in colunasImg) {
        if (data.containsKey(key) &&
            data[key] != null &&
            data[key].toString().trim().isNotEmpty) {
          urlTermo = data[key].toString().trim();
          break;
        }
      }
      if (urlTermo != null && urlTermo.startsWith('http')) {
        try {
          final resp = await http
              .get(Uri.parse(urlTermo), headers: {'User-Agent': 'Mozilla/5.0'});
          if (resp.statusCode == 200)
            imagemTermografia = pw.MemoryImage(resp.bodyBytes);
        } catch (e) {}
      }

      String dataInicio = '';
      if (data['DATADAMANUTENCAO'] != null) {
        final date = (data['DATADAMANUTENCAO'] as Timestamp).toDate();
        dataInicio =
            '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
      }

      String textoObservacao = data['OBSERVACAO']?.toString().trim() ?? '';

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.all(20),
          build: (context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // CABEÇALHO
                pw.Container(
                  decoration: pw.BoxDecoration(border: pw.Border.all(width: 1)),
                  padding: pw.EdgeInsets.all(8),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text('FORNECEDOR',
                                style: pw.TextStyle(
                                    fontSize: 10,
                                    fontWeight: pw.FontWeight.bold)),
                            if (logoEmpresa != null) ...[
                              pw.SizedBox(height: 5),
                              pw.Container(
                                  width: 80,
                                  height: 40,
                                  child: pw.Image(logoEmpresa,
                                      fit: pw.BoxFit.contain))
                            ],
                          ]),
                      pw.Column(children: [
                        pw.SizedBox(height: 15),
                        pw.Text('DATA DA MANUTENÇÃO',
                            style: pw.TextStyle(
                                fontSize: 6, fontWeight: pw.FontWeight.bold)),
                        pw.Text(dataInicio, style: pw.TextStyle(fontSize: 9)),
                      ]),
                      pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.end,
                          children: [
                            pw.Text('CLIENTE',
                                style: pw.TextStyle(
                                    fontSize: 10,
                                    fontWeight: pw.FontWeight.bold)),
                            pw.SizedBox(height: 5),
                            if (imagemCliente != null)
                              pw.Container(
                                  width: 50,
                                  height: 50,
                                  child: pw.Image(imagemCliente,
                                      fit: pw.BoxFit.contain))
                            else
                              pw.Container(
                                  width: 50,
                                  height: 50,
                                  decoration: pw.BoxDecoration(
                                      border: pw.Border.all(
                                          color: PdfColors.grey300)),
                                  child: pw.Center(
                                      child: pw.Text('Sem Logo',
                                          style: pw.TextStyle(fontSize: 6)))),
                          ]),
                    ],
                  ),
                ),
                pw.SizedBox(height: 10),

                // IDENTIFICAÇÃO
                pw.Container(
                  decoration:
                      pw.BoxDecoration(border: pw.Border.all(width: 0.5)),
                  child: pw.Column(children: [
                    pw.Container(
                        width: double.infinity,
                        color: PdfColors.grey200,
                        padding: pw.EdgeInsets.symmetric(vertical: 2),
                        child: pw.Center(
                            child: pw.Text('IDENTIFICAÇÃO',
                                style: pw.TextStyle(
                                    fontSize: 9,
                                    fontWeight: pw.FontWeight.bold)))),
                    pw.Divider(height: 1, thickness: 0.5),
                    pw.Table(
                      border: pw.TableBorder.symmetric(
                          inside: pw.BorderSide(width: 0.5)),
                      columnWidths: {
                        0: pw.FixedColumnWidth(70),
                        1: pw.FlexColumnWidth(1),
                        2: pw.FixedColumnWidth(70),
                        3: pw.FlexColumnWidth(1)
                      },
                      children: [
                        _buildIdentRow(
                            'APARELHO:',
                            data['EQUIPAMENTO'] ?? 'AR CONDICIONADO',
                            'VOLTAGEM:',
                            data['TENSAO'] ?? '220 V'),
                        _buildIdentRow('MODELO:', data['MODELO'] ?? 'SPLIT',
                            'GÁS:', data['FLUIDO'] ?? 'R410A'),
                        _buildIdentRow('TIPO:', data['TIPO'] ?? 'INVERTER',
                            'POTÊNCIA:', data['BTUS'] ?? '12K BTUS'),
                        _buildIdentRow('FABRICANTE:', data['MARCA'] ?? 'LG',
                            'PRÉDIO:', 'GERÊNCIA EXPEDIÇÃO'),
                        _buildIdentRow('PATRIMÔNIO:', data['PATRIMONIO'] ?? '',
                            'LOCALIZAÇÃO:', data['SALA'] ?? ''),
                        pw.TableRow(children: [
                          pw.Padding(
                              padding: pw.EdgeInsets.all(3),
                              child: pw.Text('TÉCNICO:',
                                  style: pw.TextStyle(
                                      fontSize: 7,
                                      fontWeight: pw.FontWeight.bold))),
                          pw.Padding(
                              padding: pw.EdgeInsets.all(3),
                              child: pw.Text(data['TECNICORESPONSAVEL'] ?? '',
                                  style: pw.TextStyle(fontSize: 7))),
                          pw.Padding(
                              padding: pw.EdgeInsets.all(3),
                              child: pw.Text('',
                                  style: pw.TextStyle(fontSize: 7))),
                          pw.Padding(
                              padding: pw.EdgeInsets.all(3),
                              child: pw.Text('',
                                  style: pw.TextStyle(fontSize: 7))),
                        ]),
                      ],
                    ),
                  ]),
                ),
                pw.SizedBox(height: 10),

                // Evaporadora e Checklist
                pw.Container(
                  height: 150,
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
                                          padding: pw.EdgeInsets.symmetric(
                                              vertical: 2),
                                          child: pw.Center(
                                              child: pw.Text(
                                                  'IMAGENS DO APARELHO',
                                                  style: pw.TextStyle(
                                                      fontSize: 8,
                                                      fontWeight: pw
                                                          .FontWeight.bold)))),
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
                                      padding:
                                          pw.EdgeInsets.symmetric(vertical: 2),
                                      child: pw.Center(
                                          child: pw.Text(
                                              'CONDIÇÃO E VERIFICAÇÃO',
                                              style: pw.TextStyle(
                                                  fontSize: 8,
                                                  fontWeight:
                                                      pw.FontWeight.bold)))),
                                  pw.Table(border: tableBorder, columnWidths: {
                                    0: pw.FixedColumnWidth(20),
                                    1: pw.FlexColumnWidth(),
                                    2: pw.FixedColumnWidth(30)
                                  }, children: [
                                    _buildCheckRow(
                                        '1',
                                        'LIMPEZA DA EVAPORADORA INTERNA:',
                                        data['LIMPEZADAEVAPORADORA'] ?? false),
                                    _buildCheckRow('2', 'LIMPEZA DO FILTRO:',
                                        data['LAVAGEMDOFILTRO'] ?? false),
                                    _buildCheckRow(
                                        '3',
                                        'LIMPEZA COM BACTERICIDA:',
                                        data['LIMPEZACOMBACTERICIDA'] ?? false),
                                    _buildCheckRow(
                                        '4',
                                        'VERIFICAÇÃO DO CONTROLE E PILHAS:',
                                        true),
                                    _buildCheckRow('5', 'VERIFICAR RUÍDOS:',
                                        data['VERIFICAODERUIDOS'] ?? false),
                                    _buildCheckRow(
                                        '6', 'VERIFICAR MAL CHEIRO:', true),
                                    _buildValueRow(
                                        '7',
                                        'CORRENTE ELÉTRICA (A):',
                                        data['AMPERAGEM']?.toString() ?? ''),
                                    _buildValueRow('8', 'TENSÃO ELÉTRICA (V):',
                                        data['TENSAO']?.toString() ?? ''),
                                  ]),
                                ]))),
                      ]),
                ),
                pw.SizedBox(height: 10),

                // Termografia
                pw.Container(
                  height: 120,
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
                                          padding: pw.EdgeInsets.symmetric(
                                              vertical: 2),
                                          child: pw.Center(
                                              child: pw.Text('TERMOGRAFIA',
                                                  style: pw.TextStyle(
                                                      fontSize: 8,
                                                      fontWeight: pw
                                                          .FontWeight.bold)))),
                                      pw.Divider(height: 1, thickness: 0.5),
                                      pw.Expanded(
                                          child: imagemTermografia != null
                                              ? pw.Image(imagemTermografia,
                                                  fit: pw.BoxFit.cover)
                                              : pw.Center(
                                                  child: pw.Text('0',
                                                      style: pw.TextStyle(
                                                          fontSize: 20,
                                                          fontWeight: pw
                                                              .FontWeight
                                                              .bold)))),
                                    ]))),
                        pw.SizedBox(width: 5),
                        pw.Expanded(
                            flex: 6,
                            child: pw.Container(
                                decoration: pw.BoxDecoration(
                                    border: pw.Border.all(width: 0.5)),
                                child: pw.Column(children: [
                                  pw.Table(border: tableBorder, columnWidths: {
                                    0: pw.FixedColumnWidth(20),
                                    1: pw.FlexColumnWidth(),
                                    2: pw.FixedColumnWidth(30)
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
                                        data['VERIFICAODOISOLAMENTOTRMICO'] ??
                                            false),
                                  ]),
                                ]))),
                      ]),
                ),
                pw.SizedBox(height: 10),

                // Itens Adicionais
                pw.Container(
                  decoration:
                      pw.BoxDecoration(border: pw.Border.all(width: 0.5)),
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
                    _buildCheckRow('1', 'JATEAMENTO DA CONDENSADORA:',
                        data['JATEAMENTODACONDENSADOR'] ?? false),
                    _buildCheckRow('2', 'JATEAMENTO DA EVAPORADORA:',
                        data['JATEAMENTODAEVAPORADORA'] ?? false),
                    _buildCheckRow('3', 'LAVAGEM DO DRENO:',
                        data['LAVAGEMDODRENO'] ?? false),
                    _buildCheckRow('4', 'LAVAGEM DA CARCAÇA EVAPORADORA:',
                        data['LAVAGEMDACARCAAEVAPORADORA'] ?? false),
                    _buildCheckRow(
                        '5',
                        'LAVAGEM DA CARCAÇA CONDENSADORA:',
                        data['LAVAGEMDACARCAACONDENSADORA'] ??
                            data['LAVAGEMDACARCAACONDENSADOR'] ??
                            false),
                    _buildCheckRow(
                        '6',
                        'LIMPEZA E LUBRIFICAÇÃO DO COMPRESSOR:',
                        data['LIMPEZAELUBRIFICAODOCOMPRESSOR'] ??
                            data['LIMPEZAELUBRIFICAODOCOMPRESS'] ??
                            false),
                    _buildCheckRow('7', 'LAVAGEM DA TURBINA EVAPORADORA:',
                        data['LAVAGEMDATURBINA'] ?? false),
                    _buildCheckRow('8', 'VERIFICAR PÉS DE BORRACHA:',
                        data['VERIFICAODOSACABAMENTOS'] ?? false),
                  ]),
                ),
                pw.SizedBox(height: 10),

                // Diagnóstico
                pw.Container(
                  width: double.infinity,
                  decoration: pw.BoxDecoration(
                      border:
                          pw.Border.all(color: PdfColors.black, width: 0.5)),
                  padding: pw.EdgeInsets.all(5),
                  child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('INFORMAÇÕES ADICIONAIS',
                            style: pw.TextStyle(
                                fontSize: 8, fontWeight: pw.FontWeight.bold)),
                        pw.SizedBox(height: 2),
                        if (textoObservacao.isNotEmpty)
                          pw.Text(textoObservacao,
                              style: pw.TextStyle(fontSize: 7))
                        else
                          pw.SizedBox(height: 10),
                      ]),
                ),
                pw.Spacer(),

                // Rodapé
                pw.Container(
                  padding: pw.EdgeInsets.only(top: 5),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.center,
                          children: [
                            if (assinaturaHPS != null)
                              pw.Container(
                                  width: 150,
                                  height: 70,
                                  child: pw.Image(assinaturaHPS,
                                      fit: pw.BoxFit.contain))
                            else
                              pw.SizedBox(height: 40),
                            pw.Container(
                                width: 150,
                                height: 0.5,
                                color: PdfColors.black),
                            pw.SizedBox(height: 2),
                            pw.Text('HPS REFRIGERAÇÃO',
                                style: pw.TextStyle(
                                    fontSize: 8,
                                    fontWeight: pw.FontWeight.bold)),
                            pw.Text('CNPJ: 28.340.152/0001-52',
                                style: pw.TextStyle(fontSize: 7)),
                          ]),
                      pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.center,
                          children: [
                            pw.Container(
                                width: 150,
                                height: 0.5,
                                color: PdfColors.black),
                            pw.SizedBox(height: 5),
                            pw.Text(
                                nomeClienteRodape.isNotEmpty
                                    ? nomeClienteRodape
                                    : 'CLIENTE',
                                style: pw.TextStyle(
                                    fontSize: 8,
                                    fontWeight: pw.FontWeight.bold)),
                            if (cnpjClienteRodape.isNotEmpty)
                              pw.Text('CNPJ: $cnpjClienteRodape',
                                  style: pw.TextStyle(fontSize: 7)),
                          ]),
                    ],
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Center(
                    child: pw.Text(
                        'Tel: (77) 98819-4630 / 98861-2447  -  www.hpsrefri.com.br',
                        style: pw.TextStyle(fontSize: 7))),
              ],
            );
          },
        ),
      );
    }

    // ── 7. PÁGINA DE PENDÊNCIAS (no final do PDF) ─────────────────────────
    if (listaPendentes.isNotEmpty) {
      final now = DateTime.now();
      final dataGeracao =
          '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.all(20),
          header: (ctx) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Imagem topo preenchendo toda a largura
              if (imgTopoPendentes != null) ...[
                pw.Container(
                  width: double.infinity,
                  height: 235,
                  child: pw.Image(imgTopoPendentes, fit: pw.BoxFit.fill),
                ),
                pw.SizedBox(height: 8),
              ],

              // Cabeçalho info
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('RELATÓRIO DE PENDÊNCIAS',
                            style: pw.TextStyle(
                                fontSize: 14,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.red700)),
                        if (nomeClienteRodape.isNotEmpty)
                          pw.Text(nomeClienteRodape,
                              style: pw.TextStyle(
                                  fontSize: 9, color: PdfColors.grey700)),
                        pw.Text('Período: $mes / $ano',
                            style: pw.TextStyle(
                                fontSize: 9, color: PdfColors.grey700)),
                      ]),
                  pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                            '${listaPendentes.length} equipamento${listaPendentes.length != 1 ? 's' : ''} pendente${listaPendentes.length != 1 ? 's' : ''}',
                            style: pw.TextStyle(
                                fontSize: 10,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.red700)),
                        pw.Text('Gerado em: $dataGeracao',
                            style: pw.TextStyle(
                                fontSize: 8, color: PdfColors.grey600)),
                      ]),
                ],
              ),
              pw.SizedBox(height: 6),
              pw.Divider(thickness: 1, color: PdfColors.red200),
              pw.SizedBox(height: 4),

              // Cabeçalho da tabela
              pw.Container(
                color: PdfColors.red700,
                padding: pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
                child: pw.Row(children: [
                  pw.Expanded(
                      flex: 1,
                      child: pw.Text('#',
                          style: pw.TextStyle(
                              fontSize: 8,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.white))),
                  pw.Expanded(
                      flex: 4,
                      child: pw.Text('EQUIPAMENTO',
                          style: pw.TextStyle(
                              fontSize: 8,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.white))),
                  pw.Expanded(
                      flex: 3,
                      child: pw.Text('MODELO',
                          style: pw.TextStyle(
                              fontSize: 8,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.white))),
                  pw.Expanded(
                      flex: 3,
                      child: pw.Text('LOCALIZAÇÃO',
                          style: pw.TextStyle(
                              fontSize: 8,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.white))),
                  pw.Expanded(
                      flex: 2,
                      child: pw.Text('PATRIMÔNIO',
                          style: pw.TextStyle(
                              fontSize: 8,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.white))),
                  pw.Expanded(
                      flex: 2,
                      child: pw.Text('SETOR',
                          style: pw.TextStyle(
                              fontSize: 8,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.white))),
                ]),
              ),
            ],
          ),
          build: (ctx) => [
            // Linhas da tabela de pendentes
            pw.Table(
              border: pw.TableBorder(
                left: pw.BorderSide(width: 0.5, color: PdfColors.grey300),
                right: pw.BorderSide(width: 0.5, color: PdfColors.grey300),
                bottom: pw.BorderSide(width: 0.5, color: PdfColors.grey300),
                horizontalInside:
                    pw.BorderSide(width: 0.5, color: PdfColors.grey200),
                verticalInside:
                    pw.BorderSide(width: 0.5, color: PdfColors.grey200),
              ),
              columnWidths: {
                0: const pw.FlexColumnWidth(1),
                1: const pw.FlexColumnWidth(4),
                2: const pw.FlexColumnWidth(3),
                3: const pw.FlexColumnWidth(3),
                4: const pw.FlexColumnWidth(2),
                5: const pw.FlexColumnWidth(2),
              },
              children: listaPendentes.asMap().entries.map((entry) {
                final i = entry.key;
                final item = entry.value;
                final isEven = i % 2 == 0;
                return pw.TableRow(
                  decoration: pw.BoxDecoration(
                      color: isEven ? PdfColors.grey50 : PdfColors.white),
                  children: [
                    pw.Padding(
                        padding: pw.EdgeInsets.all(4),
                        child: pw.Text('${i + 1}',
                            style: pw.TextStyle(
                                fontSize: 7, color: PdfColors.grey600))),
                    pw.Padding(
                        padding: pw.EdgeInsets.all(4),
                        child: pw.Text(item['EQUIPAMENTO']?.toString() ?? '-',
                            style: pw.TextStyle(
                                fontSize: 7, fontWeight: pw.FontWeight.bold))),
                    pw.Padding(
                        padding: pw.EdgeInsets.all(4),
                        child: pw.Text(item['MODELO']?.toString() ?? '-',
                            style: pw.TextStyle(fontSize: 7))),
                    pw.Padding(
                        padding: pw.EdgeInsets.all(4),
                        child: pw.Text(item['SALA']?.toString() ?? '-',
                            style: pw.TextStyle(fontSize: 7))),
                    pw.Padding(
                        padding: pw.EdgeInsets.all(4),
                        child: pw.Text(item['PATRIMONIO']?.toString() ?? '-',
                            style: pw.TextStyle(
                                fontSize: 7,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.red700))),
                    pw.Padding(
                        padding: pw.EdgeInsets.all(4),
                        child: pw.Text(item['SETOR']?.toString() ?? '-',
                            style: pw.TextStyle(fontSize: 7))),
                  ],
                );
              }).toList(),
            ),

            pw.SizedBox(height: 16),

            // Totalizador
            pw.Container(
              padding: pw.EdgeInsets.all(8),
              decoration: pw.BoxDecoration(
                  color: PdfColors.red50,
                  border: pw.Border.all(color: PdfColors.red200, width: 0.5)),
              child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                        'Total de equipamentos sem preventiva em $mes/$ano:',
                        style: pw.TextStyle(
                            fontSize: 8, fontWeight: pw.FontWeight.bold)),
                    pw.Text(
                        '${listaPendentes.length} equipamento${listaPendentes.length != 1 ? 's' : ''}',
                        style: pw.TextStyle(
                            fontSize: 8,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.red700)),
                  ]),
            ),
          ],
        ),
      );
    }

    // ── 8. UPLOAD + EMAIL ─────────────────────────────────────────────────
    final pdfBytes = await pdf.save();

    String nomeArquivoLimpo =
        nomeClienteArquivo.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
    final fileName = 'Relatorio_Geral_${nomeArquivoLimpo}.pdf';
    final pastaEmail = emailCliente.trim();
    final storagePath = '$pastaEmail/$ano/$mes/$fileName';

    final ref =
        firebase_storage.FirebaseStorage.instance.ref().child(storagePath);
    final metadata =
        firebase_storage.SettableMetadata(contentType: 'application/pdf');

    await ref.putData(pdfBytes, metadata);
    String downloadLink = await ref.getDownloadURL();

    bool emailEnviado = await _dispararEmailComLink(
        emailDestinatario, downloadLink, nomeClienteArquivo, mes, ano);

    await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdfBytes);

    if (emailEnviado) {
      return 'Sucesso! Relatório enviado para $emailDestinatario.';
    } else {
      return 'Relatório gerado, mas houve falha no envio do email.';
    }
  } catch (e) {
    print('Erro CRÍTICO: $e');
    return 'Erro interno: $e';
  }
}

// ── EMAIL ─────────────────────────────────────────────────────────────────
Future<bool> _dispararEmailComLink(
  String toEmail,
  String linkPdf,
  String nomeCliente,
  String? mes,
  String? ano,
) async {
  const String apiKey =
      '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';

  final Uri url = Uri.parse('https://api.brevo.com/v3/smtp/email');

  final String htmlBody = '''
<!DOCTYPE html>
<html lang="pt-BR">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<style>
  body, table, td, a { -webkit-text-size-adjust: 100%; -ms-text-size-adjust: 100%; }
  table, td { mso-table-lspace: 0pt; mso-table-rspace: 0pt; }
  img { -ms-interpolation-mode: bicubic; border: 0; height: auto; line-height: 100%; outline: none; text-decoration: none; }
  table { border-collapse: collapse !important; }
  body { height: 100% !important; margin: 0 !important; padding: 0 !important; width: 100% !important; }
</style>
</head>
<body style="margin: 0; padding: 0; background-color: #f4f4f4;">
  <table border="0" cellpadding="0" cellspacing="0" width="100%">
    <tr>
      <td bgcolor="#f4f4f4" align="center" style="padding: 10px;">
        <table border="0" cellpadding="0" cellspacing="0" width="100%" style="max-width: 600px; background-color: #ffffff; border-radius: 8px; overflow: hidden; box-shadow: 0 2px 5px rgba(0,0,0,0.1);">
          <tr>
            <td align="center" style="padding: 0;">
              <img src="https://firebasestorage.googleapis.com/v0/b/h-p-s-modificado-emdcp0.appspot.com/o/logo%20email%20(1)%20(1)%20(1)%20(1).png?alt=media&token=5c018b59-c7be-4a7d-9736-f7d51f38d25e" alt="HPS" style="display: block; width: 100%; max-width: 100%; height: auto;" />
            </td>
          </tr>
          <tr>
            <td align="center" style="padding: 30px 20px; color: #333333; font-family: Arial, sans-serif;">
              <h2 style="color: #0056b3; margin-top: 0; font-size: 24px;">Relatório Disponível</h2>
              <p style="font-size: 16px; line-height: 1.5; margin-bottom: 25px; text-align: center;">
                Olá, <strong>$nomeCliente</strong>.<br><br>
                O relatório completo referente a <strong>$mes de $ano</strong> já está pronto para download.
              </p>
              <table border="0" cellspacing="0" cellpadding="0">
                <tr>
                  <td align="center" style="border-radius: 5px;" bgcolor="#28a745">
                    <a href="$linkPdf" target="_blank" style="font-size: 16px; font-family: Helvetica, Arial, sans-serif; color: #ffffff; text-decoration: none; padding: 15px 30px; border-radius: 5px; border: 1px solid #28a745; display: inline-block; font-weight: bold;">
                      BAIXAR RELATÓRIO
                    </a>
                  </td>
                </tr>
              </table>
              <p style="font-size: 13px; color: #666666; margin-top: 30px; word-break: break-all;">
                Se o botão não funcionar, copie o link abaixo:<br>
                <a href="$linkPdf" style="color: #0056b3;">$linkPdf</a>
              </p>
            </td>
          </tr>
          <tr>
            <td bgcolor="#eeeeee" align="center" style="padding: 15px; font-family: Arial, sans-serif; font-size: 12px; color: #777777;">
              &copy; 2026 HPS Refrigeração
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
    "sender": {"name": "Hps Refrigeração", "email": "equipe@hpsrefri.com.br"},
    "to": [
      {"email": toEmail}
    ],
    "subject": "Relatório de Manutenção - $mes/$ano",
    "htmlContent": htmlBody,
  };

  try {
    final response = await http.post(url,
        headers: {'Content-Type': 'application/json', 'api-key': apiKey},
        body: jsonEncode(body));
    return (response.statusCode == 200 || response.statusCode == 201);
  } catch (e) {
    return false;
  }
}

// ── HELPERS ───────────────────────────────────────────────────────────────
pw.TableRow _buildIdentRow(
    String label1, String value1, String label2, String value2) {
  return pw.TableRow(children: [
    pw.Padding(
        padding: pw.EdgeInsets.all(3),
        child: pw.Text(label1,
            style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold))),
    pw.Padding(
        padding: pw.EdgeInsets.all(3),
        child: pw.Text(value1, style: pw.TextStyle(fontSize: 7))),
    pw.Padding(
        padding: pw.EdgeInsets.all(3),
        child: pw.Text(label2,
            style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold))),
    pw.Padding(
        padding: pw.EdgeInsets.all(3),
        child: pw.Text(value2, style: pw.TextStyle(fontSize: 7))),
  ]);
}

pw.TableRow _buildCheckRow(String num, String label, bool checked) {
  return pw.TableRow(children: [
    pw.Padding(
        padding: pw.EdgeInsets.all(2),
        child:
            pw.Center(child: pw.Text(num, style: pw.TextStyle(fontSize: 7)))),
    pw.Padding(
        padding: pw.EdgeInsets.all(2),
        child: pw.Text(label, style: pw.TextStyle(fontSize: 7))),
    pw.Padding(
        padding: pw.EdgeInsets.all(2),
        child: pw.Center(
            child: pw.Text(checked ? 'OK' : '',
                style: pw.TextStyle(
                    fontSize: 7, fontWeight: pw.FontWeight.bold)))),
  ]);
}

pw.TableRow _buildValueRow(String num, String label, String value) {
  return pw.TableRow(children: [
    pw.Padding(
        padding: pw.EdgeInsets.all(2),
        child:
            pw.Center(child: pw.Text(num, style: pw.TextStyle(fontSize: 7)))),
    pw.Padding(
        padding: pw.EdgeInsets.all(2),
        child: pw.Text(label, style: pw.TextStyle(fontSize: 7))),
    pw.Padding(
        padding: pw.EdgeInsets.all(2),
        child: pw.Center(
            child: pw.Text(value,
                style: pw.TextStyle(
                    fontSize: 7, fontWeight: pw.FontWeight.bold)))),
  ]);
}
