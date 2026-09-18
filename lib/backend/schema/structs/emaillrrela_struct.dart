// ignore_for_file: unnecessary_getters_setters

import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class EmaillrrelaStruct extends FFFirebaseStruct {
  EmaillrrelaStruct({
    String? emmail,
    FirestoreUtilData firestoreUtilData = const FirestoreUtilData(),
  })  : _emmail = emmail,
        super(firestoreUtilData);

  // "EMMAIL" field.
  String? _emmail;
  String get emmail => _emmail ?? '';
  set emmail(String? val) => _emmail = val;

  bool hasEmmail() => _emmail != null;

  static EmaillrrelaStruct fromMap(Map<String, dynamic> data) =>
      EmaillrrelaStruct(
        emmail: data['EMMAIL'] as String?,
      );

  static EmaillrrelaStruct? maybeFromMap(dynamic data) => data is Map
      ? EmaillrrelaStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'EMMAIL': _emmail,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'EMMAIL': serializeParam(
          _emmail,
          ParamType.String,
        ),
      }.withoutNulls;

  static EmaillrrelaStruct fromSerializableMap(Map<String, dynamic> data) =>
      EmaillrrelaStruct(
        emmail: deserializeParam(
          data['EMMAIL'],
          ParamType.String,
          false,
        ),
      );

  @override
  String toString() => 'EmaillrrelaStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is EmaillrrelaStruct && emmail == other.emmail;
  }

  @override
  int get hashCode => const ListEquality().hash([emmail]);
}

EmaillrrelaStruct createEmaillrrelaStruct({
  String? emmail,
  Map<String, dynamic> fieldValues = const {},
  bool clearUnsetFields = true,
  bool create = false,
  bool delete = false,
}) =>
    EmaillrrelaStruct(
      emmail: emmail,
      firestoreUtilData: FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
        delete: delete,
        fieldValues: fieldValues,
      ),
    );

EmaillrrelaStruct? updateEmaillrrelaStruct(
  EmaillrrelaStruct? emaillrrela, {
  bool clearUnsetFields = true,
  bool create = false,
}) =>
    emaillrrela
      ?..firestoreUtilData = FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
      );

void addEmaillrrelaStructData(
  Map<String, dynamic> firestoreData,
  EmaillrrelaStruct? emaillrrela,
  String fieldName, [
  bool forFieldValue = false,
]) {
  firestoreData.remove(fieldName);
  if (emaillrrela == null) {
    return;
  }
  if (emaillrrela.firestoreUtilData.delete) {
    firestoreData[fieldName] = FieldValue.delete();
    return;
  }
  final clearFields =
      !forFieldValue && emaillrrela.firestoreUtilData.clearUnsetFields;
  if (clearFields) {
    firestoreData[fieldName] = <String, dynamic>{};
  }
  final emaillrrelaData =
      getEmaillrrelaFirestoreData(emaillrrela, forFieldValue);
  final nestedData =
      emaillrrelaData.map((k, v) => MapEntry('$fieldName.$k', v));

  final mergeFields = emaillrrela.firestoreUtilData.create || clearFields;
  firestoreData
      .addAll(mergeFields ? mergeNestedFields(nestedData) : nestedData);
}

Map<String, dynamic> getEmaillrrelaFirestoreData(
  EmaillrrelaStruct? emaillrrela, [
  bool forFieldValue = false,
]) {
  if (emaillrrela == null) {
    return {};
  }
  final firestoreData = mapToFirestore(emaillrrela.toMap());

  // Add any Firestore field values
  mapToFirestore(emaillrrela.firestoreUtilData.fieldValues)
      .forEach((k, v) => firestoreData[k] = v);

  return forFieldValue ? mergeNestedFields(firestoreData) : firestoreData;
}

List<Map<String, dynamic>> getEmaillrrelaListFirestoreData(
  List<EmaillrrelaStruct>? emaillrrelas,
) =>
    emaillrrelas?.map((e) => getEmaillrrelaFirestoreData(e, true)).toList() ??
    [];
