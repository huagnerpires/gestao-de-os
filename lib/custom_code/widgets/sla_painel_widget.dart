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

import 'hps_sheet.dart';
import 'os_tempo.dart';

/// Status operacionais alinhados à home.
const _kStatusLabels = <String, String>{
  'AGUARDANDO AVALIAÇÃO': 'Pendentes',
  'INICIAR AVALIAÇÃO': 'Testes',
  'PASSAR ORÇAMENTO': 'Orçamento',
  'AGUARDANDO APROVAÇÃO': 'Ag. Aprovação',
  'AGUARDANDO PEÇA': 'Ag. Peça',
  'CANCELADA': 'Canceladas',
  'APROVADO': 'Aprovadas',
  'INICIOU O SERVIÇO': 'Em Andamento',
  'CONCLUÍDA': 'Concluídas',
};

enum _SlaRisco { ok, atencao, critico }

class _SlaItem {
  const _SlaItem({
    required this.osNumber,
    required this.cliente,
    required this.status,
    required this.dias,
    required this.risco,
    required this.row,
  });

  final String osNumber;
  final String cliente;
  final String status;
  final int dias;
  final _SlaRisco risco;
  final Map<String, dynamic> row;
}

class SlaPainelWidget extends StatefulWidget {
  const SlaPainelWidget({
    super.key,
    this.width,
    this.height,
  });

  final double? width;
  final double? height;

  @override
  State<SlaPainelWidget> createState() => _SlaPainelWidgetState();
}

