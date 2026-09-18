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

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';

Future<String> enviarRelatorioPDFs(
  String emailCliente,
  String emailDestino,
  String? anoFiltro,
  String? mesFiltro,
) async {
  try {
    print('=== INICIANDO VARREDURA (COM FILTRO DE RELATÓRIOS) ===');
    print('Pasta Raiz (Storage): $emailCliente');
    print('Email de Destino: $emailDestino');
    if (anoFiltro != null) print('Filtro Ano: $anoFiltro');
    if (mesFiltro != null) print('Filtro Mês: $mesFiltro');

    // ── 1. CALCULAR PENDENTES ─────────────────────────────────────────────
    List<Map<String, dynamic>> listaPendentes = [];

    try {
      // Converte mês por extenso para número
      const listaMeses = [
        'Janeiro',
        'Fevereiro',
        'Março',
        'Abril',
        'Maio',
        'Junho',
        'Julho',
        'Agosto',
        'Setembro',
        'Outubro',
        'Novembro',
        'Dezembro'
      ];

      int mesNumero = -1;
      if (mesFiltro != null) {
        if (listaMeses.contains(mesFiltro)) {
          mesNumero = listaMeses.indexOf(mesFiltro) + 1;
        } else {
          mesNumero = int.tryParse(mesFiltro) ?? -1;
        }
      }

      if (mesNumero != -1 && anoFiltro != null) {
        // Busca preventivas do período
        final previQuery = await FirebaseFirestore.instance
            .collection('PREVENTIVAS')
            .where('EMAIL', isEqualTo: emailCliente.trim())
            .get();

        // Monta set de patrimônios que já têm preventiva no período
        final Set<String> patFeitos = {};
        for (final doc in previQuery.docs) {
          final d = doc.data();
          if (d['DATADAMANUTENCAO'] == null) continue;
          final dataDoc = (d['DATADAMANUTENCAO'] as Timestamp).toDate();
          if (dataDoc.year.toString() != anoFiltro) continue;
          if (dataDoc.month != mesNumero) continue;
          final pat = (d['PATRIMONIO'] ?? '')
              .toString()
              .toLowerCase()
              .trim()
              .replaceAll(RegExp(r'\s+'), ' ');
          if (pat.isNotEmpty) patFeitos.add(pat);
        }

        // Busca equipamentos com contrato ativo
        final equipQuery = await FirebaseFirestore.instance
            .collection('EQUIPAMENTOS_EMPRESA')
            .where('CONTRATO', isEqualTo: true)
            .where('EMAIL', isEqualTo: emailCliente.trim())
            .get();

        // Cruza para achar pendentes
        final Set<String> patConsumido = {};
        for (final doc in equipQuery.docs) {
          final d = doc.data();
          final pat = (d['PATRIMONIO'] ?? '')
              .toString()
              .toLowerCase()
              .trim()
              .replaceAll(RegExp(r'\s+'), ' ');

          if (pat.isNotEmpty &&
              patFeitos.contains(pat) &&
              !patConsumido.contains(pat)) {
            patConsumido.add(pat);
          } else {
            listaPendentes.add(d);
          }
        }

        print('Pendentes encontrados: ${listaPendentes.length}');
      }
    } catch (e) {
      print('Aviso: erro ao calcular pendentes: $e');
      // Não interrompe o fluxo — continua sem a seção de pendentes
    }

    // ── 2. MONTAR HTML DO RELATÓRIO ───────────────────────────────────────
    final storageRef =
        firebase_storage.FirebaseStorage.instance.ref().child(emailCliente);

    StringBuffer relatorioHtml = StringBuffer();
    relatorioHtml.writeln(
        '<div style="font-family: Arial, sans-serif; max-width: 800px; margin: 0 auto; padding: 20px; background-color: #f4f4f4;">');

    // IMAGEM DO TOPO
    relatorioHtml.writeln(
        '<div style="text-align: center; margin-bottom: 20px; background-color: #fff; padding: 20px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1);">');
    relatorioHtml.writeln(
        '<img src="https://i.ibb.co/DD2CKxFs/0bbcb951fecb.png" alt="HPS Refrigeração" style="max-width: 100%; height: auto; display: block; margin: 0 auto;">');
    relatorioHtml.writeln('</div>');

    relatorioHtml.writeln(
        '<h1 style="color: #333; border-bottom: 3px solid #007BFF; padding-bottom: 10px;">Relatório de Preventivas</h1>');
    relatorioHtml.writeln(
        '<p style="font-size: 16px; color: #555;">Seguem abaixo os links para download dos relatórios:</p>');

    // Container Principal
    relatorioHtml.writeln(
        '<div style="background-color: #fff; padding: 20px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1);">');

    // ── 3. LISTAR ANOS ────────────────────────────────────────────────────
    final anosResult = await storageRef.listAll();
    if (anosResult.prefixes.isEmpty) {
      print('AVISO: Nenhuma pasta de ANO encontrada.');
      return 'Nenhum arquivo encontrado.';
    }

    bool anoEncontrado = false;
    bool mesEncontrado = false;
    bool arquivoEncontrado = false;

    for (var anoRef in anosResult.prefixes) {
      String nomeAno = anoRef.name;

      if (anoFiltro != null && nomeAno != anoFiltro) {
        print('>>> Ano IGNORADO (filtro): $nomeAno');
        continue;
      }

      anoEncontrado = true;
      print('>>> Ano Encontrado: $nomeAno');

      relatorioHtml.writeln('''
        <div style="margin-bottom: 20px; border-left: 4px solid #007BFF; padding-left: 15px;">
          <h2 style="color: #007BFF; margin: 0 0 10px 0;">📅 Ano: $nomeAno</h2>
      ''');

      // ── 4. LISTAR MESES ───────────────────────────────────────────────
      final mesesResult = await anoRef.listAll();
      for (var mesRef in mesesResult.prefixes) {
        String nomeMes = mesRef.name;

        if (mesFiltro != null && nomeMes != mesFiltro) {
          print(' > Mês IGNORADO (filtro): $nomeMes');
          continue;
        }

        mesEncontrado = true;
        print(' > Mês Encontrado: $nomeMes');

        relatorioHtml.writeln('''
          <div style="margin-left: 20px; margin-bottom: 15px;">
            <h3 style="color: #555; margin: 0 0 10px 0;">📂 $nomeMes</h3>
        ''');

        // ── 5. LISTAR ARQUIVOS (PDFs) ─────────────────────────────────
        final arquivosResult = await mesRef.listAll();
        for (var arquivoRef in arquivosResult.items) {
          String nomeArquivo = arquivoRef.name;

          if (nomeArquivo.contains('Relatorio_Geral') ||
              nomeArquivo.contains('Relatorio_Completo')) {
            print('    [IGNORADO] Arquivo consolidado: $nomeArquivo');
            continue;
          }

          String downloadUrl = await arquivoRef.getDownloadURL();
          print('    - Arquivo adicionado: $nomeArquivo');
          arquivoEncontrado = true;

          relatorioHtml.writeln('''
            <div style="margin-left: 20px; padding: 10px; background-color: #f9f9f9; border-radius: 5px; margin-bottom: 8px;">
              <span style="font-size: 14px; color: #333;">📄 $nomeArquivo</span>
              <a href="$downloadUrl" style="margin-left: 10px; color: #007BFF; text-decoration: none; font-weight: bold;">⬇ Baixar</a>
            </div>
          ''');
        }

        relatorioHtml.writeln('</div>'); // Fecha Mês
      }

      relatorioHtml.writeln('</div>'); // Fecha Ano
    }

    relatorioHtml.writeln('</div>'); // Fecha Container PDFs

    // ── 6. SEÇÃO DE PENDENTES NO EMAIL ────────────────────────────────────
    if (listaPendentes.isNotEmpty) {
      final periodoLabel = (mesFiltro != null && anoFiltro != null)
          ? '$mesFiltro / $anoFiltro'
          : (anoFiltro ?? mesFiltro ?? '');

      relatorioHtml.writeln('''
        <div style="margin-top: 30px; background-color: #fff; padding: 20px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1);">
          <h2 style="color: #c0392b; border-bottom: 3px solid #c0392b; padding-bottom: 10px; margin-top: 0;">
            ⚠️ Equipamentos Pendentes — $periodoLabel
          </h2>
          <p style="font-size: 14px; color: #555; margin-bottom: 16px;">
            Os equipamentos abaixo <strong>não possuem preventiva registrada</strong> no período informado:
          </p>

          <table style="width: 100%; border-collapse: collapse; font-size: 13px;">
            <thead>
              <tr style="background-color: #c0392b; color: #ffffff;">
                <th style="padding: 8px 10px; text-align: left;">#</th>
                <th style="padding: 8px 10px; text-align: left;">Equipamento</th>
                <th style="padding: 8px 10px; text-align: left;">Modelo</th>
                <th style="padding: 8px 10px; text-align: left;">Localização</th>
                <th style="padding: 8px 10px; text-align: left;">Patrimônio</th>
                <th style="padding: 8px 10px; text-align: left;">Setor</th>
              </tr>
            </thead>
            <tbody>
      ''');

      for (int i = 0; i < listaPendentes.length; i++) {
        final item = listaPendentes[i];
        final bgColor = i % 2 == 0 ? '#fdf2f2' : '#ffffff';
        final num = i + 1;
        final equipamento = item['EQUIPAMENTO']?.toString() ?? '-';
        final modelo = item['MODELO']?.toString() ?? '-';
        final sala = item['SALA']?.toString() ?? '-';
        final patrimonio = item['PATRIMONIO']?.toString() ?? '-';
        final setor = item['SETOR']?.toString() ?? '-';

        relatorioHtml.writeln('''
              <tr style="background-color: $bgColor;">
                <td style="padding: 7px 10px; border-bottom: 1px solid #f0d0d0; color: #888;">$num</td>
                <td style="padding: 7px 10px; border-bottom: 1px solid #f0d0d0; font-weight: bold;">$equipamento</td>
                <td style="padding: 7px 10px; border-bottom: 1px solid #f0d0d0;">$modelo</td>
                <td style="padding: 7px 10px; border-bottom: 1px solid #f0d0d0;">$sala</td>
                <td style="padding: 7px 10px; border-bottom: 1px solid #f0d0d0; font-weight: bold; color: #c0392b;">$patrimonio</td>
                <td style="padding: 7px 10px; border-bottom: 1px solid #f0d0d0;">$setor</td>
              </tr>
        ''');
      }

      relatorioHtml.writeln('''
            </tbody>
          </table>

          <div style="margin-top: 16px; padding: 12px 16px; background-color: #fdf2f2; border: 1px solid #f5c6cb; border-radius: 6px; display: flex; justify-content: space-between;">
            <span style="font-size: 13px; font-weight: bold; color: #333;">
              Total de equipamentos sem preventiva em $periodoLabel:
            </span>
            <span style="font-size: 13px; font-weight: bold; color: #c0392b;">
              ${listaPendentes.length} equipamento${listaPendentes.length != 1 ? 's' : ''}
            </span>
          </div>
        </div>
      ''');
    }

    relatorioHtml.writeln('</div>'); // Fecha div raiz

    // ── 7. VALIDAÇÕES ─────────────────────────────────────────────────────
    if (anoFiltro != null && !anoEncontrado) {
      return 'Ano "$anoFiltro" não encontrado. Verifique se o ano está correto.';
    }
    if (mesFiltro != null && !mesEncontrado) {
      return 'Mês "$mesFiltro" não encontrado. Verifique se o mês está correto.';
    }
    if (!arquivoEncontrado) {
      String mensagem = 'Nenhum relatório encontrado';
      if (anoFiltro != null && mesFiltro != null) {
        mensagem += ' para $mesFiltro de $anoFiltro.';
      } else if (anoFiltro != null) {
        mensagem += ' para o ano $anoFiltro.';
      } else if (mesFiltro != null) {
        mensagem += ' para o mês $mesFiltro.';
      } else {
        mensagem += '.';
      }
      return mensagem;
    }

    print('=== CONSTRUÇÃO DO EMAIL FINALIZADA ===');

    // ── 8. ENVIAR EMAIL ───────────────────────────────────────────────────
    bool emailEnviado = await _dispararEmailBrevo(emailDestino,
        'Relatório de Manutenções - HPS', relatorioHtml.toString());

    if (emailEnviado) {
      return 'Email enviado com sucesso!';
    } else {
      return 'Erro ao enviar email (API).';
    }
  } catch (e) {
    print('ERRO CRÍTICO NA ACTION: $e');
    return 'Erro técnico: $e';
  }
}

// ── EMAIL ─────────────────────────────────────────────────────────────────
Future<bool> _dispararEmailBrevo(
  String toEmail,
  String subject,
  String contentMessage,
) async {
  const String apiKey =
      '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';
  const String senderEmail = 'equipe@hpsrefri.com.br';
  const String senderName = 'Hps Refrigeração';

  final Uri url = Uri.parse('https://api.brevo.com/v3/smtp/email');

  final String htmlBody = '''
    <div style="font-family: Arial, sans-serif; max-width: 800px; margin: 0 auto;">
      $contentMessage
      <div style="margin-top: 30px; padding-top: 20px; border-top: 1px solid #ddd; color: #777; font-size: 14px;">
        <p>Atenciosamente,<br>Equipe HPS Refrigeração</p>
      </div>
    </div>
  ''';

  final Map<String, dynamic> body = {
    "sender": {"name": senderName, "email": senderEmail},
    "to": [
      {"email": toEmail}
    ],
    "subject": subject,
    "htmlContent": htmlBody,
  };

  try {
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'api-key': apiKey,
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      print('Erro Brevo: ${response.body}');
      return false;
    }
  } catch (e) {
    print('Erro HTTP: $e');
    return false;
  }
}
