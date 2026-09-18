import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class PreventivasRecord extends FirestoreRecord {
  PreventivasRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "NDATERMOGRAFIA" field.
  String? _ndatermografia;
  String get ndatermografia => _ndatermografia ?? '';
  bool hasNdatermografia() => _ndatermografia != null;

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

  // "LAVAGEMDOFILTRO" field.
  bool? _lavagemdofiltro;
  bool get lavagemdofiltro => _lavagemdofiltro ?? false;
  bool hasLavagemdofiltro() => _lavagemdofiltro != null;

  // "LIMPEZACOMBACTERICIDA" field.
  bool? _limpezacombactericida;
  bool get limpezacombactericida => _limpezacombactericida ?? false;
  bool hasLimpezacombactericida() => _limpezacombactericida != null;

  // "LAVAGEMDATURBINA" field.
  bool? _lavagemdaturbina;
  bool get lavagemdaturbina => _lavagemdaturbina ?? false;
  bool hasLavagemdaturbina() => _lavagemdaturbina != null;

  // "VERIFICACAODERUIDOS" field.
  bool? _verificacaoderuidos;
  bool get verificacaoderuidos => _verificacaoderuidos ?? false;
  bool hasVerificacaoderuidos() => _verificacaoderuidos != null;

  // "LAVAGEMDACONDENSADORA" field.
  bool? _lavagemdacondensadora;
  bool get lavagemdacondensadora => _lavagemdacondensadora ?? false;
  bool hasLavagemdacondensadora() => _lavagemdacondensadora != null;

  // "TERMOGRAFIA" field.
  bool? _termografia;
  bool get termografia => _termografia ?? false;
  bool hasTermografia() => _termografia != null;

  // "VERIFICACAODOSACABAMENTOS" field.
  bool? _verificacaodosacabamentos;
  bool get verificacaodosacabamentos => _verificacaodosacabamentos ?? false;
  bool hasVerificacaodosacabamentos() => _verificacaodosacabamentos != null;

  // "ANO" field.
  int? _ano;
  int get ano => _ano ?? 0;
  bool hasAno() => _ano != null;

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

  // "TENSAO" field.
  String? _tensao;
  String get tensao => _tensao ?? '';
  bool hasTensao() => _tensao != null;

  // "AMPERAGEM" field.
  String? _amperagem;
  String get amperagem => _amperagem ?? '';
  bool hasAmperagem() => _amperagem != null;

  // "TIPO" field.
  String? _tipo;
  String get tipo => _tipo ?? '';
  bool hasTipo() => _tipo != null;

  // "NUMERO_OS" field.
  int? _numeroOs;
  int get numeroOs => _numeroOs ?? 0;
  bool hasNumeroOs() => _numeroOs != null;

  // "PATRIMONIO" field.
  String? _patrimonio;
  String get patrimonio => _patrimonio ?? '';
  bool hasPatrimonio() => _patrimonio != null;

  // "LIMPEZADAEVAPORADORA" field.
  bool? _limpezadaevaporadora;
  bool get limpezadaevaporadora => _limpezadaevaporadora ?? false;
  bool hasLimpezadaevaporadora() => _limpezadaevaporadora != null;

  // "VERIFICAODODRENO" field.
  bool? _verificaododreno;
  bool get verificaododreno => _verificaododreno ?? false;
  bool hasVerificaododreno() => _verificaododreno != null;

  // "VERIFICAODOSACABAMENTOS" field.
  bool? _verificaodosacabamentos;
  bool get verificaodosacabamentos => _verificaodosacabamentos ?? false;
  bool hasVerificaodosacabamentos() => _verificaodosacabamentos != null;

  // "VERIFICAODERUIDOS" field.
  bool? _verificaoderuidos;
  bool get verificaoderuidos => _verificaoderuidos ?? false;
  bool hasVerificaoderuidos() => _verificaoderuidos != null;

  // "VERIFICAODOISOLAMENTOTRMICO" field.
  bool? _verificaodoisolamentotrmico;
  bool get verificaodoisolamentotrmico => _verificaodoisolamentotrmico ?? false;
  bool hasVerificaodoisolamentotrmico() => _verificaodoisolamentotrmico != null;

  // "IMAGEM" field.
  String? _imagem;
  String get imagem => _imagem ?? '';
  bool hasImagem() => _imagem != null;

  // "JATEAMENTODACONDENSADOR" field.
  bool? _jateamentodacondensador;
  bool get jateamentodacondensador => _jateamentodacondensador ?? false;
  bool hasJateamentodacondensador() => _jateamentodacondensador != null;

  // "JATEAMENTODAEVAPORADORA" field.
  bool? _jateamentodaevaporadora;
  bool get jateamentodaevaporadora => _jateamentodaevaporadora ?? false;
  bool hasJateamentodaevaporadora() => _jateamentodaevaporadora != null;

  // "LAVAGEMDODRENO" field.
  bool? _lavagemdodreno;
  bool get lavagemdodreno => _lavagemdodreno ?? false;
  bool hasLavagemdodreno() => _lavagemdodreno != null;

  // "LAVAGEMDACARCAACONDENSADOR" field.
  bool? _lavagemdacarcaacondensador;
  bool get lavagemdacarcaacondensador => _lavagemdacarcaacondensador ?? false;
  bool hasLavagemdacarcaacondensador() => _lavagemdacarcaacondensador != null;

  // "LIMPEZAELUBRIFICAODOCOMPRESSO" field.
  bool? _limpezaelubrificaodocompresso;
  bool get limpezaelubrificaodocompresso =>
      _limpezaelubrificaodocompresso ?? false;
  bool hasLimpezaelubrificaodocompresso() =>
      _limpezaelubrificaodocompresso != null;

  // "LAVAGEMDACARCAAEVAPORADORA" field.
  bool? _lavagemdacarcaaevaporadora;
  bool get lavagemdacarcaaevaporadora => _lavagemdacarcaaevaporadora ?? false;
  bool hasLavagemdacarcaaevaporadora() => _lavagemdacarcaaevaporadora != null;

  // "OBSERVACAO" field.
  String? _observacao;
  String get observacao => _observacao ?? '';
  bool hasObservacao() => _observacao != null;

  // "SETOR" field.
  String? _setor;
  String get setor => _setor ?? '';
  bool hasSetor() => _setor != null;

  // "PILHAS" field.
  bool? _pilhas;
  bool get pilhas => _pilhas ?? false;
  bool hasPilhas() => _pilhas != null;

  // "PSI" field.
  bool? _psi;
  bool get psi => _psi ?? false;
  bool hasPsi() => _psi != null;

  void _initializeFields() {
    _ndatermografia = snapshotData['NDATERMOGRAFIA'] as String?;
    _equipamento = snapshotData['EQUIPAMENTO'] as String?;
    _marca = snapshotData['MARCA'] as String?;
    _modelo = snapshotData['MODELO'] as String?;
    _btus = snapshotData['BTUS'] as String?;
    _sala = snapshotData['SALA'] as String?;
    _lavagemdofiltro = snapshotData['LAVAGEMDOFILTRO'] as bool?;
    _limpezacombactericida = snapshotData['LIMPEZACOMBACTERICIDA'] as bool?;
    _lavagemdaturbina = snapshotData['LAVAGEMDATURBINA'] as bool?;
    _verificacaoderuidos = snapshotData['VERIFICACAODERUIDOS'] as bool?;
    _lavagemdacondensadora = snapshotData['LAVAGEMDACONDENSADORA'] as bool?;
    _termografia = snapshotData['TERMOGRAFIA'] as bool?;
    _verificacaodosacabamentos =
        snapshotData['VERIFICACAODOSACABAMENTOS'] as bool?;
    _ano = castToType<int>(snapshotData['ANO']);
    _email = snapshotData['EMAIL'] as String?;
    _fluido = snapshotData['FLUIDO'] as String?;
    _responsavel = snapshotData['RESPONSAVEL'] as String?;
    _tecnicoresponsavel = snapshotData['TECNICORESPONSAVEL'] as String?;
    _datadamanutencao = snapshotData['DATADAMANUTENCAO'] as DateTime?;
    _descricaodoservico = snapshotData['DESCRICAODOSERVICO'] as String?;
    _mes = snapshotData['MES'] as String?;
    _nome = snapshotData['NOME'] as String?;
    _tensao = snapshotData['TENSAO'] as String?;
    _amperagem = snapshotData['AMPERAGEM'] as String?;
    _tipo = snapshotData['TIPO'] as String?;
    _numeroOs = castToType<int>(snapshotData['NUMERO_OS']);
    _patrimonio = snapshotData['PATRIMONIO'] as String?;
    _limpezadaevaporadora = snapshotData['LIMPEZADAEVAPORADORA'] as bool?;
    _verificaododreno = snapshotData['VERIFICAODODRENO'] as bool?;
    _verificaodosacabamentos = snapshotData['VERIFICAODOSACABAMENTOS'] as bool?;
    _verificaoderuidos = snapshotData['VERIFICAODERUIDOS'] as bool?;
    _verificaodoisolamentotrmico =
        snapshotData['VERIFICAODOISOLAMENTOTRMICO'] as bool?;
    _imagem = snapshotData['IMAGEM'] as String?;
    _jateamentodacondensador = snapshotData['JATEAMENTODACONDENSADOR'] as bool?;
    _jateamentodaevaporadora = snapshotData['JATEAMENTODAEVAPORADORA'] as bool?;
    _lavagemdodreno = snapshotData['LAVAGEMDODRENO'] as bool?;
    _lavagemdacarcaacondensador =
        snapshotData['LAVAGEMDACARCAACONDENSADOR'] as bool?;
    _limpezaelubrificaodocompresso =
        snapshotData['LIMPEZAELUBRIFICAODOCOMPRESSO'] as bool?;
    _lavagemdacarcaaevaporadora =
        snapshotData['LAVAGEMDACARCAAEVAPORADORA'] as bool?;
    _observacao = snapshotData['OBSERVACAO'] as String?;
    _setor = snapshotData['SETOR'] as String?;
    _pilhas = snapshotData['PILHAS'] as bool?;
    _psi = snapshotData['PSI'] as bool?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('PREVENTIVAS');

  static Stream<PreventivasRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => PreventivasRecord.fromSnapshot(s));

  static Future<PreventivasRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => PreventivasRecord.fromSnapshot(s));

  static PreventivasRecord fromSnapshot(DocumentSnapshot snapshot) =>
      PreventivasRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static PreventivasRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      PreventivasRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'PreventivasRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is PreventivasRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createPreventivasRecordData({
  String? ndatermografia,
  String? equipamento,
  String? marca,
  String? modelo,
  String? btus,
  String? sala,
  bool? lavagemdofiltro,
  bool? limpezacombactericida,
  bool? lavagemdaturbina,
  bool? verificacaoderuidos,
  bool? lavagemdacondensadora,
  bool? termografia,
  bool? verificacaodosacabamentos,
  int? ano,
  String? email,
  String? fluido,
  String? responsavel,
  String? tecnicoresponsavel,
  DateTime? datadamanutencao,
  String? descricaodoservico,
  String? mes,
  String? nome,
  String? tensao,
  String? amperagem,
  String? tipo,
  int? numeroOs,
  String? patrimonio,
  bool? limpezadaevaporadora,
  bool? verificaododreno,
  bool? verificaodosacabamentos,
  bool? verificaoderuidos,
  bool? verificaodoisolamentotrmico,
  String? imagem,
  bool? jateamentodacondensador,
  bool? jateamentodaevaporadora,
  bool? lavagemdodreno,
  bool? lavagemdacarcaacondensador,
  bool? limpezaelubrificaodocompresso,
  bool? lavagemdacarcaaevaporadora,
  String? observacao,
  String? setor,
  bool? pilhas,
  bool? psi,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'NDATERMOGRAFIA': ndatermografia,
      'EQUIPAMENTO': equipamento,
      'MARCA': marca,
      'MODELO': modelo,
      'BTUS': btus,
      'SALA': sala,
      'LAVAGEMDOFILTRO': lavagemdofiltro,
      'LIMPEZACOMBACTERICIDA': limpezacombactericida,
      'LAVAGEMDATURBINA': lavagemdaturbina,
      'VERIFICACAODERUIDOS': verificacaoderuidos,
      'LAVAGEMDACONDENSADORA': lavagemdacondensadora,
      'TERMOGRAFIA': termografia,
      'VERIFICACAODOSACABAMENTOS': verificacaodosacabamentos,
      'ANO': ano,
      'EMAIL': email,
      'FLUIDO': fluido,
      'RESPONSAVEL': responsavel,
      'TECNICORESPONSAVEL': tecnicoresponsavel,
      'DATADAMANUTENCAO': datadamanutencao,
      'DESCRICAODOSERVICO': descricaodoservico,
      'MES': mes,
      'NOME': nome,
      'TENSAO': tensao,
      'AMPERAGEM': amperagem,
      'TIPO': tipo,
      'NUMERO_OS': numeroOs,
      'PATRIMONIO': patrimonio,
      'LIMPEZADAEVAPORADORA': limpezadaevaporadora,
      'VERIFICAODODRENO': verificaododreno,
      'VERIFICAODOSACABAMENTOS': verificaodosacabamentos,
      'VERIFICAODERUIDOS': verificaoderuidos,
      'VERIFICAODOISOLAMENTOTRMICO': verificaodoisolamentotrmico,
      'IMAGEM': imagem,
      'JATEAMENTODACONDENSADOR': jateamentodacondensador,
      'JATEAMENTODAEVAPORADORA': jateamentodaevaporadora,
      'LAVAGEMDODRENO': lavagemdodreno,
      'LAVAGEMDACARCAACONDENSADOR': lavagemdacarcaacondensador,
      'LIMPEZAELUBRIFICAODOCOMPRESSO': limpezaelubrificaodocompresso,
      'LAVAGEMDACARCAAEVAPORADORA': lavagemdacarcaaevaporadora,
      'OBSERVACAO': observacao,
      'SETOR': setor,
      'PILHAS': pilhas,
      'PSI': psi,
    }.withoutNulls,
  );

  return firestoreData;
}

