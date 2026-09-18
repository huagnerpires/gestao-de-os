import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class EquipamentosEmpresaRecord extends FirestoreRecord {
  EquipamentosEmpresaRecord._(
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

  // "NOME" field.
  String? _nome;
  String get nome => _nome ?? '';
  bool hasNome() => _nome != null;

  // "TENSAO" field.
  String? _tensao;
  String get tensao => _tensao ?? '';
  bool hasTensao() => _tensao != null;

  // "TIPO" field.
  String? _tipo;
  String get tipo => _tipo ?? '';
  bool hasTipo() => _tipo != null;

  // "numero_pesquisa" field.
  String? _numeroPesquisa;
  String get numeroPesquisa => _numeroPesquisa ?? '';
  bool hasNumeroPesquisa() => _numeroPesquisa != null;

  // "RESPONSAVEL" field.
  String? _responsavel;
  String get responsavel => _responsavel ?? '';
  bool hasResponsavel() => _responsavel != null;

  // "PATRIMONIO" field.
  String? _patrimonio;
  String get patrimonio => _patrimonio ?? '';
  bool hasPatrimonio() => _patrimonio != null;

  // "SETOR" field.
  String? _setor;
  String get setor => _setor ?? '';
  bool hasSetor() => _setor != null;

  // "CONTRATO" field.
  bool? _contrato;
  bool get contrato => _contrato ?? false;
  bool hasContrato() => _contrato != null;

  void _initializeFields() {
    _equipamento = snapshotData['EQUIPAMENTO'] as String?;
    _marca = snapshotData['MARCA'] as String?;
    _modelo = snapshotData['MODELO'] as String?;
    _btus = snapshotData['BTUS'] as String?;
    _sala = snapshotData['SALA'] as String?;
    _email = snapshotData['EMAIL'] as String?;
    _fluido = snapshotData['FLUIDO'] as String?;
    _nome = snapshotData['NOME'] as String?;
    _tensao = snapshotData['TENSAO'] as String?;
    _tipo = snapshotData['TIPO'] as String?;
    _numeroPesquisa = snapshotData['numero_pesquisa'] as String?;
    _responsavel = snapshotData['RESPONSAVEL'] as String?;
    _patrimonio = snapshotData['PATRIMONIO'] as String?;
    _setor = snapshotData['SETOR'] as String?;
    _contrato = snapshotData['CONTRATO'] as bool?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('EQUIPAMENTOS_EMPRESA');

  static Stream<EquipamentosEmpresaRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => EquipamentosEmpresaRecord.fromSnapshot(s));

  static Future<EquipamentosEmpresaRecord> getDocumentOnce(
          DocumentReference ref) =>
      ref.get().then((s) => EquipamentosEmpresaRecord.fromSnapshot(s));

  static EquipamentosEmpresaRecord fromSnapshot(DocumentSnapshot snapshot) =>
      EquipamentosEmpresaRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static EquipamentosEmpresaRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      EquipamentosEmpresaRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'EquipamentosEmpresaRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is EquipamentosEmpresaRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createEquipamentosEmpresaRecordData({
  String? equipamento,
  String? marca,
  String? modelo,
  String? btus,
  String? sala,
  String? email,
  String? fluido,
  String? nome,
  String? tensao,
  String? tipo,
  String? numeroPesquisa,
  String? responsavel,
  String? patrimonio,
  String? setor,
  bool? contrato,
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
      'NOME': nome,
      'TENSAO': tensao,
      'TIPO': tipo,
      'numero_pesquisa': numeroPesquisa,
      'RESPONSAVEL': responsavel,
      'PATRIMONIO': patrimonio,
      'SETOR': setor,
      'CONTRATO': contrato,
    }.withoutNulls,
  );

  return firestoreData;
}

class EquipamentosEmpresaRecordDocumentEquality
    implements Equality<EquipamentosEmpresaRecord> {
  const EquipamentosEmpresaRecordDocumentEquality();

  @override
  bool equals(EquipamentosEmpresaRecord? e1, EquipamentosEmpresaRecord? e2) {
    return e1?.equipamento == e2?.equipamento &&
        e1?.marca == e2?.marca &&
        e1?.modelo == e2?.modelo &&
        e1?.btus == e2?.btus &&
        e1?.sala == e2?.sala &&
        e1?.email == e2?.email &&
        e1?.fluido == e2?.fluido &&
        e1?.nome == e2?.nome &&
        e1?.tensao == e2?.tensao &&
        e1?.tipo == e2?.tipo &&
        e1?.numeroPesquisa == e2?.numeroPesquisa &&
        e1?.responsavel == e2?.responsavel &&
        e1?.patrimonio == e2?.patrimonio &&
        e1?.setor == e2?.setor &&
        e1?.contrato == e2?.contrato;
  }

  @override
  int hash(EquipamentosEmpresaRecord? e) => const ListEquality().hash([
        e?.equipamento,
        e?.marca,
        e?.modelo,
        e?.btus,
        e?.sala,
        e?.email,
        e?.fluido,
        e?.nome,
        e?.tensao,
        e?.tipo,
        e?.numeroPesquisa,
        e?.responsavel,
        e?.patrimonio,
        e?.setor,
        e?.contrato
      ]);

  @override
  bool isValidKey(Object? o) => o is EquipamentosEmpresaRecord;
}
