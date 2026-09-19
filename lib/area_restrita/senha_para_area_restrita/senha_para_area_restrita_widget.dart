import '/components/escolha_novo_custom_widget.dart';
import '/custom_code/widgets/hps_sheet.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'senha_para_area_restrita_model.dart';
export 'senha_para_area_restrita_model.dart';

class SenhaParaAreaRestritaWidget extends StatefulWidget {
  const SenhaParaAreaRestritaWidget({super.key});

  @override
  State<SenhaParaAreaRestritaWidget> createState() =>
      _SenhaParaAreaRestritaWidgetState();
}

class _SenhaParaAreaRestritaWidgetState
    extends State<SenhaParaAreaRestritaWidget> {
  late SenhaParaAreaRestritaModel _model;
  String? _errorMessage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SenhaParaAreaRestritaModel());

    _model.textFielSENHAPONTOSetsatTextController ??= TextEditingController();
    _model.textFielSENHAPONTOSetsatFocusNode ??= FocusNode();

    _model.textFielSENHAPONTOSTextController ??= TextEditingController();
    _model.textFielSENHAPONTOSFocusNode ??= FocusNode();

    _model.textFielSENHAPONTOSetsatVisibility = false;
  }

  @override
  void dispose() {
    _model.maybeDispose();
    super.dispose();
  }

  Future<void> _verificarSenha() async {
    final senha =
        _model.textFielSENHAPONTOSetsatTextController?.text.trim() ?? '';

    if (senha.isEmpty) {
      setState(() {
        _errorMessage = 'Digite a senha de segurança para continuar.';
      });
      return;
    }

    if (senha != '260393') {
      setState(() {
        _errorMessage = 'Senha incorreta. Acesso não autorizado.';
        _model.textFielSENHAPONTOSetsatTextController?.clear();
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final navigator = Navigator.of(context);
      navigator.pop();
      await Future<void>.delayed(Duration.zero);
      if (!navigator.mounted) return;
      await showHpsSheet(
        navigator.context,
        showClose: false,
        child: const EscolhaNovoCustomWidget(),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final textPrimary = isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
    final textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final inputBg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);

    final screenWidth = MediaQuery.sizeOf(context).width;
    final cardWidth = screenWidth < 500 ? (screenWidth - 32) : 420.0;

    return Center(
      child: SingleChildScrollView(
        child: Container(
          width: cardWidth,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withOpacity(0.5)
                    : const Color(0xFF0F172A).withOpacity(0.12),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                // Detalhe superior em gradiente carmim de segurança
                Container(
                  height: 4,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFB91C1C), Color(0xFFB91C1C)],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Ícone de Escudo com Ambient Glow
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: const Color(0xFFB91C1C).withOpacity(0.12),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFB91C1C).withOpacity(0.3),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFB91C1C).withOpacity(0.2),
                              blurRadius: 16,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.admin_panel_settings_rounded,
                            color: Color(0xFFB91C1C),
                            size: 32,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Área Restrita',
                        style: GoogleFonts.interTight(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: textPrimary,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Digite a senha de administrador para acessar o painel de configurações do sistema.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: textSecondary,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Banner de erro integrado
                      if (_errorMessage != null) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFB91C1C).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xFFB91C1C).withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.error_outline_rounded,
                                color: Color(0xFFB91C1C),
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFFB91C1C),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      // Campo de Senha Moderno
                      Container(
                        decoration: BoxDecoration(
                          color: inputBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: borderColor),
                        ),
                        child: TextField(
                          controller:
                              _model.textFielSENHAPONTOSetsatTextController,
                          focusNode: _model.textFielSENHAPONTOSetsatFocusNode,
                          autofocus: true,
                          obscureText:
                              !_model.textFielSENHAPONTOSetsatVisibility,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 4,
                            color: textPrimary,
                          ),
                          onSubmitted: (_) => _verificarSenha(),
                          decoration: InputDecoration(
                            hintText: '••••••',
                            hintStyle: GoogleFonts.inter(
                              fontSize: 16,
                              letterSpacing: 4,
                              color: textSecondary.withOpacity(0.6),
                            ),
                            prefixIcon: Icon(
                              Icons.lock_outline_rounded,
                              color: textSecondary,
                              size: 20,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _model.textFielSENHAPONTOSetsatVisibility
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: textSecondary,
                                size: 20,
                              ),
                              onPressed: () {
                                setState(() {
                                  _model.textFielSENHAPONTOSetsatVisibility =
                                      !_model
                                          .textFielSENHAPONTOSetsatVisibility;
                                });
                              },
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Botão Entrar com Gradiente
                      SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _verificarSenha,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFB91C1C),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: EdgeInsets.zero,
                          ),
                          child: Ink(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFB91C1C), Color(0xFFB91C1C)],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      const Color(0xFFB91C1C).withOpacity(0.35),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Center(
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.lock_open_rounded,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'AUTENTICAR',
                                          style: GoogleFonts.interTight(
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Botão Cancelar
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          foregroundColor: textSecondary,
                          minimumSize: const Size(double.infinity, 38),
                        ),
                        child: Text(
                          'Cancelar',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
