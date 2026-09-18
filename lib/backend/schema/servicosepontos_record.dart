import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class ServicosepontosRecord extends FirestoreRecord {
  ServicosepontosRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "SERVICOS" field.
  String? _servicos;
  String get servicos => _servicos ?? '';
  bool hasServicos() => _servicos != null;

  // "PONTOS" field.
  double? _pontos;
  double get pontos => _pontos ?? 0.0;
  bool hasPontos() => _pontos != null;

  void _initializeFields() {
    _servicos = snapshotData['SERVICOS'] as String?;
    _pontos = castToType<double>(snapshotData['PONTOS']);
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('SERVICOSEPONTOS');

  static Stream<ServicosepontosRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => ServicosepontosRecord.fromSnapshot(s));

  static Future<ServicosepontosRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => ServicosepontosRecord.fromSnapshot(s));

  static ServicosepontosRecord fromSnapshot(DocumentSnapshot snapshot) =>
      ServicosepontosRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static ServicosepontosRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      ServicosepontosRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'ServicosepontosRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is ServicosepontosRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createServicosepontosRecordData({
  String? servicos,
  double? pontos,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'SERVICOS': servicos,
      'PONTOS': pontos,
    }.withoutNulls,
  );

  return firestoreData;
}

class ServicosepontosRecordDocumentEquality
    implements Equality<ServicosepontosRecord> {
  const ServicosepontosRecordDocumentEquality();

  @override
  bool equals(ServicosepontosRecord? e1, ServicosepontosRecord? e2) {
    return e1?.servicos == e2?.servicos && e1?.pontos == e2?.pontos;
  }

  @override
  int hash(ServicosepontosRecord? e) =>
      const ListEquality().hash([e?.servicos, e?.pontos]);

  @override
  bool isValidKey(Object? o) => o is ServicosepontosRecord;
}
