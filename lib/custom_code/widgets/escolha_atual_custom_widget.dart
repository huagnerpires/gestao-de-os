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

import '/custom_code/actions/index.dart' as actions;
import '/components/resetar_senha_widget.dart';
import '/components/add_tecnico_widget.dart';
import '/components/adicionarservico_widget.dart';
import '/components/equipamento_dropdown_widget.dart';
import '/components/relatorio_financeiro_widget.dart';
import '/components/pdf_que_falta_widget.dart';
import '/components/cadastrar_novo_sem_erro_widget.dart';
import '/components/teste_preventivas_widget.dart';
import '/components/cadastrar_equipamento_customwidget_widget.dart';
import '/components/usuario_novo_widget.dart';
import '/components/gerenciar_tecnicos_sheet_widget.dart';
import '/components/email_novo_widget.dart';
import '/components/email_nova_widget.dart';
import '/components/preventivas_penden_widget.dart';
import '/components/imagens_widget.dart';
import '/components/editar_preventiva_widget.dart';
import '/components/enviar_notas_widget.dart';
import '/components/formulario_widget.dart';
import '/components/os_custom_e_x_c_l_u_i_r_widget.dart';
import '/index.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';

// ─────────────────────────────────────────────────────────────────────────────
// DESIGN TOKENS
// ─────────────────────────────────────────────────────────────────────────────
class _T {
  static Color surface(BuildContext ctx) => HpsUi.surface;
  static Color border(BuildContext ctx) => Colors.white.withOpacity(0.10);
  static Color textPrimary(BuildContext ctx) => HpsUi.textPrimary;
  static Color textSecondary(BuildContext ctx) => HpsUi.textSecondary;
  static Color textMuted(BuildContext ctx) => HpsUi.textMuted;

  static const teal = HpsUi.success;
  static const indigo = HpsUi.accent;
  static const amber = Color(0xFFB45309);
  static const rose = Color(0xFF9F1239);
  static const sage = Color(0xFF047857);
  static const sky = Color(0xFF1D4ED8);
  static const lilac = Color(0xFF3730A3);
  static const coral = Color(0xFFC2410C);
  static const danger = HpsUi.error;
  static const warn = Color(0xFFB45309);

  static Color iconBg(BuildContext ctx, Color c) => c.withOpacity(0.18);
}

// ─────────────────────────────────────────────────────────────────────────────
// MODELO
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

