import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'hps_sheet.dart';

/// Interpreta datas de O.S. no formato BR (não usa [DateTime.tryParse] sozinho).
DateTime? parseOsDate(dynamic v) {
  if (v == null) return null;
  if (v is DateTime) return v;
  if (v is Timestamp) return v.toDate();
  if (v is num) {
    final n = v.toInt();
    if (n <= 0) return null;
    if (n < 100000000000) {
      return DateTime.fromMillisecondsSinceEpoch(n * 1000);
    }
    return DateTime.fromMillisecondsSinceEpoch(n);
  }
  if (v is Map) {
    final seconds = v['_seconds'] ?? v['seconds'];
    if (seconds is num) {
      final nanos = v['_nanoseconds'] ?? v['nanoseconds'] ?? 0;
      final nano = nanos is num ? nanos.toInt() : 0;
      return DateTime.fromMillisecondsSinceEpoch(
        seconds.toInt() * 1000 + (nano ~/ 1000000),
      );
    }
  }

  final raw = v.toString().trim().replaceAll(RegExp(r'\s+'), ' ');
  if (raw.isEmpty || raw.toLowerCase() == 'null') return null;

  final withYear = RegExp(
    r'^(\d{1,2})/(\d{1,2})/(\d{2,4})(?:[ T](\d{1,2}):(\d{2})(?::(\d{2}))?)?$',
  );
  final noYear = RegExp(
    r'^(\d{1,2})/(\d{1,2})[ T](\d{1,2}):(\d{2})(?::(\d{2}))?$',
  );

  final yMatch = withYear.firstMatch(raw);
  if (yMatch != null) {
    return _osDateFromParts(
      int.parse(yMatch.group(1)!),
      int.parse(yMatch.group(2)!),
      int.parse(yMatch.group(3)!),
      int.parse(yMatch.group(4) ?? '0'),
      int.parse(yMatch.group(5) ?? '0'),
      int.parse(yMatch.group(6) ?? '0'),
    );
  }

  final nMatch = noYear.firstMatch(raw);
  if (nMatch != null) {
    final now = DateTime.now();
    return _osDateFromParts(
      int.parse(nMatch.group(1)!),
      int.parse(nMatch.group(2)!),
      now.year,
      int.parse(nMatch.group(3)!),
      int.parse(nMatch.group(4)!),
      int.parse(nMatch.group(5) ?? '0'),
    );
  }

  // ISO só depois dos padrões BR — tryParse sozinho quebraria dd/MM/yyyy.
  if (RegExp(r'^\d{4}-\d{2}-\d{2}').hasMatch(raw)) {
    return DateTime.tryParse(raw);
  }
  return null;
}

DateTime? _osDateFromParts(
  int day,
  int month,
  int year, [
  int hour = 0,
  int minute = 0,
  int second = 0,
]) {
  if (month < 1 || month > 12 || day < 1 || day > 31) return null;
  if (hour > 23 || minute > 59 || second > 59) return null;
  var y = year;
  if (y < 100) y += 2000;
  final dt = DateTime(y, month, day, hour, minute, second);
  if (dt.year != y || dt.month != month || dt.day != day) return null;
  return dt;
}

class OsStaleItem {
  const OsStaleItem({
    required this.osNumber,
    required this.cliente,
    required this.daysOpen,
    required this.status,
    required this.row,
  });

  final String osNumber;
  final String cliente;
  final int daysOpen;
  final String status;
  final Map<String, dynamic> row;
}

class OsTempoStats {
  const OsTempoStats({
    this.avgDays,
    this.concludedCount = 0,
    this.stale = const [],
  });

  final double? avgDays;
  final int concludedCount;
  final List<OsStaleItem> stale;
}

String formatOsAvgDays(double? avgDays) {
  if (avgDays == null) return '—';
  final one = (avgDays * 10).round() / 10.0;
  if (one == one.roundToDouble()) {
    return '${one.round()} dias';
  }
  return '${one.toStringAsFixed(1).replaceAll('.', ',')} dias';
}

String _osNumero(Map<String, dynamic> row) {
  final a = (row['NUMERODAOS'] ?? '').toString().trim();
  if (a.isNotEmpty) return a;
  return (row['NUMERO_OS'] ?? '').toString().trim();
}

bool _isClosedStatus(String status) =>
    status == 'CONCLUÍDA' || status == 'CANCELADA';

