import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class ImagensRecord extends FirestoreRecord {
  ImagensRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "MES" field.
  String? _mes;
  String get mes => _mes ?? '';
  bool hasMes() => _mes != null;

  // "ANO" field.
  int? _ano;
  int get ano => _ano ?? 0;
  bool hasAno() => _ano != null;

  // "IMAGEM" field.
  String? _imagem;
  String get imagem => _imagem ?? '';
  bool hasImagem() => _imagem != null;

  // "DATA" field.
  DateTime? _data;
  DateTime? get data => _data;
  bool hasData() => _data != null;

  // "FIXA" field.
  bool? _fixa;
  bool get fixa => _fixa ?? false;
  bool hasFixa() => _fixa != null;

  // "TIPO" field.
  String? _tipo;
  String get tipo => _tipo ?? '';
  bool hasTipo() => _tipo != null;

  // "VIDEO" field.
  String? _video;
  String get video => _video ?? '';
  bool hasVideo() => _video != null;

  // "CATEGORIA" field.
  String? _categoria;
  String get categoria => _categoria ?? '';
  bool hasCategoria() => _categoria != null;

  // "PATRIMONIO" field.
  String? _patrimonio;
  String get patrimonio => _patrimonio ?? '';
  bool hasPatrimonio() => _patrimonio != null;

  void _initializeFields() {
    _mes = snapshotData['MES'] as String?;
    _ano = castToType<int>(snapshotData['ANO']);
    _imagem = snapshotData['IMAGEM'] as String?;
    _data = snapshotData['DATA'] as DateTime?;
    _fixa = snapshotData['FIXA'] as bool?;
    _tipo = snapshotData['TIPO'] as String?;
    _video = snapshotData['VIDEO'] as String?;
    _categoria = snapshotData['CATEGORIA'] as String?;
    _patrimonio = snapshotData['PATRIMONIO'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('IMAGENS');

  static Stream<ImagensRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => ImagensRecord.fromSnapshot(s));

  static Future<ImagensRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => ImagensRecord.fromSnapshot(s));

  static ImagensRecord fromSnapshot(DocumentSnapshot snapshot) =>
      ImagensRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static ImagensRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      ImagensRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'ImagensRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is ImagensRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createImagensRecordData({
  String? mes,
  int? ano,
  String? imagem,
  DateTime? data,
  bool? fixa,
  String? tipo,
  String? video,
  String? categoria,
  String? patrimonio,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'MES': mes,
      'ANO': ano,
      'IMAGEM': imagem,
      'DATA': data,
      'FIXA': fixa,
      'TIPO': tipo,
      'VIDEO': video,
      'CATEGORIA': categoria,
      'PATRIMONIO': patrimonio,
    }.withoutNulls,
  );

  return firestoreData;
}

class ImagensRecordDocumentEquality implements Equality<ImagensRecord> {
  const ImagensRecordDocumentEquality();

  @override
  bool equals(ImagensRecord? e1, ImagensRecord? e2) {
    return e1?.mes == e2?.mes &&
        e1?.ano == e2?.ano &&
        e1?.imagem == e2?.imagem &&
        e1?.data == e2?.data &&
        e1?.fixa == e2?.fixa &&
        e1?.tipo == e2?.tipo &&
        e1?.video == e2?.video &&
        e1?.categoria == e2?.categoria &&
        e1?.patrimonio == e2?.patrimonio;
  }

  @override
  int hash(ImagensRecord? e) => const ListEquality().hash([
        e?.mes,
        e?.ano,
        e?.imagem,
        e?.data,
        e?.fixa,
        e?.tipo,
        e?.video,
        e?.categoria,
        e?.patrimonio
      ]);

  @override
  bool isValidKey(Object? o) => o is ImagensRecord;
}
