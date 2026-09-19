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

import 'index.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_ai/firebase_ai.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  CONSTANTES
// ─────────────────────────────────────────────────────────────────────────────
const _kRemetenteEmail = 'equipe@hpsrefri.com.br';
const _kRemetenteNome = 'HPS Refrigeração';
const _kBannerUrl =
    'https://firebasestorage.googleapis.com/v0/b/h-p-s-modificado-emdcp0.appspot.com/o/Gemini_Generated_Image_2xpdsd2xpdsd2xpd%20(1).png?alt=media&token=be3e052e-a0b8-4e8c-8151-b9365b507ed5';
const _kVerde = Color(0xFF1A3C34);
const _kOsAppId = '7b01186f-cf76-4b5d-8354-87d83737d40c';
const _kOsApiKey = 'ZTdlNjIwZWItMjEyMC00M2RhLWJlZmYtMzc2NTBmNzNmMDdj';
const _kOsChannel = '577bba44-d1bf-4ac9-9d11-20d89e09a61a';
const _kHpsEmail = 'hpsrefri@gmail.com';

// ─────────────────────────────────────────────────────────────────────────────
//  Firestore helpers
// ─────────────────────────────────────────────────────────────────────────────
Future<String> _getApiBrevo() async {
  try {
    final snap = await FirebaseFirestore.instance
        .collection('USUARIOS')
        .where('email', isEqualTo: _kHpsEmail)
        .limit(1)
        .get();
    if (snap.docs.isNotEmpty) {
      return (snap.docs.first.data()['apibrevo'] ?? '').toString().trim();
    }
  } catch (e) {
    debugPrint('apibrevo erro: $e');
  }
  return '';
}

// ─────────────────────────────────────────────────────────────────────────────
//  IA — padrão IDÊNTICO ao FirebaseAiFinanceWidget que funciona no projeto
//  Usa FirebaseAI.googleAI() + startChat() + sendMessage() — gemini-2.5-flash
// ─────────────────────────────────────────────────────────────────────────────

// Instâncias globais reutilizáveis (mesmo padrão do FinanceWidget)
GenerativeModel? _emailIAModel;
ChatSession? _emailIAChat;

/// Inicializa o modelo uma vez e reutiliza — igual ao _initAI() do FinanceWidget
void _inicializarEmailIA() {
  try {
    _emailIAModel = FirebaseAI.googleAI().generativeModel(
      model: 'gemini-2.5-flash',
      systemInstruction: Content.system(
        'Você é um assistente de redação profissional da HPS Refrigeração, '
        'empresa especializada em serviços de refrigeração e ar-condicionado no Brasil. '
        'Responda sempre em português brasileiro. '
        'Quando pedido para melhorar ou corrigir textos, retorne APENAS o texto '
        'corrigido/melhorado, sem explicações, sem prefixos, sem aspas extras.',
      ),
    );
    _emailIAChat = _emailIAModel!.startChat();
  } catch (e) {
    debugPrint('[EmailIA] init erro: $e');
  }
}

/// Envia prompt e retorna resposta — mesmo padrão do _send() do FinanceWidget
Future<String> _chamarGeminiSDK(String prompt) async {
  // Inicializa se ainda não foi feito
  if (_emailIAModel == null || _emailIAChat == null) {
    _inicializarEmailIA();
  }

  if (_emailIAChat == null) {
    throw Exception(
        'Não foi possível inicializar a IA. Verifique a configuração do Firebase AI.');
  }

  final response = await _emailIAChat!
      .sendMessage(Content.text(prompt))
      .timeout(const Duration(seconds: 30));

  final texto = response.text?.trim() ?? '';
  if (texto.isEmpty) throw Exception('IA retornou resposta vazia.');
  return texto;
}

