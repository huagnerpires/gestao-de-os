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

import '/custom_code/widgets/index.dart';
import '/custom_code/actions/index.dart';
import '/flutter_flow/custom_functions.dart';

import 'index.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import '/custom_code/actions/index.dart' as actions;
import '/components/resetar_senha_widget.dart';
import '/components/add_tecnico_widget.dart';
import '/components/adicionarservico_widget.dart';
import '/components/listar_permissao_widget.dart';
import '/components/equipamento_dropdown_widget.dart';
import '/components/relatorio_financeiro_widget.dart';
import '/components/pdf_que_falta_widget.dart';
import '/components/cadastrar_novo_sem_erro_widget.dart';
import '/components/teste_preventivas_widget.dart';
import '/components/cadastrar_equipamento_customwidget_widget.dart';
import '/components/usuario_novo_widget.dart';
import '/components/email_novo_widget.dart';
import '/components/email_nova_widget.dart';
import '/components/preventivas_penden_widget.dart';
import '/components/imagens_widget.dart';
import '/components/editar_preventiva_widget.dart';
import '/components/enviar_notas_widget.dart';
import '/components/formulario_widget.dart';
import '/components/os_custom_e_x_c_l_u_i_r_widget.dart';
import '/index.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SISTEMA DE DESIGN — TOKENS ADAPTATIVOS DARK / LIGHT
// ─────────────────────────────────────────────────────────────────────────────

class _T {
  static bool dark(BuildContext ctx) =>
      Theme.of(ctx).brightness == Brightness.dark;

  static Color bg(BuildContext ctx) => dark(ctx) ? Colors.black : Colors.white;
  static Color surface(BuildContext ctx) =>
      dark(ctx) ? const Color(0xFF121212) : const Color(0xFFFAFAFA);
  static Color surface2(BuildContext ctx) =>
      dark(ctx) ? const Color(0xFF1E1E1E) : const Color(0xFFF0F0F0);
  static Color surface3(BuildContext ctx) =>
      dark(ctx) ? const Color(0xFF2A2A2A) : const Color(0xFFE8E8E8);

  static Color border(BuildContext ctx) =>
      dark(ctx) ? const Color(0xFF333333) : const Color(0xFFE0E0E0);
  static Color borderFocus(BuildContext ctx) =>
      dark(ctx) ? const Color(0xFF555555) : const Color(0xFFBBBBBB);

  static Color textPrimary(BuildContext ctx) =>
      dark(ctx) ? Colors.white : Colors.black;
  static Color textSecondary(BuildContext ctx) =>
      dark(ctx) ? Colors.grey[400]! : Colors.grey[600]!;
  static Color textHint(BuildContext ctx) =>
      dark(ctx) ? Colors.grey[700]! : Colors.grey[400]!;

  static const primary = Color(0xFF0F766E);
  static const primaryDark = Color(0xFF0F766E);
  static const accent = Color(0xFF3730A3);
  static const accentSoft = Color(0xFF64748B);
  static const earn = Color(0xFF047857);
  static const spend = Color(0xFFB91C1C);
  static const warn = Color(0xFFC2410C);
  static const info = Color(0xFF0369A1);

  static const gradPrimary = [Color(0xFF0F766E), Color(0xFF0369A1)];
  static const gradSpend = [Color(0xFFB91C1C), Color(0xFFB45309)];
  static const gradEarn = [Color(0xFF047857), Color(0xFF3730A3)];
  static const gradNeg = [Color(0xFF991B1B), Color(0xFFB91C1C)];

  static BoxDecoration cardDeco(BuildContext ctx,
          {Color? accent, double radius = 16}) =>
      BoxDecoration(
        color: surface(ctx),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
            color: accent != null ? accent.withOpacity(0.22) : border(ctx)),
        boxShadow: dark(ctx)
            ? [
                BoxShadow(
                    color: Colors.black.withOpacity(0.18),
                    blurRadius: 12,
                    offset: const Offset(0, 4))
              ]
            : [
                BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 3))
              ],
      );

  static InputDecoration inputDeco(BuildContext ctx, String label,
          {IconData? icon}) =>
      InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: textSecondary(ctx), fontSize: 13),
        prefixIcon: icon != null ? Icon(icon, size: 18, color: primary) : null,
        filled: true,
        fillColor: surface2(ctx),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: border(ctx))),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: border(ctx))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: primary, width: 1.5)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        isDense: true,
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// SHARED WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

class _GradientIcon extends StatelessWidget {
  final IconData icon;
  final List<Color> colors;
  final double size;
  final double containerSize;
  final double radius;

  const _GradientIcon(
      {required this.icon,
      required this.colors,
      this.size = 18,
      this.containerSize = 36,
      this.radius = 10});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: containerSize,
      height: containerSize,
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Icon(icon, color: Colors.white, size: size),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final Color color;
  final bool compact;

  const _Pill(this.label, this.color, {this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: compact ? 6 : 8, vertical: compact ? 2 : 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.14),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: compact ? 9 : 10,
              fontWeight: FontWeight.w700,
              color: color)),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(text,
          style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: _T.textSecondary(context),
              letterSpacing: 0.6)),
    );
  }
}

