import 'package:flutter/material.dart';
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/backend/api_requests/api_manager.dart';
import 'backend/supabase/supabase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'flutter_flow/flutter_flow_util.dart';

class FFAppState extends ChangeNotifier {
  static FFAppState _instance = FFAppState._internal();

  factory FFAppState() {
    return _instance;
  }

  FFAppState._internal();

  static void reset() {
    _instance = FFAppState._internal();
  }

  Future initializePersistedState() async {
    prefs = await SharedPreferences.getInstance();
    _safeInit(() {
      _SOMAR2 = prefs.getInt('ff_SOMAR2') ?? _SOMAR2;
    });
  }

  void update(VoidCallback callback) {
    callback();
    notifyListeners();
  }

  late SharedPreferences prefs;

  double _os = 0.0;
  double get os => _os;
  set os(double value) {
    _os = value;
  }

  double _AJUSTARPONTOS = 0.0;
  double get AJUSTARPONTOS => _AJUSTARPONTOS;
  set AJUSTARPONTOS(double value) {
    _AJUSTARPONTOS = value;
  }

  int _SOMAR2 = 0;
  int get SOMAR2 => _SOMAR2;
  set SOMAR2(int value) {
    _SOMAR2 = value;
    prefs.setInt('ff_SOMAR2', value);
  }

  int _PONTOSJO = 0;
  int get PONTOSJO => _PONTOSJO;
  set PONTOSJO(int value) {
    _PONTOSJO = value;
  }

  int _PONTOSJHON = 0;
  int get PONTOSJHON => _PONTOSJHON;
  set PONTOSJHON(int value) {
    _PONTOSJHON = value;
  }

  int _PONTOSJUNIOR = 0;
  int get PONTOSJUNIOR => _PONTOSJUNIOR;
  set PONTOSJUNIOR(int value) {
    _PONTOSJUNIOR = value;
  }

  String _emailpesquisa = '';
  String get emailpesquisa => _emailpesquisa;
  set emailpesquisa(String value) {
    _emailpesquisa = value;
  }

  String _NOMEDOCLIENTE = '';
  String get NOMEDOCLIENTE => _NOMEDOCLIENTE;
  set NOMEDOCLIENTE(String value) {
    _NOMEDOCLIENTE = value;
  }

  int _SOMAR123456 = 0;
  int get SOMAR123456 => _SOMAR123456;
  set SOMAR123456(int value) {
    _SOMAR123456 = value;
  }

  bool _MANTERLOGADO = false;
  bool get MANTERLOGADO => _MANTERLOGADO;
  set MANTERLOGADO(bool value) {
    _MANTERLOGADO = value;
  }

  double _NUMERO1 = 0.0;
  double get NUMERO1 => _NUMERO1;
  set NUMERO1(double value) {
    _NUMERO1 = value;
  }

  double _NUMERO2 = 0.0;
  double get NUMERO2 => _NUMERO2;
  set NUMERO2(double value) {
    _NUMERO2 = value;
  }

  double _RESULTADO = 0.0;
  double get RESULTADO => _RESULTADO;
  set RESULTADO(double value) {
    _RESULTADO = value;
  }

  String _RESULT = '';
  String get RESULT => _RESULT;
  set RESULT(String value) {
    _RESULT = value;
  }

  double _somartec = 0.0;
  double get somartec => _somartec;
  set somartec(double value) {
    _somartec = value;
  }

  double _somartec2 = 0.0;
  double get somartec2 => _somartec2;
  set somartec2(double value) {
    _somartec2 = value;
  }

  double _somartec4 = 0.0;
  double get somartec4 => _somartec4;
  set somartec4(double value) {
    _somartec4 = value;
  }

  double _somartec3 = 0.0;
  double get somartec3 => _somartec3;
  set somartec3(double value) {
    _somartec3 = value;
  }

