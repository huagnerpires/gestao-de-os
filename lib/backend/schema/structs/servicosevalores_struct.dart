// ignore_for_file: unnecessary_getters_setters

import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class ServicosevaloresStruct extends FFFirebaseStruct {
  ServicosevaloresStruct({
    String? servico,
    int? quantia,
    double? valor,
    FirestoreUtilData firestoreUtilData = const FirestoreUtilData(),
  })  : _servico = servico,
        _quantia = quantia,
        _valor = valor,
        super(firestoreUtilData);

  // "SERVICO" field.
  String? _servico;
  String get servico => _servico ?? '';
  set servico(String? val) => _servico = val;

  bool hasServico() => _servico != null;

  // "QUANTIA" field.
  int? _quantia;
  int get quantia => _quantia ?? 0;
  set quantia(int? val) => _quantia = val;

  void incrementQuantia(int amount) => quantia = quantia + amount;

  bool hasQuantia() => _quantia != null;

  // "VALOR" field.
  double? _valor;
  double get valor => _valor ?? 0.0;
  set valor(double? val) => _valor = val;

  void incrementValor(double amount) => valor = valor + amount;

  bool hasValor() => _valor != null;

  static ServicosevaloresStruct fromMap(Map<String, dynamic> data) =>
      ServicosevaloresStruct(
        servico: data['SERVICO'] as String?,
        quantia: castToType<int>(data['QUANTIA']),
        valor: castToType<double>(data['VALOR']),
      );

  static ServicosevaloresStruct? maybeFromMap(dynamic data) => data is Map
      ? ServicosevaloresStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'SERVICO': _servico,
        'QUANTIA': _quantia,
        'VALOR': _valor,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'SERVICO': serializeParam(
          _servico,
          ParamType.String,
        ),
        'QUANTIA': serializeParam(
          _quantia,
          ParamType.int,
        ),
        'VALOR': serializeParam(
          _valor,
          ParamType.double,
        ),
      }.withoutNulls;

  static ServicosevaloresStruct fromSerializableMap(
          Map<String, dynamic> data) =>
      ServicosevaloresStruct(
        servico: deserializeParam(
          data['SERVICO'],
          ParamType.String,
          false,
        ),
        quantia: deserializeParam(
          data['QUANTIA'],
          ParamType.int,
          false,
        ),
        valor: deserializeParam(
          data['VALOR'],
          ParamType.double,
          false,
        ),
      );

  @override
  String toString() => 'ServicosevaloresStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is ServicosevaloresStruct &&
        servico == other.servico &&
        quantia == other.quantia &&
        valor == other.valor;
  }

  @override
  int get hashCode => const ListEquality().hash([servico, quantia, valor]);
}

ServicosevaloresStruct createServicosevaloresStruct({
  String? servico,
  int? quantia,
  double? valor,
  Map<String, dynamic> fieldValues = const {},
  bool clearUnsetFields = true,
  bool create = false,
  bool delete = false,
}) =>
    ServicosevaloresStruct(
      servico: servico,
      quantia: quantia,
      valor: valor,
      firestoreUtilData: FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
        delete: delete,
        fieldValues: fieldValues,
      ),
    );

ServicosevaloresStruct? updateServicosevaloresStruct(
  ServicosevaloresStruct? servicosevalores, {
  bool clearUnsetFields = true,
  bool create = false,
}) =>
    servicosevalores
      ?..firestoreUtilData = FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
      );

void addServicosevaloresStructData(
  Map<String, dynamic> firestoreData,
  ServicosevaloresStruct? servicosevalores,
  String fieldName, [
  bool forFieldValue = false,
]) {
  firestoreData.remove(fieldName);
  if (servicosevalores == null) {
    return;
  }
  if (servicosevalores.firestoreUtilData.delete) {
    firestoreData[fieldName] = FieldValue.delete();
    return;
  }
  final clearFields =
      !forFieldValue && servicosevalores.firestoreUtilData.clearUnsetFields;
  if (clearFields) {
    firestoreData[fieldName] = <String, dynamic>{};
  }
  final servicosevaloresData =
      getServicosevaloresFirestoreData(servicosevalores, forFieldValue);
  final nestedData =
      servicosevaloresData.map((k, v) => MapEntry('$fieldName.$k', v));

  final mergeFields = servicosevalores.firestoreUtilData.create || clearFields;
  firestoreData
      .addAll(mergeFields ? mergeNestedFields(nestedData) : nestedData);
}

Map<String, dynamic> getServicosevaloresFirestoreData(
  ServicosevaloresStruct? servicosevalores, [
  bool forFieldValue = false,
]) {
  if (servicosevalores == null) {
    return {};
  }
  final firestoreData = mapToFirestore(servicosevalores.toMap());

  // Add any Firestore field values
  mapToFirestore(servicosevalores.firestoreUtilData.fieldValues)
      .forEach((k, v) => firestoreData[k] = v);

  return forFieldValue ? mergeNestedFields(firestoreData) : firestoreData;
}

List<Map<String, dynamic>> getServicosevaloresListFirestoreData(
  List<ServicosevaloresStruct>? servicosevaloress,
) =>
    servicosevaloress
        ?.map((e) => getServicosevaloresFirestoreData(e, true))
        .toList() ??
    [];
