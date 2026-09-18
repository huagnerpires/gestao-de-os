import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class TermografiaRecord extends FirestoreRecord {
  TermografiaRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "TERMOGRAFIA" field.
  int? _termografia;
  int get termografia => _termografia ?? 0;
  bool hasTermografia() => _termografia != null;

  // "EMAIL" field.
  String? _email;
  String get email => _email ?? '';
  bool hasEmail() => _email != null;

  // "MES" field.
  String? _mes;
  String get mes => _mes ?? '';
  bool hasMes() => _mes != null;

  // "patrimonio_pesquisa" field.
  String? _patrimonioPesquisa;
  String get patrimonioPesquisa => _patrimonioPesquisa ?? '';
  bool hasPatrimonioPesquisa() => _patrimonioPesquisa != null;

  // "PATRIMONIO" field.
  String? _patrimonio;
  String get patrimonio => _patrimonio ?? '';
  bool hasPatrimonio() => _patrimonio != null;

  void _initializeFields() {
    _termografia = castToType<int>(snapshotData['TERMOGRAFIA']);
    _email = snapshotData['EMAIL'] as String?;
    _mes = snapshotData['MES'] as String?;
    _patrimonioPesquisa = snapshotData['patrimonio_pesquisa'] as String?;
    _patrimonio = snapshotData['PATRIMONIO'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('TERMOGRAFIA');

  static Stream<TermografiaRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => TermografiaRecord.fromSnapshot(s));

  static Future<TermografiaRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => TermografiaRecord.fromSnapshot(s));

  static TermografiaRecord fromSnapshot(DocumentSnapshot snapshot) =>
      TermografiaRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static TermografiaRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      TermografiaRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'TermografiaRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is TermografiaRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createTermografiaRecordData({
  int? termografia,
  String? email,
  String? mes,
  String? patrimonioPesquisa,
  String? patrimonio,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'TERMOGRAFIA': termografia,
      'EMAIL': email,
      'MES': mes,
      'patrimonio_pesquisa': patrimonioPesquisa,
      'PATRIMONIO': patrimonio,
    }.withoutNulls,
  );

  return firestoreData;
}

class TermografiaRecordDocumentEquality implements Equality<TermografiaRecord> {
  const TermografiaRecordDocumentEquality();

  @override
  bool equals(TermografiaRecord? e1, TermografiaRecord? e2) {
    return e1?.termografia == e2?.termografia &&
        e1?.email == e2?.email &&
        e1?.mes == e2?.mes &&
        e1?.patrimonioPesquisa == e2?.patrimonioPesquisa &&
        e1?.patrimonio == e2?.patrimonio;
  }

  @override
  int hash(TermografiaRecord? e) => const ListEquality().hash(
      [e?.termografia, e?.email, e?.mes, e?.patrimonioPesquisa, e?.patrimonio]);

  @override
  bool isValidKey(Object? o) => o is TermografiaRecord;
}
