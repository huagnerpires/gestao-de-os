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
import '/flutter_flow/custom_functions.dart';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'dart:convert';
import 'package:http/http.dart' as http;

// ─── Grade decorativa de fundo do pad ────────────────────────────────────────
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFEEF1F5)
      ..strokeWidth = 0.8;
    const step = 28.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_GridPainter old) => false;
}

// ─── Assinatura Digital Painter ───────────────────────────────────────────────
// [capturedSize] = tamanho do canvas onde os traços foram desenhados.
// Quando fornecido, os pontos são re-escalados para o tamanho atual do widget,
// permitindo que o mesmo conjunto de traços seja exibido corretamente tanto
// no pad original quanto no preview menor.
class _SignaturePainter extends CustomPainter {
  final List<List<Offset?>> strokes;
  final Size? capturedSize;

  _SignaturePainter({required this.strokes, this.capturedSize});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1E2A35)
      ..strokeWidth = capturedSize != null ? 2.0 : 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    // Fatores de escala: 1.0 quando não há capturedSize (pad original)
    final double scaleX = capturedSize != null && capturedSize!.width > 0
        ? size.width / capturedSize!.width
        : 1.0;
    final double scaleY = capturedSize != null && capturedSize!.height > 0
        ? size.height / capturedSize!.height
        : 1.0;

    for (final stroke in strokes) {
      final path = Path();
      bool started = false;
      for (final pt in stroke) {
        if (pt == null) {
          started = false;
          continue;
        }
        final dx = pt.dx * scaleX;
        final dy = pt.dy * scaleY;
        if (!started) {
          path.moveTo(dx, dy);
          started = true;
        } else {
          path.lineTo(dx, dy);
        }
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_SignaturePainter old) =>
      old.strokes != strokes || old.capturedSize != capturedSize;
}

// ─── Painter da linha-guia de assinatura ─────────────────────────────────────
class _SignatureLinePainter extends CustomPainter {
  final Color lineColor;
  final Color labelColor;
  // Posição Y da linha como fração da altura total (ex: 0.72 = 72% de cima)
  final double lineFraction;

  _SignatureLinePainter({
    this.lineColor = const Color(0xFFAEC6CF),
    this.labelColor = const Color(0xFFB0BEC5),
    this.lineFraction = 0.72,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final y = size.height * lineFraction;

    // Linha tracejada
    final dashPaint = Paint()
      ..color = lineColor
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    const dashWidth = 8.0;
    const gapWidth = 5.0;
    double x = 20;
    while (x < size.width - 20) {
      canvas.drawLine(
        Offset(x, y),
        Offset((x + dashWidth).clamp(0, size.width - 20), y),
        dashPaint,
      );
      x += dashWidth + gapWidth;
    }

    // Marcador esquerdo "X"
    final xPaint = Paint()
      ..color = lineColor
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    const xSize = 6.0;
    canvas.drawLine(
        Offset(20, y - xSize), Offset(20 + xSize, y + xSize), xPaint);
    canvas.drawLine(
        Offset(20 + xSize, y - xSize), Offset(20, y + xSize), xPaint);
  }

  @override
  bool shouldRepaint(_SignatureLinePainter old) => false;
}

// ─── Modelo USUARIOS ──────────────────────────────────────────────────────────
class _UsuarioItem {
  final String docId;
  final String displayName;
  final String cnpj;
  final String endereco;
  final String numero;
  final String bairro;
  final String cep;
  final String cidade;
  final String telefone;
  final String email;
  final String photoUrl;
  final List<String> emailsTeste;

  _UsuarioItem({
    required this.docId,
    required this.displayName,
    required this.cnpj,
    required this.endereco,
    required this.numero,
    required this.bairro,
    required this.cep,
    required this.cidade,
    required this.telefone,
    required this.email,
    required this.photoUrl,
    required this.emailsTeste,
  });

  factory _UsuarioItem.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>? ?? {};
    List<String> emails = [];
    final et = d['emailteste'];
    if (et is List) {
      emails = et
          .map((e) => e.toString().trim())
          .where((e) => e.isNotEmpty)
          .toList();
    } else if (et is String && et.trim().isNotEmpty) {
      emails = [et.trim()];
    }
    return _UsuarioItem(
      docId: doc.id,
      displayName: d['display_name'] ?? d['NOME'] ?? '',
      cnpj: d['CNPJ'] ?? '',
      endereco: d['ENDERECO'] ?? '',
      numero: d['NUMERO'] ?? '',
      bairro: d['BAIIRO'] ?? d['BAIRRO'] ?? '',
      cep: d['CEP'] ?? '',
      cidade: d['CIDADE'] ?? '',
      telefone: d['TELEFONE'] ?? d['phone_number'] ?? '',
      email: d['email'] ?? '',
      photoUrl: d['photo_url'] ?? '',
      emailsTeste: emails,
    );
  }

  String get enderecoCompleto {
    final p = <String>[];
    if (endereco.isNotEmpty) p.add(endereco);
    if (numero.isNotEmpty) p.add('nº $numero');
    if (bairro.isNotEmpty) p.add(bairro);
    return p.join(', ');
  }
}

// ─── Constantes HPS ───────────────────────────────────────────────────────────
class _HPS {
  static const nome = 'HPS REFRIGERAÇÃO';
  static const cnpj = '28.340.253/0001-52';
  static const endereco = 'Vitória da Conquista - BA';
  static const cep = '45.075-262';
  static const cidade = 'Vitória da Conquista - BA';
  static const telefone = '(77) 98819-4630 / (77) 98861-2447';
  static const email = 'hpsrefri@gmail.com';
  static const senderEmail = 'equipe@hpsrefri.com.br';
  static const senderName = 'HPS Refrigeração';
  static const osAppId = '7b01186f-cf76-4b5d-8354-87d83737d40c';
  static const osApiKey = 'ZTdlNjIwZWItMjEyMC00M2RhLWJlZmYtMzc2NTBmNzNmMDdj';
  static const osChannel = '577bba44-d1bf-4ac9-9d11-20d89e09a61a';
  static const bannerUrl =
      'https://firebasestorage.googleapis.com/v0/b/h-p-s-modificado-emdcp0.appspot.com/o/Gemini_Generated_Image_2xpdsd2xpdsd2xpd%20(1).png?alt=media&token=be3e052e-a0b8-4e8c-8151-b9365b507ed5';
  static const logoUrl = 'https://i.ibb.co/VpqNsxXt/Imagem1.jpg';
}

/// ═════════════════════════════════════════════════════════════════════════════
class FormularioRecebimentoWidget extends StatefulWidget {
  const FormularioRecebimentoWidget({
    super.key,
    this.width,
    this.height,
    this.assinatura,
    this.setor,
  });

  final double? width;
  final double? height;
  final String? assinatura;
  final String? setor;

  @override
  State<FormularioRecebimentoWidget> createState() =>
      _FormularioRecebimentoWidgetState();
}

