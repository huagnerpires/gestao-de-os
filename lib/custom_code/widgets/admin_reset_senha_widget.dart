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
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// ── OneSignal ─────────────────────────────────────────────────────────────────
const String _kOsAppId = '7b01186f-cf76-4b5d-8354-87d83737d40c';
const String _kOsApiKey = 'ZTdlNjIwZWItMjEyMC00M2RhLWJlZmYtMzc2NTBmNzNmMDdj';
const String _kOsChannel = '577bba44-d1bf-4ac9-9d11-20d89e09a61a';

const Color _kVerde = Color(0xFF1A3C34);
const Color _kPrimary = Color(0xFF0F766E);
const Color _kRed = Color(0xFFB91C1C);
const Color _kOrange = Color(0xFFC2410C);
const Color _kGreen = Color(0xFF2E7D32);
const Color _kBlue = Color(0xFF1D4ED8);

Future<void> _enviarPushOneSignalAdmin({
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
          {'field': 'tag', 'key': 'E-mail', 'relation': '=', 'value': email},
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

class AdminResetSenhaWidget extends StatefulWidget {
  const AdminResetSenhaWidget({Key? key, this.width, this.height})
      : super(key: key);
  final double? width;
  final double? height;

  @override
  State<AdminResetSenhaWidget> createState() => _AdminResetSenhaWidgetState();
}

class _AdminResetSenhaWidgetState extends State<AdminResetSenhaWidget> {
  int _paginaAtual = 0;

  // ── Solicitações ────────────────────────────────────────────────────────────
  String? _docIdSelecionado;
  Map<String, dynamic>? _solSelecionada;
  final _novaSenhaCtrl = TextEditingController();
  final _confirmarCtrl = TextEditingController();
  bool _showNova = false;
  bool _showConfirmar = false;
  bool _processando = false;
  String _feedbackSol = '';
  bool _feedbackOk = false;

  // ── Reset rápido ────────────────────────────────────────────────────────────
  String? _emailRapido;
  List<String> _emailsAdicionaisRapido = [];
  List<String> _emailsSelecionadosRapido = [];
  final _senhaRapidaCtrl = TextEditingController();
  final _confirmarRapidaCtrl = TextEditingController();
  bool _showRapida = false;
  bool _showConfirmarRapida = false;

  // ── Usuários ─────────────────────────────────────────────────────────────────
  // Estrutura interna: {'id', 'email', 'nome', 'ativo', 'emailteste': List<String>}
  // Campos Firestore confirmados na coleção USUARIOS: 'email' e 'emailteste' (sem hífen)
  List<Map<String, dynamic>> _todosUsuarios = [];
  bool _loadingUsuarios = true;
  String _buscaUsuario = '';

  // ── Notificação manual ──────────────────────────────────────────────────────
  String? _emailNotif;
  List<String> _emailsAdicionaisNotif = [];
  List<String> _emailsSelecionadosNotif = [];
  final _tituloCtrl = TextEditingController();
  final _msgCtrl = TextEditingController();
  bool _enviandoNotif = false;
  String _feedbackNotif = '';
  bool _feedbackNotifOk = false;

  @override
  void initState() {
    super.initState();
    _carregarUsuarios();
  }

  @override
  void dispose() {
    _novaSenhaCtrl.dispose();
    _confirmarCtrl.dispose();
    _senhaRapidaCtrl.dispose();
    _confirmarRapidaCtrl.dispose();
    _tituloCtrl.dispose();
    _msgCtrl.dispose();
    super.dispose();
  }

  // ── Carrega usuários ─────────────────────────────────────────────────────────
  Future<void> _carregarUsuarios() async {
    try {
      final snap =
          await FirebaseFirestore.instance.collection('USUARIOS').get();
      final lista = <Map<String, dynamic>>[];
      for (final doc in snap.docs) {
        final d = doc.data();
        // Campos Firestore confirmados: 'email' e 'emailteste' (sem hífen)
        final email = d['email']?.toString().trim() ?? '';
        if (email.isEmpty) continue;
        final nome = d['display_name']?.toString().trim() ?? email;

        final extras = <String>[];
        final field = d['emailteste'];
        if (field is List) {
          for (final e in field) {
            final s = (e ?? '').toString().trim();
            if (s.isNotEmpty) extras.add(s);
          }
        } else if (field is String && field.trim().isNotEmpty) {
          extras.add(field.trim());
        }

        lista.add({
          'id': doc.id,
          'email': email,
          'nome': nome,
          'ativo': d['ativo'] != false,
          'emailteste': extras,
        });
      }
      lista
          .sort((a, b) => (a['nome'] as String).compareTo(b['nome'] as String));
      if (!mounted) return;
      setState(() {
        _todosUsuarios = lista;
        _loadingUsuarios = false;
        // Limpa seleção se o email sumiu da lista após reload
        if (!lista.any((u) => u['email'] == _emailRapido)) {
          _emailRapido = null;
          _emailsAdicionaisRapido = [];
          _emailsSelecionadosRapido = [];
        }
        if (!lista.any((u) => u['email'] == _emailNotif)) {
          _emailNotif = null;
          _emailsAdicionaisNotif = [];
          _emailsSelecionadosNotif = [];
        }
      });
    } catch (_) {
      if (mounted) setState(() => _loadingUsuarios = false);
    }
  }

  // ── Monta lista de emails — igual ao EnviarRelatorioEmailWidget ──────────────
  List<String> _montarListaEmails(String emailPrincipal, List emailteste) {
    final extras = <String>[];
    for (final e in emailteste) {
      final s = e?.toString().trim() ?? '';
      if (s.isNotEmpty) extras.add(s);
    }
    final set = <String>{emailPrincipal, ...extras};
    final lista = set.toList();
    lista.remove(emailPrincipal);
    lista.insert(0, emailPrincipal);
    return lista;
  }

  // ── Busca apibrevo ───────────────────────────────────────────────────────────
  Future<String> _getApiBrevo() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('USUARIOS')
          .where('email', isEqualTo: 'hpsrefri@gmail.com')
          .limit(1)
          .get();
      if (snap.docs.isNotEmpty) {
        return (snap.docs.first.data()['apibrevo'] ?? '').toString().trim();
      }
    } catch (_) {}
    return '';
  }

  // ── Reset via Cloud Function ─────────────────────────────────────────────────
  Future<bool> _chamarReset(String emailAlvo, String novaSenha) async {
    try {
      final res = await http.post(
        Uri.parse(
            'https://us-central1-h-p-s-modificado-emdcp0.cloudfunctions.net/resetarSenhaAdmin'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'data': {'novaSenha': novaSenha, 'e-mailAlvo': emailAlvo}
        }),
      );
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // ── Envia email Brevo ────────────────────────────────────────────────────────
  Future<void> _enviarEmail({
    required String para,
    required String assunto,
    required String corpo,
  }) async {
    final apiKey = await _getApiBrevo();
    if (apiKey.isEmpty) return;

    const imgUrl =
        'https://firebasestorage.googleapis.com/v0/b/h-p-s-modificado-emdcp0.appspot.com/o/Gemini_Generated_Image_2xpdsd2xpdsd2xpd%20(1).png?alt=media&token=be3e052e-a0b8-4e8c-8151-b9365b507ed5';

    final htmlFull = '<!DOCTYPE html><html lang="pt-BR"><head>'
        '<meta charset="UTF-8"><title>$assunto</title></head>'
        '<body style="margin:0;padding:0;background-color:#f4f6f8;font-family:Arial,Helvetica,sans-serif;">'
        '<table width="100%" cellpadding="0" cellspacing="0" border="0" style="background-color:#f4f6f8;padding:20px 0;">'
        '<tr><td align="center">'
        '<table width="600" cellpadding="0" cellspacing="0" border="0" style="background:#ffffff;border-radius:12px;overflow:hidden;max-width:1400px;width:100%;">'
        '<tr><td style="padding:0;margin:0;line-height:0;">'
        '<img src="$imgUrl" alt="HPS Refrigeração" width="600" style="display:block;width:100%;max-width:1400px;height:auto;border:0;"/>'
        '</td></tr>'
        '<tr><td style="background-color:#1A3C34;padding:12px 24px;">'
        '<span style="background:#ffffff20;color:#ffffff;font-size:11px;font-weight:bold;padding:4px 10px;border-radius:20px;">Notificação Automática</span>'
        '</td></tr>'
        '<tr><td style="padding:28px;color:#333333;font-size:15px;line-height:1.7;">$corpo</td></tr>'
        '<tr><td style="padding:0 28px;"><hr style="border:none;border-top:1px solid #e8ecf0;margin:0;"></td></tr>'
        '<tr><td style="padding:20px 28px;">'
        '<table cellpadding="0" cellspacing="0" border="0"><tr>'
        '<td style="width:44px;vertical-align:top;">'
        '<div style="width:40px;height:40px;background:#1A3C34;border-radius:50%;text-align:center;line-height:40px;">'
        '<span style="color:#fff;font-size:18px;font-weight:bold;">H</span></div></td>'
        '<td style="padding-left:12px;vertical-align:top;">'
        '<span style="font-size:15px;font-weight:bold;color:#1A3C34;">Huagner Pires</span><br>'
        '<span style="font-size:13px;color:#555555;">Especialista em Refrigeração</span><br>'
        '<span style="font-size:12px;color:#888888;">hpsrefri.com.br</span>'
        '</td></tr></table></td></tr>'
        '<tr><td style="background:#f1f5f9;padding:14px 28px;text-align:center;font-size:12px;color:#94a3b8;border-top:1px solid #e2e8f0;">'
        '&copy; 2026 HPS Refrigeração &middot; Todos os direitos reservados<br>'
        '<span style="font-size:11px;">Esta é uma mensagem automática.</span>'
        '</td></tr></table></td></tr></table></body></html>';

    await http.post(
      Uri.parse('https://api.brevo.com/v3/smtp/email'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'api-key': apiKey,
      },
      body: jsonEncode({
        'sender': {
          'name': 'HPS Refrigeração',
          'email': 'equipe@hpsrefri.com.br'
        },
        'replyTo': {
          'name': 'HPS Refrigeração',
          'email': 'equipe@hpsrefri.com.br'
        },
        'to': [
          {'email': para}
        ],
        'subject': assunto,
        'htmlContent': htmlFull,
      }),
    );
  }

  // ── Notificação Firebase ─────────────────────────────────────────────────────
  Future<void> _criarNotificacao({
    required String email,
    required String titulo,
    required String mensagem,
    String tipo = 'sistema',
  }) async {
    await FirebaseFirestore.instance.collection('NOTIFICACAO').add({
      'e-mail': email,
      'título': titulo,
      'mensagem': mensagem,
      'tipo': tipo,
      'visto': false,
      'data': Timestamp.now(),
      'status': 'pendente',
      'os': '',
    });
  }

  // ── AÇÃO: Resolver solicitação ───────────────────────────────────────────────
  Future<void> _resolverSolicitacao() async {
    final nova = _novaSenhaCtrl.text.trim();
    final conf = _confirmarCtrl.text.trim();
    final sol = _solSelecionada;
    if (sol == null) return;
    if (nova.isEmpty || conf.isEmpty) {
      setState(() {
        _feedbackSol = 'Preencha os dois campos.';
        _feedbackOk = false;
      });
      return;
    }
    if (nova.length < 6) {
      setState(() {
        _feedbackSol = 'Mínimo 6 caracteres.';
        _feedbackOk = false;
      });
      return;
    }
    if (nova != conf) {
      setState(() {
        _feedbackSol = 'As senhas não coincidem.';
        _feedbackOk = false;
      });
      return;
    }

    setState(() {
      _processando = true;
      _feedbackSol = '';
    });

    final emailAlvo = sol['e-mail']?.toString() ?? '';
    final nomeAlvo = sol['nome']?.toString() ?? emailAlvo;

    final ok = await _chamarReset(emailAlvo, nova);
    if (!ok) {
      setState(() {
        _feedbackSol = 'Erro ao chamar Cloud Function.';
        _feedbackOk = false;
        _processando = false;
      });
      return;
    }

    await FirebaseFirestore.instance
        .collection('SOLICITACOES_SENHA')
        .doc(_docIdSelecionado)
        .update({
      'status': 'resolvido',
      'resolvidoEm': FieldValue.serverTimestamp(),
      'resolvidoPor': 'hpsrefri@gmail.com',
      'novaSenha': nova,
    });

    await _criarNotificacao(
      email: emailAlvo,
      titulo: 'Senha Redefinida',
      mensagem:
          'Sua senha foi redefinida pela equipe HPS. Verifique seu email.',
    );
    await _enviarPushOneSignalAdmin(
      email: emailAlvo,
      titulo: 'Senha Redefinida com Sucesso',
      mensagem:
          'Sua senha foi redefinida pela equipe HPS. Verifique seu email.',
    );

    final corpoEmail =
        '<h2 style="margin:0 0 16px;color:#1A3C34;">Olá, $nomeAlvo!</h2>'
        '<p style="font-size:15px;color:#374151;line-height:1.7;">Sua senha foi <strong>redefinida com sucesso</strong> pela equipe HPS.</p>'
        '<table width="100%" cellpadding="0" cellspacing="0" border="0" style="border-collapse:collapse;border:1px solid #e2e8f0;font-size:14px;margin-bottom:16px;">'
        '<tr><td colspan="2" style="background:#1A3C34;padding:10px 14px;"><span style="color:#fff;font-weight:bold;">SUAS CREDENCIAIS</span></td></tr>'
        '<tr><td style="padding:12px 14px;font-weight:bold;color:#374151;width:120px;border-bottom:1px solid #e2e8f0;">Email</td>'
        '<td style="padding:12px 14px;border-bottom:1px solid #e2e8f0;">$emailAlvo</td></tr>'
        '<tr style="background:#f8fafc;"><td style="padding:12px 14px;font-weight:bold;color:#374151;">Nova Senha</td>'
        '<td style="padding:12px 14px;"><span style="background:#f0fdf4;border:1px solid #2E7D32;border-radius:6px;'
        'padding:6px 14px;font-size:16px;font-weight:bold;color:#1A3C34;letter-spacing:2px;">$nova</span></td></tr>'
        '</table>'
        '<p style="background:#fff3cd;border-left:4px solid #C2410C;padding:12px;color:#856404;margin:0;">'
        'Por segurança, altere sua senha após o primeiro acesso.</p>';

    await _enviarEmail(
        para: emailAlvo,
        assunto: 'Sua senha foi redefinida - HPS',
        corpo: corpoEmail);

    _novaSenhaCtrl.clear();
    _confirmarCtrl.clear();
    setState(() {
      _processando = false;
      _feedbackOk = true;
      _feedbackSol = 'Senha redefinida! Email e notificação enviados.';
      _docIdSelecionado = null;
      _solSelecionada = null;
    });
  }

  // ── AÇÃO: Rejeitar solicitação ───────────────────────────────────────────────
  Future<void> _rejeitarSolicitacao(String docId) async {
    await FirebaseFirestore.instance
        .collection('SOLICITACOES_SENHA')
        .doc(docId)
        .update({
      'status': 'rejeitado',
      'resolvidoEm': FieldValue.serverTimestamp(),
      'resolvidoPor': 'hpsrefri@gmail.com',
    });
    setState(() {
      _feedbackOk = true;
      _feedbackSol = 'Solicitação rejeitada.';
      _docIdSelecionado = null;
      _solSelecionada = null;
    });
  }

  // ── AÇÃO: Reset rápido ───────────────────────────────────────────────────────
  Future<void> _resetRapido() async {
    final nova = _senhaRapidaCtrl.text.trim();
    final conf = _confirmarRapidaCtrl.text.trim();
    if (_emailRapido == null) {
      _snack('Selecione um usuário.');
      return;
    }
    if (_emailsSelecionadosRapido.isEmpty) {
      _snack('Marque pelo menos um email para receber a notificação.');
      return;
    }
    if (nova.isEmpty || conf.isEmpty) {
      _snack('Preencha os dois campos.');
      return;
    }
    if (nova.length < 6) {
      _snack('Mínimo 6 caracteres.');
      return;
    }
    if (nova != conf) {
      _snack('As senhas não coincidem.');
      return;
    }

    setState(() => _processando = true);

    final ok = await _chamarReset(_emailRapido!, nova);
    if (!ok) {
      setState(() => _processando = false);
      _snack('Erro ao redefinir senha.');
      return;
    }

    final usuario = _todosUsuarios.firstWhere((u) => u['email'] == _emailRapido,
        orElse: () => {});
    final nome = usuario['nome']?.toString() ?? _emailRapido!;

    await _criarNotificacao(
      email: _emailRapido!,
      titulo: 'Senha Redefinida pelo Admin',
      mensagem: 'Sua senha foi redefinida. Verifique seu email.',
    );
    await _enviarPushOneSignalAdmin(
      email: _emailRapido!,
      titulo: 'Senha Redefinida',
      mensagem:
          'Sua senha foi redefinida pelo administrador HPS. Verifique seu email.',
    );

    final corpoEmail =
        '<h2 style="margin:0 0 16px;color:#1A3C34;">Olá, $nome!</h2>'
        '<p style="font-size:15px;color:#374151;line-height:1.7;">Sua senha foi redefinida pelo administrador da HPS Refrigeração.</p>'
        '<table width="100%" cellpadding="0" cellspacing="0" border="0" style="border-collapse:collapse;border:1px solid #e2e8f0;font-size:14px;margin-bottom:16px;">'
        '<tr><td colspan="2" style="background:#1A3C34;padding:10px 14px;"><span style="color:#fff;font-weight:bold;">CREDENCIAIS</span></td></tr>'
        '<tr><td style="padding:12px 14px;font-weight:bold;color:#374151;width:120px;border-bottom:1px solid #e2e8f0;">Email</td>'
        '<td style="padding:12px 14px;border-bottom:1px solid #e2e8f0;">${_emailRapido!}</td></tr>'
        '<tr style="background:#f8fafc;"><td style="padding:12px 14px;font-weight:bold;color:#374151;">Nova Senha</td>'
        '<td style="padding:12px 14px;"><span style="background:#f0fdf4;border:1px solid #2E7D32;border-radius:6px;'
        'padding:6px 14px;font-size:16px;font-weight:bold;color:#1A3C34;letter-spacing:2px;">$nova</span></td></tr>'
        '</table>'
        '<p style="background:#fff3cd;border-left:4px solid #C2410C;padding:12px;color:#856404;margin:0;">'
        'Por segurança, altere sua senha após o primeiro acesso.</p>';

    for (final em in _emailsSelecionadosRapido) {
      await _enviarEmail(
          para: em, assunto: 'Senha redefinida - HPS', corpo: corpoEmail);
    }

    _senhaRapidaCtrl.clear();
    _confirmarRapidaCtrl.clear();
    setState(() {
      _processando = false;
      _emailRapido = null;
      _emailsAdicionaisRapido = [];
      _emailsSelecionadosRapido = [];
    });
    _snack('Senha redefinida com sucesso!');
  }

  // ── AÇÃO: Toggle ativo ───────────────────────────────────────────────────────
  Future<void> _toggleAtivo(String docId, bool ativoAtual) async {
    await FirebaseFirestore.instance
        .collection('USUARIOS')
        .doc(docId)
        .update({'ativo': !ativoAtual});
    await _carregarUsuarios();
    _snack(ativoAtual ? 'Usuário desativado.' : 'Usuário ativado.');
  }

  // ── AÇÃO: Enviar notificação manual ──────────────────────────────────────────
  Future<void> _enviarNotificacao() async {
    final titulo = _tituloCtrl.text.trim();
    final msg = _msgCtrl.text.trim();
    if (_emailNotif == null) {
      setState(() {
        _feedbackNotif = 'Selecione o destinatário.';
        _feedbackNotifOk = false;
      });
      return;
    }
    if (_emailsSelecionadosNotif.isEmpty) {
      setState(() {
        _feedbackNotif = 'Marque pelo menos um email.';
        _feedbackNotifOk = false;
      });
      return;
    }
    if (titulo.isEmpty || msg.isEmpty) {
      setState(() {
        _feedbackNotif = 'Preencha título e mensagem.';
        _feedbackNotifOk = false;
      });
      return;
    }

    setState(() {
      _enviandoNotif = true;
      _feedbackNotif = '';
    });

    final corpo = '<h2 style="margin:0 0 16px;color:#1A3C34;">$titulo</h2>'
        '<p style="font-size:15px;color:#374151;line-height:1.7;">$msg</p>';

    await _criarNotificacao(
        email: _emailNotif!, titulo: titulo, mensagem: msg, tipo: 'aviso');
    await _enviarPushOneSignalAdmin(
        email: _emailNotif!, titulo: titulo, mensagem: msg);

    final todosEmails = _emailsSelecionadosNotif.toSet().toList();
    for (final em in todosEmails) {
      await _enviarEmail(para: em, assunto: titulo, corpo: corpo);
      if (em != _emailNotif) {
        await _criarNotificacao(
            email: em, titulo: titulo, mensagem: msg, tipo: 'aviso');
        await _enviarPushOneSignalAdmin(
            email: em, titulo: titulo, mensagem: msg);
      }
    }

    _tituloCtrl.clear();
    _msgCtrl.clear();
    setState(() {
      _enviandoNotif = false;
      _feedbackNotifOk = true;
      _feedbackNotif = 'Enviado para ${todosEmails.length} destinatário(s)!';
      _emailNotif = null;
      _emailsAdicionaisNotif = [];
      _emailsSelecionadosNotif = [];
    });
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), duration: const Duration(seconds: 3)));
  }

  // ── InputDecoration — igual ao EnviarRelatorioEmailWidget ────────────────────
  InputDecoration _inputDeco(String hint, bool isDark) {
    final border = isDark ? Colors.white12 : Colors.black12;
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
          fontSize: 13, color: isDark ? Colors.white54 : Colors.black54),
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

  // ── BUILD ────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    const isDark = true;

    return SafeArea(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: widget.width ?? double.infinity,
          color: const Color(0xFF0B0F17),
          child: Column(children: [
            // ── Header ──────────────────────────────────────────────────────
            Container(
              decoration: const BoxDecoration(color: _kVerde),
              padding: const EdgeInsets.fromLTRB(20, 20, 12, 0),
              child: Column(children: [
                Row(children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.admin_panel_settings_rounded,
                        color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Painel Administrativo',
                          style: GoogleFonts.interTight(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.3)),
                      const SizedBox(height: 2),
                      const Text('HPS Refrigeração',
                          style:
                              TextStyle(color: Colors.white60, fontSize: 11)),
                    ],
                  )),
                ]),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(children: [
                    _navTab(0, Icons.pending_actions_rounded, 'Solicitações'),
                    _navTab(1, Icons.people_rounded, 'Usuários'),
                    _navTab(2, Icons.notifications_rounded, 'Notificação'),
                    _navTab(3, Icons.history_rounded, 'Histórico'),
                  ]),
                ),
              ]),
            ),
            Expanded(
              child: IndexedStack(
                index: _paginaAtual,
                children: [
                  _pagSolicitacoes(theme, isDark),
                  _pagUsuarios(theme, isDark),
                  _pagNotificacao(theme, isDark),
                  _pagHistorico(theme, isDark),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _navTab(int idx, IconData icon, String label) {
    final sel = _paginaAtual == idx;
    return GestureDetector(
      onTap: () => setState(() => _paginaAtual = idx),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(right: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: sel ? Colors.white.withOpacity(0.18) : Colors.transparent,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
          ),
          border: sel
              ? const Border(
                  bottom: BorderSide(color: Colors.white, width: 2.5))
              : null,
        ),
        child: Row(children: [
          Icon(icon, color: sel ? Colors.white : Colors.white38, size: 16),
          const SizedBox(width: 6),
          Text(label,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: sel ? FontWeight.w700 : FontWeight.w400,
                  color: sel ? Colors.white : Colors.white38)),
        ]),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // PAG 1 — SOLICITAÇÕES
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _pagSolicitacoes(FlutterFlowTheme theme, bool isDark) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
          16, 16, 16, 16 + MediaQuery.of(context).padding.bottom),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        if (_feedbackSol.isNotEmpty)
          _banner(
              _feedbackOk ? _kGreen : _kRed,
              _feedbackOk ? Icons.check_circle_rounded : Icons.error_rounded,
              _feedbackSol,
              theme),
        _titulo('PENDENTES', Icons.pending_actions_rounded, theme),
        const SizedBox(height: 10),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('SOLICITACOES_SENHA')
              .where('status', isEqualTo: 'pendente')
              .snapshots(),
          builder: (ctx, snap) {
            if (snap.connectionState == ConnectionState.waiting)
              return _loading();
            final docs = snap.data?.docs ?? [];
            final sorted = List.from(docs)
              ..sort((a, b) {
                final ta =
                    ((a.data() as Map)['criadoEm'] as Timestamp?)?.toDate() ??
                        DateTime(0);
                final tb =
                    ((b.data() as Map)['criadoEm'] as Timestamp?)?.toDate() ??
                        DateTime(0);
                return tb.compareTo(ta);
              });
            if (sorted.isEmpty)
              return _vazio(
                  'Nenhuma solicitação pendente', Icons.inbox_rounded, theme);

            return Column(
                children: sorted.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final isSelected = _docIdSelecionado == doc.id;
              final nome = data['nome']?.toString() ?? '-';
              final email = data['e-mail']?.toString() ?? '-';
              final motivo = data['motivo']?.toString() ?? '-';
              final detalhe = data['detalhe']?.toString() ?? '';
              final ts = data['criadoEm'] as Timestamp?;
              final dataStr = ts != null ? _fmtData(ts.toDate()) : '';

              return Column(children: [
                GestureDetector(
                  onTap: () => setState(() {
                    if (isSelected) {
                      _docIdSelecionado = null;
                      _solSelecionada = null;
                    } else {
                      _docIdSelecionado = doc.id;
                      _solSelecionada = data;
                      _feedbackSol = '';
                    }
                  }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? _kVerde.withOpacity(isDark ? 0.18 : 0.07)
                          : theme.secondaryBackground,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: isSelected ? _kVerde : theme.alternate,
                          width: isSelected ? 1.8 : 1),
                    ),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                    color: _kOrange.withOpacity(0.12),
                                    shape: BoxShape.circle),
                                child: const Icon(Icons.person_rounded,
                                    color: _kOrange, size: 20)),
                            const SizedBox(width: 12),
                            Expanded(
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                  Text(nome,
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: theme.primaryText)),
                                  Text(email,
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: theme.secondaryText)),
                                ])),
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  _chip(motivo, _kOrange),
                                  if (dataStr.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(dataStr,
                                        style: TextStyle(
                                            fontSize: 10,
                                            color: theme.secondaryText
                                                .withOpacity(0.5))),
                                  ],
                                ]),
                          ]),
                          if (detalhe.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 7),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.white.withOpacity(0.05)
                                    : Colors.black.withOpacity(0.03),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(detalhe,
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: theme.secondaryText,
                                      fontStyle: FontStyle.italic)),
                            ),
                          ],
                        ]),
                  ),
                ),
                if (isSelected) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _kVerde.withOpacity(isDark ? 0.1 : 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: _kVerde.withOpacity(0.25), width: 1.5),
                    ),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text('Definir nova senha para $nome',
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: _kVerde)),
                          const SizedBox(height: 12),
                          _campoSenha(
                              ctrl: _novaSenhaCtrl,
                              hint: 'Nova senha',
                              obscure: !_showNova,
                              toggle: () =>
                                  setState(() => _showNova = !_showNova),
                              isDark: isDark,
                              theme: theme),
                          const SizedBox(height: 8),
                          _campoSenha(
                              ctrl: _confirmarCtrl,
                              hint: 'Confirmar nova senha',
                              obscure: !_showConfirmar,
                              toggle: () => setState(
                                  () => _showConfirmar = !_showConfirmar),
                              isDark: isDark,
                              theme: theme),
                          const SizedBox(height: 14),
                          Row(children: [
                            Expanded(
                                child: _btnAcao(
                                    label: 'Redefinir e Notificar',
                                    icon: Icons.lock_reset_rounded,
                                    cor: _kVerde,
                                    carregando: _processando,
                                    onTap: _resolverSolicitacao)),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () => _rejeitarSolicitacao(doc.id),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 13),
                                decoration: BoxDecoration(
                                    color: _kRed.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                        color: _kRed.withOpacity(0.3))),
                                child: const Icon(Icons.close_rounded,
                                    color: _kRed, size: 18),
                              ),
                            ),
                          ]),
                        ]),
                  ),
                ],
                const SizedBox(height: 10),
              ]);
            }).toList());
          },
        ),
      ]),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // PAG 2 — USUÁRIOS
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _pagUsuarios(FlutterFlowTheme theme, bool isDark) {
    final primaryTextColor = isDark ? Colors.white : Colors.black87;
    final filtrados = _todosUsuarios.where((u) {
      final q = _buscaUsuario.toLowerCase();
      return q.isEmpty ||
          (u['nome'] as String).toLowerCase().contains(q) ||
          (u['email'] as String).toLowerCase().contains(q);
    }).toList();

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
          16, 16, 16, 16 + MediaQuery.of(context).padding.bottom),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        // Busca
        Container(
          decoration: BoxDecoration(
              color: theme.secondaryBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.alternate)),
          child: TextField(
            onChanged: (v) => setState(() => _buscaUsuario = v),
            style: TextStyle(fontSize: 14, color: theme.primaryText),
            decoration: InputDecoration(
              hintText: 'Buscar por nome ou email...',
              hintStyle: TextStyle(
                  fontSize: 13, color: theme.secondaryText.withOpacity(0.5)),
              prefixIcon: Icon(Icons.search_rounded,
                  color: theme.secondaryText.withOpacity(0.5), size: 20),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            ),
          ),
        ),
        const SizedBox(height: 16),

        _titulo('RESET RÁPIDO', Icons.lock_reset_rounded, theme),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
              color: theme.secondaryBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.alternate)),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            // ── Dropdown — padrão idêntico ao EnviarRelatorioEmailWidget ──
            // Renderiza CircularProgressIndicator enquanto carrega,
            // e DropdownButtonFormField apenas depois.
            // Isso garante que items nunca está vazio quando o widget existe,
            // eliminando o assertion do Flutter definitivamente.
            _loadingUsuarios
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Row(children: [
                      SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: _kVerde)),
                      SizedBox(width: 12),
                      Text('Carregando usuários...',
                          style: TextStyle(fontSize: 13)),
                    ]))
                : DropdownButtonFormField<String>(
                    value: _emailRapido,
                    hint: Text('Selecione o usuário',
                        style: TextStyle(
                            fontSize: 13,
                            color: isDark ? Colors.white54 : Colors.black54)),
                    isExpanded: true,
                    decoration: _inputDeco('Selecione o usuário', isDark),
                    dropdownColor:
                        isDark ? const Color(0xFF252D3A) : Colors.white,
                    style: TextStyle(fontSize: 14, color: primaryTextColor),
                    items: _todosUsuarios.map((u) {
                      final email = u['email']?.toString() ?? '';
                      final nome = u['nome']?.toString() ?? email;
                      return DropdownMenuItem<String>(
                        value: email,
                        child: Text('$nome ($email)',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 13, color: primaryTextColor)),
                      );
                    }).toList(),
                    onChanged: (v) {
                      if (v == null) return;
                      final u = _todosUsuarios
                          .firstWhere((u) => u['email'] == v, orElse: () => {});
                      final lista =
                          _montarListaEmails(v, u['emailteste'] as List? ?? []);
                      setState(() {
                        _emailRapido = v;
                        _emailsAdicionaisRapido = lista;
                        _emailsSelecionadosRapido = [v];
                      });
                    },
                  ),

            if (_emailRapido != null) ...[
              const SizedBox(height: 12),
              Row(children: [
                Text('E-mails para receber a notificação',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: theme.primaryText.withOpacity(0.75))),
                const SizedBox(width: 6),
                if (_emailsSelecionadosRapido.isNotEmpty)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                        color: _kBlue, borderRadius: BorderRadius.circular(10)),
                    child: Text('+${_emailsSelecionadosRapido.length}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600)),
                  ),
              ]),
              const SizedBox(height: 3),
              Text(
                  'Push/notif: email principal  |  Email Brevo: marcados abaixo',
                  style: TextStyle(
                      fontSize: 10,
                      color: theme.secondaryText.withOpacity(0.45),
                      fontStyle: FontStyle.italic)),
              const SizedBox(height: 8),
              _listaChecks(_emailsAdicionaisRapido, _emailsSelecionadosRapido,
                  _kBlue, theme, isDark),
            ],

            const SizedBox(height: 10),
            _campoSenha(
                ctrl: _senhaRapidaCtrl,
                hint: 'Nova senha',
                obscure: !_showRapida,
                toggle: () => setState(() => _showRapida = !_showRapida),
                isDark: isDark,
                theme: theme),
            const SizedBox(height: 8),
            _campoSenha(
                ctrl: _confirmarRapidaCtrl,
                hint: 'Confirmar nova senha',
                obscure: !_showConfirmarRapida,
                toggle: () => setState(
                    () => _showConfirmarRapida = !_showConfirmarRapida),
                isDark: isDark,
                theme: theme),
            const SizedBox(height: 12),
            _btnAcao(
                label: 'Redefinir Senha',
                icon: Icons.lock_reset_rounded,
                cor: _kBlue,
                carregando: _processando,
                onTap: _resetRapido),
          ]),
        ),

        const SizedBox(height: 24),
        _titulo('TODOS OS USUÁRIOS (${filtrados.length})', Icons.people_rounded,
            theme),
        const SizedBox(height: 10),

        _loadingUsuarios
            ? _loading()
            : filtrados.isEmpty
                ? _vazio('Nenhum usuário encontrado', Icons.person_off_rounded,
                    theme)
                : Column(
                    children: filtrados.map((u) {
                    final ativo = u['ativo'] as bool;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.secondaryBackground,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: ativo
                                ? theme.alternate
                                : _kRed.withOpacity(0.3)),
                      ),
                      child: Row(children: [
                        Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                                color: ativo
                                    ? _kVerde.withOpacity(0.1)
                                    : _kRed.withOpacity(0.1),
                                shape: BoxShape.circle),
                            child: Icon(Icons.person_rounded,
                                color: ativo ? _kVerde : _kRed, size: 20)),
                        const SizedBox(width: 12),
                        Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                              Text(u['nome']?.toString() ?? '',
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: theme.primaryText)),
                              Text(u['email']?.toString() ?? '',
                                  style: TextStyle(
                                      fontSize: 11, color: theme.secondaryText),
                                  overflow: TextOverflow.ellipsis),
                            ])),
                        GestureDetector(
                          onTap: () => _toggleAtivo(u['id'].toString(), ativo),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                                color: ativo
                                    ? _kGreen.withOpacity(0.1)
                                    : _kRed.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: ativo
                                        ? _kGreen.withOpacity(0.4)
                                        : _kRed.withOpacity(0.4))),
                            child: Text(ativo ? 'Ativo' : 'Inativo',
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: ativo ? _kGreen : _kRed)),
                          ),
                        ),
                      ]),
                    );
                  }).toList()),
      ]),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // PAG 3 — NOTIFICAÇÃO MANUAL
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _pagNotificacao(FlutterFlowTheme theme, bool isDark) {
    final primaryTextColor = isDark ? Colors.white : Colors.black87;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
          16, 16, 16, 16 + MediaQuery.of(context).padding.bottom),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        if (_feedbackNotif.isNotEmpty)
          _banner(
              _feedbackNotifOk ? _kGreen : _kRed,
              _feedbackNotifOk
                  ? Icons.check_circle_rounded
                  : Icons.error_rounded,
              _feedbackNotif,
              theme),
        _titulo('ENVIAR NOTIFICAÇÃO', Icons.notifications_rounded, theme),
        const SizedBox(height: 6),
        Text('Envia notificação no app + OneSignal + e-mail via Brevo.',
            style: TextStyle(
                fontSize: 12,
                color: theme.secondaryText.withOpacity(0.7),
                height: 1.5)),
        const SizedBox(height: 16),

        Text('Destinatário',
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: theme.primaryText.withOpacity(0.75))),
        const SizedBox(height: 6),

        // ── Dropdown — padrão idêntico ao EnviarRelatorioEmailWidget ──────
        _loadingUsuarios
            ? const Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Row(children: [
                  SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: _kVerde)),
                  SizedBox(width: 12),
                  Text('Carregando usuários...',
                      style: TextStyle(fontSize: 13)),
                ]))
            : DropdownButtonFormField<String>(
                value: _emailNotif,
                hint: Text('Selecione o usuário',
                    style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white54 : Colors.black54)),
                isExpanded: true,
                decoration: _inputDeco('Selecione o usuário', isDark),
                dropdownColor: isDark ? const Color(0xFF252D3A) : Colors.white,
                style: TextStyle(fontSize: 14, color: primaryTextColor),
                items: _todosUsuarios.map((u) {
                  final email = u['email']?.toString() ?? '';
                  final nome = u['nome']?.toString() ?? email;
                  return DropdownMenuItem<String>(
                    value: email,
                    child: Text('$nome ($email)',
                        overflow: TextOverflow.ellipsis,
                        style:
                            TextStyle(fontSize: 13, color: primaryTextColor)),
                  );
                }).toList(),
                onChanged: (v) {
                  if (v == null) return;
                  final u = _todosUsuarios.firstWhere((u) => u['email'] == v,
                      orElse: () => {});
                  final lista =
                      _montarListaEmails(v, u['emailteste'] as List? ?? []);
                  setState(() {
                    _emailNotif = v;
                    _emailsAdicionaisNotif = lista;
                    _emailsSelecionadosNotif = [v];
                  });
                },
              ),

        if (_emailNotif != null) ...[
          const SizedBox(height: 12),
          Row(children: [
            Text('Destinatários (Para)',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: theme.primaryText.withOpacity(0.75))),
            const SizedBox(width: 8),
            if (_emailsSelecionadosNotif.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                    color: _kVerde, borderRadius: BorderRadius.circular(10)),
                child: Text('+${_emailsSelecionadosNotif.length}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600)),
              ),
          ]),
          const SizedBox(height: 4),
          Text('Marque os e-mails que vão receber a notificação',
              style: TextStyle(
                  fontSize: 11, color: theme.secondaryText.withOpacity(0.5))),
          const SizedBox(height: 8),
          _listaChecks(_emailsAdicionaisNotif, _emailsSelecionadosNotif,
              _kVerde, theme, isDark),
        ],

        const SizedBox(height: 14),
        Text('Título',
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: theme.primaryText.withOpacity(0.75))),
        const SizedBox(height: 6),
        _campoTexto(
            ctrl: _tituloCtrl,
            hint: 'Ex: Manutenção agendada',
            theme: theme,
            isDark: isDark),
        const SizedBox(height: 12),
        Text('Mensagem',
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: theme.primaryText.withOpacity(0.75))),
        const SizedBox(height: 6),
        _campoTexto(
            ctrl: _msgCtrl,
            hint: 'Digite a mensagem completa...',
            theme: theme,
            isDark: isDark,
            maxLines: 5),
        const SizedBox(height: 20),
        _btnAcao(
            label: 'Enviar Notificação e E-mail',
            icon: Icons.send_rounded,
            cor: _kPrimary,
            carregando: _enviandoNotif,
            onTap: _enviarNotificacao),
        const SizedBox(height: 28),
        _titulo('ÚLTIMAS NOTIFICAÇÕES', Icons.history_rounded, theme),
        const SizedBox(height: 10),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('NOTIFICACAO')
              .orderBy('data', descending: true)
              .limit(20)
              .snapshots(),
          builder: (ctx, snap) {
            final docs = snap.data?.docs ?? [];
            if (docs.isEmpty)
              return _vazio('Nenhuma notificação ainda',
                  Icons.notifications_off_rounded, theme);
            return Column(
                children: docs.map((doc) {
              final d = doc.data() as Map<String, dynamic>;
              final visto = d['visto'] == true;
              final ts = d['data'] as Timestamp?;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: theme.secondaryBackground,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: theme.alternate)),
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(top: 5, right: 10),
                          decoration: BoxDecoration(
                              color: visto ? theme.alternate : _kPrimary,
                              shape: BoxShape.circle)),
                      Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            Text(d['título']?.toString() ?? '',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: theme.primaryText)),
                            const SizedBox(height: 2),
                            Text(d['e-mail']?.toString() ?? '',
                                style: const TextStyle(
                                    fontSize: 11, color: _kPrimary)),
                            const SizedBox(height: 3),
                            Text(d['mensagem']?.toString() ?? '',
                                style: TextStyle(
                                    fontSize: 12, color: theme.secondaryText),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis),
                          ])),
                      if (ts != null)
                        Text(_fmtData(ts.toDate()),
                            style: TextStyle(
                                fontSize: 10,
                                color: theme.secondaryText.withOpacity(0.45))),
                    ]),
              );
            }).toList());
          },
        ),
      ]),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // PAG 4 — HISTÓRICO
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _pagHistorico(FlutterFlowTheme theme, bool isDark) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
          16, 16, 16, 16 + MediaQuery.of(context).padding.bottom),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        _titulo('HISTÓRICO DE SOLICITAÇÕES', Icons.history_rounded, theme),
        const SizedBox(height: 10),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('SOLICITACOES_SENHA')
              .snapshots(),
          builder: (ctx, snap) {
            final docs = snap.data?.docs ?? [];
            final sorted = List.from(docs)
              ..sort((a, b) {
                final ta =
                    ((a.data() as Map)['criadoEm'] as Timestamp?)?.toDate() ??
                        DateTime(0);
                final tb =
                    ((b.data() as Map)['criadoEm'] as Timestamp?)?.toDate() ??
                        DateTime(0);
                return tb.compareTo(ta);
              });
            if (sorted.isEmpty)
              return _vazio(
                  'Nenhum registro ainda', Icons.history_rounded, theme);

            return Column(
                children: sorted.map((doc) {
              final d = doc.data() as Map<String, dynamic>;
              final status = d['status']?.toString() ?? 'pendente';
              final nome = d['nome']?.toString() ?? '-';
              final email = d['e-mail']?.toString() ?? '-';
              final motivo = d['motivo']?.toString() ?? '-';
              final ts = d['criadoEm'] as Timestamp?;
              final tsRes = d['resolvidoEm'] as Timestamp?;

              Color statusCor;
              IconData statusIcon;
              String statusLabel;
              switch (status) {
                case 'resolvido':
                  statusCor = _kGreen;
                  statusIcon = Icons.check_circle_rounded;
                  statusLabel = 'Resolvido';
                  break;
                case 'rejeitado':
                  statusCor = _kRed;
                  statusIcon = Icons.cancel_rounded;
                  statusLabel = 'Rejeitado';
                  break;
                default:
                  statusCor = _kOrange;
                  statusIcon = Icons.pending_rounded;
                  statusLabel = 'Pendente';
              }

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                    color: theme.secondaryBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusCor.withOpacity(0.3))),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Icon(statusIcon, color: statusCor, size: 16),
                        const SizedBox(width: 6),
                        _chip(statusLabel, statusCor),
                        const Spacer(),
                        if (ts != null)
                          Text(_fmtData(ts.toDate()),
                              style: TextStyle(
                                  fontSize: 10,
                                  color: theme.secondaryText.withOpacity(0.5))),
                      ]),
                      const SizedBox(height: 8),
                      Text(nome,
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: theme.primaryText)),
                      Text(email,
                          style: TextStyle(
                              fontSize: 11, color: theme.secondaryText)),
                      const SizedBox(height: 6),
                      Text('Motivo: $motivo',
                          style: TextStyle(
                              fontSize: 12,
                              color: theme.secondaryText.withOpacity(0.7))),
                      if (tsRes != null)
                        Text('Resolvido em: ${_fmtData(tsRes.toDate())}',
                            style: TextStyle(
                                fontSize: 11,
                                color: statusCor.withOpacity(0.7))),
                    ]),
              );
            }).toList());
          },
        ),
      ]),
    );
  }

  // ── Helpers UI ───────────────────────────────────────────────────────────────
  String _fmtData(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year} '
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  Widget _titulo(String text, IconData icon, FlutterFlowTheme theme) =>
      Row(children: [
        Icon(icon, size: 14, color: _kVerde),
        const SizedBox(width: 7),
        Text(text,
            style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: _kVerde,
                letterSpacing: 0.5)),
        const SizedBox(width: 8),
        Expanded(child: Divider(color: _kVerde.withOpacity(0.2), height: 1)),
      ]);

  Widget _chip(String label, Color cor) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
            color: cor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: cor.withOpacity(0.3))),
        child: Text(label,
            style: TextStyle(
                fontSize: 10, color: cor, fontWeight: FontWeight.w600)),
      );

  Widget _banner(
          Color cor, IconData icon, String msg, FlutterFlowTheme theme) =>
      Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: cor.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: cor.withOpacity(0.3))),
        child: Row(children: [
          Icon(icon, color: cor, size: 18),
          const SizedBox(width: 10),
          Expanded(
              child: Text(msg,
                  style: TextStyle(
                      color: cor, fontSize: 13, fontWeight: FontWeight.w500))),
        ]),
      );

  Widget _loading() => const Padding(
      padding: EdgeInsets.all(24),
      child: Center(
          child: CircularProgressIndicator(color: _kVerde, strokeWidth: 2)));

  Widget _vazio(String msg, IconData icon, FlutterFlowTheme theme) => Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
            color: theme.secondaryBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.alternate)),
        child: Column(children: [
          Icon(icon, size: 38, color: theme.secondaryText.withOpacity(0.3)),
          const SizedBox(height: 10),
          Text(msg, style: TextStyle(color: theme.secondaryText, fontSize: 13)),
        ]),
      );

  Widget _btnAcao({
    required String label,
    required IconData icon,
    required Color cor,
    required bool carregando,
    required VoidCallback onTap,
  }) =>
      GestureDetector(
        onTap: carregando ? null : onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            color: carregando ? cor.withOpacity(0.35) : cor,
            borderRadius: BorderRadius.circular(10),
            boxShadow: carregando
                ? []
                : [
                    BoxShadow(
                        color: cor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3))
                  ],
          ),
          child: Center(
            child: carregando
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2.5))
                : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(icon, color: Colors.white, size: 16),
                    const SizedBox(width: 8),
                    Text(label,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w700)),
                  ]),
          ),
        ),
      );

  Widget _listaChecks(List<String> lista, List<String> selecionados, Color cor,
      FlutterFlowTheme theme, bool isDark) {
    if (lista.isEmpty)
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: isDark ? const Color(0xFF252D3A) : const Color(0xFFF4F6F8),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: theme.alternate)),
        child: Text('Nenhum email adicional cadastrado',
            style: TextStyle(fontSize: 13, color: theme.secondaryText)),
      );

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF252D3A) : const Color(0xFFF4F6F8),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.alternate),
      ),
      child: Column(
        children: List.generate(lista.length, (idx) {
          final email = lista[idx];
          final sel = selecionados.contains(email);
          final isFirst = idx == 0;
          final isLast = idx == lista.length - 1;
          return Column(children: [
            if (!isFirst) Divider(height: 1, color: theme.alternate),
            InkWell(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(isFirst ? 10 : 0),
                topRight: Radius.circular(isFirst ? 10 : 0),
                bottomLeft: Radius.circular(isLast ? 10 : 0),
                bottomRight: Radius.circular(isLast ? 10 : 0),
              ),
              onTap: () => setState(() {
                if (sel)
                  selecionados.remove(email);
                else
                  selecionados.add(email);
              }),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                child: Row(children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: sel ? cor : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                          color: sel
                              ? cor
                              : (isDark
                                  ? Colors.white30
                                  : Colors.grey.shade400),
                          width: 2),
                    ),
                    child: sel
                        ? const Icon(Icons.check, color: Colors.white, size: 14)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                      child: Text(email,
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight:
                                  sel ? FontWeight.w600 : FontWeight.normal,
                              color: sel ? cor : theme.primaryText))),
                ]),
              ),
            ),
          ]);
        }),
      ),
    );
  }

  Widget _campoSenha({
    required TextEditingController ctrl,
    required String hint,
    required bool obscure,
    required VoidCallback toggle,
    required bool isDark,
    required FlutterFlowTheme theme,
  }) =>
      Container(
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withOpacity(0.05)
              : Colors.black.withOpacity(0.03),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: theme.alternate),
        ),
        child: TextField(
          controller: ctrl,
          obscureText: obscure,
          style: TextStyle(fontSize: 13, color: theme.primaryText),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
                fontSize: 12, color: theme.secondaryText.withOpacity(0.5)),
            prefixIcon: Icon(Icons.lock_outline_rounded,
                color: _kVerde.withOpacity(0.5), size: 17),
            suffixIcon: IconButton(
              icon: Icon(
                  obscure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: theme.secondaryText.withOpacity(0.4),
                  size: 17),
              onPressed: toggle,
            ),
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
      );

  Widget _campoTexto({
    required TextEditingController ctrl,
    required String hint,
    required FlutterFlowTheme theme,
    required bool isDark,
    int maxLines = 1,
  }) =>
      Container(
        decoration: BoxDecoration(
            color: theme.secondaryBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.alternate)),
        child: TextField(
          controller: ctrl,
          maxLines: maxLines,
          style: TextStyle(fontSize: 14, color: theme.primaryText),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
                fontSize: 13, color: theme.secondaryText.withOpacity(0.5)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            border: InputBorder.none,
          ),
        ),
      );
}