class _TypingDots extends StatelessWidget {
  final AnimationController ctrl;
  const _TypingDots({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ctrl,
      builder: (_, __) {
        final t = ctrl.value;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final raw = t - i * 0.28;
            final phase = raw < 0.0
                ? 0.0
                : raw > 1.0
                    ? 1.0
                    : raw;
            final scale =
                1.0 + 0.45 * (phase < 0.5 ? phase * 2 : (1 - phase) * 2);
            return Transform.scale(
              scale: scale,
              child: Container(
                width: 7,
                height: 7,
                margin: const EdgeInsets.symmetric(horizontal: 2.5),
                decoration: BoxDecoration(
                  color: _T.primary.withOpacity(0.4 + 0.6 * (scale - 1) / 0.45),
                  shape: BoxShape.circle,
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MODELOS
// ─────────────────────────────────────────────────────────────────────────────

enum MsgStatus { sending, sent, error }

enum FinType { gasto, receber }

class FinRecord {
  final String id;
  final FinType type;
  final double valor;
  final String setor;
  final String data;
  final String hora;
  final String quem;
  final String descricao;
  final bool pago;
  final DateTime createdAt;

  FinRecord({
    String? id,
    required this.type,
    required this.valor,
    required this.setor,
    required this.data,
    required this.hora,
    required this.quem,
    required this.descricao,
    this.pago = false,
    DateTime? createdAt,
  })  : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'id': id,
        'type': type.name,
        'value': valor,
        'sector': setor,
        'date': data,
        'time': hora,
        'who': quem,
        'description': descricao,
        'paid': pago,
        'createdAt': createdAt.toIso8601String(),
      };

  factory FinRecord.fromMap(Map<String, dynamic> m) => FinRecord(
        id: m['id'],
        type: m['type'] == 'receber' ? FinType.receber : FinType.gasto,
        valor: (m['value'] as num?)?.toDouble() ?? 0.0,
        setor: m['sector'] ?? 'Geral',
        data: m['date'] ?? '',
        hora: m['time'] ?? '',
        quem: m['who'] ?? '',
        descricao: m['description'] ?? '',
        pago: m['paid'] ?? false,
        createdAt: m['createdAt'] != null
            ? DateTime.tryParse(m['createdAt']) ?? DateTime.now()
            : DateTime.now(),
      );
}

class ChatMsg {
  final String id;
  final String text;
  final bool isUser;
  final Uint8List? imageBytes;
  final DateTime timestamp;
  final MsgStatus status;

  ChatMsg({
    String? id,
    required this.text,
    required this.isUser,
    this.imageBytes,
    DateTime? timestamp,
    this.status = MsgStatus.sent,
  })  : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        timestamp = timestamp ?? DateTime.now();

  ChatMsg copyWith({MsgStatus? status, String? text}) => ChatMsg(
        id: id,
        text: text ?? this.text,
        isUser: isUser,
        imageBytes: imageBytes,
        timestamp: timestamp,
        status: status ?? this.status,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'text': text,
        'isUser': isUser,
        'timestamp': timestamp.toIso8601String(),
        'status': status.name,
      };

  factory ChatMsg.fromMap(Map<String, dynamic> m) => ChatMsg(
        id: m['id'],
        text: m['text'] ?? '',
        isUser: m['isUser'] ?? false,
        timestamp: m['timestamp'] != null
            ? DateTime.tryParse(m['timestamp']) ?? DateTime.now()
            : DateTime.now(),
        status: MsgStatus.values.firstWhere(
          (s) => s.name == m['status'],
          orElse: () => MsgStatus.sent,
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// WIDGET 1 — FirebaseAiFinanceWidget
// ─────────────────────────────────────────────────────────────────────────────

class FirebaseAiFinanceWidget extends StatefulWidget {
  const FirebaseAiFinanceWidget({Key? key, this.width, this.height})
      : super(key: key);
  final double? width;
  final double? height;

  @override
  State<FirebaseAiFinanceWidget> createState() =>
      _FirebaseAiFinanceWidgetState();
}

class _FirebaseAiFinanceWidgetState extends State<FirebaseAiFinanceWidget>
    with TickerProviderStateMixin {
  final TextEditingController _inputCtrl = TextEditingController();
  final FocusNode _inputFocus = FocusNode();
  final ScrollController _scrollCtrl = ScrollController();
  final ImagePicker _picker = ImagePicker();

  GenerativeModel? _model;
  ChatSession? _chat;
  bool _aiReady = false;
  String? _aiError;

  final List<ChatMsg> _messages = [];
  final List<FinRecord> _records = [];

  bool _loading = false;
  int _tabIndex = 0;

  Uint8List? _pendingBytes;
  String? _pendingMime;
  String? _pendingName;
  bool _pendingIsFile = false;

  late AnimationController _typingCtrl;
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;
  late TabController _tabCtrl;

  static const List<String> kSetores = [
    'Alimentação',
    'Assinaturas',
    'Casa',
    'Combustível',
    'Equipamentos',
    'Funcionário',
    'Hospedagem',
    'Impostos',
    'Limpeza',
    'Loja',
    'Manutenção',
    'Marketing',
    'Material',
    'Serviços',
    'Taxas Bancárias',
    'Transporte',
    'Vendas',
    'Outros',
  ];
  static const List<String> kSetoresReceber = [
    'Manutenção',
    'Preventiva',
    'Instalação',
    'Consultoria',
    'Peças',
    'Contrato',
    'Outros',
  ];

  static const _kRecords = 'hps_fin_records_v3';
  static const _kMessages = 'hps_fin_messages_v3';

  String get _systemPrompt {
    final now = DateTime.now();
    final date =
        '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
    final time =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    return '''Você é o Assistente Financeiro Executivo da HPS Refrigeração. Hoje é $date às $time.
OBJETIVO: Registrar GASTOS e CONTAS A RECEBER com precisão.
TIPOS: "gasto" = despesas; "receber" = valores a receber de clientes.
SETORES GASTOS: ${kSetores.join(', ')}
SETORES RECEBER: ${kSetoresReceber.join(', ')}
REGRAS: 1. Identifique automaticamente o tipo. 2. Pergunte quem se não souber. 3. Confirme dados ambíguos. 4. Extraia dados de imagens/PDFs.
FORMATO: Breve resumo + JSON no final se tiver todos os dados:
GASTO: {"registrar":true,"tipo":"gasto","valor":100.00,"setor":"Transporte","data":"$date","hora":"$time","quem":"Nome","descricao":"Descrição","pago":true}
RECEBER: {"registrar":true,"tipo":"receber","valor":500.00,"setor":"Manutenção","data":"$date","hora":"$time","quem":"Cliente","descricao":"Serviço","pago":false}
Use "." para decimais. Data DD/MM/AAAA, hora HH:MM.
IMPORTANTE: O campo "registrar" deve ser SEMPRE true quando tiver todos os dados necessários, independente do tipo ser gasto ou receber.''';
  }

  @override
  void initState() {
    super.initState();
    _typingCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1500))
      ..repeat();
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _tabCtrl = TabController(length: 2, vsync: this);
    _tabCtrl.addListener(() {
      if (mounted) setState(() => _tabIndex = _tabCtrl.index);
    });
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await _loadLocal();
    _initAI();
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _typingCtrl.dispose();
    _fadeCtrl.dispose();
    _inputCtrl.dispose();
    _inputFocus.dispose();
    _scrollCtrl.dispose();
    _tabCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rs = prefs.getString(_kRecords);
      if (rs != null && mounted) {
        final List raw = jsonDecode(rs);
        setState(() {
          _records.clear();
          _records.addAll(raw.map((e) => FinRecord.fromMap(e)));
        });
      }
      final ms = prefs.getString(_kMessages);
      if (ms != null && mounted) {
        final List raw = jsonDecode(ms);
        setState(() {
          _messages.clear();
          _messages.addAll(raw.map((m) => ChatMsg.fromMap(m)));
        });
      }
    } catch (e) {
      debugPrint('[Finance] load: $e');
    }
  }

  Future<void> _saveLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          _kRecords, jsonEncode(_records.map((r) => r.toMap()).toList()));
      final msgs = _messages.length > 500
          ? _messages.sublist(_messages.length - 500)
          : _messages;
      await prefs.setString(
          _kMessages, jsonEncode(msgs.map((m) => m.toMap()).toList()));
    } catch (e) {
      debugPrint('[Finance] save: $e');
    }
  }

  Future<void> _clearAll() async {
    final ok = await _confirm('Limpar histórico',
        'Apagará mensagens e registros locais. Firebase não será afetado.');
    if (!ok) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kRecords);
    await prefs.remove(_kMessages);
    if (mounted) {
      setState(() {
        _records.clear();
        _messages.clear();
        _chat = _model?.startChat();
      });
    }
    _addBot('🗑️ Histórico limpo. Como posso ajudar?');
  }

  static const String _appCheckFriendly =
      'A Inteligência Artificial está temporariamente indisponível. O Firebase exige App Check neste projeto. Toque em Tentar novamente ou peça ao administrador para ativar o App Check no console.';

  String _friendlyAiError(Object e, {String? fallback}) {
    final s = e.toString();
    if (s.contains('App Check') ||
        s.contains('deactivated') ||
        s.contains('Firebase AI Logic')) {
      return _appCheckFriendly;
    }
    return fallback ?? 'Falha ao iniciar IA: $e';
  }

  void _initAI() {
    try {
      _model = FirebaseAI.googleAI().generativeModel(
        model: 'gemini-2.0-flash', // ← CORRIGIDO: era gemini-2.5-flash
        systemInstruction: Content.system(_systemPrompt),
      );
      _chat = _model!.startChat();
      if (mounted) setState(() => _aiReady = true);
      if (_messages.isEmpty) {
        _addBot(
          '👋 Olá! Sou o **Assistente Financeiro HPS**.\n\n'
          'Posso registrar:\n'
          '• 💸 **Gastos** — despesas e compras\n'
          '• 💰 **Contas a Receber** — cobranças de clientes\n\n'
          'Envie foto de recibo, PDF ou descreva o lançamento.',
        );
      }
    } catch (e) {
      if (mounted) setState(() => _aiError = _friendlyAiError(e));
    }
  }

  void _addBot(String text, {MsgStatus status = MsgStatus.sent}) {
    if (!mounted) return;
    setState(() =>
        _messages.add(ChatMsg(text: text, isUser: false, status: status)));
    _scrollToBottom();
  }

  Future<void> _send() async {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty && _pendingBytes == null) return;
    if (_loading || _chat == null || !_aiReady) return;
    _inputCtrl.clear();

    final bytesToSend = _pendingBytes;
    final mimeToSend = _pendingMime ?? 'image/jpeg';
    final isFile = _pendingIsFile;
    final fileName = _pendingName;

    final userMsg = ChatMsg(
      text:
          text.isEmpty ? (isFile ? '📎 $fileName' : '📷 Imagem enviada') : text,
      isUser: true,
      imageBytes: isFile ? null : bytesToSend,
      status: MsgStatus.sending,
    );

    setState(() {
      _messages.add(userMsg);
      _pendingBytes = null;
      _pendingName = null;
      _loading = true;
    });
    _scrollToBottom();

    try {
      Content content;
      if (bytesToSend != null) {
        content = Content.multi([
          InlineDataPart(mimeToSend, bytesToSend),
          TextPart(text.isNotEmpty
              ? text
              : 'Analise e extraia os dados. Se não souber quem, pergunte.'),
        ]);
      } else {
        content = Content.text(text);
      }

      final response = await _chat!.sendMessage(content);
      String reply = response.text ?? 'Sem resposta.';
      reply = await _processReply(reply);

      if (mounted) {
        setState(() {
          _messages.add(ChatMsg(
            text: reply,
            isUser: false,
            status: MsgStatus.sent,
          ));
          final ui = _messages.indexWhere((m) => m.id == userMsg.id);
          if (ui != -1) {
            _messages[ui] = _messages[ui].copyWith(status: MsgStatus.sent);
          }
          _loading = false;
        });
      }
      _saveLocal();
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add(ChatMsg(
            text: _friendlyAiError(e, fallback: '❌ Erro. Tente novamente.'),
            isUser: false,
            status: MsgStatus.error,
          ));
          _loading = false;
        });
      }
      debugPrint('[Finance] send: $e');
    }
    _scrollToBottom();
  }

  Future<String> _processReply(String reply) async {
    String cleaned = reply
        .replaceAll(RegExp(r'```[a-z]*\n?', caseSensitive: false), '')
        .replaceAll('```', '');

    final s = cleaned.indexOf('{');
    final e = cleaned.lastIndexOf('}');
    if (s == -1 || e == -1 || s >= e) return cleaned.trim();

    try {
      final jsonStr = cleaned.substring(s, e + 1);
      final data = jsonDecode(jsonStr) as Map<String, dynamic>;

      final deveRegistrar = data['registrar'] == true || data['gasto'] == true;
      if (!deveRegistrar) return cleaned.trim();

      final tipoStr = (data['tipo'] ?? '').toString().toLowerCase().trim();
      final tipo = tipoStr == 'receber' ? FinType.receber : FinType.gasto;

      final now = DateTime.now();
      final date =
          '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
      final time =
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

      final rec = FinRecord(
        type: tipo,
        valor: (data['valor'] as num).toDouble(),
        setor: data['setor'] ?? 'Outros',
        data: data['data'] ?? date,
        hora: data['hora'] ?? time,
        quem: data['quem'] ?? 'Não informado',
        descricao: data['descricao'] ?? 'Registro',
        pago: data['pago'] ?? (tipo == FinType.gasto),
      );

      final col = tipo == FinType.receber ? 'financeiro_receber' : 'financeiro';

      await FirebaseFirestore.instance.collection(col).add({
        'valor': rec.valor,
        'setor': rec.setor,
        'data': rec.data,
        'hora': rec.hora,
        'quem': rec.quem,
        'descricao': rec.descricao,
        'pago': rec.pago,
        'tipo': rec.type.name,
        'criadoEm': FieldValue.serverTimestamp(),
        'origem': 'app_finance_ai',
      });

      if (mounted) {
        setState(() => _records.add(rec));
        final label = tipo == FinType.receber ? '💰 A receber' : '💸 Gasto';
        _showSnack(
            '$label registrado: R\$ ${rec.valor.toStringAsFixed(2)} — ${rec.quem}',
            isError: false);
      }

      return cleaned.substring(0, s).trim();
    } catch (e) {
      debugPrint('[Finance] JSON parse: $e');
      return cleaned.trim();
    }
  }

  Future<void> _pickCamera() async {
    try {
      final f = await _picker.pickImage(
          source: ImageSource.camera, imageQuality: 85, maxWidth: 1920);
      if (f != null && mounted) {
        final b = await f.readAsBytes();
        setState(() {
          _pendingBytes = b;
          _pendingName = f.name;
          _pendingMime = 'image/jpeg';
          _pendingIsFile = false;
        });
      }
    } catch (_) {
      _showSnack('Erro ao abrir câmera.', isError: true);
    }
  }

  Future<void> _pickGallery() async {
    try {
      final f = await _picker.pickImage(
          source: ImageSource.gallery, imageQuality: 85, maxWidth: 1920);
      if (f != null && mounted) {
        final b = await f.readAsBytes();
        setState(() {
          _pendingBytes = b;
          _pendingName = f.name;
          _pendingMime = 'image/jpeg';
          _pendingIsFile = false;
        });
      }
    } catch (_) {
      _showSnack('Erro ao acessar galeria.', isError: true);
    }
  }

  Future<void> _pickDoc() async {
    try {
      final r = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['pdf', 'txt'],
          withData: true);
      if (r != null && r.files.first.bytes != null && mounted) {
        setState(() {
          _pendingBytes = r.files.first.bytes;
          _pendingName = r.files.first.name;
          _pendingMime = r.files.first.extension == 'pdf'
              ? 'application/pdf'
              : 'text/plain';
          _pendingIsFile = true;
        });
      }
    } catch (_) {
      _showSnack('Erro ao selecionar arquivo.', isError: true);
    }
  }

  Future<void> _exportPdf() async {
    if (_records.isEmpty) {
      _showSnack('Nenhum dado para exportar.', isError: true);
      return;
    }
    final pdf = pw.Document();
    final now = DateTime.now();
    final dateStr =
        '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
    final gastos = _records.where((r) => r.type == FinType.gasto).toList();
    final receber = _records.where((r) => r.type == FinType.receber).toList();
    final totGasto = gastos.fold(0.0, (s, r) => s + r.valor);
    final totRec = receber.fold(0.0, (s, r) => s + r.valor);
    final totRecPago =
        receber.where((r) => r.pago).fold(0.0, (s, r) => s + r.valor);

    pdf.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      header: (_) => pw.Container(
        padding: const pw.EdgeInsets.only(bottom: 10),
        decoration: const pw.BoxDecoration(
            border: pw.Border(
                bottom: pw.BorderSide(color: PdfColors.teal700, width: 2))),
        child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('HPS Refrigeração',
                        style: pw.TextStyle(
                            fontSize: 16,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.teal700)),
                    pw.Text('Relatório Financeiro Completo',
                        style: const pw.TextStyle(
                            fontSize: 10, color: PdfColors.grey600)),
                  ]),
              pw.Text('Gerado em $dateStr',
                  style: const pw.TextStyle(
                      fontSize: 9, color: PdfColors.grey600)),
            ]),
      ),
      footer: (ctx) => pw.Align(
        alignment: pw.Alignment.centerRight,
        child: pw.Text('Página ${ctx.pageNumber}/${ctx.pagesCount}',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
      ),
      build: (_) => [
        pw.SizedBox(height: 14),
        pw.Row(children: [
          _pdfSummCard('Total Gastos', _fmtPdf(totGasto), PdfColors.red700),
          pw.SizedBox(width: 10),
          _pdfSummCard('A Receber', _fmtPdf(totRec), PdfColors.teal700),
          pw.SizedBox(width: 10),
          _pdfSummCard('Já Recebido', _fmtPdf(totRecPago), PdfColors.green700),
        ]),
        pw.SizedBox(height: 20),
        if (gastos.isNotEmpty) ...[
          pw.Text('Gastos',
              style:
                  pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 6),
          _pdfTable(gastos),
          pw.SizedBox(height: 20),
        ],
        if (receber.isNotEmpty) ...[
          pw.Text('Contas a Receber',
              style:
                  pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 6),
          _pdfTableRec(receber),
        ],
      ],
    ));
    await Printing.layoutPdf(onLayout: (_) => pdf.save());
  }

  String _fmtPdf(double v) =>
      'R\$ ${v.toStringAsFixed(2).replaceAll('.', ',')}';

  pw.Widget _pdfSummCard(String label, String value, PdfColor color) =>
      pw.Expanded(
          child: pw.Container(
        padding: const pw.EdgeInsets.all(12),
        decoration: pw.BoxDecoration(
            color: PdfColors.grey100,
            borderRadius: pw.BorderRadius.circular(8)),
        child: pw
            .Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Text(label,
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
          pw.SizedBox(height: 4),
          pw.Text(value,
              style: pw.TextStyle(
                  fontSize: 14, fontWeight: pw.FontWeight.bold, color: color)),
        ]),
      ));

  pw.Widget _pdfTable(List<FinRecord> rows) => pw.Table(
        border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
        columnWidths: {
          0: const pw.FlexColumnWidth(1.5),
          1: const pw.FlexColumnWidth(2),
          2: const pw.FlexColumnWidth(1.5),
          3: const pw.FlexColumnWidth(3),
          4: const pw.FlexColumnWidth(1.8),
        },
        children: [
          pw.TableRow(
            decoration: const pw.BoxDecoration(color: PdfColors.teal700),
            children: ['Data', 'Quem', 'Setor', 'Descrição', 'Valor']
                .map((h) => _pc(h, bold: true, light: true))
                .toList(),
          ),
          ...rows.asMap().entries.map((e) => pw.TableRow(
                decoration: e.key.isOdd
                    ? const pw.BoxDecoration(color: PdfColors.grey100)
                    : null,
                children: [
                  _pc('${e.value.data}\n${e.value.hora}', small: true),
                  _pc(e.value.quem),
                  _pc(e.value.setor),
                  _pc(e.value.descricao),
                  _pc(_fmtPdf(e.value.valor), right: true),
                ],
              )),
          pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.teal50),
              children: [
                _pc('TOTAL', bold: true),
                _pc(''),
                _pc(''),
                _pc(''),
                _pc(_fmtPdf(rows.fold(0.0, (s, r) => s + r.valor)),
                    bold: true, right: true),
              ]),
        ],
      );

  pw.Widget _pdfTableRec(List<FinRecord> rows) => pw.Table(
        border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
        columnWidths: {
          0: const pw.FlexColumnWidth(1.5),
          1: const pw.FlexColumnWidth(2),
          2: const pw.FlexColumnWidth(1.5),
          3: const pw.FlexColumnWidth(2.5),
          4: const pw.FlexColumnWidth(1.8),
          5: const pw.FlexColumnWidth(1.2),
        },
        children: [
          pw.TableRow(
            decoration: const pw.BoxDecoration(color: PdfColors.teal700),
            children: [
              'Data',
              'Cliente',
              'Setor',
              'Descrição',
              'Valor',
              'Status'
            ].map((h) => _pc(h, bold: true, light: true)).toList(),
          ),
          ...rows.asMap().entries.map((e) => pw.TableRow(
                decoration: e.key.isOdd
                    ? const pw.BoxDecoration(color: PdfColors.grey100)
                    : null,
                children: [
                  _pc('${e.value.data}\n${e.value.hora}', small: true),
                  _pc(e.value.quem),
                  _pc(e.value.setor),
                  _pc(e.value.descricao),
                  _pc(_fmtPdf(e.value.valor), right: true),
                  _pc(e.value.pago ? 'Recebido' : 'Pendente',
                      color: e.value.pago
                          ? PdfColors.green700
                          : PdfColors.orange700),
                ],
              )),
        ],
      );

  pw.Widget _pc(String t,
          {bool bold = false,
          bool light = false,
          bool right = false,
          bool small = false,
          PdfColor? color}) =>
      pw.Padding(
        padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: pw.Text(t,
            textAlign: right ? pw.TextAlign.right : pw.TextAlign.left,
            style: pw.TextStyle(
              fontSize: small ? 8 : 9,
              fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
              color: light ? PdfColors.white : (color ?? PdfColors.black),
            )),
      );

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 320), () {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(_scrollCtrl.position.maxScrollExtent,
            duration: const Duration(milliseconds: 280), curve: Curves.easeOut);
      }
    });
  }

  void _showSnack(String msg, {required bool isError}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        Icon(isError ? Icons.error_outline_rounded : Icons.check_circle_rounded,
            color: Colors.white, size: 16),
        const SizedBox(width: 8),
        Expanded(child: Text(msg, style: const TextStyle(color: Colors.white))),
      ]),
      backgroundColor: isError ? _T.spend : _T.primary,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      duration: const Duration(seconds: 3),
    ));
  }

  Future<bool> _confirm(String title, String msg) async =>
      await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: _T.surface2(context),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Text(title,
              style: TextStyle(
                  color: _T.textPrimary(context), fontWeight: FontWeight.bold)),
          content: Text(msg,
              style: TextStyle(color: _T.textSecondary(context), fontSize: 13)),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text('Cancelar',
                    style: TextStyle(color: _T.textSecondary(context)))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: _T.spend,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10))),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Confirmar'),
            ),
          ],
        ),
      ) ??
      false;

  void _showAttachOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: _T.surface(context),
      isDismissible: true,
      enableDrag: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                    color: _T.border(context),
                    borderRadius: BorderRadius.circular(2))),
            _attachTile(Icons.camera_alt_rounded, 'Câmera',
                'Fotografar recibo ou nota', _T.primary, () {
              Navigator.pop(context);
              _pickCamera();
            }),
            _attachTile(Icons.photo_library_rounded, 'Galeria',
                'Selecionar imagem existente', _T.accent, () {
              Navigator.pop(context);
              _pickGallery();
            }),
            _attachTile(
                Icons.attach_file_rounded, 'Arquivo', 'PDF ou TXT', _T.warn,
                () {
              Navigator.pop(context);
              _pickDoc();
            }),
          ]),
        ),
      ),
    );
  }

  Widget _attachTile(IconData icon, String title, String sub, Color color,
          VoidCallback onTap) =>
      ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(title,
            style: TextStyle(
                color: _T.textPrimary(context),
                fontWeight: FontWeight.w600,
                fontSize: 14)),
        subtitle: Text(sub,
            style: TextStyle(color: _T.textSecondary(context), fontSize: 12)),
        onTap: onTap,
      );

  List<FinRecord> get _gastos =>
      _records.where((r) => r.type == FinType.gasto).toList();
  List<FinRecord> get _receber =>
      _records.where((r) => r.type == FinType.receber).toList();
  double get _totalGasto => _gastos.fold(0.0, (s, r) => s + r.valor);
  double get _totalReceber => _receber.fold(0.0, (s, r) => s + r.valor);
  double get _totalPendente =>
      _receber.where((r) => !r.pago).fold(0.0, (s, r) => s + r.valor);
  double get _saldo => _totalReceber - _totalGasto;
  String _fmtVal(double v) =>
      'R\$ ${v.toStringAsFixed(2).replaceAll('.', ',')}';

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final isDark = _T.dark(context);
    return FadeTransition(
      opacity: _fadeAnim,
      child: Container(
        width: widget.width ?? double.infinity,
        height: widget.height ?? double.infinity,
        decoration: BoxDecoration(
          color: _T.bg(context),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _T.border(context)),
          boxShadow: isDark
              ? [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.35),
                      blurRadius: 24,
                      offset: const Offset(0, 6))
                ]
              : [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 4))
                ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Column(children: [
            _buildTopBar(),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabCtrl,
                physics: const NeverScrollableScrollPhysics(),
                children: [_buildChat(), _buildDashboard()],
              ),
            ),
            SizedBox(height: bottom),
          ]),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 6, 12),
      decoration: BoxDecoration(
        color: _T.surface(context),
        border: Border(bottom: BorderSide(color: _T.border(context))),
      ),
      child: Row(children: [
        _GradientIcon(
            icon: Icons.auto_awesome_rounded,
            colors: _T.gradPrimary,
            size: 18,
            containerSize: 38,
            radius: 11),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Finance AI',
                    style: TextStyle(
                        color: _T.textPrimary(context),
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        letterSpacing: -0.3)),
                Text('HPS Refrigeração',
                    style: TextStyle(
                        color: _T.textSecondary(context), fontSize: 10)),
              ]),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: (_aiReady ? _T.primary : _T.warn).withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: (_aiReady ? _T.primary : _T.warn).withOpacity(0.28)),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                    color: _aiReady ? _T.primary : _T.warn,
                    shape: BoxShape.circle)),
            const SizedBox(width: 5),
            Text(_aiReady ? 'IA Ativa' : 'Iniciando',
                style: TextStyle(
                    fontSize: 10,
                    color: _aiReady ? _T.primary : _T.warn,
                    fontWeight: FontWeight.w600)),
          ]),
        ),
        const SizedBox(width: 2),
        IconButton(
          icon: Icon(Icons.picture_as_pdf_rounded, color: _T.primary, size: 20),
          onPressed: _exportPdf,
          tooltip: 'Exportar PDF',
          padding: const EdgeInsets.all(6),
          constraints: const BoxConstraints(),
        ),
        PopupMenuButton<String>(
          icon: Icon(Icons.more_vert_rounded,
              color: _T.textSecondary(context), size: 20),
          color: _T.surface2(context),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          onSelected: (v) {
            if (v == 'clear') _clearAll();
          },
          itemBuilder: (_) => [
            PopupMenuItem(
                value: 'clear',
                child: Row(children: [
                  Icon(Icons.delete_outline_rounded, size: 18, color: _T.spend),
                  const SizedBox(width: 10),
                  Text('Limpar histórico', style: TextStyle(color: _T.spend)),
                ])),
          ],
        ),
      ]),
    );
  }

  Widget _buildTabBar() => Container(
        color: _T.surface(context),
        child: TabBar(
          controller: _tabCtrl,
          indicatorColor: _T.primary,
          indicatorWeight: 2.5,
          indicatorSize: TabBarIndicatorSize.tab,
          labelColor: _T.primary,
          unselectedLabelColor: _T.textSecondary(context),
          labelStyle:
              const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          dividerColor: _T.border(context),
          tabs: const [
            Tab(
                icon: Icon(Icons.chat_bubble_rounded, size: 15),
                text: 'Chat IA'),
            Tab(
                icon: Icon(Icons.bar_chart_rounded, size: 15),
                text: 'Dashboard'),
          ],
        ),
      );

  Widget _buildChat() => Column(children: [
        if (_records.isNotEmpty) _buildMiniSummary(),
        Expanded(child: _buildBody()),
        if (_loading) _buildTyping(),
        if (_pendingBytes != null) _buildAttachPreview(),
        _buildInput(),
      ]);

  Widget _buildMiniSummary() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        color: _T.surface(context),
        child: Row(children: [
          _miniCard('Gastos', _fmtVal(_totalGasto), _T.spend,
              Icons.trending_down_rounded),
          const SizedBox(width: 8),
          _miniCard('Pendente', _fmtVal(_totalPendente), _T.warn,
              Icons.hourglass_empty_rounded),
          const SizedBox(width: 8),
          _miniCard(
              'Saldo',
              _fmtVal(_saldo.abs()),
              _saldo >= 0 ? _T.primary : _T.spend,
              _saldo >= 0
                  ? Icons.trending_up_rounded
                  : Icons.trending_down_rounded),
        ]),
      );

  Widget _miniCard(String label, String value, Color color, IconData icon) =>
      Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.18)),
          ),
          child: Row(children: [
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(label,
                        style: TextStyle(
                            color: _T.textSecondary(context), fontSize: 9)),
                    Text(value,
                        style: TextStyle(
                            color: color,
                            fontSize: 11,
                            fontWeight: FontWeight.w800),
                        overflow: TextOverflow.ellipsis),
                  ]),
            ),
          ]),
        ),
      );

  Widget _buildBody() {
    if (_aiError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.error_outline_rounded, color: _T.spend, size: 48),
            const SizedBox(height: 12),
            Text(_aiError!,
                textAlign: TextAlign.center, style: TextStyle(color: _T.spend)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                setState(() => _aiError = null);
                _initAI();
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Tentar novamente'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: _T.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))),
            ),
          ]),
        ),
      );
    }
    if (!_aiReady) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          SizedBox(
            width: 32,
            height: 32,
            child:
                CircularProgressIndicator(color: _T.primary, strokeWidth: 2.5),
          ),
          const SizedBox(height: 16),
          Text('Inicializando IA...',
              style: TextStyle(color: _T.textSecondary(context), fontSize: 13)),
        ]),
      );
    }
    if (_messages.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.chat_bubble_outline_rounded,
              color: _T.textHint(context), size: 44),
          const SizedBox(height: 12),
          Text('Nenhuma mensagem ainda.',
              style: TextStyle(color: _T.textSecondary(context), fontSize: 14)),
        ]),
      );
    }
    return ListView.builder(
      controller: _scrollCtrl,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
      itemCount: _messages.length,
      itemBuilder: (_, i) => _buildBubble(_messages[i]),
    );
  }

  Widget _buildBubble(ChatMsg msg) {
    final isUser = msg.isUser;
    final maxW = MediaQuery.of(context).size.width * 0.76;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            Container(
              width: 30,
              height: 30,
              margin: const EdgeInsets.only(right: 8),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                    colors: _T.gradPrimary,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.smart_toy_rounded,
                  color: Colors.white, size: 15),
            ),
          ],
          Flexible(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxW),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isUser
                      ? _T.primary.withOpacity(0.9)
                      : _T.surface(context),
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                    bottomLeft: Radius.circular(isUser ? 16 : 4),
                    bottomRight: Radius.circular(isUser ? 4 : 16),
                  ),
                  border: isUser ? null : Border.all(color: _T.border(context)),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.07),
                        blurRadius: 8,
                        offset: const Offset(0, 2))
                  ],
                ),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (msg.imageBytes != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.memory(msg.imageBytes!,
                                height: 140, fit: BoxFit.cover),
                          ),
                        ),
                      _richText(msg.text, isUser),
                      const SizedBox(height: 4),
                      Row(mainAxisSize: MainAxisSize.min, children: [
                        Text(
                          '${msg.timestamp.hour.toString().padLeft(2, '0')}:${msg.timestamp.minute.toString().padLeft(2, '0')}',
                          style: TextStyle(
                              fontSize: 9,
                              color: isUser
                                  ? Colors.white.withOpacity(0.55)
                                  : _T.textSecondary(context)),
                        ),
                        if (isUser) ...[
                          const SizedBox(width: 4),
                          Icon(
                            msg.status == MsgStatus.sending
                                ? Icons.schedule_rounded
                                : msg.status == MsgStatus.error
                                    ? Icons.error_outline_rounded
                                    : Icons.done_rounded,
                            size: 11,
                            color: msg.status == MsgStatus.error
                                ? _T.spend
                                : Colors.white.withOpacity(0.55),
                          ),
                        ],
                      ]),
                    ]),
              ),
            ),
          ),
          if (isUser) ...[
            Container(
              width: 30,
              height: 30,
              margin: const EdgeInsets.only(left: 8),
              decoration: const BoxDecoration(
                color: _T.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person_rounded,
                  color: Colors.white, size: 15),
            ),
          ],
        ],
      ),
    );
  }

  Widget _richText(String text, bool isUser) {
    final base = isUser ? Colors.white : _T.textPrimary(context);
    if (!text.contains('**')) {
      return Text(text,
          style: TextStyle(color: base, fontSize: 13.5, height: 1.5));
    }
    final parts = text.split('**');
    final spans = parts
        .asMap()
        .entries
        .map((e) => TextSpan(
              text: e.value,
              style: e.key.isOdd
                  ? TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isUser ? Colors.white : _T.primary)
                  : TextStyle(color: base),
            ))
        .toList();
    return RichText(
        text: TextSpan(
            style: TextStyle(fontSize: 13.5, height: 1.5, color: base),
            children: spans));
  }

  Widget _buildTyping() => Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 6),
        child: Row(children: [
          Container(
            width: 30,
            height: 30,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                  colors: _T.gradPrimary,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.smart_toy_rounded,
                color: Colors.white, size: 15),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: _T.surface(context),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _T.border(context)),
            ),
            child: _TypingDots(ctrl: _typingCtrl),
          ),
        ]),
      );

  Widget _buildAttachPreview() => Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: _T.primary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _T.primary.withOpacity(0.28)),
        ),
        child: Row(children: [
          Icon(_pendingIsFile ? Icons.description_rounded : Icons.image_rounded,
              color: _T.primary, size: 16),
          const SizedBox(width: 8),
          Expanded(
              child: Text(_pendingName ?? 'Arquivo',
                  style: TextStyle(color: _T.primary, fontSize: 12),
                  overflow: TextOverflow.ellipsis)),
          GestureDetector(
            onTap: () => setState(() {
              _pendingBytes = null;
              _pendingName = null;
            }),
            child: Icon(Icons.close_rounded, color: _T.primary, size: 16),
          ),
        ]),
      );

  Widget _buildInput() => SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
          decoration: BoxDecoration(
            color: _T.surface(context),
            border: Border(top: BorderSide(color: _T.border(context))),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              InkWell(
                onTap: _showAttachOptions,
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Icon(Icons.add_circle_outline_rounded,
                      color: _T.primary, size: 22),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 120),
                  decoration: BoxDecoration(
                    color: _T.surface2(context),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: _T.border(context)),
                  ),
                  child: KeyboardListener(
                    focusNode: FocusNode(),
                    onKeyEvent: (event) {
                      if (event is KeyDownEvent &&
                          event.logicalKey == LogicalKeyboardKey.enter &&
                          !HardwareKeyboard.instance.isShiftPressed) {
                        if (!_loading && _aiReady) _send();
                      }
                    },
                    child: TextField(
                      controller: _inputCtrl,
                      focusNode: _inputFocus,
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      textCapitalization: TextCapitalization.sentences,
                      style: TextStyle(
                          fontSize: 13.5, color: _T.textPrimary(context)),
                      decoration: InputDecoration(
                        hintText: 'Descreva o gasto ou recebimento...',
                        hintStyle: TextStyle(
                            color: _T.textSecondary(context), fontSize: 13),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 11),
                      ),
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) {
                        if (!_loading && _aiReady) _send();
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  gradient: _loading
                      ? null
                      : const LinearGradient(
                          colors: _T.gradPrimary,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight),
                  shape: BoxShape.circle,
                  boxShadow: _loading
                      ? null
                      : [
                          BoxShadow(
                              color: _T.primary.withOpacity(0.35),
                              blurRadius: 10,
                              offset: const Offset(0, 3))
                        ],
                ),
                child: InkWell(
                  onTap: _loading ? null : _send,
                  borderRadius: BorderRadius.circular(21),
                  child: Center(
                    child: _loading
                        ? SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                color: _T.primary, strokeWidth: 2))
                        : const Icon(Icons.send_rounded,
                            color: Colors.white, size: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      );

  Widget _buildDashboard() {
    if (_records.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.bar_chart_rounded, color: _T.textHint(context), size: 52),
          const SizedBox(height: 12),
          Text('Nenhum registro ainda.',
              style: TextStyle(color: _T.textSecondary(context), fontSize: 14)),
          const SizedBox(height: 6),
          Text('Use o Chat IA para registrar gastos\ne contas a receber.',
              textAlign: TextAlign.center,
              style: TextStyle(color: _T.textSecondary(context), fontSize: 12)),
        ]),
      );
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _buildSaldoCard(),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(
              child: _dashCard(
                  'Total Gastos',
                  _fmtVal(_totalGasto),
                  Icons.trending_down_rounded,
                  _T.spend,
                  '${_gastos.length} lançamentos')),
          const SizedBox(width: 10),
          Expanded(
              child: _dashCard(
                  'A Receber',
                  _fmtVal(_totalReceber),
                  Icons.account_balance_wallet_rounded,
                  _T.earn,
                  '${_receber.length} lançamentos')),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(
              child: _dashCard(
                  'Pendente',
                  _fmtVal(_totalPendente),
                  Icons.hourglass_empty_rounded,
                  _T.warn,
                  '${_receber.where((r) => !r.pago).length} pendentes')),
          const SizedBox(width: 10),
          Expanded(
              child: _dashCard(
                  'Já Recebido',
                  _fmtVal(_receber
                      .where((r) => r.pago)
                      .fold(0.0, (s, r) => s + r.valor)),
                  Icons.check_circle_rounded,
                  _T.primary,
                  '${_receber.where((r) => r.pago).length} recebidos')),
        ]),
        if (_gastos.isNotEmpty) ...[
          const SizedBox(height: 22),
          const _SectionLabel('GASTOS POR SETOR'),
          ..._buildBarsAI(_gastos, _totalGasto),
        ],
        if (_receber.isNotEmpty) ...[
          const SizedBox(height: 22),
          const _SectionLabel('CONTAS A RECEBER'),
          ..._receber.take(8).map((r) => _receberTile(r)),
        ],
        const SizedBox(height: 20),
      ]),
    );
  }

  Widget _buildSaldoCard() {
    final pos = _saldo >= 0;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: pos ? _T.gradEarn : _T.gradNeg,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: (pos ? _T.primary : _T.spend).withOpacity(0.32),
              blurRadius: 16,
              offset: const Offset(0, 5))
        ],
      ),
      child: Row(children: [
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Saldo Geral',
                style: TextStyle(
                    color: Colors.white.withOpacity(0.75),
                    fontSize: 11,
                    fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),
            Text(_fmtVal(_saldo.abs()),
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.8)),
            const SizedBox(height: 4),
            Text(pos ? '▲ Saldo positivo' : '▼ Saldo negativo',
                style: TextStyle(
                    color: Colors.white.withOpacity(0.7), fontSize: 11)),
          ]),
        ),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(14)),
          child: Icon(
              pos ? Icons.trending_up_rounded : Icons.trending_down_rounded,
              color: Colors.white,
              size: 28),
        ),
      ]),
    );
  }

  Widget _dashCard(
          String label, String value, IconData icon, Color color, String sub) =>
      Container(
        padding: const EdgeInsets.all(14),
        decoration: _T.cardDeco(context, accent: color),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                    color: color.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: color, size: 15)),
            const SizedBox(width: 8),
            Expanded(
                child: Text(label,
                    style: TextStyle(
                        color: _T.textSecondary(context), fontSize: 10))),
          ]),
          const SizedBox(height: 10),
          Text(value,
              style: TextStyle(
                  color: color,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3),
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 3),
          Text(sub,
              style: TextStyle(color: _T.textSecondary(context), fontSize: 10)),
        ]),
      );

  List<Widget> _buildBarsAI(List<FinRecord> rows, double total) {
    final map = <String, double>{};
    for (final r in rows) map[r.setor] = (map[r.setor] ?? 0) + r.valor;
    final sorted = map.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.map((e) {
      final pct = total > 0 ? e.value / total : 0.0;
      final barColor = _sectorColor(e.key);
      final count = rows.where((r) => r.setor == e.key).length;
      return Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
                width: 10,
                height: 10,
                decoration:
                    BoxDecoration(color: barColor, shape: BoxShape.circle)),
            const SizedBox(width: 8),
            Expanded(
                child: Text(e.key,
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: _T.textPrimary(context)))),
            Text('$count reg.',
                style:
                    TextStyle(fontSize: 11, color: _T.textSecondary(context))),
            const SizedBox(width: 10),
            Text(_fmtVal(e.value),
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: barColor)),
            const SizedBox(width: 8),
            Text('${(pct * 100).toStringAsFixed(1)}%',
                style:
                    TextStyle(fontSize: 11, color: _T.textSecondary(context))),
          ]),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
                value: pct,
                backgroundColor: barColor.withOpacity(0.12),
                valueColor: AlwaysStoppedAnimation<Color>(barColor),
                minHeight: 7),
          ),
        ]),
      );
    }).toList();
  }

  Color _sectorColor(String s) {
    const cols = [
      Color(0xFF0F766E),
      Color(0xFF3730A3),
      Color(0xFFB45309),
      Color(0xFFB91C1C),
      Color(0xFF047857),
      Color(0xFF3730A3),
      Color(0xFF9F1239),
      Color(0xFF0F766E),
    ];
    return cols[s.hashCode.abs() % cols.length];
  }

  Widget _receberTile(FinRecord r) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: _T.cardDeco(context,
            accent: r.pago ? _T.primary : _T.warn, radius: 12),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (r.pago ? _T.primary : _T.warn).withOpacity(0.12),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(
                r.pago
                    ? Icons.check_circle_rounded
                    : Icons.hourglass_empty_rounded,
                color: r.pago ? _T.primary : _T.warn,
                size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(r.quem,
                  style: TextStyle(
                      color: _T.textPrimary(context),
                      fontSize: 13,
                      fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis),
              Text(r.descricao,
                  style:
                      TextStyle(color: _T.textSecondary(context), fontSize: 11),
                  overflow: TextOverflow.ellipsis),
            ]),
          ),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(_fmtVal(r.valor),
                style: TextStyle(
                    color: r.pago ? _T.primary : _T.warn,
                    fontSize: 13,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 3),
            _Pill(
                r.pago ? 'Recebido' : 'Pendente', r.pago ? _T.primary : _T.warn,
                compact: true),
          ]),
        ]),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// WIDGET 2 — FinanceDashboardWidget