OsTempoStats computeOsTempo(List<Map<String, dynamic>> rows) {
  final now = DateTime.now();
  final durations = <double>[];
  final stale = <OsStaleItem>[];

  for (final row in rows) {
    final statusRaw = (row['STATUS'] ?? '').toString().trim();
    final status = statusRaw.toUpperCase();

    if (status == 'CONCLUÍDA') {
      final inicio = parseOsDate(row['INICIO']);
      final termino = parseOsDate(row['TERMINO']);
      if (inicio != null && termino != null) {
        final days = termino.difference(inicio).inMilliseconds /
            Duration.millisecondsPerDay;
        if (days >= 0) durations.add(days);
      }
    }

    if (!_isClosedStatus(status)) {
      final abertura = parseOsDate(row['INICIO']) ?? parseOsDate(row['DATA']);
      if (abertura == null) continue;
      final daysOpen = now.difference(abertura).inDays;
      if (daysOpen > 5) {
        stale.add(OsStaleItem(
          osNumber: _osNumero(row),
          cliente: (row['CLIENTE'] ?? '').toString().trim(),
          daysOpen: daysOpen,
          status: statusRaw.isEmpty ? 'SEM STATUS' : statusRaw,
          row: Map<String, dynamic>.from(row),
        ));
      }
    }
  }

  stale.sort((a, b) => b.daysOpen.compareTo(a.daysOpen));

  return OsTempoStats(
    avgDays: durations.isEmpty
        ? null
        : durations.reduce((a, b) => a + b) / durations.length,
    concludedCount: durations.length,
    stale: stale,
  );
}

/// Popup uma vez por sessão. [force] reabre pelo chip (ignora o flag).
/// [onOpen] recebe o mapa original da O.S. após fechar o popup.
Future<void> maybeShowOsStaleDialog(
  BuildContext context,
  List<OsStaleItem> stale, {
  bool force = false,
  void Function(Map<String, dynamic> row)? onOpen,
}) async {
  if (stale.isEmpty) return;
  if (!force && _OsStaleDialog._shown) return;
  if (!force) _OsStaleDialog._shown = true;
  if (!context.mounted) return;

  final selected = await showHpsSheet<Map<String, dynamic>>(
    context,
    compact: true,
    title: 'O.S. atrasadas',
    child: _OsStaleDialog(stale: stale),
  );
  if (selected != null && context.mounted) {
    onOpen?.call(selected);
  }
}

Future<void> showOsStaleDialog(
  BuildContext context,
  List<OsStaleItem> stale, {
  void Function(Map<String, dynamic> row)? onOpen,
}) {
  return maybeShowOsStaleDialog(
    context,
    stale,
    force: true,
    onOpen: onOpen,
  );
}

class _OsStaleDialog extends StatelessWidget {
  const _OsStaleDialog({required this.stale});

  static bool _shown = false;

  final List<OsStaleItem> stale;

  @override
  Widget build(BuildContext context) {
    final maxH =
        (MediaQuery.sizeOf(context).height * 0.42).clamp(140.0, 320.0);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Abertas há mais de 5 dias',
            style: GoogleFonts.inter(
              color: HpsUi.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Toque em uma O.S. para visualizar',
            style: GoogleFonts.inter(
              color: HpsUi.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxH),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: stale.length,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                color: Colors.white.withOpacity(0.08),
              ),
              itemBuilder: (context, i) {
                final item = stale[i];
                final os = item.osNumber.isEmpty ? '—' : item.osNumber;
                final cliente = item.cliente.isEmpty ? '—' : item.cliente;
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => Navigator.of(context).pop(item.row),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 4,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 72,
                            child: Text(
                              '#$os',
                              style: GoogleFonts.interTight(
                                color: HpsUi.accent,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  cliente,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.inter(
                                    color: HpsUi.textPrimary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
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
                          Text(
                            '${item.daysOpen} dias',
                            style: GoogleFonts.interTight(
                              color: HpsUi.error,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.chevron_right_rounded,
                            size: 20,
                            color: HpsUi.textMuted,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 44,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [HpsUi.buttonStart, HpsUi.buttonEnd],
                ),
                borderRadius: BorderRadius.circular(HpsUi.radiusControl),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(HpsUi.radiusControl),
                  onTap: () => Navigator.of(context).maybePop(),
                  child: Center(
                    child: Text(
                      'Entendi',
                      style: GoogleFonts.interTight(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
