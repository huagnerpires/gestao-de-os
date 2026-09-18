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

import 'os_widget.dart'; // <-- IMPORTAÇÃO DIRETA DO SEU WIDGET DE O.S.

import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

const Color _kPrimary = Color(0xFF39D2C0);

class NotificacaoWidget1 extends StatefulWidget {
  const NotificacaoWidget1({
    super.key,
    this.width,
    this.height,
  });

  final double? width;
  final double? height;

  @override
  State<NotificacaoWidget1> createState() => _NotificacaoWidget1State();
}

class _NotificacaoWidget1State extends State<NotificacaoWidget1> {
  String _filtro = 'todas';

  // Parâmetro fixo para buscar as notificações
  final String _emailAlvo = 'hpsrefri@gmail.com';

  /// Stream que busca as notificações no banco de dados para o e-mail fixado.
  Stream<QuerySnapshot> get _stream => FirebaseFirestore.instance
      .collection('NOTIFICACAO')
      .where('email', isEqualTo: _emailAlvo)
      .snapshots();

  @override
  void initState() {
    super.initState();
  }

  Future<void> _marcarVisto(String docId) async {
    await FirebaseFirestore.instance
        .collection('NOTIFICACAO')
        .doc(docId)
        .update({'visto': true});
  }

  Future<void> _excluirTodas(List<QueryDocumentSnapshot> docs) async {
    final batch = FirebaseFirestore.instance.batch();
    for (final doc in docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  Future<void> _mostrarModalExcluir(List<QueryDocumentSnapshot> docs) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      useSafeArea: true,
      builder: (_) => _ModalExcluir(
        total: docs.length,
        onConfirmar: () async {
          Navigator.pop(context);
          await _excluirTodas(docs);
        },
      ),
    );
  }

  List<QueryDocumentSnapshot> _aplicarFiltro(List<QueryDocumentSnapshot> docs) {
    switch (_filtro) {
      case 'lidas':
        return docs.where((d) {
          final m = d.data() as Map<String, dynamic>? ?? {};
          return m['visto'] as bool? ?? false;
        }).toList();
      case 'nao_lidas':
        return docs.where((d) {
          final m = d.data() as Map<String, dynamic>? ?? {};
          return !(m['visto'] as bool? ?? false);
        }).toList();
      default:
        return docs;
    }
  }

  List<QueryDocumentSnapshot> _ordenar(List<QueryDocumentSnapshot> docs) {
    final sorted = List<QueryDocumentSnapshot>.from(docs);
    sorted.sort((a, b) {
      final ma = a.data() as Map<String, dynamic>? ?? {};
      final mb = b.data() as Map<String, dynamic>? ?? {};
      final ta = (ma['data'] as Timestamp?)?.toDate() ?? DateTime(0);
      final tb = (mb['data'] as Timestamp?)?.toDate() ?? DateTime(0);
      return tb.compareTo(ta);
    });
    return sorted;
  }

