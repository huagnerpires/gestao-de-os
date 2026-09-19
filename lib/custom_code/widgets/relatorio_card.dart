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

import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Garante formatação de data

// IMPORTS NECESSÁRIOS PARA O PDF
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class RelatorioCard extends StatefulWidget {
  const RelatorioCard({
    Key? key,
    this.width,
    this.height,
    required this.email,
    this.mes,
    this.ano,
  }) : super(key: key);

  final double? width;
  final double? height;
  final String email;
  final String? mes;
  final String? ano;

  @override
  _RelatorioCardState createState() => _RelatorioCardState();
}

class _RelatorioCardState extends State<RelatorioCard> {
  // --- NOVAS VARIÁVEIS PARA A TELA DE SELEÇÃO ---
  bool _relatorioGerado = false;
  String? _emailSelecionado;
  List<String> _listaEmails = [];
  bool _carregandoEmails = true;

  String? _filtroMes;
  String? _filtroAno;
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  // Cor principal do PDF (Teal do FlutterFlow)
  final PdfColor _baseColor = PdfColor.fromInt(0xFF0F766E);
  final PdfColor _textColor = PdfColors.blueGrey900;

  final List<String> _listaMeses = [
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
    'DEZEMBRO'
  ];

  @override
  void initState() {
    super.initState();

    _emailSelecionado = widget.email.isNotEmpty ? widget.email : null;

    // Configura o MÊS
    if (widget.mes != null && widget.mes!.isNotEmpty) {
      _filtroMes = widget.mes;
    } else {
      _filtroMes = _listaMeses[DateTime.now().month - 1];
    }

    // Configura o ANO
    if (widget.ano != null && widget.ano!.isNotEmpty) {
      _filtroAno = widget.ano;
    } else {
      _filtroAno = DateTime.now().year.toString();
    }

    // Busca os e-mails disponíveis no banco de dados
    _fetchEmails();
  }

  Future<void> _fetchEmails() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('CORRETIVAS').get();
      final Set<String> emails = {};

      for (var doc in snapshot.docs) {
        final data = doc.data();
        if (data['EMAIL'] != null &&
            data['EMAIL'].toString().trim().isNotEmpty) {
          emails.add(data['EMAIL'].toString().trim());
        }
      }