// ─────────────────────────────────────────────────────────────────────────────
//  Envio Brevo
// ─────────────────────────────────────────────────────────────────────────────
Future<void> _enviarBrevo({
  required String apiKey,
  required List<String> para,
  required List<String> cc,
  required String assunto,
  required String corpo,
  required String nomeRemetente,
}) async {
  if (apiKey.isEmpty) throw Exception('apibrevo não configurado');

  final html = '''
<!DOCTYPE html>
<html lang="pt-BR">
<head><meta charset="UTF-8"><title>$assunto</title></head>
<body style="margin:0;padding:0;background:#f4f6f8;font-family:Arial,sans-serif;">
  <table width="100%" cellpadding="0" cellspacing="0" border="0"
         style="background:#f4f6f8;padding:20px 0;">
    <tr><td align="center">
      <table width="600" cellpadding="0" cellspacing="0" border="0"
             style="background:#fff;border-radius:12px;overflow:hidden;max-width:1400px;width:100%;">
        <tr>
          <td style="padding:0;line-height:0;">
            <img src="$_kBannerUrl" width="1400"
                 style="display:block;width:100%;height:auto;border:0;"/>
          </td>
        </tr>
        <tr>
          <td style="background:#1A3C34;padding:10px 24px;">
            <span style="color:#fff;font-size:13px;font-weight:bold;">
              $nomeRemetente
            </span>
          </td>
        </tr>
        <tr>
          <td style="padding:28px;color:#333;font-size:15px;line-height:1.8;">
            ${corpo.replaceAll('\n', '<br>')}
          </td>
        </tr>
        <tr>
          <td style="background:#f1f5f9;padding:14px 28px;text-align:center;
                     font-size:12px;color:#94a3b8;border-top:1px solid #e2e8f0;">
            &copy; 2026 HPS Refrigeração &middot; www.hpsrefri.com.br
          </td>
        </tr>
      </table>
    </td></tr>
  </table>
</body>
</html>''';

  final payload = <String, dynamic>{
    'sender': {'name': _kRemetenteNome, 'email': _kRemetenteEmail},
    'replyTo': {'name': _kRemetenteNome, 'email': _kRemetenteEmail},
    'to': para.map((e) => {'email': e.trim()}).toList(),
    'subject': assunto,
    'htmlContent': html,
  };
  if (cc.isNotEmpty) {
    payload['cc'] = cc.map((e) => {'email': e.trim()}).toList();
  }

  final resp = await http.post(
    Uri.parse('https://api.brevo.com/v3/smtp/email'),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'api-key': apiKey,
    },
    body: jsonEncode(payload),
  );
  if (resp.statusCode != 200 && resp.statusCode != 201) {
    throw Exception('Brevo ${resp.statusCode}: ${resp.body}');
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Push OneSignal
// ─────────────────────────────────────────────────────────────────────────────
Future<void> _pushHps(String assunto) async {
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
          {
            'field': 'tag',
            'key': 'Email',
            'relation': '=',
            'value': _kHpsEmail
          },
        ],
        'android_channel_id': _kOsChannel,
        'headings': {'en': '📧 E-mail Enviado'},
        'contents': {'en': 'Assunto: $assunto'},
        'priority': 10,
      }),
    );
  } catch (e) {
    debugPrint('OneSignal: $e');
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Helpers locais
// ─────────────────────────────────────────────────────────────────────────────
bool _emailValido(String e) =>
    RegExp(r'^[\w\.\+\-]+@[\w\-]+\.[a-zA-Z]{2,}$').hasMatch(e.trim());

List<String> _splitEmails(String texto) => texto
    .split(RegExp(r'[,;\n]+'))
    .map((e) => e.trim())
    .where((e) => e.isNotEmpty)
    .toList();

/// ─────────────────────────────────────────────────────────────────────────────
/// WIDGET
/// ─────────────────────────────────────────────────────────────────────────────
class EnviarEmailLivreWidget extends StatefulWidget {
  const EnviarEmailLivreWidget({
    super.key,
    this.width,
    this.height,
    this.onCancelar,
    this.emailParaInicial,
    this.assuntoInicial,
  });

  final double? width;
  final double? height;
  final Future<dynamic> Function()? onCancelar;
  final String? emailParaInicial;
  final String? assuntoInicial;

  @override
  State<EnviarEmailLivreWidget> createState() => _EnviarEmailLivreWidgetState();
}

class _EnviarEmailLivreWidgetState extends State<EnviarEmailLivreWidget>
    with TickerProviderStateMixin {
  // ── Controllers ──────────────────────────────────────────────────
  final _cCc = TextEditingController();
  final _cAssunto = TextEditingController();
  final _cNome = TextEditingController();
  final _cCorpo = TextEditingController();

  // ── Usuários do Firestore ─────────────────────────────────────────
  List<Map<String, dynamic>> _usuarios = [];
  bool _loadingUsuarios = true;

  // ── Seleção de destinatários (padrão original: dropdown + checkboxes) ────
  String? _emailPrincipal; // email do usuário selecionado no dropdown
  List<String> _emailsDisponiveis =
      []; // emails disponíveis (principal + emailteste)
  List<String> _emailsSelecionados = []; // emails marcados nos checkboxes

  // ── Estado IA ────────────────────────────────────────────────────
  bool _iaAssuntoLoad = false;
  bool _iaCorpoLoad = false;
  String? _sugestaoAssunto;
  String? _sugestaoCorpo;
  String? _assuntoAntes;
  String? _corpoAntes;

  // ── Estado envio ─────────────────────────────────────────────────
  bool _enviando = false;
  bool _enviado = false;
  double _progresso = 0.0;
  String _progressoLabel = '';

  // ── Erros de validação ────────────────────────────────────────────
  String? _erroPara;
  String? _erroAssunto;
  String? _erroCorpo;

  // ── Animations ───────────────────────────────────────────────────
  late final AnimationController _successCtrl;
  late final Animation<double> _successAnim;

  // ─────────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _successCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _successAnim =
        CurvedAnimation(parent: _successCtrl, curve: Curves.elasticOut);

    _cNome.text = _kRemetenteNome;
    if (widget.assuntoInicial != null) {
      _cAssunto.text = widget.assuntoInicial!;
    }
    _carregarUsuarios();
  }

  @override
  void dispose() {
    _cCc.dispose();
    _cAssunto.dispose();
    _cNome.dispose();
    _cCorpo.dispose();
    _successCtrl.dispose();
    super.dispose();
  }

  // ── Carrega usuários ──────────────────────────────────────────────
  Future<void> _carregarUsuarios() async {
    try {
      final snap =
          await FirebaseFirestore.instance.collection('USUARIOS').get();
      final lista = <Map<String, dynamic>>[];
      for (final doc in snap.docs) {
        final d = doc.data();
        final email = (d['email'] ?? '').toString().trim();
        if (email.isEmpty) continue;
        final nome = (d['display_name'] ?? '').toString().trim();

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
          'email': email,
          'nome': nome.isNotEmpty ? nome : email,
          'extras': extras,
        });
      }
      lista
          .sort((a, b) => (a['nome'] as String).compareTo(b['nome'] as String));
      if (mounted) {
        setState(() {
          _usuarios = lista;
          _loadingUsuarios = false;
        });
        // se veio emailParaInicial, pré-seleciona o usuário
        if (widget.emailParaInicial != null) {
          _selecionarUsuario(widget.emailParaInicial);
        }
      }
    } catch (_) {
      if (mounted) setState(() => _loadingUsuarios = false);
    }
  }

  // ── Seleciona usuário no dropdown → monta lista de emails disponíveis ─────
  void _selecionarUsuario(String? email) {
    if (email == null) return;
    final u = _usuarios.firstWhere((u) => u['email'] == email,
        orElse: () => <String, dynamic>{});
    if (u.isEmpty) return;

    final extras = List<String>.from(u['extras'] as List<String>? ?? []);
    // garante que o email principal aparece primeiro
    if (!extras.contains(email)) extras.insert(0, email);

    setState(() {
      _emailPrincipal = email;
      _emailsDisponiveis = extras;
      _emailsSelecionados = [];
      _erroPara = null;
    });
  }

  // ── IA ────────────────────────────────────────────────────────────
  Future<void> _melhorarAssunto() async {
    final texto = _cAssunto.text.trim();
    if (texto.isEmpty) {
      _toast('Digite um assunto antes de usar a IA');
      return;
    }
    setState(() {
      _iaAssuntoLoad = true;
      _sugestaoAssunto = null;
      _assuntoAntes = _cAssunto.text;
    });
    try {
      final resultado = await _chamarGeminiSDK('''
Você é assistente de redação profissional da HPS Refrigeração (serviços de refrigeração e ar-condicionado no Brasil).

Melhore o assunto de e-mail abaixo: corrija ortografia, acentuação e gramática. Deixe profissional, claro e objetivo.
Máximo 80 caracteres. Responda APENAS com o texto melhorado, sem aspas, sem prefixo, sem explicações.

Assunto original: $texto''');
      if (mounted) {
        setState(() {
          _sugestaoAssunto = resultado;
          _iaAssuntoLoad = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _iaAssuntoLoad = false);
        _toast('Erro IA: $e');
      }
    }
  }

  Future<void> _melhorarCorpo() async {
    final texto = _cCorpo.text.trim();
    if (texto.isEmpty) {
      _toast('Digite o corpo antes de usar a IA');
      return;
    }
    setState(() {
      _iaCorpoLoad = true;
      _sugestaoCorpo = null;
      _corpoAntes = _cCorpo.text;
    });
    try {
      final resultado = await _chamarGeminiSDK('''
Você é assistente de redação profissional da HPS Refrigeração.

Corrija TODOS os erros de ortografia, acentuação, gramática e pontuação do e-mail abaixo.
Melhore a clareza e o tom profissional. Mantenha parágrafos separados por linha em branco.
Preserve saudação e despedida originais. Responda APENAS com o texto corrigido, sem prefixo, sem explicações.

Texto original:
$texto''');
      if (mounted) {
        setState(() {
          _sugestaoCorpo = resultado;
          _iaCorpoLoad = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _iaCorpoLoad = false);
        _toast('Erro IA: $e');
      }
    }
  }

  Future<void> _gerarCorpo() async {
    final assunto = _cAssunto.text.trim();
    if (assunto.isEmpty) {
      _toast('Preencha o assunto para gerar o corpo com IA');
      return;
    }
    setState(() {
      _iaCorpoLoad = true;
      _sugestaoCorpo = null;
      _corpoAntes = _cCorpo.text;
    });
    try {
      final corpoParcial = _cCorpo.text.trim();
      final resultado = await _chamarGeminiSDK('''
Você é assistente de redação da HPS Refrigeração (empresa de refrigeração e ar-condicionado no Brasil).

Escreva um e-mail profissional e cordial com base no assunto: "$assunto"
${corpoParcial.isNotEmpty ? 'Rascunho inicial do usuário (melhore-o): "$corpoParcial"' : ''}

Retorne APENAS o corpo do e-mail (sem campo assunto), em português brasileiro,
com saudação inicial e despedida profissional. Tom corporativo e adequado para empresa de serviços.''');
      if (mounted) {
        setState(() {
          _sugestaoCorpo = resultado;
          _iaCorpoLoad = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _iaCorpoLoad = false);
        _toast('Erro IA: $e');
      }
    }
  }

  void _aceitarAssunto() {
    if (_sugestaoAssunto == null) return;
    setState(() {
      _cAssunto.text = _sugestaoAssunto!;
      _cAssunto.selection =
          TextSelection.collapsed(offset: _cAssunto.text.length);
      _sugestaoAssunto = null;
    });
  }

  void _rejeitarAssunto() => setState(() => _sugestaoAssunto = null);

  void _desfazerAssunto() {
    if (_assuntoAntes == null) return;
    setState(() {
      _cAssunto.text = _assuntoAntes!;
      _sugestaoAssunto = null;
      _assuntoAntes = null;
    });
  }

  void _aceitarCorpo() {
    if (_sugestaoCorpo == null) return;
    setState(() {
      _cCorpo.text = _sugestaoCorpo!;
      _cCorpo.selection = TextSelection.collapsed(offset: _cCorpo.text.length);
      _sugestaoCorpo = null;
    });
  }

  void _rejeitarCorpo() => setState(() => _sugestaoCorpo = null);

  void _desfazerCorpo() {
    if (_corpoAntes == null) return;
    setState(() {
      _cCorpo.text = _corpoAntes!;
      _sugestaoCorpo = null;
      _corpoAntes = null;
    });
  }

  // ── Validação ─────────────────────────────────────────────────────
  bool _validar() {
    bool ok = true;
    setState(() {
      _erroPara = null;
      _erroAssunto = null;
      _erroCorpo = null;
    });
    if (_emailPrincipal == null) {
      setState(() => _erroPara = 'Selecione um cliente/empresa');
      ok = false;
    } else if (_emailsSelecionados.isEmpty) {
      setState(() => _erroPara = 'Marque pelo menos um e-mail na lista');
      ok = false;
    }
    if (_cAssunto.text.trim().isEmpty) {
      setState(() => _erroAssunto = 'O assunto é obrigatório');
      ok = false;
    }
    if (_cCorpo.text.trim().isEmpty) {
      setState(() => _erroCorpo = 'O corpo do e-mail é obrigatório');
      ok = false;
    }
    return ok;
  }

  // ── Envio ─────────────────────────────────────────────────────────
  Future<void> _enviar() async {
    if (_sugestaoAssunto != null || _sugestaoCorpo != null) {
      _toast('Aceite ou descarte as sugestões da IA antes de enviar');
      return;
    }
    if (!_validar()) return;

    setState(() {
      _enviando = true;
      _progresso = 0;
      _progressoLabel = 'Preparando...';
    });

    try {
      await _step(0.20, 'Buscando configurações...');
      final apiBrevo = await _getApiBrevo();

      await _step(0.50, 'Enviando e-mail...');
      final emailsCc = _splitEmails(_cCc.text).where(_emailValido).toList();

      await _enviarBrevo(
        apiKey: apiBrevo,
        para: List<String>.from(_emailsSelecionados),
        cc: emailsCc,
        assunto: _cAssunto.text.trim(),
        corpo: _cCorpo.text.trim(),
        nomeRemetente: _cNome.text.trim().isNotEmpty
            ? _cNome.text.trim()
            : _kRemetenteNome,
      );

      await _step(0.80, 'Registrando envio...');
      await FirebaseFirestore.instance.collection('EMAILS_ENVIADOS').add({
        'para': List<String>.from(_emailsSelecionados),
        'cc': emailsCc,
        'assunto': _cAssunto.text.trim(),
        'corpo': _cCorpo.text.trim(),
        'nomeRemetente': _cNome.text.trim(),
        'remetente': _kRemetenteEmail,
        'dataEnvio': Timestamp.now(),
        'origem': 'EnviarEmailLivreWidget',
      });

      await _step(0.92, 'Notificando equipe...');
      await _pushHps(_cAssunto.text.trim());

      await _step(1.0, 'Concluído!');

      if (!mounted) return;
      setState(() {
        _enviado = true;
        _enviando = false;
      });
      _successCtrl.forward();
      await Future.delayed(const Duration(milliseconds: 3200));
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        setState(() {
          _enviando = false;
          _progresso = 0;
        });
        _toast('Erro ao enviar: $e');
      }
    }
  }

  Future<void> _step(double alvo, String label) async {
    if (!mounted) return;
    setState(() => _progressoLabel = label);
    final ini = _progresso;
    for (int i = 1; i <= 20; i++) {
      await Future.delayed(const Duration(milliseconds: 16));
      if (!mounted) return;
      setState(() => _progresso = ini + (alvo - ini) * (i / 20));
    }
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), duration: const Duration(seconds: 4)));
  }

  // ── Decoração de campo ────────────────────────────────────────────
  InputDecoration _dec({
    required String label,
    required String hint,
    required bool isDark,
    String? erro,
    IconData? icon,
    Widget? suffix,
  }) {
    final borda = isDark ? Colors.white12 : Colors.black12;
    final erroCor = Colors.red.shade400;
    return InputDecoration(
      labelText: label.isNotEmpty ? label : null,
      labelStyle: TextStyle(
          fontSize: 13, color: isDark ? Colors.white60 : Colors.black54),
      hintText: hint,
      hintStyle: TextStyle(
          fontSize: 13, color: isDark ? Colors.white30 : Colors.black26),
      filled: true,
      fillColor: isDark ? const Color(0xFF252D3A) : const Color(0xFFF8FAFB),
      errorText: erro,
      errorStyle: TextStyle(fontSize: 11, color: erroCor),
      prefixIcon: icon != null
          ? Icon(icon,
              size: 18, color: isDark ? Colors.white38 : Colors.black38)
          : null,
      suffixIcon: suffix,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: borda)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: erro != null ? erroCor : borda)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _kVerde, width: 1.8)),
      errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: erroCor)),
      focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: erroCor, width: 1.8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
    );
  }

  // ── Botão IA ──────────────────────────────────────────────────────
  Widget _btnIA({
    required String label,
    required bool loading,
    required VoidCallback onTap,
    Color cor = const Color(0xFF3730A3),
    IconData icone = Icons.auto_awesome_rounded,
  }) {
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: cor.withOpacity(loading ? 0.06 : 0.12),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: cor.withOpacity(loading ? 0.15 : 0.40)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (loading)
            SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                  strokeWidth: 1.5, color: cor, value: null),
            )
          else
            Icon(icone, size: 13, color: cor),
          if (label.isNotEmpty) ...[
            const SizedBox(width: 5),
            Text(label,
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: cor.withOpacity(loading ? 0.45 : 1.0))),
          ],
        ]),
      ),
    );
  }

  // ── Card sugestão IA ──────────────────────────────────────────────
  Widget _cardSugestao({
    required String texto,
    required VoidCallback onAceitar,
    required VoidCallback onRejeitar,
    required bool isDark,
    bool scrollable = false,
  }) {
    const purple = Color(0xFF3730A3);
    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1430) : const Color(0xFFF5F0FF),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: purple.withOpacity(0.35), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: purple.withOpacity(isDark ? 0.20 : 0.08),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(9)),
            ),
            child: Row(children: [
              const Icon(Icons.auto_awesome_rounded, size: 14, color: purple),
              const SizedBox(width: 6),
              const Text('Sugestão da IA',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: purple)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: purple.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text('Gemini',
                    style: TextStyle(
                        fontSize: 10,
                        color: purple,
                        fontWeight: FontWeight.w600)),
              ),
            ]),
          ),
          // Conteúdo
          Padding(
            padding: const EdgeInsets.all(12),
            child: scrollable
                ? ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 160),
                    child: SingleChildScrollView(
                      child: Text(texto,
                          style: TextStyle(
                              fontSize: 13,
                              height: 1.6,
                              color: isDark
                                  ? const Color(0xDEFFFFFF)
                                  : Colors.black87)),
                    ),
                  )
                : Text(texto,
                    style: TextStyle(
                        fontSize: 13,
                        height: 1.5,
                        fontWeight: FontWeight.w500,
                        color:
                            isDark ? const Color(0xDEFFFFFF) : Colors.black87)),
          ),
          // Botões
          Padding(
            padding: const EdgeInsets.only(left: 12, right: 12, bottom: 12),
            child: Row(children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onRejeitar,
                  icon: const Icon(Icons.close_rounded, size: 14),
                  label:
                      const Text('Descartar', style: TextStyle(fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red.shade400,
                    side: BorderSide(color: Colors.red.shade200),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: onAceitar,
                  icon: const Icon(Icons.check_rounded,
                      size: 14, color: Colors.white),
                  label: const Text('Aceitar sugestão',
                      style: TextStyle(fontSize: 12, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: purple,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  // ── BUILD ─────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E2530) : Colors.white;
    final bordaCor = isDark ? Colors.white12 : Colors.black12;
    final txtPri = isDark ? Colors.white : Colors.black87;
    final txtSec = isDark ? Colors.white54 : Colors.black54;

    // ── Tela de sucesso ───────────────────────────────────────────
    if (_enviado) {
      return Container(
        width: widget.width,
        padding: const EdgeInsets.all(36),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.10), blurRadius: 20)
          ],
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ScaleTransition(
            scale: _successAnim,
            child: Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.green.shade300, width: 3)),
              child: const Icon(Icons.mark_email_read_rounded,
                  color: Colors.green, size: 46),
            ),
          ),
          const SizedBox(height: 22),
          const Text('E-mail enviado com sucesso!',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green)),
          const SizedBox(height: 10),
          Text('Para: ${_emailsSelecionados.join(", ")}',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: txtSec, height: 1.6)),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
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
          ),
        ]),
      );
    }

    // ── Formulário ────────────────────────────────────────────────
    final form = Container(
      width: widget.width,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.40 : 0.08),
              blurRadius: 20,
              offset: const Offset(0, 4))
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
                      color: _kVerde, borderRadius: BorderRadius.circular(12)),
                  child: const Center(
                      child: Text('HPS Refrigeração',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18))),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Remetente fixo
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                  color: _kVerde.withOpacity(isDark ? 0.15 : 0.07),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _kVerde.withOpacity(0.18))),
              child: Row(children: [
                CircleAvatar(
                    radius: 18,
                    backgroundColor: _kVerde,
                    child: const Text('H',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15))),
                const SizedBox(width: 10),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(_kRemetenteEmail,
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: txtPri)),
                  Text('Remetente fixo',
                      style: TextStyle(fontSize: 11, color: txtSec)),
                ]),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                      color: _kVerde, borderRadius: BorderRadius.circular(12)),
                  child: const Text('De',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600)),
                ),
              ]),
            ),
            const SizedBox(height: 14),

            // Título
            Row(children: [
              const Icon(Icons.email_outlined, size: 18, color: _kVerde),
              const SizedBox(width: 8),
              Text('Novo E-mail',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: txtPri)),
            ]),
            const SizedBox(height: 4),
            Text(
                'Busque usuários ou digite e-mails. '
                'Use a IA para corrigir e melhorar os textos.',
                style: TextStyle(fontSize: 11, color: txtSec)),
            const SizedBox(height: 14),
            Divider(color: bordaCor),
            const SizedBox(height: 12),

            // ── Nome do remetente ─────────────────────────────────
            TextFormField(
              controller: _cNome,
              style: TextStyle(fontSize: 14, color: txtPri),
              textCapitalization: TextCapitalization.words,
              decoration: _dec(
                label: 'Nome do remetente',
                hint: 'Ex: Huagner Pires — HPS Refrigeração',
                isDark: isDark,
                icon: Icons.person_outline_rounded,
              ),
            ),
            const SizedBox(height: 14),

            // ── Destinatários ─────────────────────────────────────
            Row(children: [
              Text('Destinatário',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: txtPri)),
              const SizedBox(width: 8),
              if (_emailsSelecionados.isNotEmpty)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                      color: _kVerde, borderRadius: BorderRadius.circular(10)),
                  child: Text('+${_emailsSelecionados.length}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600)),
                ),
            ]),
            const SizedBox(height: 4),
            const Text('Selecione para carregar os e-mails disponíveis',
                style: TextStyle(fontSize: 11, color: Colors.grey)),
            const SizedBox(height: 8),

            // Dropdown de cliente
            _loadingUsuarios
                ? const Center(
                    child: Padding(
                        padding: EdgeInsets.all(12),
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: _kVerde)))
                : DropdownButtonFormField<String>(
                    value: _emailPrincipal,
                    hint: Text('Selecione o cliente / empresa',
                        style: TextStyle(
                            color: isDark ? Colors.white54 : Colors.black54)),
                    isExpanded: true,
                    decoration: _dec(
                        label: '',
                        hint: 'Selecione o cliente',
                        isDark: isDark,
                        erro: _emailPrincipal == null ? _erroPara : null),
                    dropdownColor:
                        isDark ? const Color(0xFF252D3A) : Colors.white,
                    style: TextStyle(color: txtPri),
                    items: _usuarios.map((u) {
                      final email = u['email'] as String;
                      final nome = u['nome'] as String;
                      return DropdownMenuItem<String>(
                        value: email,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(nome,
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: txtPri),
                                overflow: TextOverflow.ellipsis),
                            Text(email,
                                style: TextStyle(fontSize: 12, color: txtSec),
                                overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: _selecionarUsuario,
                  ),
            const SizedBox(height: 12),

            // Lista de e-mails com checkboxes (aparece após selecionar cliente)
            if (_emailPrincipal != null) ...[
              Row(children: [
                Text('E-mails para envio',
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: txtPri)),
                const SizedBox(width: 8),
              ]),
              const SizedBox(height: 4),
              const Text('Marque os e-mails que vão receber a mensagem',
                  style: TextStyle(fontSize: 11, color: Colors.grey)),
              const SizedBox(height: 8),

              if (_emailsDisponiveis.isEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF252D3A)
                          : const Color(0xFFF4F6F8),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: bordaCor)),
                  child: const Text(
                      'Nenhum e-mail cadastrado para este cliente',
                      style: TextStyle(fontSize: 13, color: Colors.grey)),
                )
              else
                Container(
                  decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF252D3A)
                          : const Color(0xFFF4F6F8),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color:
                              _emailsSelecionados.isEmpty && _erroPara != null
                                  ? Colors.red.shade400
                                  : bordaCor)),
                  child: Column(
                    children: List.generate(
                      _emailsDisponiveis.length,
                      (idx) {
                        final email = _emailsDisponiveis[idx];
                        final sel = _emailsSelecionados.contains(email);
                        final isFirst = idx == 0;
                        final isLast = idx == _emailsDisponiveis.length - 1;
                        return Column(children: [
                          if (!isFirst) Divider(height: 1, color: bordaCor),
                          InkWell(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(isFirst ? 10 : 0),
                              topRight: Radius.circular(isFirst ? 10 : 0),
                              bottomLeft: Radius.circular(isLast ? 10 : 0),
                              bottomRight: Radius.circular(isLast ? 10 : 0),
                            ),
                            onTap: () => setState(() {
                              if (sel) {
                                _emailsSelecionados.remove(email);
                              } else {
                                _emailsSelecionados.add(email);
                              }
                              _erroPara = null;
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
                                    color: sel ? _kVerde : Colors.transparent,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                        color: sel
                                            ? _kVerde
                                            : (isDark
                                                ? Colors.white30
                                                : Colors.grey.shade400),
                                        width: 2),
                                  ),
                                  child: sel
                                      ? const Icon(Icons.check,
                                          color: Colors.white, size: 14)
                                      : null,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(email,
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: sel
                                              ? FontWeight.w600
                                              : FontWeight.normal,
                                          color: sel ? _kVerde : txtPri)),
                                ),
                              ]),
                            ),
                          ),
                        ]);
                      },
                    ),
                  ),
                ),

              // Erro e-mails
              if (_emailsSelecionados.isEmpty && _erroPara != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(_erroPara!,
                      style:
                          TextStyle(fontSize: 11, color: Colors.red.shade400)),
                ),
              const SizedBox(height: 14),
            ],

            // ── CC ────────────────────────────────────────────────
            TextFormField(
              controller: _cCc,
              keyboardType: TextInputType.emailAddress,
              style: TextStyle(fontSize: 14, color: txtPri),
              maxLines: 2,
              minLines: 1,
              decoration: _dec(
                label: 'CC (cópia)',
                hint: 'Opcional — email@copia.com, outro@exemplo.com',
                isDark: isDark,
                icon: Icons.alternate_email_rounded,
              ),
            ),
            const SizedBox(height: 14),

            // ── Assunto ───────────────────────────────────────────
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(children: [
                  Expanded(
                    child: Text('Assunto *',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: txtPri)),
                  ),
                  _btnIA(
                    label: _iaAssuntoLoad ? 'Melhorando...' : 'Melhorar com IA',
                    loading: _iaAssuntoLoad,
                    onTap: _melhorarAssunto,
                    icone: Icons.auto_fix_high_rounded,
                  ),
                  if (_assuntoAntes != null) ...[
                    const SizedBox(width: 6),
                    _btnIA(
                      label: 'Desfazer',
                      loading: false,
                      onTap: _desfazerAssunto,
                      cor: Colors.orange.shade700,
                      icone: Icons.undo_rounded,
                    ),
                  ],
                ]),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _cAssunto,
                  style: TextStyle(fontSize: 14, color: txtPri),
                  decoration: _dec(
                    label: '',
                    hint: 'Ex: Relatório preventiva – Maio/2026',
                    isDark: isDark,
                    erro: _erroAssunto,
                  ),
                ),
                if (_sugestaoAssunto != null)
                  _cardSugestao(
                    texto: _sugestaoAssunto!,
                    onAceitar: _aceitarAssunto,
                    onRejeitar: _rejeitarAssunto,
                    isDark: isDark,
                  ),
              ],
            ),
            const SizedBox(height: 14),

            // ── Corpo ─────────────────────────────────────────────
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text('Corpo do e-mail *',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: txtPri)),
                    _btnIA(
                      label: _iaCorpoLoad ? 'Gerando...' : 'Gerar com IA',
                      loading: _iaCorpoLoad,
                      onTap: _gerarCorpo,
                      cor: const Color(0xFF0369A1),
                      icone: Icons.auto_awesome_outlined,
                    ),
                    _btnIA(
                      label: _iaCorpoLoad ? '' : 'Melhorar',
                      loading: _iaCorpoLoad,
                      onTap: _melhorarCorpo,
                      icone: Icons.auto_fix_high_rounded,
                    ),
                    if (_corpoAntes != null)
                      _btnIA(
                        label: 'Desfazer',
                        loading: false,
                        onTap: _desfazerCorpo,
                        cor: Colors.orange.shade700,
                        icone: Icons.undo_rounded,
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _cCorpo,
                  maxLines: 10,
                  minLines: 6,
                  textCapitalization: TextCapitalization.sentences,
                  style: TextStyle(fontSize: 14, color: txtPri, height: 1.6),
                  decoration: _dec(
                    label: '',
                    hint: 'Prezados,\n\nEscreva o conteúdo do e-mail...',
                    isDark: isDark,
                    erro: _erroCorpo,
                  ),
                ),
                if (_sugestaoCorpo != null)
                  _cardSugestao(
                    texto: _sugestaoCorpo!,
                    onAceitar: _aceitarCorpo,
                    onRejeitar: _rejeitarCorpo,
                    isDark: isDark,
                    scrollable: true,
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '💡 "Gerar com IA" cria rascunho a partir do assunto. '
              '"Melhorar" corrige e aprimora o texto digitado.',
              style: TextStyle(fontSize: 10, color: txtSec),
            ),
            const SizedBox(height: 20),

            // ── Botões ────────────────────────────────────────────
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
                      side: BorderSide(
                          color: isDark ? Colors.white24 : Colors.black26)),
                  child: Text('Cancelar', style: TextStyle(color: txtPri)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.send_rounded,
                      size: 16, color: Colors.white),
                  label: const Text('Enviar E-mail',
                      style: TextStyle(color: Colors.white)),
                  onPressed: _enviando ? null : _enviar,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: _kVerde,
                      elevation: 1,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10))),
                ),
              ),
            ]),
          ],
        ),
      ),
    );

    // ── Overlay de progresso ──────────────────────────────────────
    if (_enviando) {
      return Stack(children: [
        form,
        Positioned.fill(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              color: Colors.black.withOpacity(0.55),
              child: Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 32),
                  padding: const EdgeInsets.all(26),
                  decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.30),
                            blurRadius: 24)
                      ]),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Container(
                      width: 66,
                      height: 66,
                      decoration: BoxDecoration(
                          color: _kVerde.withOpacity(0.12),
                          shape: BoxShape.circle),
                      child: const Icon(Icons.email_rounded,
                          color: _kVerde, size: 34),
                    ),
                    const SizedBox(height: 16),
                    Text('Enviando e-mail',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: txtPri)),
                    const SizedBox(height: 6),
                    Text(_progressoLabel,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, color: txtSec)),
                    const SizedBox(height: 20),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: _progresso,
                        minHeight: 10,
                        backgroundColor:
                            isDark ? Colors.white12 : Colors.grey.shade200,
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(_kVerde),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text('${(_progresso * 100).toStringAsFixed(0)}%',
                          style: const TextStyle(
                              fontSize: 12,
                              color: _kVerde,
                              fontWeight: FontWeight.bold)),
                    ),
                  ]),
                ),
              ),
            ),
          ),
        ),
      ]);
    }

    return form;
  }
}