  void _abrirOsDetalhe(QueryDocumentSnapshot doc) async {
    final docData = doc.data() as Map<String, dynamic>? ?? {};
    final tipo = (docData['tipo'] as String? ?? '').trim().toUpperCase();

    // Marca como lida
    await _marcarVisto(doc.id);

    // Se for documento financeiro, avisa para ir pro financeiro
    if (tipo == 'DOCUMENTO') {
      if (!mounted) return;
      await showDialog(
        context: context,
        builder: (_) => const _ModalAvisoFinanceiro(),
      );
      return;
    }

    // Tenta extrair o número da O.S da notificação
    String numeroOS = (docData['os'] as String? ?? '').trim();
    if (numeroOS.isEmpty)
      numeroOS = (docData['numeroOS'] as String? ?? '').trim();
    if (numeroOS.isEmpty)
      numeroOS = (docData['NUMERO_OS'] as String? ?? '').trim();
    if (numeroOS.isEmpty) numeroOS = (docData['OS'] as String? ?? '').trim();

    if (numeroOS.isEmpty) {
      final texto = '${docData['mensagem'] ?? ''} ${docData['titulo'] ?? ''}';
      final match = RegExp(r'#(\w+)').firstMatch(texto);
      if (match != null) numeroOS = match.group(1) ?? '';
    }

    if (numeroOS.isNotEmpty) {
      try {
        final snap = await FirebaseFirestore.instance
            .collection('SERVICOSREALIZADOS')
            .where('NUMERODAOS', isEqualTo: numeroOS)
            .limit(1)
            .get();

        if (snap.docs.isNotEmpty) {
          final osData = {'_id': snap.docs.first.id, ...snap.docs.first.data()};
          final statusDaOs = (osData['STATUS'] ?? '').toString().toUpperCase();

          if (!mounted) return;

          final navigator = Navigator.of(context);

          Widget telaDestino;
          if (statusDaOs == 'PASSAR ORÇAMENTO') {
            telaDestino = OsOrcamentoPage(
              os: osData,
              db: FirebaseFirestore.instance,
              onSaved: () {},
              embedded: true,
            );
          } else {
            telaDestino = OsEditPage(
              os: osData,
              db: FirebaseFirestore.instance,
              onSaved: () {},
              embedded: true,
            );
          }

          navigator.pop();
          await Future<void>.delayed(Duration.zero);
          if (!navigator.mounted) return;
          await showHpsSheet(navigator.context, child: telaDestino);

          return;
        }
      } catch (e) {
        debugPrint('Erro ao buscar a O.S para abrir a tela: $e');
      }
    }

    if (!mounted) return;
    await showDialog(
      context: context,
      builder: (_) => _ModalDetalhes(docData: docData),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      textStyle: const TextStyle(decoration: TextDecoration.none),
      child: SafeArea(
        child: Container(
          width: widget.width ?? double.infinity,
          color: FlutterFlowTheme.of(context).secondaryBackground,
          height: widget.height ?? double.infinity,
          child: StreamBuilder<QuerySnapshot>(
            stream: _stream,
            builder: (context, snapshot) {
              final todos = _ordenar(snapshot.data?.docs ?? []);
              final filtrados = _aplicarFiltro(todos);
              final naoVistas = todos.where((d) {
                final m = d.data() as Map<String, dynamic>? ?? {};
                return !(m['visto'] as bool? ?? false);
              }).length;

              final agora = DateTime.now();
              final hoje = filtrados.where((d) {
                final m = d.data() as Map<String, dynamic>? ?? {};
                final ts = m['data'] as Timestamp?;
                if (ts == null) return false;
                return agora.difference(ts.toDate()).inHours < 24;
              }).toList();
              final anteriores = filtrados.where((d) {
                final m = d.data() as Map<String, dynamic>? ?? {};
                final ts = m['data'] as Timestamp?;
                if (ts == null) return true;
                return agora.difference(ts.toDate()).inHours >= 24;
              }).toList();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    color: FlutterFlowTheme.of(context).secondaryBackground,
                    padding: const EdgeInsets.fromLTRB(20, 16, 12, 14),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'NOTIFICAÇÕES',
                            style: GoogleFonts.inter(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              color: FlutterFlowTheme.of(context).primaryText,
                            ),
                          ),
                        ),
                        if (todos.isNotEmpty) ...[
                          GestureDetector(
                            onTap: () => _mostrarModalExcluir(todos),
                            child: Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context)
                                    .primaryBackground,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.delete_outline_rounded,
                                size: 18,
                                color:
                                    FlutterFlowTheme.of(context).secondaryText,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context)
                                  .primaryBackground,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.close_rounded,
                              size: 18,
                              color: FlutterFlowTheme.of(context).secondaryText,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: FlutterFlowTheme.of(context).alternate,
                  ),
                  Container(
                    color: FlutterFlowTheme.of(context).secondaryBackground,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          ('todas', 'TODAS'),
                          (
                            'nao_lidas',
                            naoVistas > 0
                                ? 'NÃO LIDAS ($naoVistas)'
                                : 'NÃO LIDAS'
                          ),
                          ('lidas', 'LIDAS'),
                        ].map((f) {
                          final ativo = _filtro == f.$1;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: GestureDetector(
                              onTap: () => setState(() => _filtro = f.$1),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 7),
                                decoration: BoxDecoration(
                                  color: ativo
                                      ? _kPrimary.withOpacity(0.1)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: ativo
                                        ? _kPrimary
                                        : FlutterFlowTheme.of(context)
                                            .alternate,
                                    width: ativo ? 1.5 : 0.8,
                                  ),
                                ),
                                child: Text(
                                  f.$2,
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: ativo
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                    color: ativo
                                        ? _kPrimary
                                        : FlutterFlowTheme.of(context)
                                            .secondaryText,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  Expanded(
                    child: snapshot.connectionState == ConnectionState.waiting
                        ? const Center(
                            child: CircularProgressIndicator(color: _kPrimary))
                        : snapshot.hasError
                            ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Text(
                                    'ERRO: ${snapshot.error}',
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      color: FlutterFlowTheme.of(context).error,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              )
                            : filtrados.isEmpty
                                ? Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.notifications_off_outlined,
                                          size: 48,
                                          color: FlutterFlowTheme.of(context)
                                              .secondaryText,
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'NENHUMA NOTIFICAÇÃO',
                                          style: GoogleFonts.inter(
                                            fontSize: 15,
                                            color: FlutterFlowTheme.of(context)
                                                .secondaryText,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : ListView(
                                    children: [
                                      if (hoje.isNotEmpty) ...[
                                        _buildSectionLabel(context, 'HOJE'),
                                        ...hoje.map((doc) => _NotifItem(
                                              doc: doc,
                                              onTap: () => _abrirOsDetalhe(doc),
                                            )),
                                      ],
                                      if (anteriores.isNotEmpty) ...[
                                        _buildSectionLabel(
                                            context, 'ANTERIORES'),
                                        ...anteriores.map((doc) => _NotifItem(
                                              doc: doc,
                                              onTap: () => _abrirOsDetalhe(doc),
                                            )),
                                      ],
                                      const SizedBox(height: 24),
                                    ],
                                  ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(BuildContext context, String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
      child: Text(
        label.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: FlutterFlowTheme.of(context).secondaryText,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

class _NotifItem extends StatelessWidget {
  const _NotifItem({required this.doc, required this.onTap});

  final QueryDocumentSnapshot doc;
  final VoidCallback onTap;

  Map<String, dynamic> get _data => doc.data() as Map<String, dynamic>? ?? {};

  bool get _visto => _data['visto'] as bool? ?? false;
  String get _titulo => _data['titulo'] as String? ?? '';
  String get _mensagem => _data['mensagem'] as String? ?? '';
  String get _tipo => (_data['tipo'] as String? ?? '').toLowerCase().trim();
  String get _numeroOS {
    String v = (_data['OS'] as String? ?? '').trim();
    if (v.isEmpty) v = (_data['NUMERO_OS'] as String? ?? '').trim();
    if (v.isEmpty) v = (_data['numeroOS'] as String? ?? '').trim();
    if (v.isEmpty) v = (_data['os'] as String? ?? '').trim();
    if (v.isEmpty) {
      final mensagem = (_data['mensagem'] as String? ?? '');
      final titulo = (_data['titulo'] as String? ?? '');
      final match = RegExp(r'#(\w+)').firstMatch('$mensagem $titulo');
      if (match != null) v = match.group(1) ?? '';
    }
    return v;
  }

  String get _tempo {
    if (_tipo == 'preventiva' || _tipo == 'preventivas') return '';
    final ts = _data['data'] as Timestamp?;
    if (ts == null) return '';
    final diff = DateTime.now().difference(ts.toDate());
    if (diff.inMinutes < 1) return 'agora';
    if (diff.inMinutes < 60) return '${diff.inMinutes}min';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }

  IconData get _icon {
    switch (_tipo) {
      case 'documento':
        return Icons.description_outlined;
      case 'preventiva':
      case 'preventivas':
      case 'manutencao':
        return Icons.calendar_month_outlined;
      case 'corretiva':
        return Icons.build_outlined;
      case 'financeiro':
      case 'pagamento':
        return Icons.payments_outlined;
      case 'sistema':
        return Icons.settings_outlined;
      case 'alerta':
        return Icons.warning_amber_rounded;
      default:
        return Icons.notifications_outlined;
    }
  }

  Color get _avatarBg {
    switch (_tipo) {
      case 'documento':
        return const Color(0xFFF3E5F5);
      case 'preventiva':
      case 'preventivas':
      case 'manutencao':
        return const Color(0xFFFFF3E0);
      case 'corretiva':
        return const Color(0xFFE3F2FD);
      case 'financeiro':
      case 'pagamento':
        return const Color(0xFFE8F5E9);
      case 'alerta':
        return const Color(0xFFFFEBEE);
      default:
        return const Color(0xFFF1F4F8);
    }
  }

  Color get _avatarFg {
    switch (_tipo) {
      case 'documento':
        return const Color(0xFF8E24AA);
      case 'preventiva':
      case 'preventivas':
      case 'manutencao':
        return const Color(0xFFE65100);
      case 'corretiva':
        return const Color(0xFF1565C0);
      case 'financeiro':
      case 'pagamento':
        return const Color(0xFF2E7D32);
      case 'alerta':
        return const Color(0xFFC62828);
      default:
        return const Color(0xFF57636C);
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Stack(
        children: [
          Container(
            color: _visto
                ? FlutterFlowTheme.of(context).secondaryBackground
                : const Color(0xFF39D2C0).withOpacity(0.03),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration:
                      BoxDecoration(color: _avatarBg, shape: BoxShape.circle),
                  child: Icon(_icon, size: 20, color: _avatarFg),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _titulo,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight:
                              _visto ? FontWeight.w400 : FontWeight.w600,
                          color: FlutterFlowTheme.of(context).primaryText,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _mensagem,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w300,
                          color: FlutterFlowTheme.of(context).secondaryText,
                          height: 1.5,
                        ),
                      ),
                      if (_numeroOS.isNotEmpty) ...[
                        const SizedBox(height: 5),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF39D2C0).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                                color:
                                    const Color(0xFF39D2C0).withOpacity(0.35),
                                width: 0.8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.build_circle_outlined,
                                  size: 10, color: Color(0xFF39D2C0)),
                              const SizedBox(width: 4),
                              Text(
                                'OS #$_numeroOS · TOQUE PARA VER',
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF39D2C0),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (_tempo.isNotEmpty) ...[
                      Text(
                        _tempo,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: FlutterFlowTheme.of(context).secondaryText,
                        ),
                      ),
                      const SizedBox(height: 6),
                    ],
                    if (!_visto)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFF39D2C0),
                          shape: BoxShape.circle,
                        ),
                      )
                    else
                      Icon(
                        Icons.check,
                        size: 14,
                        color: FlutterFlowTheme.of(context).secondaryText,
                      ),
                  ],
                ),
              ],
            ),
          ),
          if (!_visto)
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 3,
                decoration: const BoxDecoration(
                  color: Color(0xFF39D2C0),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(2),
                    bottomRight: Radius.circular(2),
                  ),
                ),
              ),
            ),
          Positioned(
            left: 16,
            right: 0,
            bottom: 0,
            child: Divider(
                height: 1, color: FlutterFlowTheme.of(context).alternate),
          ),
        ],
      ),
    );
  }
}

