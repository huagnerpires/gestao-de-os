import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class UsuariosRecord extends FirestoreRecord {
  UsuariosRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "email" field.
  String? _email;
  String get email => _email ?? '';
  bool hasEmail() => _email != null;

  // "display_name" field.
  String? _displayName;
  String get displayName => _displayName ?? '';
  bool hasDisplayName() => _displayName != null;

  // "phone_number" field.
  String? _phoneNumber;
  String get phoneNumber => _phoneNumber ?? '';
  bool hasPhoneNumber() => _phoneNumber != null;

  // "uid" field.
  String? _uid;
  String get uid => _uid ?? '';
  bool hasUid() => _uid != null;

  // "created_time" field.
  DateTime? _createdTime;
  DateTime? get createdTime => _createdTime;
  bool hasCreatedTime() => _createdTime != null;

  // "senha" field.
  String? _senha;
  String get senha => _senha ?? '';
  bool hasSenha() => _senha != null;

  // "tipodecontrato" field.
  String? _tipodecontrato;
  String get tipodecontrato => _tipodecontrato ?? '';
  bool hasTipodecontrato() => _tipodecontrato != null;

  // "CNPJ" field.
  String? _cnpj;
  String get cnpj => _cnpj ?? '';
  bool hasCnpj() => _cnpj != null;

  // "ONESIGNAL" field.
  String? _onesignal;
  String get onesignal => _onesignal ?? '';
  bool hasOnesignal() => _onesignal != null;

  // "ENDERECO" field.
  String? _endereco;
  String get endereco => _endereco ?? '';
  bool hasEndereco() => _endereco != null;

  // "NUMERO" field.
  String? _numero;
  String get numero => _numero ?? '';
  bool hasNumero() => _numero != null;

  // "CONDOMINIO_OU_LOJA" field.
  String? _condominioOuLoja;
  String get condominioOuLoja => _condominioOuLoja ?? '';
  bool hasCondominioOuLoja() => _condominioOuLoja != null;

  // "TELEFONE" field.
  String? _telefone;
  String get telefone => _telefone ?? '';
  bool hasTelefone() => _telefone != null;

  // "BAIIRO" field.
  String? _baiiro;
  String get baiiro => _baiiro ?? '';
  bool hasBaiiro() => _baiiro != null;

  // "photo_url" field.
  String? _photoUrl;
  String get photoUrl => _photoUrl ?? '';
  bool hasPhotoUrl() => _photoUrl != null;

  // "empresa" field.
  bool? _empresa;
  bool get empresa => _empresa ?? false;
  bool hasEmpresa() => _empresa != null;

  // "CIDADE" field.
  String? _cidade;
  String get cidade => _cidade ?? '';
  bool hasCidade() => _cidade != null;

  // "emailnotificacao" field.
  String? _emailnotificacao;
  String get emailnotificacao => _emailnotificacao ?? '';
  bool hasEmailnotificacao() => _emailnotificacao != null;

  // "emailrelatorio" field.
  String? _emailrelatorio;
  String get emailrelatorio => _emailrelatorio ?? '';
  bool hasEmailrelatorio() => _emailrelatorio != null;

  // "emailteste" field.
  List<String>? _emailteste;
  List<String> get emailteste => _emailteste ?? const [];
  bool hasEmailteste() => _emailteste != null;

  void _initializeFields() {
    _email = snapshotData['email'] as String?;
    _displayName = snapshotData['display_name'] as String?;
    _phoneNumber = snapshotData['phone_number'] as String?;
    _uid = snapshotData['uid'] as String?;
    _createdTime = snapshotData['created_time'] as DateTime?;
    _senha = snapshotData['senha'] as String?;
    _tipodecontrato = snapshotData['tipodecontrato'] as String?;
    _cnpj = snapshotData['CNPJ'] as String?;
    _onesignal = snapshotData['ONESIGNAL'] as String?;
    _endereco = snapshotData['ENDERECO'] as String?;
    _numero = snapshotData['NUMERO'] as String?;
    _condominioOuLoja = snapshotData['CONDOMINIO_OU_LOJA'] as String?;
    _telefone = snapshotData['TELEFONE'] as String?;
    _baiiro = snapshotData['BAIIRO'] as String?;
    _photoUrl = snapshotData['photo_url'] as String?;
    _empresa = snapshotData['empresa'] as bool?;
    _cidade = snapshotData['CIDADE'] as String?;
    _emailnotificacao = snapshotData['emailnotificacao'] as String?;
    _emailrelatorio = snapshotData['emailrelatorio'] as String?;
    _emailteste = getDataList(snapshotData['emailteste']);
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('USUARIOS');

  static Stream<UsuariosRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => UsuariosRecord.fromSnapshot(s));

  static Future<UsuariosRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => UsuariosRecord.fromSnapshot(s));

  static UsuariosRecord fromSnapshot(DocumentSnapshot snapshot) =>
      UsuariosRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static UsuariosRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      UsuariosRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'UsuariosRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is UsuariosRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createUsuariosRecordData({
  String? email,
  String? displayName,
  String? phoneNumber,
  String? uid,
  DateTime? createdTime,
  String? senha,
  String? tipodecontrato,
  String? cnpj,
  String? onesignal,
  String? endereco,
  String? numero,
  String? condominioOuLoja,
  String? telefone,
  String? baiiro,
  String? photoUrl,
  bool? empresa,
  String? cidade,
  String? emailnotificacao,
  String? emailrelatorio,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'email': email,
      'display_name': displayName,
      'phone_number': phoneNumber,
      'uid': uid,
      'created_time': createdTime,
      'senha': senha,
      'tipodecontrato': tipodecontrato,
      'CNPJ': cnpj,
      'ONESIGNAL': onesignal,
      'ENDERECO': endereco,
      'NUMERO': numero,
      'CONDOMINIO_OU_LOJA': condominioOuLoja,
      'TELEFONE': telefone,
      'BAIIRO': baiiro,
      'photo_url': photoUrl,
      'empresa': empresa,
      'CIDADE': cidade,
      'emailnotificacao': emailnotificacao,
      'emailrelatorio': emailrelatorio,
    }.withoutNulls,
  );

  return firestoreData;
}

