// ignore_for_file: unnecessary_getters_setters

import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class NumeroOsStruct extends FFFirebaseStruct {
  NumeroOsStruct({
    double? numeroOsEditar,
    bool? logado,
    FirestoreUtilData firestoreUtilData = const FirestoreUtilData(),
  })  : _numeroOsEditar = numeroOsEditar,
        _logado = logado,
        super(firestoreUtilData);

  // "numero_os_editar" field.
  double? _numeroOsEditar;
  double get numeroOsEditar => _numeroOsEditar ?? 0.0;
  set numeroOsEditar(double? val) => _numeroOsEditar = val;

  void incrementNumeroOsEditar(double amount) =>
      numeroOsEditar = numeroOsEditar + amount;

  bool hasNumeroOsEditar() => _numeroOsEditar != null;

  // "LOGADO" field.
  bool? _logado;
  bool get logado => _logado ?? false;
  set logado(bool? val) => _logado = val;

  bool hasLogado() => _logado != null;

  static NumeroOsStruct fromMap(Map<String, dynamic> data) => NumeroOsStruct(
        numeroOsEditar: castToType<double>(data['numero_os_editar']),
        logado: data['LOGADO'] as bool?,
      );

  static NumeroOsStruct? maybeFromMap(dynamic data) =>
      data is Map ? NumeroOsStruct.fromMap(data.cast<String, dynamic>()) : null;

  Map<String, dynamic> toMap() => {
        'numero_os_editar': _numeroOsEditar,
        'LOGADO': _logado,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'numero_os_editar': serializeParam(
          _numeroOsEditar,
          ParamType.double,
        ),
        'LOGADO': serializeParam(
          _logado,
          ParamType.bool,
        ),
      }.withoutNulls;

  static NumeroOsStruct fromSerializableMap(Map<String, dynamic> data) =>
      NumeroOsStruct(
        numeroOsEditar: deserializeParam(
          data['numero_os_editar'],
          ParamType.double,
          false,
        ),
        logado: deserializeParam(
          data['LOGADO'],
          ParamType.bool,
          false,
        ),
      );

  @override
  String toString() => 'NumeroOsStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is NumeroOsStruct &&
        numeroOsEditar == other.numeroOsEditar &&
        logado == other.logado;
  }

  @override
  int get hashCode => const ListEquality().hash([numeroOsEditar, logado]);
}

NumeroOsStruct createNumeroOsStruct({
  double? numeroOsEditar,
  bool? logado,
  Map<String, dynamic> fieldValues = const {},
  bool clearUnsetFields = true,
  bool create = false,
  bool delete = false,
}) =>
    NumeroOsStruct(
      numeroOsEditar: numeroOsEditar,
      logado: logado,
      firestoreUtilData: FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
        delete: delete,
        fieldValues: fieldValues,
      ),
    );

NumeroOsStruct? updateNumeroOsStruct(
  NumeroOsStruct? numeroOs, {
  bool clearUnsetFields = true,
  bool create = false,
}) =>
    numeroOs
      ?..firestoreUtilData = FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
      );

void addNumeroOsStructData(
  Map<String, dynamic> firestoreData,
  NumeroOsStruct? numeroOs,
  String fieldName, [
  bool forFieldValue = false,
]) {
  firestoreData.remove(fieldName);
  if (numeroOs == null) {
    return;
  }
  if (numeroOs.firestoreUtilData.delete) {
    firestoreData[fieldName] = FieldValue.delete();
    return;
  }
  final clearFields =
      !forFieldValue && numeroOs.firestoreUtilData.clearUnsetFields;
  if (clearFields) {
    firestoreData[fieldName] = <String, dynamic>{};
  }
  final numeroOsData = getNumeroOsFirestoreData(numeroOs, forFieldValue);
  final nestedData = numeroOsData.map((k, v) => MapEntry('$fieldName.$k', v));

  final mergeFields = numeroOs.firestoreUtilData.create || clearFields;
  firestoreData
      .addAll(mergeFields ? mergeNestedFields(nestedData) : nestedData);
}

Map<String, dynamic> getNumeroOsFirestoreData(
  NumeroOsStruct? numeroOs, [
  bool forFieldValue = false,
]) {
  if (numeroOs == null) {
    return {};
  }
  final firestoreData = mapToFirestore(numeroOs.toMap());

  // Add any Firestore field values
  mapToFirestore(numeroOs.firestoreUtilData.fieldValues)
      .forEach((k, v) => firestoreData[k] = v);

  return forFieldValue ? mergeNestedFields(firestoreData) : firestoreData;
}

List<Map<String, dynamic>> getNumeroOsListFirestoreData(
  List<NumeroOsStruct>? numeroOss,
) =>
    numeroOss?.map((e) => getNumeroOsFirestoreData(e, true)).toList() ?? [];
