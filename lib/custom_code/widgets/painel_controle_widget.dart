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

import '/auth/firebase_auth/auth_util.dart';
import '/components/add_tecnico_widget.dart';
import '/components/adicionarservico_widget.dart';
import '/components/cadastrar_equipamento_customwidget_widget.dart';
import '/components/cadastrar_novo_sem_erro_widget.dart';
import '/components/editar_preventiva_widget.dart';
import '/components/email_nova_widget.dart';
import '/components/email_novo_widget.dart';
import '/components/equipamento_dropdown_widget.dart';
import '/components/imagens_widget.dart';
import '/components/listar_permissao_widget.dart';
import '/components/os_custom_e_x_c_l_u_i_r_widget.dart';
import '/components/pdf_que_falta_widget.dart';
import '/components/preventivas_penden_widget.dart';
import '/components/relatorio_financeiro_widget.dart';
import '/components/resetar_senha_widget.dart';
import '/components/teste_preventivas_widget.dart';
import '/components/usuario_novo_widget.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:async';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import '/index.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class PainelControleWidget extends StatefulWidget {
  const PainelControleWidget({
    super.key,
    this.width,
    this.height,
  });

  final double? width;
  final double? height;

  @override
  State<PainelControleWidget> createState() => _PainelControleWidgetState();
}

