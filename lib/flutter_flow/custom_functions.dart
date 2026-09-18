import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'lat_lng.dart';
import 'place.dart';
import 'uploaded_file.dart';
import '/backend/backend.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/backend/schema/structs/index.dart';
import '/backend/supabase/supabase.dart';
import '/auth/firebase_auth/auth_util.dart';

String? tempomedio(
  String? inicio,
  String? termino,
) {
// RECEBER MES EM STRING EX INICIO 20/11/2025 , TERMINO 20/12/2025 CONVERTER PARA DATE TIME  E RETORNAR EM DIAS E HORAS O TEMPO QUE PASSOU
  if (inicio == null || termino == null) return null;

  DateFormat format = DateFormat("dd/MM/yyyy");
  DateTime startDate = format.parse(inicio);
  DateTime endDate = format.parse(termino);

  Duration difference = endDate.difference(startDate);
  int days = difference.inDays;

  return '$days dias';
}

int? converterprainteiro(String? valor) {
  // VAI RECEBER UMA STRING E VAI retornar em inteira
  if (valor == null) return null;
  return int.tryParse(valor);
}

String? getMesMaiuscula(String? maiusculo) {
  // CONVERTER TEXTO MINUSCULO PARA MAIUSCULO
  if (maiusculo == null) return null;
  return maiusculo.toUpperCase();
}

int? anoatual() {
// PRECISO DE UMA FUNÇÃO DO ANO ATUAL FORMATADO DE ACORDO O ANO ATUAL
  return DateTime.now().year; // Retorna o ano atual
}

DateTime? datatime(String? data) {
  // vai receber uma string ex: 04/12/2025  e formatar para datatime
  if (data == null) return null;

  DateFormat format = DateFormat("dd/MM/yyyy");
  return format.parse(data);
}

double? semvirgula(String? digitado) {
// gerar codigo para se ao digitar um numero com virgura ira retorna double
  if (digitado == null || digitado.isEmpty) {
    return null;
  }
  // Replace comma with dot and parse to double
  return double.tryParse(digitado.replaceAll(',', '.'));
}

String? anosss() {
  // preciso preecher um dopdonw com anos ex: 2026,2027,2028 ate 2100
  List<String> anos = [];
  for (int i = 2026; i <= 2100; i++) {
    anos.add(i.toString());
  }
  return anos.join(','); // Returns a comma-separated string of years
}