class PreventivasRecordDocumentEquality implements Equality<PreventivasRecord> {
  const PreventivasRecordDocumentEquality();

  @override
  bool equals(PreventivasRecord? e1, PreventivasRecord? e2) {
    return e1?.ndatermografia == e2?.ndatermografia &&
        e1?.equipamento == e2?.equipamento &&
        e1?.marca == e2?.marca &&
        e1?.modelo == e2?.modelo &&
        e1?.btus == e2?.btus &&
        e1?.sala == e2?.sala &&
        e1?.lavagemdofiltro == e2?.lavagemdofiltro &&
        e1?.limpezacombactericida == e2?.limpezacombactericida &&
        e1?.lavagemdaturbina == e2?.lavagemdaturbina &&
        e1?.verificacaoderuidos == e2?.verificacaoderuidos &&
        e1?.lavagemdacondensadora == e2?.lavagemdacondensadora &&
        e1?.termografia == e2?.termografia &&
        e1?.verificacaodosacabamentos == e2?.verificacaodosacabamentos &&
        e1?.ano == e2?.ano &&
        e1?.email == e2?.email &&
        e1?.fluido == e2?.fluido &&
        e1?.responsavel == e2?.responsavel &&
        e1?.tecnicoresponsavel == e2?.tecnicoresponsavel &&
        e1?.datadamanutencao == e2?.datadamanutencao &&
        e1?.descricaodoservico == e2?.descricaodoservico &&
        e1?.mes == e2?.mes &&
        e1?.nome == e2?.nome &&
        e1?.tensao == e2?.tensao &&
        e1?.amperagem == e2?.amperagem &&
        e1?.tipo == e2?.tipo &&
        e1?.numeroOs == e2?.numeroOs &&
        e1?.patrimonio == e2?.patrimonio &&
        e1?.limpezadaevaporadora == e2?.limpezadaevaporadora &&
        e1?.verificaododreno == e2?.verificaododreno &&
        e1?.verificaodosacabamentos == e2?.verificaodosacabamentos &&
        e1?.verificaoderuidos == e2?.verificaoderuidos &&
        e1?.verificaodoisolamentotrmico == e2?.verificaodoisolamentotrmico &&
        e1?.imagem == e2?.imagem &&
        e1?.jateamentodacondensador == e2?.jateamentodacondensador &&
        e1?.jateamentodaevaporadora == e2?.jateamentodaevaporadora &&
        e1?.lavagemdodreno == e2?.lavagemdodreno &&
        e1?.lavagemdacarcaacondensador == e2?.lavagemdacarcaacondensador &&
        e1?.limpezaelubrificaodocompresso ==
            e2?.limpezaelubrificaodocompresso &&
        e1?.lavagemdacarcaaevaporadora == e2?.lavagemdacarcaaevaporadora &&
        e1?.observacao == e2?.observacao &&
        e1?.setor == e2?.setor &&
        e1?.pilhas == e2?.pilhas &&
        e1?.psi == e2?.psi;
  }