// ─────────────────────────────────────────────────────────────────────────────

enum DashFinType { gasto, receber }

class DashRecord {
  final String docId;
  final DashFinType type;
  double valor;
  String setor;
  String data;
  String hora;
  String quem;
  String descricao;
  bool pago;
  final DateTime criadoEm;

  DashRecord({
    required this.docId,
    required this.type,
    required this.valor,
    required this.setor,
    required this.data,
    required this.hora,
    required this.quem,
    required this.descricao,
    required this.pago,
    required this.criadoEm,
  });

  factory DashRecord.fromDoc(DocumentSnapshot doc, DashFinType type) {
    final d = doc.data() as Map<String, dynamic>;
    DateTime created = DateTime.now();
    if (d['criadoEm'] is Timestamp) {
      created = (d['criadoEm'] as Timestamp).toDate();
    }
    return DashRecord(
      docId: doc.id,
      type: type,
      valor: (d['valor'] as num?)?.toDouble() ?? 0.0,
      setor: d['setor'] ?? 'Outros',
      data: d['data'] ?? '',
      hora: d['hora'] ?? '',
      quem: d['quem'] ?? '',
      descricao: d['descricao'] ?? '',
      pago: d['pago'] ?? (type == DashFinType.gasto),
      criadoEm: created,
    );
  }

