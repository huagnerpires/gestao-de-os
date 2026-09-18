import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class AreaRestritaRecord extends FirestoreRecord {
  AreaRestritaRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "ID_DO_CELULAR" field.
  String? _idDoCelular;
  String get idDoCelular => _idDoCelular ?? '';
  bool hasIdDoCelular() => _idDoCelular != null;

  // "PERMISSAO" field.
  bool? _permissao;
  bool get permissao => _permissao ?? false;
  bool hasPermissao() => _permissao != null;

  // "NOMEDOUSUARIO" field.
  String? _nomedousuario;
  String get nomedousuario => _nomedousuario ?? '';
  bool hasNomedousuario() => _nomedousuario != null;

  void _initializeFields() {
    _idDoCelular = snapshotData['ID_DO_CELULAR'] as String?;
    _permissao = snapshotData['PERMISSAO'] as bool?;
    _nomedousuario = snapshotData['NOMEDOUSUARIO'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('AREA_RESTRITA');

  static Stream<AreaRestritaRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => AreaRestritaRecord.fromSnapshot(s));

  static Future<AreaRestritaRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => AreaRestritaRecord.fromSnapshot(s));

  static AreaRestritaRecord fromSnapshot(DocumentSnapshot snapshot) =>
      AreaRestritaRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static AreaRestritaRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      AreaRestritaRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'AreaRestritaRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is AreaRestritaRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createAreaRestritaRecordData({
  String? idDoCelular,
  bool? permissao,
  String? nomedousuario,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'ID_DO_CELULAR': idDoCelular,
      'PERMISSAO': permissao,
      'NOMEDOUSUARIO': nomedousuario,
    }.withoutNulls,
  );

  return firestoreData;
}

class AreaRestritaRecordDocumentEquality
    implements Equality<AreaRestritaRecord> {
  const AreaRestritaRecordDocumentEquality();

  @override
  bool equals(AreaRestritaRecord? e1, AreaRestritaRecord? e2) {
    return e1?.idDoCelular == e2?.idDoCelular &&
        e1?.permissao == e2?.permissao &&
        e1?.nomedousuario == e2?.nomedousuario;
  }

  @override
  int hash(AreaRestritaRecord? e) => const ListEquality()
      .hash([e?.idDoCelular, e?.permissao, e?.nomedousuario]);

  @override
  bool isValidKey(Object? o) => o is AreaRestritaRecord;
}
