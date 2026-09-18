import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class ListaChatRecord extends FirestoreRecord {
  ListaChatRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "nome" field.
  String? _nome;
  String get nome => _nome ?? '';
  bool hasNome() => _nome != null;

  // "email" field.
  String? _email;
  String get email => _email ?? '';
  bool hasEmail() => _email != null;

  // "nova_mensagem" field.
  bool? _novaMensagem;
  bool get novaMensagem => _novaMensagem ?? false;
  bool hasNovaMensagem() => _novaMensagem != null;

  void _initializeFields() {
    _nome = snapshotData['nome'] as String?;
    _email = snapshotData['email'] as String?;
    _novaMensagem = snapshotData['nova_mensagem'] as bool?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('lista_chat');

  static Stream<ListaChatRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => ListaChatRecord.fromSnapshot(s));

  static Future<ListaChatRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => ListaChatRecord.fromSnapshot(s));

  static ListaChatRecord fromSnapshot(DocumentSnapshot snapshot) =>
      ListaChatRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static ListaChatRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      ListaChatRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'ListaChatRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is ListaChatRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createListaChatRecordData({
  String? nome,
  String? email,
  bool? novaMensagem,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'nome': nome,
      'email': email,
      'nova_mensagem': novaMensagem,
    }.withoutNulls,
  );

  return firestoreData;
}

class ListaChatRecordDocumentEquality implements Equality<ListaChatRecord> {
  const ListaChatRecordDocumentEquality();

  @override
  bool equals(ListaChatRecord? e1, ListaChatRecord? e2) {
    return e1?.nome == e2?.nome &&
        e1?.email == e2?.email &&
        e1?.novaMensagem == e2?.novaMensagem;
  }

  @override
  int hash(ListaChatRecord? e) =>
      const ListEquality().hash([e?.nome, e?.email, e?.novaMensagem]);

  @override
  bool isValidKey(Object? o) => o is ListaChatRecord;
}