      if (mounted) {
        setState(() {
          _listaEmails = emails.toList()..sort();
          _carregandoEmails = false;
          // Se não houver email passado, seleciona o primeiro da lista
          if (_emailSelecionado == null && _listaEmails.isNotEmpty) {
            _emailSelecionado = _listaEmails.first;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _carregandoEmails = false);
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<BoxShadow> getElevationShadow(bool isDark) => [
        BoxShadow(
          color: Colors.black.withOpacity(isDark ? 0.3 : 0.15),
          blurRadius: 4,
          offset: const Offset(0, 2),
          spreadRadius: 0,
        )
      ];

  double _calcularValorItem(dynamic rawVal) {
    double valor = 0.0;
    if (rawVal is List) {
      for (var item in rawVal) {
        if (item is num)
          valor += item.toDouble();
        else if (item is String) valor += double.tryParse(item) ?? 0.0;
      }
    } else if (rawVal is num) {
      valor = rawVal.toDouble();
    } else if (rawVal is String) {
      valor = double.tryParse(rawVal) ?? 0.0;
    }
    return valor;
  }

  // --- FUNÇÃO DE GERAÇÃO E COMPARTILHAMENTO DE PDF ---
  Future<void> _generatePdf(List<QueryDocumentSnapshot> docs) async {
    final pdf = pw.Document();
    final fontRegular = await PdfGoogleFonts.openSansRegular();
    final fontBold = await PdfGoogleFonts.openSansBold();
    final fontItalic = await PdfGoogleFonts.openSansItalic();

    Map<String, List<Map<String, dynamic>>> itensPorSetor = {};
    double totalGeral = 0.0;

    for (var doc in docs) {
      var data = doc.data() as Map<String, dynamic>;
      String setor = data['SETOR']?.toString().toUpperCase() ?? 'GERAL';
      double valorDoc = _calcularValorItem(data['VALOR']);

      if (!itensPorSetor.containsKey(setor)) {
        itensPorSetor[setor] = [];
      }
      itensPorSetor[setor]!.add(data);
      totalGeral += valorDoc;
    }

    var setoresOrdenados = itensPorSetor.keys.toList()..sort();
    final now = DateTime.now();
    final String dataImpressao = DateFormat('dd/MM/yyyy').format(now);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(vertical: 30, horizontal: 30),
        theme: pw.ThemeData.withFont(
          base: fontRegular,
          bold: fontBold,
          italic: fontItalic,
        ),
        header: (context) => _buildPdfHeader(dataImpressao),
        footer: (context) => _buildPdfFooter(context, totalGeral),
        build: (pw.Context context) {
          return [
            pw.SizedBox(height: 10),
            pw.Container(
              padding:
                  const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 10),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: pw.BorderRadius.circular(4),
                border: pw.Border.all(color: PdfColors.grey300),
              ),
              child: pw.Row(
                mainAxisSize: pw.MainAxisSize.min,
                children: [
                  pw.Text("Filtros Aplicados: ",
                      style: pw.TextStyle(
                          color: _textColor,
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 10)),
                  pw.Text(
                      "Ano: ${_filtroAno ?? 'Todos'}  •  Mês: ${_filtroMes ?? 'Todos'}",
                      style: pw.TextStyle(color: _textColor, fontSize: 10)),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
            ...setoresOrdenados.map((setor) {
              List<Map<String, dynamic>> lista = itensPorSetor[setor]!;
              double totalSetor = 0.0;
              for (var data in lista) {
                totalSetor += _calcularValorItem(data['VALOR']);
              }

              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Container(
                    width: double.infinity,
                    padding: const pw.EdgeInsets.symmetric(
                        vertical: 6, horizontal: 8),
                    decoration: pw.BoxDecoration(
                        color: _baseColor,
                        borderRadius: const pw.BorderRadius.only(
                          topLeft: pw.Radius.circular(4),
                          topRight: pw.Radius.circular(4),
                        )),
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text("SETOR: $setor",
                            style: pw.TextStyle(
                                color: PdfColors.white,
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 12)),
                        pw.Text(
                            "Subtotal: R\$ ${totalSetor.toStringAsFixed(2).replaceAll('.', ',')}",
                            style: pw.TextStyle(
                                color: PdfColors.white,
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 12)),
                      ],
                    ),
                  ),
                  pw.Table(
                    border: pw.TableBorder(
                      verticalInside: pw.BorderSide.none,
                      horizontalInside:
                          pw.BorderSide(color: PdfColors.grey300, width: 0.5),
                      bottom:
                          pw.BorderSide(color: PdfColors.grey300, width: 0.5),
                      left: pw.BorderSide(color: PdfColors.grey300, width: 0.5),
                      right:
                          pw.BorderSide(color: PdfColors.grey300, width: 0.5),
                    ),
                    columnWidths: {
                      0: const pw.FixedColumnWidth(85),
                      1: const pw.FixedColumnWidth(110),
                      2: const pw.FlexColumnWidth(),
                      3: const pw.FixedColumnWidth(80),
                    },
                    children: [
                      pw.TableRow(
                        decoration: pw.BoxDecoration(color: PdfColors.grey50),
                        children: [
                          _buildTh("OS / DATA"),
                          _buildTh("LOCAL / EQUIP."),
                          _buildTh("DETALHAMENTO (PEÇAS E SERVIÇOS)"),
                          _buildTh("VALOR", align: pw.TextAlign.right),
                        ],
                      ),
                      ...lista.map((data) => _buildTableRow(data)).toList(),
                    ],
                  ),
                  pw.SizedBox(height: 20),
                ],
              );
            }).toList(),
          ];
        },
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'Relatorio_Financeiro_Manutencao.pdf',
    );
  }

  // --- CABEÇALHO DO PDF (HPS REFRIGERAÇÃO) ---
  pw.Widget _buildPdfHeader(String dataImpressao) {
    return pw.Column(
      children: [
        // BLOCO DO CLIENTE (TOPO)
        pw.Center(
          child: pw.Column(
            mainAxisSize: pw.MainAxisSize.min,
            children: [
              pw.Text("HPS REFRIGERAÇÃO",
                  style: pw.TextStyle(
                    color: PdfColors.blue800, // Azul Destaque
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  )),
              pw.SizedBox(height: 4),
              pw.Text(
                "AV. Pará 486 - Ibirapuera, Vitória da Conquista - BA",
                style: pw.TextStyle(color: PdfColors.black, fontSize: 11),
              ),
              pw.Text(
                "Tel: 77 98819-4630 ou 98861-2447",
                style: pw.TextStyle(color: PdfColors.black, fontSize: 11),
              ),
            ],
          ),
        ),
        pw.SizedBox(height: 20),
        // BLOCO ORIGINAL DO RELATÓRIO
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text("RELATÓRIO FINANCEIRO",
                    style: pw.TextStyle(
                        color: _baseColor,
                        fontSize: 20,
                        fontWeight: pw.FontWeight.bold)),
                pw.Text("Detalhamento de Manutenção Corretiva",
                    style:
                        pw.TextStyle(color: PdfColors.grey700, fontSize: 12)),
              ],
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text("Data de Emissão",
                    style: pw.TextStyle(color: PdfColors.grey600, fontSize: 8)),
                pw.Text(dataImpressao,
                    style: pw.TextStyle(
                        color: _textColor,
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 10)),
              ],
            )
          ],
        ),
        pw.SizedBox(height: 10),
        pw.Divider(color: _baseColor, thickness: 2),
        pw.SizedBox(height: 10),
      ],
    );
  }

  pw.Widget _buildPdfFooter(pw.Context context, double totalGeral) {
    return pw.Column(
      children: [
        pw.Divider(color: PdfColors.grey400),
        pw.Container(
          padding: const pw.EdgeInsets.only(top: 10),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                "Página ${context.pageNumber} de ${context.pagesCount}",
                style:
                    const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
              ),
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text("TOTAL GERAL: ",
                      style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                          color: _textColor)),
                  pw.Text(
                    "R\$ ${totalGeral.toStringAsFixed(2).replaceAll('.', ',')}",
                    style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                        color: _baseColor),
                  ),
                ],
              ),
            ],
          ),
        )
      ],
    );
  }

  pw.Widget _buildTh(String text, {pw.TextAlign align = pw.TextAlign.left}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 6),
      child: pw.Text(text,
          textAlign: align,
          style: pw.TextStyle(
              color: PdfColors.grey700,
              fontSize: 9,
              fontWeight: pw.FontWeight.bold)),
    );
  }

  pw.TableRow _buildTableRow(Map<String, dynamic> data) {
    double valTotalItem = _calcularValorItem(data['VALOR']);
    String sala = data['SALA']?.toString() ?? '-';
    String equip = data['EQUIPAMENTO']?.toString() ?? '-';
    String os = data['NUMERO_OS']?.toString() ?? data['OS']?.toString() ?? '-';
    String dataTermino = data['DATA_TERMINO']?.toString() ?? '-';
    String defeito = data['DEFEITO']?.toString() ?? '';

    String servicoRealizado = data['SERVICOREALIZADO']?.toString() ??
        data['DESCRICAODOSERVICO']?.toString() ??
        '';

    var rawPecas = data['PECAS'] ?? data['pecas'];
    List<String> listaPecas = [];
    if (rawPecas is List) {
      listaPecas = List.from(rawPecas).map((e) => e.toString()).toList();
    } else if (rawPecas != null) {
      listaPecas.add(rawPecas.toString());
    }

    List<double> listaValoresInd = [];
    if (data['VALOR'] is List) {
      for (var item in data['VALOR']) {
        if (item is num)
          listaValoresInd.add(item.toDouble());
        else if (item is String)
          listaValoresInd.add(double.tryParse(item) ?? 0.0);
      }
    } else {
      listaValoresInd.add(_calcularValorItem(data['VALOR']));
    }

    final detalhamentoWidget = pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        if (defeito.isNotEmpty)
          pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 4),
            child: pw.Text("Defeito: $defeito",
                style: pw.TextStyle(
                    fontSize: 9,
                    color: PdfColors.red800,
                    fontWeight: pw.FontWeight.bold)),
          ),
        ...List.generate(listaPecas.length, (index) {
          String nomePeca = listaPecas[index];
          double valPeca =
              (index < listaValoresInd.length) ? listaValoresInd[index] : 0.0;
          return pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 2),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Expanded(
                  child: pw.Text("• $nomePeca",
                      style: const pw.TextStyle(
                          fontSize: 9, color: PdfColors.grey800)),
                ),
                pw.SizedBox(width: 8),
                pw.Text(
                    "R\$ ${valPeca.toStringAsFixed(2).replaceAll('.', ',')}",
                    style: const pw.TextStyle(
                        fontSize: 9, color: PdfColors.black)),
              ],
            ),
          );
        }),
        if (listaPecas.isEmpty)
          if (servicoRealizado.isNotEmpty)
            pw.Text("• $servicoRealizado",
                style:
                    const pw.TextStyle(fontSize: 9, color: PdfColors.grey700))
          else
            pw.Text("Serviço Geral",
                style:
                    const pw.TextStyle(fontSize: 8, color: PdfColors.grey500))
      ],
    );

    return pw.TableRow(
      verticalAlignment: pw.TableCellVerticalAlignment.top,
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(6),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text("OS: $os",
                  style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold, fontSize: 10)),
              pw.Text(dataTermino,
                  style: const pw.TextStyle(
                      fontSize: 9, color: PdfColors.grey700)),
            ],
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(6),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(sala,
                  style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold, fontSize: 9)),
              pw.SizedBox(height: 2),
              pw.Text(equip,
                  style: const pw.TextStyle(
                      fontSize: 8, color: PdfColors.grey600)),
            ],
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(6),
          child: detalhamentoWidget,
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(6),
          child: pw.Text(
            "R\$ ${valTotalItem.toStringAsFixed(2).replaceAll('.', ',')}",
            textAlign: pw.TextAlign.right,
            style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
          ),
        ),
      ],
    );
  }

  void _showDetalhesPopup(BuildContext context, Map<String, dynamic> data) {
    final theme = FlutterFlowTheme.of(context);
    double screenWidth = MediaQuery.of(context).size.width;
    bool isWeb = screenWidth > 800;
    double popupWidth = isWeb ? 500 : double.maxFinite;
    double imageHeight = isWeb ? 350 : 200;

    double valorNumericoTotal = _calcularValorItem(data['VALOR']);
    String valorTotalFmt =
        "R\$ ${valorNumericoTotal.toStringAsFixed(2).replaceAll('.', ',')}";
    String dataManutencao = "";

    if (data['DATADAMANUTENCAO'] is Timestamp) {
      DateTime dt = (data['DATADAMANUTENCAO'] as Timestamp).toDate();
      dataManutencao = "${dt.day}/${dt.month}/${dt.year}";
    } else {
      dataManutencao = data['DATADAMANUTENCAO']?.toString() ?? "N/A";
    }

    String patrimonio = data['PATRIMONIO']?.toString() ?? "";
    var rawPecas = data['PECAS'] ?? data['pecas'];
    List<String> listaPecas = [];

    if (rawPecas is List) {
      listaPecas = List.from(rawPecas).map((e) => e.toString()).toList();
    } else if (rawPecas != null) {
      listaPecas.add(rawPecas.toString());
    }

    List<double> listaValoresIndividuais = [];
    if (data['VALOR'] is List) {
      for (var item in data['VALOR']) {
        if (item is num)
          listaValoresIndividuais.add(item.toDouble());
        else if (item is String)
          listaValoresIndividuais.add(double.tryParse(item) ?? 0.0);
      }
    } else {
      listaValoresIndividuais.add(_calcularValorItem(data['VALOR']));
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: theme.secondaryBackground,
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 24),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          titlePadding: EdgeInsets.zero,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          title: Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFF0F766E),
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16), topRight: Radius.circular(16)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                    child: Text("Detalhes da Manutenção",
                        style: GoogleFonts.inter(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16))),
                InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(Icons.close, color: Colors.white))
              ],
            ),
          ),
          content: Container(
            width: popupWidth,
            constraints: const BoxConstraints(maxHeight: 700),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (patrimonio.isNotEmpty)
                    FutureBuilder<QuerySnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('IMAGENS')
                          .where('PATRIMONIO', isEqualTo: patrimonio)
                          .limit(1)
                          .get(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting)
                          return Center(
                              child: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: CircularProgressIndicator(
                                      color: Color(0xFF0F766E))));

                        if (snapshot.hasData &&
                            snapshot.data!.docs.isNotEmpty) {
                          var docImagem = snapshot.data!.docs.first.data()
                              as Map<String, dynamic>;
                          String? urlImagem = docImagem['IMAGEM']?.toString();

                          if (urlImagem != null && urlImagem.isNotEmpty) {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              height: imageHeight,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: theme.alternate,
                                  image: DecorationImage(
                                      image: NetworkImage(urlImagem),
                                      fit: BoxFit.cover)),
                            );
                          }
                        }
                        return SizedBox.shrink();
                      },
                    ),
                  if (valorNumericoTotal == 0)
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: const Color(0xFFE0F2F1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: const Color(0xFF0F766E), width: 1)),
                      child: Row(children: [
                        Icon(Icons.check_circle,
                            color: const Color(0xFF00695C), size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                            child: Text("SERVIÇO COBERTO PELO CONTRATO",
                                style: GoogleFonts.inter(
                                    color: const Color(0xFF00695C),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11)))
                      ]),
                    ),
                  _buildPopupRow(context, "Nº OS",
                      data['NUMERO_OS'] ?? data['OS'] ?? "S/N"),
                  _buildPopupRow(context, "Status", data['STATUS'] ?? "N/A"),
                  Divider(color: theme.alternate, height: 16),
                  _buildPopupRow(context, "Setor", data['SETOR'] ?? "N/A"),
                  _buildPopupRow(
                      context, "Sala / Local", data['SALA'] ?? "N/A"),
                  Divider(color: theme.alternate, height: 16),
                  _buildPopupRow(
                      context, "Equipamento", data['EQUIPAMENTO'] ?? "N/A"),
                  _buildPopupRow(context, "Marca", data['MARCA'] ?? "N/A"),
                  _buildPopupRow(context, "Modelo", data['MODELO'] ?? "N/A"),
                  _buildPopupRow(
                      context, "Patrimônio", data['PATRIMONIO'] ?? "N/A"),
                  _buildPopupRow(
                      context, "BTUs/Potência", data['BTUS'] ?? "N/A"),
                  _buildPopupRow(context, "Fluido", data['FLUIDO'] ?? "N/A"),
                  Divider(color: theme.alternate, height: 16),
                  _buildPopupRow(context, "Data Manutenção", dataManutencao),
                  _buildPopupRow(
                      context, "Data Término", data['DATA_TERMINO'] ?? "N/A"),
                  _buildPopupRow(
                      context, "Mês/Ano", "${data['MES']} / ${data['ANO']}"),
                  _buildPopupRow(
                      context, "Técnico", data['TECNICORESPONSAVEL'] ?? "N/A"),
                  Divider(color: theme.alternate, height: 16),
                  _buildPopupRow(
                      context, "Defeito Relatado", data['DEFEITO'] ?? "N/A"),
                  _buildPopupRow(context, "Serviço Realizado",
                      data['SERVICOREALIZADO'] ?? "N/A"),
                  _buildPopupRow(context, "Descrição Detalhada",
                      data['DESCRICAODOSERVICO'] ?? "N/A"),
                  Divider(color: theme.alternate, height: 16),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6.0, top: 2.0),
                    child: Text("Detalhamento de Custos:",
                        style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold,
                            color: theme.primaryText,
                            fontSize: 14)),
                  ),
                  if (listaPecas.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6.0),
                      child: Text("Nenhuma peça/serviço listado.",
                          style: GoogleFonts.inter(
                              color: theme.secondaryText, fontSize: 13)),
                    )
                  else
                    ...List.generate(listaPecas.length, (index) {
                      String nomePeca = listaPecas[index];
                      double valPeca = (index < listaValoresIndividuais.length)
                          ? listaValoresIndividuais[index]
                          : 0.0;
                      String valPecaFmt =
                          "R\$ ${valPeca.toStringAsFixed(2).replaceAll('.', ',')}";

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                "• $nomePeca",
                                style: GoogleFonts.inter(
                                    color: theme.secondaryText, fontSize: 13),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              valPecaFmt,
                              style: GoogleFonts.inter(
                                  color: theme.primaryText,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13),
                            ),
                          ],
                        ),
                      );
                    }),
                  Divider(color: theme.alternate, height: 16),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: theme.primaryBackground,
                        borderRadius: BorderRadius.circular(8)),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Custo Total:",
                              style: GoogleFonts.inter(
                                  fontWeight: FontWeight.bold,
                                  color: theme.primaryText)),
                          Text(valorTotalFmt,
                              style: GoogleFonts.inter(
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF0F766E),
                                  fontSize: 16))
                        ]),
                  )
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text("Fechar",
                    style: GoogleFonts.inter(
                        color: const Color(0xFF0F766E),
                        fontWeight: FontWeight.bold)))
          ],
        );
      },
    );
  }

  void _showSetorCompletoPopup(BuildContext context, String nomeSetor,
      List<QueryDocumentSnapshot> listaCompleta) {
    final theme = FlutterFlowTheme.of(context);
    double screenWidth = MediaQuery.of(context).size.width;
    bool isWeb = screenWidth > 800;
    double popupWidth = isWeb ? 600 : double.maxFinite;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        String localSearch = "";
        return StatefulBuilder(builder: (context, setStatePopup) {
          var listaFiltrada = listaCompleta.where((doc) {
            if (localSearch.isEmpty) return true;
            var data = doc.data() as Map<String, dynamic>;
            String search = localSearch.toLowerCase();
            String os =
                (data['NUMERO_OS']?.toString() ?? data['OS']?.toString() ?? "")
                    .toLowerCase();
            String patrimonio =
                (data['PATRIMONIO']?.toString() ?? "").toLowerCase();
            String sala = (data['SALA']?.toString() ?? "").toLowerCase();

            return os.contains(search) ||
                patrimonio.contains(search) ||
                sala.contains(search);
          }).toList();

          return AlertDialog(
            backgroundColor: theme.secondaryBackground,
            insetPadding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 24),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            titlePadding: EdgeInsets.zero,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            title: Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Color(0xFF0F766E),
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                      child: Text("Setor: $nomeSetor",
                          style: GoogleFonts.inter(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18))),
                  InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      child: const Icon(Icons.close, color: Colors.white))
                ],
              ),
            ),
            content: Container(
              width: popupWidth,
              constraints: const BoxConstraints(maxHeight: 700),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: theme.secondaryBackground,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: theme.alternate),
                      ),
                      child: TextField(
                        onChanged: (val) {
                          setStatePopup(() {
                            localSearch = val;
                          });
                        },
                        style: GoogleFonts.inter(
                            fontSize: 13, color: theme.primaryText),
                        decoration: InputDecoration(
                          hintText: "Filtrar neste setor...",
                          hintStyle: GoogleFonts.inter(
                              fontSize: 13, color: theme.secondaryText),
                          prefixIcon: Icon(Icons.search,
                              size: 20, color: theme.secondaryText),
                          border: InputBorder.none,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                        "Exibindo ${listaFiltrada.length} de ${listaCompleta.length} registros.",
                        style: GoogleFonts.inter(
                            color: theme.secondaryText,
                            fontSize: 12,
                            fontStyle: FontStyle.italic)),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          if (listaFiltrada.isEmpty)
                            Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Text("Nenhum item encontrado.",
                                  style: GoogleFonts.inter(
                                      color: theme.secondaryText)),
                            ),
                          ...listaFiltrada.map((doc) {
                            var data = doc.data() as Map<String, dynamic>;
                            return _buildServiceCard(context, data);
                          }).toList(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text("Fechar",
                      style: GoogleFonts.inter(
                          color: const Color(0xFF0F766E),
                          fontWeight: FontWeight.bold)))
            ],
          );
        });
      },
    );
  }

  Widget _buildServiceCard(BuildContext context, Map<String, dynamic> data) {
    final theme = FlutterFlowTheme.of(context);
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    String sala = data['SALA'] ?? 'Sem Local';
    String dataServico = data['DATA_TERMINO'] ?? '';
    String os = data['NUMERO_OS'] ?? 'S/N';
    String mes = data['MES'] ?? '';
    String equipamento = data['EQUIPAMENTO'] ?? '';
    String defeito = data['DEFEITO'] ?? 'Não informado';

    double valItem = _calcularValorItem(data['VALOR']);
    String valItemFmt =
        "R\$ ${valItem.toStringAsFixed(2).replaceAll('.', ',')}";

    return InkWell(
      onTap: () => _showDetalhesPopup(context, data),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12, top: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.secondaryBackground,
          borderRadius: BorderRadius.circular(8),
          boxShadow: getElevationShadow(isDark),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                    child: Text(sala,
                        style: GoogleFonts.inter(
                            color: theme.primaryText,
                            fontWeight: FontWeight.bold,
                            fontSize: 14))),
                Text(valItemFmt,
                    style: GoogleFonts.inter(
                        color: theme.tertiary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text("Nº DA O.S: $os",
                  style: GoogleFonts.inter(
                      color: theme.secondaryText,
                      fontWeight: FontWeight.w600,
                      fontSize: 12)),
            ),
            Divider(height: 12, color: theme.alternate),
            const SizedBox(height: 4),
            _buildItemRow(const Color(0xFF0F766E), equipamento, theme),
            const SizedBox(height: 4),
            _buildItemRow(theme.error, "Defeito: $defeito", theme),
            const SizedBox(height: 4),
            _buildItemRow(theme.warning, "Data: $dataServico  ($mes)", theme),
          ],
        ),
      ),
    );
  }

  Widget _buildPopupRow(BuildContext context, String label, String value) {
    final theme = FlutterFlowTheme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("$label:",
              style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  color: theme.secondaryText,
                  fontSize: 13)),
          SizedBox(width: 12),
          Expanded(
              child: Text(value,
                  textAlign: TextAlign.end,
                  style: GoogleFonts.inter(
                      color: theme.primaryText, fontSize: 13))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark
        ? const Color(0xFF14181B)
        : Theme.of(context).scaffoldBackgroundColor;

    // --- TELA DE SELEÇÃO INICIAL ---
    if (!_relatorioGerado) {
      return Container(
        width: widget.width ?? double.infinity,
        height: widget.height ?? double.infinity,
        color: backgroundColor,
        child: Center(
          child: Container(
            width:
                MediaQuery.of(context).size.width > 500 ? 450 : double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.secondaryBackground,
              borderRadius: BorderRadius.circular(12),
              boxShadow: getElevationShadow(isDark),
            ),
            child: _carregandoEmails
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(color: Color(0xFF0F766E)),
                      const SizedBox(height: 16),
                      Text("Carregando lista de clientes...",
                          style: GoogleFonts.inter(color: theme.secondaryText)),
                    ],
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Gerar Relatório",
                          style: GoogleFonts.inter(
                              color: theme.primaryText,
                              fontSize: 20,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 24),
                      Text("Selecione o Cliente (E-mail):",
                          style: GoogleFonts.inter(
                              color: theme.secondaryText, fontSize: 13)),
                      const SizedBox(height: 8),
                      _buildDropdown(
                        context,
                        hint: "Selecione o e-mail",
                        value: _emailSelecionado,
                        items: _listaEmails,
                        onChanged: (val) =>
                            setState(() => _emailSelecionado = val),
                      ),
                      const SizedBox(height: 16),
                      Text("Selecione o Mês:",
                          style: GoogleFonts.inter(
                              color: theme.secondaryText, fontSize: 13)),
                      const SizedBox(height: 8),
                      _buildDropdown(
                        context,
                        hint: "Mês",
                        value: _filtroMes,
                        items: _listaMeses,
                        onChanged: (val) => setState(() => _filtroMes = val),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 45,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0F766E),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: _emailSelecionado == null
                              ? null
                              : () {
                                  setState(() {
                                    _relatorioGerado = true;
                                  });
                                },
                          child: Text("Visualizar Relatório",
                              style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15)),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      );
    }

    // --- TELA DO RELATÓRIO (MOSTRADO APÓS CLICAR NO BOTÃO) ---
    return Container(
      width: widget.width,
      height: widget.height,
      color: backgroundColor,
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('CORRETIVAS')
            .where('EMAIL',
                isEqualTo: _emailSelecionado) // Usa a variável selecionada
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Center(
                child:
                    CircularProgressIndicator(color: const Color(0xFF0F766E)));

          final allDocs = snapshot.data!.docs;

          if (allDocs.isEmpty)
            return Center(
                child: Text('Nenhum registro encontrado para este cliente.',
                    style: GoogleFonts.inter(color: theme.secondaryText)));

          Set<String> anosDisponiveis = {};
          for (var doc in allDocs) {
            var data = doc.data() as Map<String, dynamic>;
            if (data['ANO'] != null)
              anosDisponiveis.add(data['ANO'].toString());
          }

          List<String> listaAnos = anosDisponiveis.toList()..sort();

          var docsFiltrados = allDocs.where((doc) {
            var data = doc.data() as Map<String, dynamic>;
            bool passaAno = _filtroAno == null ||
                _filtroAno == 'Todos' ||
                data['ANO'] == _filtroAno;
            bool passaMes = _filtroMes == null ||
                _filtroMes == 'Todos' ||
                (data['MES']?.toString().toUpperCase() ==
                    _filtroMes?.toUpperCase());
            bool passaSearch = true;

            if (_searchQuery.isNotEmpty) {
              String search = _searchQuery.toLowerCase();
              String os = (data['NUMERO_OS']?.toString() ??
                      data['OS']?.toString() ??
                      "")
                  .toLowerCase();
              String setor = (data['SETOR']?.toString() ?? "").toLowerCase();
              String patrimonio =
                  (data['PATRIMONIO']?.toString() ?? "").toLowerCase();
              String sala = (data['SALA']?.toString() ?? "").toLowerCase();

              passaSearch = os.contains(search) ||
                  setor.contains(search) ||
                  patrimonio.contains(search) ||
                  sala.contains(search);
            }
            return passaAno && passaMes && passaSearch;
          }).toList();

          Map<String, List<QueryDocumentSnapshot>> itensPorSetor = {};
          Map<String, double> somaPorSetor = {};
          double totalGeral = 0.0;

          for (var doc in docsFiltrados) {
            var data = doc.data() as Map<String, dynamic>;
            String setor = data['SETOR']?.toString().toUpperCase() ?? 'GERAL';
            double valorDoc = _calcularValorItem(data['VALOR']);

            if (!itensPorSetor.containsKey(setor)) {
              itensPorSetor[setor] = [];
              somaPorSetor[setor] = 0.0;
            }
            itensPorSetor[setor]!.add(doc);
            somaPorSetor[setor] = (somaPorSetor[setor] ?? 0.0) + valorDoc;
            totalGeral += valorDoc;
          }

          var setoresOrdenados = itensPorSetor.keys.toList()..sort();
          String totalGeralFormatado =
              "R\$ ${totalGeral.toStringAsFixed(2).replaceAll('.', ',')}";

          return Column(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                margin: const EdgeInsets.only(bottom: 2),
                decoration: BoxDecoration(
                    color: theme.secondaryBackground,
                    boxShadow: getElevationShadow(isDark)),
                child: Column(
                  children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              InkWell(
                                onTap: () =>
                                    setState(() => _relatorioGerado = false),
                                child: const Icon(Icons.arrow_back,
                                    color: Color(0xFF0F766E), size: 20),
                              ),
                              const SizedBox(width: 8),
                              Text("Filtros",
                                  style: GoogleFonts.inter(
                                      color: theme.secondaryText,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                          Row(children: [
                            if (_filtroAno != null ||
                                _filtroMes != null ||
                                _searchQuery.isNotEmpty)
                              InkWell(
                                  onTap: () => setState(() {
                                        _filtroAno = null;
                                        _filtroMes = null;
                                        _searchQuery = "";
                                        _searchController.clear();
                                      }),
                                  child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8),
                                      child: Text("Limpar",
                                          style: GoogleFonts.inter(
                                              color: const Color(0xFF0F766E),
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold)))),
                          ]),
                        ]),
                    const SizedBox(height: 10),
                    Container(
                        height: 40,
                        decoration: BoxDecoration(
                            color: theme.secondaryBackground,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: theme.alternate)),
                        child: TextField(
                            controller: _searchController,
                            onChanged: (val) {
                              setState(() {
                                _searchQuery = val;
                              });
                            },
                            style: GoogleFonts.inter(
                                fontSize: 13, color: theme.primaryText),
                            decoration: InputDecoration(
                                hintText:
                                    "Pesquisar por O.S, Setor, Patrimônio ou Sala...",
                                hintStyle: GoogleFonts.inter(
                                    fontSize: 13, color: theme.secondaryText),
                                prefixIcon: Icon(Icons.search,
                                    size: 20, color: theme.secondaryText),
                                border: InputBorder.none,
                                contentPadding:
                                    const EdgeInsets.symmetric(vertical: 8)))),
                    const SizedBox(height: 10),
                    Row(children: [
                      Expanded(
                          child: _buildDropdown(context,
                              hint: "Ano",
                              value: _filtroAno,
                              items: listaAnos,
                              onChanged: (val) =>
                                  setState(() => _filtroAno = val))),
                      const SizedBox(width: 10),
                      Expanded(
                          child: _buildDropdown(context,
                              hint: "Mês",
                              value: _filtroMes,
                              items: _listaMeses,
                              onChanged: (val) =>
                                  setState(() => _filtroMes = val))),
                    ]),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  width: double.infinity,
                  color: backgroundColor,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: Text('Relatório Detalhado',
                                style: GoogleFonts.inter(
                                    color: const Color(0xFF0F766E),
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold))),
                        if (docsFiltrados.isNotEmpty)
                          Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                  color: const Color(0xFF0F766E),
                                  borderRadius: BorderRadius.circular(12)),
                              child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.share,
                                          color: Colors.white),
                                      tooltip: "Compartilhar Relatório",
                                      onPressed: () =>
                                          _generatePdf(docsFiltrados),
                                    ),
                                    Expanded(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text("Resumo Geral",
                                                  style: GoogleFonts.inter(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white,
                                                      fontSize: 14)),
                                              Text(totalGeralFormatado,
                                                  style: GoogleFonts.inter(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white,
                                                      fontSize: 20)),
                                            ],
                                          )
                                        ],
                                      ),
                                    )
                                  ])),
                        const SizedBox(height: 20),
                        if (docsFiltrados.isEmpty)
                          Center(
                              child: Padding(
                                  padding: const EdgeInsets.only(top: 40),
                                  child: Column(children: [
                                    Icon(Icons.search_off,
                                        size: 40, color: theme.secondaryText),
                                    const SizedBox(height: 10),
                                    Text("Nenhum dado encontrado.",
                                        style: GoogleFonts.inter(
                                            color: theme.secondaryText))
                                  ]))),
                        ...setoresOrdenados.map((setor) {
                          double totalSetor = somaPorSetor[setor] ?? 0.0;
                          String totalSetorString =
                              "R\$ ${totalSetor.toStringAsFixed(2).replaceAll('.', ',')}";
                          List<QueryDocumentSnapshot> listaDoSetor =
                              itensPorSetor[setor]!;
                          var listaPreview = listaDoSetor.take(3).toList();

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin:
                                    const EdgeInsets.only(top: 10, bottom: 10),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 8),
                                decoration: BoxDecoration(
                                    border: Border(
                                        bottom: BorderSide(
                                            color: theme.alternate, width: 1))),
                                child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                          child: Text(setor,
                                              style: GoogleFonts.inter(
                                                  color: theme.primaryText,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16))),
                                      Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(totalSetorString,
                                                style: GoogleFonts.inter(
                                                    color: theme.tertiary,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 15)),
                                            Text(
                                                "${listaDoSetor.length} serviços",
                                                style: GoogleFonts.inter(
                                                    color: theme.secondaryText,
                                                    fontSize: 10))
                                          ])
                                    ]),
                              ),
                              ...listaPreview.map((doc) {
                                var data = doc.data() as Map<String, dynamic>;
                                return _buildServiceCard(context, data);
                              }).toList(),
                              if (listaDoSetor.length > 3)
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 8.0, bottom: 8.0),
                                  child: Center(
                                    child: InkWell(
                                      onTap: () => _showSetorCompletoPopup(
                                          context, setor, listaDoSetor),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 8),
                                        decoration: BoxDecoration(
                                            color: theme.secondaryBackground,
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            border: Border.all(
                                                color:
                                                    const Color(0xFF0F766E))),
                                        child: Text(
                                          "Ver todos os ${listaDoSetor.length} itens",
                                          style: GoogleFonts.inter(
                                              color: const Color(0xFF0F766E),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 20),
                            ],
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDropdown(BuildContext context,
      {required String hint,
      required String? value,
      required List<String> items,
      required Function(String?) onChanged}) {
    final theme = FlutterFlowTheme.of(context);
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
      height: 45,
      decoration: BoxDecoration(
          color: theme.secondaryBackground,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: theme.alternate),
          boxShadow: getElevationShadow(isDark)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: (items.contains(value)) ? value : null,
          hint: Text(hint,
              style:
                  GoogleFonts.inter(color: theme.secondaryText, fontSize: 13)),
          dropdownColor: theme.secondaryBackground,
          icon: Icon(Icons.arrow_drop_down, color: theme.secondaryText),
          style: GoogleFonts.inter(color: theme.primaryText, fontSize: 13),
          isExpanded: true,
          items: items
              .map((String item) => DropdownMenuItem<String>(
                  value: item,
                  child:
                      Text(item, maxLines: 1, overflow: TextOverflow.ellipsis)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildItemRow(Color iconColor, String text, FlutterFlowTheme theme) {
    return Row(
      children: [
        Icon(Icons.circle, size: 6, color: iconColor),
        const SizedBox(width: 8),
        Expanded(
            child: Text(text,
                style:
                    GoogleFonts.inter(color: theme.secondaryText, fontSize: 12),
                maxLines: 2,
                overflow: TextOverflow.ellipsis)),
      ],
    );
  }
}
