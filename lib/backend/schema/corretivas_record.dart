import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class CorretivasRecord extends FirestoreRecord {
  CorretivasRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "EQUIPAMENTO" field.
  String? _equipamento;
  String get equipamento => _equipamento ?? '';
  bool hasEquipamento() => _equipamento != null;

  // "MARCA" field.
  String? _marca;
  String get marca => _marca ?? '';
  bool hasMarca() => _marca != null;

  // "MODELO" field.
  String? _modelo;
  String get modelo => _modelo ?? '';
  bool hasModelo() => _modelo != null;

  // "BTUS" field.
  String? _btus;
  String get btus => _btus ?? '';
  bool hasBtus() => _btus != null;

  // "SALA" field.
  String? _sala;
  String get sala => _sala ?? '';
  bool hasSala() => _sala != null;

  // "EMAIL" field.
  String? _email;
  String get email => _email ?? '';
  bool hasEmail() => _email != null;

  // "FLUIDO" field.
  String? _fluido;
  String get fluido => _fluido ?? '';
  bool hasFluido() => _fluido != null;

  // "RESPONSAVEL" field.
  String? _responsavel;
  String get responsavel => _responsavel ?? '';
  bool hasResponsavel() => _responsavel != null;

  // "TECNICORESPONSAVEL" field.
  String? _tecnicoresponsavel;
  String get tecnicoresponsavel => _tecnicoresponsavel ?? '';
  bool hasTecnicoresponsavel() => _tecnicoresponsavel != null;

  // "DATADAMANUTENCAO" field.
  DateTime? _datadamanutencao;
  DateTime? get datadamanutencao => _datadamanutencao;
  bool hasDatadamanutencao() => _datadamanutencao != null;

  // "DESCRICAODOSERVICO" field.
  String? _descricaodoservico;
  String get descricaodoservico => _descricaodoservico ?? '';
  bool hasDescricaodoservico() => _descricaodoservico != null;

  // "MES" field.
  String? _mes;
  String get mes => _mes ?? '';
  bool hasMes() => _mes != null;

  // "NOME" field.
  String? _nome;
  String get nome => _nome ?? '';
  bool hasNome() => _nome != null;

  // "STATUS" field.
  String? _status;
  String get status => _status ?? '';
  bool hasStatus() => _status != null;

  // "DATA_TERMINO" field.
  String? _dataTermino;
  String get dataTermino => _dataTermino ?? '';
  bool hasDataTermino() => _dataTermino != null;

  // "TIPO" field.
  String? _tipo;
  String get tipo => _tipo ?? '';
  bool hasTipo() => _tipo != null;

  // "NUMERO_OS" field.
  String? _numeroOs;
  String get numeroOs => _numeroOs ?? '';
  bool hasNumeroOs() => _numeroOs != null;

  // "ANO" field.
  String? _ano;
  String get ano => _ano ?? '';
  bool hasAno() => _ano != null;

  // "PATRIMONIO" field.
  String? _patrimonio;
  String get patrimonio => _patrimonio ?? '';
  bool hasPatrimonio() => _patrimonio != null;

  // "SERVICOREALIZADO" field.
  String? _servicorealizado;
  String get servicorealizado => _servicorealizado ?? '';
  bool hasServicorealizado() => _servicorealizado != null;

  // "SETOR" field.
  String? _setor;
  String get setor => _setor ?? '';
  bool hasSetor() => _setor != null;

  // "DEFEITO" field.
  String? _defeito;
  String get defeito => _defeito ?? '';
  bool hasDefeito() => _defeito != null;

  // "VALOR" field.
  List<double>? _valor;
  List<double> get valor => _valor ?? const [];
  bool hasValor() => _valor != null;

  // "PECAS" field.
  List<String>? _pecas;
  List<String> get pecas => _pecas ?? const [];
  bool hasPecas() => _pecas != null;

  // "QUANTIDADE" field.
  double? _quantidade;
  double get quantidade => _quantidade ?? 0.0;
  bool hasQuantidade() => _quantidade != null;

  void _initializeFields() {
    _equipamento = snapshotData['EQUIPAMENTO'] as String?;
    _marca = snapshotData['MARCA'] as String?;
    _modelo = snapshotData['MODELO'] as String?;
    _btus = snapshotData['BTUS'] as String?;
    _sala = snapshotData['SALA'] as String?;
    _email = snapshotData['EMAIL'] as String?;
    _fluido = snapshotData['FLUIDO'] as String?;
    _responsavel = snapshotData['RESPONSAVEL'] as String?;
    _tecnicoresponsavel = snapshotData['TECNICORESPONSAVEL'] as String?;
    _datadamanutencao = snapshotData['DATADAMANUTENCAO'] as DateTime?;
    _descricaodoservico = snapshotData['DESCRICAODOSERVICO'] as String?;
    _mes = snapshotData['MES'] as String?;
    _nome = snapshotData['NOME'] as String?;
    _status = snapshotData['STATUS'] as String?;
    _dataTermino = snapshotData['DATA_TERMINO'] as String?;
    _tipo = snapshotData['TIPO'] as String?;
    _numeroOs = snapshotData['NUMERO_OS'] as String?;
    _ano = snapshotData['ANO'] as String?;
    _patrimonio = snapshotData['PATRIMONIO'] as String?;
    _servicorealizado = snapshotData['SERVICOREALIZADO'] as String?;
    _setor = snapshotData['SETOR'] as String?;
    _defeito = snapshotData['DEFEITO'] as String?;
    _valor = getDataList(snapshotData['VALOR']);
    _pecas = getDataList(snapshotData['PECAS']);
    _quantidade = castToType<double>(snapshotData['QUANTIDADE']);
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('CORRETIVAS');

  static Stream<CorretivasRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => CorretivasRecord.fromSnapshot(s));

  static Future<CorretivasRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => CorretivasRecord.fromSnapshot(s));

  static CorretivasRecord fromSnapshot(DocumentSnapshot snapshot) =>
      CorretivasRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static CorretivasRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      CorretivasRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'CorretivasRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is CorretivasRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createCorretivasRecordData({
  String? equipamento,
  String? marca,
  String? modelo,
  String? btus,
  String? sala,
  String? email,
  String? fluido,
  String? responsavel,
  String? tecnicoresponsavel,
  DateTime? datadamanutencao,
  String? descricaodoservico,
  String? mes,
  String? nome,
  String? status,
  String? dataTermino,
  String? tipo,
  String? numeroOs,
  String? ano,
  String? patrimonio,
  String? servicorealizado,
  String? setor,
  String? defeito,
  double? quantidade,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'EQUIPAMENTO': equipamento,
      'MARCA': marca,
      'MODELO': modelo,
      'BTUS': btus,
      'SALA': sala,
      'EMAIL': email,
      'FLUIDO': fluido,
      'RESPONSAVEL': responsavel,
      'TECNICORESPONSAVEL': tecnicoresponsavel,
      'DATADAMANUTENCAO': datadamanutencao,
      'DESCRICAODOSERVICO': descricaodoservico,
      'MES': mes,
      'NOME': nome,
      'STATUS': status,
      'DATA_TERMINO': dataTermino,
      'TIPO': tipo,
      'NUMERO_OS': numeroOs,
      'ANO': ano,
      'PATRIMONIO': patrimonio,
      'SERVICOREALIZADO': servicorealizado,
      'SETOR': setor,
      'DEFEITO': defeito,
      'QUANTIDADE': quantidade,
    }.withoutNulls,
  );

  return firestoreData;
}

