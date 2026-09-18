import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class ChatRecord extends FirestoreRecord {
  ChatRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "mensagens" field.
  String? _mensagens;
  String get mensagens => _mensagens ?? '';
  bool hasMensagens() => _mensagens != null;

  // "email_cliente" field.
  String? _emailCliente;
  String get emailCliente => _emailCliente ?? '';
  bool hasEmailCliente() => _emailCliente != null;

  // "uid" field.
  String? _uid;
  String get uid => _uid ?? '';
  bool hasUid() => _uid != null;

  // "data" field.
  DateTime? _data;
  DateTime? get data => _data;
  bool hasData() => _data != null;

  // "adm" field.
  bool? _adm;
  bool get adm => _adm ?? false;
  bool hasAdm() => _adm != null;

  // "lida_ou_nao" field.
  bool? _lidaOuNao;
  bool get lidaOuNao => _lidaOuNao ?? false;
  bool hasLidaOuNao() => _lidaOuNao != null;

  void _initializeFields() {
    _mensagens = snapshotData['mensagens'] as String?;
    _emailCliente = snapshotData['email_cliente'] as String?;
    _uid = snapshotData['uid'] as String?;
    _data = snapshotData['data'] as DateTime?;
    _adm = snapshotData['adm'] as bool?;
    _lidaOuNao = snapshotData['lida_ou_nao'] as bool?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('chat');

  static Stream<ChatRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => ChatRecord.fromSnapshot(s));

  static Future<ChatRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => ChatRecord.fromSnapshot(s));

  static ChatRecord fromSnapshot(DocumentSnapshot snapshot) => ChatRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static ChatRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      ChatRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'ChatRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is ChatRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createChatRecordData({
  String? mensagens,
  String? emailCliente,
  String? uid,
  DateTime? data,
  bool? adm,
  bool? lidaOuNao,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'mensagens': mensagens,
      'email_cliente': emailCliente,
      'uid': uid,
      'data': data,
      'adm': adm,
      'lida_ou_nao': lidaOuNao,
    }.withoutNulls,
  );

  return firestoreData;
}

class ChatRecordDocumentEquality implements Equality<ChatRecord> {
  const ChatRecordDocumentEquality();

  @override
  bool equals(ChatRecord? e1, ChatRecord? e2) {
    return e1?.mensagens == e2?.mensagens &&
        e1?.emailCliente == e2?.emailCliente &&
        e1?.uid == e2?.uid &&
        e1?.data == e2?.data &&
        e1?.adm == e2?.adm &&
        e1?.lidaOuNao == e2?.lidaOuNao;
  }

  @override
  int hash(ChatRecord? e) => const ListEquality().hash(
      [e?.mensagens, e?.emailCliente, e?.uid, e?.data, e?.adm, e?.lidaOuNao]);

  @override
  bool isValidKey(Object? o) => o is ChatRecord;
}
