import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class PontosPorTecnicoRecord extends FirestoreRecord {
  PontosPorTecnicoRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "TECNICO" field.
  String? _tecnico;
  String get tecnico => _tecnico ?? '';
  bool hasTecnico() => _tecnico != null;

  // "FOTO" field.
  String? _foto;
  String get foto => _foto ?? '';
  bool hasFoto() => _foto != null;

  // "SENHA" field.
  String? _senha;
  String get senha => _senha ?? '';
  bool hasSenha() => _senha != null;

  // "PONTOS" field.
  double? _pontos;
  double get pontos => _pontos ?? 0.0;
  bool hasPontos() => _pontos != null;

  void _initializeFields() {
    _tecnico = snapshotData['TECNICO'] as String?;
    _foto = snapshotData['FOTO'] as String?;
    _senha = snapshotData['SENHA'] as String?;
    _pontos = castToType<double>(snapshotData['PONTOS']);
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('PONTOS_POR_TECNICO');

  static Stream<PontosPorTecnicoRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => PontosPorTecnicoRecord.fromSnapshot(s));

  static Future<PontosPorTecnicoRecord> getDocumentOnce(
          DocumentReference ref) =>
      ref.get().then((s) => PontosPorTecnicoRecord.fromSnapshot(s));

  static PontosPorTecnicoRecord fromSnapshot(DocumentSnapshot snapshot) =>
      PontosPorTecnicoRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static PontosPorTecnicoRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      PontosPorTecnicoRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'PontosPorTecnicoRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is PontosPorTecnicoRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createPontosPorTecnicoRecordData({
  String? tecnico,
  String? foto,
  String? senha,
  double? pontos,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'TECNICO': tecnico,
      'FOTO': foto,
      'SENHA': senha,
      'PONTOS': pontos,
    }.withoutNulls,
  );

  return firestoreData;
}

class PontosPorTecnicoRecordDocumentEquality
    implements Equality<PontosPorTecnicoRecord> {
  const PontosPorTecnicoRecordDocumentEquality();

  @override
  bool equals(PontosPorTecnicoRecord? e1, PontosPorTecnicoRecord? e2) {
    return e1?.tecnico == e2?.tecnico &&
        e1?.foto == e2?.foto &&
        e1?.senha == e2?.senha &&
        e1?.pontos == e2?.pontos;
  }

  @override
  int hash(PontosPorTecnicoRecord? e) =>
      const ListEquality().hash([e?.tecnico, e?.foto, e?.senha, e?.pontos]);

  @override
  bool isValidKey(Object? o) => o is PontosPorTecnicoRecord;
}
