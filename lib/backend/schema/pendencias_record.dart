import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class PendenciasRecord extends FirestoreRecord {
  PendenciasRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "equipamento" field.
  String? _equipamento;
  String get equipamento => _equipamento ?? '';
  bool hasEquipamento() => _equipamento != null;

  void _initializeFields() {
    _equipamento = snapshotData['equipamento'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('PENDENCIAS');

  static Stream<PendenciasRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => PendenciasRecord.fromSnapshot(s));

  static Future<PendenciasRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => PendenciasRecord.fromSnapshot(s));

  static PendenciasRecord fromSnapshot(DocumentSnapshot snapshot) =>
      PendenciasRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static PendenciasRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      PendenciasRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'PendenciasRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is PendenciasRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createPendenciasRecordData({
  String? equipamento,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'equipamento': equipamento,
    }.withoutNulls,
  );

  return firestoreData;
}

class PendenciasRecordDocumentEquality implements Equality<PendenciasRecord> {
  const PendenciasRecordDocumentEquality();

  @override
  bool equals(PendenciasRecord? e1, PendenciasRecord? e2) {
    return e1?.equipamento == e2?.equipamento;
  }

  @override
  int hash(PendenciasRecord? e) => const ListEquality().hash([e?.equipamento]);

  @override
  bool isValidKey(Object? o) => o is PendenciasRecord;
}