class _SlaPainelWidgetState extends State<SlaPainelWidget> {
  bool _loading = true;
  String? _erro;
  double? _avgDays;
  int _abertas = 0;
  int _atencao = 0;
  int _critico = 0;
  Map<String, int> _porStatus = {};
  List<_SlaItem> _paradas = [];

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() {
      _loading = true;
      _erro = null;
    });
    try {
      final snap = await FirebaseFirestore.instance
          .collection('SERVICOSREALIZADOS')
          .limit(500)
          .get();
      final rows = snap.docs
          .map((d) => <String, dynamic>{
                ...d.data(),
                '_id': d.id,
              })
          .toList();
      _processar(rows);
      if (!mounted) return;
      setState(() => _loading = false);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _erro = 'Não foi possível carregar as O.S.';
      });
    }
  }

  void _processar(List<Map<String, dynamic>> rows) {
    final now = DateTime.now();
    final stats = computeOsTempo(rows);
    final counts = <String, int>{};
    for (final k in _kStatusLabels.keys) {
      counts[k] = 0;
    }

    var abertas = 0;
    var atencao = 0;
    var critico = 0;
    final paradas = <_SlaItem>[];

    for (final row in rows) {
      final statusRaw = (row['STATUS'] ?? '').toString().trim();
      final statusUp = statusRaw.toUpperCase();
      if (counts.containsKey(statusUp)) {
        counts[statusUp] = (counts[statusUp] ?? 0) + 1;
      } else if (statusRaw.isNotEmpty) {
        counts[statusRaw] = (counts[statusRaw] ?? 0) + 1;
      }

      final fechada =
          statusUp == 'CONCLUÍDA' || statusUp == 'CANCELADA';
      if (fechada) continue;

      abertas++;
      final ref = _dataReferenciaStatus(row);
      if (ref == null) continue;
      final dias = now.difference(ref).inDays;
      if (dias < 0) continue;

      _SlaRisco risco = _SlaRisco.ok;
      if (dias > 5) {
        risco = _SlaRisco.critico;
        critico++;
      } else if (dias > 3) {
        risco = _SlaRisco.atencao;
        atencao++;
      }

      if (risco != _SlaRisco.ok) {
        paradas.add(_SlaItem(
          osNumber: _osNumero(row),
          cliente: (row['CLIENTE'] ?? '').toString().trim(),
          status: statusRaw.isEmpty ? 'SEM STATUS' : statusRaw,
          dias: dias,
          risco: risco,
          row: row,
        ));
      }
    }

    paradas.sort((a, b) {
      final r = b.risco.index.compareTo(a.risco.index);
      if (r != 0) return r;
      return b.dias.compareTo(a.dias);
    });

    _avgDays = stats.avgDays;
    _abertas = abertas;
    _atencao = atencao;
    _critico = critico;
    _porStatus = counts;
    _paradas = paradas;
  }

  /// Data de referência alinhada à home (+5 dias via INICIO/DATA).
  DateTime? _dataReferenciaStatus(Map<String, dynamic> row) {
    return parseOsDate(row['ULTIMAATUALIZACAO']) ??
        parseOsDate(row['DATASTATUS']) ??
        parseOsDate(row['DATAATUALIZACAO']) ??
        parseOsDate(row['updated_at']) ??
        parseOsDate(row['INICIO']) ??
        parseOsDate(row['DATA']);
  }

  String _osNumero(Map<String, dynamic> row) {
    final a = (row['NUMERODAOS'] ?? '').toString().trim();
    if (a.isNotEmpty) return a;
    return (row['NUMERO_OS'] ?? '').toString().trim();
  }

  Color _riscoCor(_SlaRisco r) {
    switch (r) {
      case _SlaRisco.critico:
        return HpsUi.error;
      case _SlaRisco.atencao:
        return const Color(0xFFC2410C);
      case _SlaRisco.ok:
        return HpsUi.success;
    }
  }

  String _riscoLabel(_SlaRisco r) {
    switch (r) {
      case _SlaRisco.critico:
        return 'Crítico';
      case _SlaRisco.atencao:
        return 'Atenção';
      case _SlaRisco.ok:
        return 'No prazo';
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
                      : RefreshIndicator(
                          color: HpsUi.accent,
                          backgroundColor: HpsUi.surface,
                          onRefresh: _carregar,
                          child: ListView(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                            children: [
                              _buildResumo(),
                              const SizedBox(height: 16),
                              _buildContagens(),
                              const SizedBox(height: 16),
                              _buildListaParadas(),
                            ],
                          ),
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
              color: HpsUi.accent.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.timer_outlined, color: HpsUi.accent, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SLA e alertas',
                  style: GoogleFonts.interTight(
                    color: HpsUi.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Atenção >3 dias · Crítico >5 dias',
                  style: GoogleFonts.inter(
                    color: HpsUi.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Atualizar',
            onPressed: _loading ? null : _carregar,
            icon: const Icon(Icons.refresh_rounded, color: HpsUi.textSecondary),
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

  Widget _buildResumo() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _metricCard(
          'Tempo médio',
          formatOsAvgDays(_avgDays),
          Icons.av_timer_outlined,
          HpsUi.accent,
        ),
        _metricCard(
          'O.S. abertas',
          '$_abertas',
          Icons.assignment_outlined,
          const Color(0xFF0369A1),
        ),
        _metricCard(
          'Atenção',
          '$_atencao',
          Icons.warning_amber_rounded,
          const Color(0xFFC2410C),
        ),
        _metricCard(
          'Crítico',
          '$_critico',
          Icons.priority_high_rounded,
          HpsUi.error,
        ),
      ],
    );
  }

  Widget _metricCard(String label, String value, IconData icon, Color accent) {
    return SizedBox(
      width: 158,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
        decoration: BoxDecoration(
          color: HpsUi.surface.withOpacity(0.85),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: accent),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      color: HpsUi.textMuted,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: GoogleFonts.interTight(
                color: HpsUi.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContagens() {
    final entries = _porStatus.entries
        .where((e) => e.value > 0)
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: HpsUi.surface.withOpacity(0.85),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Contagem por status',
            style: GoogleFonts.interTight(
              color: HpsUi.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          if (entries.isEmpty)
            Text(
              'Nenhuma O.S. encontrada.',
              style: GoogleFonts.inter(color: HpsUi.textMuted, fontSize: 13),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: entries.map((e) {
                final label = _kStatusLabels[e.key] ?? e.key;
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: HpsUi.inputFill,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.06)),
                  ),
                  child: Text(
                    '$label · ${e.value}',
                    style: GoogleFonts.inter(
                      color: HpsUi.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildListaParadas() {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
      decoration: BoxDecoration(
        color: HpsUi.surface.withOpacity(0.85),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'O.S. paradas / risco de atraso',
            style: GoogleFonts.interTight(
              color: HpsUi.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Dias no status atual (ou desde a abertura)',
            style: GoogleFonts.inter(
              color: HpsUi.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          if (_paradas.isEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                'Nenhuma O.S. em atenção ou crítica no momento.',
                style: GoogleFonts.inter(color: HpsUi.textMuted, fontSize: 13),
              ),
            )
          else
            ..._paradas.map(_buildParadaTile),
        ],
      ),
    );
  }

  Widget _buildParadaTile(_SlaItem item) {
    final cor = _riscoCor(item.risco);
    final os = item.osNumber.isEmpty ? '—' : item.osNumber;
    final cliente = item.cliente.isEmpty ? '—' : item.cliente;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: HpsUi.inputFill.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cor.withOpacity(0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            height: 42,
            decoration: BoxDecoration(
              color: cor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'O.S. #$os',
                  style: GoogleFonts.interTight(
                    color: HpsUi.textPrimary,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  cliente,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    color: HpsUi.textSecondary,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.status,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    color: HpsUi.textMuted,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${item.dias} dias',
                style: GoogleFonts.interTight(
                  color: cor,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: cor.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _riscoLabel(item.risco),
                  style: GoogleFonts.inter(
                    color: cor,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
