import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class HistoricoDasOsRecord extends FirestoreRecord {
  HistoricoDasOsRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "SERVICO" field.
  String? _servico;
  String get servico => _servico ?? '';
  bool hasServico() => _servico != null;

  // "EQUIPAMENTO" field.
  String? _equipamento;
  String get equipamento => _equipamento ?? '';
  bool hasEquipamento() => _equipamento != null;

  // "TECNICO" field.
  String? _tecnico;
  String get tecnico => _tecnico ?? '';
  bool hasTecnico() => _tecnico != null;

  // "NUMERODAOS" field.
  String? _numerodaos;
  String get numerodaos => _numerodaos ?? '';
  bool hasNumerodaos() => _numerodaos != null;

  // "STATUS" field.
  String? _status;
  String get status => _status ?? '';
  bool hasStatus() => _status != null;

  // "PONTOS" field.
  double? _pontos;
  double get pontos => _pontos ?? 0.0;
  bool hasPontos() => _pontos != null;

  // "TERMINO" field.
  String? _termino;
  String get termino => _termino ?? '';
  bool hasTermino() => _termino != null;

  // "INICIO" field.
  String? _inicio;
  String get inicio => _inicio ?? '';
  bool hasInicio() => _inicio != null;

  // "CLIENTE" field.
  String? _cliente;
  String get cliente => _cliente ?? '';
  bool hasCliente() => _cliente != null;

  // "MES" field.
  String? _mes;
  String get mes => _mes ?? '';
  bool hasMes() => _mes != null;

  void _initializeFields() {
    _servico = snapshotData['SERVICO'] as String?;
    _equipamento = snapshotData['EQUIPAMENTO'] as String?;
    _tecnico = snapshotData['TECNICO'] as String?;
    _numerodaos = snapshotData['NUMERODAOS'] as String?;
    _status = snapshotData['STATUS'] as String?;
    _pontos = castToType<double>(snapshotData['PONTOS']);
    _termino = snapshotData['TERMINO'] as String?;
    _inicio = snapshotData['INICIO'] as String?;
    _cliente = snapshotData['CLIENTE'] as String?;
    _mes = snapshotData['MES'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('HISTORICO_DAS_OS');

  static Stream<HistoricoDasOsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => HistoricoDasOsRecord.fromSnapshot(s));

  static Future<HistoricoDasOsRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => HistoricoDasOsRecord.fromSnapshot(s));

  static HistoricoDasOsRecord fromSnapshot(DocumentSnapshot snapshot) =>
      HistoricoDasOsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static HistoricoDasOsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      HistoricoDasOsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'HistoricoDasOsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is HistoricoDasOsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createHistoricoDasOsRecordData({
  String? servico,
  String? equipamento,
  String? tecnico,
  String? numerodaos,
  String? status,
  double? pontos,
  String? termino,
  String? inicio,
  String? cliente,
  String? mes,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'SERVICO': servico,
      'EQUIPAMENTO': equipamento,
      'TECNICO': tecnico,
      'NUMERODAOS': numerodaos,
      'STATUS': status,
      'PONTOS': pontos,
      'TERMINO': termino,
      'INICIO': inicio,
      'CLIENTE': cliente,
      'MES': mes,
    }.withoutNulls,
  );

  return firestoreData;
}

class HistoricoDasOsRecordDocumentEquality
    implements Equality<HistoricoDasOsRecord> {
  const HistoricoDasOsRecordDocumentEquality();

  @override
  bool equals(HistoricoDasOsRecord? e1, HistoricoDasOsRecord? e2) {
    return e1?.servico == e2?.servico &&
        e1?.equipamento == e2?.equipamento &&
        e1?.tecnico == e2?.tecnico &&
        e1?.numerodaos == e2?.numerodaos &&
        e1?.status == e2?.status &&
        e1?.pontos == e2?.pontos &&
        e1?.termino == e2?.termino &&
        e1?.inicio == e2?.inicio &&
        e1?.cliente == e2?.cliente &&
        e1?.mes == e2?.mes;
  }

  @override
  int hash(HistoricoDasOsRecord? e) => const ListEquality().hash([
        e?.servico,
        e?.equipamento,
        e?.tecnico,
        e?.numerodaos,
        e?.status,
        e?.pontos,
        e?.termino,
        e?.inicio,
        e?.cliente,
        e?.mes
      ]);

  @override
  bool isValidKey(Object? o) => o is HistoricoDasOsRecord;
}
