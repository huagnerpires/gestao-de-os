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
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EsqueciSenhaWidget extends StatefulWidget {
  const EsqueciSenhaWidget({Key? key, this.width, this.height})
      : super(key: key);
  final double? width;
  final double? height;

  @override
  State<EsqueciSenhaWidget> createState() => _EsqueciSenhaWidgetState();
}

class _EsqueciSenhaWidgetState extends State<EsqueciSenhaWidget> {
  static const Color _primary = Color(0xFF0F766E);
  static const Color _dark = Color(0xFF0F766E);
  static const Color _red = Color(0xFFB91C1C);
  static const Color _orange = Color(0xFFC2410C);
  static const Color _bg = Color(0xFF1A3C34);

  String get _email => FirebaseAuth.instance.currentUser?.email ?? '';

  // Dica
  String _dicaMascarada = '';
  int _tamanhoSenha = 0;
  bool _mostrandoDica = false;

  // Campos alterar senha
  final _senhaAtualCtrl = TextEditingController();
  final _novaSenhaCtrl = TextEditingController();
  final _confirmarCtrl = TextEditingController();
  bool _showAtual = false;
  bool _showNova = false;
  bool _showConfirmar = false;

  // Solicitar reset
  bool _mostrarReset = false;
  final _nomeCtrl = TextEditingController();
  final _motivoCtrl = TextEditingController();
  String? _motivoSelecionado;
  final List<String> _motivos = [
    'Esqueci minha senha',
    'Senha não funciona mais',
    'Primeiro acesso',
    'Outro',
  ];

  // Estados
  bool _carregando = false;
  bool _sucesso = false;
  bool _resetEnviado = false;
  String _erro = '';

  @override
  void initState() {
    super.initState();
    _carregarDica();
  }

  @override
  void dispose() {
    _senhaAtualCtrl.dispose();
    _novaSenhaCtrl.dispose();
    _confirmarCtrl.dispose();
    _nomeCtrl.dispose();
    _motivoCtrl.dispose();
    super.dispose();
  }

  Future<void> _carregarDica() async {
    try {
      final userEmail = _email;
      final snap = await FirebaseFirestore.instance
          .collection('USUÁRIOS')
          .where('e-mail', isEqualTo: userEmail)
          .limit(1)
          .get();
      if (snap.docs.isNotEmpty) {
        final senha = (snap.docs.first.data()['senha'] ?? '').toString().trim();
        if (senha.isNotEmpty) {
          String dica;
          if (senha.length == 1) {
            dica = '*';
          } else if (senha.length == 2) {
            dica = '${senha[0]}*';
          } else {
            dica =
                '${senha[0]}${'*' * (senha.length - 2)}${senha[senha.length - 1]}';
          }
          if (mounted) {
            setState(() {
              _dicaMascarada = dica;
              _tamanhoSenha = senha.length;
            });
          }
        }
      }
    } catch (_) {}
  }