  Map<String, dynamic> toMap() => {
        'valor': valor,
        'setor': setor,
        'data': data,
        'hora': hora,
        'quem': quem,
        'descricao': descricao,
        'pago': pago,
      };
}

class FinanceDashboardWidget extends StatefulWidget {
  const FinanceDashboardWidget({Key? key, this.width, this.height})
      : super(key: key);
  final double? width;
  final double? height;

  @override
  State<FinanceDashboardWidget> createState() => _FinanceDashboardWidgetState();
}

class _FinanceDashboardWidgetState extends State<FinanceDashboardWidget>
    with SingleTickerProviderStateMixin {
  List<DashRecord> _gastos = [];
  List<DashRecord> _receber = [];
  bool _loading = true;
  String? _error;

  String _filterSetor = 'Todos';
  String _filterQuem = 'Todos';
  DateTime? _dateStart;
  DateTime? _dateEnd;
  String _searchQ = '';

  final Set<String> _selected = {};
  bool _selectMode = false;

  late TabController _tabCtrl;
  final TextEditingController _searchCtrl = TextEditingController();
  String _sortField = 'criadoEm';
  bool _sortAsc = false;

  static const kSetoresGasto = [
    'Todos',
    'Alimentação',
    'Assinaturas',
    'Casa',
    'Combustível',
    'Equipamentos',
    'Funcionário',
    'Hospedagem',
    'Impostos',
    'Limpeza',
    'Loja',
    'Manutenção',
    'Marketing',
    'Material',
    'Serviços',
    'Taxas Bancárias',
    'Transporte',
    'Vendas',
    'Outros',
  ];
  static const kSetoresReceber = [
    'Todos',
    'Manutenção',
    'Preventiva',
    'Instalação',
    'Consultoria',
    'Peças',
    'Contrato',
    'Outros',
  ];

  Color _sectorColor(String s) {
    const cols = [
      Color(0xFF0F766E),
      Color(0xFF3730A3),
      Color(0xFFB45309),
      Color(0xFFB91C1C),
      Color(0xFF047857),
      Color(0xFF3730A3),
      Color(0xFF9F1239),
      Color(0xFF0F766E),
    ];
    return cols[s.hashCode.abs() % cols.length];
  }

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    _tabCtrl.addListener(() {
      if (mounted) setState(() {});
    });
    _loadData();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> _fetchAll(
      String collection) async {
    const int pageSize = 500;
    final List<QueryDocumentSnapshot<Map<String, dynamic>>> all = [];
    DocumentSnapshot? lastDoc;
    while (true) {
      Query<Map<String, dynamic>> q =
          FirebaseFirestore.instance.collection(collection).limit(pageSize);
      if (lastDoc != null) q = q.startAfterDocument(lastDoc);
      final snap = await q.get();
      all.addAll(snap.docs);
      if (snap.docs.length < pageSize) break;
      lastDoc = snap.docs.last;
    }
    return all;
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    List<QueryDocumentSnapshot<Map<String, dynamic>>>? gDocs;
    List<QueryDocumentSnapshot<Map<String, dynamic>>>? rDocs;
    String? gError;
    String? rError;

    await Future.wait([
      _fetchAll('financeiro').then((d) => gDocs = d).catchError((e) {
        gError = '$e';
        return <QueryDocumentSnapshot<Map<String, dynamic>>>[];
      }),
      _fetchAll('financeiro_receber').then((d) => rDocs = d).catchError((e) {
        rError = '$e';
        return <QueryDocumentSnapshot<Map<String, dynamic>>>[];
      }),
    ]);

    if (!mounted) return;
    setState(() {
      if (gDocs != null) {
        _gastos = gDocs!
            .map((d) => DashRecord.fromDoc(d, DashFinType.gasto))
            .toList()
          ..sort((a, b) => b.criadoEm.compareTo(a.criadoEm));
      }
      if (rDocs != null) {
        _receber = rDocs!
            .map((d) => DashRecord.fromDoc(d, DashFinType.receber))
            .toList()
          ..sort((a, b) => b.criadoEm.compareTo(a.criadoEm));
      }
      if (gDocs == null && rDocs == null) {
        _error = gError ?? rError ?? 'Erro ao carregar dados.';
      }
      _loading = false;
    });
  }

  Future<void> _deleteRecord(DashRecord rec) async {
    final col =
        rec.type == DashFinType.gasto ? 'financeiro' : 'financeiro_receber';
    await FirebaseFirestore.instance.collection(col).doc(rec.docId).delete();
    if (!mounted) return;
    setState(() {
      if (rec.type == DashFinType.gasto) {
        _gastos.removeWhere((r) => r.docId == rec.docId);
      } else {
        _receber.removeWhere((r) => r.docId == rec.docId);
      }
    });
    _snack('Lançamento excluído.', isError: true);
  }

  Future<void> _deleteSelected() async {
    final batch = FirebaseFirestore.instance.batch();
    for (final id in _selected) {
      final isGasto = _gastos.any((r) => r.docId == id);
      final col = isGasto ? 'financeiro' : 'financeiro_receber';
      batch.delete(FirebaseFirestore.instance.collection(col).doc(id));
    }
    await batch.commit();
    if (!mounted) return;
    setState(() {
      _gastos.removeWhere((r) => _selected.contains(r.docId));
      _receber.removeWhere((r) => _selected.contains(r.docId));
      _selected.clear();
      _selectMode = false;
    });
    _snack('Lançamentos excluídos.', isError: true);
  }

  Future<void> _updateRecord(DashRecord rec) async {
    final col =
        rec.type == DashFinType.gasto ? 'financeiro' : 'financeiro_receber';
    await FirebaseFirestore.instance
        .collection(col)
        .doc(rec.docId)
        .update(rec.toMap());
    if (!mounted) return;
    _snack('Lançamento atualizado!');
    setState(() {});
  }

  Future<void> _togglePago(DashRecord rec) async {
    rec.pago = !rec.pago;
    final col =
        rec.type == DashFinType.gasto ? 'financeiro' : 'financeiro_receber';
    await FirebaseFirestore.instance
        .collection(col)
        .doc(rec.docId)
        .update({'pago': rec.pago});
    if (!mounted) return;
    _snack(rec.pago ? '✅ Marcado como recebido!' : 'Marcado como pendente.');
    setState(() {});
  }

  List<DashRecord> _applyFilters(List<DashRecord> list) {
    if (_filterSetor != 'Todos') {
      list = list.where((r) => r.setor == _filterSetor).toList();
    }
    if (_filterQuem != 'Todos') {
      list = list.where((r) => r.quem == _filterQuem).toList();
    }
    if (_searchQ.isNotEmpty) {
      final q = _searchQ.toLowerCase();
      list = list
          .where((r) =>
              r.descricao.toLowerCase().contains(q) ||
              r.quem.toLowerCase().contains(q) ||
              r.setor.toLowerCase().contains(q))
          .toList();
    }
    if (_dateStart != null) {
      list = list.where((r) => !r.criadoEm.isBefore(_dateStart!)).toList();
    }
    if (_dateEnd != null) {
      final end =
          DateTime(_dateEnd!.year, _dateEnd!.month, _dateEnd!.day, 23, 59, 59);
      list = list.where((r) => !r.criadoEm.isAfter(end)).toList();
    }
    list.sort((a, b) {
      int cmp;
      switch (_sortField) {
        case 'valor':
          cmp = a.valor.compareTo(b.valor);
          break;
        case 'quem':
          cmp = a.quem.compareTo(b.quem);
          break;
        default:
          cmp = a.criadoEm.compareTo(b.criadoEm);
      }
      return _sortAsc ? cmp : -cmp;
    });
    return list;
  }

  List<DashRecord> get _filtGastos => _applyFilters(List.from(_gastos));
  List<DashRecord> get _filtReceber => _applyFilters(List.from(_receber));
  double get _totGasto => _filtGastos.fold(0.0, (s, r) => s + r.valor);
  double get _totReceber => _filtReceber.fold(0.0, (s, r) => s + r.valor);
  double get _totPendente =>
      _filtReceber.where((r) => !r.pago).fold(0.0, (s, r) => s + r.valor);
  double get _totRecebido =>
      _filtReceber.where((r) => r.pago).fold(0.0, (s, r) => s + r.valor);
  double get _saldo => _totReceber - _totGasto;

  List<String> _quemList(List<DashRecord> src) {
    final set = <String>{'Todos'};
    for (final r in src) set.add(r.quem);
    return set.toList()..sort();
  }

  String _fmtVal(double v) =>
      'R\$ ${v.toStringAsFixed(2).replaceAll('.', ',')}';
  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  bool get _hasFilters =>
      _filterSetor != 'Todos' ||
      _filterQuem != 'Todos' ||
      _dateStart != null ||
      _dateEnd != null ||
      _searchQ.isNotEmpty;

  void _snack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        Icon(
            isError ? Icons.delete_outline_rounded : Icons.check_circle_rounded,
            color: Colors.white,
            size: 16),
        const SizedBox(width: 8),
        Expanded(child: Text(msg, style: const TextStyle(color: Colors.white))),
      ]),
      backgroundColor: isError ? _T.spend : _T.primary,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      duration: const Duration(seconds: 3),
    ));
  }

  Future<void> _showEditDialog(DashRecord rec) async {
    final valCtrl = TextEditingController(text: rec.valor.toStringAsFixed(2));
    final descCtrl = TextEditingController(text: rec.descricao);
    final quemCtrl = TextEditingController(text: rec.quem);
    final dataCtrl = TextEditingController(text: rec.data);
    final horaCtrl = TextEditingController(text: rec.hora);
    String setor = rec.setor;
    bool pago = rec.pago;
    final setores = rec.type == DashFinType.gasto
        ? kSetoresGasto.where((s) => s != 'Todos').toList()
        : kSetoresReceber.where((s) => s != 'Todos').toList();

    final saved = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSt) => Dialog(
          backgroundColor: _T.surface2(context),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    _GradientIcon(
                        icon: Icons.edit_rounded,
                        colors: rec.type == DashFinType.receber
                            ? _T.gradEarn
                            : _T.gradSpend,
                        size: 16,
                        containerSize: 36,
                        radius: 10),
                    const SizedBox(width: 12),
                    Expanded(
                        child: Text(
                            rec.type == DashFinType.receber
                                ? 'Editar Conta a Receber'
                                : 'Editar Gasto',
                            style: TextStyle(
                                color: _T.textPrimary(context),
                                fontSize: 15,
                                fontWeight: FontWeight.bold))),
                    IconButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        icon: Icon(Icons.close_rounded,
                            color: _T.textSecondary(context), size: 20)),
                  ]),
                  const SizedBox(height: 18),
                  TextFormField(
                    controller: valCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    style:
                        TextStyle(color: _T.textPrimary(context), fontSize: 14),
                    decoration: _T.inputDeco(context, 'Valor (R\$)',
                        icon: Icons.attach_money_rounded),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: setores.contains(setor) ? setor : setores.first,
                    dropdownColor: _T.surface2(context),
                    style:
                        TextStyle(color: _T.textPrimary(context), fontSize: 14),
                    decoration: _T.inputDeco(context, 'Setor',
                        icon: Icons.category_rounded),
                    items: setores
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (v) => setSt(() => setor = v ?? setor),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: quemCtrl,
                    style:
                        TextStyle(color: _T.textPrimary(context), fontSize: 14),
                    decoration: _T.inputDeco(
                        context,
                        rec.type == DashFinType.receber
                            ? 'Cliente'
                            : 'Quem realizou',
                        icon: Icons.person_rounded),
                  ),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(
                        child: TextFormField(
                      controller: dataCtrl,
                      style: TextStyle(
                          color: _T.textPrimary(context), fontSize: 14),
                      decoration: _T.inputDeco(context, 'Data (DD/MM/AAAA)',
                          icon: Icons.calendar_today_rounded),
                    )),
                    const SizedBox(width: 10),
                    Expanded(
                        child: TextFormField(
                      controller: horaCtrl,
                      style: TextStyle(
                          color: _T.textPrimary(context), fontSize: 14),
                      decoration: _T.inputDeco(context, 'Hora (HH:MM)',
                          icon: Icons.access_time_rounded),
                    )),
                  ]),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: descCtrl,
                    maxLines: 3,
                    style:
                        TextStyle(color: _T.textPrimary(context), fontSize: 14),
                    decoration: _T.inputDeco(context, 'Descrição',
                        icon: Icons.description_rounded),
                  ),
                  const SizedBox(height: 12),
                  if (rec.type == DashFinType.receber)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                          color: _T.surface(context),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _T.border(context))),
                      child: Row(children: [
                        Icon(Icons.payment_rounded,
                            color: _T.primary, size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                            child: Text('Já recebido?',
                                style: TextStyle(
                                    color: _T.textPrimary(context),
                                    fontSize: 14))),
                        Switch(
                            value: pago,
                            onChanged: (v) => setSt(() => pago = v),
                            activeColor: _T.primary,
                            inactiveThumbColor: _T.textSecondary(context)),
                      ]),
                    ),
                  const SizedBox(height: 20),
                  Row(children: [
                    Expanded(
                        child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: _T.border(context)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        foregroundColor: _T.textSecondary(context),
                      ),
                      child: const Text('Cancelar'),
                    )),
                    const SizedBox(width: 10),
                    Expanded(
                        child: ElevatedButton.icon(
                      onPressed: () => Navigator.pop(ctx, true),
                      icon: const Icon(Icons.save_rounded, size: 16),
                      label: const Text('Salvar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _T.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    )),
                  ]),
                ]),
          ),
        ),
      ),
    );

    if (saved == true) {
      rec.valor = double.tryParse(valCtrl.text.replaceAll(',', '.').trim()) ??
          rec.valor;
      rec.setor = setor;
      rec.quem = quemCtrl.text.trim();
      rec.data = dataCtrl.text.trim();
      rec.hora = horaCtrl.text.trim();
      rec.descricao = descCtrl.text.trim();
      rec.pago = pago;
      await _updateRecord(rec);
    }
  }

  Future<bool> _confirmDel(String msg) async =>
      await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: _T.surface2(context),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Row(children: [
            Icon(Icons.warning_amber_rounded, color: _T.warn),
            const SizedBox(width: 8),
            Text('Confirmar exclusão',
                style: TextStyle(color: _T.textPrimary(context))),
          ]),
          content: Text(msg,
              style: TextStyle(color: _T.textSecondary(context), fontSize: 13)),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text('Cancelar',
                    style: TextStyle(color: _T.textSecondary(context)))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: _T.spend,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10))),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Excluir'),
            ),
          ],
        ),
      ) ??
      false;

  Future<void> _exportPdf() async {
    final allRecords = [..._filtGastos, ..._filtReceber];
    if (allRecords.isEmpty) {
      _snack('Nenhum dado para exportar.', isError: true);
      return;
    }
    final pdf = pw.Document();
    final dateStr = _fmtDate(DateTime.now());

    pdf.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      header: (_) => pw.Container(
        padding: const pw.EdgeInsets.only(bottom: 10),
        decoration: const pw.BoxDecoration(
            border: pw.Border(
                bottom: pw.BorderSide(color: PdfColors.teal700, width: 2))),
        child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('HPS Refrigeração',
                        style: pw.TextStyle(
                            fontSize: 16,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.teal700)),
                    pw.Text('Relatório Financeiro',
                        style: const pw.TextStyle(
                            fontSize: 10, color: PdfColors.grey600)),
                  ]),
              pw.Text('Gerado em $dateStr',
                  style: const pw.TextStyle(
                      fontSize: 9, color: PdfColors.grey600)),
            ]),
      ),
      footer: (ctx) => pw.Align(
        alignment: pw.Alignment.centerRight,
        child: pw.Text('Página ${ctx.pageNumber}/${ctx.pagesCount}',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
      ),
      build: (_) => [
        pw.SizedBox(height: 14),
        pw.Row(children: [
          _pdfCard('Total Gastos', _fmtVal(_totGasto), PdfColors.red700),
          pw.SizedBox(width: 8),
          _pdfCard('A Receber', _fmtVal(_totReceber), PdfColors.teal700),
          pw.SizedBox(width: 8),
          _pdfCard('Pendente', _fmtVal(_totPendente), PdfColors.orange700),
          pw.SizedBox(width: 8),
          _pdfCard('Saldo', _fmtVal(_saldo),
              _saldo >= 0 ? PdfColors.green700 : PdfColors.red700),
        ]),
        pw.SizedBox(height: 20),
        if (_filtGastos.isNotEmpty) ...[
          pw.Text('Gastos',
              style:
                  pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 6),
          _pdfTableDash(_filtGastos, isReceber: false),
          pw.SizedBox(height: 20),
        ],
        if (_filtReceber.isNotEmpty) ...[
          pw.Text('Contas a Receber',
              style:
                  pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 6),
          _pdfTableDash(_filtReceber, isReceber: true),
        ],
      ],
    ));
    await Printing.layoutPdf(onLayout: (_) => pdf.save());
  }

  pw.Widget _pdfCard(String label, String value, PdfColor color) => pw.Expanded(
          child: pw.Container(
        padding: const pw.EdgeInsets.all(10),
        decoration: pw.BoxDecoration(
            color: PdfColors.grey100,
            borderRadius: pw.BorderRadius.circular(6)),
        child: pw
            .Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Text(label,
              style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
          pw.SizedBox(height: 3),
          pw.Text(value,
              style: pw.TextStyle(
                  fontSize: 12, fontWeight: pw.FontWeight.bold, color: color)),
        ]),
      ));

  pw.Widget _pdfTableDash(List<DashRecord> rows, {required bool isReceber}) {
    final cols = isReceber
        ? {
            0: const pw.FlexColumnWidth(1.5),
            1: const pw.FlexColumnWidth(2),
            2: const pw.FlexColumnWidth(1.5),
            3: const pw.FlexColumnWidth(2.5),
            4: const pw.FlexColumnWidth(1.8),
            5: const pw.FlexColumnWidth(1.2),
          }
        : {
            0: const pw.FlexColumnWidth(1.5),
            1: const pw.FlexColumnWidth(2),
            2: const pw.FlexColumnWidth(1.5),
            3: const pw.FlexColumnWidth(3),
            4: const pw.FlexColumnWidth(1.8),
          };
    final headers = isReceber
        ? ['Data', 'Cliente', 'Setor', 'Descrição', 'Valor', 'Status']
        : ['Data', 'Quem', 'Setor', 'Descrição', 'Valor'];
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
      columnWidths: cols,
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.teal700),
          children:
              headers.map((h) => _pc(h, bold: true, light: true)).toList(),
        ),
        ...rows.asMap().entries.map((e) => pw.TableRow(
              decoration: e.key.isOdd
                  ? const pw.BoxDecoration(color: PdfColors.grey100)
                  : null,
              children: [
                _pc('${e.value.data}\n${e.value.hora}', small: true),
                _pc(e.value.quem),
                _pc(e.value.setor),
                _pc(e.value.descricao),
                _pc(_fmtVal(e.value.valor), right: true),
                if (isReceber)
                  _pc(e.value.pago ? 'Recebido' : 'Pendente',
                      color: e.value.pago
                          ? PdfColors.green700
                          : PdfColors.orange700),
              ],
            )),
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.teal50),
          children: [
            _pc('TOTAL', bold: true),
            _pc(''),
            _pc(''),
            _pc(''),
            _pc(_fmtVal(rows.fold(0.0, (s, r) => s + r.valor)),
                bold: true, right: true),
            if (isReceber) _pc(''),
          ],
        ),
      ],
    );
  }

  pw.Widget _pc(String t,
          {bool bold = false,
          bool light = false,
          bool right = false,
          bool small = false,
          PdfColor? color}) =>
      pw.Padding(
        padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: pw.Text(t,
            textAlign: right ? pw.TextAlign.right : pw.TextAlign.left,
            style: pw.TextStyle(
              fontSize: small ? 8 : 9,
              fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
              color: light ? PdfColors.white : (color ?? PdfColors.black),
            )),
      );

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        width: widget.width ?? double.infinity,
        height: widget.height ?? double.infinity,
        decoration: BoxDecoration(
          color: _T.bg(context),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _T.border(context)),
          boxShadow: _T.dark(context)
              ? [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.35),
                      blurRadius: 24,
                      offset: const Offset(0, 6))
                ]
              : [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 4))
                ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Column(children: [
            _buildHeader(),
            _buildSearch(),
            _buildTabBar2(),
            Expanded(
              child: _loading
                  ? _buildLoading()
                  : _error != null
                      ? _buildError()
                      : TabBarView(
                          controller: _tabCtrl,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            _buildOverview(),
                            _buildGastosTab(),
                            _buildReceberTab(),
                          ],
                        ),
            ),
            if (_selectMode && _selected.isNotEmpty) _buildSelectionBar(),
          ]),
        ),
      ),
    );
  }

  Widget _buildHeader() => Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 6, 12),
        decoration: BoxDecoration(
          color: _T.surface(context),
          border: Border(bottom: BorderSide(color: _T.border(context))),
        ),
        child: Row(children: [
          _GradientIcon(
              icon: Icons.bar_chart_rounded,
              colors: _T.gradPrimary,
              size: 18,
              containerSize: 38,
              radius: 11),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Dashboard Financeiro',
                      style: TextStyle(
                          color: _T.textPrimary(context),
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          letterSpacing: -0.3)),
                  Text('HPS Refrigeração',
                      style: TextStyle(
                          color: _T.textSecondary(context), fontSize: 10)),
                ]),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
                color: _T.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _T.primary.withOpacity(0.2))),
            child: Text('${_filtGastos.length + _filtReceber.length} reg.',
                style: TextStyle(
                    fontSize: 10,
                    color: _T.primary,
                    fontWeight: FontWeight.w700)),
          ),
          IconButton(
              icon: Icon(Icons.tune_rounded,
                  color: _hasFilters ? _T.primary : _T.textSecondary(context),
                  size: 20),
              tooltip: 'Filtros',
              padding: const EdgeInsets.all(6),
              constraints: const BoxConstraints(),
              onPressed: _showFilters),
          IconButton(
              icon: Icon(Icons.picture_as_pdf_rounded,
                  color: _T.primary, size: 20),
              tooltip: 'Exportar PDF',
              padding: const EdgeInsets.all(6),
              constraints: const BoxConstraints(),
              onPressed: _exportPdf),
          IconButton(
              icon: Icon(Icons.refresh_rounded,
                  color: _T.textSecondary(context), size: 20),
              tooltip: 'Atualizar',
              padding: const EdgeInsets.all(6),
              constraints: const BoxConstraints(),
              onPressed: _loadData),
          IconButton(
            icon: Icon(
                _selectMode
                    ? Icons.check_box_rounded
                    : Icons.check_box_outline_blank_rounded,
                color: _selectMode ? _T.primary : _T.textSecondary(context),
                size: 20),
            padding: const EdgeInsets.all(6),
            constraints: const BoxConstraints(),
            onPressed: () => setState(() {
              _selectMode = !_selectMode;
              _selected.clear();
            }),
          ),
        ]),
      );

  Widget _buildSearch() => Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        color: _T.surface(context),
        child: TextField(
          controller: _searchCtrl,
          onChanged: (v) => setState(() => _searchQ = v),
          style: TextStyle(fontSize: 13, color: _T.textPrimary(context)),
          decoration: InputDecoration(
            hintText: 'Pesquisar descrição, quem ou setor...',
            hintStyle:
                TextStyle(fontSize: 12, color: _T.textSecondary(context)),
            prefixIcon: Icon(Icons.search_rounded,
                color: _T.textSecondary(context), size: 18),
            suffixIcon: _searchQ.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.clear_rounded,
                        color: _T.textSecondary(context), size: 16),
                    onPressed: () {
                      _searchCtrl.clear();
                      setState(() => _searchQ = '');
                    })
                : null,
            filled: true,
            fillColor: _T.surface2(context),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            isDense: true,
          ),
        ),
      );

  Widget _buildTabBar2() => Container(
        color: _T.surface(context),
        child: TabBar(
          controller: _tabCtrl,
          indicatorColor: _T.primary,
          indicatorWeight: 2.5,
          indicatorSize: TabBarIndicatorSize.tab,
          labelColor: _T.primary,
          unselectedLabelColor: _T.textSecondary(context),
          labelStyle:
              const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
          dividerColor: _T.border(context),
          tabs: [
            const Tab(
                icon: Icon(Icons.pie_chart_rounded, size: 14),
                text: 'Visão Geral'),
            Tab(
                icon: const Icon(Icons.trending_down_rounded, size: 14),
                text: 'Gastos (${_filtGastos.length})'),
            Tab(
                icon:
                    const Icon(Icons.account_balance_wallet_rounded, size: 14),
                text: 'Receber (${_filtReceber.length})'),
          ],
        ),
      );

  Widget _buildOverview() {
    if (_gastos.isEmpty && _receber.isEmpty) return _buildEmpty();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _buildSaldoCard(),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(
              child: _dashCard(
                  'Gastos',
                  _fmtVal(_totGasto),
                  Icons.trending_down_rounded,
                  _T.spend,
                  '${_filtGastos.length} reg.')),
          const SizedBox(width: 10),
          Expanded(
              child: _dashCard(
                  'A Receber',
                  _fmtVal(_totReceber),
                  Icons.account_balance_wallet_rounded,
                  _T.earn,
                  '${_filtReceber.length} reg.')),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(
              child: _dashCard(
                  'Pendente',
                  _fmtVal(_totPendente),
                  Icons.hourglass_empty_rounded,
                  _T.warn,
                  '${_filtReceber.where((r) => !r.pago).length} pendentes')),
          const SizedBox(width: 10),
          Expanded(
              child: _dashCard(
                  'Recebido',
                  _fmtVal(_totRecebido),
                  Icons.check_circle_rounded,
                  _T.primary,
                  '${_filtReceber.where((r) => r.pago).length} concluídos')),
        ]),
        if (_filtGastos.isNotEmpty) ...[
          const SizedBox(height: 22),
          const _SectionLabel('GASTOS POR SETOR'),
          ..._buildBars(_filtGastos, _totGasto),
        ],
        if (_filtReceber.isNotEmpty) ...[
          const SizedBox(height: 22),
          const _SectionLabel('A RECEBER POR SETOR'),
          ..._buildBars(_filtReceber, _totReceber),
        ],
        if (_filtGastos.isNotEmpty) ...[
          const SizedBox(height: 22),
          const _SectionLabel('GASTOS POR PESSOA'),
          ..._buildPersonBars(_filtGastos, _totGasto),
        ],
        const SizedBox(height: 20),
      ]),
    );
  }

  Widget _buildSaldoCard() {
    final pos = _saldo >= 0;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: pos ? _T.gradEarn : _T.gradNeg,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: (pos ? _T.primary : _T.spend).withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 5))
        ],
      ),
      child: Row(children: [
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Saldo Geral',
                style: TextStyle(
                    color: Colors.white.withOpacity(0.75),
                    fontSize: 11,
                    fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),
            Text(_fmtVal(_saldo.abs()),
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.8)),
            const SizedBox(height: 4),
            Text(
                pos
                    ? '▲ Positivo — mais a receber do que gastos'
                    : '▼ Negativo — gastos maiores que receitas',
                style: TextStyle(
                    color: Colors.white.withOpacity(0.7), fontSize: 10)),
          ]),
        ),
        Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                borderRadius: BorderRadius.circular(14)),
            child: Icon(
                pos ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                color: Colors.white,
                size: 28)),
      ]),
    );
  }

  Widget _dashCard(
          String label, String value, IconData icon, Color color, String sub) =>
      Container(
        padding: const EdgeInsets.all(14),
        decoration: _T.cardDeco(context, accent: color),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                    color: color.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: color, size: 15)),
            const SizedBox(width: 8),
            Expanded(
                child: Text(label,
                    style: TextStyle(
                        color: _T.textSecondary(context), fontSize: 10))),
          ]),
          const SizedBox(height: 10),
          Text(value,
              style: TextStyle(
                  color: color,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3),
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 3),
          Text(sub,
              style: TextStyle(color: _T.textSecondary(context), fontSize: 10)),
        ]),
      );

  List<Widget> _buildBars(List<DashRecord> rows, double total) {
    final map = <String, double>{};
    for (final r in rows) map[r.setor] = (map[r.setor] ?? 0) + r.valor;
    final sorted = map.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.map((e) {
      final pct = total > 0 ? e.value / total : 0.0;
      final barColor = _sectorColor(e.key);
      final count = rows.where((r) => r.setor == e.key).length;
      return Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
                width: 10,
                height: 10,
                decoration:
                    BoxDecoration(color: barColor, shape: BoxShape.circle)),
            const SizedBox(width: 8),
            Expanded(
                child: Text(e.key,
                    style: TextStyle(
                        color: _T.textPrimary(context),
                        fontSize: 12,
                        fontWeight: FontWeight.w500))),
            Text('$count reg.',
                style:
                    TextStyle(fontSize: 11, color: _T.textSecondary(context))),
            const SizedBox(width: 10),
            Text(_fmtVal(e.value),
                style: TextStyle(
                    color: barColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w700)),
            const SizedBox(width: 8),
            Text('${(pct * 100).toStringAsFixed(1)}%',
                style:
                    TextStyle(fontSize: 11, color: _T.textSecondary(context))),
          ]),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
                value: pct,
                backgroundColor: barColor.withOpacity(0.12),
                valueColor: AlwaysStoppedAnimation<Color>(barColor),
                minHeight: 7),
          ),
        ]),
      );
    }).toList();
  }

  List<Widget> _buildPersonBars(List<DashRecord> rows, double total) {
    final map = <String, double>{};
    for (final r in rows) map[r.quem] = (map[r.quem] ?? 0) + r.valor;
    final sorted = map.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(5).map((e) {
      final pct = total > 0 ? e.value / total : 0.0;
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(children: [
          CircleAvatar(
              radius: 16,
              backgroundColor: _T.spend.withOpacity(0.12),
              child: Text(e.key.isNotEmpty ? e.key[0].toUpperCase() : '?',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _T.spend))),
          const SizedBox(width: 10),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(e.key,
                  style:
                      TextStyle(color: _T.textPrimary(context), fontSize: 12)),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                    value: pct,
                    backgroundColor: _T.spend.withOpacity(0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(_T.spend),
                    minHeight: 4),
              ),
            ]),
          ),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(_fmtVal(e.value),
                style: TextStyle(
                    color: _T.textPrimary(context),
                    fontSize: 11,
                    fontWeight: FontWeight.bold)),
            Text('${(pct * 100).toStringAsFixed(0)}%',
                style:
                    TextStyle(color: _T.textSecondary(context), fontSize: 10)),
          ]),
        ]),
      );
    }).toList();
  }

  Widget _buildGastosTab() {
    final rows = _filtGastos;
    if (rows.isEmpty) return _buildEmpty();
    return _buildTable(rows);
  }

  Widget _buildReceberTab() {
    final rows = _filtReceber;
    if (rows.isEmpty) return _buildEmpty('Nenhuma conta a receber.');
    return Column(children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        color: _T.surface(context),
        child: Row(children: [
          _receberBadge('Pendente', _totPendente, _T.warn),
          const SizedBox(width: 14),
          _receberBadge('Recebido', _totRecebido, _T.primary),
          const Spacer(),
          Text('Total: ${_fmtVal(_totReceber)}',
              style: TextStyle(
                  color: _T.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700)),
        ]),
      ),
      Expanded(child: _buildTable(rows, isReceber: true)),
    ]);
  }

  Widget _receberBadge(String label, double value, Color color) =>
      Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 5),
        Text('$label: ${_fmtVal(value)}',
            style: TextStyle(
                color: color, fontSize: 11, fontWeight: FontWeight.w600)),
      ]);

  Widget _buildTable(List<DashRecord> rows, {bool isReceber = false}) {
    return Column(children: [
      Container(
        color: _T.surface2(context),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(children: [
          if (_selectMode)
            SizedBox(
                width: 36,
                child: Checkbox(
                  value:
                      _selected.isNotEmpty && _selected.length == rows.length,
                  tristate:
                      _selected.isNotEmpty && _selected.length < rows.length,
                  onChanged: (v) => setState(() => v == true
                      ? _selected.addAll(rows.map((r) => r.docId))
                      : _selected.clear()),
                  activeColor: _T.primary,
                  checkColor: Colors.white,
                )),
          _sortHead('Data', 'criadoEm', flex: 17),
          _sortHead(isReceber ? 'Cliente' : 'Quem', 'quem', flex: 18),
          _sortHead('Setor', 'setor', flex: 14),
          Expanded(
              flex: 22,
              child: Text('Descrição',
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: _T.textSecondary(context)))),
          _sortHead('Valor', 'valor', flex: 16, right: true),
          if (isReceber) const SizedBox(width: 52),
          if (!isReceber) const SizedBox(width: 60),
        ]),
      ),
      Divider(height: 1, color: _T.border(context)),
      Expanded(
        child: ListView.separated(
          itemCount: rows.length,
          separatorBuilder: (_, __) =>
              Divider(height: 1, color: _T.border(context)),
          itemBuilder: (_, i) => _buildRow(rows[i], i, isReceber: isReceber),
        ),
      ),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
            color: _T.surface(context),
            border: Border(top: BorderSide(color: _T.border(context)))),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('${rows.length} lançamentos',
              style: TextStyle(fontSize: 11, color: _T.textSecondary(context))),
          Text(_fmtVal(rows.fold(0.0, (s, r) => s + r.valor)),
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: _T.primary)),
        ]),
      ),
    ]);
  }

  Widget _sortHead(String label, String field,
      {int flex = 1, bool right = false}) {
    final active = _sortField == field;
    return Expanded(
      flex: flex,
      child: GestureDetector(
        onTap: () => setState(() =>
            _sortField == field ? _sortAsc = !_sortAsc : _sortField = field),
        child: Row(
            mainAxisAlignment:
                right ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: active ? _T.primary : _T.textSecondary(context))),
              if (active)
                Icon(
                    _sortAsc
                        ? Icons.arrow_upward_rounded
                        : Icons.arrow_downward_rounded,
                    size: 10,
                    color: _T.primary),
            ]),
      ),
    );
  }

  Widget _buildRow(DashRecord rec, int index, {bool isReceber = false}) {
    final isSelected = _selected.contains(rec.docId);
    final color = isReceber ? _T.earn : _T.spend;
    return Dismissible(
      key: Key(rec.docId),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) =>
          _confirmDel('Excluir "${rec.descricao}" — ${_fmtVal(rec.valor)}?'),
      onDismissed: (_) => _deleteRecord(rec),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: _T.spend.withOpacity(0.1),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.delete_rounded, color: _T.spend),
          const SizedBox(width: 6),
          Text('Excluir',
              style: TextStyle(color: _T.spend, fontWeight: FontWeight.w600)),
        ]),
      ),
      child: GestureDetector(
        onTap: _selectMode
            ? () => setState(() => isSelected
                ? _selected.remove(rec.docId)
                : _selected.add(rec.docId))
            : null,
        child: Container(
          color: isSelected
              ? _T.primary.withOpacity(0.07)
              : index.isEven
                  ? _T.surface(context)
                  : _T.surface2(context),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
            if (_selectMode)
              SizedBox(
                  width: 36,
                  child: Checkbox(
                    value: isSelected,
                    onChanged: (v) => setState(() => v == true
                        ? _selected.add(rec.docId)
                        : _selected.remove(rec.docId)),
                    activeColor: _T.primary,
                    checkColor: Colors.white,
                  )),
            Expanded(
                flex: 17,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(rec.data,
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: _T.textPrimary(context))),
                      Text(rec.hora,
                          style: TextStyle(
                              fontSize: 9, color: _T.textSecondary(context))),
                    ])),
            Expanded(
                flex: 18,
                child: Row(children: [
                  CircleAvatar(
                      radius: 12,
                      backgroundColor: color.withOpacity(0.12),
                      child: Text(
                          rec.quem.isNotEmpty ? rec.quem[0].toUpperCase() : '?',
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: color))),
                  const SizedBox(width: 6),
                  Expanded(
                      child: Text(rec.quem,
                          style: TextStyle(
                              fontSize: 11, color: _T.textPrimary(context)),
                          overflow: TextOverflow.ellipsis)),
                ])),
            Expanded(
                flex: 14,
                child:
                    _Pill(rec.setor, _sectorColor(rec.setor), compact: true)),
            Expanded(
                flex: 22,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Text(rec.descricao,
                      style: TextStyle(
                          fontSize: 11, color: _T.textSecondary(context)),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2),
                )),
            Expanded(
                flex: 16,
                child: Text(_fmtVal(rec.valor),
                    textAlign: TextAlign.right,
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: color))),
            if (!_selectMode)
              Row(mainAxisSize: MainAxisSize.min, children: [
                const SizedBox(width: 4),
                if (isReceber)
                  InkWell(
                    onTap: () => _togglePago(rec),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                        padding: const EdgeInsets.all(5),
                        child: Icon(
                            rec.pago
                                ? Icons.check_circle_rounded
                                : Icons.radio_button_unchecked_rounded,
                            size: 16,
                            color: rec.pago ? _T.primary : _T.warn)),
                  ),
                InkWell(
                    onTap: () => _showEditDialog(rec),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                        padding: const EdgeInsets.all(5),
                        child: Icon(Icons.edit_rounded,
                            size: 15, color: _T.accent))),
                InkWell(
                  onTap: () async {
                    if (await _confirmDel('Excluir "${rec.descricao}"?')) {
                      _deleteRecord(rec);
                    }
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                      padding: const EdgeInsets.all(5),
                      child: Icon(Icons.delete_rounded,
                          size: 15, color: _T.spend)),
                ),
              ]),
          ]),
        ),
      ),
    );
  }

  Widget _buildSelectionBar() => SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
              color: _T.spend.withOpacity(0.07),
              border:
                  Border(top: BorderSide(color: _T.spend.withOpacity(0.22)))),
          child: Row(children: [
            Icon(Icons.check_circle_rounded, color: _T.spend, size: 18),
            const SizedBox(width: 10),
            Expanded(
                child: Text('${_selected.length} selecionado(s)',
                    style: TextStyle(
                        color: _T.spend, fontWeight: FontWeight.w600))),
            TextButton(
                onPressed: () => setState(() => _selected.clear()),
                child: Text('Limpar',
                    style: TextStyle(color: _T.textSecondary(context)))),
            ElevatedButton.icon(
              onPressed: () async {
                if (await _confirmDel(
                    'Excluir ${_selected.length} lançamento(s)?')) {
                  _deleteSelected();
                }
              },
              icon: const Icon(Icons.delete_rounded, size: 14),
              label: const Text('Excluir'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _T.spend,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              ),
            ),
          ]),
        ),
      );

  void _showFilters() {
    DateTime? ts = _dateStart, te = _dateEnd;
    String fs = _filterSetor, fq = _filterQuem;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: _T.surface2(context),
      isDismissible: true,
      enableDrag: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSt) => DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.65,
          maxChildSize: 0.92,
          shouldCloseOnMinExtent: true,
          builder: (_, sc) => SafeArea(
            top: false,
            child: SingleChildScrollView(
              controller: sc,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                        child: Container(
                            width: 36,
                            height: 4,
                            margin: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                                color: _T.border(context),
                                borderRadius: BorderRadius.circular(2)))),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Filtros',
                              style: TextStyle(
                                  color: _T.textPrimary(context),
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold)),
                          TextButton(
                              onPressed: () {
                                setState(() {
                                  _filterSetor = 'Todos';
                                  _filterQuem = 'Todos';
                                  _dateStart = null;
                                  _dateEnd = null;
                                });
                                Navigator.pop(ctx);
                              },
                              child: Text('Limpar tudo',
                                  style: TextStyle(color: _T.spend))),
                        ]),
                    const SizedBox(height: 14),
                    Text('Setor',
                        style: TextStyle(
                            color: _T.textPrimary(context),
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: kSetoresGasto
                            .map((s) =>
                                _fChip(s, fs, (v) => setSt(() => fs = v)))
                            .toList()),
                    const SizedBox(height: 14),
                    Text('Pessoa',
                        style: TextStyle(
                            color: _T.textPrimary(context),
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _quemList([..._gastos, ..._receber])
                            .map((q) =>
                                _fChip(q, fq, (v) => setSt(() => fq = v)))
                            .toList()),
                    const SizedBox(height: 14),
                    Text('Período',
                        style: TextStyle(
                            color: _T.textPrimary(context),
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Row(children: [
                      Expanded(
                          child: _dpicker(
                              'De', ts, (d) => setSt(() => ts = d), ctx)),
                      const SizedBox(width: 12),
                      Expanded(
                          child: _dpicker(
                              'Até', te, (d) => setSt(() => te = d), ctx,
                              first: ts)),
                    ]),
                    const SizedBox(height: 24),
                    SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _filterSetor = fs;
                              _filterQuem = fq;
                              _dateStart = ts;
                              _dateEnd = te;
                            });
                            Navigator.pop(ctx);
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: _T.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12))),
                          child: const Text('Aplicar',
                              style: TextStyle(fontWeight: FontWeight.w700)),
                        )),
                  ]),
            ),
          ),
        ),
      ),
    );
  }

  Widget _fChip(String label, String current, Function(String) onSel) {
    final sel = current == label;
    return FilterChip(
      label: Text(label,
          style: TextStyle(
              fontSize: 11, color: sel ? _T.primary : _T.textPrimary(context))),
      selected: sel,
      onSelected: (v) => onSel(v ? label : 'Todos'),
      selectedColor: _T.primary.withOpacity(0.14),
      checkmarkColor: _T.primary,
      backgroundColor: _T.surface(context),
      side: BorderSide(color: sel ? _T.primary : _T.border(context)),
    );
  }

  Widget _dpicker(String label, DateTime? val, Function(DateTime?) onPick,
          BuildContext ctx,
          {DateTime? first}) =>
      InkWell(
        onTap: () async {
          final d = await showDatePicker(
            context: ctx,
            initialDate: val ?? DateTime.now(),
            firstDate: first ?? DateTime(2020),
            lastDate: DateTime.now(),
            builder: (c, child) => Theme(
              data: ThemeData.dark().copyWith(
                  colorScheme: const ColorScheme.dark(
                      primary: _T.primary, onPrimary: Colors.white)),
              child: child!,
            ),
          );
          if (d != null) onPick(d);
        },
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            border: Border.all(
                color: val != null ? _T.primary : _T.border(context)),
            borderRadius: BorderRadius.circular(10),
            color: val != null
                ? _T.primary.withOpacity(0.06)
                : _T.surface(context),
          ),
          child: Row(children: [
            Icon(Icons.calendar_today_rounded,
                size: 14,
                color: val != null ? _T.primary : _T.textSecondary(context)),
            const SizedBox(width: 6),
            Expanded(
                child: Text(
              val != null ? _fmtDate(val) : label,
              style: TextStyle(
                  fontSize: 12,
                  color: val != null ? _T.primary : _T.textSecondary(context)),
              overflow: TextOverflow.ellipsis,
            )),
            if (val != null)
              GestureDetector(
                onTap: () => onPick(null),
                child: Icon(Icons.close_rounded,
                    size: 13, color: _T.textSecondary(context)),
              ),
          ]),
        ),
      );

  Widget _buildLoading() => Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
        SizedBox(
            width: 32,
            height: 32,
            child:
                CircularProgressIndicator(color: _T.primary, strokeWidth: 2.5)),
        const SizedBox(height: 14),
        Text('Carregando dados...',
            style: TextStyle(color: _T.textSecondary(context), fontSize: 13)),
      ]));

  Widget _buildError() => Center(
      child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.cloud_off_rounded, color: _T.spend, size: 48),
            const SizedBox(height: 12),
            Text('Erro ao carregar',
                style: TextStyle(
                    color: _T.textPrimary(context),
                    fontWeight: FontWeight.bold,
                    fontSize: 15)),
            const SizedBox(height: 6),
            Text(_error ?? '',
                textAlign: TextAlign.center,
                style:
                    TextStyle(fontSize: 12, color: _T.textSecondary(context))),
            if (_error != null &&
                (_error!.contains('permission') ||
                    _error!.contains('Permission')))
              Container(
                margin: const EdgeInsets.only(top: 14),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _T.warn.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _T.warn.withOpacity(0.3)),
                ),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Icon(Icons.info_outline_rounded,
                            color: _T.warn, size: 14),
                        const SizedBox(width: 6),
                        Text('Adicione as Rules no Firebase Console',
                            style: TextStyle(
                                color: _T.warn,
                                fontSize: 11,
                                fontWeight: FontWeight.bold)),
                      ]),
                      const SizedBox(height: 6),
                      Text(
                        'Firestore → Rules:\n\nmatch /financeiro/{d} {\n  allow read, write: if request.auth != null;\n}\nmatch /financeiro_receber/{d} {\n  allow read, write: if request.auth != null;\n}',
                        style: TextStyle(
                            color: _T.textSecondary(context), fontSize: 10),
                      ),
                    ]),
              ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Tentar novamente'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: _T.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))),
            ),
          ]))));

  Widget _buildEmpty([String msg = 'Nenhum lançamento encontrado.']) => Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.inbox_rounded, color: _T.textHint(context), size: 52),
        const SizedBox(height: 12),
        Text(msg,
            style: TextStyle(color: _T.textSecondary(context), fontSize: 13)),
        if (_hasFilters)
          TextButton(
            onPressed: () => setState(() {
              _filterSetor = 'Todos';
              _filterQuem = 'Todos';
              _dateStart = null;
              _dateEnd = null;
              _searchQ = '';
              _searchCtrl.clear();
            }),
            child: Text('Limpar filtros', style: TextStyle(color: _T.primary)),
          ),
      ]));
}

