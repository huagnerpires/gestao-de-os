import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class ServicosrealizadosRecord extends FirestoreRecord {
  ServicosrealizadosRecord._(
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

  // "TERMINO" field.
  String? _termino;
  String get termino => _termino ?? '';
  bool hasTermino() => _termino != null;

  // "CLIENTE" field.
  String? _cliente;
  String get cliente => _cliente ?? '';
  bool hasCliente() => _cliente != null;

  // "MES" field.
  String? _mes;
  String get mes => _mes ?? '';
  bool hasMes() => _mes != null;

  // "DATA" field.
  DateTime? _data;
  DateTime? get data => _data;
  bool hasData() => _data != null;

  // "PONTOS" field.
  double? _pontos;
  double get pontos => _pontos ?? 0.0;
  bool hasPontos() => _pontos != null;

  // "DESCRICAO" field.
  String? _descricao;
  String get descricao => _descricao ?? '';
  bool hasDescricao() => _descricao != null;

  // "PATRIMONIO" field.
  String? _patrimonio;
  String get patrimonio => _patrimonio ?? '';
  bool hasPatrimonio() => _patrimonio != null;

  // "PECA" field.
  String? _peca;
  String get peca => _peca ?? '';
  bool hasPeca() => _peca != null;

  // "CADASTRO" field.
  String? _cadastro;
  String get cadastro => _cadastro ?? '';
  bool hasCadastro() => _cadastro != null;

  // "EMAIL" field.
  String? _email;
  String get email => _email ?? '';
  bool hasEmail() => _email != null;

  // "EMPRESA" field.
  bool? _empresa;
  bool get empresa => _empresa ?? false;
  bool hasEmpresa() => _empresa != null;

  // "INICIO" field.
  String? _inicio;
  String get inicio => _inicio ?? '';
  bool hasInicio() => _inicio != null;

  // "SERVICOREALIZADO" field.
  String? _servicorealizado;
  String get servicorealizado => _servicorealizado ?? '';
  bool hasServicorealizado() => _servicorealizado != null;

  // "SETOR" field.
  String? _setor;
  String get setor => _setor ?? '';
  bool hasSetor() => _setor != null;

  // "SALA" field.
  String? _sala;
  String get sala => _sala ?? '';
  bool hasSala() => _sala != null;

  void _initializeFields() {
    _servico = snapshotData['SERVICO'] as String?;
    _equipamento = snapshotData['EQUIPAMENTO'] as String?;
    _tecnico = snapshotData['TECNICO'] as String?;
    _numerodaos = snapshotData['NUMERODAOS'] as String?;
    _status = snapshotData['STATUS'] as String?;
    _termino = snapshotData['TERMINO'] as String?;
    _cliente = snapshotData['CLIENTE'] as String?;
    _mes = snapshotData['MES'] as String?;
    _data = snapshotData['DATA'] as DateTime?;
    _pontos = castToType<double>(snapshotData['PONTOS']);
    _descricao = snapshotData['DESCRICAO'] as String?;
    _patrimonio = snapshotData['PATRIMONIO'] as String?;
    _peca = snapshotData['PECA'] as String?;
    _cadastro = snapshotData['CADASTRO'] as String?;
    _email = snapshotData['EMAIL'] as String?;
    _empresa = snapshotData['EMPRESA'] as bool?;
    _inicio = snapshotData['INICIO'] as String?;
    _servicorealizado = snapshotData['SERVICOREALIZADO'] as String?;
    _setor = snapshotData['SETOR'] as String?;
    _sala = snapshotData['SALA'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('SERVICOSREALIZADOS');

  static Stream<ServicosrealizadosRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => ServicosrealizadosRecord.fromSnapshot(s));

  static Future<ServicosrealizadosRecord> getDocumentOnce(
          DocumentReference ref) =>
      ref.get().then((s) => ServicosrealizadosRecord.fromSnapshot(s));

  static ServicosrealizadosRecord fromSnapshot(DocumentSnapshot snapshot) =>
      ServicosrealizadosRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static ServicosrealizadosRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      ServicosrealizadosRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'ServicosrealizadosRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is ServicosrealizadosRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createServicosrealizadosRecordData({
  String? servico,
  String? equipamento,
  String? tecnico,
  String? numerodaos,
  String? status,
  String? termino,
  String? cliente,
  String? mes,
  DateTime? data,
  double? pontos,
  String? descricao,
  String? patrimonio,
  String? peca,
  String? cadastro,
  String? email,
  bool? empresa,
  String? inicio,
  String? servicorealizado,
  String? setor,
  String? sala,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'SERVICO': servico,
      'EQUIPAMENTO': equipamento,
      'TECNICO': tecnico,
      'NUMERODAOS': numerodaos,
      'STATUS': status,
      'TERMINO': termino,
      'CLIENTE': cliente,
      'MES': mes,
      'DATA': data,
      'PONTOS': pontos,
      'DESCRICAO': descricao,
      'PATRIMONIO': patrimonio,
      'PECA': peca,
      'CADASTRO': cadastro,
      'EMAIL': email,
      'EMPRESA': empresa,
      'INICIO': inicio,
      'SERVICOREALIZADO': servicorealizado,
      'SETOR': setor,
      'SALA': sala,
    }.withoutNulls,
  );

  return firestoreData;
}

class ServicosrealizadosRecordDocumentEquality
    implements Equality<ServicosrealizadosRecord> {
  const ServicosrealizadosRecordDocumentEquality();

  @override
  bool equals(ServicosrealizadosRecord? e1, ServicosrealizadosRecord? e2) {
    return e1?.servico == e2?.servico &&
        e1?.equipamento == e2?.equipamento &&
        e1?.tecnico == e2?.tecnico &&
        e1?.numerodaos == e2?.numerodaos &&
        e1?.status == e2?.status &&
        e1?.termino == e2?.termino &&
        e1?.cliente == e2?.cliente &&
        e1?.mes == e2?.mes &&
        e1?.data == e2?.data &&
        e1?.pontos == e2?.pontos &&
        e1?.descricao == e2?.descricao &&
        e1?.patrimonio == e2?.patrimonio &&
        e1?.peca == e2?.peca &&
        e1?.cadastro == e2?.cadastro &&
        e1?.email == e2?.email &&
        e1?.empresa == e2?.empresa &&
        e1?.inicio == e2?.inicio &&
        e1?.servicorealizado == e2?.servicorealizado &&
        e1?.setor == e2?.setor &&
        e1?.sala == e2?.sala;
  }

  @override
  int hash(ServicosrealizadosRecord? e) => const ListEquality().hash([
        e?.servico,
        e?.equipamento,
        e?.tecnico,
        e?.numerodaos,
        e?.status,
        e?.termino,
        e?.cliente,
        e?.mes,
        e?.data,
        e?.pontos,
        e?.descricao,
        e?.patrimonio,
        e?.peca,
        e?.cadastro,
        e?.email,
        e?.empresa,
        e?.inicio,
        e?.servicorealizado,
        e?.setor,
        e?.sala
      ]);

  @override
  bool isValidKey(Object? o) => o is ServicosrealizadosRecord;
}
