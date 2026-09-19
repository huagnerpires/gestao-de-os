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

// ============================================================
// FirebaseAiChatWidget — texto puro via GoogleAI (fixo)
// Sem Live API, sem áudio, sem microfone, sem VertexAI
// Dependências: firebase_ai, image_picker, file_picker
// ============================================================

import 'package:flutter/services.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import 'package:google_fonts/google_fonts.dart';

class FirebaseAiChatWidget extends StatefulWidget {
  const FirebaseAiChatWidget({
    super.key,
    this.width,
    this.height,
    this.systemInstruction = '',
    this.titleText = 'Assistente HPS',
    this.subtitleText = 'Inteligência artificial para técnicos',
  });

  final double? width;
  final double? height;
  final String systemInstruction;
  final String titleText;
  final String subtitleText;

  @override
  State<FirebaseAiChatWidget> createState() => _FirebaseAiChatWidgetState();
}

class _FirebaseAiChatWidgetState extends State<FirebaseAiChatWidget>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();
  final List<_Msg> _messages = [];

  GenerativeModel? _model;
  ChatSession? _chat;

  bool _loading = false;
  bool _initialized = false;
  String? _errorInit;
  late AnimationController _dotCtrl;

  Uint8List? _pendingBytes;
  String? _pendingMime;
  String? _pendingName;
  bool _pendingIsFile = false;

  static const String _defaultSystem =
      'Você é um assistente inteligente da HPS REFRIGERAÇÃO. '
      'Responda em português brasileiro, de forma clara, '
      'objetiva e amigável. '
      'Quando receber imagens ou arquivos, analise-os '
      'detalhadamente.';

  static const String _appCheckFriendly =
      'A Inteligência Artificial está temporariamente indisponível. O Firebase exige App Check neste projeto. Toque em Tentar novamente ou peça ao administrador para ativar o App Check no console.';

  static const List<String> _modelCandidates = [
    'gemini-3-flash-preview',
    'gemini-2.0-flash',
    'gemini-2.5-flash',
  ];

  String _friendlyAiError(Object e, {String prefix = 'Erro ao inicializar: '}) {
    final s = e.toString();
    if (s.contains('App Check') ||
        s.contains('deactivated') ||
        s.contains('Firebase AI Logic')) {
      return _appCheckFriendly;
    }
    return '$prefix$e';
  }

  @override
  void initState() {
    super.initState();
    _dotCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _initModel();
  }

  void _initModel() {
    try {
      final raw = widget.systemInstruction.trim();
      final instruction = raw.isNotEmpty ? raw : _defaultSystem;

      Object? lastError;
      _model = null;
      _chat = null;
      for (final name in _modelCandidates) {
        try {
          _model = FirebaseAI.googleAI().generativeModel(
            model: name,
            systemInstruction: Content.system(instruction),
          );
          _chat = _model!.startChat();
          lastError = null;
          break;
        } catch (e) {
          lastError = e;
        }
      }
      if (_model == null || _chat == null) {
        throw lastError ?? Exception('Falha ao iniciar o modelo de IA');
      }

      setState(() {
        _initialized = true;
        _errorInit = null;
        _messages.add(_Msg(
          text: 'Olá! Sou seu assistente virtual da HPS '
              'REFRIGERAÇÃO.\n\nPode me perguntar sobre '
              'qualquer assunto, enviar imagens ou arquivos. '
              'Como posso ajudar?',
          isUser: false,
        ));
      });
    } catch (e) {
      setState(() {
        _errorInit = _friendlyAiError(e);
        _initialized = false;
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final f = await _picker.pickImage(
          source: source, imageQuality: 85, maxWidth: 1920);
      if (f == null) return;
      final bytes = await f.readAsBytes();
      final ext = f.name.split('.').last.toLowerCase();
      final mime = ext == 'png'
          ? 'image/png'
          : ext == 'webp'
              ? 'image/webp'
              : 'image/jpeg';
      setState(() {
        _pendingBytes = bytes;
        _pendingMime = mime;
        _pendingName = f.name;
        _pendingIsFile = false;
      });
    } catch (e) {
      _showSnack('Erro: $e');
    }
  }

  Future<void> _pickFile() async {
    try {
      final r = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'txt', 'csv', 'json', 'md'],
        withData: true,
      );
      if (r == null || r.files.isEmpty || r.files.first.bytes == null) return;
      final f = r.files.first;
      final ext = (f.extension ?? 'txt').toLowerCase();
      final mime = ext == 'pdf'
          ? 'application/pdf'
          : ext == 'csv'
              ? 'text/csv'
              : ext == 'json'
                  ? 'application/json'
                  : 'text/plain';
      setState(() {
        _pendingBytes = f.bytes;
        _pendingMime = mime;
        _pendingName = f.name;
        _pendingIsFile = true;
      });
    } catch (e) {
      _showSnack('Erro: $e');
    }
  }

  void _removePending() => setState(() {
        _pendingBytes = null;
        _pendingMime = null;
        _pendingName = null;
        _pendingIsFile = false;
      });

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty && _pendingBytes == null) return;
    if (_loading || _chat == null) return;

    _controller.clear();
    final imgBytes = _pendingBytes;
    final imgMime = _pendingMime ?? 'image/jpeg';
    final imgName = _pendingName;
    final isFile = _pendingIsFile;

    setState(() {
      _messages.add(_Msg(
        text: text.isEmpty
            ? (isFile ? '📎 ${imgName ?? 'Arquivo'}' : '📷 Imagem enviada')
            : text,
        isUser: true,
        imageBytes: (!isFile) ? imgBytes : null,
        fileName: isFile ? imgName : null,
      ));
      _pendingBytes = null;
      _pendingMime = null;
      _pendingName = null;
      _pendingIsFile = false;
      _loading = true;
    });
    _scrollToBottom();

    try {
      Content content;
      if (imgBytes != null) {
        content = Content.multi([
          InlineDataPart(imgMime, imgBytes),
          TextPart(text.isNotEmpty
              ? text
              : isFile
                  ? 'Analise este arquivo detalhadamente.'
                  : 'Analise esta imagem detalhadamente.'),
        ]);
      } else {
        content = Content.text(text);
      }

      final response = await _chat!.sendMessage(content);
      final reply = response.text ?? '(sem resposta)';

      setState(() {
        _messages.add(_Msg(text: reply, isUser: false));
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _messages.add(_Msg(
          text: _friendlyAiError(e, prefix: 'Erro: '),
          isUser: false,
          isError: true,
        ));
        _loading = false;
      });
    }
    _scrollToBottom();
  }

  void _copyText(String t) {
    Clipboard.setData(ClipboardData(text: t));
    _showSnack('Copiado!');
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _clear() {
    setState(() {
      _chat = _model?.startChat();
      _messages.clear();
      _messages.add(
          _Msg(text: 'Conversa reiniciada. Como posso ajudar?', isUser: false));
    });
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      duration: const Duration(seconds: 2),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  void _showAttachMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: _surface,
      isDismissible: true,
      enableDrag: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                      color: _border, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 16),
              ListTile(
                leading: CircleAvatar(
                    backgroundColor: _accent.withOpacity(0.12),
                    child: Icon(Icons.photo_library_rounded, color: _accent)),
                title: Text('Galeria',
                    style: TextStyle(
                        color: _textPrimary, fontWeight: FontWeight.w500)),
                subtitle: Text('Enviar imagem da galeria',
                    style: TextStyle(color: _textSecondary, fontSize: 12)),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: CircleAvatar(
                    backgroundColor: _accent.withOpacity(0.12),
                    child: Icon(Icons.camera_alt_rounded, color: _accent)),
                title: Text('Câmera',
                    style: TextStyle(
                        color: _textPrimary, fontWeight: FontWeight.w500)),
                subtitle: Text('Tirar uma foto',
                    style: TextStyle(color: _textSecondary, fontSize: 12)),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: CircleAvatar(
                    backgroundColor: Colors.orange.withOpacity(0.12),
                    child: const Icon(Icons.attach_file_rounded,
                        color: Colors.orange)),
                title: Text('Arquivo',
                    style: TextStyle(
                        color: _textPrimary, fontWeight: FontWeight.w500)),
                subtitle: Text('PDF, TXT, CSV, JSON, MD',
                    style: TextStyle(color: _textSecondary, fontSize: 12)),
                onTap: () {
                  Navigator.pop(context);
                  _pickFile();
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _dotCtrl.dispose();
    super.dispose();
  }

  bool get _dark => true;
  Color get _bg => const Color(0xFF0B0F17);
  Color get _surface => const Color(0xFF131B2E);
  Color get _header => const Color(0xFF0B0F17);
  Color get _accent => const Color(0xFF0F766E);
  Color get _userBubble => const Color(0xFF1D4ED8);
  Color get _aiBubble => const Color(0xFF131B2E);
  Color get _textPrimary => const Color(0xFFF8FAFC);
  Color get _textSecondary => const Color(0xFF94A3B8);
  Color get _inputBg => const Color(0xFF0F172A);
  Color get _border => const Color(0xFF334155);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width ?? double.infinity,
      height: widget.height ?? 600,
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: _dark
                ? Colors.black.withOpacity(0.4)
                : Colors.black.withOpacity(0.06),
            blurRadius: 24,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            _buildHeader(),
            if (!_initialized && _errorInit != null)
              _buildInitError()
            else ...[
              Expanded(child: Container(color: _bg, child: _buildList())),
              if (_loading) _buildTyping(),
              if (_pendingBytes != null) _buildAttachPreview(),
              _buildInput(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
      decoration: BoxDecoration(
        color: _header,
        border: Border(bottom: BorderSide(color: _border)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F766E), Color(0xFF0369A1)],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F766E).withOpacity(0.35),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Icons.auto_awesome_rounded,
                color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.titleText,
                  style: GoogleFonts.interTight(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
                Row(children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: _accent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    widget.subtitleText,
                    style: GoogleFonts.inter(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 11,
                    ),
                  ),
                ]),
              ],
            ),
          ),
          if (_messages.length > 1)
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: _clear,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white.withOpacity(0.12)),
                  ),
                  child: const Icon(Icons.refresh_rounded,
                      color: Colors.white, size: 16),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInitError() {
    return Expanded(
      child: Container(
        color: _bg,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.error_outline, color: Colors.red[400], size: 40),
              const SizedBox(height: 12),
              Text(_errorInit ?? '',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: _textSecondary, fontSize: 13)),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: _initModel,
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar novamente'),
                style: TextButton.styleFrom(foregroundColor: _accent),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _buildList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      itemCount: _messages.length,
      itemBuilder: (_, i) => _buildBubble(_messages[i]),
    );
  }

  Widget _buildBubble(_Msg msg) {
    final isUser = msg.isUser;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: _accent.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _accent.withOpacity(0.3)),
              ),
              child: Icon(Icons.auto_awesome, color: _accent, size: 14),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isUser
                        ? _userBubble
                        : msg.isError
                            ? (_dark
                                ? const Color(0xFF3D1A1A)
                                : const Color(0xFFFFF0F0))
                            : _aiBubble,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isUser ? 16 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 16),
                    ),
                    border: msg.isError
                        ? Border.all(color: Colors.red.withOpacity(0.3))
                        : !isUser && !_dark
                            ? Border.all(color: _border)
                            : null,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (msg.imageBytes != null) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.memory(msg.imageBytes!,
                              width: 200, fit: BoxFit.cover),
                        ),
                        if (msg.text.isNotEmpty &&
                            msg.text != '📷 Imagem enviada')
                          const SizedBox(height: 8),
                      ],
                      if (msg.fileName != null) ...[
                        Row(children: [
                          const Icon(Icons.attach_file_rounded,
                              color: Colors.orange, size: 16),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(msg.fileName!,
                                style: const TextStyle(
                                    color: Colors.orange,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500),
                                overflow: TextOverflow.ellipsis),
                          ),
                        ]),
                        if (msg.text.isNotEmpty) const SizedBox(height: 6),
                      ],
                      if (msg.text.isNotEmpty &&
                          msg.text != '📷 Imagem enviada' &&
                          !msg.text.startsWith('📎'))
                        Text(msg.text,
                            style: GoogleFonts.inter(
                              color: isUser
                                  ? Colors.white
                                  : msg.isError
                                      ? Colors.red[300]
                                      : _textPrimary,
                              fontSize: 13.5,
                              height: 1.55,
                            )),
                    ],
                  ),
                ),
                if (!isUser && !msg.isError && msg.text.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4, left: 4),
                    child: GestureDetector(
                      onTap: () => _copyText(msg.text),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.copy_rounded,
                            size: 12, color: _textSecondary),
                        const SizedBox(width: 3),
                        Text('Copiar',
                            style:
                                TextStyle(fontSize: 11, color: _textSecondary)),
                      ]),
                    ),
                  ),
              ],
            ),
          ),
          if (isUser) const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildTyping() {
    return Container(
      color: _bg,
      padding: const EdgeInsets.fromLTRB(20, 0, 0, 10),
      child: Row(children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: _accent.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.auto_awesome, color: _accent, size: 14),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: _aiBubble,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
              bottomRight: Radius.circular(16),
              bottomLeft: Radius.circular(4),
            ),
          ),
          child: AnimatedBuilder(
            animation: _dotCtrl,
            builder: (_, __) => Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) {
                final delay = i / 3;
                final t = (_dotCtrl.value - delay).clamp(0.0, 1.0);
                final opacity = (t < 0.5 ? t * 2 : (1 - t) * 2).clamp(0.3, 1.0);
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                      color: _accent.withOpacity(opacity),
                      shape: BoxShape.circle),
                );
              }),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _buildAttachPreview() {
    return Container(
      color: _bg,
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 4),
      child: Row(children: [
        _pendingIsFile
            ? Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: const Icon(Icons.description_rounded,
                    color: Colors.orange, size: 22))
            : ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.memory(_pendingBytes!,
                    width: 48, height: 48, fit: BoxFit.cover)),
        const SizedBox(width: 10),
        Expanded(
            child: Text(_pendingName ?? 'Anexo selecionado',
                style: TextStyle(color: _textSecondary, fontSize: 12),
                overflow: TextOverflow.ellipsis)),
        GestureDetector(
          onTap: _removePending,
          child: Container(
            width: 22,
            height: 22,
            decoration:
                BoxDecoration(color: Colors.red[600], shape: BoxShape.circle),
            child: const Icon(Icons.close, color: Colors.white, size: 13),
          ),
        ),
      ]),
    );
  }

  Widget _buildInput() {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 14),
      decoration: BoxDecoration(
        color: _surface,
        border: Border(top: BorderSide(color: _border)),
      ),
      child: Row(children: [
        _iconBtn(
          icon: Icons.add_rounded,
          color: _pendingBytes != null ? _accent : _textSecondary,
          bg: _inputBg,
          border: _pendingBytes != null ? _accent : _border,
          onTap: _showAttachMenu,
          active: _pendingBytes != null,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: _inputBg,
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: _border),
            ),
            child: TextField(
              controller: _controller,
              minLines: 1,
              maxLines: 5,
              style: GoogleFonts.inter(color: _textPrimary, fontSize: 13.5),
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _send(),
              decoration: InputDecoration(
                hintText: 'Pergunte qualquer coisa ao assistente...',
                hintStyle: GoogleFonts.inter(color: _textSecondary, fontSize: 13),
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
              ),
            ),
          ),
        ),
        const SizedBox(width: 6),
        _loading
            ? SizedBox(
                width: 42,
                height: 42,
                child:
                    CircularProgressIndicator(strokeWidth: 2, color: _accent))
            : _iconBtn(
                icon: Icons.send_rounded,
                color: Colors.white,
                bg: _accent,
                border: _accent,
                onTap: _send,
                active: false,
              ),
      ]),
    );
  }

  Widget _iconBtn({
    required IconData icon,
    required Color color,
    required Color bg,
    required Color border,
    required VoidCallback onTap,
    required bool active,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(21),
          border: Border.all(color: border, width: active ? 1.5 : 1),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }
}

class _Msg {
  final String text;
  final bool isUser;
  final bool isError;
  final Uint8List? imageBytes;
  final String? fileName;
  _Msg({
    required this.text,
    required this.isUser,
    this.isError = false,
    this.imageBytes,
    this.fileName,
  });
}