class UsuariosRecordDocumentEquality implements Equality<UsuariosRecord> {
  const UsuariosRecordDocumentEquality();

  @override
  bool equals(UsuariosRecord? e1, UsuariosRecord? e2) {
    const listEquality = ListEquality();
    return e1?.email == e2?.email &&
        e1?.displayName == e2?.displayName &&
        e1?.phoneNumber == e2?.phoneNumber &&
        e1?.uid == e2?.uid &&
        e1?.createdTime == e2?.createdTime &&
        e1?.senha == e2?.senha &&
        e1?.tipodecontrato == e2?.tipodecontrato &&
        e1?.cnpj == e2?.cnpj &&
        e1?.onesignal == e2?.onesignal &&
        e1?.endereco == e2?.endereco &&
        e1?.numero == e2?.numero &&
        e1?.condominioOuLoja == e2?.condominioOuLoja &&
        e1?.telefone == e2?.telefone &&
        e1?.baiiro == e2?.baiiro &&
        e1?.photoUrl == e2?.photoUrl &&
        e1?.empresa == e2?.empresa &&
        e1?.cidade == e2?.cidade &&
        e1?.emailnotificacao == e2?.emailnotificacao &&
        e1?.emailrelatorio == e2?.emailrelatorio &&
        listEquality.equals(e1?.emailteste, e2?.emailteste);
  }

  @override
  int hash(UsuariosRecord? e) => const ListEquality().hash([
        e?.email,
        e?.displayName,
        e?.phoneNumber,
        e?.uid,
        e?.createdTime,
        e?.senha,
        e?.tipodecontrato,
        e?.cnpj,
        e?.onesignal,
        e?.endereco,
        e?.numero,
        e?.condominioOuLoja,
        e?.telefone,
        e?.baiiro,
        e?.photoUrl,
        e?.empresa,
        e?.cidade,
        e?.emailnotificacao,
        e?.emailrelatorio,
        e?.emailteste
      ]);

  @override
  bool isValidKey(Object? o) => o is UsuariosRecord;
}
