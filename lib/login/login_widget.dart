import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import '/index.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_model.dart';
export 'login_model.dart';

class LoginWidget extends StatefulWidget {
  const LoginWidget({super.key});

  static String routeName = 'LOGIN';
  static String routePath = '/login';

  @override
  State<LoginWidget> createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget>
    with TickerProviderStateMixin {
  late LoginModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => LoginModel());

    // On page load action: verificar se já está marcado para manter logado
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      if (_model.manterlogado == true) {
        context.pushNamed(HomepagenovaWidget.routeName);
      }
    });

    _model.emailAddressTextController ??= TextEditingController();
    _model.emailAddressFocusNode ??= FocusNode();

    _model.passwordTextController ??= TextEditingController();
    _model.passwordFocusNode ??= FocusNode();

    _model.checkboxValue ??= true; // Por padrão manter conectado ativado
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    FocusScope.of(context).unfocus();

    final email = _model.emailAddressTextController?.text.trim() ?? '';
    final password = _model.passwordTextController?.text.trim() ?? '';

    if (email.isEmpty) {
      safeSetState(() {
        _model.errorMessage = 'Por favor, digite seu usuário ou e-mail.';
      });
      return;
    }

    if (password.isEmpty) {
      safeSetState(() {
        _model.errorMessage = 'Por favor, digite sua senha de acesso.';
      });
      return;
    }

    safeSetState(() {
      _model.isLoading = true;
      _model.errorMessage = null;
    });

    try {
      // 1. Consulta auxiliar de técnico no Firestore (mantendo retrocompatibilidade)
      _model.vERIFICARUSUARIOd = await queryPontosPorTecnicoRecordOnce(
        queryBuilder: (query) => query.where('TECNICO', isEqualTo: email),
        singleRecord: true,
      ).then((s) => s.firstOrNull);

      if (!mounted) return;

      // 2. Tentativa de Login com Firebase Auth
      GoRouter.of(context).prepareAuthEvent();

      final user = await authManager.signInWithEmail(
        context,
        email,
        password,
      );

      if (user != null) {
        if (_model.checkboxValue == true) {
          _model.manterlogado = true;
        }

        // Notificação OneSignal
        await actions.onesignal(
          'hpsrefri@gmail.com',
          '+5577988194630',
          'Email',
          'hpsrefri@gmail.com',
          currentUserUid,
        );

        if (!mounted) return;
        context.goNamedAuth(HomepagenovaWidget.routeName, context.mounted);
        return;
      }

      // 3. Fallback: Se o Firebase Auth não autenticou, verifica tabela de técnicos localmente
      if (_model.vERIFICARUSUARIOd != null &&
          _model.vERIFICARUSUARIOd?.tecnico == email &&
          _model.vERIFICARUSUARIOd?.senha == password) {
        if (_model.checkboxValue == true) {
          _model.manterlogado = true;
        }

        if (!mounted) return;
        context.goNamedAuth(HomePageWidget.routeName, context.mounted);
        return;
      }

      // Se falhou em ambos
      safeSetState(() {
        _model.errorMessage =
            'Credenciais inválidas. Verifique seu usuário e senha.';
      });
    } catch (e) {
      safeSetState(() {
        _model.errorMessage = 'Erro ao conectar: ${e.toString()}';
      });
    } finally {
      if (mounted) {
        safeSetState(() {
          _model.isLoading = false;
        });
      }
    }
  }

  void _showForgotPasswordDialog() {
    final resetEmailController = TextEditingController(
      text: _model.emailAddressTextController?.text.trim() ?? '',
    );
    bool isResetting = false;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1E293B),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
                side: BorderSide(
                  color: Colors.white.withOpacity(0.1),
                  width: 1.0,
                ),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: const Icon(
                      Icons.lock_reset_rounded,
                      color: Color(0xFF60A5FA),
                      size: 22.0,
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  Text(
                    'Redefinir Senha',
                    style: GoogleFonts.interTight(
                      color: Colors.white,
                      fontSize: 18.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Digite seu e-mail cadastrado para receber o link de recuperação de acesso:',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF94A3B8),
                      fontSize: 13.5,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: resetEmailController,
                    style: GoogleFonts.inter(color: Colors.white, fontSize: 14.0),
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: 'exemplo@empresa.com.br',
                      hintStyle: GoogleFonts.inter(color: const Color(0xFF64748B)),
                      prefixIcon: const Icon(
                        Icons.mail_outline_rounded,
                        color: Color(0xFF94A3B8),
                        size: 20.0,
                      ),
                      filled: true,
                      fillColor: const Color(0xFF0F172A),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 14.0,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide(
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: const BorderSide(
                          color: Color(0xFF3B82F6),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              actionsPadding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text(
                    'Cancelar',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF94A3B8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: isResetting
                      ? null
                      : () async {
                          final mail = resetEmailController.text.trim();
                          if (mail.isEmpty) return;

                          setDialogState(() => isResetting = true);
                          try {
                            await FirebaseAuth.instance
                                .sendPasswordResetEmail(email: mail);
                            if (mounted) {
                              Navigator.pop(dialogContext);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'E-mail de recuperação enviado com sucesso!',
                                    style: GoogleFonts.inter(color: Colors.white),
                                  ),
                                  backgroundColor: const Color(0xFF059669),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          } catch (e) {
                            setDialogState(() => isResetting = false);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Não foi possível enviar o e-mail: ${e.toString()}',
                                    style: GoogleFonts.inter(color: Colors.white),
                                  ),
                                  backgroundColor: const Color(0xFFDC2626),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 12.0,
                    ),
                  ),
                  child: isResetting
                      ? const SizedBox(
                          width: 18.0,
                          height: 18.0,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.0,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'Enviar Link',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 950;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: const Color(0xFF0B0F17),
        body: Stack(
          children: [
            // Fundo decorativo moderno com gradientes e ambient glow
            Positioned(
              top: -120.0,
              left: -100.0,
              child: Container(
                width: 480.0,
                height: 480.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF2563EB).withOpacity(0.22),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -150.0,
              right: -100.0,
              child: Container(
                width: 520.0,
                height: 520.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF0D9488).withOpacity(0.18),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Linha sutil de grid/textura de fundo
            Positioned.fill(
              child: Opacity(
                opacity: 0.03,
                child: CustomPaint(
                  painter: _GridBackgroundPainter(),
                ),
              ),
            ),

            // Conteúdo principal responsivo
            SafeArea(
              child: isDesktop
                  ? _buildDesktopLayout(context)
                  : _buildMobileLayout(context),
            ),
          ],
        ),
      ),
    );
  }

  /// Layout em duas colunas para Desktop / Web / Telas largas
  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      children: [
        // Coluna Esquerda: Apresentação da Marca & Recursos
        Expanded(
          flex: 6,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 64.0, vertical: 48.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Topo da Coluna Esquerda: Badge Corporativo
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14.0,
                        vertical: 6.0,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(30.0),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.12),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8.0,
                            height: 8.0,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF10B981),
                            ),
                          ),
                          const SizedBox(width: 8.0),
                          Text(
                            'SISTEMA OPERACIONAL • V1.0',
                            style: GoogleFonts.inter(
                              color: const Color(0xFFCBD5E1),
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Centro da Coluna Esquerda: Logo, Título e Benefícios
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Container com o Logo
                    Container(
                      width: 96.0,
                      height: 96.0,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B).withOpacity(0.7),
                        borderRadius: BorderRadius.circular(24.0),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.15),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF2563EB).withOpacity(0.25),
                            blurRadius: 32.0,
                            spreadRadius: 2.0,
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14.0),
                        child: Image.asset(
                          'assets/images/iconeapp__1_-removebg-preview.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ).animate().fade(duration: 500.ms).scale(
                          begin: const Offset(0.9, 0.9),
                          end: const Offset(1.0, 1.0),
                        ),
                    const SizedBox(height: 32.0),

                    // Título Principal com Gradiente
                    Text(
                      'GESTÃO DE O.S',
                      style: GoogleFonts.interTight(
                        fontSize: 44.0,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1.0,
                        color: Colors.white,
                      ),
                    ).animate().fade(delay: 100.ms, duration: 500.ms).slideX(
                          begin: -0.1,
                          end: 0.0,
                        ),
                    const SizedBox(height: 12.0),

                    Text(
                      'Plataforma completa para controle de ordens de serviço, manutenções preventivas, pontuação técnica e gestão de equipes em campo.',
                      style: GoogleFonts.inter(
                        fontSize: 16.5,
                        color: const Color(0xFF94A3B8),
                        height: 1.5,
                      ),
                    ).animate().fade(delay: 200.ms, duration: 500.ms),
                    const SizedBox(height: 40.0),

                    // Cards informativos de recursos
                    _buildFeatureItem(
                      icon: Icons.checklist_rounded,
                      title: 'Ordens de Serviço em Tempo Real',
                      description:
                          'Acompanhe status, laudos e atualizações operacionais instantâneas.',
                    ).animate().fade(delay: 300.ms, duration: 400.ms),
                    const SizedBox(height: 18.0),
                    _buildFeatureItem(
                      icon: Icons.trending_up_rounded,
                      title: 'Produtividade e Pontos Técnicos',
                      description:
                          'Gestão por desempenho com métricas assertivas para cada técnico.',
                    ).animate().fade(delay: 400.ms, duration: 400.ms),
                    const SizedBox(height: 18.0),
                    _buildFeatureItem(
                      icon: Icons.verified_user_rounded,
                      title: 'Segurança & Sincronização em Nuvem',
                      description:
                          'Dados protegidos com sincronização contínua via Firebase & Supabase.',
                    ).animate().fade(delay: 500.ms, duration: 400.ms),
                  ],
                ),

                // Rodapé da Coluna Esquerda
                Row(
                  children: [
                    const Icon(
                      Icons.shield_outlined,
                      size: 16.0,
                      color: Color(0xFF64748B),
                    ),
                    const SizedBox(width: 8.0),
                    Text(
                      'Ambiente seguro • Criptografia ponta a ponta 256-bit',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF64748B),
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Divisor vertical sutil
        Container(
          width: 1.0,
          color: Colors.white.withOpacity(0.08),
        ),

        // Coluna Direita: Cartão de Autenticação
        Expanded(
          flex: 5,
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 48.0, vertical: 32.0),
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440.0),
                child: _buildAuthCard(context),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Layout para Mobile e Telas Menores
  Widget _buildMobileLayout(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Cabeçalho Mobile com Logo
              Container(
                width: 80.0,
                height: 80.0,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B).withOpacity(0.8),
                  borderRadius: BorderRadius.circular(22.0),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.12),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2563EB).withOpacity(0.3),
                      blurRadius: 28.0,
                      spreadRadius: 1.0,
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Image.asset(
                    'assets/images/iconeapp__1_-removebg-preview.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ).animate().fade(duration: 400.ms).scale(),
              const SizedBox(height: 20.0),

              Text(
                'GESTÃO DE O.S',
                textAlign: TextAlign.center,
                style: GoogleFonts.interTight(
                  fontSize: 28.0,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ).animate().fade(delay: 100.ms, duration: 400.ms),
              const SizedBox(height: 6.0),

              Text(
                'Sistema Integrado de Manutenção e Serviços',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 13.5,
                  color: const Color(0xFF94A3B8),
                ),
              ).animate().fade(delay: 150.ms, duration: 400.ms),
              const SizedBox(height: 28.0),

              // Formulário de Login dentro do Cartão Moderno
              _buildAuthCard(context),

              const SizedBox(height: 24.0),
              // Rodapé Mobile
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.lock_rounded,
                    size: 14.0,
                    color: Color(0xFF64748B),
                  ),
                  const SizedBox(width: 6.0),
                  Text(
                    'Acesso Seguro • HPS Refrigeração',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF64748B),
                      fontSize: 12.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// O Cartão de Autenticação (Comum a ambos os layouts)
  Widget _buildAuthCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF131B2E).withOpacity(0.85),
        borderRadius: BorderRadius.circular(24.0),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 36.0,
            offset: const Offset(0.0, 16.0),
          ),
          BoxShadow(
            color: const Color(0xFF2563EB).withOpacity(0.08),
            blurRadius: 20.0,
            offset: const Offset(0.0, -4.0),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.0),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16.0, sigmaY: 16.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 32.0,
              vertical: 36.0,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Título do Formulário
                Text(
                  'Acessar Plataforma',
                  style: GoogleFonts.interTight(
                    fontSize: 22.0,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6.0),
                Text(
                  'Informe suas credenciais para entrar',
                  style: GoogleFonts.inter(
                    fontSize: 13.5,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
                const SizedBox(height: 24.0),

                // Alerta de Erro (se houver)
                if (_model.errorMessage != null &&
                    _model.errorMessage!.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14.0,
                      vertical: 12.0,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(
                        color: const Color(0xFFEF4444).withOpacity(0.35),
                        width: 1.0,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline_rounded,
                          color: Color(0xFFF87171),
                          size: 20.0,
                        ),
                        const SizedBox(width: 10.0),
                        Expanded(
                          child: Text(
                            _model.errorMessage!,
                            style: GoogleFonts.inter(
                              color: const Color(0xFFFCA5A5),
                              fontSize: 13.0,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            safeSetState(() => _model.errorMessage = null);
                          },
                          child: const Icon(
                            Icons.close_rounded,
                            color: Color(0xFFF87171),
                            size: 18.0,
                          ),
                        ),
                      ],
                    ),
                  ).animate().fade(duration: 250.ms).slideY(
                        begin: -0.1,
                        end: 0.0,
                      ),
                  const SizedBox(height: 20.0),
                ],

                // Campo: Usuário / E-mail
                Text(
                  'USUÁRIO OU E-MAIL',
                  style: GoogleFonts.inter(
                    color: const Color(0xFFCBD5E1),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 8.0),
                TextFormField(
                  controller: _model.emailAddressTextController,
                  focusNode: _model.emailAddressFocusNode,
                  keyboardType: TextInputType.emailAddress,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 14.5,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Digite seu usuário ou e-mail',
                    hintStyle: GoogleFonts.inter(
                      color: const Color(0xFF64748B),
                      fontSize: 14.0,
                    ),
                    prefixIcon: const Icon(
                      Icons.person_outline_rounded,
                      color: Color(0xFF94A3B8),
                      size: 20.0,
                    ),
                    filled: true,
                    fillColor: const Color(0xFF0F172A).withOpacity(0.7),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 16.0,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14.0),
                      borderSide: BorderSide(
                        color: Colors.white.withOpacity(0.1),
                        width: 1.0,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14.0),
                      borderSide: const BorderSide(
                        color: Color(0xFF3B82F6),
                        width: 1.8,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14.0),
                      borderSide: const BorderSide(
                        color: Color(0xFFEF4444),
                        width: 1.0,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20.0),

                // Campo: Senha
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'SENHA',
                      style: GoogleFonts.inter(
                        color: const Color(0xFFCBD5E1),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                      ),
                    ),
                    InkWell(
                      onTap: _showForgotPasswordDialog,
                      child: Text(
                        'Esqueceu a senha?',
                        style: GoogleFonts.inter(
                          color: const Color(0xFF60A5FA),
                          fontSize: 12.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8.0),
                TextFormField(
                  controller: _model.passwordTextController,
                  focusNode: _model.passwordFocusNode,
                  obscureText: !_model.passwordVisibility,
                  onFieldSubmitted: (_) => _handleLogin(),
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 14.5,
                  ),
                  decoration: InputDecoration(
                    hintText: '••••••••',
                    hintStyle: GoogleFonts.inter(
                      color: const Color(0xFF64748B),
                      fontSize: 14.0,
                    ),
                    prefixIcon: const Icon(
                      Icons.lock_outline_rounded,
                      color: Color(0xFF94A3B8),
                      size: 20.0,
                    ),
                    suffixIcon: InkWell(
                      onTap: () {
                        safeSetState(() {
                          _model.passwordVisibility =
                              !_model.passwordVisibility;
                        });
                      },
                      child: Icon(
                        _model.passwordVisibility
                            ? Icons.visibility_rounded
                            : Icons.visibility_off_rounded,
                        color: const Color(0xFF94A3B8),
                        size: 20.0,
                      ),
                    ),
                    filled: true,
                    fillColor: const Color(0xFF0F172A).withOpacity(0.7),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 16.0,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14.0),
                      borderSide: BorderSide(
                        color: Colors.white.withOpacity(0.1),
                        width: 1.0,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14.0),
                      borderSide: const BorderSide(
                        color: Color(0xFF3B82F6),
                        width: 1.8,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14.0),
                      borderSide: const BorderSide(
                        color: Color(0xFFEF4444),
                        width: 1.0,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),

                // Opção: Manter Conectado
                Row(
                  children: [
                    SizedBox(
                      height: 24.0,
                      width: 24.0,
                      child: Checkbox(
                        value: _model.checkboxValue ?? true,
                        activeColor: const Color(0xFF2563EB),
                        checkColor: Colors.white,
                        side: BorderSide(
                          color: Colors.white.withOpacity(0.3),
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        onChanged: (newValue) {
                          safeSetState(() {
                            _model.checkboxValue = newValue;
                            if (newValue == true) {
                              _model.manterlogado = true;
                            }
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 10.0),
                    GestureDetector(
                      onTap: () {
                        safeSetState(() {
                          _model.checkboxValue = !(_model.checkboxValue ?? true);
                        });
                      },
                      child: Text(
                        'Manter conectado neste dispositivo',
                        style: GoogleFonts.inter(
                          color: const Color(0xFF94A3B8),
                          fontSize: 13.0,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 26.0),

                // Botão de Login Principal com Gradiente e Loading State
                Container(
                  height: 50.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14.0),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF2563EB),
                        Color(0xFF1D4ED8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2563EB).withOpacity(0.4),
                        blurRadius: 18.0,
                        offset: const Offset(0.0, 6.0),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14.0),
                      onTap: _model.isLoading ? null : _handleLogin,
                      child: Center(
                        child: _model.isLoading
                            ? const SizedBox(
                                width: 22.0,
                                height: 22.0,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'ENTRAR NO SISTEMA',
                                    style: GoogleFonts.interTight(
                                      color: Colors.white,
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                  const SizedBox(width: 8.0),
                                  const Icon(
                                    Icons.arrow_forward_rounded,
                                    color: Colors.white,
                                    size: 18.0,
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fade(duration: 400.ms).slideY(
          begin: 0.05,
          end: 0.0,
        );
  }

  /// Item de recurso da coluna esquerda
  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42.0,
          height: 42.0,
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B).withOpacity(0.8),
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF60A5FA),
            size: 22.0,
          ),
        ),
        const SizedBox(width: 16.0),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.interTight(
                  color: Colors.white,
                  fontSize: 15.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 3.0),
              Text(
                description,
                style: GoogleFonts.inter(
                  color: const Color(0xFF94A3B8),
                  fontSize: 13.0,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Pintor customizado para uma textura de grade ultra sutil no fundo
class _GridBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.0;

    const step = 48.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