class _ModalExcluir extends StatelessWidget {
  const _ModalExcluir({required this.total, required this.onConfirmar});
  final int total;
  final VoidCallback onConfirmar;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.fromLTRB(
            20, 20, 20, 20 + MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).alternate,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                  color: Color(0xFFFFEBEE), shape: BoxShape.circle),
              child: const Icon(Icons.delete_forever_rounded,
                  color: Color(0xFFC62828), size: 24),
            ),
            const SizedBox(height: 14),
            Text(
              'APAGAR NOTIFICAÇÕES',
              style: GoogleFonts.inter(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: FlutterFlowTheme.of(context).primaryText,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'TODAS AS $total NOTIFICAÇÕES SERÃO APAGADAS. ESTA AÇÃO NÃO PODE SER DESFEITA.',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: FlutterFlowTheme.of(context).secondaryText,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      side: BorderSide(
                          color: FlutterFlowTheme.of(context).alternate),
                    ),
                    child: Text(
                      'CANCELAR',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w500,
                        color: FlutterFlowTheme.of(context).secondaryText,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: onConfirmar,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFC62828),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      'APAGAR TUDO',
                      style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ModalAvisoFinanceiro extends StatelessWidget {
  const _ModalAvisoFinanceiro();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).secondaryBackground,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                    color: Color(0xFFE8F5E9), shape: BoxShape.circle),
                child: const Icon(Icons.account_balance_wallet_outlined,
                    color: Color(0xFF2E7D32), size: 28),
              ),
              const SizedBox(height: 16),
              Text(
                'ACESSE O FINANCEIRO',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: FlutterFlowTheme.of(context).primaryText,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'PARA VISUALIZAR ESTE DOCUMENTO, POR FAVOR, ACESSE A ABA FINANCEIRO NA TELA INICIAL DO APLICATIVO.',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: FlutterFlowTheme.of(context).secondaryText,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(context),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF39D2C0),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    'ENTENDI',
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModalDetalhes extends StatelessWidget {
  const _ModalDetalhes({required this.docData});
  final Map<String, dynamic> docData;

  @override
  Widget build(BuildContext context) {
    final titulo = docData['titulo'] as String? ?? 'DETALHES DA NOTIFICAÇÃO';
    final mensagem =
        docData['mensagem'] as String? ?? 'NENHUM DETALHE ADICIONAL.';
    final ts = docData['data'] as Timestamp?;
    final tipo = (docData['tipo'] as String? ?? '').trim().toLowerCase();

    final dataStr = ts != null
        ? '${ts.toDate().day.toString().padLeft(2, '0')}/${ts.toDate().month.toString().padLeft(2, '0')}/${ts.toDate().year} ÀS ${ts.toDate().hour.toString().padLeft(2, '0')}:${ts.toDate().minute.toString().padLeft(2, '0')}'
        : '';

    final camposIgnorados = [
      'titulo',
      'mensagem',
      'data',
      'visto',
      'status',
      'tipo',
      'email',
      'EMAIL',
      'os',
      'numeroOS',
      'NUMERO_OS',
      'OS'
    ];
    final informacoesExtras = docData.entries
        .where((e) =>
            !camposIgnorados.contains(e.key) &&
            e.value != null &&
            e.value.toString().trim().isNotEmpty)
        .toList();

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).secondaryBackground,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF39D2C0).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.info_outline_rounded,
                          color: Color(0xFF39D2C0), size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        titulo,
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: FlutterFlowTheme.of(context).primaryText,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  mensagem,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: FlutterFlowTheme.of(context).secondaryText,
                    height: 1.5,
                  ),
                ),
                if (informacoesExtras.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Divider(color: FlutterFlowTheme.of(context).alternate),
                  const SizedBox(height: 8),
                  Text(
                    'DETALHES ADICIONAIS:',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: FlutterFlowTheme.of(context).primaryText,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...informacoesExtras.map((e) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${e.key.toUpperCase()}: ',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: FlutterFlowTheme.of(context).secondaryText,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              '${e.value}',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: FlutterFlowTheme.of(context).primaryText,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
                if (dataStr.isNotEmpty &&
                    tipo != 'preventiva' &&
                    tipo != 'preventivas') ...[
                  const SizedBox(height: 16),
                  Text(
                    dataStr,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: FlutterFlowTheme.of(context).alternate,
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.pop(context),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF39D2C0),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      'FECHAR',
                      style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600, color: Colors.white),
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
}
