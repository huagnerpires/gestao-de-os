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
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'dart:async';

import 'hps_sheet.dart';

class CompartilharOsWidget extends StatefulWidget {
  const CompartilharOsWidget({
    super.key,
    this.width,
    this.height,
  });

  final double? width;
  final double? height;

  @override
  State<CompartilharOsWidget> createState() => _CompartilharOsWidgetState();
}

class _CompartilharOsWidgetState extends State<CompartilharOsWidget> {
  final _buscaCtrl = TextEditingController();
  bool _loading = true;
  String? _erro;
  List<Map<String, dynamic>> _todas = [];
  List<Map<String, dynamic>> _filtradas = [];
  Map<String, dynamic>? _selecionada;
  bool _apenasPendentes = false;

  bool _isFaltaCompartilhar(Map<String, dynamic> row) {
    return row['FALTA_COMPARTILHAR'] == true ||
        (row['COMPARTILHADO'] != true &&
            (row['STATUS'] == 'CONCLUÍDA' ||
                row['STATUS'] == 'AGUARDANDO APROVAÇÃO' ||
                row['STATUS'] == 'APROVADO'));
  }

  Future<void> _marcarComoCompartilhado(Map<String, dynamic> row,
      [bool status = true]) async {
    try {
      final docId = row['_id']?.toString();
      if (docId != null && docId.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('SERVICOSREALIZADOS')
            .doc(docId)
            .update({
          'FALTA_COMPARTILHAR': !status,
          'COMPARTILHADO': status,
          'DATA_COMPARTILHADO': FieldValue.serverTimestamp(),
        });
        if (mounted) {
          setState(() {
            row['FALTA_COMPARTILHAR'] = !status;
            row['COMPARTILHADO'] = status;
          });
        }
      }
    } catch (_) {}
  }

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  @override
  void dispose() {
    _buscaCtrl.dispose();
    super.dispose();
  }