class _PainelControleWidgetState extends State<PainelControleWidget> {
  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return Container(
      decoration: const BoxDecoration(color: Colors.transparent),
      child: Align(
        alignment: AlignmentDirectional.center,
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(0, 20, 0, 20),
          child: Container(
            decoration: BoxDecoration(
              color: theme.secondaryBackground,
              boxShadow: const [
                BoxShadow(
                  blurRadius: 24,
                  color: Color(0x1A000000),
                  offset: Offset(0, 4),
                  spreadRadius: 0,
                )
              ],
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Header ──────────────────────────────────────────────
                _buildHeader(context, theme),

                // ── Divider ─────────────────────────────────────────────
                Divider(height: 1, thickness: 1, color: theme.alternate),

                // ── Scrollable body ──────────────────────────────────────
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // ── Seção: Ações críticas (destaque) ────────────
                        _sectionLabel(context, theme, 'Ações Críticas',
                            Icons.warning_amber_rounded, theme.error),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            // Apagar O.S.
                            Expanded(
                              child: _dangerCard(
                                context: context,
                                theme: theme,
                                icon: Icons.delete_outline,
                                label: 'Apagar O.S.',
                                subtitle: 'Remove todas as OS',
                                onTap: () async {
                                  final ok = await showDialog<bool>(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          title: const Text('ATENÇÃO!'),
                                          content: const Text(
                                              'Deseja apagar todas as ordens de serviço?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(ctx, false),
                                              child: const Text('Cancelar'),
                                            ),
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(ctx, true),
                                              child: const Text('Confirmar'),
                                            ),
                                          ],
                                        ),
                                      ) ??
                                      false;
                                  if (ok) {
                                    await actions.apagadocumentos();
                                    await showDialog(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: const Text('ATENÇÃO!'),
                                        content: const Text(
                                            'Todas o.s foram apagadas'),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(ctx),
                                            child: const Text('Ok'),
                                          ),
                                        ],
                                      ),
                                    );
                                    Navigator.pop(context);
                                  }
                                },
                              ),
                            ),
                            SizedBox(width: 10),
                            // Excluir Ordem
                            Expanded(
                              child: _actionCard(
                                context: context,
                                theme: theme,
                                icon: Icons.delete_forever_rounded,
                                iconColor: theme.primary,
                                label: 'Excluir Ordem',
                                subtitle: 'Excluir OS',
                                onTap: () async {
                                  await showModalBottomSheet(
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    enableDrag: true,
                                    isDismissible: true,
                                    useSafeArea: true,
                                    context: context,
                                    builder: (ctx) => Padding(
                                      padding: MediaQuery.viewInsetsOf(context),
                                      child: const OsCustomEXCLUIRWidget(
                                          status: ''),
                                    ),
                                  ).then((_) => safeSetState(() {}));
                                },
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 20),

                        // ── Seção: Usuários & Acesso ─────────────────────
                        _sectionLabel(context, theme, 'Usuários & Acesso',
                            Icons.manage_accounts_rounded, theme.secondary),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            // Resetar senha
                            Expanded(
                              child: _actionCard(
                                context: context,
                                theme: theme,
                                icon: Icons.password_rounded,
                                iconColor: theme.secondary,
                                label: 'Resetar Senha',
                                subtitle: 'Redefinir acesso',
                                onTap: () async {
                                  await showModalBottomSheet(
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    enableDrag: true,
                                    isDismissible: true,
                                    useSafeArea: true,
                                    context: context,
                                    builder: (ctx) => Padding(
                                      padding: MediaQuery.viewInsetsOf(context),
                                      child: const ResetarSenhaWidget(),
                                    ),
                                  ).then((_) => safeSetState(() {}));
                                  Navigator.pop(context);
                                },
                              ),
                            ),
                            SizedBox(width: 10),
                            // Adicionar Técnico
                            Expanded(
                              child: _actionCard(
                                context: context,
                                theme: theme,
                                icon: Icons.person_add_outlined,
                                iconColor: theme.secondary,
                                label: 'Adicionar Técnico',
                                subtitle: 'Novo técnico',
                                onTap: () async {
                                  await showModalBottomSheet(
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    enableDrag: true,
                                    isDismissible: true,
                                    useSafeArea: true,
                                    context: context,
                                    builder: (ctx) => Padding(
                                      padding: MediaQuery.viewInsetsOf(context),
                                      child: const AddTecnicoWidget(),
                                    ),
                                  ).then((_) => safeSetState(() {}));
                                  Navigator.pop(context);
                                },
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            // Cadastrar/Editar Usuário
                            Expanded(
                              child: _actionCard(
                                context: context,
                                theme: theme,
                                icon: Icons.person,
                                iconColor: theme.accent2,
                                label: 'Cadastrar/Editar Usuário',
                                subtitle: 'Cadastrar novo',
                                onTap: () async {
                                  await showModalBottomSheet(
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    enableDrag: true,
                                    isDismissible: true,
                                    useSafeArea: true,
                                    context: context,
                                    builder: (ctx) => Padding(
                                      padding: MediaQuery.viewInsetsOf(context),
                                      child: const UsuarioNovoWidget(),
                                    ),
                                  ).then((_) => safeSetState(() {}));
                                },
                              ),
                            ),
                            SizedBox(width: 10),
                            // Liberar Financeiro
                            Expanded(
                              child: _actionCard(
                                context: context,
                                theme: theme,
                                icon: Icons.account_balance_outlined,
                                iconColor: theme.primary,
                                label: 'Liberar Financeiro',
                                subtitle: 'Permissão financeiro',
                                onTap: () async {
                                  await showModalBottomSheet(
                                    isScrollControlled: true,
                                    backgroundColor: theme.primaryText,
                                    enableDrag: true,
                                    isDismissible: true,
                                    useSafeArea: true,
                                    context: context,
                                    builder: (ctx) => Padding(
                                      padding: MediaQuery.viewInsetsOf(context),
                                      child: const ListarPermissaoWidget(),
                                    ),
                                  ).then((_) => safeSetState(() {}));
                                  Navigator.pop(context);
                                },
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 20),

                        // ── Seção: Ordens de Serviço ─────────────────────
                        _sectionLabel(context, theme, 'Ordens de Serviço',
                            Icons.receipt_long_rounded, theme.primary),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            // Nova Ordem
                            Expanded(
                              child: _actionCard(
                                context: context,
                                theme: theme,
                                icon: Icons.add_circle_outline,
                                iconColor: theme.primary,
                                label: 'Nova Ordem',
                                subtitle: 'Criar nova OS',
                                onTap: () async {
                                  await showModalBottomSheet(
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    enableDrag: true,
                                    isDismissible: true,
                                    useSafeArea: true,
                                    context: context,
                                    builder: (ctx) => Padding(
                                      padding: MediaQuery.viewInsetsOf(context),
                                      child: const CadastrarNovoSemErroWidget(),
                                    ),
                                  ).then((_) => safeSetState(() {}));
                                },
                              ),
                            ),
                            SizedBox(width: 10),
                            // Zerar Pontuação
                            Expanded(
                              child: _actionCard(
                                context: context,
                                theme: theme,
                                icon: Icons.stars_rounded,
                                iconColor: theme.tertiary,
                                label: 'Zerar Pontuação',
                                subtitle: 'Reset de pontos',
                                onTap: () async {
                                  await showModalBottomSheet(
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    enableDrag: true,
                                    isDismissible: true,
                                    useSafeArea: true,
                                    context: context,
                                    builder: (ctx) => Padding(
                                      padding: MediaQuery.viewInsetsOf(context),
                                      child: const EditarPreventivaWidget(),
                                    ),
                                  ).then((_) => safeSetState(() {}));
                                  Navigator.pop(context);
                                },
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 20),

                        // ── Seção: Preventivas ───────────────────────────
                        _sectionLabel(context, theme, 'Preventivas',
                            Icons.domain_verification_rounded, theme.accent2),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            // Preventiva - Cadastrar nova
                            Expanded(
                              child: _actionCard(
                                context: context,
                                theme: theme,
                                icon: Icons.list_alt_rounded,
                                iconColor: theme.accent2,
                                label: 'Preventiva',
                                subtitle: 'Cadastrar nova',
                                onTap: () async {
                                  await showModalBottomSheet(
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    enableDrag: true,
                                    isDismissible: true,
                                    useSafeArea: true,
                                    context: context,
                                    builder: (ctx) => Padding(
                                      padding: MediaQuery.viewInsetsOf(context),
                                      child: const TestePreventivasWidget(),
                                    ),
                                  ).then((_) => safeSetState(() {}));
                                },
                              ),
                            ),
                            SizedBox(width: 10),
                            // Verificar preventivas
                            Expanded(
                              child: _actionCard(
                                context: context,
                                theme: theme,
                                icon: Icons.domain_verification_rounded,
                                iconColor: theme.error,
                                label: 'Verificar Preventivas',
                                subtitle: 'Preventivas pendentes',
                                onTap: () async {
                                  await showModalBottomSheet(
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    enableDrag: true,
                                    isDismissible: true,
                                    useSafeArea: true,
                                    context: context,
                                    builder: (ctx) => Padding(
                                      padding: MediaQuery.viewInsetsOf(context),
                                      child: const PreventivasPendenWidget(),
                                    ),
                                  ).then((_) => safeSetState(() {}));
                                },
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 20),

                        // ── Seção: Cadastros ─────────────────────────────
                        _sectionLabel(context, theme, 'Cadastros',
                            Icons.inventory_2_rounded, theme.success),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            // Cadastrar Serviços
                            Expanded(
                              child: _actionCard(
                                context: context,
                                theme: theme,
                                icon: Icons.add_business_outlined,
                                iconColor: theme.success,
                                label: 'Cadastrar Serviços',
                                subtitle: 'Serviços e pontos',
                                onTap: () async {
                                  await showModalBottomSheet(
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    enableDrag: true,
                                    isDismissible: true,
                                    useSafeArea: true,
                                    context: context,
                                    builder: (ctx) => Padding(
                                      padding: MediaQuery.viewInsetsOf(context),
                                      child: const AdicionarservicoWidget(),
                                    ),
                                  ).then((_) => safeSetState(() {}));
                                  Navigator.pop(context);
                                },
                              ),
                            ),
                            SizedBox(width: 10),
                            // Cadastrar nome Equipamento (dropdown)
                            Expanded(
                              child: _actionCard(
                                context: context,
                                theme: theme,
                                icon: Icons.new_label,
                                iconColor: theme.success,
                                label: 'Nome Equipamento',
                                subtitle: 'Cadastrar dropdown',
                                onTap: () async {
                                  await showModalBottomSheet(
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    enableDrag: true,
                                    isDismissible: true,
                                    useSafeArea: true,
                                    context: context,
                                    builder: (ctx) => Padding(
                                      padding: MediaQuery.viewInsetsOf(context),
                                      child: const EquipamentoDropdownWidget(),
                                    ),
                                  ).then((_) => safeSetState(() {}));
                                  Navigator.pop(context);
                                },
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        // Cadastrar/Editar/Excluir Equipamento
                        _actionCardWide(
                          context: context,
                          theme: theme,
                          icon: Icons.assessment,
                          iconColor: const Color(0xFFFF5F00),
                          label: 'Cadastrar / Editar / Excluir Equipamento',
                          subtitle: 'Gerenciar equipamentos',
                          onTap: () async {
                            await showModalBottomSheet(
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              enableDrag: true,
                              isDismissible: true,
                              useSafeArea: true,
                              context: context,
                              builder: (ctx) => Padding(
                                padding: MediaQuery.viewInsetsOf(context),
                                child:
                                    const CadastrarEquipamentoCustomwidgetWidget(),
                              ),
                            ).then((_) => safeSetState(() {}));
                          },
                        ),

                        SizedBox(height: 20),

                        // ── Seção: Relatórios & Financeiro ───────────────
                        _sectionLabel(context, theme, 'Relatórios & Financeiro',
                            Icons.bar_chart_rounded, theme.success),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            // Relatório financeiro
                            Expanded(
                              child: _actionCard(
                                context: context,
                                theme: theme,
                                icon: Icons.account_balance_rounded,
                                iconColor: theme.success,
                                label: 'Relatório Financeiro',
                                subtitle: 'Ver relatório',
                                onTap: () async {
                                  await showModalBottomSheet(
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    enableDrag: true,
                                    isDismissible: true,
                                    useSafeArea: true,
                                    context: context,
                                    builder: (ctx) => Padding(
                                      padding: MediaQuery.viewInsetsOf(context),
                                      child: const RelatorioFinanceiroWidget(),
                                    ),
                                  ).then((_) => safeSetState(() {}));
                                  Navigator.pop(context);
                                },
                              ),
                            ),
                            SizedBox(width: 10),
                            // Confirmar PDF
                            Expanded(
                              child: _actionCard(
                                context: context,
                                theme: theme,
                                icon: Icons.picture_as_pdf_rounded,
                                iconColor: theme.success,
                                label: 'Confirmar PDF',
                                subtitle: 'Verificar PDFs',
                                onTap: () async {
                                  await showModalBottomSheet(
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    enableDrag: true,
                                    isDismissible: true,
                                    useSafeArea: true,
                                    context: context,
                                    builder: (ctx) => Padding(
                                      padding: MediaQuery.viewInsetsOf(context),
                                      child: const PdfQueFaltaWidget(),
                                    ),
                                  ).then((_) => safeSetState(() {}));
                                },
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 20),

                        // ── Seção: Comunicação ───────────────────────────
                        _sectionLabel(context, theme, 'Comunicação',
                            Icons.email_rounded, const Color(0xCF39D2C0)),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            // Enviar notificação
                            Expanded(
                              child: _actionCard(
                                context: context,
                                theme: theme,
                                icon: Icons.email_rounded,
                                iconColor: const Color(0xCF39D2C0),
                                label: 'Enviar Notificação',
                                subtitle: 'Aviso sala indisponível',
                                onTap: () async {
                                  await showModalBottomSheet(
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    enableDrag: true,
                                    isDismissible: true,
                                    useSafeArea: true,
                                    context: context,
                                    builder: (ctx) => Padding(
                                      padding: MediaQuery.viewInsetsOf(context),
                                      child: const EmailNovoWidget(),
                                    ),
                                  ).then((_) => safeSetState(() {}));
                                },
                              ),
                            ),
                            SizedBox(width: 10),
                            // Enviar Relatório
                            Expanded(
                              child: _actionCard(
                                context: context,
                                theme: theme,
                                icon: Icons.list,
                                iconColor: const Color(0xCF39D2C0),
                                label: 'Enviar Relatório',
                                subtitle: 'Enviar relatórios completo',
                                onTap: () async {
                                  await showModalBottomSheet(
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    enableDrag: true,
                                    isDismissible: true,
                                    useSafeArea: true,
                                    context: context,
                                    builder: (ctx) => Padding(
                                      padding: MediaQuery.viewInsetsOf(context),
                                      child: const EmailNovaWidget(),
                                    ),
                                  ).then((_) => safeSetState(() {}));
                                },
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 20),

                        // ── Seção: Imagens ───────────────────────────────
                        _sectionLabel(context, theme, 'Imagens',
                            Icons.image_search, theme.primary),
                        SizedBox(height: 10),
                        // Verificar imagens
                        _actionCardWide(
                          context: context,
                          theme: theme,
                          icon: Icons.image_search,
                          iconColor: theme.primary,
                          label: 'Verificar Imagens',
                          subtitle: 'Adicionar / verificar / excluir',
                          onTap: () async {
                            await showModalBottomSheet(
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              enableDrag: true,
                              isDismissible: true,
                              useSafeArea: true,
                              context: context,
                              builder: (ctx) => Padding(
                                padding: MediaQuery.viewInsetsOf(context),
                                child: const ImagensWidget(),
                              ),
                            ).then((_) => safeSetState(() {}));
                          },
                        ),

                        // Buscar OS (visível apenas para email específico)
                        if (currentUserEmail == 'MIHUGYFCXZGZH GHJKJL') ...[
                          SizedBox(height: 10),
                          _actionCardWide(
                            context: context,
                            theme: theme,
                            icon: Icons.search,
                            iconColor: theme.tertiary,
                            label: 'Buscar OS',
                            subtitle: 'Localizar ordem',
                            onTap: () {},
                          ),
                        ],

                        SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context, FlutterFlowTheme theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 8, 16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [theme.primary, theme.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.dashboard_customize_rounded,
                color: Colors.white, size: 24),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Painel de Controle',
                  style: GoogleFonts.interTight(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: theme.primaryText,
                  ),
                ),
                Text(
                  'Gerencie ordens de serviço e configurações',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: theme.secondaryText,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.close_rounded, color: theme.secondaryText),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  // ── Section label ───────────────────────────────────────────────────────────

  Widget _sectionLabel(BuildContext context, FlutterFlowTheme theme,
      String label, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        SizedBox(width: 6),
        Text(
          label.toUpperCase(),
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: color,
            letterSpacing: 0.8,
          ),
        ),
        SizedBox(width: 8),
        Expanded(child: Divider(color: color.withOpacity(0.25), thickness: 1)),
      ],
    );
  }

  // ── Card normal (half width) ────────────────────────────────────────────────

  Widget _actionCard({
    required BuildContext context,
    required FlutterFlowTheme theme,
    required IconData icon,
    required Color iconColor,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: theme.primaryBackground,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: theme.alternate, width: 1),
          boxShadow: [
            BoxShadow(
              blurRadius: 6,
              color: Colors.black.withOpacity(0.04),
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.interTight(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: theme.primaryText,
              ),
            ),
            SizedBox(height: 2),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 10,
                color: theme.secondaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Card full width ─────────────────────────────────────────────────────────

  Widget _actionCardWide({
    required BuildContext context,
    required FlutterFlowTheme theme,
    required IconData icon,
    required Color iconColor,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: theme.primaryBackground,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: theme.alternate, width: 1),
          boxShadow: [
            BoxShadow(
              blurRadius: 6,
              color: Colors.black.withOpacity(0.04),
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.interTight(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: theme.primaryText,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: theme.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: theme.secondaryText, size: 20),
          ],
        ),
      ),
    );
  }

  // ── Danger card (vermelho destaque) ─────────────────────────────────────────

  Widget _dangerCard({
    required BuildContext context,
    required FlutterFlowTheme theme,
    required IconData icon,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: theme.error.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: theme.error.withOpacity(0.3), width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: theme.error.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: theme.error, size: 22),
            ),
            SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.interTight(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: theme.error,
              ),
            ),
            SizedBox(height: 2),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 10,
                color: theme.error.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