/// ─────────────────────────────────────────────────────────────────────────────
/// WIDGET
/// ─────────────────────────────────────────────────────────────────────────────
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
    await showHpsSheet(context, child: child);
  }

  Future<void> _sheetFin(Widget child) async {
    await showHpsSheet(
      context,
      child: child,
      initialChildSize: 0.97,
      maxChildSize: 0.97,
    );
  }

  Future<bool> _confirm(String title, String msg) async {
    final res = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _T.surface(context),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: _T.border(context), width: 0.5)),
        title: Row(children: [
          Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                  color: _T.iconBg(context, _T.danger),
                  borderRadius: BorderRadius.circular(8)),
              child: Icon(Icons.warning_amber_rounded,
                  color: _T.danger, size: 17)),
          const SizedBox(width: 10),
          Expanded(
              child: Text(title,
                  style: TextStyle(
                      color: _T.textPrimary(context),
                      fontWeight: FontWeight.w600,
                      fontSize: 14))),
        ]),
        content: Text(msg,
            style: TextStyle(
                color: _T.textSecondary(context), fontSize: 13, height: 1.5)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text('Cancelar',
                  style: TextStyle(
                      color: _T.textSecondary(context), fontSize: 13))),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Confirmar',
                style: TextStyle(
                    color: _T.danger,
                    fontWeight: FontWeight.w600,
                    fontSize: 13)),
          ),
        ],
      ),
    );
    return res ?? false;
  }

  void _snack(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        Container(
            width: 3,
            height: 14,
            decoration: BoxDecoration(
                color: color, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 10),
        Expanded(
            child: Text(msg,
                style:
                    TextStyle(color: _T.textPrimary(context), fontSize: 13))),
      ]),
      backgroundColor: _T.surface(context),
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: _T.border(context), width: 0.5)),
      duration: const Duration(seconds: 3),
    ));
  }

  List<_PanelItem> get _items => [
        _PanelItem(
            label: 'Apagar todas O.S',
            subtitle: 'Ação irreversível',
            icon: Icons.delete_forever_rounded,
            color: _T.danger,
            section: 'Perigo',
            action: (ctx) async {
              final ok = await _confirm(
                  'Atenção', 'Deseja apagar TODAS as ordens de serviço?');
              if (!ok) return;
              await actions.apagadocumentos();
              if (!mounted) return;
              Navigator.pop(context);
              _snack('Todas as O.S foram apagadas', _T.danger);
            }),
        _PanelItem(
            label: 'Zerar Pontuação',
            subtitle: 'Todos os técnicos',
            icon: Icons.refresh_rounded,
            color: _T.warn,
            section: 'Perigo',
            action: (ctx) async {
              final ok = await _confirm('Atenção', 'Deseja zerar a pontuação?');
              if (!ok) return;
              await actions.zerapontos();
              if (!mounted) return;
              Navigator.pop(context);
              _snack('Pontuação zerada', _T.warn);
            }),
        _PanelItem(
            label: 'Resetar Senha',
            subtitle: 'Redefinir acesso',
            icon: Icons.lock_reset_rounded,
            color: _T.sky,
            section: 'Usuários',
            action: (ctx) async {
              await _sheet(ResetarSenhaWidget());
              if (!mounted) return;
              Navigator.pop(context);
            }),
        _PanelItem(
            label: 'Adicionar Técnico',
            subtitle: 'Novo técnico',
            icon: Icons.person_add_outlined,
            color: _T.sky,
            section: 'Usuários',
            action: (ctx) async {
              await _sheet(AddTecnicoWidget());
              if (!mounted) return;
              Navigator.pop(context);
            }),
        _PanelItem(
            label: 'Gerenciar Técnicos',
            subtitle: 'Listar, editar, fotos e excluir',
            icon: Icons.engineering_rounded,
            color: _T.sky,
            section: 'Usuários',
            action: (ctx) async {
              await _sheet(GerenciarTecnicosSheetWidget());
            }),
        _PanelItem(
            label: 'Cad./Editar Usuário',
            subtitle: 'Gerenciar usuários',
            icon: Icons.manage_accounts_rounded,
            color: _T.sky,
            section: 'Usuários',
            action: (ctx) async {
              await _sheet(UsuarioNovoWidget());
            }),
        _PanelItem(
            label: 'Gerenciar Acesso',
            subtitle: 'Permissões',
            icon: Icons.admin_panel_settings_rounded,
            color: _T.indigo,
            section: 'Usuários',
            action: (ctx) async {
              await _sheet(GerenciarAcesso(
                  width: double.infinity, height: double.infinity));
              if (!mounted) return;
              Navigator.pop(context);
            }),
        _PanelItem(
            label: 'Nova O.S',
            subtitle: 'Criar ordem',
            icon: Icons.add_circle_outline_rounded,
            color: _T.teal,
            section: 'O.S',
            action: (ctx) async {
              await _sheet(CadastrarNovoSemErroWidget());
            }),
        _PanelItem(
            label: 'Excluir O.S',
            subtitle: 'Remover ordem',
            icon: Icons.delete_outline_rounded,
            color: _T.rose,
            section: 'O.S',
            action: (ctx) async {
              await _sheet(OsCustomEXCLUIRWidget(status: ''));
            }),
        _PanelItem(
            label: 'Enviar Notas',
            subtitle: 'Notas fiscais',
            icon: Icons.description_outlined,
            color: _T.sage,
            section: 'O.S',
            action: (ctx) async {
              await _sheet(EnviarNotasWidget());
            }),
        _PanelItem(
            label: 'Formulário',
            subtitle: 'Preencher',
            icon: Icons.format_align_left_rounded,
            color: _T.sage,
            section: 'O.S',
            action: (ctx) async {
              await _sheet(FormularioWidget());
            }),
        _PanelItem(
            label: 'Preventiva',
            subtitle: 'Cadastrar nova',
            icon: Icons.list_alt_rounded,
            color: _T.teal,
            section: 'Preventivas',
            action: (ctx) async {
              await _sheet(TestePreventivasWidget());
            }),
        _PanelItem(
            label: 'Pendentes',
            subtitle: 'Ver pendências',
            icon: Icons.pending_actions_rounded,
            color: _T.amber,
            section: 'Preventivas',
            action: (ctx) async {
              await _sheet(PreventivasPendenWidget());
            }),
        _PanelItem(
            label: 'Editar Preventiva',
            subtitle: 'Alterar existente',
            icon: Icons.edit_note_rounded,
            color: _T.teal,
            section: 'Preventivas',
            action: (ctx) async {
              await _sheet(EditarPreventivaWidget());
            }),
        _PanelItem(
            label: 'Verificar',
            subtitle: 'Checar pendências',
            icon: Icons.domain_verification_rounded,
            color: _T.indigo,
            section: 'Preventivas',
            action: (ctx) async {
              await _sheet(PreventivasPendenWidget());
            }),
        _PanelItem(
            label: 'Cad./Editar Equip.',
            subtitle: 'Gerenciar',
            icon: Icons.precision_manufacturing_outlined,
            color: _T.amber,
            section: 'Equipamentos',
            action: (ctx) async {
              await _sheet(CadastrarEquipamentoCustomwidgetWidget());
            }),
        _PanelItem(
            label: 'Nome Equipamento',
            subtitle: 'Cadastrar nome',
            icon: Icons.label_outline_rounded,
            color: _T.amber,
            section: 'Equipamentos',
            action: (ctx) async {
              await _sheet(EquipamentoDropdownWidget());
              if (!mounted) return;
              Navigator.pop(context);
            }),
        _PanelItem(
            label: 'Verificar Imagens',
            subtitle: 'Adicionar / excluir',
            icon: Icons.image_search_rounded,
            color: _T.sky,
            section: 'Equipamentos',
            action: (ctx) async {
              await _sheet(ImagensWidget());
            }),
        _PanelItem(
            label: 'Rel. Equipamentos',
            subtitle: 'Contratos e PDFs',
            icon: Icons.picture_as_pdf_rounded,
            color: _T.coral,
            section: 'Equipamentos',
            action: (ctx) async {
              await _sheet(RelatorioEquipamentosWidget());
            }),
        _PanelItem(
            label: 'Cad. Serviços',
            subtitle: 'Serviços e pontos',
            icon: Icons.add_business_outlined,
            color: _T.indigo,
            section: 'Serviços',
            action: (ctx) async {
              await _sheet(AdicionarservicoWidget());
              if (!mounted) return;
              Navigator.pop(context);
            }),
        _PanelItem(
            label: 'Rel. Financeiro',
            subtitle: 'Ver relatório',
            icon: Icons.account_balance_rounded,
            color: _T.teal,
            section: 'Serviços',
            action: (ctx) async {
              await _sheet(RelatorioFinanceiroWidget());
              if (!mounted) return;
              Navigator.pop(context);
            }),
        _PanelItem(
            label: 'Confirmar PDF',
            subtitle: 'PDFs pendentes',
            icon: Icons.task_rounded,
            color: _T.sage,
            section: 'Serviços',
            action: (ctx) async {
              await _sheet(PdfQueFaltaWidget());
            }),
        _PanelItem(
            label: 'Notificação',
            subtitle: 'Notificar usuários',
            icon: Icons.notifications_active_outlined,
            color: _T.lilac,
            section: 'Serviços',
            action: (ctx) async {
              await _sheet(EmailNovoWidget());
              if (!mounted) return;
              Navigator.pop(context);
            }),
        _PanelItem(
            label: 'Enviar Relatório',
            subtitle: 'Relatório por e-mail',
            icon: Icons.send_rounded,
            color: _T.lilac,
            section: 'Serviços',
            action: (ctx) async {
              await _sheet(EmailNovaWidget());
              if (!mounted) return;
              Navigator.pop(context);
            }),
        _PanelItem(
            label: 'Dashboard',
            subtitle: 'Painel de indicadores',
            icon: Icons.bar_chart_rounded,
            color: _T.indigo,
            section: 'Geral',
            action: (ctx) async {
              context.pushNamed(DashboardWidget.routeName);
            }),
      ];

  List<String> get _sections => _items.map((e) => e.section).toSet().toList();

  // ── BUILD ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    return HpsGridBackground(
      child: SafeArea(
        top: true,
        bottom: true,
        child: Column(children: [
          _buildHeader(),
          Divider(height: 0.5, thickness: 0.5, color: _T.border(context)),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 36),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFinanceBanner(),
                  const SizedBox(height: 28),
                  ..._sections.map((s) {
                    final items = _items.where((i) => i.section == s).toList();
                    return _buildSection(s, items, w);
                  }),
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }

  // ── Header ───────────────────────────────────────────────────────────────
  Widget _buildHeader() => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
        child: Row(children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [HpsUi.buttonStart, HpsUi.buttonEnd],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: HpsUi.buttonStart.withOpacity(0.30),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Icons.tune_rounded, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                      'Painel de Controle',
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.interTight(
                        color: _T.textPrimary(context),
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        letterSpacing: -0.2,
                      ),
                    ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: HpsUi.success.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(HpsUi.radiusPill),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 5,
                            height: 5,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: _T.teal,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'ADMIN',
                            style: GoogleFonts.inter(
                              color: _T.teal,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'HPS Refrigeração • Gestão Geral do Sistema',
                  style: GoogleFonts.inter(
                    color: _T.textSecondary(context),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          HpsCloseButton(onPressed: () => Navigator.of(context).maybePop()),
        ]),
      );

  // ── Banner financeiro ────────────────────────────────────────────────────
  Widget _buildFinanceBanner() => ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
        decoration: BoxDecoration(
          color: HpsUi.surface.withOpacity(0.85),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.10)),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _T.teal.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.auto_awesome_rounded,
                  color: _T.teal, size: 16),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              Text(
                'Módulo Financeiro IA',
                style: GoogleFonts.interTight(
                  color: _T.textPrimary(context),
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              Text(
                'Gastos · Contas a Receber · Balanço & Dashboards',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  color: _T.textSecondary(context),
                  fontSize: 11,
                ),
              ),
                ],
              ),
            ),
          ]),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(
              child: _finBtn(
                icon: Icons.smart_toy_rounded,
                label: 'IA Financeira',
                subtitle: 'Registrar lançamentos',
                color: _T.teal,
                onTap: () => _sheetFin(FirebaseAiFinanceWidget()),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _finBtn(
                icon: Icons.dashboard_rounded,
                label: 'Dashboard',
                subtitle: 'Gastos & Recebimentos',
                color: _T.indigo,
                onTap: () => _sheetFin(FinanceDashboardWidget()),
              ),
            ),
          ]),
        ]),
          ),
        ),
      );

  Widget _finBtn({
    required IconData icon,
    required String label,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) =>
      Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: _T.iconBg(context, color),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withOpacity(0.25), width: 0.8),
            ),
            child: Row(children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.interTight(
                        color: _T.textPrimary(context),
                        fontWeight: FontWeight.w600,
                        fontSize: 12.5,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(
                        color: _T.textSecondary(context),
                        fontSize: 9.5,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded,
                  color: _T.textMuted(context), size: 11),
            ]),
          ),
        ),
      );

  // ── Seção ────────────────────────────────────────────────────────────────
  Widget _buildSection(String title, List<_PanelItem> items, double w) {
    final isDanger = title == 'Perigo';
    final cols = w < 400 ? 2 : (w < 768 ? 3 : (w < 1024 ? 4 : 5));

    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Label da seção
        Row(children: [
          Container(
            width: 3,
            height: 12,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: isDanger ? _T.danger : _T.sky,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Text(
            title.toUpperCase(),
            style: GoogleFonts.inter(
              color: isDanger ? _T.danger : _T.textSecondary(context),
              fontWeight: FontWeight.w700,
              fontSize: 11,
              letterSpacing: 1.2,
            ),
          ),
        ]),
        const SizedBox(height: 12),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            mainAxisExtent: w < 600 ? 140 : 128,
          ),
          itemBuilder: (_, i) => _panelCard(items[i], w),
        ),

        if (isDanger) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _T.danger.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _T.danger.withOpacity(0.2), width: 0.8),
            ),
            child: Row(children: [
              const Icon(Icons.warning_amber_rounded, size: 14, color: _T.danger),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Ações desta seção são críticas e irreversíveis. Use com cautela.',
                  style: GoogleFonts.inter(
                    color: _T.danger,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ]),
          ),
        ],
      ]),
    );
  }

  // ── Card ─────────────────────────────────────────────────────────────────
  Widget _panelCard(_PanelItem item, double w) {
    final isPhone = w < 600;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: item.action != null ? () => item.action!(context) : null,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              decoration: BoxDecoration(
                color: HpsUi.surface.withOpacity(0.85),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.10)),
              ),
              child: Padding(
                padding: EdgeInsets.all(isPhone ? 10 : 12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: isPhone ? 38 : 42,
                      height: isPhone ? 38 : 42,
                      decoration: BoxDecoration(
                        color: _T.iconBg(context, item.color),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: item.color.withOpacity(0.25),
                          width: 0.8,
                        ),
                      ),
                      child: Icon(
                        item.icon,
                        color: item.color,
                        size: isPhone ? 19 : 22,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.label,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.interTight(
                        color: HpsUi.textPrimary,
                        fontSize: isPhone ? 10.5 : 12,
                        fontWeight: FontWeight.w600,
                        height: 1.25,
                      ),
                    ),
                    if (item.subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        item.subtitle!,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          color: HpsUi.textMuted,
                          fontSize: 9.5,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