  @override
  int hash(PreventivasRecord? e) => const ListEquality().hash([
        e?.ndatermografia,
        e?.equipamento,
        e?.marca,
        e?.modelo,
        e?.btus,
        e?.sala,
        e?.lavagemdofiltro,
        e?.limpezacombactericida,
        e?.lavagemdaturbina,
        e?.verificacaoderuidos,
        e?.lavagemdacondensadora,
        e?.termografia,
        e?.verificacaodosacabamentos,
        e?.ano,
        e?.email,
        e?.fluido,
        e?.responsavel,
        e?.tecnicoresponsavel,
        e?.datadamanutencao,
        e?.descricaodoservico,
        e?.mes,
        e?.nome,
        e?.tensao,
        e?.amperagem,
        e?.tipo,
        e?.numeroOs,
        e?.patrimonio,
        e?.limpezadaevaporadora,
        e?.verificaododreno,
        e?.verificaodosacabamentos,
        e?.verificaoderuidos,
        e?.verificaodoisolamentotrmico,
        e?.imagem,
        e?.jateamentodacondensador,
        e?.jateamentodaevaporadora,
        e?.lavagemdodreno,
        e?.lavagemdacarcaacondensador,
        e?.limpezaelubrificaodocompresso,
        e?.lavagemdacarcaaevaporadora,
        e?.observacao,
        e?.setor,
        e?.pilhas,
        e?.psi
      ]);

  @override
  bool isValidKey(Object? o) => o is PreventivasRecord;
}
