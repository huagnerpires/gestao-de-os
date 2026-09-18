import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class EquipamentoscadastroRecord extends FirestoreRecord {
  EquipamentoscadastroRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "EQUIPAMENTOS" field.
  String? _equipamentos;
  String get equipamentos => _equipamentos ?? '';
  bool hasEquipamentos() => _equipamentos != null;

  void _initializeFields() {
    _equipamentos = snapshotData['EQUIPAMENTOS'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('EQUIPAMENTOSCADASTRO');

  static Stream<EquipamentoscadastroRecord> getDocument(
          DocumentReference ref) =>
      ref.snapshots().map((s) => EquipamentoscadastroRecord.fromSnapshot(s));

  static Future<EquipamentoscadastroRecord> getDocumentOnce(
          DocumentReference ref) =>
      ref.get().then((s) => EquipamentoscadastroRecord.fromSnapshot(s));

  static EquipamentoscadastroRecord fromSnapshot(DocumentSnapshot snapshot) =>
      EquipamentoscadastroRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static EquipamentoscadastroRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      EquipamentoscadastroRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'EquipamentoscadastroRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is EquipamentoscadastroRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createEquipamentoscadastroRecordData({
  String? equipamentos,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'EQUIPAMENTOS': equipamentos,
    }.withoutNulls,
  );

  return firestoreData;
}

class EquipamentoscadastroRecordDocumentEquality
    implements Equality<EquipamentoscadastroRecord> {
  const EquipamentoscadastroRecordDocumentEquality();

  @override
  bool equals(EquipamentoscadastroRecord? e1, EquipamentoscadastroRecord? e2) {
    return e1?.equipamentos == e2?.equipamentos;
  }

  @override
  int hash(EquipamentoscadastroRecord? e) =>
      const ListEquality().hash([e?.equipamentos]);

  @override
  bool isValidKey(Object? o) => o is EquipamentoscadastroRecord;
}
