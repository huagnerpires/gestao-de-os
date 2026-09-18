import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'hps_sheet.dart';
import 'os_widget.dart';

/// Abre a O.S. em edição/atendimento/orçamento (mesma regra do card).
void openOsEditarSheet(
  BuildContext context,
  Map row,
  FirebaseFirestore db,
  VoidCallback onSaved,
) {
  final os = Map<String, dynamic>.from(row);
  final s = (os['STATUS'] ?? '').toString();
  final t = (os['TECNICORESPONSAVEL'] ?? '').toString();
  final Widget page;
  if (s == 'PASSAR ORÇAMENTO') {
    page = OsOrcamentoPage(os: os, db: db, onSaved: onSaved, embedded: true);
  } else if (t.isEmpty || t == 'NÃO DEFINIDO') {
    page = OsEditPage(os: os, db: db, onSaved: onSaved, embedded: true);
  } else {
    page = OsEditPage(os: os, db: db, onSaved: onSaved, embedded: true);
  }
  showHpsSheet(context, child: page);
}
