import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class ManutencaoRecord extends FirestoreRecord {
  ManutencaoRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "STATUS" field.
  String? _status;
  String get status => _status ?? '';
  bool hasStatus() => _status != null;

  // "PREVISAODAPECA" field.
  String? _previsaodapeca;
  String get previsaodapeca => _previsaodapeca ?? '';
  bool hasPrevisaodapeca() => _previsaodapeca != null;

  // "NUMERO_OS" field.
  String? _numeroOs;
  String get numeroOs => _numeroOs ?? '';
  bool hasNumeroOs() => _numeroOs != null;

  // "TECNICORESPONSAVEL" field.
  String? _tecnicoresponsavel;
  String get tecnicoresponsavel => _tecnicoresponsavel ?? '';
  bool hasTecnicoresponsavel() => _tecnicoresponsavel != null;

  // "PATRIMONIO" field.
  String? _patrimonio;
  String get patrimonio => _patrimonio ?? '';
  bool hasPatrimonio() => _patrimonio != null;

  // "MES" field.
  String? _mes;
  String get mes => _mes ?? '';
  bool hasMes() => _mes != null;

  // "NOME" field.
  String? _nome;
  String get nome => _nome ?? '';
  bool hasNome() => _nome != null;

  // "TIPO" field.
  String? _tipo;
  String get tipo => _tipo ?? '';
  bool hasTipo() => _tipo != null;

  // "DATA_TERMINO" field.
  String? _dataTermino;
  String get dataTermino => _dataTermino ?? '';
  bool hasDataTermino() => _dataTermino != null;

  // "DESCRICAODOSERVICO" field.
  String? _descricaodoservico;
  String get descricaodoservico => _descricaodoservico ?? '';
  bool hasDescricaodoservico() => _descricaodoservico != null;

  // "EQUIPAMENTO" field.
  String? _equipamento;
  String get equipamento => _equipamento ?? '';
  bool hasEquipamento() => _equipamento != null;

  // "FLUIDO" field.
  String? _fluido;
  String get fluido => _fluido ?? '';
  bool hasFluido() => _fluido != null;

  // "EMAIL" field.
  String? _email;
  String get email => _email ?? '';
  bool hasEmail() => _email != null;

  // "SALA" field.
  String? _sala;
  String get sala => _sala ?? '';
  bool hasSala() => _sala != null;

  // "MODELO" field.
  String? _modelo;
  String get modelo => _modelo ?? '';
  bool hasModelo() => _modelo != null;

  // "MARCA" field.
  String? _marca;
  String get marca => _marca ?? '';
  bool hasMarca() => _marca != null;

  // "BTUS" field.
  String? _btus;
  String get btus => _btus ?? '';
  bool hasBtus() => _btus != null;

  // "ANO" field.
  int? _ano;
  int get ano => _ano ?? 0;
  bool hasAno() => _ano != null;

  // "RESPONSAVEL" field.
  String? _responsavel;
  String get responsavel => _responsavel ?? '';
  bool hasResponsavel() => _responsavel != null;

  // "DATADAMANUTENCAO" field.
  DateTime? _datadamanutencao;
  DateTime? get datadamanutencao => _datadamanutencao;
  bool hasDatadamanutencao() => _datadamanutencao != null;

  // "Empresa" field.
  bool? _empresa;
  bool get empresa => _empresa ?? false;
  bool hasEmpresa() => _empresa != null;

  // "DEFEITO" field.
  String? _defeito;
  String get defeito => _defeito ?? '';
  bool hasDefeito() => _defeito != null;

  // "SETOR" field.
  String? _setor;
  String get setor => _setor ?? '';
  bool hasSetor() => _setor != null;

  // "PECAS" field.
  List<String>? _pecas;
  List<String> get pecas => _pecas ?? const [];
  bool hasPecas() => _pecas != null;

  // "VALOR" field.
  List<double>? _valor;
  List<double> get valor => _valor ?? const [];
  bool hasValor() => _valor != null;

  // "QUANTIDADE" field.
  List<int>? _quantidade;
  List<int> get quantidade => _quantidade ?? const [];
  bool hasQuantidade() => _quantidade != null;

  void _initializeFields() {
    _status = snapshotData['STATUS'] as String?;
    _previsaodapeca = snapshotData['PREVISAODAPECA'] as String?;
    _numeroOs = snapshotData['NUMERO_OS'] as String?;
    _tecnicoresponsavel = snapshotData['TECNICORESPONSAVEL'] as String?;
    _patrimonio = snapshotData['PATRIMONIO'] as String?;
    _mes = snapshotData['MES'] as String?;
    _nome = snapshotData['NOME'] as String?;
    _tipo = snapshotData['TIPO'] as String?;
    _dataTermino = snapshotData['DATA_TERMINO'] as String?;
    _descricaodoservico = snapshotData['DESCRICAODOSERVICO'] as String?;
    _equipamento = snapshotData['EQUIPAMENTO'] as String?;
    _fluido = snapshotData['FLUIDO'] as String?;
    _email = snapshotData['EMAIL'] as String?;
    _sala = snapshotData['SALA'] as String?;
    _modelo = snapshotData['MODELO'] as String?;
    _marca = snapshotData['MARCA'] as String?;
    _btus = snapshotData['BTUS'] as String?;
    _ano = castToType<int>(snapshotData['ANO']);
    _responsavel = snapshotData['RESPONSAVEL'] as String?;
    _datadamanutencao = snapshotData['DATADAMANUTENCAO'] as DateTime?;
    _empresa = snapshotData['Empresa'] as bool?;
    _defeito = snapshotData['DEFEITO'] as String?;
    _setor = snapshotData['SETOR'] as String?;
    _pecas = getDataList(snapshotData['PECAS']);
    _valor = getDataList(snapshotData['VALOR']);
    _quantidade = getDataList(snapshotData['QUANTIDADE']);
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('MANUTENCAO');

  static Stream<ManutencaoRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => ManutencaoRecord.fromSnapshot(s));

  static Future<ManutencaoRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => ManutencaoRecord.fromSnapshot(s));

  static ManutencaoRecord fromSnapshot(DocumentSnapshot snapshot) =>
      ManutencaoRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static ManutencaoRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      ManutencaoRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'ManutencaoRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is ManutencaoRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createManutencaoRecordData({
  String? status,
  String? previsaodapeca,
  String? numeroOs,
  String? tecnicoresponsavel,
  String? patrimonio,
  String? mes,
  String? nome,
  String? tipo,
  String? dataTermino,
  String? descricaodoservico,
  String? equipamento,
  String? fluido,
  String? email,
  String? sala,
  String? modelo,
  String? marca,
  String? btus,
  int? ano,
  String? responsavel,
  DateTime? datadamanutencao,
  bool? empresa,
  String? defeito,
  String? setor,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'STATUS': status,
      'PREVISAODAPECA': previsaodapeca,
      'NUMERO_OS': numeroOs,
      'TECNICORESPONSAVEL': tecnicoresponsavel,
      'PATRIMONIO': patrimonio,
      'MES': mes,
      'NOME': nome,
      'TIPO': tipo,
      'DATA_TERMINO': dataTermino,
      'DESCRICAODOSERVICO': descricaodoservico,
      'EQUIPAMENTO': equipamento,
      'FLUIDO': fluido,
      'EMAIL': email,
      'SALA': sala,
      'MODELO': modelo,
      'MARCA': marca,
      'BTUS': btus,
      'ANO': ano,
      'RESPONSAVEL': responsavel,
      'DATADAMANUTENCAO': datadamanutencao,
      'Empresa': empresa,
      'DEFEITO': defeito,
      'SETOR': setor,
    }.withoutNulls,
  );

  return firestoreData;
}