// ─────────────────────────────────────────────────────────────────────────────
// WIDGET 3 — EscolhaAtualCustomWidget (Painel de Controle)
// ─────────────────────────────────────────────────────────────────────────────

class _PanelItem {
  final String label;
  final String? subtitle;
  final IconData icon;
  final Color color;
  final String section;
  final Future<void> Function(BuildContext ctx)? action;

  const _PanelItem({
    required this.label,
    this.subtitle,
    required this.icon,
    required this.color,
    required this.section,
    this.action,
  });
}

class EscolhaAtualCustomWidget extends StatefulWidget {
  const EscolhaAtualCustomWidget({super.key, this.width, this.height});
  final double? width;
  final double? height;

  @override
  State<EscolhaAtualCustomWidget> createState() =>
      _EscolhaAtualCustomWidgetState();
}

class _EscolhaAtualCustomWidgetState extends State<EscolhaAtualCustomWidget> {
  Future<void> _sheet(Widget child) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      backgroundColor: Colors.transparent,
      enableDrag: true,
      useSafeArea: true,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.92,
        minChildSize: 0.25,
        maxChildSize: 0.95,
        shouldCloseOnMinExtent: true,
        builder: (_, ctrl) => _SheetWrap(controller: ctrl, child: child),
      ),
    );
  }

  Future<void> _sheetFin(Widget child) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      backgroundColor: Colors.transparent,
      enableDrag: true,
      useSafeArea: true,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.97,
        minChildSize: 0.25,
        maxChildSize: 0.99,
        shouldCloseOnMinExtent: true,
        builder: (_, ctrl) => CustomScrollView(
          controller: ctrl,
          slivers: [
            SliverFillRemaining(
              hasScrollBody: true,
              child: Container(
          decoration: BoxDecoration(
            color: _T.bg(context),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(children: [
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                          color: _T.border(context),
                          borderRadius: BorderRadius.circular(2))),
                  Positioned(
                    right: 0,
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: _T.surface2(context),
                          shape: BoxShape.circle,
                          border: Border.all(color: _T.border(context)),
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: _T.textSecondary(context),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Expanded(child: child),
          ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _confirm(String title, String msg) async {
    final res = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _T.surface2(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(children: [
          Icon(Icons.warning_amber_rounded, color: _T.warn, size: 22),
          const SizedBox(width: 8),
          Expanded(
              child: Text(title,
                  style: TextStyle(
                      color: _T.textPrimary(context),
                      fontWeight: FontWeight.bold,
                      fontSize: 15))),
        ]),
        content: Text(msg,
            style: TextStyle(color: _T.textSecondary(context), fontSize: 13)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text('Cancelar',
                  style: TextStyle(color: _T.textSecondary(context)))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: _T.spend,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
    return res ?? false;
  }

  void _snack(String msg, Color bg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: TextStyle(color: _T.textPrimary(context))),
      backgroundColor: bg,
      duration: const Duration(milliseconds: 3500),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  List<_PanelItem> get _items => [
        _PanelItem(
            label: 'Apagar todas O.S',
            subtitle: 'Ação irreversível',
            icon: Icons.delete_forever_rounded,
            color: _T.spend,
            section: 'Perigo',
            action: (ctx) async {
              final ok = await _confirm(
                  'ATENÇÃO!', 'Deseja apagar TODAS as ordens de serviço?');
              if (!ok) return;
              await actions.apagadocumentos();
              if (!mounted) return;
              Navigator.pop(context);
              _snack('Todas as O.S foram apagadas',
                  FlutterFlowTheme.of(context).error);
            }),
        _PanelItem(
            label: 'Zerar Pontuação',
            subtitle: 'Todos os técnicos',
            icon: Icons.refresh_outlined,
            color: _T.warn,
            section: 'Perigo',
            action: (ctx) async {
              final ok =
                  await _confirm('ATENÇÃO!', 'Deseja zerar a pontuação?');
              if (!ok) return;
              await actions.zerapontos();
              if (!mounted) return;
              Navigator.pop(context);
              _snack('Pontuação zerada', FlutterFlowTheme.of(context).tertiary);
            }),
        _PanelItem(
            label: 'Resetar Senha',
            subtitle: 'Redefinir acesso',
            icon: Icons.password_rounded,
            color: _T.info,
            section: 'Usuários',
            action: (ctx) async {
              await _sheet(const ResetarSenhaWidget());
              if (!mounted) return;
              Navigator.pop(context);
            }),
        _PanelItem(
            label: 'Adicionar Técnico',
            subtitle: 'Novo técnico',
            icon: Icons.person_add_outlined,
            color: _T.info,
            section: 'Usuários',
            action: (ctx) async {
              await _sheet(const AddTecnicoWidget());
              if (!mounted) return;
              Navigator.pop(context);
            }),
        _PanelItem(
            label: 'Cad./Editar Usuário',
            subtitle: 'Gerenciar usuários',
            icon: Icons.manage_accounts_rounded,
            color: _T.info,
            section: 'Usuários',
            action: (ctx) async {
              await _sheet(const UsuarioNovoWidget());
            }),
        _PanelItem(
            label: 'Liberar Financeiro',
            subtitle: 'Permissões de acesso',
            icon: Icons.account_balance_outlined,
            color: _T.accent,
            section: 'Usuários',
            action: (ctx) async {
              await showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: FlutterFlowTheme.of(context).primaryText,
                isDismissible: true,
                enableDrag: true,
                useSafeArea: true,
                builder: (_) => Padding(
                    padding: MediaQuery.viewInsetsOf(context),
                    child: const ListarPermissaoWidget()),
              );
              if (!mounted) return;
              Navigator.pop(context);
            }),
        _PanelItem(
            label: 'Nova O.S',
            subtitle: 'Criar ordem de serviço',
            icon: Icons.add_circle_outline_rounded,
            color: _T.earn,
            section: 'O.S',
            action: (ctx) async {
              await _sheet(const CadastrarNovoSemErroWidget());
            }),
        _PanelItem(
            label: 'Excluir O.S',
            subtitle: 'Remover ordem',
            icon: Icons.delete_outline_rounded,
            color: _T.spend,
            section: 'O.S',
            action: (ctx) async {
              await _sheet(const OsCustomEXCLUIRWidget(status: ''));
            }),
        _PanelItem(
            label: 'Enviar Notas',
            subtitle: 'Notas fiscais',
            icon: Icons.description_outlined,
            color: _T.earn,
            section: 'O.S',
            action: (ctx) async {
              await _sheet(const EnviarNotasWidget());
            }),
        _PanelItem(
            label: 'Formulário',
            subtitle: 'Preencher formulário',
            icon: Icons.format_align_left,
            color: _T.earn,
            section: 'O.S',
            action: (ctx) async {
              await _sheet(const FormularioWidget());
            }),
        _PanelItem(
            label: 'Preventiva',
            subtitle: 'Cadastrar nova',
            icon: Icons.list_alt_rounded,
            color: _T.primary,
            section: 'Preventivas',
            action: (ctx) async {
              await _sheet(const TestePreventivasWidget());
            }),
        _PanelItem(
            label: 'Preventivas Pendentes',
            subtitle: 'Ver pendências',
            icon: Icons.pending_actions_rounded,
            color: _T.primary,
            section: 'Preventivas',
            action: (ctx) async {
              await _sheet(const PreventivasPendenWidget());
            }),
        _PanelItem(
            label: 'Editar Preventiva',
            subtitle: 'Alterar existente',
            icon: Icons.edit_document,
            color: _T.primary,
            section: 'Preventivas',
            action: (ctx) async {
              await _sheet(const EditarPreventivaWidget());
            }),
        _PanelItem(
            label: 'Verificar Preventivas',
            subtitle: 'Preventivas pendentes',
            icon: Icons.domain_verification_rounded,
            color: _T.spend,
            section: 'Preventivas',
            action: (ctx) async {
              await _sheet(const PreventivasPendenWidget());
            }),
        _PanelItem(
            label: 'Cad./Editar Equipamento',
            subtitle: 'Gerenciar equipamentos',
            icon: Icons.precision_manufacturing_outlined,
            color: _T.warn,
            section: 'Equipamentos',
            action: (ctx) async {
              await _sheet(const CadastrarEquipamentoCustomwidgetWidget());
            }),
        _PanelItem(
            label: 'Nome Equipamento',
            subtitle: 'Cadastrar nome',
            icon: Icons.new_label_rounded,
            color: _T.warn,
            section: 'Equipamentos',
            action: (ctx) async {
              await _sheet(const EquipamentoDropdownWidget());
              if (!mounted) return;
              Navigator.pop(context);
            }),
        _PanelItem(
            label: 'Verificar Imagens',
            subtitle: 'Adicionar / excluir',
            icon: Icons.image_search_rounded,
            color: _T.info,
            section: 'Equipamentos',
            action: (ctx) async {
              await _sheet(const ImagensWidget());
            }),
        _PanelItem(
            label: 'Cadastrar Serviços',
            subtitle: 'Serviços e pontos',
            icon: Icons.add_business_outlined,
            color: _T.info,
            section: 'Serviços',
            action: (ctx) async {
              await _sheet(const AdicionarservicoWidget());
              if (!mounted) return;
              Navigator.pop(context);
            }),
        _PanelItem(
            label: 'Relatório Financeiro',
            subtitle: 'Ver relatório',
            icon: Icons.account_balance_rounded,
            color: _T.earn,
            section: 'Serviços',
            action: (ctx) async {
              await _sheet(const RelatorioFinanceiroWidget());
              if (!mounted) return;
              Navigator.pop(context);
            }),
        _PanelItem(
            label: 'Confirmar PDF',
            subtitle: 'PDFs pendentes',
            icon: Icons.picture_as_pdf_rounded,
            color: _T.earn,
            section: 'Serviços',
            action: (ctx) async {
              await _sheet(const PdfQueFaltaWidget());
            }),
        _PanelItem(
            label: 'Enviar Notificação',
            subtitle: 'Notificar usuários',
            icon: Icons.notifications_active_outlined,
            color: const Color(0xFF6B21A8),
            section: 'Serviços',
            action: (ctx) async {
              await _sheet(const EmailNovoWidget());
              if (!mounted) return;
              Navigator.pop(context);
            }),
        _PanelItem(
            label: 'Enviar Relatório',
            subtitle: 'Relatório por e-mail',
            icon: Icons.send_rounded,
            color: const Color(0xFF6B21A8),
            section: 'Serviços',
            action: (ctx) async {
              await _sheet(const EmailNovaWidget());
              if (!mounted) return;
              Navigator.pop(context);
            }),
        _PanelItem(
            label: 'DASHBOARD',
            subtitle: 'Painel de indicadores',
            icon: Icons.bar_chart_rounded,
            color: _T.accent,
            section: 'Geral',
            action: (ctx) async {
              context.pushNamed(DashboardWidget.routeName);
            }),
      ];

  List<String> get _sections => _items.map((e) => e.section).toSet().toList();

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final w = MediaQuery.sizeOf(context).width;
    final isPhone = w < 600;

    return SafeArea(
      bottom: true,
      child: Container(
        decoration: BoxDecoration(
          color: theme.secondaryBackground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(height: 10),
          Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                  color: theme.alternate,
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(children: [
              _GradientIcon(
                  icon: Icons.admin_panel_settings_rounded,
                  colors: [theme.primary, const Color(0xFF3730A3)],
                  size: 22,
                  containerSize: 46,
                  radius: 13),
              const SizedBox(width: 14),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text('Painel de Controle',
                        style: theme.titleMedium.override(
                            fontFamily: 'Inter Tight',
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0)),
                    Text('Gerencie O.S e configurações',
                        style: theme.bodySmall.override(
                            fontFamily: 'Inter',
                            color: theme.secondaryText,
                            fontSize: 11)),
                  ])),
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: theme.primaryBackground,
                    shape: BoxShape.circle,
                    border: Border.all(color: theme.alternate, width: 1.5),
                  ),
                  child: Icon(
                    Icons.close_rounded,
                    size: 20,
                    color: theme.secondaryText,
                  ),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 14),
          _buildFinanceBanner(theme),
          const SizedBox(height: 6),
          Divider(height: 1, color: theme.alternate),
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16, 16, 16, isPhone ? 24 : 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _sections.map((s) {
                  final items = _items.where((i) => i.section == s).toList();
                  return _buildSection(s, items, theme, w);
                }).toList(),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildFinanceBanner(FlutterFlowTheme theme) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [Color(0xFF064E3B), Color(0xFF0F766E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                  color: _T.primary.withOpacity(0.25),
                  blurRadius: 16,
                  offset: const Offset(0, 4))
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(9)),
                    child: const Icon(Icons.auto_awesome_rounded,
                        color: Colors.white, size: 16)),
                const SizedBox(width: 10),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Módulo Financeiro IA',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 13)),
                  Text('Gastos · Contas a Receber · Dashboard',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.7), fontSize: 10)),
                ]),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                    child: _finBtn(
                        icon: Icons.smart_toy_rounded,
                        label: 'IA Financeira',
                        subtitle: 'Registrar lançamentos',
                        onTap: () =>
                            _sheetFin(const FirebaseAiFinanceWidget()))),
                const SizedBox(width: 10),
                Expanded(
                    child: _finBtn(
                        icon: Icons.dashboard_rounded,
                        label: 'Dashboard',
                        subtitle: 'Gastos & Recebimentos',
                        onTap: () =>
                            _sheetFin(const FinanceDashboardWidget()))),
              ]),
            ]),
          ),
        ),
      );

  Widget _finBtn({
    required IconData icon,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
  }) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withOpacity(0.22))),
          child: Row(children: [
            Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(9)),
                child: Icon(icon, color: Colors.white, size: 18)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 12)),
                    Text(subtitle,
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.68),
                            fontSize: 9)),
                  ]),
            ),
            Icon(Icons.arrow_forward_ios_rounded,
                color: Colors.white.withOpacity(0.5), size: 12),
          ]),
        ),
      );

  Widget _buildSection(
      String title, List<_PanelItem> items, FlutterFlowTheme theme, double w) {
    final isDanger = title == 'Perigo';
    final cols = w < 400 ? 2 : (w < 768 ? 3 : (w < 1024 ? 4 : 5));

    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          if (isDanger)
            Container(
                margin: const EdgeInsets.only(right: 6),
                width: 3,
                height: 16,
                decoration: BoxDecoration(
                    color: _T.spend, borderRadius: BorderRadius.circular(2))),
          Text(title.toUpperCase(),
              style: TextStyle(
                  color: isDanger ? _T.spend : _T.textSecondary(context),
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                  letterSpacing: 0.8)),
        ]),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: cols,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: w < 400 ? 0.95 : 1.1),
          itemBuilder: (_, i) => _panelCard(items[i], theme, w),
        ),
        if (isDanger)
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: _T.spend.withOpacity(0.07),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _T.spend.withOpacity(0.2))),
            child: Row(children: [
              Icon(Icons.info_outline_rounded, size: 14, color: _T.spend),
              const SizedBox(width: 8),
              Expanded(
                  child: Text('Ações desta seção são irreversíveis.',
                      style: TextStyle(color: _T.spend, fontSize: 11))),
            ]),
          ),
      ]),
    );
  }

  Widget _panelCard(_PanelItem item, FlutterFlowTheme theme, double w) {
    final isPhone = w < 600;
    return GestureDetector(
      onTap: item.action != null ? () => item.action!(context) : null,
      child: Container(
        decoration: BoxDecoration(
            color: theme.primaryBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: item.color.withOpacity(0.22), width: 1),
            boxShadow: [
              BoxShadow(
                  color: item.color.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 3))
            ]),
        child: Padding(
          padding: EdgeInsets.all(isPhone ? 10 : 13),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
                width: isPhone ? 38 : 44,
                height: isPhone ? 38 : 44,
                decoration: BoxDecoration(
                    color: item.color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(11)),
                child: Icon(item.icon,
                    color: item.color, size: isPhone ? 20 : 24)),
            const SizedBox(height: 8),
            Text(item.label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.bodySmall.override(
                    fontFamily: 'Inter',
                    color: theme.primaryText,
                    fontSize: isPhone ? 9.5 : 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0)),
            if (item.subtitle != null && !isPhone) ...[
              const SizedBox(height: 2),
              Text(item.subtitle!,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.bodySmall.override(
                      fontFamily: 'Inter',
                      color: theme.secondaryText,
                      fontSize: 9,
                      letterSpacing: 0)),
            ],
          ]),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SHEET WRAP
// ─────────────────────────────────────────────────────────────────────────────

class _SheetWrap extends StatelessWidget {
  const _SheetWrap({required this.child, required this.controller});
  final Widget child;
  final ScrollController controller;

  @override
  Widget build(BuildContext context) => SafeArea(
        bottom: true,
        child: Container(
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).secondaryBackground,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(children: [
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                          color: FlutterFlowTheme.of(context).alternate,
                          borderRadius: BorderRadius.circular(2))),
                  Positioned(
                    right: 0,
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: FlutterFlowTheme.of(context).primaryBackground,
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: FlutterFlowTheme.of(context).alternate),
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: FlutterFlowTheme.of(context).secondaryText,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(child: child),
          ]),
        ),
      );
}
