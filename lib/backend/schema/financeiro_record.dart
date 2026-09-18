import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class FinanceiroRecord extends FirestoreRecord {
  FinanceiroRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "valor" field.
  double? _valor;
  double get valor => _valor ?? 0.0;
  bool hasValor() => _valor != null;

  void _initializeFields() {
    _valor = castToType<double>(snapshotData['valor']);
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('financeiro');

  static Stream<FinanceiroRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => FinanceiroRecord.fromSnapshot(s));

  static Future<FinanceiroRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => FinanceiroRecord.fromSnapshot(s));

  static FinanceiroRecord fromSnapshot(DocumentSnapshot snapshot) =>
      FinanceiroRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static FinanceiroRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      FinanceiroRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'FinanceiroRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is FinanceiroRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createFinanceiroRecordData({
  double? valor,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'valor': valor,
    }.withoutNulls,
  );

  return firestoreData;
}

class FinanceiroRecordDocumentEquality implements Equality<FinanceiroRecord> {
  const FinanceiroRecordDocumentEquality();

  @override
  bool equals(FinanceiroRecord? e1, FinanceiroRecord? e2) {
    return e1?.valor == e2?.valor;
  }

  @override
  int hash(FinanceiroRecord? e) => const ListEquality().hash([e?.valor]);

  @override
  bool isValidKey(Object? o) => o is FinanceiroRecord;
}