class _FormularioRecebimentoWidgetState
    extends State<FormularioRecebimentoWidget> {
  // ─── Clientes ─────────────────────────────────────────────────────────────
  List<_UsuarioItem> _usuarios = [];
  _UsuarioItem? _cli;
  bool _loadingUsers = true;
  String? _erroUsers;
  final _searchCtrl = TextEditingController();
  List<_UsuarioItem> _filtrados = [];
  bool _showDrop = false;

  // ─── Nº OS ────────────────────────────────────────────────────────────────
  final _numeroOsCtrl = TextEditingController();

  // ─── Recebimento ──────────────────────────────────────────────────────────
  late TextEditingController _assinatura;
  late TextEditingController _setor;
  late TextEditingController _recebedor;
  late TextEditingController _cracha;
  DateTime? _data;

  // ─── Assinatura digital ───────────────────────────────────────────────────
  final List<List<Offset?>> _strokes = [];
  List<Offset?> _currentStroke = [];
  bool _usarDigital = false;
  // Dimensões do pad no momento da captura — usadas para escalar o preview
  Size? _padCapturedSize;

  // ─── Itens tabela ─────────────────────────────────────────────────────────
  final List<Map<String, TextEditingController>> _itens = [];

  // ─── Upload / envio ───────────────────────────────────────────────────────
  bool _enviando = false;
  double _prog = 0;
  String _progLabel = '';
  bool _ok = false;
  String? _erro;

  // ─── Cores ────────────────────────────────────────────────────────────────
  static const _primary = Color(0xFF3D5A80);
  static const _primaryLight = Color(0xFF4F6F8F);
  static const _surface = Color(0xFF0B0F17);
  static const _cardBg = Color(0xFF131B2E);
  static const _border = Color(0xFF1E293B);
  static const _textDark = Color(0xFFFFFFFF);
  static const _textMid = Color(0xFF94A3B8);
  static const _accent = Color(0xFF4F7396);
  static const _cliColor = Color(0xFF4A6858);
  static const _verde = Color(0xFF047857);

  // ─── Meses ────────────────────────────────────────────────────────────────
  static const _meses = [
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
  late String _mesSelecionado;
  String get _ano => DateTime.now().year.toString();

  // ══════════════════════════════════════════════════════════════════════════
  @override
  void initState() {
    super.initState();
    _assinatura = TextEditingController(text: widget.assinatura ?? '');
    _setor = TextEditingController(text: widget.setor ?? '');
    _recebedor = TextEditingController();
    _cracha = TextEditingController();
    _mesSelecionado = _meses[DateTime.now().month - 1];
    _carregarUsuarios();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _assinatura.dispose();
    _setor.dispose();
    _recebedor.dispose();
    _cracha.dispose();
    _numeroOsCtrl.dispose();
    for (final item in _itens) {
      item.forEach((_, c) => c.dispose());
    }
    super.dispose();
  }

  // ─── Firestore: lista usuários ────────────────────────────────────────────
  Future<void> _carregarUsuarios() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('USUARIOS')
          .orderBy('display_name')
          .get();
      final lista = snap.docs
          .map((d) => _UsuarioItem.fromDoc(d))
          .where((u) => u.displayName.isNotEmpty)
          .toList();
      if (mounted) {
        setState(() {
          _usuarios = lista;
          _filtrados = lista;
          _loadingUsers = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _erroUsers = e.toString();
          _loadingUsers = false;
        });
      }
    }
  }

  void _filtrar(String q) {
    final ql = q.toLowerCase();
    setState(() {
      _filtrados = q.isEmpty
          ? _usuarios
          : _usuarios
              .where((u) =>
                  u.displayName.toLowerCase().contains(ql) ||
                  u.cnpj.contains(ql) ||
                  u.email.toLowerCase().contains(ql))
              .toList();
      _showDrop = true;
    });
  }

  void _selecionarCliente(_UsuarioItem u) {
    setState(() {
      _cli = u;
      _searchCtrl.text = u.displayName;
      _showDrop = false;
    });
  }

  void _limparCliente() {
    setState(() {
      _cli = null;
      _searchCtrl.clear();
      _filtrados = _usuarios;
      _showDrop = false;
    });
  }

  // ─── Itens tabela ─────────────────────────────────────────────────────────
  void _addItem() {
    setState(() => _itens.add({
          'codigo': TextEditingController(),
          'descricao': TextEditingController(),
          'quantidade': TextEditingController(),
          'valorUnitario': TextEditingController(),
        }));
  }

  void _removeItem(int i) {
    setState(() {
      _itens[i].forEach((_, c) => c.dispose());
      _itens.removeAt(i);
    });
  }

  double _totalLinha(int i) {
    final q =
        double.tryParse(_itens[i]['quantidade']!.text.replaceAll(',', '.'));
    final v =
        double.tryParse(_itens[i]['valorUnitario']!.text.replaceAll(',', '.'));
    return (q != null && v != null) ? q * v : 0;
  }

  double get _totalGeral =>
      List.generate(_itens.length, _totalLinha).fold(0.0, (a, b) => a + b);

  String _fmt(double v) =>
      NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$', decimalDigits: 2)
          .format(v);

  // ─── OneSignal ────────────────────────────────────────────────────────────
  Future<void> _push(String email, String titulo, String msg) async {
    if (email.isEmpty) return;
    try {
      await http.post(
        Uri.parse('https://onesignal.com/api/v1/notifications'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Basic ${_HPS.osApiKey}',
        },
        body: jsonEncode({
          'app_id': _HPS.osAppId,
          'filters': [
            {'field': 'tag', 'key': 'Email', 'relation': '=', 'value': email}
          ],
          'android_channel_id': _HPS.osChannel,
          'headings': {'en': titulo},
          'contents': {'en': msg},
          'priority': 10,
        }),
      );
    } catch (_) {}
  }

  // ─── Notificação Firestore ────────────────────────────────────────────────
  Future<void> _criarNotificacao({
    required String email,
    required String downloadUrl,
    required String numeroOs,
  }) async {
    if (email.isEmpty) return;
    final now = DateTime.now();
    final mnUp = [
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
      'DEZEMBRO'
    ];
    final msg = numeroOs.isNotEmpty
        ? 'Formulário de Recebimento OS #$numeroOs – $_mesSelecionado/$_ano foi gerado.'
        : 'Formulário de Recebimento – $_mesSelecionado/$_ano foi gerado.';
    try {
      await FirebaseFirestore.instance.collection('NOTIFICACAO').add({
        'email': email,
        'visto': false,
        'titulo': 'Formulário de Recebimento',
        'mensagem': msg,
        'status': 'ENVIADO',
        'os': numeroOs,
        'mes': mnUp[now.month],
        'ano': _ano,
        'tipo': 'DOCUMENTO',
        'data': FieldValue.serverTimestamp(),
        'url': downloadUrl,
        'tipoDocumento': 'FORMULÁRIO DE RECEBIMENTO DE MERCADORIAS',
        'mesReferencia': _mesSelecionado,
      });
    } catch (_) {}
  }

  // ─── Download de imagem como bytes ────────────────────────────────────────
  Future<Uint8List?> _downloadBytes(String url) async {
    if (url.isEmpty) return null;
    try {
      final r = await http.get(Uri.parse(url));
      if (r.statusCode == 200) return r.bodyBytes;
    } catch (_) {}
    return null;
  }

  // ─── Render assinatura → PNG ──────────────────────────────────────────────
  Future<Uint8List?> _renderSign() async {
    if (_strokes.isEmpty) return null;

    // 1. Encontra os limites (bounding box) do desenho para cortar o excesso
    double minX = double.infinity;
    double minY = double.infinity;
    double maxX = 0.0;
    double maxY = 0.0;
    bool hasPoints = false;

    for (final stroke in _strokes) {
      for (final pt in stroke) {
        if (pt != null) {
          if (pt.dx < minX) minX = pt.dx;
          if (pt.dy < minY) minY = pt.dy;
          if (pt.dx > maxX) maxX = pt.dx;
          if (pt.dy > maxY) maxY = pt.dy;
          hasPoints = true;
        }
      }
    }

    if (!hasPoints) return null;

    // 2. Adiciona uma margem de respiro (padding) de 20px
    const double padding = 20.0;
    minX = (minX - padding < 0.0) ? 0.0 : minX - padding;
    minY = (minY - padding < 0.0) ? 0.0 : minY - padding;
    maxX += padding;
    maxY += padding;

    final double w = maxX - minX;
    final double h = maxY - minY;

    final rec = ui.PictureRecorder();
    final canvas = Canvas(rec, Rect.fromLTWH(0.0, 0.0, w, h));

    // Fundo branco
    canvas.drawRect(
        Rect.fromLTWH(0.0, 0.0, w, h), Paint()..color = Colors.white);

    // Translada (move) o canvas para alinhar perfeitamente com o corte
    canvas.translate(-minX, -minY);

    _SignaturePainter(
      strokes: _strokes,
      capturedSize: null, // Deixamos nulo para ele desenhar no tamanho exato
    ).paint(canvas, Size(w, h));

    final pic = rec.endRecording();
    final img = await pic.toImage(w.toInt(), h.toInt());
    final bd = await img.toByteData(format: ui.ImageByteFormat.png);
    return bd?.buffer.asUint8List();
  }

  // ─── Progress helper ──────────────────────────────────────────────────────
  Future<void> _setProgress(double alvo, String label) async {
    if (!mounted) return;
    setState(() => _progLabel = label);
    final ini = _prog;
    for (int i = 1; i <= 15; i++) {
      await Future.delayed(const Duration(milliseconds: 18));
      if (!mounted) return;
      setState(() => _prog = ini + (alvo - ini) * (i / 15));
    }
  }

  // ─── GERAR PDF + UPLOAD + ENVIO ───────────────────────────────────────────
  Future<void> _gerarEEnviar() async {
    if (_cli == null) {
      _snack('Selecione o cliente antes de gerar o PDF.', Colors.orange);
      return;
    }
    setState(() {
      _enviando = true;
      _prog = 0;
      _progLabel = 'Gerando PDF...';
      _ok = false;
      _erro = null;
    });
    try {
      await _setProgress(0.05, 'Preparando imagens...');

      final signPng = _usarDigital ? await _renderSign() : null;
      final logoBytes = await _downloadBytes(_cli!.photoUrl);
      final hpsBytes = await _downloadBytes(_HPS.logoUrl);

      await _setProgress(0.15, 'Gerando PDF...');

      final pdfBytes = await _buildPdfBytes(
        signPng: signPng,
        logoBytes: logoBytes,
        hpsBytes: hpsBytes,
        recebedor: _recebedor.text.trim(),
        cracha: _cracha.text.trim(),
      );

      await _setProgress(0.35, 'Enviando para Storage...');

      final nos = _numeroOsCtrl.text.trim().toUpperCase();
      final now = DateTime.now();
      final dh =
          '${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}'
          '_${now.hour.toString().padLeft(2, '0')}h${now.minute.toString().padLeft(2, '0')}';
      final nome = nos.isNotEmpty
          ? 'RECEBIMENTO_OS${nos}_$dh.pdf'
          : 'RECEBIMENTO_$dh.pdf';
      final path = '${_cli!.email}/$_ano/$_mesSelecionado/NOTAS FISCAIS/$nome';
      final ref = FirebaseStorage.instance.ref().child(path);
      final task = ref.putData(
          pdfBytes, SettableMetadata(contentType: 'application/pdf'));

      task.snapshotEvents.listen((s) {
        if (!mounted) return;
        final pct = s.bytesTransferred / (s.totalBytes == 0 ? 1 : s.totalBytes);
        setState(() {
          _prog = 0.35 + pct * 0.3;
          _progLabel = 'Enviando... ${(_prog * 100).toStringAsFixed(0)}%';
        });
      });
      await task;
      final downloadUrl = await ref.getDownloadURL();

      await _setProgress(0.70, 'Salvando notificação...');

      await _criarNotificacao(
        email: _cli!.email,
        downloadUrl: downloadUrl,
        numeroOs: nos,
      );
      await _criarNotificacao(
        email: _HPS.email,
        downloadUrl: downloadUrl,
        numeroOs: nos,
      );

      await _setProgress(0.88, 'Enviando notificação push...');
      await Future.wait([
        _push(
            _cli!.email,
            '📄 Formulário Disponível',
            nos.isNotEmpty
                ? 'Formulário de Recebimento OS #$nos está pronto.'
                : 'Formulário de Recebimento de Mercadorias está pronto.'),
        _push(_HPS.email, '📤 Formulário Gerado',
            'Formulário gerado para ${_cli!.displayName} – $_mesSelecionado/$_ano.'),
      ]);

      await _setProgress(1.0, 'Concluído!');
      if (mounted) {
        setState(() {
          _enviando = false;
          _ok = true;
        });
      }

      await Printing.layoutPdf(
        onLayout: (_) async => pdfBytes,
        name: nome,
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _enviando = false;
          _erro = 'Erro: $e';
        });
      }
    }
  }

  // ─── Constrói bytes do PDF ────────────────────────────────────────────────
  Future<Uint8List> _buildPdfBytes({
    Uint8List? signPng,
    Uint8List? logoBytes,
    Uint8List? hpsBytes,
    String recebedor = '',
    String cracha = '',
  }) async {
    final doc = pw.Document();

    final pPrimary = PdfColor.fromHex('#3D5A80');
    final pCli = PdfColor.fromHex('#4A6858');
    final pBgForn = PdfColor.fromHex('#EEF1F5');
    final pBgCli = PdfColor.fromHex('#EEF2EF');
    final pBorder = PdfColor.fromHex('#D6DCE4');
    final pCliBorder = PdfColor.fromHex('#C4D4CA');
    final pRowAlt = PdfColor.fromHex('#F5F6F8');
    final pWhite = PdfColors.white;
    final pDark = PdfColor.fromHex('#1E2A35');
    final pGrey = PdfColor.fromHex('#546E7A');
    final cli = _cli!;
    final dataStr = _data != null
        ? DateFormat('dd/MM/yyyy').format(_data!)
        : '___/___/______';

    doc.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.symmetric(horizontal: 28, vertical: 32),
      build: (ctx) => [
        // ── Cabeçalho ────────────────────────────────────────────────────
        pw.Container(
          decoration: pw.BoxDecoration(
              color: pPrimary, borderRadius: pw.BorderRadius.circular(10)),
          padding: const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    if (hpsBytes != null) ...[
                      pw.Container(
                        width: 52,
                        height: 38,
                        decoration: pw.BoxDecoration(
                            color: pWhite,
                            borderRadius: pw.BorderRadius.circular(5)),
                        padding: const pw.EdgeInsets.all(3),
                        child: pw.Image(pw.MemoryImage(hpsBytes),
                            fit: pw.BoxFit.contain),
                      ),
                      pw.SizedBox(width: 12),
                    ],
                    pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('FORMULÁRIO DE RECEBIMENTO',
                              style: pw.TextStyle(
                                  color: pWhite,
                                  fontSize: 14,
                                  fontWeight: pw.FontWeight.bold,
                                  letterSpacing: 1.0)),
                          pw.Text('DE MERCADORIAS',
                              style: pw.TextStyle(
                                  color: PdfColor.fromHex('#B0BEC5'),
                                  fontSize: 10)),
                          pw.SizedBox(height: 3),
                          pw.Text(
                              'Data: $dataStr  |  Mês: $_mesSelecionado/$_ano',
                              style: pw.TextStyle(
                                  color: PdfColor.fromHex('#B0BEC5'),
                                  fontSize: 8)),
                        ]),
                  ]),
              if (logoBytes != null)
                pw.Container(
                  height: 48,
                  decoration: pw.BoxDecoration(
                      color: pWhite, borderRadius: pw.BorderRadius.circular(6)),
                  padding:
                      const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: pw.Image(pw.MemoryImage(logoBytes),
                      fit: pw.BoxFit.contain),
                )
              else
                pw.Text(cli.displayName,
                    style: pw.TextStyle(
                        color: PdfColor.fromHex('#B0BEC5'), fontSize: 9)),
            ],
          ),
        ),
        pw.SizedBox(height: 14),

        // ── Fornecedor + Cliente ──────────────────────────────────────────
        pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Expanded(
              child: _pdfCard(
            titulo: 'FORNECEDOR',
            cor: pPrimary,
            bgBody: pBgForn,
            border: pBorder,
            campos: [
              _pdfField('Nome / Razão Social', _HPS.nome, pDark),
              _pdfRow2(
                  [('CNPJ', _HPS.cnpj), ('Telefone', _HPS.telefone)], pDark),
              _pdfField('Endereço', _HPS.endereco, pDark),
              _pdfRow2([('CEP', _HPS.cep), ('Cidade', _HPS.cidade)], pDark),
            ],
          )),
          pw.SizedBox(width: 10),
          pw.Expanded(
              child: _pdfCard(
            titulo: 'CLIENTE',
            cor: pCli,
            bgBody: pBgCli,
            border: pCliBorder,
            campos: [
              _pdfField('Nome / Razão Social', cli.displayName, pDark),
              _pdfRow2([('CNPJ', cli.cnpj), ('Telefone', cli.telefone)], pDark),
              _pdfField('Endereço', cli.enderecoCompleto, pDark),
              _pdfRow2([('CEP', cli.cep), ('Cidade', cli.cidade)], pDark),
            ],
          )),
        ]),
        pw.SizedBox(height: 14),

        // ── Tabela itens ─────────────────────────────────────────────────
        pw.Container(
          decoration: pw.BoxDecoration(
              borderRadius: pw.BorderRadius.circular(8),
              border: pw.Border.all(color: pBorder)),
          child: pw.Column(children: [
            pw.Container(
              decoration: pw.BoxDecoration(
                  color: pPrimary,
                  borderRadius: const pw.BorderRadius.only(
                      topLeft: pw.Radius.circular(7),
                      topRight: pw.Radius.circular(7))),
              padding:
                  const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              child: pw.Row(children: [
                pw.Text('DESCRIÇÃO DA MERCADORIA',
                    style: pw.TextStyle(
                        color: pWhite,
                        fontSize: 9,
                        fontWeight: pw.FontWeight.bold,
                        letterSpacing: 0.8)),
              ]),
            ),
            pw.Container(
              color: pBgForn,
              padding:
                  const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: pw.Row(children: [
                pw.SizedBox(
                    width: 60,
                    child: pw.Text('CÓDIGO', style: _pdfColStyle(pPrimary))),
                pw.Expanded(
                    child: pw.Text('DESCRIÇÃO', style: _pdfColStyle(pPrimary))),
                pw.SizedBox(
                    width: 55,
                    child: pw.Text('QTDE',
                        textAlign: pw.TextAlign.center,
                        style: _pdfColStyle(pPrimary))),
                pw.SizedBox(
                    width: 75,
                    child: pw.Text('VL. UNIT.',
                        textAlign: pw.TextAlign.right,
                        style: _pdfColStyle(pPrimary))),
                pw.SizedBox(
                    width: 75,
                    child: pw.Text('VL. TOTAL',
                        textAlign: pw.TextAlign.right,
                        style: _pdfColStyle(pPrimary))),
              ]),
            ),
            ...List.generate(_itens.length, (i) {
              final tot = _totalLinha(i);
              final empty = _itens[i]['codigo']!.text.isEmpty &&
                  _itens[i]['descricao']!.text.isEmpty;
              return pw.Container(
                color: i.isEven ? pWhite : pRowAlt,
                padding:
                    const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: pw.Row(children: [
                  pw.SizedBox(
                      width: 60,
                      child: pw.Text(empty ? '' : _itens[i]['codigo']!.text,
                          style: pw.TextStyle(fontSize: 8, color: pDark))),
                  pw.Expanded(
                      child: pw.Text(empty ? '' : _itens[i]['descricao']!.text,
                          style: pw.TextStyle(fontSize: 8, color: pDark))),
                  pw.SizedBox(
                      width: 55,
                      child: pw.Text(empty ? '' : _itens[i]['quantidade']!.text,
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(fontSize: 8, color: pDark))),
                  pw.SizedBox(
                      width: 75,
                      child: pw.Text(
                          empty || _itens[i]['valorUnitario']!.text.isEmpty
                              ? ''
                              : _fmt(double.tryParse(_itens[i]['valorUnitario']!
                                      .text
                                      .replaceAll(',', '.')) ??
                                  0),
                          textAlign: pw.TextAlign.right,
                          style: pw.TextStyle(fontSize: 8, color: pDark))),
                  pw.SizedBox(
                      width: 75,
                      child: pw.Text(empty || tot == 0 ? '' : _fmt(tot),
                          textAlign: pw.TextAlign.right,
                          style: pw.TextStyle(
                              fontSize: 8,
                              color: pPrimary,
                              fontWeight: pw.FontWeight.bold))),
                ]),
              );
            }),
            if (_itens.isEmpty)
              pw.Container(
                color: pWhite,
                padding:
                    const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                child: pw.Text('Nenhum item informado.',
                    style: pw.TextStyle(fontSize: 8, color: pGrey)),
              ),
            pw.Container(
              decoration: pw.BoxDecoration(
                  color: pPrimary,
                  borderRadius: const pw.BorderRadius.only(
                      bottomLeft: pw.Radius.circular(7),
                      bottomRight: pw.Radius.circular(7))),
              padding:
                  const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.end,
                  children: [
                    pw.Text('TOTAL GERAL:',
                        style: pw.TextStyle(
                            color: pWhite,
                            fontSize: 9,
                            fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(width: 8),
                    pw.Text(_fmt(_totalGeral),
                        style: pw.TextStyle(
                            color: pWhite,
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold)),
                  ]),
            ),
          ]),
        ),
        pw.SizedBox(height: 14),

        // ── Recebimento ───────────────────────────────────────────────────
        pw.Container(
          decoration: pw.BoxDecoration(
              color: pBgForn,
              borderRadius: pw.BorderRadius.circular(8),
              border: pw.Border.all(color: pBorder)),
          padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('RECEBIMENTO DA MERCADORIA',
                    style: pw.TextStyle(
                        color: pPrimary,
                        fontSize: 9,
                        fontWeight: pw.FontWeight.bold,
                        letterSpacing: 0.8)),
                pw.SizedBox(height: 10),
                pw.Row(children: [
                  pw.Expanded(
                      flex: 3,
                      child: _pdfBox('RECEBEDOR', recebedor, pWhite, pBorder,
                          pDark, pGrey)),
                  pw.SizedBox(width: 8),
                  pw.Expanded(
                      flex: 2,
                      child: _pdfBox(
                          'Nº CRACHÁ', cracha, pWhite, pBorder, pDark, pGrey)),
                  pw.SizedBox(width: 8),
                  pw.Expanded(
                      flex: 2,
                      child: _pdfBox(
                          'SETOR', _setor.text, pWhite, pBorder, pDark, pGrey)),
                  pw.SizedBox(width: 8),
                  pw.Expanded(
                      flex: 2,
                      child: _pdfBox(
                          'DATA', dataStr, pWhite, pBorder, pDark, pGrey,
                          center: true)),
                ]),
                pw.SizedBox(height: 10),
                signPng != null
                    ? pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                            pw.Text('ASSINATURA',
                                style: pw.TextStyle(
                                    color: pGrey,
                                    fontSize: 7,
                                    fontWeight: pw.FontWeight.bold)),
                            pw.SizedBox(height: 4),
                            pw.Container(
                              height: 65,
                              width: 300.0,
                              decoration: pw.BoxDecoration(
                                  color: pWhite,
                                  borderRadius: pw.BorderRadius.circular(4),
                                  border: pw.Border.all(color: pBorder)),
                              child: pw.Image(pw.MemoryImage(signPng),
                                  fit: pw.BoxFit.contain),
                            ),
                          ])
                    : _pdfBox('ASSINATURA', _assinatura.text, pWhite, pBorder,
                        pDark, pGrey),
              ]),
        ),
        pw.SizedBox(height: 20),
        pw.Divider(color: pBorder),
        pw.SizedBox(height: 4),
        pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
          pw.Text(
              'Gerado em ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
              style: pw.TextStyle(fontSize: 7, color: pGrey)),
          pw.Text('HPS Refrigeração · Formulário de Recebimento de Mercadorias',
              style: pw.TextStyle(fontSize: 7, color: pGrey)),
        ]),
      ],
    ));

    return doc.save();
  }

  // ─── PDF helpers ──────────────────────────────────────────────────────────
  pw.TextStyle _pdfColStyle(PdfColor c) => pw.TextStyle(
      fontSize: 8,
      fontWeight: pw.FontWeight.bold,
      color: c,
      letterSpacing: 0.5);

  pw.Widget _pdfCard({
    required String titulo,
    required PdfColor cor,
    required PdfColor bgBody,
    required PdfColor border,
    required List<pw.Widget> campos,
  }) =>
      pw.Container(
        decoration: pw.BoxDecoration(
            borderRadius: pw.BorderRadius.circular(8),
            border: pw.Border.all(color: border)),
        child: pw.Column(children: [
          pw.Container(
            decoration: pw.BoxDecoration(
                color: cor,
                borderRadius: const pw.BorderRadius.only(
                    topLeft: pw.Radius.circular(7),
                    topRight: pw.Radius.circular(7))),
            padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: pw.Row(children: [
              pw.Text(titulo,
                  style: pw.TextStyle(
                      color: PdfColors.white,
                      fontSize: 8,
                      fontWeight: pw.FontWeight.bold,
                      letterSpacing: 0.8)),
            ]),
          ),
          pw.Container(
              color: bgBody,
              padding: const pw.EdgeInsets.all(8),
              child: pw.Column(children: campos)),
        ]),
      );

  pw.Widget _pdfField(String label, String value, PdfColor tc) => pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 5),
        child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(label,
                  style: pw.TextStyle(
                      fontSize: 6.5,
                      color: PdfColor.fromHex('#546E7A'),
                      fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 2),
              pw.Container(
                width: double.infinity,
                padding:
                    const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: pw.BoxDecoration(
                    color: PdfColors.white,
                    borderRadius: pw.BorderRadius.circular(3),
                    border: pw.Border.all(
                        color: PdfColor.fromHex('#D6DCE4'), width: 0.5)),
                child: pw.Text(value.isEmpty ? ' ' : value,
                    style: pw.TextStyle(fontSize: 7.5, color: tc)),
              ),
            ]),
      );

  pw.Widget _pdfRow2(List<(String, String)> pairs, PdfColor tc) => pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 5),
        child: pw.Row(
            children: pairs
                .map((p) => pw.Expanded(
                      child: pw.Padding(
                        padding:
                            pw.EdgeInsets.only(right: p == pairs.last ? 0 : 6),
                        child: _pdfField(p.$1, p.$2, tc),
                      ),
                    ))
                .toList()),
      );

  pw.Widget _pdfBox(String label, String value, PdfColor bg, PdfColor border,
          PdfColor tc, PdfColor lc,
          {bool center = false}) =>
      pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        pw.Text(label,
            style: pw.TextStyle(
                color: lc, fontSize: 7, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 4),
        pw.Container(
          height: 28,
          decoration: pw.BoxDecoration(
              color: bg,
              borderRadius: pw.BorderRadius.circular(4),
              border: pw.Border.all(color: border)),
          alignment: center ? pw.Alignment.center : pw.Alignment.centerLeft,
          padding:
              center ? pw.EdgeInsets.zero : const pw.EdgeInsets.only(left: 6),
          child: pw.Text(value, style: pw.TextStyle(fontSize: 8, color: tc)),
        ),
      ]);

  void _snack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(16),
    ));
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  BUILD
  // ══════════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
      width: widget.width,
      height: widget.height,
      color: _surface,
      child: Stack(children: [
        SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
              16, 16, 16, 16 + MediaQuery.of(context).padding.bottom),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            _buildHeader(),
            const SizedBox(height: 16),
            _buildPartySection(),
            const SizedBox(height: 16),
            _buildMesOs(),
            const SizedBox(height: 16),
            _buildItensSection(),
            const SizedBox(height: 16),
            _buildRecebimentoSection(),
            const SizedBox(height: 16),
            if (_ok) _buildSucesso(),
            if (_erro != null) _buildErro(),
            const SizedBox(height: 16),
            _buildBotao(),
            const SizedBox(height: 24),
          ]),
        ),
        if (_enviando) _buildOverlay(),
      ]),
    ),
    );
  }

  // ── Cabeçalho ─────────────────────────────────────────────────────────────
  Widget _buildHeader() => Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [_primary, _primaryLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: _primary.withOpacity(0.28),
                blurRadius: 10,
                offset: const Offset(0, 4))
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Container(
            margin: const EdgeInsets.only(right: 14),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(8)),
            constraints: const BoxConstraints(maxWidth: 80, maxHeight: 48),
            child: Image.network(
              _HPS.logoUrl,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Icon(
                  Icons.inventory_2_outlined,
                  color: Colors.white,
                  size: 26),
            ),
          ),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                const Text('FORMULÁRIO DE RECEBIMENTO',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8)),
                const Text('DE MERCADORIAS',
                    style: TextStyle(
                        color: Color(0xFFB0BEC5),
                        fontSize: 12,
                        letterSpacing: 0.5)),
                if (_data != null)
                  Text(DateFormat('dd/MM/yyyy').format(_data!),
                      style: const TextStyle(
                          color: Color(0xFFB0BEC5), fontSize: 11)),
              ])),
          if (_cli != null && _cli!.photoUrl.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(left: 12),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(8)),
              constraints: const BoxConstraints(maxWidth: 120, maxHeight: 56),
              child: Image.network(_cli!.photoUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink()),
            ),
        ]),
      );

  // ── Fornecedor + Cliente ──────────────────────────────────────────────────
  Widget _buildPartySection() => LayoutBuilder(builder: (ctx, c) {
        if (c.maxWidth > 640) {
          return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(child: _buildFornecedorCard()),
            const SizedBox(width: 12),
            Expanded(child: _buildClienteCard()),
          ]);
        }
        return Column(children: [
          _buildFornecedorCard(),
          const SizedBox(height: 12),
          _buildClienteCard(),
        ]);
      });

  Widget _buildFornecedorCard() => _cardShell(
        titulo: 'FORNECEDOR',
        icone: Icons.local_shipping_outlined,
        headerColor: _primary,
        child: Column(children: [
          _infoRow('Nome / Razão Social', _HPS.nome),
          _row2(
              _infoRow('CNPJ', _HPS.cnpj), _infoRow('Telefone', _HPS.telefone)),
          _infoRow('Endereço', _HPS.endereco),
          _row2(_infoRow('CEP', _HPS.cep), _infoRow('Cidade', _HPS.cidade)),
        ]),
      );

  Widget _buildClienteCard() => _cardShell(
        titulo: 'CLIENTE',
        icone: Icons.business_outlined,
        headerColor: _cliColor,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _fieldLabel('Razão Social'),
          const SizedBox(height: 3),
          if (_loadingUsers)
            const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Row(children: [
                  SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: _accent)),
                  SizedBox(width: 10),
                  Text('Carregando clientes...',
                      style: TextStyle(fontSize: 12, color: _textMid)),
                ]))
          else if (_erroUsers != null)
            Row(children: [
              const Icon(Icons.error_outline, size: 16, color: Colors.red),
              const SizedBox(width: 6),
              Expanded(
                  child: Text('Erro: $_erroUsers',
                      style: const TextStyle(fontSize: 11, color: Colors.red))),
              TextButton(
                  onPressed: () {
                    setState(() {
                      _loadingUsers = true;
                      _erroUsers = null;
                    });
                    _carregarUsuarios();
                  },
                  child: const Text('Tentar novamente')),
            ])
          else
            _buildDropdown(),
          if (_cli != null) ...[
            const SizedBox(height: 6),
            _row2(_infoRow('CNPJ', _cli!.cnpj),
                _infoRow('Telefone', _cli!.telefone)),
            _infoRow('Endereço', _cli!.enderecoCompleto),
            _row2(_infoRow('CEP', _cli!.cep), _infoRow('Cidade', _cli!.cidade)),
          ] else ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                  color: _cardBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _border)),
              child: const Center(
                  child: Text('Selecione um cliente para preencher os dados',
                      style: TextStyle(fontSize: 12, color: _textMid),
                      textAlign: TextAlign.center)),
            ),
          ],
        ]),
      );

  Widget _buildDropdown() => Column(children: [
        TextFormField(
          controller: _searchCtrl,
          onChanged: _filtrar,
          onTap: () => setState(() => _showDrop = true),
          style: const TextStyle(fontSize: 13, color: _textDark),
          decoration: InputDecoration(
            hintText: 'Buscar por nome, CNPJ ou e-mail...',
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 12),
            prefixIcon: const Icon(Icons.search, size: 18, color: _accent),
            suffixIcon: _cli != null || _searchCtrl.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close, size: 16, color: Colors.grey),
                    onPressed: _limparCliente)
                : null,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            filled: true,
            fillColor: _cardBg,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(7),
                borderSide: const BorderSide(color: _border)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(7),
                borderSide: const BorderSide(color: _border)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(7),
                borderSide: const BorderSide(color: _cliColor, width: 1.5)),
            isDense: true,
          ),
        ),
        if (_showDrop && _cli == null)
          Container(
            margin: const EdgeInsets.only(top: 2),
            constraints: const BoxConstraints(maxHeight: 210),
            decoration: BoxDecoration(
              color: _cardBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _border),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 3))
              ],
            ),
            child: _filtrados.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(14),
                    child: Text('Nenhum cliente encontrado.',
                        style: TextStyle(fontSize: 12, color: _textMid)))
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: _filtrados.length,
                    itemBuilder: (ctx, i) {
                      final u = _filtrados[i];
                      return InkWell(
                        onTap: () => _selecionarCliente(u),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 9),
                          decoration: BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                                      color: _border.withOpacity(0.5)))),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(u.displayName,
                                    style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: _textDark)),
                                if (u.cnpj.isNotEmpty)
                                  Text('CNPJ: ${u.cnpj}',
                                      style: const TextStyle(
                                          fontSize: 10, color: _textMid)),
                              ]),
                        ),
                      );
                    },
                  ),
          ),
      ]);

  // ── Mês + Nº OS ──────────────────────────────────────────────────────────
  Widget _buildMesOs() => _cardShell(
        titulo: 'REFERÊNCIA',
        icone: Icons.calendar_month_outlined,
        headerColor: _primary,
        child: _row2(
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _fieldLabel('Mês de Referência'),
            const SizedBox(height: 3),
            GestureDetector(
              onTap: () => _abrirSelecaoMes(),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                decoration: BoxDecoration(
                    color: _surface,
                    borderRadius: BorderRadius.circular(7),
                    border: Border.all(color: _border)),
                child: Row(children: [
                  const Icon(Icons.calendar_today_outlined,
                      size: 14, color: _accent),
                  const SizedBox(width: 6),
                  Text(_mesSelecionado,
                      style: const TextStyle(fontSize: 13, color: _textDark)),
                  const Spacer(),
                  const Icon(Icons.keyboard_arrow_down,
                      size: 16, color: _accent),
                ]),
              ),
            ),
          ]),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _fieldLabel('Nº da O.S. (opcional)'),
            const SizedBox(height: 3),
            TextFormField(
              controller: _numeroOsCtrl,
              textCapitalization: TextCapitalization.characters,
              onChanged: (_) => setState(() {}),
              style: const TextStyle(
                  fontSize: 13, color: _textDark, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                hintText: 'Ex: 1042',
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                prefixIcon: const Icon(Icons.tag, size: 16, color: _accent),
                filled: true,
                fillColor: _surface,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(7),
                    borderSide: const BorderSide(color: _border)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(7),
                    borderSide: const BorderSide(color: _border)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(7),
                    borderSide: const BorderSide(color: _primary, width: 1.5)),
                isDense: true,
              ),
            ),
          ]),
        ),
      );

  void _abrirSelecaoMes() {
    showModalBottomSheet(
      context: context,
      isDismissible: true,
      enableDrag: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => ListView(shrinkWrap: true, children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text('Selecionar Mês',
              style: TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w700, color: _textDark)),
        ),
        ..._meses.map((m) => ListTile(
              title: Text(m),
              trailing: m == _mesSelecionado
                  ? const Icon(Icons.check, color: _primary)
                  : null,
              onTap: () {
                setState(() => _mesSelecionado = m);
                Navigator.pop(context);
              },
            )),
        const SizedBox(height: 16),
      ]),
    );
  }

  // ── Tabela itens ──────────────────────────────────────────────────────────
  Widget _buildItensSection() => Container(
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _border),
          boxShadow: [
            BoxShadow(
                color: _primary.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ],
        ),
        child: Column(children: [
          _sectionHeader('DESCRIÇÃO DA MERCADORIA', Icons.list_alt),
          Container(
            color: const Color(0xFFEEF1F5),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(children: [
              Expanded(flex: 10, child: Text('CÓDIGO', style: _colStyle)),
              Expanded(flex: 28, child: Text('DESCRIÇÃO', style: _colStyle)),
              Expanded(
                  flex: 9,
                  child: Text('QTDE',
                      textAlign: TextAlign.center, style: _colStyle)),
              Expanded(
                  flex: 13,
                  child: Text('VL. UNIT.',
                      textAlign: TextAlign.right, style: _colStyle)),
              Expanded(
                  flex: 13,
                  child: Text('VL. TOTAL',
                      textAlign: TextAlign.right, style: _colStyle)),
              const SizedBox(width: 32),
            ]),
          ),
          ...List.generate(_itens.length, (i) => _buildItemRow(i)),
          if (_itens.isEmpty)
            Container(
              color: _cardBg,
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: const Center(
                  child: Text(
                      'Nenhum item adicionado. Clique em "+ Adicionar item".',
                      style:
                          TextStyle(fontSize: 12, color: Color(0xFF9EAAB5)))),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(children: [
              TextButton.icon(
                onPressed: () => setState(_addItem),
                icon: const Icon(Icons.add_circle_outline,
                    size: 16, color: _accent),
                label: const Text('Adicionar item',
                    style: TextStyle(
                        fontSize: 12,
                        color: _accent,
                        fontWeight: FontWeight.w600)),
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7),
                      side: const BorderSide(color: _accent)),
                ),
              ),
              const Spacer(),
              const Text('TOTAL GERAL',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: _textMid,
                      letterSpacing: 0.5)),
              const SizedBox(width: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                    color: _primary, borderRadius: BorderRadius.circular(8)),
                child: Text(_fmt(_totalGeral),
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
              ),
              const SizedBox(width: 36),
            ]),
          ),
        ]),
      );

  static const _colStyle = TextStyle(
      fontSize: 9,
      fontWeight: FontWeight.w700,
      color: _primary,
      letterSpacing: 0.5);

  Widget _buildItemRow(int i) {
    final tot = _totalLinha(i);
    return Container(
      color: i.isEven ? Colors.white : const Color(0xFFF5F6F8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: Row(children: [
        Expanded(
            flex: 10, child: _itemInput(_itens[i]['codigo']!, hint: 'Cód.')),
        const SizedBox(width: 4),
        Expanded(
            flex: 28,
            child: _itemInput(_itens[i]['descricao']!, hint: 'Descrição')),
        const SizedBox(width: 4),
        Expanded(
            flex: 9,
            child: _itemInput(_itens[i]['quantidade']!,
                hint: '0', keyboard: TextInputType.number)),
        const SizedBox(width: 4),
        Expanded(
            flex: 13,
            child: _itemInput(_itens[i]['valorUnitario']!,
                hint: '0,00', keyboard: TextInputType.number)),
        const SizedBox(width: 4),
        Expanded(
          flex: 13,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
            decoration: BoxDecoration(
              color:
                  tot > 0 ? _primary.withOpacity(0.07) : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(tot > 0 ? _fmt(tot) : '–',
                textAlign: TextAlign.right,
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: tot > 0 ? _primary : Colors.grey)),
          ),
        ),
        SizedBox(
            width: 32,
            child: IconButton(
              icon: const Icon(Icons.remove_circle_outline,
                  size: 18, color: Colors.red),
              padding: EdgeInsets.zero,
              onPressed: () => _removeItem(i),
            )),
      ]),
    );
  }

  Widget _itemInput(TextEditingController c,
          {String hint = '', TextInputType? keyboard}) =>
      TextFormField(
        controller: c,
        onChanged: (_) => setState(() {}),
        keyboardType: keyboard,
        style: const TextStyle(fontSize: 12, color: _textDark),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 11),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          filled: true,
          fillColor: _surface,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: _border)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: _border)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: _primary, width: 1.5)),
          isDense: true,
        ),
      );

  // ── Recebimento ───────────────────────────────────────────────────────────
  Widget _buildRecebimentoSection() => Container(
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _border),
          boxShadow: [
            BoxShadow(
                color: _primary.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _sectionHeader(
              'RECEBIMENTO DA MERCADORIA', Icons.assignment_turned_in_outlined),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(children: [
              // Recebedor + Crachá
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(
                    flex: 3,
                    child: _inputEditable('Recebedor', _recebedor,
                        hint: 'Nome do recebedor...')),
                const SizedBox(width: 10),
                Expanded(
                    flex: 2,
                    child:
                        _inputEditable('Nº Crachá', _cracha, hint: 'Ex: 1234')),
              ]),
              const SizedBox(height: 10),
              // Setor + Data
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(
                    flex: 3,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _fieldLabel('Setor'),
                          const SizedBox(height: 3),
                          TextFormField(
                            controller: _setor,
                            onChanged: (_) => setState(() {}),
                            style:
                                const TextStyle(fontSize: 13, color: _textDark),
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 10),
                              filled: true,
                              fillColor: _surface,
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(7),
                                  borderSide: const BorderSide(color: _border)),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(7),
                                  borderSide: const BorderSide(color: _border)),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(7),
                                  borderSide: const BorderSide(
                                      color: _primary, width: 1.5)),
                              isDense: true,
                            ),
                          ),
                        ])),
                const SizedBox(width: 10),
                Expanded(
                    flex: 2,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _fieldLabel('Data'),
                          const SizedBox(height: 3),
                          GestureDetector(
                            onTap: () async {
                              final p = await showDatePicker(
                                context: context,
                                initialDate: _data ?? DateTime.now(),
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2030),
                                locale: const Locale('pt', 'BR'),
                              );
                              if (p != null) {
                                setState(() => _data = p);
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 10),
                              decoration: BoxDecoration(
                                  color: _surface,
                                  borderRadius: BorderRadius.circular(7),
                                  border: Border.all(color: _border)),
                              child: Row(children: [
                                const Icon(Icons.calendar_today_outlined,
                                    size: 14, color: _accent),
                                const SizedBox(width: 6),
                                Text(
                                  _data != null
                                      ? DateFormat('dd/MM/yyyy').format(_data!)
                                      : 'Selecionar',
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: _data != null
                                          ? _textDark
                                          : Colors.grey),
                                ),
                              ]),
                            ),
                          ),
                        ])),
              ]),
              const SizedBox(height: 12),
              // ── Assinatura ─────────────────────────────────────
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _fieldLabel('Assinatura'),
                const SizedBox(height: 6),
                Row(children: [
                  _toggleSign(
                      label: 'Texto',
                      icone: Icons.edit_outlined,
                      ativo: !_usarDigital,
                      onTap: () => setState(() => _usarDigital = false)),
                  const SizedBox(width: 8),
                  _toggleSign(
                      label: 'Assinatura digital',
                      icone: Icons.draw_outlined,
                      ativo: _usarDigital,
                      onTap: () => setState(() => _usarDigital = true)),
                ]),
                const SizedBox(height: 8),
                if (!_usarDigital)
                  TextFormField(
                    controller: _assinatura,
                    onChanged: (_) => setState(() {}),
                    style: const TextStyle(fontSize: 13, color: _textDark),
                    decoration: InputDecoration(
                      hintText: 'Nome do responsável...',
                      hintStyle:
                          TextStyle(color: Colors.grey.shade400, fontSize: 12),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 10),
                      filled: true,
                      fillColor: _surface,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(7),
                          borderSide: const BorderSide(color: _border)),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(7),
                          borderSide: const BorderSide(color: _border)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(7),
                          borderSide:
                              const BorderSide(color: _primary, width: 1.5)),
                      isDense: true,
                    ),
                  )
                else
                  _buildSignPad(),
              ]),
            ]),
          ),
        ]),
      );

  Widget _toggleSign(
          {required String label,
          required IconData icone,
          required bool ativo,
          required VoidCallback onTap}) =>
      GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: ativo ? _primary : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: ativo ? _primary : _border, width: 1.5),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(icone, size: 15, color: ativo ? Colors.white : _textMid),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: ativo ? Colors.white : _textMid)),
          ]),
        ),
      );

  // ── Pad de assinatura: preview somente-leitura + botão para abrir sheet ───
  Widget _buildSignPad() {
    final has = _strokes.isNotEmpty;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Preview (somente leitura — toque abre a sheet)
      GestureDetector(
        onTap: _abrirAssinaturaSheet,
        child: Container(
          height: 120,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: has ? _primary : _border,
              width: has ? 1.8 : 1.2,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(7),
            child: Stack(children: [
              // Linha-guia tracejada (sempre visível)
              CustomPaint(
                painter: _SignatureLinePainter(lineFraction: 0.75),
                child: const SizedBox.expand(),
              ),
              if (!has)
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.draw_outlined,
                          size: 28, color: Color(0xFFB0BEC5)),
                      SizedBox(height: 6),
                      Text(
                        'Toque para assinar',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFFB0BEC5),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                )
              else
                // Escala os traços para o tamanho do preview
                CustomPaint(
                  painter: _SignaturePainter(
                    strokes: List.from(_strokes),
                    capturedSize: _padCapturedSize,
                  ),
                  child: const SizedBox.expand(),
                ),
            ]),
          ),
        ),
      ),
      const SizedBox(height: 6),
      Row(children: [
        TextButton.icon(
          onPressed: _abrirAssinaturaSheet,
          icon: const Icon(Icons.edit, size: 15, color: _accent),
          label: Text(
            has ? 'Editar assinatura' : 'Abrir pad de assinatura',
            style: const TextStyle(fontSize: 12, color: _accent),
          ),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          ),
        ),
        const Spacer(),
        if (has)
          TextButton.icon(
            onPressed: () => setState(() {
              _strokes.clear();
              _currentStroke = [];
            }),
            icon: Icon(Icons.refresh, size: 15, color: Colors.red.shade400),
            label: Text('Limpar',
                style: TextStyle(fontSize: 12, color: Colors.red.shade400)),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            ),
          ),
      ]),
    ]);
  }

  // ── Bottom sheet fixa para assinatura — Tela Cheia (Safe Area) ────────
  void _abrirAssinaturaSheet() {
    // Cópia local dos traços para edição dentro da sheet
    final List<List<Offset?>> strokesTemp =
        _strokes.map((s) => List<Offset?>.from(s)).toList();
    List<Offset?> currentStrokeTemp = [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Habilita ocupar 100% da tela
      isDismissible: false, // evita fechar acidentalmente ao assinar
      enableDrag: false, // desabilita drag — conflita com a caneta
      useSafeArea: true,
      backgroundColor:
          Colors.black, // Fundo preto fora da SafeArea fica mais premium
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            final hasStrokes = strokesTemp.isNotEmpty;

            return SafeArea(
              // O SafeArea garante que o app não vai encostar no notch da câmera ou na barra do sistema
              child: Container(
                height: MediaQuery.of(context)
                    .size
                    .height, // Ocupa 100% da altura disponível
                width: double.infinity, // Ocupa 100% da largura
                color: Colors.white, // Fundo da tela todo branco
                child: Column(children: [
                  // ── Cabeçalho ─────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 14),
                    color:
                        _primary, // Removido o BorderRadius para colar no topo da tela
                    child: Row(children: [
                      const Icon(Icons.draw_outlined,
                          color: Colors.white, size: 18),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'ASSINATURA DIGITAL',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      if (hasStrokes)
                        TextButton.icon(
                          onPressed: () => setSheetState(() {
                            strokesTemp.clear();
                            currentStrokeTemp = [];
                          }),
                          icon: Icon(Icons.refresh,
                              size: 15, color: Colors.red.shade200),
                          label: Text('Limpar',
                              style: TextStyle(
                                  fontSize: 12, color: Colors.red.shade200)),
                          style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4)),
                        ),
                      const SizedBox(width: 4),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        tooltip: 'Fechar',
                        onPressed: () => Navigator.pop(sheetCtx),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ]),
                  ),

                  // ── Instrução Atualizada ──────────────────────────────
                  Container(
                    width: double.infinity,
                    color: const Color(0xFFEEF1F5),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(children: const [
                      Icon(Icons.screen_rotation, size: 13, color: _textMid),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Gire o celular na horizontal para assinar com mais espaço.',
                          style: TextStyle(
                              fontSize: 11,
                              color: _textMid,
                              fontStyle: FontStyle.italic),
                        ),
                      ),
                    ]),
                  ),

                  // ── Área de desenho ───────────────────────────────
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: hasStrokes ? _primary : _border,
                            width: hasStrokes ? 2 : 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: _primary.withOpacity(0.06),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(11),
                          // A MÁGICA AQUI: RotatedBox gira apenas o conteúdo interno em 90 graus
                          child: RotatedBox(
                            quarterTurns: 1,
                            child: LayoutBuilder(
                              builder: (_, constraints) {
                                final padSize = Size(
                                  constraints.maxWidth,
                                  constraints.maxHeight,
                                );
                                return Stack(children: [
                                  // Grade de fundo
                                  CustomPaint(
                                    painter: _GridPainter(),
                                    child: const SizedBox.expand(),
                                  ),
                                  // Linha-guia tracejada com marcador X
                                  CustomPaint(
                                    painter: _SignatureLinePainter(
                                      lineFraction: 0.72,
                                      lineColor: const Color(0xFFAEC6CF),
                                      labelColor: const Color(0xFFB0BEC5),
                                    ),
                                    child: const SizedBox.expand(),
                                  ),
                                  // Placeholder
                                  if (!hasStrokes)
                                    const Center(
                                      child: Text(
                                        'Assine aqui',
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: Color(0xFFCCD5DC),
                                            fontStyle: FontStyle.italic),
                                      ),
                                    ),
                                  // Listener isolado — sem competição com scroll
                                  Listener(
                                    behavior: HitTestBehavior.opaque,
                                    onPointerDown: (e) {
                                      setSheetState(() {
                                        currentStrokeTemp = [e.localPosition];
                                        strokesTemp.add(currentStrokeTemp);
                                      });
                                    },
                                    onPointerMove: (e) {
                                      setSheetState(() {
                                        currentStrokeTemp.add(e.localPosition);
                                      });
                                    },
                                    onPointerUp: (_) {
                                      setSheetState(() {
                                        currentStrokeTemp.add(null);
                                      });
                                      // Grava o tamanho real do pad a cada traço
                                      // para que o preview possa escalar corretamente
                                      setState(
                                          () => _padCapturedSize = padSize);
                                    },
                                    child: CustomPaint(
                                      painter: _SignaturePainter(
                                          strokes: List.from(strokesTemp)),
                                      child: const SizedBox.expand(),
                                    ),
                                  ),
                                ]);
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ── Botões ────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                    child: Row(children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(sheetCtx),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            side: const BorderSide(color: _border, width: 1.5),
                          ),
                          child: const Text(
                            'Cancelar',
                            style: TextStyle(
                                fontSize: 13,
                                color: _textMid,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          onPressed: hasStrokes
                              ? () {
                                  setState(() {
                                    _strokes.clear();
                                    _strokes.addAll(strokesTemp);
                                    _currentStroke = [];
                                    // _padCapturedSize já foi salvo via onPointerUp
                                  });
                                  Navigator.pop(sheetCtx);
                                }
                              : null,
                          icon:
                              const Icon(Icons.check_circle_outline, size: 18),
                          label: const Text(
                            'Confirmar Assinatura',
                            style: TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w700),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _verde,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.grey.shade200,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            elevation: 3,
                            shadowColor: _verde.withOpacity(0.3),
                          ),
                        ),
                      ),
                    ]),
                  ),
                ]),
              ),
            );
          },
        );
      },
    );
  }

  // ── Sucesso / Erro ────────────────────────────────────────────────────────
  Widget _buildSucesso() => Column(children: [
        _faixa(_verde, Icons.check_circle_outline,
            'PDF salvo no Storage com sucesso!'),
        const SizedBox(height: 8),
        _faixa(_primary, Icons.notifications_active_outlined,
            'Notificação registrada para ${_cli?.email ?? ''}.'),
        const SizedBox(height: 8),
        _faixa(const Color(0xFFB45309), Icons.campaign_outlined,
            'Push OneSignal enviado.'),
        const SizedBox(height: 8),
        _faixa(
            const Color(0xFF546E7A),
            Icons.info_outline,
            'O email será enviado automaticamente ao emitir o documento'
            ' no Upload de Documentos.'),
      ]);

  Widget _buildErro() => _faixa(Colors.redAccent, Icons.error_outline, _erro!);

  Widget _faixa(Color cor, IconData icone, String msg) => Container(
        margin: const EdgeInsets.only(bottom: 4),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: cor.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: cor.withOpacity(0.35)),
        ),
        child: Row(children: [
          Icon(icone, color: cor, size: 18),
          const SizedBox(width: 10),
          Expanded(
              child: Text(msg,
                  style: TextStyle(
                      color: cor, fontSize: 12, fontWeight: FontWeight.w500))),
        ]),
      );

  // ── Botão Gerar/Enviar PDF ────────────────────────────────────────────────
  Widget _buildBotao() => ElevatedButton.icon(
        onPressed: _enviando ? null : _gerarEEnviar,
        icon: _enviando
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white))
            : const Icon(Icons.picture_as_pdf_outlined, size: 20),
        label: Text(_enviando ? 'Gerando...' : 'GERAR E ENVIAR PDF',
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 1)),
        style: ElevatedButton.styleFrom(
          backgroundColor: _cli != null ? _primary : Colors.grey.shade300,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey.shade300,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 4,
          shadowColor: _primary.withOpacity(0.3),
        ),
      );

  // ── Overlay de progresso ──────────────────────────────────────────────────
  Widget _buildOverlay() => Positioned.fill(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            color: Colors.black.withOpacity(0.55),
            child: Center(
                child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 32),
              padding: const EdgeInsets.all(26),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.12), blurRadius: 24)
                  ]),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                      color: _primary.withOpacity(0.12),
                      shape: BoxShape.circle),
                  child: const Icon(Icons.picture_as_pdf_outlined,
                      color: _primary, size: 32),
                ),
                const SizedBox(height: 16),
                const Text('Gerando PDF',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _textDark)),
                const SizedBox(height: 6),
                Text(_progLabel,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 13, color: _textMid)),
                const SizedBox(height: 20),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: _prog,
                    minHeight: 10,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: const AlwaysStoppedAnimation<Color>(_primary),
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                    alignment: Alignment.centerRight,
                    child: Text('${(_prog * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(
                            fontSize: 12,
                            color: _primary,
                            fontWeight: FontWeight.bold))),
              ]),
            )),
          ),
        ),
      );

  // ─── UI helpers ──────────────────────────────────────────────────────────
  Widget _sectionHeader(String titulo, IconData icone) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: const BoxDecoration(
            color: _primary,
            borderRadius: BorderRadius.vertical(top: Radius.circular(11))),
        child: Row(children: [
          Icon(icone, color: Colors.white, size: 15),
          const SizedBox(width: 8),
          Text(titulo,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1)),
        ]),
      );

  Widget _cardShell(
          {required String titulo,
          required IconData icone,
          required Color headerColor,
          required Widget child}) =>
      Container(
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _border),
          boxShadow: [
            BoxShadow(
                color: headerColor.withOpacity(0.07),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
                color: headerColor,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(11))),
            child: Row(children: [
              Icon(icone, color: Colors.white, size: 15),
              const SizedBox(width: 8),
              Text(titulo,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1)),
            ]),
          ),
          Padding(padding: const EdgeInsets.all(12), child: child),
        ]),
      );

  Widget _inputEditable(String label, TextEditingController ctrl,
          {String hint = ''}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _fieldLabel(label),
          const SizedBox(height: 3),
          TextFormField(
            controller: ctrl,
            onChanged: (_) => setState(() {}),
            style: const TextStyle(fontSize: 13, color: _textDark),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 12),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              filled: true,
              fillColor: _surface,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(7),
                  borderSide: const BorderSide(color: _border)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(7),
                  borderSide: const BorderSide(color: _border)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(7),
                  borderSide: const BorderSide(color: _primary, width: 1.5)),
              isDense: true,
            ),
          ),
        ]),
      );

  Widget _fieldLabel(String label) => Text(label.toUpperCase(),
      style: const TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: Color(0xFF546E7A),
          letterSpacing: 0.5));

  Widget _infoRow(String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 7),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _fieldLabel(label),
          const SizedBox(height: 3),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
                color: _surface,
                borderRadius: BorderRadius.circular(7),
                border: Border.all(color: _border)),
            child: Text(value.isEmpty ? '—' : value,
                style: TextStyle(
                    fontSize: 12,
                    color: value.isEmpty ? Colors.grey : _textDark)),
          ),
        ]),
      );

  Widget _row2(Widget a, Widget b) =>
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(
            child: Padding(padding: const EdgeInsets.only(right: 6), child: a)),
        Expanded(child: b),
      ]);
}