  Future<void> _carregar() async {
    setState(() {
      _loading = true;
      _erro = null;
    });
    try {
      final snap = await FirebaseFirestore.instance
          .collection('SERVICOSREALIZADOS')
          .limit(300)
          .get();
      final rows = snap.docs
          .map((d) => <String, dynamic>{
                ...d.data(),
                '_id': d.id,
              })
          .toList();

      rows.sort((a, b) {
        final na = _osNumero(a);
        final nb = _osNumero(b);
        return nb.compareTo(na);
      });

      if (!mounted) return;
      setState(() {
        _todas = rows;
        _loading = false;
      });
      _filtrar();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _erro = 'Não foi possível carregar as O.S.';
      });
    }
  }

  void _filtrar([String? q]) {
    final query = (q ?? _buscaCtrl.text).trim().toLowerCase();
    final out = <Map<String, dynamic>>[];
    for (final row in _todas) {
      if (_apenasPendentes && !_isFaltaCompartilhar(row)) {
        continue;
      }
      if (query.isNotEmpty) {
        final nos = _osNumero(row).toLowerCase();
        final cli = (row['CLIENTE'] ?? '').toString().toLowerCase();
        final st = (row['STATUS'] ?? '').toString().toLowerCase();
        if (!nos.contains(query) && !cli.contains(query) && !st.contains(query)) {
          continue;
        }
      }
      out.add(row);
      if (out.length >= 60) break;
    }
    setState(() => _filtradas = out);
  }

  String _osNumero(Map<String, dynamic> row) {
    final a = (row['NUMERODAOS'] ?? '').toString().trim();
    if (a.isNotEmpty) return a;
    return (row['NUMERO_OS'] ?? '').toString().trim();
  }

  String _descricaoCurta(Map<String, dynamic> row) {
    final candidatos = [
      row['DESCRICAO'],
      row['DESCRICAODOSERVICO'],
      row['SERVICO'],
      row['DEFEITO'],
      row['SERVICOREALIZADO'],
    ];
    for (final c in candidatos) {
      final t = (c ?? '').toString().trim();
      if (t.isNotEmpty) {
        if (t.length <= 140) return t;
        return '${t.substring(0, 137)}...';
      }
    }
    return '';
  }

  double _valorOrcamento(dynamic raw) {
    var valor = 0.0;
    if (raw is List) {
      for (final item in raw) {
        if (item is num) {
          valor += item.toDouble();
        } else if (item is String) {
          valor += double.tryParse(
                  item.replaceAll('.', '').replaceAll(',', '.')) ??
              0.0;
        }
      }
    } else if (raw is num) {
      valor = raw.toDouble();
    } else if (raw is String) {
      valor = double.tryParse(raw.replaceAll('.', '').replaceAll(',', '.')) ??
          0.0;
    }
    return valor;
  }

  String? _linkPdf(Map<String, dynamic> row) {
    const keys = [
      'PDF',
      'LINKPDF',
      'URLPDF',
      'PDFURL',
      'pdfUrl',
      'link_pdf',
      'LINK_PDF',
      'URL_PDF',
      'PDFLINK',
      'arquivoPdf',
      'ARQUIVOPDF',
    ];
    for (final k in keys) {
      final v = (row[k] ?? '').toString().trim();
      if (v.startsWith('http')) return v;
    }
    // Alguns docs guardam URL solta em campos genéricos.
    for (final entry in row.entries) {
      final key = entry.key.toString().toLowerCase();
      if (!key.contains('pdf') && !key.contains('link')) continue;
      final v = (entry.value ?? '').toString().trim();
      if (v.startsWith('http') && v.toLowerCase().contains('.pdf')) return v;
    }
    return null;
  }

  String _fmtValor(double v) {
    final s = v.toStringAsFixed(2).replaceAll('.', ',');
    return 'R\$ $s';
  }

  String _fmtData(dynamic raw) {
    if (raw == null) return '';
    try {
      if (raw is Timestamp) {
        return DateFormat('dd/MM/yyyy').format(raw.toDate());
      } else if (raw is DateTime) {
        return DateFormat('dd/MM/yyyy').format(raw);
      } else if (raw is String && raw.isNotEmpty) {
        return raw;
      }
    } catch (_) {}
    return '';
  }

  String _statusComEmoji(String status) {
    final s = status.trim();
    final upper = s.toUpperCase();
    if (upper.contains('FINALIZAD') ||
        upper.contains('CONCLU') ||
        upper.contains('OK')) {
      return '🟢 $s';
    }
    if (upper.contains('ANDAMENTO') ||
        upper.contains('EXECU') ||
        upper.contains('INICIAD')) {
      return '🟡 $s';
    }
    if (upper.contains('PENDENT') ||
        upper.contains('AGUARD') ||
        upper.contains('ABERT')) {
      return '⏳ $s';
    }
    if (upper.contains('CANCEL') || upper.contains('REPROV')) {
      return '🔴 $s';
    }
    return '📌 $s';
  }

  String _montarResumo(Map<String, dynamic> row) {
    final nos = _osNumero(row);
    final cliente = (row['CLIENTE'] ?? '').toString().trim();
    final rawStatus = (row['STATUS'] ?? '').toString().trim();
    final statusFmt = rawStatus.isNotEmpty ? _statusComEmoji(rawStatus) : '—';
    final equipamento = (row['EQUIPAMENTO'] ?? '').toString().trim();
    final patrimonio = (row['PATRIMONIO'] ?? '').toString().trim();
    final setor = (row['SETOR'] ?? '').toString().trim();
    final sala = (row['SALA'] ?? '').toString().trim();
    final tecnico = (row['TECNICO'] ?? '').toString().trim();
    final dataFmt = _fmtData(row['DATA']);
    final inicio = (row['INICIO'] ?? '').toString().trim();
    final termino = (row['TERMINO'] ?? '').toString().trim();
    final desc = (row['DESCRICAO'] ??
            row['DESCRICAODOSERVICO'] ??
            row['SERVICO'] ??
            row['DEFEITO'] ??
            '')
        .toString()
        .trim();
    final servicoRealizado = (row['SERVICOREALIZADO'] ?? '').toString().trim();
    final peca = (row['PECA'] ?? '').toString().trim();
    final valor = _valorOrcamento(row['VALOR']);
    final pdf = _linkPdf(row);

    final buf = StringBuffer();
    buf.writeln('❄️ *HPS REFRIGERAÇÃO & CLIMATIZAÇÃO*');
    buf.writeln('📋 *ORDEM DE SERVIÇO Nº #${nos.isEmpty ? '—' : nos}*');
    buf.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━');
    buf.writeln();
    buf.writeln('🏢 *Cliente:* ${cliente.isEmpty ? '—' : cliente}');

    if (setor.isNotEmpty || sala.isNotEmpty) {
      final loc = [
        if (setor.isNotEmpty) 'Setor: $setor',
        if (sala.isNotEmpty) 'Sala: $sala'
      ].join(' | ');
      buf.writeln('📍 *Localização:* $loc');
    }

    if (equipamento.isNotEmpty || patrimonio.isNotEmpty) {
      final equipStr = [
        if (equipamento.isNotEmpty) equipamento,
        if (patrimonio.isNotEmpty) '(Patrimônio/Tag: $patrimonio)'
      ].join(' ');
      buf.writeln('❄️ *Equipamento:* $equipStr');
    }

    if (tecnico.isNotEmpty) {
      buf.writeln('👤 *Técnico Responsável:* $tecnico');
    }

    if (dataFmt.isNotEmpty || inicio.isNotEmpty || termino.isNotEmpty) {
      final horarios = [
        if (dataFmt.isNotEmpty) dataFmt,
        if (inicio.isNotEmpty && termino.isNotEmpty) '$inicio às $termino'
        else if (inicio.isNotEmpty) 'Início: $inicio'
        else if (termino.isNotEmpty) 'Término: $termino'
      ].join(' — ');
      buf.writeln('📅 *Data / Horário:* $horarios');
    }

    buf.writeln('📊 *Status:* $statusFmt');

    if (desc.isNotEmpty) {
      buf.writeln();
      buf.writeln('📝 *Solicitação / Defeito:*');
      buf.writeln(desc);
    }

    if (servicoRealizado.isNotEmpty && servicoRealizado != desc) {
      buf.writeln();
      buf.writeln('🔧 *Serviço Executado:*');
      buf.writeln(servicoRealizado);
    }

    if (peca.isNotEmpty &&
        peca.toLowerCase() != 'não' &&
        peca.toLowerCase() != 'nao' &&
        peca != '-') {
      buf.writeln();
      buf.writeln('📦 *Peças / Materiais Aplicados:*');
      buf.writeln(peca);
    }

    if (valor > 0) {
      buf.writeln();
      buf.writeln('💰 *Valor Total do Atendimento:* ${_fmtValor(valor)}');
    }

    if (pdf != null) {
      buf.writeln();
      buf.writeln('📄 *Laudo Técnico Digital (PDF):*');
      buf.writeln(pdf);
    }

    buf.writeln();
    buf.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━');
    buf.writeln('📞 *Plantão & Atendimento:* (77) 98819-4630 / (77) 98861-2447');
    buf.writeln('🌐 *Site:* www.hpsrefri.com.br');
    buf.write('Agradecemos a preferência e confiança na equipe HPS!');
    return buf.toString();
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: HpsUi.surface,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _copiar() async {
    final row = _selecionada;
    if (row == null) {
      _snack('Selecione uma O.S. primeiro.');
      return;
    }
    await Clipboard.setData(ClipboardData(text: _montarResumo(row)));
    unawaited(_marcarComoCompartilhado(row, true));
    _snack('Resumo copiado e marcado como compartilhado!');
  }

  Future<void> _whatsapp() async {
    final row = _selecionada;
    if (row == null) {
      _snack('Selecione uma O.S. primeiro.');
      return;
    }
    final texto = _montarResumo(row);
    // Garante que o texto formatado com emojis também já fique na área de transferência
    await Clipboard.setData(ClipboardData(text: texto));

    final telRaw = (row['TELEFONE'] ??
            row['CELULAR'] ??
            row['CONTATO'] ??
            row['phone_number'] ??
            '')
        .toString();
    final telClean = telRaw.replaceAll(RegExp(r'\D'), '');
    final phoneParam = telClean.length >= 10
        ? (telClean.startsWith('55') ? telClean : '55$telClean')
        : '';

    final encodedText = Uri.encodeComponent(texto);

    // 1ª Opção: whatsapp:// (protocolo direto do app - não passa por redirect HTTP e não corrompe emojis)
    final nativeUri = Uri.parse(phoneParam.isNotEmpty
        ? 'whatsapp://send?phone=$phoneParam&text=$encodedText'
        : 'whatsapp://send?text=$encodedText');

    // 2ª Opção: api.whatsapp.com (direto na API sem passar pelo wa.me que quebra caracteres UTF-8)
    final webUri = Uri.parse(phoneParam.isNotEmpty
        ? 'https://api.whatsapp.com/send?phone=$phoneParam&text=$encodedText'
        : 'https://api.whatsapp.com/send?text=$encodedText');

    try {
      bool opened = false;
      if (await canLaunchUrl(nativeUri)) {
        opened = await launchUrl(nativeUri, mode: LaunchMode.externalApplication);
      }
      if (!opened) {
        opened = await launchUrl(webUri, mode: LaunchMode.externalApplication);
      }
      if (!opened) {
        opened = await launchUrl(webUri);
      }

      unawaited(_marcarComoCompartilhado(row, true));
      _snack('WhatsApp aberto! (Texto também copiado para segurança)');
    } catch (_) {
      try {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
        unawaited(_marcarComoCompartilhado(row, true));
        _snack('WhatsApp aberto! (Texto também copiado para segurança)');
      } catch (err) {
        unawaited(_marcarComoCompartilhado(row, true));
        _snack('Não foi possível abrir o WhatsApp diretamente. O texto com emojis foi copiado!');
      }
    }
  }

  Future<void> _email() async {
    final row = _selecionada;
    if (row == null) {
      _snack('Selecione uma O.S. primeiro.');
      return;
    }
    final texto = _montarResumo(row);
    final nos = _osNumero(row);
    final cliente = (row['CLIENTE'] ?? '').toString().trim();
    final destEmail = (row['EMAIL'] ?? row['email'] ?? '').toString().trim();
    final uri = Uri(
      scheme: 'mailto',
      path: destEmail.isNotEmpty ? destEmail : null,
      queryParameters: {
        'subject':
            'Relatório O.S. #${nos.isEmpty ? '' : nos} ${cliente.isNotEmpty ? '— ' + cliente : ''} — HPS Refrigeração',
        'body': texto,
      },
    );
    try {
      final ok = await launchUrl(uri);
      if (!ok) {
        await Clipboard.setData(ClipboardData(text: texto));
        _snack('E-mail indisponível. Resumo copiado para colar.');
      }
      unawaited(_marcarComoCompartilhado(row, true));
    } catch (_) {
      await Clipboard.setData(ClipboardData(text: texto));
      _snack('E-mail indisponível. Resumo copiado para colar.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: HpsGridBackground(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: HpsUi.accent,
                        strokeWidth: 2.5,
                      ),
                    )
                  : _erro != null
                      ? _buildErro()
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: _buildBusca(),
                            ),
                            const SizedBox(height: 12),
                            if (_selecionada == null)
                              Expanded(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                  child: _buildLista(expanded: true),
                                ),
                              )
                            else
                              Expanded(
                                child: ListView(
                                  padding:
                                      const EdgeInsets.fromLTRB(16, 0, 16, 24),
                                  children: [
                                    _buildCardSelecionada(),
                                    const SizedBox(height: 14),
                                    _buildPreview(),
                                    const SizedBox(height: 14),
                                    _buildAcoes(),
                                  ],
                                ),
                              ),
                          ],
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: HpsUi.success.withOpacity(0.18),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.share_outlined,
                color: HpsUi.success, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Compartilhar O.S.',
                  style: GoogleFonts.interTight(
                    color: HpsUi.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Resumo para WhatsApp, e-mail ou cópia',
                  style: GoogleFonts.inter(
                    color: HpsUi.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErro() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: HpsUi.error, size: 40),
            const SizedBox(height: 12),
            Text(
              _erro!,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(color: HpsUi.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _carregar,
              style: TextButton.styleFrom(foregroundColor: HpsUi.accent),
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBusca() {
    final totalPendentes = _todas.where(_isFaltaCompartilhar).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _buscaCtrl,
          onChanged: _filtrar,
          style: GoogleFonts.inter(color: HpsUi.textPrimary, fontSize: 14),
          cursorColor: HpsUi.accent,
          decoration: InputDecoration(
            hintText: 'Buscar por nº da O.S. ou cliente…',
            hintStyle:
                GoogleFonts.inter(color: HpsUi.textMuted, fontSize: 13.5),
            prefixIcon:
                const Icon(Icons.search_rounded, color: HpsUi.textMuted),
            filled: true,
            fillColor: HpsUi.inputFill,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(HpsUi.radiusControl),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(HpsUi.radiusControl),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(HpsUi.radiusControl),
              borderSide: const BorderSide(color: HpsUi.accent, width: 1.2),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _filtroChip(
                label: 'Todas as O.S. (${_todas.length})',
                selecionado: !_apenasPendentes,
                onTap: () {
                  setState(() => _apenasPendentes = false);
                  _filtrar();
                },
              ),
              const SizedBox(width: 8),
              _filtroChip(
                label: '🔔 Falta Compartilhar ($totalPendentes)',
                selecionado: _apenasPendentes,
                corDestaque: const Color(0xFFF59E0B),
                onTap: () {
                  setState(() => _apenasPendentes = true);
                  _filtrar();
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _filtroChip({
    required String label,
    required bool selecionado,
    required VoidCallback onTap,
    Color? corDestaque,
  }) {
    final cor = corDestaque ?? HpsUi.accent;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selecionado ? cor.withOpacity(0.18) : HpsUi.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selecionado ? cor : Colors.white.withOpacity(0.1),
            width: selecionado ? 1.4 : 1,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            color: selecionado ? Colors.white : HpsUi.textSecondary,
            fontSize: 12,
            fontWeight: selecionado ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildCardSelecionada() {
    final row = _selecionada!;
    final nos = _osNumero(row);
    final cli = (row['CLIENTE'] ?? '—').toString();
    final st = (row['STATUS'] ?? '—').toString();
    final eq = (row['EQUIPAMENTO'] ?? '').toString().trim();
    final faltaComp = _isFaltaCompartilhar(row);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: HpsUi.surface.withOpacity(0.95),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: faltaComp
              ? const Color(0xFFF59E0B).withOpacity(0.5)
              : HpsUi.accent.withOpacity(0.4),
        ),
        boxShadow: [
          BoxShadow(
            color: (faltaComp ? const Color(0xFFF59E0B) : HpsUi.accent)
                .withOpacity(0.10),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: HpsUi.accent.withOpacity(0.18),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: HpsUi.accent.withOpacity(0.35)),
            ),
            child: Text(
              '#${nos.isEmpty ? '—' : nos}',
              style: GoogleFonts.interTight(
                color: HpsUi.accent,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        cli,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          color: HpsUi.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (faltaComp) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF59E0B).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                              color: const Color(0xFFF59E0B).withOpacity(0.5)),
                        ),
                        child: Text(
                          'Falta Compartilhar',
                          style: GoogleFonts.inter(
                            color: const Color(0xFFF59E0B),
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (eq.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    eq,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      color: HpsUi.textMuted,
                      fontSize: 11.5,
                    ),
                  ),
                ],
                const SizedBox(height: 2),
                Text(
                  _statusComEmoji(st),
                  style: GoogleFonts.inter(
                    color: HpsUi.textSecondary,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            onPressed: () => setState(() => _selecionada = null),
            icon: const Icon(Icons.swap_horiz_rounded, size: 16),
            label: const Text('Trocar O.S.'),
            style: OutlinedButton.styleFrom(
              foregroundColor: HpsUi.accent,
              side: BorderSide(color: HpsUi.accent.withOpacity(0.5)),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLista({bool expanded = false}) {
    if (_filtradas.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: HpsUi.surface.withOpacity(0.85),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off_rounded,
                color: HpsUi.textMuted, size: 36),
            const SizedBox(height: 10),
            Text(
              _apenasPendentes
                  ? 'Nenhuma O.S. pendente de compartilhamento!'
                  : 'Nenhuma O.S. encontrada.',
              style: GoogleFonts.inter(color: HpsUi.textMuted, fontSize: 13.5),
            ),
          ],
        ),
      );
    }

    final listView = ListView.separated(
      shrinkWrap: !expanded,
      itemCount: _filtradas.length,
      separatorBuilder: (_, __) =>
          Divider(height: 1, color: Colors.white.withOpacity(0.06)),
      itemBuilder: (context, i) {
        final row = _filtradas[i];
        final nos = _osNumero(row);
        final cli = (row['CLIENTE'] ?? '—').toString();
        final st = (row['STATUS'] ?? '—').toString();
        final eq = (row['EQUIPAMENTO'] ?? '').toString().trim();
        final dataStr = _fmtData(row['DATA']);
        final selected = _selecionada?['_id'] == row['_id'];
        final faltaComp = _isFaltaCompartilhar(row);

        return Material(
          color: selected
              ? HpsUi.accent.withOpacity(0.14)
              : Colors.transparent,
          child: InkWell(
            onTap: () => setState(() => _selecionada = row),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Icon(
                    selected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    size: 20,
                    color: selected ? HpsUi.accent : HpsUi.textMuted,
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: HpsUi.accent.withOpacity(0.14),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '#${nos.isEmpty ? '—' : nos}',
                      style: GoogleFonts.interTight(
                        color: HpsUi.accent,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                cli,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.inter(
                                  color: HpsUi.textPrimary,
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            if (faltaComp) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 1.5),
                                decoration: BoxDecoration(
                                  color:
                                      const Color(0xFFF59E0B).withOpacity(0.18),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                      color: const Color(0xFFF59E0B)
                                          .withOpacity(0.4)),
                                ),
                                child: Text(
                                  'Falta compartilhar',
                                  style: GoogleFonts.inter(
                                    color: const Color(0xFFF59E0B),
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ] else if (row['COMPARTILHADO'] == true) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 1.5),
                                decoration: BoxDecoration(
                                  color: HpsUi.success.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '✓ Compartilhado',
                                  style: GoogleFonts.inter(
                                    color: HpsUi.success,
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            if (eq.isNotEmpty) ...[
                              Flexible(
                                child: Text(
                                  eq,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.inter(
                                    color: HpsUi.textMuted,
                                    fontSize: 11.5,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text('•',
                                  style: TextStyle(
                                      color: HpsUi.textMuted, fontSize: 10)),
                              const SizedBox(width: 6),
                            ],
                            Text(
                              _statusComEmoji(st),
                              style: GoogleFonts.inter(
                                color: HpsUi.textSecondary,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (dataStr.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Text(
                      dataStr,
                      style: GoogleFonts.inter(
                        color: HpsUi.textMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: HpsUi.textMuted,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    return Container(
      decoration: BoxDecoration(
        color: HpsUi.surface.withOpacity(0.85),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: listView,
    );
  }

  Widget _buildPreview() {
    final texto = _montarResumo(_selecionada!);
    const headerImgUrl =
        'https://firebasestorage.googleapis.com/v0/b/h-p-s-modificado-emdcp0.appspot.com/o/Gemini_Generated_Image_2xpdsd2xpdsd2xpd%20(1).png?alt=media&token=be3e052e-a0b8-4e8c-8151-b9365b507ed5';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: HpsUi.surface.withOpacity(0.85),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            child: Image.asset(
              'assets/images/hps_banner_header.png',
              width: double.infinity,
              height: 125,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Image.network(
                headerImgUrl,
                width: double.infinity,
                height: 125,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Prévia do resumo',
                      style: GoogleFonts.interTight(
                        color: HpsUi.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: HpsUi.accent.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.image_outlined,
                              size: 12, color: HpsUi.accent),
                          const SizedBox(width: 4),
                          Text(
                            'Banner Topo',
                            style: GoogleFonts.inter(
                              color: HpsUi.accent,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SelectableText(
                  texto,
                  style: GoogleFonts.inter(
                    color: HpsUi.textSecondary,
                    fontSize: 13,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAcoes() {
    final row = _selecionada;
    final compartilhado = row?['COMPARTILHADO'] == true;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _acaoBtn(
                label: 'Copiar',
                icon: Icons.copy_rounded,
                color: HpsUi.accent,
                onTap: _copiar,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _acaoBtn(
                label: 'WhatsApp',
                icon: Icons.chat_outlined,
                color: HpsUi.success,
                onTap: _whatsapp,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: _acaoBtn(
            label: 'E-mail',
            icon: Icons.email_outlined,
            color: const Color(0xFF0369A1),
            onTap: _email,
          ),
        ),
        if (row != null) ...[
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: _acaoBtn(
              label: compartilhado
                  ? '✓ Marcada como Compartilhada'
                  : 'Marcar como Compartilhada',
              icon: compartilhado
                  ? Icons.check_circle_rounded
                  : Icons.done_all_rounded,
              color: compartilhado
                  ? HpsUi.success
                  : const Color(0xFFF59E0B),
              onTap: () => _marcarComoCompartilhado(row, !compartilhado),
            ),
          ),
        ],
      ],
    );
  }

  Widget _acaoBtn({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      height: 46,
      child: Material(
        color: color.withOpacity(0.16),
        borderRadius: BorderRadius.circular(HpsUi.radiusControl),
        child: InkWell(
          borderRadius: BorderRadius.circular(HpsUi.radiusControl),
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(HpsUi.radiusControl),
              border: Border.all(color: color.withOpacity(0.35)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 18, color: color),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: GoogleFonts.interTight(
                    color: HpsUi.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
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
