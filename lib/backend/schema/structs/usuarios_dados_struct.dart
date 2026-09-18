// ignore_for_file: unnecessary_getters_setters

import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class UsuariosDadosStruct extends FFFirebaseStruct {
  UsuariosDadosStruct({
    String? nome,
    String? senha,
    String? email,
    DocumentReference? referencia,
    FirestoreUtilData firestoreUtilData = const FirestoreUtilData(),
  })  : _nome = nome,
        _senha = senha,
        _email = email,
        _referencia = referencia,
        super(firestoreUtilData);

  // "NOME" field.
  String? _nome;
  String get nome => _nome ?? '';
  set nome(String? val) => _nome = val;

  bool hasNome() => _nome != null;

  // "SENHA" field.
  String? _senha;
  String get senha => _senha ?? '';
  set senha(String? val) => _senha = val;

  bool hasSenha() => _senha != null;

  // "EMAIL" field.
  String? _email;
  String get email => _email ?? '';
  set email(String? val) => _email = val;

  bool hasEmail() => _email != null;

  // "REFERENCIA" field.
  DocumentReference? _referencia;
  DocumentReference? get referencia => _referencia;
  set referencia(DocumentReference? val) => _referencia = val;

  bool hasReferencia() => _referencia != null;

  static UsuariosDadosStruct fromMap(Map<String, dynamic> data) =>
      UsuariosDadosStruct(
        nome: data['NOME'] as String?,
        senha: data['SENHA'] as String?,
        email: data['EMAIL'] as String?,
        referencia: data['REFERENCIA'] as DocumentReference?,
      );

  static UsuariosDadosStruct? maybeFromMap(dynamic data) => data is Map
      ? UsuariosDadosStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'NOME': _nome,
        'SENHA': _senha,
        'EMAIL': _email,
        'REFERENCIA': _referencia,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'NOME': serializeParam(
          _nome,
          ParamType.String,
        ),
        'SENHA': serializeParam(
          _senha,
          ParamType.String,
        ),
        'EMAIL': serializeParam(
          _email,
          ParamType.String,
        ),
        'REFERENCIA': serializeParam(
          _referencia,
          ParamType.DocumentReference,
        ),
      }.withoutNulls;

  static UsuariosDadosStruct fromSerializableMap(Map<String, dynamic> data) =>
      UsuariosDadosStruct(
        nome: deserializeParam(
          data['NOME'],
          ParamType.String,
          false,
        ),
        senha: deserializeParam(
          data['SENHA'],
          ParamType.String,
          false,
        ),
        email: deserializeParam(
          data['EMAIL'],
          ParamType.String,
          false,
        ),
        referencia: deserializeParam(
          data['REFERENCIA'],
          ParamType.DocumentReference,
          false,
          collectionNamePath: ['USUARIOS'],
        ),
      );

  @override
  String toString() => 'UsuariosDadosStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is UsuariosDadosStruct &&
        nome == other.nome &&
        senha == other.senha &&
        email == other.email &&
        referencia == other.referencia;
  }

  @override
  int get hashCode =>
      const ListEquality().hash([nome, senha, email, referencia]);
}

UsuariosDadosStruct createUsuariosDadosStruct({
  String? nome,
  String? senha,
  String? email,
  DocumentReference? referencia,
  Map<String, dynamic> fieldValues = const {},
  bool clearUnsetFields = true,
  bool create = false,
  bool delete = false,
}) =>
    UsuariosDadosStruct(
      nome: nome,
      senha: senha,
      email: email,
      referencia: referencia,
      firestoreUtilData: FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
        delete: delete,
        fieldValues: fieldValues,
      ),
    );

UsuariosDadosStruct? updateUsuariosDadosStruct(
  UsuariosDadosStruct? usuariosDados, {
  bool clearUnsetFields = true,
  bool create = false,
}) =>
    usuariosDados
      ?..firestoreUtilData = FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
      );

void addUsuariosDadosStructData(
  Map<String, dynamic> firestoreData,
  UsuariosDadosStruct? usuariosDados,
  String fieldName, [
  bool forFieldValue = false,
]) {
  firestoreData.remove(fieldName);
  if (usuariosDados == null) {
    return;
  }
  if (usuariosDados.firestoreUtilData.delete) {
    firestoreData[fieldName] = FieldValue.delete();
    return;
  }
  final clearFields =
      !forFieldValue && usuariosDados.firestoreUtilData.clearUnsetFields;
  if (clearFields) {
    firestoreData[fieldName] = <String, dynamic>{};
  }
  final usuariosDadosData =
      getUsuariosDadosFirestoreData(usuariosDados, forFieldValue);
  final nestedData =
      usuariosDadosData.map((k, v) => MapEntry('$fieldName.$k', v));

  final mergeFields = usuariosDados.firestoreUtilData.create || clearFields;
  firestoreData
      .addAll(mergeFields ? mergeNestedFields(nestedData) : nestedData);
}

Map<String, dynamic> getUsuariosDadosFirestoreData(
  UsuariosDadosStruct? usuariosDados, [
  bool forFieldValue = false,
]) {
  if (usuariosDados == null) {
    return {};
  }
  final firestoreData = mapToFirestore(usuariosDados.toMap());

  // Add any Firestore field values
  mapToFirestore(usuariosDados.firestoreUtilData.fieldValues)
      .forEach((k, v) => firestoreData[k] = v);

  return forFieldValue ? mergeNestedFields(firestoreData) : firestoreData;
}

List<Map<String, dynamic>> getUsuariosDadosListFirestoreData(
  List<UsuariosDadosStruct>? usuariosDadoss,
) =>
    usuariosDadoss
        ?.map((e) => getUsuariosDadosFirestoreData(e, true))
        .toList() ??
    [];
