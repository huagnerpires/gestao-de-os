// ignore_for_file: unnecessary_getters_setters

import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class ClientesStruct extends FFFirebaseStruct {
  ClientesStruct({
    List<String>? nomes,
    FirestoreUtilData firestoreUtilData = const FirestoreUtilData(),
  })  : _nomes = nomes,
        super(firestoreUtilData);

  // "NOMES" field.
  List<String>? _nomes;
  List<String> get nomes => _nomes ?? const [];
  set nomes(List<String>? val) => _nomes = val;

  void updateNomes(Function(List<String>) updateFn) {
    updateFn(_nomes ??= []);
  }

  bool hasNomes() => _nomes != null;

  static ClientesStruct fromMap(Map<String, dynamic> data) => ClientesStruct(
        nomes: getDataList(data['NOMES']),
      );

  static ClientesStruct? maybeFromMap(dynamic data) =>
      data is Map ? ClientesStruct.fromMap(data.cast<String, dynamic>()) : null;

  Map<String, dynamic> toMap() => {
        'NOMES': _nomes,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'NOMES': serializeParam(
          _nomes,
          ParamType.String,
          isList: true,
        ),
      }.withoutNulls;

  static ClientesStruct fromSerializableMap(Map<String, dynamic> data) =>
      ClientesStruct(
        nomes: deserializeParam<String>(
          data['NOMES'],
          ParamType.String,
          true,
        ),
      );

  @override
  String toString() => 'ClientesStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    const listEquality = ListEquality();
    return other is ClientesStruct && listEquality.equals(nomes, other.nomes);
  }

  @override
  int get hashCode => const ListEquality().hash([nomes]);
}

ClientesStruct createClientesStruct({
  Map<String, dynamic> fieldValues = const {},
  bool clearUnsetFields = true,
  bool create = false,
  bool delete = false,
}) =>
    ClientesStruct(
      firestoreUtilData: FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
        delete: delete,
        fieldValues: fieldValues,
      ),
    );

ClientesStruct? updateClientesStruct(
  ClientesStruct? clientes, {
  bool clearUnsetFields = true,
  bool create = false,
}) =>
    clientes
      ?..firestoreUtilData = FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
      );

void addClientesStructData(
  Map<String, dynamic> firestoreData,
  ClientesStruct? clientes,
  String fieldName, [
  bool forFieldValue = false,
]) {
  firestoreData.remove(fieldName);
  if (clientes == null) {
    return;
  }
  if (clientes.firestoreUtilData.delete) {
    firestoreData[fieldName] = FieldValue.delete();
    return;
  }
  final clearFields =
      !forFieldValue && clientes.firestoreUtilData.clearUnsetFields;
  if (clearFields) {
    firestoreData[fieldName] = <String, dynamic>{};
  }
  final clientesData = getClientesFirestoreData(clientes, forFieldValue);
  final nestedData = clientesData.map((k, v) => MapEntry('$fieldName.$k', v));

  final mergeFields = clientes.firestoreUtilData.create || clearFields;
  firestoreData
      .addAll(mergeFields ? mergeNestedFields(nestedData) : nestedData);
}

Map<String, dynamic> getClientesFirestoreData(
  ClientesStruct? clientes, [
  bool forFieldValue = false,
]) {
  if (clientes == null) {
    return {};
  }
  final firestoreData = mapToFirestore(clientes.toMap());

  // Add any Firestore field values
  mapToFirestore(clientes.firestoreUtilData.fieldValues)
      .forEach((k, v) => firestoreData[k] = v);

  return forFieldValue ? mergeNestedFields(firestoreData) : firestoreData;
}

List<Map<String, dynamic>> getClientesListFirestoreData(
  List<ClientesStruct>? clientess,
) =>
    clientess?.map((e) => getClientesFirestoreData(e, true)).toList() ?? [];
