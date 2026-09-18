// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:cloud_firestore/cloud_firestore.dart';

Future<String> atualizarEstoqueEmMassa() async {
  // Lista compilada e higienizada com chaves em MAIÚSCULO conforme solicitado
  final List<Map<String, dynamic>> listaCompilada = [
    {
      "PATRIMONIO": "168729",
      "EQUIPAMENTO": "AR CONDICIONADO",
      "MODELO": "SPLIT",
      "MARCA": "TCL",
      "TENSAO": "220V",
      "FLUIDO": "R32",
      "BTUS": "9K BTUS",
      "SETOR": "ADMINISTRATIVO",
      "SALA": "NUTRIÇÃO/PSICOLOGIA",
      "RESPONSAVEL": "TAIS OLIVEIRA LIMA"
    },
    {
      "PATRIMONIO": "168728",
      "EQUIPAMENTO": "AR CONDICIONADO",
      "MODELO": "SPLIT",
      "MARCA": "TCL",
      "TENSAO": "220V",
      "FLUIDO": "R32",
      "BTUS": "9K BTUS",
      "SETOR": "ADMINISTRATIVO",
      "SALA": "ENFERMAGEM/SESI",
      "RESPONSAVEL": "TAIS OLIVEIRA LIMA"
    },
    {
      "PATRIMONIO": "70850",
      "EQUIPAMENTO": "AR CONDICIONADO",
      "MODELO": "SPLIT",
      "MARCA": "LG",
      "TENSAO": "220V",
      "FLUIDO": "R410A",
      "BTUS": "11.5K BTUS",
      "SETOR": "ADMINISTRATIVO",
      "SALA": "GER ADM",
      "RESPONSAVEL": "NATHANAEL CORDEIROS"
    },
    {
      "PATRIMONIO": "70847",
      "EQUIPAMENTO": "AR CONDICIONADO",
      "MODELO": "SPLIT",
      "MARCA": "LG",
      "TENSAO": "220V",
      "FLUIDO": "R410A",
      "BTUS": "18K BTUS",
      "SETOR": "ADMINISTRATIVO",
      "SALA": "FISCAL CONTROLADORIA",
      "RESPONSAVEL": "NATHANAEL CORDEIROS"
    },
    {
      "PATRIMONIO": "70848",
      "EQUIPAMENTO": "AR CONDICIONADO",
      "MODELO": "SPLIT",
      "MARCA": "LG",
      "TENSAO": "220V",
      "FLUIDO": "R410A",
      "BTUS": "18K BTUS",
      "SETOR": "ADMINISTRATIVO",
      "SALA": "BUENOS AIRES",
      "RESPONSAVEL": "TAIS OLIVEIRA LIMA"
    },
    {
      "PATRIMONIO": "140370",
      "EQUIPAMENTO": "AR CONDICIONADO",
      "MODELO": "SPLIT",
      "MARCA": "ADMIRAL",
      "TENSAO": "220V",
      "FLUIDO": "R410A",
      "BTUS": "12K BTUS",
      "SETOR": "ADMINISTRATIVO",
      "SALA": "RH",
      "RESPONSAVEL": "TAIS OLIVEIRA LIMA"
    },
    {
      "PATRIMONIO": "93556",
      "EQUIPAMENTO": "AR CONDICIONADO",
      "MODELO": "SPLIT",
      "MARCA": "ELETROLUX",
      "TENSAO": "220V",
      "FLUIDO": "R410A",
      "BTUS": "12K",
      "SETOR": "ADMINISTRATIVO",
      "SALA": "RH",
      "RESPONSAVEL": "TAIS OLIVEIRA LIMA"
    },
    {
      "PATRIMONIO": "158443",
      "EQUIPAMENTO": "AR CONDICIONADO",
      "MODELO": "SPLIT",
      "MARCA": "MIDEA",
      "TENSAO": "220V",
      "FLUIDO": "R410A",
      "BTUS": "12K",
      "SETOR": "ADMINISTRATIVO",
      "SALA": "ITABERABA",
      "RESPONSAVEL": "TAIS OLIVEIRA LIMA"
    },
    {
      "PATRIMONIO": "119776",
      "EQUIPAMENTO": "AR CONDICIONADO",
      "MODELO": "SPLIT",
      "MARCA": "SAMSUNG",
      "TENSAO": "220V",
      "FLUIDO": "R410A",
      "BTUS": "18K BTUS",
      "SETOR": "ADMINISTRATIVO",
      "SALA": "T.I",
      "RESPONSAVEL": "ANDERSON"
    },
    {
      "PATRIMONIO": "126658",
      "EQUIPAMENTO": "AR CONDICIONADO",
      "MODELO": "SPLIT",
      "MARCA": "MIDEA",
      "TENSAO": "220V",
      "FLUIDO": "R410A",
      "BTUS": "24K BTUS",
      "SETOR": "ADMINISTRATIVO",
      "SALA": "DEPARTAMENTO PESSOAL",
      "RESPONSAVEL": "CLAUDENICE"
    },
    {
      "PATRIMONIO": "161805",
      "EQUIPAMENTO": "AR CONDICIONADO",
      "MODELO": "SPLIT",
      "MARCA": "SPRINGER",
      "TENSAO": "220V",
      "FLUIDO": "R410A",
      "BTUS": "18K BTUS",
      "SETOR": "ADMINISTRATIVO",
      "SALA": "GUARITA",
      "RESPONSAVEL": "TAIS OLIVEIRA LIMA"
    },
    {
      "PATRIMONIO": "126976",
      "EQUIPAMENTO": "AR CONDICIONADO",
      "MODELO": "SPLIT",
      "MARCA": "MIDEA",
      "TENSAO": "220V",
      "FLUIDO": "R410A",
      "BTUS": "12K BTUS",
      "SETOR": "ADMINISTRATIVO",
      "SALA": "DP. GUICHE EXTERNO",
      "RESPONSAVEL": "CLAUDENICE"
    },
    {
      "PATRIMONIO": "122983",
      "EQUIPAMENTO": "AR CONDICIONADO",
      "MODELO": "SPLIT",
      "MARCA": "MIDEA",
      "TENSAO": "220V",
      "FLUIDO": "R410A",
      "BTUS": "18K BTUS",
      "SETOR": "REFEITÓRIO",
      "SALA": "ESTOQUE",
      "RESPONSAVEL": "GEANE"
    },
    {
      "PATRIMONIO": "89215",
      "EQUIPAMENTO": "AR CONDICIONADO",
      "MODELO": "SPLIT",
      "MARCA": "MIDEA",
      "TENSAO": "220V",
      "FLUIDO": "R410A",
      "BTUS": "12K BTUS",
      "SETOR": "REFEITÓRIO",
      "SALA": "SALA NUTRICIONISTA",
      "RESPONSAVEL": "GEANE"
    },
    {
      "PATRIMONIO": "168724",
      "EQUIPAMENTO": "AR CONDICIONADO",
      "MODELO": "SPLIT",
      "MARCA": "TCL",
      "TENSAO": "220V",
      "FLUIDO": "R32",
      "BTUS": "9K BTUS",
      "SETOR": "REFEITÓRIO",
      "SALA": "SALA NUTRICIONISTA",
      "RESPONSAVEL": "GEANE"
    },
    {
      "PATRIMONIO": "147900",
      "EQUIPAMENTO": "AR CONDICIONADO",
      "MODELO": "SPLIT",
      "MARCA": "MIDEA",
      "TENSAO": "220V",
      "FLUIDO": "R410A",
      "BTUS": "12K BTUS",
      "SETOR": "REFEITÓRIO",
      "SALA": "PREPARO SALADAS",
      "RESPONSAVEL": "GEANE"
    },
    {
      "PATRIMONIO": "158445",
      "EQUIPAMENTO": "AR CONDICIONADO",
      "MODELO": "SPLIT",
      "MARCA": "MIDEA",
      "TENSAO": "220V",
      "FLUIDO": "R32",
      "BTUS": "9K BTUS",
      "SETOR": "PRÉ FABRICADO",
      "SALA": "QUIMICOS",
      "RESPONSAVEL": "GEVERSON"
    },
    {
      "PATRIMONIO": "89208",
      "EQUIPAMENTO": "AR CONDICIONADO",
      "MODELO": "SPLIT",
      "MARCA": "MIDEA",
      "TENSAO": "220V",
      "FLUIDO": "R410A",
      "BTUS": "12K BTUS",
      "SETOR": "QUÍMICO",
      "SALA": "DEPÓSITO",
      "RESPONSAVEL": "GEVERSON"
    },
    {
      "PATRIMONIO": "106998",
      "EQUIPAMENTO": "AR CONDICIONADO",
      "MODELO": "SPLIT",
      "MARCA": "MIDEA",
      "TENSAO": "220V",
      "FLUIDO": "R410A",
      "BTUS": "12K BTUS",
      "SETOR": "PRE FABRICADO",
      "SALA": "GERENCIA PRÉ",
      "RESPONSAVEL": "DILAMAR"
    },
    {
      "PATRIMONIO": "140231",
      "EQUIPAMENTO": "AR CONDICIONADO",
      "MODELO": "SPLIT",
      "MARCA": "MIDEA",
      "TENSAO": "220V",
      "FLUIDO": "R410A",
      "BTUS": "12K BTUS",
      "SETOR": "PRE FABRICADO",
      "SALA": "TREINAMENTO",
      "RESPONSAVEL": "DILAMAR"
    },
    {
      "PATRIMONIO": "106999",
      "EQUIPAMENTO": "AR CONDICIONADO",
      "MODELO": "PISO TETO",
      "MARCA": "CARRIER",
      "TENSAO": "220V",
      "FLUIDO": "R410A",
      "BTUS": "36K BTUS",
      "SETOR": "PRE FABRICADO",
      "SALA": "TREINAMENTO PRE",
      "RESPONSAVEL": "DILAMAR"
    },
    {
      "PATRIMONIO": "162070",
      "EQUIPAMENTO": "AR CONDICIONADO",
      "MODELO": "SPLIT",
      "MARCA": "SPRINGER",
      "TENSAO": "220V",
      "FLUIDO": "R410A",
      "BTUS": "12K BTUS",
      "SETOR": "PRE FABRICADO",
      "SALA": "RH",
      "RESPONSAVEL": "DILAMAR"
    },
    {
      "PATRIMONIO": "70849",
      "EQUIPAMENTO": "AR CONDICIONADO",
      "MODELO": "SPLIT",
      "MARCA": "LG",
      "TENSAO": "220V",
      "FLUIDO": "R410A",
      "BTUS": "9K BTUS",
      "SETOR": "PRE FABRICADO",
      "SALA": "REUNIÃO",
      "RESPONSAVEL": "DILAMAR"
    },
    {
      "PATRIMONIO": "117655",
      "EQUIPAMENTO": "AR CONDICIONADO",
      "MODELO": "SPLIT",
      "MARCA": "MIDEA",
      "TENSAO": "220V",
      "FLUIDO": "R410A",
      "BTUS": "22K BTUS",
      "SETOR": "PRE FABRICADO",
      "SALA": "PCP PRE",
      "RESPONSAVEL": "THIAGO ARAUJO"
    },
    {
      "PATRIMONIO": "72742",
      "EQUIPAMENTO": "AR CONDICIONADO",
      "MODELO": "SPLIT",
      "MARCA": "LG",
      "TENSAO": "220V",
      "FLUIDO": "R22",
      "BTUS": "9K BTUS",
      "SETOR": "RESÍDUOS",
      "SALA": "CENTRAL E RECICLADO",
      "RESPONSAVEL": "LEANDRO"
    },
    {
      "PATRIMONIO": "158114",
      "EQUIPAMENTO": "AR CONDICIONADO",
      "MODELO": "SPLIT",
      "MARCA": "MIDEA",
      "TENSAO": "220V",
      "FLUIDO": "R410A",
      "BTUS": "12K BTUS",
      "SETOR": "COLD CHOT",
      "SALA": "AUTOMAÇÃO",
      "RESPONSAVEL": "MANOEL MESSIAS"
    },
    {
      "PATRIMONIO": "147368",
      "EQUIPAMENTO": "AR CONDICIONADO",
      "MODELO": "SPLIT",
      "MARCA": "MIDEA",
      "TENSAO": "220V",
      "FLUIDO": "R410A",
      "BTUS": "12K BTUS",
      "SETOR": "COLD CHOT",
      "SALA": "AUTOMAÇÃO",
      "RESPONSAVEL": "MANOEL MESSIAS"
    },
    {
      "PATRIMONIO": "161871",
      "EQUIPAMENTO": "AR CONDICIONADO",
      "MODELO": "SPLIT",
      "MARCA": "AGRATTO",
      "TENSAO": "220V",
      "FLUIDO": "R410A",
      "BTUS": "18K BTUS",
      "SETOR": "CALDEIRA",
      "SALA": "SALA DE CONTROLE",
      "RESPONSAVEL": "PAULO ANTÔNIO"
    },
    {
      "PATRIMONIO": "126624",
      "EQUIPAMENTO": "AR CONDICIONADO",
      "MODELO": "SPLIT",
      "MARCA": "ELGIN",
      "TENSAO": "220V",
      "FLUIDO": "R410A",
      "BTUS": "18K BTUS",
      "SETOR": "CALDEIRA",
      "SALA": "SALA DE CONTROLE",
      "RESPONSAVEL": "PAULO ANTÔNIO"
    },
    {
      "PATRIMONIO": "126975",
      "EQUIPAMENTO": "AR CONDICIONADO",
      "MODELO": "SPLIT",
      "MARCA": "SPRINGER",
      "TENSAO": "220V",
      "FLUIDO": "R410A",
      "BTUS": "12K BTUS",
      "SETOR": "CALDEIRA",
      "SALA": "LABORATÓRIO CALDEIRA",
      "RESPONSAVEL": "PAULO ANTÔNIO"
    },
    {
      "PATRIMONIO": "140104",
      "EQUIPAMENTO": "AR CONDICIONADO",
      "MODELO": "SPLIT",
      "MARCA": "SANSUNG",
      "TENSAO": "220V",
      "FLUIDO": "R410A",
      "BTUS": "12K BTUS",
      "SETOR": "PAV15",
      "SALA": "GERENCIA LAMINADO",
      "RESPONSAVEL": "ADÃO"
    },
    {
      "PATRIMONIO": "93572",
      "EQUIPAMENTO": "AR CONDICIONADO",
      "MODELO": "SPLIT",
      "MARCA": "SPRINGER",
      "TENSAO": "220V",
      "FLUIDO": "R410A",
      "BTUS": "18K BTUS",
      "SETOR": "PAV 15",
      "SALA": "PCP/PAV 15",
      "RESPONSAVEL": "TAIS OLIVEIRA LIMA"
    },
    {
      "PATRIMONIO": "140105",
      "EQUIPAMENTO": "AR CONDICIONADO",
      "MODELO": "SPLIT",
      "MARCA": "SPRINGER",
      "TENSAO": "220V",
      "FLUIDO": "R410A",
      "BTUS": "12K BTUS",
      "SETOR": "PAV 15",
      "SALA": "GER. GERAL PAV15",
      "RESPONSAVEL": "NEY VARELLA"
    },
    {
      "PATRIMONIO": "168752",
      "EQUIPAMENTO": "AR CONDICIONADO",
      "MODELO": "SPLIT",
      "MARCA": "TCL",
      "TENSAO": "220V",
      "FLUIDO": "R32",
      "BTUS": "9K BTUS",
      "SETOR": "PAV 15",
      "SALA": "GER. PRODUÇÃO PAV15",
      "RESPONSAVEL": "ADAILTON"
    },
    {
      "PATRIMONIO": "122981",
      "EQUIPAMENTO": "AR CONDICIONADO",
      "MODELO": "SPLIT",
      "MARCA": "MIDEA",
      "TENSAO": "220V",
      "FLUIDO": "R410A",
      "BTUS": "12K BTUS",
      "SETOR": "PAV 15",
      "SALA": "RH",
      "RESPONSAVEL": "JESSICA"
    },
    {
      "PATRIMONIO": "122982",
      "EQUIPAMENTO": "AR CONDICIONADO",
      "MODELO": "SPLIT",
      "MARCA": "MIDEA",
      "TENSAO": "220V",
      "FLUIDO": "R410A",
      "BTUS": "12K BTUS",
      "SETOR": "PAV15",
      "SALA": "SANTO ANTÔNIO DE JESUS",
      "RESPONSAVEL": "JESSICA"
    },
    {
      "PATRIMONIO": "122985",
      "EQUIPAMENTO": "AR CONDICIONADO",
      "MODELO": "SPLIT",
      "MARCA": "MIDEA",
      "TENSAO": "220V",
      "FLUIDO": "R410A",
      "BTUS": "12K BTUS",
      "SETOR": "PAV15",
      "SALA": "SANTO ANTÔNIO DE JESUS",
      "RESPONSAVEL": "JESSICA"
    },
    {
      "PATRIMONIO": "154301",
      "EQUIPAMENTO": "AR CONDICIONADO",
      "MODELO": "SPLIT",
      "MARCA": "MIDEA",
      "TENSAO": "220V",
      "FLUIDO": "410A",
      "BTUS": "12K BTUS",
      "SETOR": "PAV 15",
      "SALA": "LABORATÓRIO",
      "RESPONSAVEL": "CRISTIANO"
    },
    {
      "PATRIMONIO": "122984",
      "EQUIPAMENTO": "AR CONDICIONADO",
      "MODELO": "SPLIT",
      "MARCA": "MIDEA",
      "TENSAO": "220V",
      "FLUIDO": "R410A",
      "BTUS": "12K BTUS",
      "SETOR": "PAV 15",
      "SALA": "LABORATÓRIO",
      "RESPONSAVEL": "NEY VARELLA"
    },
    {
      "PATRIMONIO": "147365",
      "EQUIPAMENTO": "AR CONDICIONADO",
      "MODELO": "SPLIT",
      "MARCA": "MIDEA",
      "TENSAO": "220V",
      "FLUIDO": "R410A",
      "BTUS": "12K BTUS",
      "SETOR": "PROTÓTIPO",
      "SALA": "PCP GUICHE",
      "RESPONSAVEL": "JORGE ROSA"
    },
    {
      "PATRIMONIO": "89209",
      "EQUIPAMENTO": "AR CONDICIONADO",
      "MODELO": "SPLIT",
      "MARCA": "MIDEA",
      "TENSAO": "220V",
      "FLUIDO": "R22",
      "BTUS": "7.5K BTUS",
      "SETOR": "PROTÓTIPO",
      "SALA": "SALA COLORISTA",
      "RESPONSAVEL": "MAURICIO"
    },
    {
      "PATRIMONIO": "135521",
      "EQUIPAMENTO": "AR CONDICIONADO",
      "MODELO": "PISO TETO",
      "MARCA": "SPRINGER",
      "TENSAO": "220V",
      "FLUIDO": "R410A",
      "BTUS": "48K BTUS",
      "SETOR": "PAV CENTRAL",
      "SALA": "PCP GERAL",
      "RESPONSAVEL": "JORGE ROSA"
    },
    {
      "PATRIMONIO": "144970",
      "EQUIPAMENTO": "AR CONDICIONADO",
      "MODELO": "SPLIT",
      "MARCA": "ADMIRAL",
      "TENSAO": "220V",
      "FLUIDO": "R410A",
      "BTUS": "12K BTUS",
      "SETOR": "PAV CENTRAL",
      "SALA": "DE OLHO NO CONSUMO",
      "RESPONSAVEL": "ADELMO"
    },
    {
      "PATRIMONIO": "147367",
      "EQUIPAMENTO": "AR CONDICIONADO",
      "MODELO": "SPLIT",
      "MARCA": "MIDEA",
      "TENSAO": "220V",
      "FLUIDO": "R410A",
      "BTUS": "18K BTUS",
      "SETOR": "PROTÓTIPO",
      "SALA": "DESENVOLVIMENTO",
      "RESPONSAVEL": "ROSENBERG"
    },
    {
      "PATRIMONIO": "162192",
      "EQUIPAMENTO": "AR CONDICIONADO",
      "MODELO": "SPLIT",
      "MARCA": "GREE",
      "TENSAO": "220V",
      "FLUIDO": "R410A",
      "BTUS": "30K BTUS",
      "SETOR": "PROTÓTIPO",
      "SALA": "AMOSTRAS",
      "RESPONSAVEL": "BRAULIO GUSMÃO"
    },
    {
      "PATRIMONIO": "147366",
      "EQUIPAMENTO": "AR CONDICIONADO",
      "MODELO": "SPLIT",
      "MARCA": "MIDEA",
      "TENSAO": "220V",
      "FLUIDO": "R410A",
      "BTUS": "12K BTUS",
      "SETOR": "PROTOTIPO",
      "SALA": "ADM PROTÓTIPO",
      "RESPONSAVEL": "MATHEUS OLIVEIRA"
    },
    {
      "PATRIMONIO": "168750",
      "EQUIPAMENTO": "AR CONDICIONADO",
      "MODELO": "SPLIT",
      "MARCA": "TCL",
      "TENSAO": "220V",
      "FLUIDO": "R32",
      "BTUS": "9K BTUS",
      "SETOR": "PROTÓTIPO",
      "SALA": "PROJETOS",
      "RESPONSAVEL": "BRAULIO GUSMÃO"
    },
    {
      "PATRIMONIO": "144971",
      "EQUIPAMENTO": "AR CONDICIONADO",
      "MODELO": "SPLIT",
      "MARCA": "MIDEA",
      "TENSAO": "220V",
      "FLUIDO": "R410A",
      "BTUS": "12K BTUS",
      "SETOR": "PROTÓTIPO",
      "SALA": "MELHORIA CONTINUA",
      "RESPONSAVEL": "LUCAS ANUNCIAÇÃO"
    },
    {
      "PATRIMONIO": "115257",
      "EQUIPAMENTO": "AR CONDICIONADO",
      "MODELO": "SPLIT",
      "MARCA": "MIDEA",
      "TENSAO": "220V",
      "FLUIDO": "R410A",
      "BTUS": "22K BTUS",
      "SETOR": "PROTÓTIPO",
      "SALA": "GER APOIO",
      "RESPONSAVEL": "LEANDRO ANDRADE"
    },
    {
      "PATRIMONIO": "89212",
      "EQUIPAMENTO": "AR CONDICIONADO",
      "MODELO": "SPLIT",
      "MARCA": "MIDEA",
      "TENSAO": "220V",
      "FLUIDO": "R410A",
      "BTUS": "12K BTUS",
      "SETOR": "PROTÓTIPO",
      "SALA": "PROG PCP",
      "RESPONSAVEL": "FELIPE PILOTO"
    },
    {
      "PATRIMONIO": "89213",
      "EQUIPAMENTO": "AR CONDICIONADO",
      "MODELO": "SPLIT",
      "MARCA": "MIDEA",
      "TENSAO": "220V",
      "FLUIDO": "R410A",
      "BTUS": "12K BTUS",
      "SETOR": "PROTÓTIPO",
      "SALA": "SCHRUM",
      "RESPONSAVEL": "BRAULIO GUSMÃO"
    },
    {
      "PATRIMONIO": "127000",
      "EQUIPAMENTO": "AR CONDICIONADO",
      "MODELO": "SPLIT",
      "MARCA": "MIDEA",
      "TENSAO": "220V",
      "FLUIDO": "R410A",
      "BTUS": "22K BTUS",
      "SETOR": "PROTÓTIPO",
      "SALA": "CENTRAL INDICADORES",
      "RESPONSAVEL": "GUSTAVO BRITES"
    },
    {
      "PATRIMONIO": "70846",
      "EQUIPAMENTO": "AR CONDICIONADO",
      "MODELO": "SPLIT",
      "MARCA": "LG",
      "TENSAO": "220V",
      "FLUIDO": "R22",
      "BTUS": "9K BTUS",
      "SETOR": "PAV CENTRAL",
      "SALA": "SALA S/ NOME",
      "RESPONSAVEL": "SEM IDENTIFICAÇÃO"
    },
    {
      "PATRIMONIO": "89207",
      "EQUIPAMENTO": "AR CONDICIONADO",
      "MODELO": "SPLIT",
      "MARCA": "MIDEA",
      "TENSAO": "220V",
      "FLUIDO": "R410A",
      "BTUS": "12K BTUS",
      "SETOR": "PAV CENTRAL",
      "SALA": "EVA INJETADO",
      "RESPONSAVEL": "RAMON SANTOS"
    },
    {
      "PATRIMONIO": "101364",
      "EQUIPAMENTO": "AR CONDICIONADO",
      "MODELO": "SPLIT",
      "MARCA": "ELGIN",
      "TENSAO": "220V",
      "FLUIDO": "R410A",
      "BTUS": "12K BTUS",
      "SETOR": "PAV CENTRAL",
      "SALA": "GER PROD EVA INJETADO",
      "RESPONSAVEL": "ERICK GOMES"
    },
    {
      "PATRIMONIO": "158669",
      "EQUIPAMENTO": "AR CONDICIONADO",
      "MODELO": "PISO TETO",
      "MARCA": "CARRIER",
      "TENSAO": "220V",
      "FLUIDO": "R410",
      "BTUS": "38K BTUS",
      "SETOR": "BORRACHA",
      "SALA": "TESTE E QUALIDADE",
      "RESPONSAVEL": "RUTE ARAUJO"
    },
    {
      "PATRIMONIO": "162068",
      "EQUIPAMENTO": "AR CONDICIONADO",
      "MODELO": "SPLIT",
      "MARCA": "SPRINGER",
      "TENSAO": "220V",
      "FLUIDO": "R22",
      "BTUS": "38K BTUS",
      "SETOR": "PAV CENTRAL",
      "SALA": "CENTRAL DE PADRÕES",
      "RESPONSAVEL": "JONATHAN MARTINS"
    },
    {
      "PATRIMONIO": "158133",
      "EQUIPAMENTO": "AR CONDICIONADO",
      "MODELO": "PISO TETO",
      "MARCA": "CARRIER",
      "TENSAO": "380V",
      "FLUIDO": "410A",
      "BTUS": "56K BTUS",
      "SETOR": "PAV CENTRAL",
      "SALA": "FIFO",
      "RESPONSAVEL": "RAFAEL"
    },
    {
      "PATRIMONIO": "144827",
      "EQUIPAMENTO": "AR CONDICIONADO",
      "MODELO": "K7",
      "MARCA": "CARRIER",
      "TENSAO": "220V",
      "FLUIDO": "R410A",
      "BTUS": "57K BTUS",
      "SETOR": "BORRACHA",
      "SALA": "FIFO",
      "RESPONSAVEL": "RAFAEL"
    },
    {
      "PATRIMONIO": "144828",
      "EQUIPAMENTO": "AR CONDICIONADO",
      "MODELO": "K7",
      "MARCA": "CARRIER",
      "TENSAO": "220V",
      "FLUIDO": "R410A",
      "BTUS": "57K BTUS",
      "SETOR": "BORRACHA",
      "SALA": "FIFO",
      "RESPONSAVEL": "RAFAEL"
    },
    {
      "PATRIMONIO": "147873",
      "EQUIPAMENTO": "AR CONDICIONADO",
      "MODELO": "PISO TETO",
      "MARCA": "SPRINGER",
      "TENSAO": "380V",
      "FLUIDO": "R410A",
      "BTUS": "56K BTUS",
      "SETOR": "BORRACHA",
      "SALA": "FIFO",
      "RESPONSAVEL": "RAFAEL"
    },
    {
      "PATRIMONIO": "140371",
      "EQUIPAMENTO": "AR CONDICIONADO",
      "MODELO": "SPLIT",
      "MARCA": "ADMIRAL",
      "TENSAO": "220V",
      "FLUIDO": "R410A",
      "BTUS": "12K BTUS",
      "SETOR": "FIFO",
      "SALA": "QUALIDADE",
      "RESPONSAVEL": "JOYCE"
    },
    {
      "PATRIMONIO": "89205",
      "EQUIPAMENTO": "AR CONDICIONADO",
      "MODELO": "SPLIT",
      "MARCA": "MIDEA",
      "TENSAO": "220V",
      "FLUIDO": "R410A",
      "BTUS": "12K BTUS",
      "SETOR": "BORRACHA",
      "SALA": "TECNICOR",
      "RESPONSAVEL": "CRISTIANO"
    },
    {
      "PATRIMONIO": "140374",
      "EQUIPAMENTO": "AR CONDICIONADO",
      "MODELO": "SPLIT",
      "MARCA": "ADMIRAL",
      "TENSAO": "220V",
      "FLUIDO": "R410A",
      "BTUS": "12K BTUS",
      "SETOR": "FIFO",
      "SALA": "GERENTE QUALIDADE",
      "RESPONSAVEL": "CRISTIANO"
    },
    {
      "PATRIMONIO": "140382",
      "EQUIPAMENTO": "AR CONDICIONADO",
      "MODELO": "SPLIT",
      "MARCA": "ADMIRAL",
      "TENSAO": "220V",
      "FLUIDO": "R410A",
      "BTUS": "12K BTUS",
      "SETOR": "FIFO",
      "SALA": "ELDORADO",
      "RESPONSAVEL": "MARCELO"
    },
    {
      "PATRIMONIO": "147679",
      "EQUIPAMENTO": "AR CONDICIONADO",
      "MODELO": "PISO TETO",
      "MARCA": "GREE",
      "TENSAO": "220V",
      "FLUIDO": "R410A",
      "BTUS": "48K BTUS",
      "SETOR": "FIFO",
      "SALA": "ELDORADO",
      "RESPONSAVEL": "MARCELO"
    },
    {
      "PATRIMONIO": "94943",
      "EQUIPAMENTO": "AR CONDICIONADO",
      "MODELO": "SPLIT",
      "MARCA": "MIDEA",
      "TENSAO": "220V",
      "FLUIDO": "R410A",
      "BTUS": "12K BTUS",
      "SETOR": "PAV CENTRAL",
      "SALA": "GESTAO ALMOX",
      "RESPONSAVEL": "JEVERSON"
    },
    {
      "PATRIMONIO": "144850",
      "EQUIPAMENTO": "AR CONDICIONADO",
      "MODELO": "SPLIT",
      "MARCA": "MIDEA",
      "TENSAO": "220V",
      "FLUIDO": "R22",
      "BTUS": "30K BTUS",
      "SETOR": "PAV CENTRAL",
      "SALA": "SSMA E SE",
      "RESPONSAVEL": "KADU"
    },
    {
      "PATRIMONIO": "162193",
      "EQUIPAMENTO": "AR CONDICIONADO",
      "MODELO": "SPLIT",
      "MARCA": "MIDEA",
      "TENSAO": "220V",
      "FLUIDO": "R22",
      "BTUS": "30K BTUS",
      "SETOR": "PAV CENTRAL",
      "SALA": "SSMA E SE",
      "RESPONSAVEL": "KADU"
    },
    {
      "PATRIMONIO": "140381",
      "EQUIPAMENTO": "AR CONDICIONADO",
      "MODELO": "K7",
      "MARCA": "CARRIER",
      "TENSAO": "220V",
      "FLUIDO": "R410A",
      "BTUS": "57K BTUS",
      "SETOR": "PAV CENTRAL",
      "SALA": "LABORATORIO",
      "RESPONSAVEL": "ALAN"
    },
    {
      "PATRIMONIO": "140380",
      "EQUIPAMENTO": "AR CONDICIONADO",
      "MODELO": "K7",
      "MARCA": "CARRIER",
      "TENSAO": "220V",
      "FLUIDO": "R410A",
      "BTUS": "57K BTUS",
      "SETOR": "PAV CENTRAL",
      "SALA": "LABORATORIO",
      "RESPONSAVEL": "ALAN"
    },
    {
      "PATRIMONIO": "147809",
      "EQUIPAMENTO": "AR CONDICIONADO",
      "MODELO": "SPLIT",
      "MARCA": "MIDEA",
      "TENSAO": "220V",
      "FLUIDO": "R410A",
      "BTUS": "12K BTUS",
      "SETOR": "PAV CENTRAL",
      "SALA": "GESTAO LABORATORIO",
      "RESPONSAVEL": "ALAN"
    },
    {
      "PATRIMONIO": "89211",
      "EQUIPAMENTO": "AR CONDICIONADO",
      "MODELO": "SPLIT",
      "MARCA": "MIDEA",
      "TENSAO": "220V",
      "FLUIDO": "R410A",
      "BTUS": "12K BTUS",
      "SETOR": "PROTÓTIPO",
      "SALA": "GERENTE GERAL PCP",
      "RESPONSAVEL": "JORGE ROSA"
    },
    {
      "PATRIMONIO": "144849",
      "EQUIPAMENTO": "AR CONDICIONADO",
      "MODELO": "SPLIT",
      "MARCA": "SRPINGER",
      "TENSAO": "220V",
      "FLUIDO": "R410A",
      "BTUS": "12K BTUS",
      "SETOR": "PROTÓTIPO",
      "SALA": "GER INDUSTRIAL",
      "RESPONSAVEL": "GUSTAVO BRITES"
    },
    {
      "PATRIMONIO": "101365",
      "EQUIPAMENTO": "AR CONDICIONADO",
      "MODELO": "SPLIT",
      "MARCA": "LG",
      "TENSAO": "220V",
      "FLUIDO": "R410A",
      "BTUS": "12K BTUS",
      "SETOR": "PROTÓTIPO",
      "SALA": "LASER PROTOTIPO",
      "RESPONSAVEL": "WILLIAM"
    },
    {
      "PATRIMONIO": "92743",
      "EQUIPAMENTO": "AR CONDICIONADO",
      "MODELO": "SPLIT",
      "MARCA": "SAMSUNG",
      "TENSAO": "220V",
      "FLUIDO": "R22",
      "BTUS": "9K BTUS",
      "SETOR": "MANUTENÇÃO",
      "SALA": "GESTÃO TPM",
      "RESPONSAVEL": "HELENO LUÍZ"
    },
    {
      "PATRIMONIO": "93573",
      "EQUIPAMENTO": "AR CONDICIONADO",
      "MODELO": "SPLIT",
      "MARCA": "SPRINGER",
      "TENSAO": "220V",
      "FLUIDO": "R410A",
      "BTUS": "12K BTUS",
      "SETOR": "MANUTENÇAO",
      "SALA": "GERÊNCIA MANUTENÇÃO",
      "RESPONSAVEL": "HELENO LUÍZ"
    },
    {
      "PATRIMONIO": "86548",
      "EQUIPAMENTO": "AR CONDICIONADO",
      "MODELO": "SPLIT",
      "MARCA": "LG",
      "TENSAO": "220V",
      "FLUIDO": "R22",
      "BTUS": "7.5K BTUS",
      "SETOR": "MANUTENÇÃO",
      "SALA": "ADM DA MANUTENÇÃO",
      "RESPONSAVEL": "HELENO LUÍZ"
    },
    {
      "PATRIMONIO": "168749",
      "EQUIPAMENTO": "AR CONDICIONADO",
      "MODELO": "SPLIT",
      "MARCA": "TCL",
      "TENSAO": "220V",
      "FLUIDO": "R32",
      "BTUS": "9K BTUS",
      "SETOR": "MANUTENÇÃO",
      "SALA": "COORDENAÇÃO GERAL",
      "RESPONSAVEL": "HELENO LUÍZ"
    },
    {
      "PATRIMONIO": "72741",
      "EQUIPAMENTO": "AR CONDICIONADO",
      "MODELO": "SPLIT",
      "MARCA": "LG",
      "TENSAO": "220V",
      "FLUIDO": "R410A",
      "BTUS": "12K BTUS",
      "SETOR": "MANUTENÇÃO",
      "SALA": "GESTÃO MANUTENÇÃO",
      "RESPONSAVEL": "HELENO LUÍZ"
    },
    {
      "PATRIMONIO": "158444",
      "EQUIPAMENTO": "AR CONDICIONADO",
      "MODELO": "SPLIT",
      "MARCA": "MIDEA",
      "TENSAO": "220V",
      "FLUIDO": "R410A",
      "BTUS": "12K BTUS",
      "SETOR": "MANUTENÇÃO",
      "SALA": "IBICUI",
      "RESPONSAVEL": "HELENO LUÍZ"
    },
    {
      "PATRIMONIO": "101449",
      "EQUIPAMENTO": "AR CONDICIONADO",
      "MODELO": "SPLIT",
      "MARCA": "LG",
      "TENSAO": "220V",
      "FLUIDO": "R410A",
      "BTUS": "12K BTUS",
      "SETOR": "MANUTENÇÃO",
      "SALA": "SAUDADES",
      "RESPONSAVEL": "HELENO LUÍZ"
    },
    {
      "PATRIMONIO": "140230",
      "EQUIPAMENTO": "AR CONDICIONADO",
      "MODELO": "SPLIT",
      "MARCA": "SPRINGER",
      "TENSAO": "220V",
      "FLUIDO": "R410A",
      "BTUS": "12K BTUS",
      "SETOR": "MANUTENÇÃO",
      "SALA": "TI MANUTENÇÃO",
      "RESPONSAVEL": "ANDERSON"
    },
    {
      "PATRIMONIO": "89947",
      "EQUIPAMENTO": "AR CONDICIONADO",
      "MODELO": "SPLIT",
      "MARCA": "ELETROLUX",
      "TENSAO": "220V",
      "FLUIDO": "R22",
      "BTUS": "12K BTUS",
      "SETOR": "MANUTENÇÃO",
      "SALA": "ALMOX MANUTENÇÃO",
      "RESPONSAVEL": "PAULO ANTÔNIO"
    },
    {
      "PATRIMONIO": "89210",
      "EQUIPAMENTO": "AR CONDICIONADO",
      "MODELO": "SPLIT",
      "MARCA": "MIDEA",
      "TENSAO": "220V",
      "FLUIDO": "R410A",
      "BTUS": "12K BTUS",
      "SETOR": "MANUTENÇÃO",
      "SALA": "SALA ELETRONICA",
      "RESPONSAVEL": "HELENO LUÍZ"
    },
    {
      "PATRIMONIO": "162069",
      "EQUIPAMENTO": "AR CONDICIONADO",
      "MODELO": "SPLIT",
      "MARCA": "MIDEA",
      "TENSAO": "220V",
      "FLUIDO": "R410A",
      "BTUS": "18K BTUS",
      "SETOR": "PAV CENTRAL",
      "SALA": "CENTRAL DE PADRÕES E.V.A",
      "RESPONSAVEL": "CRISTIANO"
    },
    {
      "PATRIMONIO": "70938",
      "EQUIPAMENTO": "AR CONDICIONADO",
      "MODELO": "SPLIT",
      "MARCA": "LG",
      "TENSAO": "220V",
      "FLUIDO": "R22",
      "BTUS": "36K BTUS",
      "SETOR": "ADMINISTRATIVO",
      "SALA": "SANTO ESTEVÃO",
      "RESPONSAVEL": "TAIS OLIVEIRA LIMA"
    },
    {
      "PATRIMONIO": "86733",
      "EQUIPAMENTO": "AR CONDICIONADO",
      "MODELO": "SPLIT",
      "MARCA": "CONSUL",
      "TENSAO": "220V",
      "FLUIDO": "R410A",
      "BTUS": "12K BTUS",
      "SETOR": "ADMINISTRATIVO",
      "SALA": "CONSUL. OCUPACIONAL",
      "RESPONSAVEL": "TAIS OLIVEIRA LIMA"
    },
    {
      "PATRIMONIO": "93555",
      "EQUIPAMENTO": "AR CONDICIONADO",
      "MODELO": "SPLIT",
      "MARCA": "ELETROLUX",
      "TENSAO": "220V",
      "FLUIDO": "R410A",
      "BTUS": "12K BTUS",
      "SETOR": "EXPEDIÇÃO",
      "SALA": "FATURAMENTO",
      "RESPONSAVEL": "JORGE ROSA"
    },
    {
      "PATRIMONIO": "168751",
      "EQUIPAMENTO": "AR CONDICIONADO",
      "MODELO": "SPLIT",
      "MARCA": "TCL",
      "TENSAO": "220V",
      "FLUIDO": "R410A",
      "BTUS": "12K BTUS",
      "SETOR": "PRÉ FABRICADO",
      "SALA": "AGRUPAMENTO",
      "RESPONSAVEL": "PAULO HENRIQUE"
    },
    {
      "PATRIMONIO": "126488",
      "EQUIPAMENTO": "AR CONDICIONADO",
      "MODELO": "SPLIT",
      "MARCA": "ADMIRAL",
      "TENSAO": "220V",
      "FLUIDO": "R410A",
      "BTUS": "12K BTUS",
      "SETOR": "EXPEDIÇÃO",
      "SALA": "GESTÃO EXPEDIÇÃO",
      "RESPONSAVEL": "JORGE ROSA"
    },
    {
      "PATRIMONIO": "140376",
      "EQUIPAMENTO": "AR CONDICIONADO",
      "MODELO": "SPLIT",
      "MARCA": "ADMIRAL",
      "TENSAO": "220V",
      "FLUIDO": "R410A",
      "BTUS": "12K BTUS",
      "SETOR": "PAV CENTRAL",
      "SALA": "GER ALMOXARIFADO",
      "RESPONSAVEL": "JEVERSON"
    },
    {
      "PATRIMONIO": "168937",
      "EQUIPAMENTO": "AR CONDICIONADO",
      "MODELO": "SPLIT",
      "MARCA": "ELGIN",
      "TENSAO": "220V",
      "FLUIDO": "R410A",
      "BTUS": "18K BTUS",
      "SETOR": "PAV VENTRAL",
      "SALA": "GERENCIA SSMA",
      "RESPONSAVEL": "KADU"
    },
    {
      "PATRIMONIO": "70650",
      "EQUIPAMENTO": "AR CONDICIONADO",
      "MODELO": "SPLIT",
      "MARCA": "LG",
      "TENSAO": "220V",
      "FLUIDO": "R22",
      "BTUS": "17K BTUS",
      "SETOR": "ADMINISTRATIVO",
      "SALA": "TRIAGEM AMBULATÓRIO",
      "RESPONSAVEL": "TAIS OLIVEIRA LIMA"
    },
    {
      "PATRIMONIO": "101212",
      "EQUIPAMENTO": "AR CONDICIONADO",
      "MODELO": "SPLIT",
      "MARCA": "SAMSUNG",
      "TENSAO": "220V",
      "FLUIDO": "R410A",
      "BTUS": "12K BTUS",
      "SETOR": "ADMINISTRATIVO",
      "SALA": "PROCEDIMENTO",
      "RESPONSAVEL": "TAIS OLIVEIRA LIMA"
    },
    {
      "PATRIMONIO": "72740",
      "EQUIPAMENTO": "AR CONDICIONADO",
      "MODELO": "SPLIT",
      "MARCA": "LG",
      "TENSAO": "220V",
      "FLUIDO": "R22",
      "BTUS": "9K BTUS",
      "SETOR": "ADMINISTRATIVO",
      "SALA": "CONSULTÓRIO MÉDICO",
      "RESPONSAVEL": "TAIS OLIVEIRA LIMA"
    },
    {
      "PATRIMONIO": "86734",
      "EQUIPAMENTO": "AR CONDICIONADO",
      "MODELO": "SPLIT",
      "MARCA": "SPRINGER",
      "TENSAO": "220V",
      "FLUIDO": "R410A",
      "BTUS": "12K BTUS",
      "SETOR": "ADMINISTRATIVO",
      "SALA": "RECEPÇÃO SESI",
      "RESPONSAVEL": "TAIS OLIVEIRA LIMA"
    },
    {
      "PATRIMONIO": "115258",
      "EQUIPAMENTO": "AR CONDICIONADO",
      "MODELO": "SPLIT",
      "MARCA": "MIDEA",
      "TENSAO": "220V",
      "FLUIDO": "R410A",
      "BTUS": "22K BTUS",
      "SETOR": "PRÉ FABRICADO",
      "SALA": "GERENCIA GERAL",
      "RESPONSAVEL": "THIAGO ARAUJO"
    },
    {
      "PATRIMONIO": "119775",
      "EQUIPAMENTO": "AR CONDICIONADO",
      "MODELO": "SPLIT",
      "MARCA": "SAMSUNG",
      "TENSAO": "220V",
      "FLUIDO": "R410A",
      "BTUS": "12K BTUS",
      "SETOR": "ADMINISTRATIVO",
      "SALA": "CONS. OCUPACONAL",
      "RESPONSAVEL": "TAIS OLIVEIRA LIMA"
    },
    {
      "PATRIMONIO": "140373",
      "EQUIPAMENTO": "AR CONDICIONADO",
      "MODELO": "SPLIT",
      "MARCA": "ADMIRAL",
      "TENSAO": "220V",
      "FLUIDO": "R410A",
      "BTUS": "12K BTUS",
      "SETOR": "BORRACHA",
      "SALA": "GER PRODUÇÃO",
      "RESPONSAVEL": "MARCELO"
    },
    {
      "PATRIMONIO": "140372",
      "EQUIPAMENTO": "AR CONDICIONADO",
      "MODELO": "SPLIT",
      "MARCA": "ADMIRAL",
      "TENSAO": "220V",
      "FLUIDO": "R410A",
      "BTUS": "12K BTUS",
      "SETOR": "BORRACHA",
      "SALA": "RH BORRACHA",
      "RESPONSAVEL": "ALICE"
    },
    {
      "PATRIMONIO": "126977",
      "EQUIPAMENTO": "AR CONDICIONADO",
      "MODELO": "SPLIT",
      "MARCA": "GREE",
      "TENSAO": "220V",
      "FLUIDO": "R410A",
      "BTUS": "30K BTUS",
      "SETOR": "PROTÓTIPO",
      "SALA": "SCRUM",
      "RESPONSAVEL": "WILLIAN"
    },
    {
      "PATRIMONIO": "135410",
      "EQUIPAMENTO": "AR CONDICIONADO",
      "MODELO": "SPLIT",
      "MARCA": "MIDEA",
      "TENSAO": "220V",
      "FLUIDO": "R410A",
      "BTUS": "18K BTUS",
      "SETOR": "BISTRO",
      "SALA": "BISTRO",
      "RESPONSAVEL": "GUSTAVO BRITES"
    },
    {
      "PATRIMONIO": "140377",
      "EQUIPAMENTO": "AR CONDICIONADO",
      "MODELO": "SPLIT",
      "MARCA": "ADMIRAL",
      "TENSAO": "220V",
      "FLUIDO": "R410A",
      "BTUS": "12K BTUS",
      "SETOR": "BORRACHA",
      "SALA": "GER GERAL BORRACHA",
      "RESPONSAVEL": "MARCELO"
    },
    {
      "PATRIMONIO": "144968",
      "EQUIPAMENTO": "AR CONDICIONADO",
      "MODELO": "SPLIT",
      "MARCA": "TCL",
      "TENSAO": "220V",
      "FLUIDO": "R32",
      "BTUS": "9K BTUS",
      "SETOR": "ADMINISTRATIVO",
      "SALA": "ODONTOLOGIA",
      "RESPONSAVEL": "TAIS OLIVEIRA LIMA"
    },
    {
      "PATRIMONIO": "140375",
      "EQUIPAMENTO": "AR CONDICIONADO",
      "MODELO": "SPLIT",
      "MARCA": "ADMIRAL",
      "TENSAO": "220V",
      "FLUIDO": "R410A",
      "BTUS": "12K BTUS",
      "SETOR": "PAV  CENTRAL",
      "SALA": "MATRIZARIA",
      "RESPONSAVEL": "DAVI"
    },
    {
      "PATRIMONIO": "168727",
      "EQUIPAMENTO": "AR CONDICIONADO",
      "MODELO": "SPLIT",
      "MARCA": "TCL",
      "TENSAO": "220V",
      "FLUIDO": "R32",
      "BTUS": "9K BTUS",
      "SETOR": "ADMINISTRATIVO",
      "SALA": "FONOAUDIOLOGIA",
      "RESPONSAVEL": "TAIS OLIVEIRA LIMA"
    },
    {
      "PATRIMONIO": "168726",
      "EQUIPAMENTO": "AR CONDICIONADO",
      "MODELO": "SPLIT",
      "MARCA": "TCL",
      "TENSAO": "220V",
      "FLUIDO": "R32",
      "BTUS": "9K BTUS",
      "SETOR": "ADMINISTRATIVO",
      "SALA": "ENFERMAGEM",
      "RESPONSAVEL": "TAIS OLIVEIRA LIMA"
    },
    {
      "PATRIMONIO": "168717",
      "EQUIPAMENTO": "AR CONDICIONADO",
      "MODELO": "SPLIT",
      "MARCA": "TCL",
      "TENSAO": "220V",
      "FLUIDO": "R32",
      "BTUS": "18K BTUS",
      "SETOR": "ADMINISTRATIVO",
      "SALA": "T.I",
      "RESPONSAVEL": "ANDERSON"
    },
    {
      "PATRIMONIO": "168725",
      "EQUIPAMENTO": "AR CONDICIONADO",
      "MODELO": "SPLIT",
      "MARCA": "TCL",
      "TENSAO": "220V",
      "FLUIDO": "R32",
      "BTUS": "9K BTUS",
      "SETOR": "ADMINISTRATIVO",
      "SALA": "CONSULTÓRIO MÉDICO",
      "RESPONSAVEL": "TAIS OLIVEIRA LIMA"
    },
    {
      "PATRIMONIO":
          "168749.", // Mantive com o ponto pois estava assim no seu original, mas o código abaixo trata isso.
      "EQUIPAMENTO": "AR CONDICIONADO",
      "MODELO": "SPLIT",
      "MARCA": "TCL",
      "TENSAO": "220V",
      "FLUIDO": "R32",
      "BTUS": "9K BTUS",
      "SETOR": "MANUTENÇÃO",
      "SALA": "COORDENAÇÃO GERAL",
      "RESPONSAVEL": "TAIS OLIVEIRA LIMA"
    }
  ];

  final CollectionReference collection =
      FirebaseFirestore.instance.collection('EQUIPAMENTOS_EMPRESA');

  int atualizados = 0;
  int naoEncontrados = 0;

  for (final item in listaCompilada) {
    // Tratamento para remover pontos eventuais no patrimonio (ex: 168749.)
    String patrimonioBusca =
        item['PATRIMONIO'].toString().replaceAll('.', '').trim();

    // Busca o documento onde o campo PATRIMONIO é igual ao da planilha
    final QuerySnapshot query = await collection
        .where('PATRIMONIO', isEqualTo: patrimonioBusca)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      // Se encontrou, atualiza os dados
      // Remove o campo PATRIMONIO do map de atualização para não sobrescrever a chave (opcional, mas seguro)
      Map<String, dynamic> dadosParaAtualizar = Map.from(item);
      dadosParaAtualizar.remove('PATRIMONIO');
      // Garante que o patrimônio na busca seja respeitado, ou removemos para manter o que está no banco se for chave.
      // Neste caso, vamos atualizar os outros campos.

      await query.docs.first.reference.update(dadosParaAtualizar);
      atualizados++;
    } else {
      naoEncontrados++;
      print('Patrimônio $patrimonioBusca não encontrado no Firebase.');
    }
  }

  return 'Processo finalizado. Atualizados: $atualizados. Não encontrados: $naoEncontrados.';
}
