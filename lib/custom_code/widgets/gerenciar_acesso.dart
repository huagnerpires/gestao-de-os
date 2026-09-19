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

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '/auth/firebase_auth/auth_util.dart';

String get _adminEmail => currentUserEmail;

// Verifica permissão considerando todos os campos possíveis
bool _docTemPermissaoFin(Map<String, dynamic> d) =>
    d['permissao_financeiro'] == true ||
    d['permissao'] == true ||
    d['PERMISSAO'] == true;

class GerenciarAcesso extends StatefulWidget {
  const GerenciarAcesso({Key? key, this.width, this.height}) : super(key: key);
  final double? width;
  final double? height;

  @override
  State<GerenciarAcesso> createState() => _GerenciarAcessoState();
}

class _GerenciarAcessoState extends State<GerenciarAcesso>
    with SingleTickerProviderStateMixin {
  static const Color _primary = Color(0xFF0F766E);
  static const Color _dark = Color(0xFF0F766E);
  static const Color _red = Color(0xFFB91C1C);
  static const Color _orange = Color(0xFFC2410C);

  String _busca = '';
  String _filtro = 'todos';
  final _buscaCtrl = TextEditingController();

  @override
  void dispose() {
    _buscaCtrl.dispose();
    super.dispose();
  }

  // ─── TOGGLE PERMISSÃO ────────────────────────────────────────────────────────
  Future<void> _togglePermissao(
    DocumentReference ref,
    Map<String, dynamic> data,
    String nome,
    String email,
  ) async {
    final temFin = _docTemPermissaoFin(data);
    final novoValor = !temFin;

    final ok = await _dialogConfirmar(
      titulo:
          novoValor ? 'Liberar Acesso Financeiro' : 'Revogar Acesso Financeiro',
      mensagem: novoValor
          ? 'Liberar acesso ao financeiro para $nome?\n\nEste usuário poderá visualizar todos os dados financeiros.'
          : 'Revogar acesso ao financeiro de $nome?',
      corAcao: novoValor ? _dark : _red,
      labelAcao: novoValor ? 'Liberar' : 'Revogar',
      icone:
          novoValor ? Icons.monetization_on_outlined : Icons.money_off_rounded,
    );
    if (ok != true) return;

    try {
      // Atualiza TODOS os campos de permissão para compatibilidade
      final Map<String, dynamic> update = {
        'permissao_financeiro': novoValor,
        'permissao': novoValor,
        'PERMISSAO': novoValor,
      };
      if (novoValor) {
        update['financeiro_concedido_por'] = _adminEmail;
        update['financeiro_concedido_em'] = FieldValue.serverTimestamp();
      } else {
        update['financeiro_concedido_por'] = '';
        update['financeiro_concedido_em'] = null;
      }
      await ref.update(update);

      await _registrarAuditoria(
        email: email,
        nome: nome,
        acao: novoValor ? 'LIBERAR_FINANCEIRO' : 'REVOGAR_FINANCEIRO',
        admin: _adminEmail,
      );

      if (email.isNotEmpty) {
        await _notificarUsuario(
          email: email,
          titulo: novoValor
              ? 'Acesso ao Financeiro Liberado'
              : 'Acesso ao Financeiro Revogado',
          mensagem: novoValor
              ? 'Seu acesso ao módulo financeiro foi liberado! Acesse a aba Financeiro.'
              : 'Seu acesso ao módulo financeiro foi revogado pelo administrador.',
        );
      }

      _snack(
        novoValor
            ? 'Financeiro liberado para $nome'
            : 'Financeiro revogado de $nome',
        novoValor ? _dark : _orange,
      );
    } catch (e) {
      _snack('Erro: $e', _red);
    }
  }

  // ─── EXCLUIR ─────────────────────────────────────────────────────────────────
  Future<void> _excluir(
      DocumentReference ref, String nome, String email) async {
    final ok = await _dialogConfirmar(
      titulo: 'Excluir Usuário',
      mensagem:
          'Excluir $nome da área restrita?\n\nEsta ação não pode ser desfeita.',
      corAcao: _red,
      labelAcao: 'Excluir',
      icone: Icons.delete_forever_rounded,
    );
    if (ok != true) return;
    try {
      await ref.delete();
      await _registrarAuditoria(
          email: email, nome: nome, acao: 'EXCLUIR', admin: _adminEmail);
      _snack('$nome removido', _red);
    } catch (e) {
      _snack('Erro: $e', _red);
    }
  }

  // ─── NOTIFICAR ───────────────────────────────────────────────────────────────
  Future<void> _notificarUsuario(
      {required String email,
      required String titulo,
      required String mensagem}) async {
    try {
      await http.post(Uri.parse('https://onesignal.com/api/v1/notifications'),
          headers: {
            'Authorization':
                'Basic ZTdlNjIwZWItMjEyMC00M2RhLWJlZmYtMzc2NTBmNzNmMDdj',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'app_id': '7b01186f-cf76-4b5d-8354-87d83737d40c',
            'filters': [
              {'field': 'tag', 'key': 'Email', 'relation': '=', 'value': email}
            ],
            'headings': {'en': titulo},
            'contents': {'en': mensagem},
            'android_channel_id': '577bba44-d1bf-4ac9-9d11-20d89e09a61a',
            'priority': 10,
          }));
    } catch (_) {}
    try {
      await FirebaseFirestore.instance.collection('NOTIFICACAO').add({
        'email': email,
        'titulo': titulo,
        'mensagem': mensagem,
        'tipo': 'sistema',
        'visto': false,
        'data': Timestamp.now(),
        'status': 'ativo',
        'os': '',
      });
    } catch (_) {}
  }

  // ─── AUDITORIA ───────────────────────────────────────────────────────────────
  Future<void> _registrarAuditoria(
      {required String email,
      required String nome,
      required String acao,
      required String admin}) async {
    try {
      await FirebaseFirestore.instance.collection('AUDITORIA_FINANCEIRO').add({
        'email': email,
        'nome': nome,
        'acao': acao,
        'admin': admin,
        'timestamp': FieldValue.serverTimestamp(),
        'autorizado': acao.startsWith('LIBERAR'),
      });
    } catch (_) {}
  }

  // ─── HELPERS ─────────────────────────────────────────────────────────────────
  Future<bool?> _dialogConfirmar(
          {required String titulo,
          required String mensagem,
          required Color corAcao,
          required String labelAcao,
          required IconData icone}) =>
      showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                title: Row(children: [
                  Icon(icone, color: corAcao, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                      child: Text(titulo,
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: corAcao))),
                ]),
                content: Text(mensagem,
                    style: const TextStyle(fontSize: 14, height: 1.5)),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancelar')),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: corAcao,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8))),
                    onPressed: () => Navigator.pop(ctx, true),
                    child: Text(labelAcao,
                        style: const TextStyle(color: Colors.white)),
                  ),
                ],
              ));

  void _snack(String msg, Color cor) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: cor,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  // ─── FILTRAR ─────────────────────────────────────────────────────────────────
  List<QueryDocumentSnapshot> _filtrar(List<QueryDocumentSnapshot> docs) {
    var lista = docs;
    switch (_filtro) {
      case 'aguardando':
        lista = lista
            .where(
                (d) => !_docTemPermissaoFin(d.data() as Map<String, dynamic>))
            .toList();
        break;
      case 'liberados_fin':
        lista = lista
            .where((d) => _docTemPermissaoFin(d.data() as Map<String, dynamic>))
            .toList();
        break;
    }
    if (_busca.isNotEmpty) {
      final q = _busca.toLowerCase();
      lista = lista.where((d) {
        final data = d.data() as Map<String, dynamic>;
        final nome = (data['nome'] ?? data['NOMEDOUSUARIO'] ?? '')
            .toString()
            .toLowerCase();
        final email = (data['email'] ?? data['ID_DO_CELULAR'] ?? '')
            .toString()
            .toLowerCase();
        final cargo = (data['cargo'] ?? '').toString().toLowerCase();
        return nome.contains(q) || email.contains(q) || cargo.contains(q);
      }).toList();
    }
    return lista;
  }

  // ─── BUILD ───────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    const isDark = true;
    return Material(
      color: const Color(0xFF0B0F17),
      child: SafeArea(
        child: SizedBox(
      width: widget.width ?? double.infinity,
      height: widget.height ?? double.infinity,
      child: Column(children: [
        _buildHeader(theme),
        Expanded(child: _buildLista(theme, isDark)),
      ]),
    ),
      ),
    );
  }

  // ─── HEADER ──────────────────────────────────────────────────────────────────
  Widget _buildHeader(FlutterFlowTheme theme) => Container(
      decoration: const BoxDecoration(
          gradient: LinearGradient(
              colors: [_primary, _dark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight)),
      child: Column(children: [
        Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(children: [
              Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.admin_panel_settings_rounded,
                      color: Colors.white, size: 22)),
              const SizedBox(width: 12),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text('Gerenciar Acessos',
                        style: GoogleFonts.interTight(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w700)),
                    Text('Liberação do módulo Financeiro',
                        style: TextStyle(color: Colors.white70, fontSize: 11)),
                  ])),
            ])),
        const SizedBox(height: 12),
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
                height: 40,
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10)),
                child: TextField(
                    controller: _buscaCtrl,
                    onChanged: (v) => setState(() => _busca = v),
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Buscar por nome, email ou cargo...',
                      hintStyle: TextStyle(
                          color: Colors.white.withOpacity(0.6), fontSize: 13),
                      prefixIcon: const Icon(Icons.search,
                          color: Colors.white, size: 18),
                      suffixIcon: _busca.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close,
                                  color: Colors.white, size: 16),
                              onPressed: () {
                                _buscaCtrl.clear();
                                setState(() => _busca = '');
                              })
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    )))),
        const SizedBox(height: 10),
        SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(children: [
              _chip('todos', 'Todos', Icons.people_rounded),
              const SizedBox(width: 8),
              _chip('aguardando', 'Sem Financeiro',
                  Icons.hourglass_empty_rounded),
              const SizedBox(width: 8),
              _chip('liberados_fin', 'Com Financeiro',
                  Icons.monetization_on_outlined),
            ])),
        const SizedBox(height: 12),
      ]));

  // ─── LISTA ───────────────────────────────────────────────────────────────────
  Widget _buildLista(FlutterFlowTheme theme, bool isDark) => StreamBuilder<
          QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('AREA_RESTRITA')
          .orderBy('cadastrado_em', descending: true)
          .snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting)
          return const Center(
              child: CircularProgressIndicator(color: _primary));
        if (!snap.hasData || snap.data!.docs.isEmpty)
          return _vazio(theme, 'Nenhum usuário cadastrado');

        final todos = snap.data!.docs;
        final docs = _filtrar(todos);
        final total = todos.length;
        final comFin = todos
            .where((d) => _docTemPermissaoFin(d.data() as Map<String, dynamic>))
            .length;
        final semFin = total - comFin;

        return Column(children: [
          Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: isDark
                  ? Colors.white.withOpacity(0.04)
                  : Colors.grey.withOpacity(0.06),
              child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(children: [
                    _badge('$total', 'Total', Colors.grey, theme),
                    const SizedBox(width: 16),
                    _badge('$semFin', 'Sem Financeiro', _orange, theme),
                    const SizedBox(width: 16),
                    _badge('$comFin', 'Com Financeiro', _dark, theme),
                  ]))),
          docs.isEmpty
              ? Expanded(child: _vazio(theme, 'Nenhum resultado'))
              : Expanded(
                  child: ListView.separated(
                      padding: EdgeInsets.fromLTRB(12, 12, 12,
                          12 + MediaQuery.of(context).padding.bottom),
                      itemCount: docs.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (_, i) => _card(docs[i], theme, isDark))),
        ]);
      });

  // ─── CARD ────────────────────────────────────────────────────────────────────
  Widget _card(QueryDocumentSnapshot doc, FlutterFlowTheme theme, bool isDark) {
    final data = doc.data() as Map<String, dynamic>;

    // Suporta campos novos (nome, email, cargo) e antigos (NOMEDOUSUARIO, ID_DO_CELULAR)
    final nome =
        (data['nome'] ?? data['NOMEDOUSUARIO'] ?? 'Sem nome').toString();
    final email = (data['email'] ?? data['ID_DO_CELULAR'] ?? '').toString();
    final cargo = (data['cargo'] ?? '').toString();
    final temFin = _docTemPermissaoFin(data);
    final finPor = (data['financeiro_concedido_por'] ?? '').toString();
    final cadastradoEm = data['cadastrado_em'] as Timestamp?;
    final ultimoAcesso = data['ultimo_acesso'] as Timestamp?;

    return Container(
        decoration: BoxDecoration(
          color: theme.secondaryBackground,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: temFin ? _dark : theme.alternate,
              width: temFin ? 1.5 : 1.0),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.2 : 0.06),
                blurRadius: 6,
                offset: const Offset(0, 2))
          ],
        ),
        child: Padding(
            padding: const EdgeInsets.all(14),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Nome + badge
              Row(children: [
                Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                        color: temFin
                            ? _dark.withOpacity(0.12)
                            : _primary.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(12)),
                    child: Icon(
                        temFin
                            ? Icons.monetization_on_outlined
                            : Icons.person_rounded,
                        color: temFin ? _dark : _primary,
                        size: 22)),
                const SizedBox(width: 12),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(nome,
                          style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: theme.primaryText)),
                      if (cargo.isNotEmpty)
                        Text(cargo,
                            style: GoogleFonts.inter(
                                fontSize: 11, color: theme.secondaryText)),
                    ])),
                _statusBadge(temFin ? 'Financeiro ✓' : 'Sem Financeiro',
                    temFin ? _dark : Colors.grey),
              ]),
              const SizedBox(height: 10),
              // Email
              Row(children: [
                Icon(Icons.email_outlined,
                    size: 13, color: theme.secondaryText.withOpacity(0.6)),
                const SizedBox(width: 6),
                Expanded(
                    child: Text(email.isNotEmpty ? email : '-',
                        style: GoogleFonts.inter(
                            fontSize: 12, color: theme.secondaryText),
                        overflow: TextOverflow.ellipsis)),
              ]),
              // Datas
              if (cadastradoEm != null || ultimoAcesso != null) ...[
                const SizedBox(height: 4),
                Row(children: [
                  Icon(Icons.access_time_rounded,
                      size: 11, color: theme.secondaryText.withOpacity(0.5)),
                  const SizedBox(width: 4),
                  if (cadastradoEm != null)
                    Text('Cadastro: ${_fmt(cadastradoEm)}',
                        style: TextStyle(
                            fontSize: 10,
                            color: theme.secondaryText.withOpacity(0.55))),
                  if (cadastradoEm != null && ultimoAcesso != null)
                    Text('  •  ',
                        style: TextStyle(
                            fontSize: 10,
                            color: theme.secondaryText.withOpacity(0.4))),
                  if (ultimoAcesso != null)
                    Text('Último acesso: ${_fmt(ultimoAcesso)}',
                        style: TextStyle(
                            fontSize: 10,
                            color: theme.secondaryText.withOpacity(0.55))),
                ]),
              ],
              // Concedido por
              if (temFin && finPor.isNotEmpty) ...[
                const SizedBox(height: 4),
                Row(children: [
                  Icon(Icons.verified_user_outlined,
                      size: 11, color: _dark.withOpacity(0.6)),
                  const SizedBox(width: 4),
                  Expanded(
                      child: Text('Liberado por: $finPor',
                          style: TextStyle(
                              fontSize: 10, color: _dark.withOpacity(0.7)),
                          overflow: TextOverflow.ellipsis)),
                ]),
              ],
              const SizedBox(height: 12),
              const Divider(height: 1, thickness: 0.5),
              const SizedBox(height: 10),
              // Botões
              Row(children: [
                Expanded(
                    child: _btnAcao(
                        label: temFin
                            ? 'Revogar Financeiro'
                            : 'Liberar Financeiro',
                        icone: temFin
                            ? Icons.money_off_rounded
                            : Icons.monetization_on_outlined,
                        cor: temFin ? _orange : _dark,
                        onTap: () => _togglePermissao(
                            doc.reference, data, nome, email))),
                const SizedBox(width: 8),
                GestureDetector(
                    onTap: () => _excluir(doc.reference, nome, email),
                    child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            color: _red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: _red.withOpacity(0.3))),
                        child: const Icon(Icons.delete_outline_rounded,
                            color: _red, size: 18))),
              ]),
            ])));
  }

  // ─── WIDGETS AUXILIARES ───────────────────────────────────────────────────────
  String _fmt(Timestamp ts) {
    final d = ts.toDate();
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year.toString().substring(2)}';
  }

  Widget _chip(String valor, String label, IconData icon) {
    final ativo = _filtro == valor;
    return GestureDetector(
        onTap: () => setState(() => _filtro = valor),
        child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
                color: ativo ? Colors.white : Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(icon,
                  size: 13,
                  color: ativo ? _dark : Colors.white.withOpacity(0.8)),
              const SizedBox(width: 5),
              Text(label,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: ativo ? _dark : Colors.white.withOpacity(0.9))),
            ])));
  }

  Widget _badge(
          String valor, String label, Color cor, FlutterFlowTheme theme) =>
      Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: cor, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text('$valor $label',
            style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: theme.secondaryText)),
      ]);

  Widget _statusBadge(String label, Color cor) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
          color: cor.withOpacity(0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: cor.withOpacity(0.4))),
      child: Text(label,
          style: TextStyle(
              color: cor, fontSize: 10, fontWeight: FontWeight.bold)));

  Widget _btnAcao(
          {required String label,
          required IconData icone,
          required Color cor,
          required VoidCallback onTap}) =>
      GestureDetector(
          onTap: onTap,
          child: Container(
              padding: const EdgeInsets.symmetric(vertical: 11),
              decoration: BoxDecoration(
                  color: cor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: cor.withOpacity(0.35))),
              child:
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(icone, color: cor, size: 15),
                const SizedBox(width: 6),
                Flexible(
                    child: Text(label,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: cor,
                            fontSize: 13,
                            fontWeight: FontWeight.bold))),
              ])));

  Widget _vazio(FlutterFlowTheme theme, String msg) => Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.people_outline,
            size: 48, color: theme.secondaryText.withOpacity(0.4)),
        const SizedBox(height: 12),
        Text(msg,
            style: GoogleFonts.inter(color: theme.secondaryText, fontSize: 14)),
      ]));
}