class ManutencaoRecordDocumentEquality implements Equality<ManutencaoRecord> {
  const ManutencaoRecordDocumentEquality();

  @override
  bool equals(ManutencaoRecord? e1, ManutencaoRecord? e2) {
    const listEquality = ListEquality();
    return e1?.status == e2?.status &&
        e1?.previsaodapeca == e2?.previsaodapeca &&
        e1?.numeroOs == e2?.numeroOs &&
        e1?.tecnicoresponsavel == e2?.tecnicoresponsavel &&
        e1?.patrimonio == e2?.patrimonio &&
        e1?.mes == e2?.mes &&
        e1?.nome == e2?.nome &&
        e1?.tipo == e2?.tipo &&
        e1?.dataTermino == e2?.dataTermino &&
        e1?.descricaodoservico == e2?.descricaodoservico &&
        e1?.equipamento == e2?.equipamento &&
        e1?.fluido == e2?.fluido &&
        e1?.email == e2?.email &&
        e1?.sala == e2?.sala &&
        e1?.modelo == e2?.modelo &&
        e1?.marca == e2?.marca &&
        e1?.btus == e2?.btus &&
        e1?.ano == e2?.ano &&
        e1?.responsavel == e2?.responsavel &&
        e1?.datadamanutencao == e2?.datadamanutencao &&
        e1?.empresa == e2?.empresa &&
        e1?.defeito == e2?.defeito &&
        e1?.setor == e2?.setor &&
        listEquality.equals(e1?.pecas, e2?.pecas) &&
        listEquality.equals(e1?.valor, e2?.valor) &&
        listEquality.equals(e1?.quantidade, e2?.quantidade);
  }

  @override
  int hash(ManutencaoRecord? e) => const ListEquality().hash([
        e?.status,
        e?.previsaodapeca,
        e?.numeroOs,
        e?.tecnicoresponsavel,
        e?.patrimonio,
        e?.mes,
        e?.nome,
        e?.tipo,
        e?.dataTermino,
        e?.descricaodoservico,
        e?.equipamento,
        e?.fluido,
        e?.email,
        e?.sala,
        e?.modelo,
        e?.marca,
        e?.btus,
        e?.ano,
        e?.responsavel,
        e?.datadamanutencao,
        e?.empresa,
        e?.defeito,
        e?.setor,
        e?.pecas,
        e?.valor,
        e?.quantidade
      ]);

  @override
  bool isValidKey(Object? o) => o is ManutencaoRecord;
}