  Future<void> _alterarSenha() async {
    final atual = _senhaAtualCtrl.text.trim();
    final nova = _novaSenhaCtrl.text.trim();
    final conf = _confirmarCtrl.text.trim();
    final userEmail = _email;

    if (atual.isEmpty || nova.isEmpty || conf.isEmpty) {
      setState(() => _erro = 'Preencha todos os campos.');
      return;
    }
    if (nova.length < 6) {
      setState(
          () => _erro = 'A nova senha precisa ter pelo menos 6 caracteres.');
      return;
    }
    if (nova != conf) {
      setState(() => _erro = 'As senhas não coincidem.');
      return;
    }

    setState(() {
      _carregando = true;
      _erro = '';
    });

    try {
      final snap = await FirebaseFirestore.instance
          .collection('USUÁRIOS')
          .where('e-mail', isEqualTo: userEmail)
          .limit(1)
          .get();

      if (snap.docs.isEmpty) {
        setState(() {
          _erro = 'Usuário não encontrado.';
          _carregando = false;
        });
        return;
      }

      final senhaFS = (snap.docs.first.data()['senha'] ?? '').toString().trim();
      if (atual != senhaFS) {
        setState(() {
          _erro = 'Senha atual incorreta.';
          _carregando = false;
        });
        return;
      }

      await snap.docs.first.reference.update({'senha': nova});

      try {
        await FirebaseAuth.instance.currentUser?.updatePassword(nova);
      } catch (_) {}

      try {
        await http.post(
          Uri.parse(
              'https://us-central1-h-p-s-modificado-emdcp0.cloudfunctions.net/alterarSenha'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'data': {
              'e-mail': userEmail,
              'senhaAtual': atual,
              'novaSenha': nova
            }
          }),
        );
      } catch (_) {}

      _senhaAtualCtrl.clear();
      _novaSenhaCtrl.clear();
      _confirmarCtrl.clear();
      setState(() {
        _sucesso = true;
        _carregando = false;
      });
    } catch (e) {
      setState(() {
        _erro = 'Erro: $e';
        _carregando = false;
      });
    }
  }

  Future<void> _enviarSolicitacao() async {
    final nome = _nomeCtrl.text.trim();
    final motivo = _motivoSelecionado;
    final detalhe = _motivoCtrl.text.trim();
    final userEmail = _email;

    if (nome.isEmpty) {
      setState(() => _erro = 'Informe seu nome..');
      return;
    }
    if (motivo == null) {
      setState(() => _erro = 'Selecione o motivo.');
      return;
    }

    setState(() {
      _carregando = true;
      _erro = '';
    });

    try {
      await FirebaseFirestore.instance.collection('SOLICITAÇÕES_SENHA').add({
        'e-mail': userEmail,
        'nome': nome,
        'motivo': motivo,
        'detalhe': detalhe,
        'status': 'pendente',
        'criadoEm': FieldValue.serverTimestamp(),
        'resolvidoEm': null,
        'resolvidoPor': null,
        'novaSenha': null,
      });

      await _notificarAdmins(nome: nome, motivo: motivo, userEmail: userEmail);
      await _emailHPS(
          nome: nome, motivo: motivo, detalhe: detalhe, userEmail: userEmail);

      setState(() {
        _carregando = false;
        _resetEnviado = true;
      });
    } catch (e) {
      setState(() {
        _erro = 'Erro: $e';
        _carregando = false;
      });
    }
  }

  Future<void> _notificarAdmins({
    required String nome,
    required String motivo,
    required String userEmail,
  }) async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('USUÁRIOS')
          .where('e-mail', isEqualTo: 'hpsrefri@gmail.com')
          .limit(1)
          .get();

      final lista = <String>['hpsrefri@gmail.com'];
      if (snap.docs.isNotEmpty) {
        final field = snap.docs.first.data()['e-mailteste'];
        if (field is List) {
          for (final e in field) {
            final s = (e ?? '').toString().trim();
            if (s.isNotEmpty) lista.add(s);
          }
        } else if (field is String && field.trim().isNotEmpty) {
          lista.add(field.trim());
        }
      }

      for (final adm in lista) {
        await FirebaseFirestore.instance.collection('NOTIFICAÇÃO').add({
          'e-mail': adm,
          'título': 'Solicitação de Reset de Senha',
          'mensagem':
              '$nome ($userEmail) solicitou redefinição de senha. Motivo: $motivo.',
          'tipo': 'sistema',
          'visto': false,
          'data': Timestamp.now(),
          'status': 'pendente',
          'os': '',
          'solicitanteE-mail': userEmail,
          'solicitanteNome': nome,
        });
      }
    } catch (e) {
      debugPrint('Erro notificação: $e');
    }
  }

  Future<void> _emailHPS({
    required String nome,
    required String motivo,
    required String detalhe,
    required String userEmail,
  }) async {
    String apiKey = '';
    try {
      final snap = await FirebaseFirestore.instance
          .collection('USUÁRIOS')
          .where('e-mail', isEqualTo: 'hpsrefri@gmail.com')
          .limit(1)
          .get();
      if (snap.docs.isNotEmpty) {
        apiKey = (snap.docs.first.data()['apibrevo'] ?? '').toString().trim();
      }
    } catch (_) {}
    if (apiKey.isEmpty) return;

    const img =
        'https://firebasestorage.googleapis.com/v0/b/h-p-s-modificado-emdcp0.appspot.com/o/Gemini_Generated_Image_2xpdsd2xpdsd2xpd%20(1).png?alt=media&token=be3e052e-a0b8-4e8c-8151-b9365b507ed5';
    final det = detalhe.isNotEmpty
        ? '<tr><td style="padding:10px 14px;font-weight:bold;color:#374151;">Detalhe</td><td style="padding:10px 14px;color:#1f2937;">$detalhe</td></tr>'
        : '';

    // Conteudo do email — mesmo padrao do EnviarEmailWidget
    final msgHtml =
        '<h2 style="margin:0 0 16px;color:#1A3C34;font-family:Arial,sans-serif;">Nova Solicitação de Reset de Senha</h2>'
        '<p style="margin:0 0 20px;font-size:15px;color:#374151;line-height:1.7;font-family:Arial,sans-serif;">'
        'O usuário <strong>$nome</strong> (<strong>$userEmail</strong>) solicitou a redefinição de senha no aplicativo.</p>'
        '<table width="100%" cellpadding="0" cellspacing="0" border="0" style="border-collapse:collapse;border:1px solid #e2e8f0;border-radius:8px;margin-bottom:20px;font-size:14px;font-family:Arial,sans-serif;">'
        '<tr><td colspan="2" style="background:#1A3C34;padding:10px 14px;"><span style="color:#fff;font-size:13px;font-weight:bold;letter-spacing:0.5px;">DETALHES DA SOLICITACAO</span></td></tr>'
        '<tr style="background:#f8fafc;"><td style="padding:10px 14px;font-weight:bold;color:#374151;width:160px;border-bottom:1px solid #e2e8f0;">Nome</td><td style="padding:10px 14px;color:#1f2937;border-bottom:1px solid #e2e8f0;">$nome</td></tr>'
        '<tr><td style="padding:10px 14px;font-weight:bold;color:#374151;border-bottom:1px solid #e2e8f0;">Email</td><td style="padding:10px 14px;color:#1f2937;border-bottom:1px solid #e2e8f0;">$userEmail</td></tr>'
        '<tr style="background:#f8fafc;"><td style="padding:10px 14px;font-weight:bold;color:#374151;border-bottom:1px solid #e2e8f0;">Motivo</td><td style="padding:10px 14px;color:#c0392b;font-weight:bold;border-bottom:1px solid #e2e8f0;">$motivo</td></tr>'
        '$det</table>'
        '<table width="100%" cellpadding="0" cellspacing="0" border="0" style="background:#fff3cd;border-left:4px solid #C2410C;border-radius:0 6px 6px 0;margin-bottom:8px;">'
        '<tr><td style="padding:12px 16px;font-size:14px;color:#856404;line-height:1.6;font-family:Arial,sans-serif;">'
        'Acesse o aplicativo como administrador para redefinir a senha deste usuário.'
        '</td></tr></table>';

    final htmlFull = '''
<!DOCTYPE html>
<html lang="pt-BR">
<head>
  <meta charset="UTF-8">
  <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
  <title>Solicitacao de Reset de Senha</title>
</head>
<body style="margin:0;padding:0;background-color:#f4f6f8;font-family:Arial,Helvetica,sans-serif;">
  <table width="100%" cellpadding="0" cellspacing="0" border="0" style="background-color:#f4f6f8;padding:20px 0;">
    <tr><td align="center">
      <table width="600" cellpadding="0" cellspacing="0" border="0"
             style="background:#ffffff;border-radius:12px;overflow:hidden;max-width:1400px;width:100%;">
        <tr>
          <td style="padding:0;margin:0;line-height:0;">
            <img src="\$img" alt="HPS Refrigeração" width="600"
                 style="display:block;width:100%;max-width:1400px;height:auto;border:0;"/>
          </td>
        </tr>
        <tr>
          <td style="background-color:#1A3C34;padding:12px 24px;">
            <table width="100%" cellpadding="0" cellspacing="0" border="0">
              <tr>
                <td></td>
                <td align="right">
                  <span style="background:#ffffff20;color:#ffffff;font-size:11px;font-weight:bold;padding:4px 10px;border-radius:20px;font-family:Arial,sans-serif;">Notificacao Automatica</span>
                </td>
              </tr>
            </table>
          </td>
        </tr>
        <tr>
          <td style="padding:28px;color:#333333;font-size:15px;line-height:1.7;font-family:Arial,Helvetica,sans-serif;">
            \$msgHtml
          </td>
        </tr>
        <tr><td style="padding:0 28px;"><hr style="border:none;border-top:1px solid #e8ecf0;margin:0;"></td></tr>
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
                  <span style="font-size:13px;color:#555555;font-family:Arial,sans-serif;">Especialista em Refrigeracao</span><br>
                  <span style="font-size:12px;color:#888888;font-family:Arial,sans-serif;">hpsrefri.com.br</span>
                </td>
              </tr>
            </table>
          </td>
        </tr>
        <tr>
          <td style="background:#f1f5f9;padding:14px 28px;text-align:center;font-size:12px;color:#94a3b8;font-family:Arial,Helvetica,sans-serif;border-top:1px solid #e2e8f0;">
            &copy; 2026 HPS Refrigeracao &middot; Todos os direitos reservados<br>
            <span style="font-size:11px;">Esta e uma mensagem automatica, por favor nao responda diretamente.</span>
          </td>
        </tr>
      </table>
    </td></tr>
  </table>
</body>
</html>
''';

    await http.post(
      Uri.parse('https://api.brevo.com/v3/smtp/e-mail'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'api-key': apiKey
      },
      body: jsonEncode({
        'sender': {
          'name': 'HPS Refrigeração',
          'e-mail': 'equipe@hpsrefri.com.br'
        },
        'replyTo': {
          'name': 'HPS Refrigeração',
          'e-mail': 'equipe@hpsrefri.com.br'
        },
        'to': [
          {'e-mail': 'hpsrefri@gmail.com'}
        ],
        'subject': 'Solicitação de Reset de Senha - $nome',
        'htmlContent': htmlFull,
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Tela sucesso alterar senha
    if (_sucesso) {
      return SafeArea(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: widget.width ?? double.infinity,
            color: theme.primaryBackground,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(36),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: _primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: _primary.withOpacity(0.4), width: 2),
                      ),
                      child: const Icon(Icons.check_circle_outline_rounded,
                          color: _primary, size: 40),
                    ),
                    const SizedBox(height: 22),
                    Text('Senha Alterada!',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: theme.primaryText)),
                    const SizedBox(height: 10),
                    Text('Sua senha foi atualizada com sucesso.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 14,
                            color: theme.secondaryText,
                            height: 1.6)),
                    const SizedBox(height: 30),
                    _btnFechar(_primary),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    // Tela sucesso solicitar reset
    if (_resetEnviado) {
      return SafeArea(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: widget.width ?? double.infinity,
            color: theme.primaryBackground,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(36),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: _orange.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: _orange.withOpacity(0.4), width: 2),
                      ),
                      child: const Icon(Icons.mark_email_read_rounded,
                          color: _orange, size: 40),
                    ),
                    const SizedBox(height: 22),
                    Text('Solicitação Enviada!',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: theme.primaryText)),
                    const SizedBox(height: 10),
                    Text(
                        'A equipe HPS recebeu sua solicitação\ne entrará em contato em breve.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 14,
                            color: theme.secondaryText,
                            height: 1.6)),
                    const SizedBox(height: 30),
                    _btnFechar(_orange),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return SafeArea(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: widget.width ?? double.infinity,
          color: theme.primaryBackground,
          child: Column(
            children: [
              // ── Header gradiente ─────────────────────────────────
              Container(
                padding: const EdgeInsets.fromLTRB(20, 22, 12, 22),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_primary, _dark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Row(children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.lock_person_rounded,
                        color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Gerenciar Senha',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.3)),
                      const SizedBox(height: 2),
                      Text(_email,
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.65),
                              fontSize: 11),
                          overflow: TextOverflow.ellipsis),
                    ],
                  )),
                ]),
              ),

              // ── Corpo rolavel ────────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ── Secao: Alterar senha ─────────────────────
                      _secaoTitulo(
                          'ALTERAR SENHA', Icons.lock_reset_rounded, theme),
                      const SizedBox(height: 16),

                      // Campo senha atual
                      _label('Senha Atual', theme),
                      const SizedBox(height: 6),
                      _campoSenha(
                        ctrl: _senhaAtualCtrl,
                        hint: 'Digite sua senha atual',
                        obscure: !_showAtual,
                        theme: theme,
                        isDark: isDark,
                        toggle: () => setState(() => _showAtual = !_showAtual),
                      ),

                      // Dica discreta
                      if (_dicaMascarada.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 5, left: 2),
                          child: GestureDetector(
                            onTap: () => setState(
                                () => _mostrandoDica = !_mostrandoDica),
                            child: Row(children: [
                              Icon(
                                _mostrandoDica
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                size: 12,
                                color: theme.secondaryText.withOpacity(0.4),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _mostrandoDica
                                    ? 'Ocultar dica'
                                    : 'Ver dica da senha',
                                style: TextStyle(
                                    fontSize: 11,
                                    color: theme.secondaryText.withOpacity(0.4),
                                    fontWeight: FontWeight.w400),
                              ),
                            ]),
                          ),
                        ),

                      // Dica expandida inline
                      if (_mostrandoDica && _dicaMascarada.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(top: 6),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withOpacity(0.04)
                                : Colors.black.withOpacity(0.03),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: theme.alternate.withOpacity(0.5)),
                          ),
                          child: Row(children: [
                            Icon(Icons.vpn_key_outlined,
                                size: 13,
                                color: theme.secondaryText.withOpacity(0.4)),
                            const SizedBox(width: 8),
                            Text('Formato: ',
                                style: TextStyle(
                                    fontSize: 11,
                                    color:
                                        theme.secondaryText.withOpacity(0.45))),
                            Text(_dicaMascarada,
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: theme.primaryText.withOpacity(0.7),
                                    letterSpacing: 2.5)),
                            const SizedBox(width: 6),
                            Text('• $_tamanhoSenha caracteres',
                                style: TextStyle(
                                    fontSize: 10,
                                    color:
                                        theme.secondaryText.withOpacity(0.35))),
                          ]),
                        ),

                      const SizedBox(height: 14),

                      // Nova senha
                      _label('Nova Senha', theme),
                      const SizedBox(height: 6),
                      _campoSenha(
                        ctrl: _novaSenhaCtrl,
                        hint: 'Mínimo 6 caracteres',
                        obscure: !_showNova,
                        theme: theme,
                        isDark: isDark,
                        toggle: () => setState(() => _showNova = !_showNova),
                      ),

                      const SizedBox(height: 12),

                      // Confirmar
                      _label('Confirmar Nova Senha', theme),
                      const SizedBox(height: 6),
                      _campoSenha(
                        ctrl: _confirmarCtrl,
                        hint: 'Repita a nova senha',
                        obscure: !_showConfirmar,
                        theme: theme,
                        isDark: isDark,
                        toggle: () =>
                            setState(() => _showConfirmar = !_showConfirmar),
                      ),

                      // Erro
                      if (_erro.isNotEmpty && !_mostrarReset) ...[
                        const SizedBox(height: 12),
                        _bannerErro(_erro, theme),
                      ],

                      const SizedBox(height: 20),

                      // Botao salvar
                      _btnPrimario(
                        label: 'Salvar Nova Senha',
                        icon: Icons.save_rounded,
                        carregando: _carregando && !_mostrarReset,
                        gradient: const [_primary, _dark],
                        onTap: _alterarSenha,
                      ),

                      // ── Divisor ──────────────────────────────────
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 28),
                        child: Row(children: [
                          Expanded(
                              child:
                                  Divider(color: theme.alternate, height: 1)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text('ou',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: theme.secondaryText.withOpacity(0.5),
                                    fontWeight: FontWeight.w500)),
                          ),
                          Expanded(
                              child:
                                  Divider(color: theme.alternate, height: 1)),
                        ]),
                      ),

                      // ── Secao: Solicitar reset ───────────────────
                      _secaoTitulo('NÃO LEMBRO A SENHA',
                          Icons.support_agent_rounded, theme),
                      const SizedBox(height: 6),
                      Text(
                        'Solicite a redefinição pela equipe HPS. Você será notificado quando a senha for redefinida.',
                        style: TextStyle(
                            fontSize: 12,
                            color: theme.secondaryText.withOpacity(0.7),
                            height: 1.5),
                      ),
                      const SizedBox(height: 16),

                      // Toggle expandir formulario de reset
                      GestureDetector(
                        onTap: () => setState(() {
                          _mostrarReset = !_mostrarReset;
                          _erro = '';
                        }),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 13),
                          decoration: BoxDecoration(
                            color: _mostrarReset
                                ? _orange.withOpacity(isDark ? 0.15 : 0.08)
                                : theme.secondaryBackground,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _mostrarReset
                                  ? _orange.withOpacity(0.5)
                                  : theme.alternate,
                              width: _mostrarReset ? 1.5 : 1,
                            ),
                          ),
                          child: Row(children: [
                            Icon(Icons.lock_open_rounded,
                                color: _mostrarReset
                                    ? _orange
                                    : theme.secondaryText.withOpacity(0.6),
                                size: 18),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Solicitar redefinição de senha',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: _mostrarReset
                                        ? _orange
                                        : theme.primaryText),
                              ),
                            ),
                            Icon(
                              _mostrarReset
                                  ? Icons.expand_less_rounded
                                  : Icons.expand_more_rounded,
                              color: _mostrarReset
                                  ? _orange
                                  : theme.secondaryText.withOpacity(0.5),
                              size: 20,
                            ),
                          ]),
                        ),
                      ),

                      // Formulario de reset
                      AnimatedSize(
                        duration: const Duration(milliseconds: 280),
                        curve: Curves.easeInOut,
                        child: _mostrarReset
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const SizedBox(height: 16),
                                  _label('Seu Nome', theme),
                                  const SizedBox(height: 6),
                                  _campoTexto(
                                    ctrl: _nomeCtrl,
                                    hint: 'Como você se chama',
                                    icon: Icons.person_outline_rounded,
                                    theme: theme,
                                    isDark: isDark,
                                  ),
                                  const SizedBox(height: 12),
                                  _label('Motivo', theme),
                                  const SizedBox(height: 6),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: theme.secondaryBackground,
                                      borderRadius: BorderRadius.circular(12),
                                      border:
                                          Border.all(color: theme.alternate),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        value: _motivoSelecionado,
                                        isExpanded: true,
                                        dropdownColor:
                                            theme.secondaryBackground,
                                        hint: Text('Selecione o motivo',
                                            style: TextStyle(
                                                fontSize: 13,
                                                color: theme.secondaryText)),
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: theme.primaryText,
                                            fontWeight: FontWeight.w500),
                                        items: _motivos
                                            .map((m) => DropdownMenuItem(
                                                value: m, child: Text(m)))
                                            .toList(),
                                        onChanged: (v) => setState(
                                            () => _motivoSelecionado = v),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  _label('Detalhes (opcional)', theme),
                                  const SizedBox(height: 6),
                                  _campoTexto(
                                    ctrl: _motivoCtrl,
                                    hint:
                                        'Descreva o problema com mais detalhes',
                                    icon: Icons.notes_rounded,
                                    theme: theme,
                                    isDark: isDark,
                                    maxLines: 3,
                                  ),
                                  if (_erro.isNotEmpty) ...[
                                    const SizedBox(height: 12),
                                    _bannerErro(_erro, theme),
                                  ],
                                  const SizedBox(height: 20),
                                  _btnPrimario(
                                    label: 'Enviar Solicitação',
                                    icon: Icons.send_rounded,
                                    carregando: _carregando && _mostrarReset,
                                    gradient: [
                                      _orange,
                                      const Color(0xFFC2410C)
                                    ],
                                    onTap: _enviarSolicitacao,
                                  ),
                                ],
                              )
                            : const SizedBox.shrink(),
                      ),

                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _secaoTitulo(String texto, IconData icon, FlutterFlowTheme theme) {
    return Row(children: [
      Icon(icon, size: 14, color: _primary),
      const SizedBox(width: 8),
      Text(texto,
          style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: _primary,
              letterSpacing: 0.6)),
      const SizedBox(width: 10),
      Expanded(child: Divider(color: _primary.withOpacity(0.25), height: 1)),
    ]);
  }

  Widget _label(String text, FlutterFlowTheme theme) {
    return Text(
      text,
      style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: theme.primaryText.withOpacity(0.75)),
    );
  }

  Widget _campoSenha({
    required TextEditingController ctrl,
    required String hint,
    required bool obscure,
    required FlutterFlowTheme theme,
    required bool isDark,
    required VoidCallback toggle,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.alternate),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.12 : 0.04),
              blurRadius: 4,
              offset: const Offset(0, 2))
        ],
      ),
      child: TextField(
        controller: ctrl,
        obscureText: obscure,
        style: TextStyle(
            fontSize: 14,
            color: theme.primaryText,
            fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
              fontSize: 13, color: theme.secondaryText.withOpacity(0.5)),
          prefixIcon: Icon(Icons.lock_outline_rounded,
              color: _primary.withOpacity(0.5), size: 18),
          suffixIcon: IconButton(
            icon: Icon(
                obscure
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: theme.secondaryText.withOpacity(0.4),
                size: 18),
            onPressed: toggle,
          ),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        ),
      ),
    );
  }

  Widget _campoTexto({
    required TextEditingController ctrl,
    required String hint,
    required IconData icon,
    required FlutterFlowTheme theme,
    required bool isDark,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.alternate),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.12 : 0.04),
              blurRadius: 4,
              offset: const Offset(0, 2))
        ],
      ),
      child: TextField(
        controller: ctrl,
        maxLines: maxLines,
        style: TextStyle(
            fontSize: 14,
            color: theme.primaryText,
            fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
              fontSize: 13, color: theme.secondaryText.withOpacity(0.5)),
          prefixIcon: Icon(icon, color: _primary.withOpacity(0.5), size: 18),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        ),
      ),
    );
  }

  Widget _bannerErro(String msg, FlutterFlowTheme theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: _red.withOpacity(0.07),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _red.withOpacity(0.25)),
      ),
      child: Row(children: [
        Icon(Icons.error_outline_rounded,
            color: _red.withOpacity(0.8), size: 15),
        const SizedBox(width: 8),
        Expanded(
            child: Text(msg,
                style: TextStyle(color: _red.withOpacity(0.9), fontSize: 12))),
      ]),
    );
  }

  Widget _btnPrimario({
    required String label,
    required IconData icon,
    required bool carregando,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: carregando ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          gradient: carregando ? null : LinearGradient(colors: gradient),
          color: carregando ? gradient[0].withOpacity(0.35) : null,
          borderRadius: BorderRadius.circular(12),
          boxShadow: carregando
              ? []
              : [
                  BoxShadow(
                      color: gradient[0].withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4))
                ],
        ),
        child: Center(
          child: carregando
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2.5))
              : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(icon, color: Colors.white, size: 17),
                  const SizedBox(width: 9),
                  Text(label,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3)),
                ]),
        ),
      ),
    );
  }

  Widget _btnFechar(Color cor) {
    return GestureDetector(
      onTap: () => Navigator.maybePop(context),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 40),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [cor, cor.withOpacity(0.75)]),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text('Fechar',
            style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700)),
      ),
    );
  }
}