  String _ATUALIZARPAGINA = '';
  String get ATUALIZARPAGINA => _ATUALIZARPAGINA;
  set ATUALIZARPAGINA(String value) {
    _ATUALIZARPAGINA = value;
  }

  bool _confirmar = false;
  bool get confirmar => _confirmar;
  set confirmar(bool value) {
    _confirmar = value;
  }

  String _referencia = '';
  String get referencia => _referencia;
  set referencia(String value) {
    _referencia = value;
  }

  UsuariosDadosStruct _REFUSERS = UsuariosDadosStruct();
  UsuariosDadosStruct get REFUSERS => _REFUSERS;
  set REFUSERS(UsuariosDadosStruct value) {
    _REFUSERS = value;
  }

  void updateREFUSERSStruct(Function(UsuariosDadosStruct) updateFn) {
    updateFn(_REFUSERS);
  }

  List<ServicosevaloresStruct> _SERVICOSSS = [];
  List<ServicosevaloresStruct> get SERVICOSSS => _SERVICOSSS;
  set SERVICOSSS(List<ServicosevaloresStruct> value) {
    _SERVICOSSS = value;
  }

  void addToSERVICOSSS(ServicosevaloresStruct value) {
    SERVICOSSS.add(value);
  }

  void removeFromSERVICOSSS(ServicosevaloresStruct value) {
    SERVICOSSS.remove(value);
  }

  void removeAtIndexFromSERVICOSSS(int index) {
    SERVICOSSS.removeAt(index);
  }

  void updateSERVICOSSSAtIndex(
    int index,
    ServicosevaloresStruct Function(ServicosevaloresStruct) updateFn,
  ) {
    SERVICOSSS[index] = updateFn(_SERVICOSSS[index]);
  }

  void insertAtIndexInSERVICOSSS(int index, ServicosevaloresStruct value) {
    SERVICOSSS.insert(index, value);
  }

  List<String> _enviarrmail = [];
  List<String> get enviarrmail => _enviarrmail;
  set enviarrmail(List<String> value) {
    _enviarrmail = value;
  }

  void addToEnviarrmail(String value) {
    enviarrmail.add(value);
  }

  void removeFromEnviarrmail(String value) {
    enviarrmail.remove(value);
  }

  void removeAtIndexFromEnviarrmail(int index) {
    enviarrmail.removeAt(index);
  }

  void updateEnviarrmailAtIndex(
    int index,
    String Function(String) updateFn,
  ) {
    enviarrmail[index] = updateFn(_enviarrmail[index]);
  }

  void insertAtIndexInEnviarrmail(int index, String value) {
    enviarrmail.insert(index, value);
  }

  String _EMAILENVIAR = '';
  String get EMAILENVIAR => _EMAILENVIAR;
  set EMAILENVIAR(String value) {
    _EMAILENVIAR = value;
  }

  List<EmaillrrelaStruct> _EMAILRET = [];
  List<EmaillrrelaStruct> get EMAILRET => _EMAILRET;
  set EMAILRET(List<EmaillrrelaStruct> value) {
    _EMAILRET = value;
  }

  void addToEMAILRET(EmaillrrelaStruct value) {
    EMAILRET.add(value);
  }

  void removeFromEMAILRET(EmaillrrelaStruct value) {
    EMAILRET.remove(value);
  }

  void removeAtIndexFromEMAILRET(int index) {
    EMAILRET.removeAt(index);
  }

  void updateEMAILRETAtIndex(
    int index,
    EmaillrrelaStruct Function(EmaillrrelaStruct) updateFn,
  ) {
    EMAILRET[index] = updateFn(_EMAILRET[index]);
  }

  void insertAtIndexInEMAILRET(int index, EmaillrrelaStruct value) {
    EMAILRET.insert(index, value);
  }
}

void _safeInit(Function() initializeField) {
  try {
    initializeField();
  } catch (_) {}
}

Future _safeInitAsync(Function() initializeField) async {
  try {
    await initializeField();
  } catch (_) {}
}