class CorretivasRecordDocumentEquality implements Equality<CorretivasRecord> {
  const CorretivasRecordDocumentEquality();

  @override
  bool equals(CorretivasRecord? e1, CorretivasRecord? e2) {
    const listEquality = ListEquality();
    return e1?.equipamento == e2?.equipamento &&
        e1?.marca == e2?.marca &&
        e1?.modelo == e2?.modelo &&
        e1?.btus == e2?.btus &&
        e1?.sala == e2?.sala &&
        e1?.email == e2?.email &&
        e1?.fluido == e2?.fluido &&
        e1?.responsavel == e2?.responsavel &&
        e1?.tecnicoresponsavel == e2?.tecnicoresponsavel &&
        e1?.datadamanutencao == e2?.datadamanutencao &&
        e1?.descricaodoservico == e2?.descricaodoservico &&
        e1?.mes == e2?.mes &&
        e1?.nome == e2?.nome &&
        e1?.status == e2?.status &&
        e1?.dataTermino == e2?.dataTermino &&
        e1?.tipo == e2?.tipo &&
        e1?.numeroOs == e2?.numeroOs &&
        e1?.ano == e2?.ano &&
        e1?.patrimonio == e2?.patrimonio &&
        e1?.servicorealizado == e2?.servicorealizado &&
        e1?.setor == e2?.setor &&
        e1?.defeito == e2?.defeito &&
        listEquality.equals(e1?.valor, e2?.valor) &&
        listEquality.equals(e1?.pecas, e2?.pecas) &&
        e1?.quantidade == e2?.quantidade;
  }

  @override
  int hash(CorretivasRecord? e) => const ListEquality().hash([
        e?.equipamento,
        e?.marca,
        e?.modelo,
        e?.btus,
        e?.sala,
        e?.email,
        e?.fluido,
        e?.responsavel,
        e?.tecnicoresponsavel,
        e?.datadamanutencao,
        e?.descricaodoservico,
        e?.mes,
        e?.nome,
        e?.status,
        e?.dataTermino,
        e?.tipo,
        e?.numeroOs,
        e?.ano,
        e?.patrimonio,
        e?.servicorealizado,
        e?.setor,
        e?.defeito,
        e?.valor,
        e?.pecas,
        e?.quantidade
      ]);

  @override
  bool isValidKey(Object? o) => o is CorretivasRecord;
}
