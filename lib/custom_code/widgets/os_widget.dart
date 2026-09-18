// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'index.dart'; // Imports other custom widgets

import 'dart:math' as math;
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:flutter/services.dart';

// ═══════════════════════════════════════════════════════════════
//  UPPERCASE FORMATTER
// ═══════════════════════════════════════════════════════════════
class _UpperCase extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return newValue.copyWith(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

bool _fotoValida(String? s) {
  final u = (s ?? '').trim();
  return u.startsWith('http://') || u.startsWith('https://')
      ? !u.contains('Erro:')
      : false;
}

// ═══════════════════════════════════════════════════════════════
//  TEMA — Clean Light / Full Black Dark
// ═══════════════════════════════════════════════════════════════
class _Th {
  _Th(this._dark);
  final bool _dark;

  Color get bg => _dark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
  Color get surf => _dark ? const Color(0xFF1E293B) : const Color(0xFFFFFFFF);
  Color get surf2 => _dark ? const Color(0xFF334155) : const Color(0xFFF1F5F9);
  Color get surf3 => _dark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);
  Color get card => _dark ? const Color(0xFF1E293B) : const Color(0xFFFFFFFF);

  Color get border => _dark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
  Color get border2 =>
      _dark ? const Color(0xFF475569) : const Color(0xFFCBD5E1);

  Color get ink => _dark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
  Color get ink2 => _dark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
  Color get ink3 => _dark ? const Color(0xFF64748B) : const Color(0xFF94A3B8);
  Color get ink4 => _dark ? const Color(0xFF475569) : const Color(0xFFCBD5E1);

  Color get glass => _dark ? const Color(0x14FFFFFF) : const Color(0x06000000);
  Color get glass2 => _dark ? const Color(0x0CFFFFFF) : const Color(0x04000000);

  Color get shadow => _dark ? const Color(0x40000000) : const Color(0x09000000);

  bool get isDark => _dark;
}

const _cyan = Color(0xFF00D4FF);
const _violet = Color(0xFF7C3AED);
const _amber = Color(0xFFF59E0B);
const _emerald = Color(0xFF10B981);
const _rose = Color(0xFFEF4444);
const _blue = Color(0xFF3B82F6);
const _purple = Color(0xFFA855F7);
const _teal = Color(0xFF06B6D4);
const _slate = Color(0xFF64748B);

Color _sColor(String s) {
  switch (s) {
    case 'INICIAR AVALIAÇÃO':
      return _slate;
    case 'INICIOU O SERVIÇO':
      return _blue;
    case 'PASSAR ORÇAMENTO':
      return _amber;
    case 'CANCELADA':
      return _rose;
    case 'AGUARDANDO PEÇA':
      return _purple;
    case 'AGUARDANDO APROVAÇÃO':
      return _teal;
    case 'APROVADO':
      return _emerald;
    case 'CONCLUÍDA':
      return _emerald;
    default:
      return _slate;
  }
}

IconData _sIcon(String s) {
  switch (s) {
    case 'INICIAR AVALIAÇÃO':
      return Icons.search_rounded;
    case 'INICIOU O SERVIÇO':
      return Icons.play_circle_outline_rounded;
    case 'PASSAR ORÇAMENTO':
      return Icons.receipt_long_rounded;
    case 'CANCELADA':
      return Icons.cancel_outlined;
    case 'AGUARDANDO PEÇA':
      return Icons.inventory_2_outlined;
    case 'AGUARDANDO APROVAÇÃO':
      return Icons.pending_actions_rounded;
    case 'APROVADO':
      return Icons.thumb_up_alt_outlined;
    case 'CONCLUÍDA':
      return Icons.check_circle_outline_rounded;
    default:
      return Icons.assignment_outlined;
  }
}

const _sOpts = [
  'INICIAR AVALIAÇÃO',
  'INICIOU O SERVIÇO',
  'PASSAR ORÇAMENTO',
  'CANCELADA',
  'AGUARDANDO PEÇA',
  'AGUARDANDO APROVAÇÃO',
  'APROVADO',
  'CONCLUÍDA',
];
const _meses = [
  'JANEIRO',
  'FEVEREIRO',
  'MARÇO',
  'ABRIL',
  'MAIO',
  'JUNHO',
  'JULHO',
  'AGOSTO',
  'SETEMBRO',
  'OUTUBRO',
  'NOVEMBRO',
  'DEZEMBRO',
];
const _qtdOpts = [
  '1 TÉCNICO',
  '2 TÉCNICOS',
  '3 TÉCNICOS',
  '4 TÉCNICOS',
  '5 TÉCNICOS',
  '6 TÉCNICOS',
  '7 TÉCNICOS',
  '8 TÉCNICOS',
  '9 TÉCNICOS',
  '10 TÉCNICOS',
];

double _toD(dynamic v) {
  if (v == null) return 0.0;
  if (v is double) return v;
  if (v is int) return v.toDouble();
  return double.tryParse(v.toString()) ?? 0.0;
}

TextStyle _ts(double sz, {Color? c, bool b = false, double? ls, double? h}) =>
    TextStyle(
        fontSize: sz,
        color: c,
        fontWeight: b ? FontWeight.w700 : FontWeight.w400,
        letterSpacing: ls,
        height: h);

// ═══════════════════════════════════════════════════════════════
//  EMAIL POR STATUS — Brevo
// ═══════════════════════════════════════════════════════════════
Future<void> _sendEmailPorStatus({
  required String toEmail,
  required String status,
  required String numeroos,
  required String cliente,
  required String equipamento,
  required String sala,
  required String setor,
  required String patrimonio,
}) async {
  if (toEmail.isEmpty) return;

  const senderEmail = 'equipe@hpsrefri.com.br';
  const senderName = 'HPS Refrigeração';
  const imgUrl =
      'https://firebasestorage.googleapis.com/v0/b/h-p-s-modificado-emdcp0.appspot.com/o/Gemini_Generated_Image_2xpdsd2xpdsd2xpd%20(1).png?alt=media&token=be3e052e-a0b8-4e8c-8151-b9365b507ed5';

  String apiKey = '';
  try {
    final snap = await FirebaseFirestore.instance
        .collection('USUARIOS')
        .where('email', isEqualTo: 'hpsrefri@gmail.com')
        .limit(1)
        .get();
    if (snap.docs.isNotEmpty) {
      apiKey = (snap.docs.first.data()['apibrevo'] ?? '').toString().trim();
    }
  } catch (e) {
    debugPrint('Erro ao buscar apibrevo: $e');
  }
  if (apiKey.isEmpty) return;

  final Map<String, Map<String, String>> _info = {
    'INICIAR AVALIAÇÃO': {
      'emoji': '🔍',
      'titulo': 'Avaliação Iniciada — O.S #$numeroos',
      'tagline': 'Nossa equipe técnica já está avaliando seu equipamento.',
      'corHex': '#64748B',
      'corpo':
          'Informamos que <strong>iniciamos a avaliação</strong> do seu equipamento na <strong>O.S #$numeroos</strong>. '
              'Nossa equipe técnica está analisando o defeito relatado e em breve retornaremos com o diagnóstico completo.',
      'detalhe':
          '🔎&nbsp;&nbsp;Nossa equipe está realizando os testes iniciais para identificar a causa do problema com precisão.',
    },
    'INICIOU O SERVIÇO': {
      'emoji': '🔧',
      'titulo': 'Avaliação Iniciada — O.S #$numeroos',
      'tagline':
          'Nossa equipe técnica já iniciou a avaliação do seu equipamento.',
      'corHex': '#3B82F6',
      'corpo':
          'Informamos que a <strong>avaliação foi iniciada</strong> no seu equipamento da <strong>O.S #$numeroos</strong>. '
              'Nossa equipe técnica está trabalhando para identificar e solucionar o problema com qualidade e agilidade.',
      'detalhe':
          '⚙️&nbsp;&nbsp;Nossa equipe está totalmente dedicada à avaliação do equipamento. Em breve traremos novidades.',
    },
    'PASSAR ORÇAMENTO': {
      'emoji': '📋',
      'titulo': 'Elaborando Orçamento — O.S #$numeroos',
      'tagline': 'Concluímos a avaliação e estamos elaborando o orçamento.',
      'corHex': '#F59E0B',
      'corpo':
          'Concluímos a avaliação do seu equipamento na <strong>O.S #$numeroos</strong> e estamos <strong>elaborando o orçamento</strong> detalhado. '
              'Em breve você receberá todas as informações sobre peças e serviços necessários.',
      'detalhe':
          '📝&nbsp;&nbsp;Estamos elaborando um orçamento transparente e detalhado para sua aprovação.',
    },
    'CANCELADA': {
      'emoji': '❌',
      'titulo': 'O.S Cancelada — #$numeroos',
      'tagline': 'A ordem de serviço foi cancelada.',
      'corHex': '#EF4444',
      'corpo':
          'Informamos que a <strong>O.S #$numeroos</strong> foi <strong>cancelada</strong>. '
              'Caso tenha dúvidas ou deseje reagendar o serviço, entre em contato com nossa equipe.',
      'detalhe':
          'ℹ️&nbsp;&nbsp;Entre em contato pelo telefone (77) 98819-4630 para mais informações ou reagendamento.',
    },
    'AGUARDANDO PEÇA': {
      'emoji': '📦',
      'titulo': 'Aguardando Peça — O.S #$numeroos',
      'tagline': 'Identificamos a necessidade de reposição de peça.',
      'corHex': '#A855F7',
      'corpo':
          'Durante a avaliação da <strong>O.S #$numeroos</strong>, identificamos que será necessário o uso de peça(s) de reposição. '
              'Estamos <strong>aguardando a chegada da(s) peça(s)</strong> para dar continuidade ao serviço.',
      'detalhe':
          '🚚&nbsp;&nbsp;Assim que a peça chegar, prosseguiremos imediatamente com o reparo do seu equipamento.',
    },
    'AGUARDANDO APROVAÇÃO': {
      'emoji': '✅',
      'titulo': 'Orçamento Disponível — O.S #$numeroos',
      'tagline': 'Seu orçamento está pronto para aprovação.',
      'corHex': '#06B6D4',
      'corpo':
          'O <strong>orçamento da O.S #$numeroos</strong> já está disponível para sua análise. '
              'Acesse o aplicativo ou o site para visualizar os detalhes e <strong>aprovar o serviço</strong>.',
      'detalhe':
          '📱&nbsp;&nbsp;Abra o app <strong>HPS Refrigeração</strong> ou acesse <a href="https://www.hpsrefri.com.br" style="color:#06B6D4;">www.hpsrefri.com.br</a> para visualizar e aprovar o orçamento.',
    },
    'APROVADO': {
      'emoji': '👍',
      'titulo': 'Orçamento Aprovado — O.S #$numeroos',
      'tagline': 'Orçamento aprovado! Iniciaremos o serviço em breve.',
      'corHex': '#10B981',
      'corpo':
          'Recebemos a aprovação do orçamento da <strong>O.S #$numeroos</strong>. '
              'Nossa equipe técnica iniciará o serviço o mais breve possível e você será notificado sobre cada etapa.',
      'detalhe':
          '🗓️&nbsp;&nbsp;Em breve nossa equipe entrará em contato para confirmar a data e horário do serviço.',
    },
    'CONCLUÍDA': {
      'emoji': '🎉',
      'titulo': 'Serviço Concluído — O.S #$numeroos',
      'tagline': 'Seu equipamento está pronto!',
      'corHex': '#10B981',
      'corpo':
          'É com satisfação que informamos que a <strong>O.S #$numeroos</strong> foi <strong>concluída com sucesso</strong>! '
              'O equipamento foi reparado e está em plenas condições de funcionamento.',
      'detalhe':
          '⭐&nbsp;&nbsp;Obrigado pela confiança! Em caso de qualquer dúvida, nossa equipe está à disposição.',
    },
  };

  final info = _info[status] ??
      {
        'emoji': '📌',
        'titulo': 'Atualização da O.S #$numeroos',
        'tagline': 'Sua O.S teve uma atualização de status.',
        'corHex': '#64748B',
        'corpo':
            'A <strong>O.S #$numeroos</strong> teve seu status atualizado para <strong>$status</strong>.',
        'detalhe':
            'ℹ️&nbsp;&nbsp;Entre em contato caso tenha alguma dúvida sobre sua ordem de serviço.',
      };

  final emoji = info['emoji']!;
  final titulo = info['titulo']!;
  final tagline = info['tagline']!;
  final corHex = info['corHex']!;
  final corpo = info['corpo']!;
  final detalhe = info['detalhe']!;

  final htmlBody = '''
<!DOCTYPE html>
<html lang="pt-BR">
<head>
  <meta charset="UTF-8">
  <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
  <title>$titulo</title>
</head>
<body style="margin:0;padding:0;background-color:#f4f6f8;font-family:Arial,Helvetica,sans-serif;">
  <table width="100%" cellpadding="0" cellspacing="0" border="0"
         style="background-color:#f4f6f8;padding:20px 0;">
    <tr><td align="center">
      <table width="600" cellpadding="0" cellspacing="0" border="0"
             style="background:#ffffff;border-radius:12px;overflow:hidden;max-width:1400px;width:100%;">

        <!-- BANNER -->
        <tr>
          <td style="padding:0;margin:0;line-height:0;">
            <img src="$imgUrl" alt="HPS Refrigeração" width="600"
                 style="display:block;width:100%;max-width:1400px;height:auto;border:0;"/>
          </td>
        </tr>

        <!-- BARRA COLORIDA POR STATUS -->
        <tr>
          <td style="background-color:$corHex;padding:12px 24px;">
            <table width="100%" cellpadding="0" cellspacing="0" border="0">
              <tr>
                <td>
                  <span style="color:#ffffff;font-size:13px;font-weight:bold;font-family:Arial,sans-serif;">
                    $emoji&nbsp;&nbsp;$status
                  </span>
                </td>
                <td align="right">
                  <span style="background:#ffffff20;color:#ffffff;font-size:11px;font-weight:bold;
                               padding:4px 10px;border-radius:20px;font-family:Arial,sans-serif;">
                    Notificação Automática
                  </span>
                </td>
              </tr>
            </table>
          </td>
        </tr>

        <!-- TÍTULO + TAGLINE -->
        <tr>
          <td style="padding:28px 28px 12px 28px;text-align:center;">
            <h1 style="margin:0 0 8px 0;font-size:20px;font-weight:bold;
                       color:#1A3C34;font-family:Arial,sans-serif;">
              $titulo
            </h1>
            <p style="margin:0;font-size:13px;color:#64748b;font-family:Arial,sans-serif;">
              $tagline
            </p>
          </td>
        </tr>

        <!-- CORPO -->
        <tr>
          <td style="padding:12px 28px 20px 28px;font-family:Arial,Helvetica,sans-serif;">

            <p style="margin:0 0 16px 0;font-size:15px;color:#1f2937;line-height:1.7;">
              Prezado(a) <strong>$cliente</strong>,
            </p>

            <p style="margin:0 0 20px 0;font-size:15px;color:#374151;line-height:1.7;">
              $corpo
            </p>

            <!-- DETALHE COLORIDO -->
            <table width="100%" cellpadding="0" cellspacing="0" border="0"
                   style="background:#f0fdf4;border-left:4px solid $corHex;
                          border-radius:0 8px 8px 0;margin-bottom:24px;">
              <tr>
                <td style="padding:14px 16px;font-size:14px;color:#14532d;
                           line-height:1.6;font-family:Arial,sans-serif;">
                  $detalhe
                </td>
              </tr>
            </table>

            <!-- TABELA DE DETALHES DA OS -->
            <table width="100%" cellpadding="0" cellspacing="0" border="0"
                   style="border-collapse:collapse;border-radius:8px;overflow:hidden;
                          border:1px solid #e2e8f0;margin-bottom:24px;
                          font-size:14px;font-family:Arial,sans-serif;">
              <tr>
                <td colspan="2" style="background:#1A3C34;padding:10px 14px;">
                  <span style="color:#ffffff;font-size:13px;font-weight:bold;letter-spacing:0.5px;">
                    DETALHES DA ORDEM DE SERVIÇO
                  </span>
                </td>
              </tr>
              <tr style="background:#f8fafc;">
                <td style="padding:10px 14px;font-weight:bold;color:#374151;
                           width:160px;border-bottom:1px solid #e2e8f0;">N° da O.S</td>
                <td style="padding:10px 14px;color:#1f2937;border-bottom:1px solid #e2e8f0;">
                  <strong>#$numeroos</strong>
                </td>
              </tr>
              <tr>
                <td style="padding:10px 14px;font-weight:bold;color:#374151;
                           border-bottom:1px solid #e2e8f0;">Cliente</td>
                <td style="padding:10px 14px;color:#1f2937;border-bottom:1px solid #e2e8f0;">
                  $cliente
                </td>
              </tr>
              <tr style="background:#f8fafc;">
                <td style="padding:10px 14px;font-weight:bold;color:#374151;
                           border-bottom:1px solid #e2e8f0;">Equipamento</td>
                <td style="padding:10px 14px;color:#1f2937;border-bottom:1px solid #e2e8f0;">
                  $equipamento
                </td>
              </tr>
              <tr>
                <td style="padding:10px 14px;font-weight:bold;color:#374151;
                           border-bottom:1px solid #e2e8f0;">Sala</td>
                <td style="padding:10px 14px;color:#1f2937;border-bottom:1px solid #e2e8f0;">
                  $sala
                </td>
              </tr>
              <tr style="background:#f8fafc;">
                <td style="padding:10px 14px;font-weight:bold;color:#374151;
                           border-bottom:1px solid #e2e8f0;">Patrimônio</td>
                <td style="padding:10px 14px;color:#1f2937;border-bottom:1px solid #e2e8f0;">
                  $patrimonio
                </td>
              </tr>
              <tr>
                <td style="padding:10px 14px;font-weight:bold;color:#374151;">Setor</td>
                <td style="padding:10px 14px;color:#1f2937;">$setor</td>
              </tr>
            </table>

            <p style="margin:0 0 8px 0;font-size:14px;color:#64748b;line-height:1.6;">
              Em caso de dúvidas, nossa equipe está à disposição.
            </p>

          </td>
        </tr>

        <!-- DIVISOR -->
        <tr>
          <td style="padding:0 28px;">
            <hr style="border:none;border-top:1px solid #e8ecf0;margin:0;">
          </td>
        </tr>

        <!-- ASSINATURA -->
        <tr>
          <td style="padding:20px 28px;font-family:Arial,Helvetica,sans-serif;">
            <table cellpadding="0" cellspacing="0" border="0">
              <tr>
                <td style="width:44px;vertical-align:top;">
                  <div style="width:40px;height:40px;background:#1A3C34;border-radius:50%;
                              text-align:center;line-height:40px;">
                    <span style="color:#ffffff;font-size:18px;font-weight:bold;
                                 font-family:Arial,sans-serif;">H</span>
                  </div>
                </td>
                <td style="padding-left:12px;vertical-align:top;">
                  <span style="font-size:15px;font-weight:bold;color:#1A3C34;
                               font-family:Arial,sans-serif;">Huagner Pires</span><br>
                  <span style="font-size:13px;color:#555555;font-family:Arial,sans-serif;">
                    Especialista em Refrigeração
                  </span><br>
                  <span style="font-size:12px;color:#888888;font-family:Arial,sans-serif;">
                    hpsrefri.com.br
                  </span>
                </td>
              </tr>
            </table>
          </td>
        </tr>

        <!-- RODAPÉ -->
        <tr>
          <td style="background:#f1f5f9;padding:14px 28px;text-align:center;
                     font-size:12px;color:#94a3b8;font-family:Arial,Helvetica,sans-serif;
                     border-top:1px solid #e2e8f0;">
            &copy; 2026 HPS Refrigeração &middot; Todos os direitos reservados<br>
            <span style="font-size:11px;">
              Esta é uma mensagem automática, por favor não responda diretamente.
            </span>
          </td>
        </tr>

      </table>
    </td></tr>
  </table>
</body>
</html>
''';

  try {
    await http.post(
      Uri.parse('https://api.brevo.com/v3/smtp/email'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'api-key': apiKey,
      },
      body: jsonEncode({
        'sender': {'name': senderName, 'email': senderEmail},
        'replyTo': {'name': senderName, 'email': senderEmail},
        'to': [
          {'email': toEmail}
        ],
        'subject': titulo,
        'htmlContent': htmlBody,
      }),
    );
  } catch (e) {
    debugPrint('❌ Erro ao enviar e-mail ($status): $e');
  }
}

/// ═══════════════════════════════════════════════════════════════ WIDGET
/// PRINCIPAL ═══════════════════════════════════════════════════════════════
class OsWidget extends StatefulWidget {
  const OsWidget(
      {super.key, this.width, this.height, required this.statusFiltro});
  final double? width;
  final double? height;
  final String statusFiltro;
  @override
  State<OsWidget> createState() => _OsState();
}

class _OsState extends State<OsWidget> with TickerProviderStateMixin {
  final _db = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _list = [];
  Map<String, String> _fotos = {};
  Map<String, String> _imgEquip = {};
  bool _loading = true;
  String? _erro;

  late AnimationController _fadeCtrl;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _fade = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _buscar();
  }

  @override
  void didUpdateWidget(covariant OsWidget old) {
    super.didUpdateWidget(old);
    if (old.statusFiltro != widget.statusFiltro) _buscar();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  Future<void> _buscar() async {
    if (widget.statusFiltro.isEmpty) {
      setState(() {
        _loading = false;
        _list = [];
      });
      return;
    }
    setState(() {
      _loading = true;
      _erro = null;
    });
    try {
      final rs = await Future.wait([
        _db
            .collection('SERVICOSREALIZADOS')
            .where('STATUS', isEqualTo: widget.statusFiltro)
            .get(),
        _db.collection('PONTOS_POR_TECNICO').get(),
        _db.collection('IMAGENS').get(),
      ]);
      final fotos = <String, String>{};
      for (final d in (rs[1] as QuerySnapshot).docs) {
        final data = d.data() as Map<String, dynamic>;
        final nome = (data['TECNICO'] ?? '').toString().trim();
        final foto = (data['FOTO'] ?? '').toString().trim();
        if (nome.isNotEmpty && _fotoValida(foto)) fotos[nome] = foto;
      }
      final imgEquip = <String, String>{};
      for (final d in (rs[2] as QuerySnapshot).docs) {
        final data = d.data() as Map<String, dynamic>;
        final pat = (data['PATRIMONIO'] ?? '').toString().trim();
        final url = (data['IMAGEM'] ?? '').toString().trim();
        if (pat.isNotEmpty && url.isNotEmpty) imgEquip[pat] = url;
      }
      setState(() {
        _fotos = fotos;
        _imgEquip = imgEquip;
        _list = (rs[0] as QuerySnapshot)
            .docs
            .map((d) => {'_id': d.id, ...(d.data() as Map<String, dynamic>)})
            .toList();
        _loading = false;
      });
      _fadeCtrl.forward(from: 0);
    } catch (e) {
      setState(() {
        _erro = e.toString();
        _loading = false;
      });
    }
  }

  OsBtnT _btnT(Map os) {
    final s = (os['STATUS'] ?? '').toString();
    final t = (os['TECNICORESPONSAVEL'] ?? '').toString();
    if (s == 'PASSAR ORÇAMENTO') return OsBtnT.orcamento;
    if (t.isEmpty || t == 'NÃO DEFINIDO') return OsBtnT.atender;
    return OsBtnT.editar;
  }

  void _abrir(Map<String, dynamic> os) {
    final tipo = _btnT(os);
    final Widget page = tipo == OsBtnT.orcamento
        ? OsOrcamentoPage(os: os, db: _db, onSaved: _buscar, embedded: true)
        : OsEditPage(os: os, db: _db, onSaved: _buscar, embedded: true);
    showHpsSheet(context, child: page);
  }

  @override
  Widget build(BuildContext context) {
    final th = _Th(Theme.of(context).brightness == Brightness.dark);
    return Container(
      width: widget.width ?? double.infinity,
      height: widget.height,
      color: th.bg,
      child: _loading
          ? _skelView(th)
          : _erro != null
              ? _erroView(th)
              : _list.isEmpty
                  ? _emptView(th)
                  : _listaView(th),
    );
  }

  Widget _skelView(_Th th) => ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
        itemCount: 3,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (_, i) => _SkelCard(th: th, delay: i * 100),
      );

  Widget _erroView(_Th th) => Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _rose.withOpacity(.10),
                border: Border.all(color: _rose.withOpacity(.25))),
            child: const Icon(Icons.wifi_off_rounded, color: _rose, size: 28)),
        const SizedBox(height: 16),
        Text('Sem conexão', style: _ts(17, c: th.ink, b: true)),
        const SizedBox(height: 6),
        Text(_erro!, style: _ts(11, c: th.ink3), textAlign: TextAlign.center),
        const SizedBox(height: 24),
        _Btn(
            label: 'Tentar novamente',
            icon: Icons.refresh_rounded,
            onTap: _buscar,
            color: _cyan,
            th: th),
      ]));

  Widget _emptView(_Th th) => Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                    colors: [_violet.withOpacity(.12), Colors.transparent])),
            child: Icon(Icons.inbox_rounded, color: th.ink3, size: 36)),
        const SizedBox(height: 16),
        Text('Nenhuma O.S encontrada', style: _ts(17, c: th.ink2, b: true)),
        const SizedBox(height: 4),
        Text(widget.statusFiltro, style: _ts(12, c: th.ink3)),
      ]));

  Widget _listaView(_Th th) => FadeTransition(
        opacity: _fade,
        child: RefreshIndicator(
          color: _cyan,
          backgroundColor: th.surf,
          onRefresh: _buscar,
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
            itemCount: _list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 14),
            itemBuilder: (_, i) => _OsCard(
              th: th,
              os: _list[i],
              tipo: _btnT(_list[i]),
              fotoUrl: _fotos[(_list[i]['TECNICORESPONSAVEL'] ?? '')
                      .toString()
                      .trim()] ??
                  _fotos[(_list[i]['TECNICO'] ?? '').toString().trim()],
              fotos: _fotos,
              imgEquipUrl:
                  _imgEquip[(_list[i]['PATRIMONIO'] ?? '').toString().trim()],
              index: i,
              onAction: () => _abrir(_list[i]),
            ),
          ),
        ),
      );
}

// ═══════════════════════════════════════════════════════════════
//  OS CARD
// ═══════════════════════════════════════════════════════════════
enum OsBtnT { atender, editar, orcamento }

class _OsCard extends StatefulWidget {
  const _OsCard(
      {required this.th,
      required this.os,
      required this.tipo,
      this.fotoUrl,
      required this.fotos,
      this.imgEquipUrl,
      required this.onAction,
      required this.index});
  final _Th th;
  final Map<String, dynamic> os;
  final OsBtnT tipo;
  final String? fotoUrl;
  final Map<String, String> fotos;
  final String? imgEquipUrl;
  final VoidCallback onAction;
  final int index;
  @override
  State<_OsCard> createState() => _OsCardState();
}

class _OsCardState extends State<_OsCard> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _slide, _fade;
  bool _hover = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: Duration(milliseconds: 450 + widget.index * 50));
    _slide = Tween<double>(begin: 30, end: 0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    Future.delayed(Duration(milliseconds: widget.index * 70), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final th = widget.th;
    final os = widget.os;

    final s = (os['STATUS'] ?? '').toString();
    final cor = _sColor(s);
    final cli = (os['CLIENTE'] ?? '—').toString();
    final num = (os['NUMERODAOS'] ?? '—').toString();
    final eq = (os['EQUIPAMENTO'] ?? '—').toString();
    final sl = (os['SALA'] ?? '—').toString();
    final st = (os['SETOR'] ?? '—').toString();
    final cd = (os['CADASTRO'] ?? os['DATA']?.toString() ?? '—').toString();
    final sv = (os['SERVICO'] ?? '—').toString();
    final pat = (os['PATRIMONIO'] ?? '').toString().trim();
    final desc = (os['DESCRICAO'] ?? '').toString().trim();
    final servReal = (os['SERVICOREALIZADO'] ?? '').toString().trim();

    String peca = '';
    if (os['PECAS'] is List) {
      peca = (os['PECAS'] as List).join(', ');
    } else {
      peca = (os['PECAS'] ?? '').toString().trim();
    }

    final previsaoPeca = (os['PREVISAODAPECA'] ?? '').toString().trim();
    final mes = (os['MES'] ?? '').toString().trim();
    final ini = (os['INICIO'] ?? '').toString().trim();
    final ter = (os['TERMINO'] ?? '').toString().trim();

    final tec1 = (os['TECNICORESPONSAVEL'] ?? 'NÃO DEFINIDO').toString().trim();
    final tec2 = (os['TECNICO2'] ?? '').toString().trim();
    final tec3 = (os['TECNICO3'] ?? '').toString().trim();
    final tec4 = (os['TECNICO4'] ?? '').toString().trim();

    final equipe = [tec1];
    if (tec2.isNotEmpty) equipe.add(tec2);
    if (tec3.isNotEmpty) equipe.add(tec3);
    if (tec4.isNotEmpty) equipe.add(tec4);

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, child) => FadeTransition(
        opacity: _fade,
        child:
            Transform.translate(offset: Offset(0, _slide.value), child: child),
      ),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: th.card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: _hover ? cor.withOpacity(.35) : cor.withOpacity(.12),
                width: _hover ? 1.5 : 1),
            boxShadow: th.isDark
                ? null
                : [
                    BoxShadow(
                      color: _hover ? cor.withOpacity(.08) : th.shadow,
                      blurRadius: _hover ? 16 : 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
          ),
          clipBehavior: Clip.hardEdge,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              height: 3,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [cor, cor.withOpacity(.25)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            ),
            if (widget.imgEquipUrl != null && widget.imgEquipUrl!.isNotEmpty)
              GestureDetector(
                onTap: () =>
                    _abrirImagemTela(context, widget.imgEquipUrl!, eq, th),
                child: Stack(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 240,
                      child: Image.network(
                        widget.imgEquipUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          height: 240,
                          color: th.surf3,
                          child: Center(
                            child: Icon(Icons.image_not_supported_outlined,
                                color: th.ink3, size: 32),
                          ),
                        ),
                        loadingBuilder: (_, child, progress) {
                          if (progress == null) return child;
                          return Container(
                            height: 240,
                            color: th.surf3,
                            child: Center(
                              child: CircularProgressIndicator(
                                color: cor,
                                strokeWidth: 2,
                                value: progress.expectedTotalBytes != null
                                    ? progress.cumulativeBytesLoaded /
                                        progress.expectedTotalBytes!
                                    : null,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              th.card.withOpacity(.85),
                            ],
                            stops: const [0.4, 1.0],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 10,
                      left: 14,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: th.card.withOpacity(.85),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: cor.withOpacity(.35)),
                        ),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(Icons.devices_other_rounded,
                              size: 12, color: cor),
                          const SizedBox(width: 5),
                          Text(eq,
                              style: _ts(11, c: th.ink, b: true),
                              overflow: TextOverflow.ellipsis),
                        ]),
                      ),
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(.4),
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: Colors.white.withOpacity(.25), width: 1),
                        ),
                        child: const Icon(Icons.fullscreen_rounded,
                            color: Colors.white, size: 18),
                      ),
                    ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                Text('O.S #$num',
                                    style:
                                        _ts(10, c: th.ink3, ls: 1.5, b: true)),
                                const SizedBox(height: 4),
                                Text(cli,
                                    style: _ts(19, c: th.ink, b: true, h: 1.1),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1),
                              ])),
                          const SizedBox(width: 12),
                          _StatusPill(status: s, cor: cor, th: th),
                        ]),
                    const SizedBox(height: 14),
                    Wrap(spacing: 8, runSpacing: 8, children: [
                      if (pat.isNotEmpty)
                        _Chip(
                            icon: Icons.qr_code_2_rounded,
                            label: 'PAT: $pat',
                            th: th,
                            cor: cor),
                      _Chip(
                          icon: Icons.devices_other_rounded,
                          label: eq,
                          th: th,
                          cor: cor),
                      _Chip(
                          icon: Icons.meeting_room_rounded,
                          label: sl,
                          th: th,
                          cor: cor),
                      _Chip(
                          icon: Icons.grid_view_rounded,
                          label: st,
                          th: th,
                          cor: cor),
                      _Chip(
                          icon: Icons.calendar_today_rounded,
                          label: cd,
                          th: th,
                          cor: cor),
                      if (mes.isNotEmpty)
                        _Chip(
                            icon: Icons.event_note_rounded,
                            label: mes,
                            th: th,
                            cor: cor),
                      if (ini.isNotEmpty)
                        _Chip(
                            icon: Icons.play_arrow_rounded,
                            label: 'INÍCIO: $ini',
                            th: th,
                            cor: _emerald),
                      if (ter.isNotEmpty)
                        _Chip(
                            icon: Icons.flag_rounded,
                            label: 'TÉRMINO: $ter',
                            th: th,
                            cor: _blue),
                      if (peca.isNotEmpty)
                        _Chip(
                            icon: Icons.inventory_2_outlined,
                            label: 'PREV. PEÇAS: $peca',
                            th: th,
                            cor: _purple),
                    ]),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                      decoration: BoxDecoration(
                        color: cor.withOpacity(th.isDark ? .06 : .04),
                        borderRadius: BorderRadius.circular(10),
                        border: Border(left: BorderSide(color: cor, width: 3)),
                      ),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('DEFEITO RELATADO / SERVIÇO',
                                style: _ts(8,
                                    c: cor.withOpacity(.7), ls: 1.6, b: true)),
                            const SizedBox(height: 5),
                            Text(sv.isNotEmpty ? sv : 'Não informado',
                                style: _ts(14, c: th.ink2, h: 1.4)),
                          ]),
                    ),
                    if (previsaoPeca.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: _purple.withOpacity(.07),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: _purple.withOpacity(.25)),
                        ),
                        child: Row(children: [
                          const Icon(Icons.event_rounded,
                              size: 16, color: _purple),
                          const SizedBox(width: 8),
                          Text('Previsão de chegada: ',
                              style: _ts(11, c: _purple, b: true)),
                          Expanded(
                              child: Text(previsaoPeca,
                                  style: _ts(12, c: th.ink, b: true),
                                  overflow: TextOverflow.ellipsis)),
                        ]),
                      ),
                    ],
                    if (servReal.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: _emerald.withOpacity(.07),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: _emerald.withOpacity(.25)),
                        ),
                        child: Row(children: [
                          const Icon(Icons.check_circle_rounded,
                              size: 16, color: _emerald),
                          const SizedBox(width: 8),
                          Text('Serviço Executado: ',
                              style: _ts(11, c: _emerald, b: true)),
                          Expanded(
                              child: Text(servReal,
                                  style: _ts(12, c: th.ink),
                                  overflow: TextOverflow.ellipsis)),
                        ]),
                      ),
                    ],
                    if (desc.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                        decoration: BoxDecoration(
                          color: th.surf3,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: th.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              Icon(Icons.speaker_notes_rounded,
                                  size: 12, color: th.ink3),
                              const SizedBox(width: 4),
                              Text('OBSERVAÇÕES',
                                  style: _ts(9, c: th.ink3, ls: 1.2, b: true)),
                            ]),
                            const SizedBox(height: 6),
                            Text(desc, style: _ts(12, c: th.ink2, h: 1.4)),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Divider(height: 1, color: th.border),
                    const SizedBox(height: 12),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                              child: _TecsList(
                                  equipe: equipe, th: th, fotos: widget.fotos)),
                          const SizedBox(width: 12),
                          _ActionChip(
                              tipo: widget.tipo, onTap: widget.onAction),
                        ]),
                  ]),
            ),
          ]),
        ),
      ),
    );
  }
}

// ── Múltiplos Técnicos ────────────────────────────────────────
class _TecsList extends StatelessWidget {
  const _TecsList(
      {required this.equipe, required this.th, required this.fotos});
  final List<String> equipe;
  final _Th th;
  final Map<String, String> fotos;

  @override
  Widget build(BuildContext context) {
    if (equipe.isEmpty) return const SizedBox.shrink();
    if (equipe.length == 1) {
      return _TecAvatar(
          nome: equipe[0], fotoUrl: fotos[equipe[0].trim()], th: th);
    }
    return Row(
      children: [
        SizedBox(
          width: 32.0 + ((equipe.length - 1) * 20.0),
          height: 34,
          child: Stack(
            children: List.generate(equipe.length, (index) {
              return Positioned(
                left: index * 20.0,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: th.card, width: 2),
                  ),
                  child: _TecAvatar(
                      nome: equipe[index],
                      fotoUrl: fotos[equipe[index].trim()],
                      th: th,
                      size: 30,
                      showName: false),
                ),
              );
            }),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Equipe Técnica',
                  style: _ts(9, c: th.ink3, ls: 0.5, b: true)),
              Text('${equipe.length} Técnicos',
                  style: _ts(12, c: th.ink, b: true)),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Status pill pulsante ──────────────────────────────────────
class _StatusPill extends StatefulWidget {
  const _StatusPill(
      {required this.status, required this.cor, required this.th});
  final String status;
  final Color cor;
  final _Th th;
  @override
  State<_StatusPill> createState() => _StatusPillState();
}

class _StatusPillState extends State<_StatusPill>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _p;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400))
      ..repeat(reverse: true);
    _p = Tween<double>(begin: .35, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: widget.cor.withOpacity(widget.th.isDark ? .12 : .08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: widget.cor.withOpacity(.30)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          AnimatedBuilder(
              animation: _p,
              builder: (_, __) => Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.cor.withOpacity(_p.value),
                      boxShadow: [
                        BoxShadow(
                            color: widget.cor.withOpacity(.4), blurRadius: 4)
                      ],
                    ),
                  )),
          const SizedBox(width: 6),
          Text(widget.status, style: _ts(9, c: widget.cor, b: true, ls: .5)),
        ]),
      );
}

// ── Meta chip ─────────────────────────────────────────────────
class _Chip extends StatelessWidget {
  const _Chip(
      {required this.icon,
      required this.label,
      required this.th,
      required this.cor});
  final IconData icon;
  final String label;
  final _Th th;
  final Color cor;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          color: th.surf3,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: th.border),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 11, color: th.ink3),
          const SizedBox(width: 5),
          ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 100),
              child: Text(label,
                  style: _ts(11, c: th.ink2),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1)),
        ]),
      );
}

// ── Técnico avatar ────────────────────────────────────────────
class _TecAvatar extends StatelessWidget {
  const _TecAvatar(
      {required this.nome,
      this.fotoUrl,
      required this.th,
      this.size = 34,
      this.showName = true});
  final String nome;
  final String? fotoUrl;
  final _Th th;
  final double size;
  final bool showName;

  String get _ini => nome
      .split(' ')
      .take(2)
      .map((w) => w.isNotEmpty ? w[0] : '')
      .join()
      .toUpperCase();

  @override
  Widget build(BuildContext context) {
    final String? foto = _fotoValida(fotoUrl) ? fotoUrl! : null;
    return Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: foto == null
                ? const LinearGradient(
                    colors: [_violet, _cyan],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight)
                : null,
            border: Border.all(color: _cyan.withOpacity(.30), width: 1.5),
            boxShadow: [
              BoxShadow(color: _violet.withOpacity(.20), blurRadius: 6)
            ],
          ),
          child: ClipOval(
              child: foto != null
                  ? Image.network(foto,
                      width: size,
                      height: size,
                      fit: BoxFit.cover,
                      webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
                      errorBuilder: (_, __, ___) => _IniBox(ini: _ini))
                  : _IniBox(ini: _ini)),
        ),
        if (showName) ...[
          const SizedBox(width: 9),
          Flexible(
              child: Text(nome,
                  style: _ts(12, c: th.ink2),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1)),
        ]
      ]);
  }
}

class _IniBox extends StatelessWidget {
  const _IniBox({required this.ini});
  final String ini;
  @override
  Widget build(BuildContext context) => Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
              colors: [_violet, _cyan],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight),
        ),
        child:
            Center(child: Text(ini, style: _ts(11, c: Colors.white, b: true))),
      );
}

// ── Botão de ação do card ─────────────────────────────────────
class _ActionChip extends StatefulWidget {
  const _ActionChip({required this.tipo, required this.onTap});
  final OsBtnT tipo;
  final VoidCallback onTap;
  @override
  State<_ActionChip> createState() => _ActionChipState();
}

class _ActionChipState extends State<_ActionChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 100),
        lowerBound: .93,
        upperBound: 1.0,
        value: 1.0);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final (label, g, icon) = switch (widget.tipo) {
      OsBtnT.atender => (
          'Atender O.S',
          const LinearGradient(colors: [Color(0xFF059669), _emerald]),
          Icons.handyman_rounded
        ),
      OsBtnT.editar => (
          'Editar O.S',
          const LinearGradient(colors: [_violet, Color(0xFF9333EA)]),
          Icons.edit_rounded
        ),
      OsBtnT.orcamento => (
          'Enviar Orçamento',
          const LinearGradient(colors: [Color(0xFFD97706), _amber]),
          Icons.receipt_long_rounded
        ),
    };
    return GestureDetector(
      onTapDown: (_) => _ctrl.reverse(),
      onTapUp: (_) {
        _ctrl.forward();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.forward(),
      child: ScaleTransition(
        scale: _ctrl,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            gradient: g,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: (widget.tipo == OsBtnT.atender ? _emerald : _violet)
                    .withOpacity(.28),
                blurRadius: 8,
                offset: const Offset(0, 3),
              )
            ],
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, size: 14, color: Colors.white),
            const SizedBox(width: 6),
            Text(label, style: _ts(12, c: Colors.white, b: true)),
          ]),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  MODAL DE EDIÇÃO
// ═══════════════════════════════════════════════════════════════
class OsEditPage extends StatefulWidget {
  const OsEditPage({
    required this.os,
    required this.db,
    required this.onSaved,
    this.embedded = false,
  });
  final Map<String, dynamic> os;
  final FirebaseFirestore db;
  final VoidCallback onSaved;
  final bool embedded;
  @override
  State<OsEditPage> createState() => OsEditPageState();
}

class OsEditPageState extends State<OsEditPage> {
  late TextEditingController _cPat,
      _cSala,
      _cSetor,
      _cNos,
      _cCli,
      _cDefeito,
      _cServico,
      _cDesc,
      _cIni,
      _cTer,
      _cPeca,
      _cGas;

  String? _equip, _tec, _tec2, _tec3, _tec4;
  String? _status, _mes, _servReal, _qtdTec;

  bool _usouGas = false;

  List<String> _equips = [];
  List<String> _tecs = [];
  Map<String, String> _tFotos = {};
  List<Map<String, dynamic>> _servPts = [];
  double _ptServ = 0.0;
  bool _saving = false, _loading = true;
  bool _tentou = false;
  final Set<String> _erros = {};

  int get _totalT => (_qtdOpts.indexOf(_qtdTec ?? '') + 1).clamp(1, 10);
  int get _nextra => (_qtdOpts.indexOf(_qtdTec ?? '')).clamp(0, 9);
  double get _ptCalc => _ptServ > 0 ? _ptServ / _totalT : 0.0;

  List<String> get _allTecs => [
        if (_tec != null && _tec!.isNotEmpty) _tec!,
        if (_tec2 != null && _tec2!.isNotEmpty) _tec2!,
        if (_tec3 != null && _tec3!.isNotEmpty) _tec3!,
        if (_tec4 != null && _tec4!.isNotEmpty) _tec4!,
      ];

  String _v(dynamic v) => (v ?? '').toString();
  String? _nv(dynamic v) {
    final s = _v(v).trim();
    return s.isEmpty ? null : s;
  }

  String _parseList(dynamic val) {
    if (val is List) return val.join(', ');
    return (val ?? '').toString().trim();
  }

  String _hoje() => DateFormat('d/M/y').format(DateTime.now());

  String get _titulo {
    final s = _v(widget.os['STATUS']);
    final t = _v(widget.os['TECNICORESPONSAVEL']);
    if (s == 'PASSAR ORÇAMENTO') return 'Enviar Orçamento';
    if (t.isEmpty || t == 'NÃO DEFINIDO') return 'Atender O.S';
    return 'Editar O.S';
  }

  @override
  void initState() {
    super.initState();
    final o = widget.os;
    _cPat = TextEditingController(text: _v(o['PATRIMONIO']));
    _cSala = TextEditingController(text: _v(o['SALA']));
    _cSetor = TextEditingController(text: _v(o['SETOR']));
    _cNos = TextEditingController(text: _v(o['NUMERODAOS']));
    _cCli = TextEditingController(text: _v(o['CLIENTE']));
    _cDefeito = TextEditingController(
        text:
            _v(o['DEFEITO']).isNotEmpty ? _v(o['DEFEITO']) : _v(o['SERVICO']));
    _cServico = TextEditingController(text: _v(o['SERVICO']));
    _cDesc = TextEditingController(text: _v(o['DESCRICAO']));
    _cGas = TextEditingController();
    final ini = _v(o['INICIO']);
    _cIni = TextEditingController(text: ini.isNotEmpty ? ini : _hoje());
    final ter = _v(o['TERMINO']);
    _cTer = TextEditingController(text: ter.isNotEmpty ? ter : _hoje());
    final pecaExistente =
        _v(o['PREVISAODAPECA']).isNotEmpty ? _v(o['PREVISAODAPECA']) : _hoje();
    _cPeca = TextEditingController(text: pecaExistente);
    _equip = _nv(o['EQUIPAMENTO']);
    _tec = _nv(o['TECNICORESPONSAVEL']);
    _tec2 = _nv(o['TECNICO2']);
    _tec3 = _nv(o['TECNICO3']);
    _tec4 = _nv(o['TECNICO4']);
    _status = _nv(o['STATUS']);
    _mes = _nv(o['MES']);
    _servReal = _nv(o['SERVICOREALIZADO']);
    _load();
  }

  Future<void> _load() async {
    try {
      final rs = await Future.wait([
        widget.db.collection('EQUIPAMENTOSCADASTRO').get(),
        widget.db.collection('PONTOS_POR_TECNICO').orderBy('TECNICO').get(),
        widget.db.collection('SERVICOSEPONTOS').orderBy('SERVICOS').get(),
      ]);
      final eqs = <String>[], tcs = <String>[];
      final fts = <String, String>{};
      final svs = <Map<String, dynamic>>[];

      for (final d in rs[0].docs) {
        final n = (d.data()['EQUIPAMENTOS'] ?? '').toString().trim();
        if (n.isNotEmpty) eqs.add(n);
      }
      for (final d in rs[1].docs) {
        final nm = (d.data()['TECNICO'] ?? '').toString().trim();
        final ft = (d.data()['FOTO'] ?? '').toString().trim();
        if (nm.isNotEmpty) {
          tcs.add(nm);
          if (_fotoValida(ft)) fts[nm] = ft;
        }
      }
      for (final d in rs[2].docs) {
        final nm = (d.data()['SERVICOS'] ?? '').toString();
        if (nm.isNotEmpty)
          svs.add({'nome': nm, 'pontos': _toD(d.data()['PONTOS'])});
      }
      double ptIni = 0.0;
      if (_servReal != null) {
        final m = svs.firstWhere((s) => s['nome'] == _servReal,
            orElse: () => {'pontos': 0.0});
        ptIni = _toD(m['pontos']);
      }
      setState(() {
        _equips = eqs;
        _tecs = tcs;
        _tFotos = fts;
        _servPts = svs;
        _ptServ = ptIni;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  bool _validar() {
    final e = <String>{};
    if (_status == 'CONCLUÍDA') {
      if (_equip == null || _equip!.isEmpty) e.add('equip');
      if (_tec == null || _tec!.isEmpty) e.add('tec');
      if (_cDefeito.text.trim().isEmpty) e.add('defeito');
      if (_servReal == null || _servReal!.isEmpty) e.add('servReal');
      if (_qtdTec == null || _qtdTec!.isEmpty) e.add('qtdTec');
      if (_cIni.text.trim().isEmpty) e.add('inicio');
      if (_cTer.text.trim().isEmpty) e.add('termino');
    }
    if (_status == 'INICIOU O SERVIÇO') {
      if (_cIni.text.trim().isEmpty) e.add('inicio');
    }
    setState(() {
      _tentou = true;
      _erros
        ..clear()
        ..addAll(e);
    });
    return e.isEmpty;
  }

  Map<String, String> _infoNotificacao(String status, String numeroos) {
    switch (status) {
      case 'INICIAR AVALIAÇÃO':
        return {
          'titulo': '🔍 Avaliação Iniciada',
          'mensagem':
              'Iniciamos a avaliação do seu equipamento na O.S #$numeroos. Em breve traremos novidades!',
        };
      case 'INICIOU O SERVIÇO':
        return {
          'titulo': '🔧 Avaliação Iniciada',
          'mensagem':
              'A avaliação do seu equipamento foi iniciada na O.S #$numeroos. Em breve traremos novidades!',
        };
      case 'PASSAR ORÇAMENTO':
        return {
          'titulo': '📋 Elaborando Orçamento',
          'mensagem':
              'Concluímos a avaliação da O.S #$numeroos e estamos elaborando o orçamento. Aguarde!',
        };
      case 'AGUARDANDO PEÇA':
        return {
          'titulo': '📦 Aguardando Peça',
          'mensagem':
              'Estamos aguardando a chegada da peça para concluir o reparo da O.S #$numeroos.',
        };
      case 'AGUARDANDO APROVAÇÃO':
        return {
          'titulo': '✅ Orçamento Disponível',
          'mensagem':
              'O orçamento da O.S #$numeroos já está disponível. Abra o app HPS Refrigeração ou acesse www.hpsrefri.com.br para aprovar.',
        };
      case 'APROVADO':
        return {
          'titulo': '👍 Orçamento Aprovado',
          'mensagem':
              'Orçamento da O.S #$numeroos aprovado! Vamos iniciar o serviço em breve.',
        };
      case 'CONCLUÍDA':
        return {
          'titulo': '🎉 Serviço Concluído',
          'mensagem':
              'Sua O.S #$numeroos foi concluída com sucesso! Obrigado pela confiança.',
        };
      case 'CANCELADA':
        return {
          'titulo': '❌ O.S Cancelada',
          'mensagem':
              'A O.S #$numeroos foi cancelada. Entre em contato para mais informações.',
        };
      default:
        return {
          'titulo': 'Atualização da O.S #$numeroos',
          'mensagem': 'Sua O.S #$numeroos teve uma atualização de status.',
        };
    }
  }

  static const _osAppId = '7b01186f-cf76-4b5d-8354-87d83737d40c';
  static const _osApiKey =
      'Basic ZTdlNjIwZWItMjEyMC00M2RhLWJlZmYtMzc2NTBmNzNmMDdj';
  static const _osChannelId = '577bba44-d1bf-4ac9-9d11-20d89e09a61a';

  Future<void> _pushNotificacao({
    required String email,
    required String titulo,
    required String mensagem,
    required String status,
    required String numeroos,
  }) async {
    if (email.isEmpty) return;

    try {
      await widget.db.collection('NOTIFICACAO').add({
        'email': email,
        'visto': false,
        'titulo': titulo,
        'mensagem': mensagem,
        'status': status,
        'os': numeroos,
        'mes': _mes ?? '',
        'ano': DateTime.now().year,
        'tipo': 'corretivas',
        'data': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Firebase notif error: $e');
    }

    try {
      await http.post(
        Uri.parse('https://onesignal.com/api/v1/notifications'),
        headers: {
          'Authorization': _osApiKey,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'app_id': _osAppId,
          'filters': [
            {'field': 'tag', 'key': 'Email', 'relation': '=', 'value': email}
          ],
          'headings': {'en': titulo},
          'contents': {'en': mensagem},
          'android_channel_id': _osChannelId,
          'priority': 10,
        }),
      );
    } catch (e) {
      debugPrint('OneSignal push error: $e');
    }
  }

  Future<List<String>> _mostrarDialogoConfirmarEmail({
    required String email,
    required String status,
    required String numeroos,
  }) async {
    if (email.isEmpty) return [];

    List<String> emailsAdicionais = [];
    try {
      final snap = await widget.db
          .collection('USUARIOS')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
      if (snap.docs.isNotEmpty) {
        final field = snap.docs.first.data()['emailteste'];
        if (field is List) {
          for (final e in field) {
            final s = (e ?? '').toString().trim();
            if (s.isNotEmpty) emailsAdicionais.add(s);
          }
        } else if (field is String && field.trim().isNotEmpty) {
          emailsAdicionais.add(field.trim());
        }
      }
    } catch (_) {}

    final Map<String, Map<String, String>> _info = {
      'INICIAR AVALIAÇÃO': {'emoji': '🔍', 'resumo': 'Avaliação iniciada'},
      'INICIOU O SERVIÇO': {'emoji': '🔧', 'resumo': 'Avaliação iniciada'},
      'PASSAR ORÇAMENTO': {'emoji': '📋', 'resumo': 'Elaborando orçamento'},
      'CANCELADA': {'emoji': '❌', 'resumo': 'O.S cancelada'},
      'AGUARDANDO PEÇA': {'emoji': '📦', 'resumo': 'Aguardando peça'},
      'AGUARDANDO APROVAÇÃO': {'emoji': '✅', 'resumo': 'Orçamento disponível'},
      'APROVADO': {'emoji': '👍', 'resumo': 'Orçamento aprovado'},
      'CONCLUÍDA': {'emoji': '🎉', 'resumo': 'Serviço concluído'},
    };
    final info = _info[status] ?? {'emoji': '📌', 'resumo': status};
    final cor = _sColor(status);

    List<String> selecionados = [email];

    if (!mounted) return [];

    final result = await showDialog<List<String>>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(.6),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) {
          final th = _Th(Theme.of(ctx).brightness == Brightness.dark);

          Widget emailTile({
            required String mail,
            required String badge,
            required Color badgeColor,
          }) {
            final sel = selecionados.contains(mail);
            return GestureDetector(
              onTap: () => setS(() {
                if (sel)
                  selecionados.remove(mail);
                else
                  selecionados.add(mail);
              }),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                margin: const EdgeInsets.only(bottom: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color:
                      sel ? cor.withOpacity(th.isDark ? .10 : .06) : th.surf2,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: sel ? cor.withOpacity(.45) : th.border,
                    width: sel ? 1.5 : 1,
                  ),
                ),
                child: Row(children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: sel ? cor : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: sel
                            ? cor
                            : (th.isDark ? Colors.white24 : Colors.black26),
                        width: 2,
                      ),
                    ),
                    child: sel
                        ? const Icon(Icons.check_rounded,
                            color: Colors.white, size: 13)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      mail,
                      style: _ts(13, c: sel ? th.ink : th.ink2, b: sel),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: badgeColor.withOpacity(.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(badge, style: _ts(10, c: badgeColor, b: true)),
                  ),
                ]),
              ),
            );
          }

          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
            child: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(ctx).size.height * .85,
              ),
              decoration: BoxDecoration(
                color: th.surf,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(.35),
                      blurRadius: 32,
                      offset: const Offset(0, 8)),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(20, 20, 16, 18),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          cor.withOpacity(th.isDark ? .25 : .12),
                          cor.withOpacity(th.isDark ? .08 : .04),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(24)),
                      border: Border(
                          bottom: BorderSide(color: cor.withOpacity(.18))),
                    ),
                    child: Row(children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: cor.withOpacity(.15),
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: cor.withOpacity(.35), width: 1.5),
                        ),
                        child: Center(
                          child: Text(info['emoji']!,
                              style: const TextStyle(fontSize: 22)),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Notificar por E-mail',
                                style: _ts(16, c: th.ink, b: true)),
                            const SizedBox(height: 3),
                            Text(
                              '${info['resumo']} — O.S #$numeroos',
                              style: _ts(12, c: th.ink2),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.of(ctx).pop(<String>[]),
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: th.surf3,
                            shape: BoxShape.circle,
                            border: Border.all(color: th.border),
                          ),
                          child: Icon(Icons.close_rounded,
                              size: 16, color: th.ink3),
                        ),
                      ),
                    ]),
                  ),
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: cor.withOpacity(th.isDark ? .08 : .05),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: cor.withOpacity(.22)),
                            ),
                            child: Row(children: [
                              Container(
                                  width: 7,
                                  height: 7,
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle, color: cor)),
                              const SizedBox(width: 9),
                              Text(status,
                                  style: _ts(11, c: cor, b: true, ls: .5)),
                            ]),
                          ),
                          const SizedBox(height: 18),
                          Row(children: [
                            Icon(Icons.people_outline_rounded,
                                size: 14, color: th.ink3),
                            const SizedBox(width: 7),
                            Text('DESTINATÁRIOS',
                                style: _ts(10, c: th.ink3, b: true, ls: 1.2)),
                            const SizedBox(width: 8),
                            if (selecionados.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: cor,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                    '${selecionados.length} selecionado${selecionados.length > 1 ? 's' : ''}',
                                    style: _ts(10, c: Colors.white, b: true)),
                              ),
                          ]),
                          const SizedBox(height: 10),
                          emailTile(
                            mail: email,
                            badge: 'Principal',
                            badgeColor: _emerald,
                          ),
                          ...emailsAdicionais.map((mail) => emailTile(
                                mail: mail,
                                badge: 'Adicional',
                                badgeColor: _violet,
                              )),
                          if (emailsAdicionais.isEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: th.surf3,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: th.border),
                              ),
                              child: Row(children: [
                                Icon(Icons.info_outline_rounded,
                                    size: 13, color: th.ink3),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Nenhum e-mail adicional cadastrado para este cliente.',
                                    style: _ts(12, c: th.ink3, h: 1.4),
                                  ),
                                ),
                              ]),
                            ),
                          const SizedBox(height: 18),
                          Row(children: [
                            Icon(Icons.info_outline_rounded,
                                size: 12, color: th.ink3),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'O e-mail será enviado via Brevo com o status atualizado da O.S.',
                                style: _ts(11, c: th.ink3, h: 1.5),
                              ),
                            ),
                          ]),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
                    decoration: BoxDecoration(
                      color: th.surf3,
                      borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(24)),
                      border: Border(top: BorderSide(color: th.border)),
                    ),
                    child: Column(children: [
                      GestureDetector(
                        onTap: selecionados.isEmpty
                            ? null
                            : () => Navigator.of(ctx)
                                .pop(List<String>.from(selecionados)),
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 160),
                          opacity: selecionados.isEmpty ? .4 : 1.0,
                          child: Container(
                            width: double.infinity,
                            height: 52,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  colors: [cor, cor.withOpacity(.7)]),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: selecionados.isEmpty
                                  ? null
                                  : [
                                      BoxShadow(
                                          color: cor.withOpacity(.28),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4))
                                    ],
                            ),
                            child: Center(
                              child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.send_rounded,
                                        color: Colors.white, size: 16),
                                    const SizedBox(width: 8),
                                    Text(
                                      selecionados.isEmpty
                                          ? 'Selecione ao menos 1 e-mail'
                                          : 'ENVIAR PARA ${selecionados.length} E-MAIL${selecionados.length > 1 ? 'S' : ''}',
                                      style: _ts(13, c: Colors.white, b: true),
                                    ),
                                  ]),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: () => Navigator.of(ctx).pop(<String>[]),
                        child: Container(
                          width: double.infinity,
                          height: 48,
                          decoration: BoxDecoration(
                            color: th.surf,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: th.border2),
                          ),
                          child: Center(
                            child:
                                Row(mainAxisSize: MainAxisSize.min, children: [
                              Icon(Icons.save_alt_rounded,
                                  color: th.ink2, size: 15),
                              const SizedBox(width: 8),
                              Text('SALVAR SEM ENVIAR E-MAIL',
                                  style: _ts(13, c: th.ink2, b: true)),
                            ]),
                          ),
                        ),
                      ),
                    ]),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
    return result ?? [];
  }

  void _mostrarDialogGas(_Th th) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: th.surf2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _cyan.withOpacity(.10),
                    border:
                        Border.all(color: _cyan.withOpacity(.35), width: 1.5),
                  ),
                  child: const Icon(Icons.propane_tank_rounded,
                      color: _cyan, size: 30),
                ),
                const SizedBox(height: 18),
                Text('Gás utilizado?',
                    style: _ts(18, c: th.ink, b: true),
                    textAlign: TextAlign.center),
                const SizedBox(height: 8),
                Text(
                  'Foi necessário utilizar gás\nneste serviço?',
                  style: _ts(14, c: th.ink2, h: 1.5),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _usouGas = false;
                          _cGas.clear();
                        });
                        Navigator.pop(ctx);
                      },
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: th.surf3,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: th.border),
                        ),
                        child: Center(
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            Icon(Icons.close_rounded, size: 16, color: th.ink3),
                            const SizedBox(width: 6),
                            Text('NÃO', style: _ts(14, c: th.ink3, b: true)),
                          ]),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(ctx);
                        Future.delayed(const Duration(milliseconds: 150), () {
                          if (mounted) {
                            _mostrarDialogQtdGas(_Th(
                                Theme.of(context).brightness ==
                                    Brightness.dark));
                          }
                        });
                      },
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                              colors: [_cyan, Color(0xFF0099BB)]),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                                color: _cyan.withOpacity(.28),
                                blurRadius: 8,
                                offset: const Offset(0, 3))
                          ],
                        ),
                        child: Center(
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            const Icon(Icons.check_rounded,
                                size: 16, color: Colors.white),
                            const SizedBox(width: 6),
                            Text('SIM',
                                style: _ts(14, c: Colors.white, b: true)),
                          ]),
                        ),
                      ),
                    ),
                  ),
                ]),
              ]),
            ),
            Positioned(
              top: 12,
              right: 12,
              child: GestureDetector(
                onTap: () => Navigator.pop(ctx),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: th.surf,
                    shape: BoxShape.circle,
                    border: Border.all(color: th.border),
                  ),
                  child: Icon(Icons.close_rounded, size: 16, color: th.ink3),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarDialogQtdGas(_Th th) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: th.surf2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _amber.withOpacity(.10),
                    border:
                        Border.all(color: _amber.withOpacity(.35), width: 1.5),
                  ),
                  child: const Icon(Icons.propane_rounded,
                      color: _amber, size: 30),
                ),
                const SizedBox(height: 18),
                Text('Quantidade de gás',
                    style: _ts(18, c: th.ink, b: true),
                    textAlign: TextAlign.center),
                const SizedBox(height: 8),
                Text(
                  'Informe a quantidade de gás\nutilizada no serviço:',
                  style: _ts(14, c: th.ink2, h: 1.5),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                _Field(
                  th: th,
                  ctrl: _cGas,
                  label: 'Quantidade de gás',
                  hint: 'Ex: 1.5',
                  type: const TextInputType.numberWithOptions(decimal: true),
                  accent: _amber,
                  uppercase: false,
                ),
                const SizedBox(height: 4),
                SizedBox(
                  width: double.infinity,
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _usouGas = true);
                      Navigator.pop(ctx);
                    },
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                            colors: [_amber, Color(0xFFD97706)]),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                              color: _amber.withOpacity(.28),
                              blurRadius: 8,
                              offset: const Offset(0, 3))
                        ],
                      ),
                      child: Center(
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          const Icon(Icons.check_circle_rounded,
                              size: 16, color: Colors.white),
                          const SizedBox(width: 6),
                          Text('CONFIRMAR',
                              style: _ts(14, c: Colors.white, b: true)),
                        ]),
                      ),
                    ),
                  ),
                ),
              ]),
            ),
            Positioned(
              top: 12,
              right: 12,
              child: GestureDetector(
                onTap: () => Navigator.pop(ctx),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: th.surf,
                    shape: BoxShape.circle,
                    border: Border.all(color: th.border),
                  ),
                  child: Icon(Icons.close_rounded, size: 16, color: th.ink3),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _salvar() async {
    if (!_validar()) return;
    final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => _ConfirmDialog(numeroOs: _cNos.text));
    if (ok != true) return;
    setState(() => _saving = true);

    final pts = _ptCalc;
    final numeroos = _cNos.text;
    final email = _v(widget.os['EMAIL']);
    final status = _status ?? '';
    final cliente = _cCli.text.trim();
    final equipamento = _equip ?? _v(widget.os['EQUIPAMENTO']);
    final sala = _cSala.text.trim();
    final setor = _cSetor.text.trim();
    final patrimonio = _cPat.text.trim().isNotEmpty
        ? _cPat.text.trim()
        : _v(widget.os['PATRIMONIO']);

    final info = _infoNotificacao(status, numeroos);
    final titulo = info['titulo']!;
    final mensagem = info['mensagem']!;

    try {
      final refServicos =
          widget.db.collection('SERVICOSREALIZADOS').doc(widget.os['_id']);
      final listaPecas = _cPeca.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
      final previsaoPecaTexto = _cPeca.text.trim();

      final manSnap = await widget.db
          .collection('MANUTENCAO')
          .where('NUMERO_OS', isEqualTo: numeroos)
          .limit(1)
          .get();
      final manData = manSnap.docs.isNotEmpty
          ? manSnap.docs.first.data()
          : <String, dynamic>{};
      final refManutencao =
          manSnap.docs.isNotEmpty ? manSnap.docs.first.reference : null;

      String mv(String k) => (manData[k] ?? '').toString();
      final valorFinal = manData['VALOR'] ?? widget.os['VALOR'] ?? [];

      final String servicoRelatado =
          _cServico.text.isNotEmpty ? _cServico.text : _cDefeito.text;
      final String tecnicoResponsavel = _tec ?? '';
      final String servicoExecutado = _servReal ?? '';
      final String dataInicio = _cIni.text;
      final String dataTermino = _cTer.text;

      final Map<String, dynamic> dadosIguais = {
        'STATUS': status,
        'TECNICORESPONSAVEL': tecnicoResponsavel,
        'TECNICO': tecnicoResponsavel,
        'DEFEITO': _cDefeito.text,
        'SERVICOREALIZADO': servicoExecutado,
        'INICIO': dataInicio,
        'DATA_ATUALIZACAO': FieldValue.serverTimestamp(),
      };

      unawaited(_pushNotificacao(
        email: email,
        titulo: titulo,
        mensagem: mensagem,
        status: status,
        numeroos: numeroos,
      ));

      if (mounted && email.isNotEmpty) {
        setState(() => _saving = false);
        final emailsSelecionados = await _mostrarDialogoConfirmarEmail(
          email: email,
          status: status,
          numeroos: numeroos,
        );
        setState(() => _saving = true);
        for (final dest in emailsSelecionados) {
          unawaited(_sendEmailPorStatus(
            toEmail: dest,
            status: status,
            numeroos: numeroos,
            cliente: cliente,
            equipamento: equipamento,
            sala: sala,
            setor: setor,
            patrimonio: patrimonio,
          ));
        }
      }

      if (_status == 'CONCLUÍDA') {
        final updateServicos = Map<String, dynamic>.from(widget.os);
        updateServicos.remove('_id');
        updateServicos.addAll(dadosIguais);
        updateServicos.addAll({
          'SERVICO': servicoRelatado,
          'EQUIPAMENTO': _equip ?? '',
          'NUMERODAOS': numeroos,
          'TERMINO': dataTermino,
          'CLIENTE': cliente,
          'TECNICO2': _tec2 ?? '',
          'TECNICO3': _tec3 ?? '',
          'TECNICO4': _tec4 ?? '',
          'PONTOS': pts,
          'DESCRICAO': _cDesc.text,
          'SETOR': setor,
          'SALA': sala,
          'PATRIMONIO':
              _cPat.text.isNotEmpty ? _cPat.text : _v(widget.os['PATRIMONIO']),
          'PECAS': listaPecas,
          'PREVISAODAPECA': previsaoPecaTexto,
          'VALOR': valorFinal,
        });

        if (_usouGas && _cGas.text.trim().isNotEmpty) {
          updateServicos['QUANTIDADEGAS'] = _cGas.text.trim();
        }
        await refServicos.update(updateServicos);

        if (refManutencao != null) {
          final updateManutencao = Map<String, dynamic>.from(dadosIguais);
          updateManutencao.addAll({
            'DESCRICAODOSERVICO': _cDesc.text,
            'DATA_TERMINO': dataTermino,
            'PECAS': listaPecas,
            'PREVISAODAPECA': previsaoPecaTexto,
          });
          await refManutencao.update(updateManutencao);
        }

        try {
          await widget.db.collection('CORRETIVAS').add({
            'ANO': mv('ANO').isNotEmpty ? mv('ANO') : _v(widget.os['ANO']),
            'BTUS': mv('BTUS').isNotEmpty ? mv('BTUS') : _v(widget.os['BTUS']),
            'DATADAMANUTENCAO': dataInicio,
            'INICIO': dataInicio,
            'DATA_TERMINO': dataTermino,
            'DEFEITO': _cDefeito.text,
            'DESCRICAODOSERVICO': _cDesc.text,
            'EMAIL': email,
            'EQUIPAMENTO': _v(widget.os['EQUIPAMENTO']),
            'FLUIDO': mv('FLUIDO').isNotEmpty
                ? mv('FLUIDO')
                : _v(widget.os['FLUIDO']),
            'MARCA':
                mv('MARCA').isNotEmpty ? mv('MARCA') : _v(widget.os['MARCA']),
            'MES': _v(widget.os['MES']),
            'MODELO': mv('MODELO').isNotEmpty
                ? mv('MODELO')
                : _v(widget.os['MODELO']),
            'NOME': mv('NOME').isNotEmpty ? mv('NOME') : _v(widget.os['NOME']),
            'PECAS': listaPecas,
            'PREVISAODAPECA': previsaoPecaTexto,
            'QUANTIDADE': int.tryParse((_qtdTec ?? '1').split(' ').first) ?? 1,
            if (_usouGas && _cGas.text.trim().isNotEmpty)
              'QUANTIDADEGAS': _cGas.text.trim(),
            'RESPONSAVEL': mv('RESPONSAVEL').isNotEmpty
                ? mv('RESPONSAVEL')
                : _v(widget.os['RESPONSAVEL']),
            'SALA': mv('SALA').isNotEmpty ? mv('SALA') : sala,
            'SERVICOREALIZADO': servicoExecutado,
            'SETOR': mv('SETOR').isNotEmpty ? mv('SETOR') : setor,
            'STATUS': status,
            'TECNICORESPONSAVEL': tecnicoResponsavel,
            'TIPO': mv('TIPO').isNotEmpty ? mv('TIPO') : _v(widget.os['TIPO']),
            'VALOR': valorFinal,
            'NUMERO_OS': numeroos,
            'CLIENTE': cliente,
            'PATRIMONIO': _cPat.text.isNotEmpty
                ? _cPat.text
                : _v(widget.os['PATRIMONIO']),
          });
        } catch (errCorretiva) {
          debugPrint('Erro ao criar corretiva: $errCorretiva');
        }

        for (final tecExtra in [_tec2, _tec3, _tec4]) {
          if (tecExtra != null && tecExtra.isNotEmpty) {
            final copiaExtra = Map<String, dynamic>.from(updateServicos);
            copiaExtra['TECNICORESPONSAVEL'] = tecExtra;
            copiaExtra['TECNICO'] = tecExtra;
            unawaited(
                widget.db.collection('SERVICOSREALIZADOS').add(copiaExtra));
          }
        }

        if (!mounted) return;
        widget.onSaved();
        Navigator.of(context).pushReplacement(PageRouteBuilder(
          pageBuilder: (_, a1, a2) => OsPontosPage(
            db: widget.db,
            pontosadd: pts,
            tec1: _tec ?? '',
            tec2: _tec2 ?? '',
            tec3: _tec3 ?? '',
            tec4: _tec4 ?? '',
          ),
          transitionsBuilder: (_, a, __, child) =>
              FadeTransition(opacity: a, child: child),
          transitionDuration: const Duration(milliseconds: 300),
        ));
      } else if (_status == 'CANCELADA') {
        final updateServicos = Map<String, dynamic>.from(dadosIguais);
        updateServicos.addAll({
          'SERVICO': servicoRelatado,
          'EQUIPAMENTO': _equip ?? '',
          'NUMERODAOS': numeroos,
          'CLIENTE': cliente,
          'MES': widget.os['MES'] ?? '',
          'DESCRICAO': _cDesc.text,
        });
        await refServicos.update(updateServicos);

        if (refManutencao != null) {
          final updateManutencao = Map<String, dynamic>.from(dadosIguais);
          updateManutencao.addAll({'DESCRICAODOSERVICO': _cDesc.text});
          await refManutencao.update(updateManutencao);
        }

        if (!mounted) return;
        Navigator.pop(context);
        widget.onSaved();
        _snack(context, '✅  O.S cancelada.');
      } else {
        final updateServicos = Map<String, dynamic>.from(dadosIguais);
        updateServicos.addAll({
          'SERVICO': servicoRelatado,
          'EQUIPAMENTO': _equip ?? '',
          'NUMERODAOS': numeroos,
          'TERMINO': '',
          'CLIENTE': cliente,
          'MES': widget.os['MES'] ?? '',
          'DESCRICAO': _cDesc.text,
          'PECAS': listaPecas,
          'PREVISAODAPECA': previsaoPecaTexto,
          'SETOR': setor,
          'SALA': sala,
        });

        if (status != 'INICIOU O SERVIÇO') {
          updateServicos.remove('INICIO');
          dadosIguais.remove('INICIO');
        }

        await refServicos.update(updateServicos);

        if (refManutencao != null) {
          final updateManutencao = Map<String, dynamic>.from(dadosIguais);
          updateManutencao.addAll({
            'DESCRICAODOSERVICO': _cDesc.text,
            'PECAS': listaPecas,
            'PREVISAODAPECA': previsaoPecaTexto,
          });
          await refManutencao.update(updateManutencao);
        }

        if (!mounted) return;
        Navigator.pop(context);
        widget.onSaved();
        _snack(context, '✅  O.S atualizada com sucesso!');
      }
    } catch (e) {
      if (mounted) _snack(context, '❌  Erro: $e', err: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final th = _Th(Theme.of(context).brightness == Brightness.dark);
    final cor = _sColor(_v(widget.os['STATUS']));

    return Scaffold(
      backgroundColor: th.bg,
      appBar: AppBar(
        backgroundColor: th.surf,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: !widget.embedded,
        leading: widget.embedded
            ? null
            : IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: th.surf3,
                    border: Border.all(color: th.border),
                  ),
                  child: Icon(Icons.close_rounded, size: 18, color: th.ink2),
                ),
              ),
        title: Row(children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: LinearGradient(
                colors: [cor, cor.withOpacity(.6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                    color: cor.withOpacity(.30),
                    blurRadius: 8,
                    offset: const Offset(0, 2))
              ],
            ),
            child: Icon(_sIcon(_v(widget.os['STATUS'])),
                color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(_titulo, style: _ts(16, c: th.ink, b: true)),
            Row(children: [
              Container(
                  width: 5,
                  height: 5,
                  decoration:
                      BoxDecoration(shape: BoxShape.circle, color: cor)),
              const SizedBox(width: 5),
              Text('#${_v(widget.os["NUMERODAOS"])}',
                  style: _ts(11, c: th.ink3, ls: .4)),
            ]),
          ]),
        ]),
        actions: widget.embedded ? const [SizedBox(width: 44)] : null,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [cor.withOpacity(.5), cor.withOpacity(.05)],
                ),
              )),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: _loading
            ? Center(
                child: CircularProgressIndicator(color: cor, strokeWidth: 2.5))
            : _form(th, cor),
      ),
      bottomNavigationBar: _footer(th, cor),
    );
  }

  Widget _form(_Th th, Color cor) => SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _Bloco(
              title: 'INFORMAÇÕES DO EQUIPAMENTO',
              icon: Icons.devices_other_rounded,
              th: th,
              children: [
                Row(children: [
                  Expanded(
                      child: _F(th, _cPat, 'Patrimônio / N° Série',
                          type: TextInputType.number, uppercase: false)),
                  const SizedBox(width: 10),
                  Expanded(child: _F(th, _cSala, 'SALA')),
                ]),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(child: _F(th, _cSetor, 'SETOR')),
                  const SizedBox(width: 10),
                  Expanded(
                      child: _F(th, _cNos, 'N° da O.S',
                          type: TextInputType.number, uppercase: false)),
                ]),
                const SizedBox(height: 10),
                _F(th, _cCli, 'Cliente'),
                const SizedBox(height: 10),
                _D(
                    th,
                    'EQUIPAMENTO',
                    _equips.contains(_equip) ? _equip : null,
                    _equips,
                    (v) => setState(() {
                          _equip = v;
                          _erros.remove('equip');
                        }),
                    ek: 'equip'),
              ]),
          _Bloco(
              title: 'TÉCNICO RESPONSÁVEL',
              icon: Icons.engineering_rounded,
              th: th,
              children: [
                _D(
                    th,
                    'TÉCNICO',
                    _tecs.contains(_tec) ? _tec : null,
                    _tecs,
                    (v) => setState(() {
                          _tec = v;
                          _erros.remove('tec');
                        }),
                    search: true,
                    ek: 'tec'),
                if (_tec != null && _tec!.isNotEmpty)
                  Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 4),
                      child: _TecAvatar(
                          nome: _tec!,
                          fotoUrl: _tFotos[_tec!.trim()],
                          th: th,
                          size: 38)),
              ]),
          _Bloco(
              title: 'DEFEITO / MÊS',
              icon: Icons.report_problem_rounded,
              th: th,
              children: [
                _F(th, _cDefeito, 'Defeito Relatado',
                    ek: 'defeito',
                    onChange: () => setState(() => _erros.remove('defeito'))),
                const SizedBox(height: 10),
                _D(th, _mes ?? 'MÊS', _mes, List.from(_meses),
                    (v) => setState(() => _mes = v),
                    search: true),
              ]),
          if (_status == 'CONCLUÍDA')
            Container(
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                  color: _emerald.withOpacity(th.isDark ? 0.04 : 0.02),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _emerald, width: 2),
                  boxShadow: th.isDark
                      ? null
                      : [
                          BoxShadow(
                              color: _emerald.withOpacity(.08), blurRadius: 12)
                        ]),
              child: _Bloco(
                  title: '🚨 PREENCHIMENTO OBRIGATÓRIO (CONCLUSÃO)',
                  icon: Icons.verified_rounded,
                  th: th,
                  accent: _emerald,
                  highlight: true,
                  children: [
                    Row(children: [
                      Expanded(
                        child: _F(th, _cIni, 'DATA DE INÍCIO',
                            type: TextInputType.number,
                            mask: '##/##/####',
                            accent: _emerald,
                            ek: 'inicio',
                            uppercase: false,
                            onChange: () =>
                                setState(() => _erros.remove('inicio'))),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _F(th, _cTer, 'DATA DO TÉRMINO',
                            type: TextInputType.number,
                            mask: '##/##/####',
                            accent: _emerald,
                            ek: 'termino',
                            uppercase: false,
                            onChange: () =>
                                setState(() => _erros.remove('termino'))),
                      ),
                    ]),
                    const SizedBox(height: 10),
                    _D(
                        th,
                        'SELECIONE O SERVIÇO REALIZADO',
                        _servPts.any((s) => s['nome'] == _servReal)
                            ? _servReal
                            : null,
                        _servPts.map((s) => s['nome'].toString()).toList(),
                        (v) {
                      setState(() {
                        _servReal = v;
                        _erros.remove('servReal');
                        _usouGas = false;
                        _cGas.clear();
                        final m = _servPts.firstWhere((s) => s['nome'] == v,
                            orElse: () => {'pontos': 0.0});
                        _ptServ = _toD(m['pontos']);
                      });
                      if (v != null) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (mounted) {
                            _mostrarDialogGas(_Th(
                                Theme.of(context).brightness ==
                                    Brightness.dark));
                          }
                        });
                      }
                    }, search: true, ek: 'servReal'),
                    if (_usouGas) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _amber.withOpacity(.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _amber.withOpacity(.25)),
                        ),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: _amber.withOpacity(.12),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Icon(Icons.propane_rounded,
                                      size: 13, color: _amber),
                                ),
                                const SizedBox(width: 8),
                                Text('GÁS UTILIZADO',
                                    style:
                                        _ts(10, c: _amber, ls: 1.2, b: true)),
                              ]),
                              const SizedBox(height: 10),
                              _F(th, _cGas, 'QUANTIDADE DE GÁS',
                                  hint: 'Ex: 1.5',
                                  type: const TextInputType.numberWithOptions(
                                      decimal: true),
                                  accent: _amber,
                                  uppercase: false),
                            ]),
                      ),
                    ],
                    const SizedBox(height: 10),
                    _D(
                        th,
                        'QUANTOS TÉCNICOS REALIZARAM O SERVIÇO?',
                        _qtdTec,
                        List.from(_qtdOpts),
                        (v) => setState(() {
                              _qtdTec = v;
                              _erros.remove('qtdTec');
                            }),
                        ek: 'qtdTec'),
                    if (_nextra >= 1) ...[
                      const SizedBox(height: 10),
                      _D(th, 'TÉCNICO 2', _tecs.contains(_tec2) ? _tec2 : null,
                          _tecs, (v) => setState(() => _tec2 = v),
                          search: true),
                      if (_tec2 != null && _tec2!.isNotEmpty)
                        Padding(
                            padding: const EdgeInsets.only(top: 6, bottom: 4),
                            child: _TecAvatar(
                                nome: _tec2!,
                                fotoUrl: _tFotos[_tec2!.trim()],
                                th: th,
                                size: 34)),
                    ],
                    if (_nextra >= 2) ...[
                      _D(th, 'TÉCNICO 3', _tecs.contains(_tec3) ? _tec3 : null,
                          _tecs, (v) => setState(() => _tec3 = v),
                          search: true),
                      if (_tec3 != null && _tec3!.isNotEmpty)
                        Padding(
                            padding: const EdgeInsets.only(top: 6, bottom: 4),
                            child: _TecAvatar(
                                nome: _tec3!,
                                fotoUrl: _tFotos[_tec3!.trim()],
                                th: th,
                                size: 34)),
                    ],
                    if (_nextra >= 3) ...[
                      _D(th, 'TÉCNICO 4', _tecs.contains(_tec4) ? _tec4 : null,
                          _tecs, (v) => setState(() => _tec4 = v),
                          search: true),
                      if (_tec4 != null && _tec4!.isNotEmpty)
                        Padding(
                            padding: const EdgeInsets.only(top: 6, bottom: 4),
                            child: _TecAvatar(
                                nome: _tec4!,
                                fotoUrl: _tFotos[_tec4!.trim()],
                                th: th,
                                size: 34)),
                    ],
                    if (_servReal != null && _servReal!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _PontosCard(
                          ptTotal: _ptServ,
                          ptCalc: _ptCalc,
                          tecs: _allTecs,
                          fotos: _tFotos,
                          th: th),
                    ],
                  ]),
            ),
          _Bloco(
              title: 'STATUS DA O.S',
              icon: Icons.flag_rounded,
              th: th,
              children: [
                _D(th, _status ?? 'STATUS', _status, List.from(_sOpts),
                    (v) => setState(() => _status = v)),
                if (_status == 'INICIOU O SERVIÇO') ...[
                  const SizedBox(height: 10),
                  _F(th, _cIni, 'DATA DE INÍCIO DO SERVIÇO',
                      type: TextInputType.number,
                      mask: '##/##/####',
                      accent: _rose,
                      ek: 'inicio',
                      uppercase: false,
                      onChange: () => setState(() => _erros.remove('inicio'))),
                ],
                if (_status == 'AGUARDANDO PEÇA') ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _purple.withOpacity(.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _purple.withOpacity(.25)),
                    ),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: _purple.withOpacity(.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Icon(Icons.event_rounded,
                                  size: 13, color: _purple),
                            ),
                            const SizedBox(width: 8),
                            Text('PREVISÃO DE CHEGADA DA PEÇA',
                                style: _ts(10, c: _purple, ls: 1.2, b: true)),
                          ]),
                          const SizedBox(height: 10),
                          _F(th, _cPeca, 'DATA DE PREVISÃO',
                              hint: 'dd/mm/aaaa',
                              type: TextInputType.number,
                              mask: '##/##/####',
                              accent: _purple,
                              uppercase: false),
                        ]),
                  ),
                ],
              ]),
          _Bloco(
              title: 'INFORMAÇÕES ADICIONAIS',
              icon: Icons.notes_rounded,
              th: th,
              children: [
                _F(th, _cServico, 'Serviço / Solução', maxLines: 3),
                const SizedBox(height: 10),
                _F(th, _cDesc, 'Observações gerais', maxLines: 3),
              ]),
        ]),
      );

  Widget _F(
    _Th th,
    TextEditingController ctrl,
    String label, {
    String? hint,
    int maxLines = 1,
    TextInputType? type,
    Color? accent,
    String? mask,
    String? ek,
    VoidCallback? onChange,
    bool uppercase = true,
  }) {
    MaskTextInputFormatter? fmt;
    if (mask != null) fmt = MaskTextInputFormatter(mask: mask);
    final err = ek != null && _erros.contains(ek);
    return _ShakeIt(
      trigger: err,
      child: _Field(
          th: th,
          ctrl: ctrl,
          label: label,
          hint: hint,
          maxLines: maxLines,
          type: type,
          accent: accent,
          fmt: fmt,
          hasErr: err,
          errMsg: err ? _eMsg(ek!) : null,
          onChange: onChange,
          uppercase: uppercase),
    );
  }

  Widget _D(_Th th, String hint, String? value, List<String> items,
      void Function(String?) onChange,
      {bool search = false, String? ek}) {
    final err = ek != null && _erros.contains(ek);
    return _ShakeIt(
      trigger: err,
      child: _Drop(
          th: th,
          hint: hint,
          value: value,
          items: items,
          onChanged: onChange,
          searchable: search,
          hasErr: err,
          errMsg: err ? _eMsg(ek!) : null),
    );
  }

  String _eMsg(String k) => switch (k) {
        'equip' => 'Selecione o equipamento',
        'tec' => 'Selecione o técnico responsável',
        'defeito' => 'Informe o defeito relatado',
        'servReal' => 'Selecione o serviço realizado',
        'qtdTec' => 'Informe quantos técnicos realizaram',
        'termino' => 'Informe a data de término',
        'inicio' => 'Informe a data de início',
        _ => 'Campo obrigatório',
      };

  Widget _footer(_Th th, Color cor) {
    final n = _erros.length;
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 12, 16, MediaQuery.of(context).padding.bottom + 14),
      decoration: BoxDecoration(
        color: th.surf,
        border: Border(top: BorderSide(color: th.border)),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        if (_tentou && n > 0) ...[
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: _rose.withOpacity(.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _rose.withOpacity(.30)),
            ),
            child: Row(children: [
              const Icon(Icons.error_outline_rounded, color: _rose, size: 16),
              const SizedBox(width: 8),
              Expanded(
                  child: Text(
                '$n campo${n > 1 ? 's obrigatórios não preenchidos' : ' obrigatório não preenchido'}',
                style: _ts(12, c: _rose),
              )),
            ]),
          ),
        ],
        Row(children: [
          _Btn(
              label: 'Cancelar',
              icon: Icons.close_rounded,
              onTap: () => Navigator.pop(context),
              color: th.ink3,
              th: th),
          const SizedBox(width: 10),
          Expanded(
              child: _Btn(
            label: _saving ? 'Salvando...' : 'EDITAR O.S',
            icon: _saving ? null : Icons.save_alt_rounded,
            loading: _saving,
            onTap: _saving ? null : _salvar,
            gradient: LinearGradient(
                colors: [_violet, cor == _emerald ? _emerald : _cyan]),
            glowColor: _violet,
            th: th,
          )),
        ]),
      ]),
    );
  }

  @override
  void dispose() {
    for (final c in [
      _cPat,
      _cSala,
      _cSetor,
      _cNos,
      _cCli,
      _cDefeito,
      _cServico,
      _cDesc,
      _cIni,
      _cTer,
      _cPeca,
      _cGas
    ]) {
      c.dispose();
    }
    super.dispose();
  }
}

// ═══════════════════════════════════════════════════════════════
//  BLOCO DE SEÇÃO
// ═══════════════════════════════════════════════════════════════
class _Bloco extends StatelessWidget {
  const _Bloco(
      {required this.title,
      required this.icon,
      required this.th,
      required this.children,
      this.accent,
      this.highlight = false});
  final String title;
  final IconData icon;
  final _Th th;
  final List<Widget> children;
  final Color? accent;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final ac = accent ?? _cyan;
    return Container(
      margin: highlight ? EdgeInsets.zero : const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: highlight ? Colors.transparent : th.surf2,
        borderRadius: BorderRadius.circular(16),
        border: highlight ? null : Border.all(color: th.border),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: const EdgeInsets.fromLTRB(14, 11, 14, 11),
          decoration: BoxDecoration(
            color: ac.withOpacity(th.isDark ? .10 : .06),
            border: Border(
                bottom: BorderSide(
                    color: highlight ? ac.withOpacity(.25) : th.border)),
          ),
          child: Row(children: [
            Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: ac.withOpacity(.15),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Icon(icon, size: 13, color: ac)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(title,
                  style: _ts(highlight ? 10 : 9,
                      c: highlight ? ac : th.ink3, ls: 1.5, b: true)),
            ),
          ]),
        ),
        Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children)),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  FIELD
// ═══════════════════════════════════════════════════════════════
class _Field extends StatefulWidget {
  const _Field(
      {required this.th,
      required this.ctrl,
      required this.label,
      this.hint,
      this.maxLines = 1,
      this.type,
      this.accent,
      this.fmt,
      this.hasErr = false,
      this.errMsg,
      this.onChange,
      this.uppercase = true});
  final _Th th;
  final TextEditingController ctrl;
  final String label;
  final String? hint;
  final int maxLines;
  final TextInputType? type;
  final Color? accent;
  final MaskTextInputFormatter? fmt;
  final bool hasErr;
  final String? errMsg;
  final VoidCallback? onChange;
  final bool uppercase;
  @override
  State<_Field> createState() => _FieldState();
}

class _FieldState extends State<_Field> {
  bool _focused = false;
  @override
  Widget build(BuildContext context) {
    final th = widget.th;
    final ac = widget.accent ?? _cyan;
    final err = widget.hasErr;
    final bColor = err
        ? _rose
        : _focused
            ? ac
            : th.border;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Focus(
        onFocusChange: (v) => setState(() => _focused = v),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          constraints: BoxConstraints(minHeight: widget.maxLines > 1 ? 80 : 48),
          decoration: BoxDecoration(
            color: err
                ? _rose.withOpacity(.04)
                : _focused
                    ? ac.withOpacity(th.isDark ? .04 : .03)
                    : th.surf3,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: bColor, width: err || _focused ? 1.5 : 1),
          ),
          child: TextFormField(
            controller: widget.ctrl,
            maxLines: widget.maxLines,
            keyboardType: widget.type,
            textCapitalization: widget.uppercase
                ? TextCapitalization.characters
                : TextCapitalization.none,
            inputFormatters: [
              if (widget.uppercase) _UpperCase(),
              if (widget.fmt != null) widget.fmt!,
            ],
            style: _ts(14, c: th.ink),
            onChanged: (_) => widget.onChange?.call(),
            decoration: InputDecoration(
              isDense: true,
              labelText: widget.label,
              labelStyle: _ts(12,
                  c: err
                      ? _rose
                      : _focused
                          ? ac
                          : th.ink3),
              hintText: widget.hint,
              hintStyle: _ts(13, c: th.ink3),
              filled: true,
              fillColor: Colors.transparent,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              suffixIcon: err
                  ? const Icon(Icons.error_outline_rounded,
                      color: _rose, size: 18)
                  : null,
            ),
            cursorColor: ac,
          ),
        ),
      ),
      if (err && widget.errMsg != null)
        Padding(
            padding: const EdgeInsets.only(left: 4, top: 4, bottom: 4),
            child: Row(children: [
              const Icon(Icons.info_outline_rounded, color: _rose, size: 12),
              const SizedBox(width: 4),
              Text(widget.errMsg!, style: _ts(11, c: _rose)),
            ]))
      else
        const SizedBox(height: 10),
    ]);
  }
}

// ═══════════════════════════════════════════════════════════════
//  DROPDOWN
// ═══════════════════════════════════════════════════════════════
class _Drop extends StatefulWidget {
  const _Drop(
      {required this.th,
      required this.hint,
      required this.value,
      required this.items,
      required this.onChanged,
      this.searchable = false,
      this.hasErr = false,
      this.errMsg});
  final _Th th;
  final String hint;
  final String? value;
  final List<String> items;
  final void Function(String?) onChanged;
  final bool searchable, hasErr;
  final String? errMsg;
  @override
  State<_Drop> createState() => _DropState();
}

class _DropState extends State<_Drop> {
  bool _pressing = false;
  void _open() => showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        isDismissible: true,
        enableDrag: true,
        useSafeArea: true,
        builder: (_) => _Sheet(
            th: widget.th,
            hint: widget.hint,
            value: widget.value,
            items: widget.items,
            onChanged: widget.onChanged,
            searchable: widget.searchable),
      );

  @override
  Widget build(BuildContext context) {
    final th = widget.th;
    final err = widget.hasErr;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      GestureDetector(
        onTapDown: (_) => setState(() => _pressing = true),
        onTapUp: (_) {
          setState(() => _pressing = false);
          _open();
        },
        onTapCancel: () => setState(() => _pressing = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 48,
          decoration: BoxDecoration(
            color: err
                ? _rose.withOpacity(.04)
                : _pressing
                    ? _cyan.withOpacity(.04)
                    : th.surf3,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: err
                  ? _rose
                  : _pressing
                      ? _cyan
                      : th.border,
              width: err || _pressing ? 1.5 : 1,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(children: [
            Expanded(
                child: Text(
              widget.value ?? widget.hint,
              style: _ts(14,
                  c: widget.value != null
                      ? th.ink
                      : err
                          ? _rose.withOpacity(.65)
                          : th.ink3),
              overflow: TextOverflow.ellipsis,
            )),
            err
                ? const Icon(Icons.error_outline_rounded,
                    color: _rose, size: 18)
                : Icon(Icons.keyboard_arrow_down_rounded,
                    color: _pressing ? _cyan : th.ink3, size: 22),
          ]),
        ),
      ),
      if (err && widget.errMsg != null)
        Padding(
            padding: const EdgeInsets.only(left: 4, top: 4, bottom: 4),
            child: Row(children: [
              const Icon(Icons.info_outline_rounded, color: _rose, size: 12),
              const SizedBox(width: 4),
              Text(widget.errMsg!, style: _ts(11, c: _rose)),
            ]))
      else
        const SizedBox(height: 10),
    ]);
  }
}

// ── Bottom sheet do dropdown ───────────────────────────────────
class _Sheet extends StatefulWidget {
  const _Sheet(
      {required this.th,
      required this.hint,
      required this.value,
      required this.items,
      required this.onChanged,
      this.searchable = false});
  final _Th th;
  final String hint;
  final String? value;
  final List<String> items;
  final void Function(String?) onChanged;
  final bool searchable;
  @override
  State<_Sheet> createState() => _SheetState();
}

class _SheetState extends State<_Sheet> {
  List<String> _filt = [];
  final _sc = TextEditingController();
  @override
  void initState() {
    super.initState();
    _filt = widget.items;
  }

  @override
  Widget build(BuildContext context) {
    final th = widget.th;
    return Container(
      decoration: BoxDecoration(
        color: th.surf,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        border: Border(top: BorderSide(color: th.border)),
      ),
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: .55,
        maxChildSize: .92,
        shouldCloseOnMinExtent: true,
        builder: (_, ctrl) => Column(children: [
          Center(
              child: Container(
                  margin: const EdgeInsets.only(top: 10, bottom: 8),
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                      color: th.border2,
                      borderRadius: BorderRadius.circular(2)))),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 4, 16, 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget.hint, style: _ts(14, c: th.ink2, b: true)),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: th.surf3,
                      border: Border.all(color: th.border),
                    ),
                    child: Icon(Icons.close_rounded, size: 14, color: th.ink2),
                  ),
                ),
              ],
            ),
          ),
          if (widget.searchable)
            Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
                child: _Field(
                  th: th,
                  ctrl: _sc,
                  label: '',
                  hint: 'Pesquisar...',
                  type: TextInputType.text,
                  uppercase: false,
                  onChange: () => setState(() {
                    final q = _sc.text.toLowerCase();
                    _filt = widget.items
                        .where((i) => i.toLowerCase().contains(q))
                        .toList();
                  }),
                )),
          Divider(height: 1, color: th.border),
          Expanded(
              child: ListView.builder(
            controller: ctrl,
            itemCount: _filt.length,
            itemBuilder: (_, i) {
              final item = _filt[i];
              final sel = item == widget.value;
              return ListTile(
                tileColor:
                    sel ? _cyan.withOpacity(th.isDark ? .08 : .05) : null,
                title:
                    Text(item, style: _ts(14, c: sel ? _cyan : th.ink, b: sel)),
                trailing: sel
                    ? Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _cyan.withOpacity(.12),
                            border: Border.all(color: _cyan.withOpacity(.4))),
                        child: const Icon(Icons.check_rounded,
                            color: _cyan, size: 13))
                    : null,
                onTap: () {
                  widget.onChanged(item);
                  Navigator.pop(context);
                },
              );
            },
          )),
        ]),
      ),
    );
  }

  @override
  void dispose() {
    _sc.dispose();
    super.dispose();
  }
}

// ═══════════════════════════════════════════════════════════════
//  CARD DE PONTOS
// ═══════════════════════════════════════════════════════════════
class _PontosCard extends StatelessWidget {
  const _PontosCard(
      {required this.ptTotal,
      required this.ptCalc,
      required this.tecs,
      required this.fotos,
      required this.th});
  final double ptTotal, ptCalc;
  final List<String> tecs;
  final Map<String, String> fotos;
  final _Th th;
  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: th.surf3,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _violet.withOpacity(.25)),
          boxShadow: th.isDark
              ? null
              : [BoxShadow(color: _violet.withOpacity(.06), blurRadius: 10)],
        ),
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [_violet, _amber]),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.emoji_events_rounded,
                    color: Colors.white, size: 15)),
            const SizedBox(width: 10),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('DISTRIBUIÇÃO DE PONTOS',
                  style: _ts(9, c: th.ink3, ls: 1.4, b: true)),
              const SizedBox(height: 2),
              Row(children: [
                Text('${ptTotal.toStringAsFixed(0)} pts totais',
                    style: _ts(12, c: th.ink2)),
                if (tecs.length > 1) ...[
                  Text('  ÷  ${tecs.length} = ', style: _ts(12, c: th.ink3)),
                  Text('${ptCalc.toStringAsFixed(1)} pts cada',
                      style: _ts(12, c: _amber, b: true)),
                ],
              ]),
            ]),
          ]),
          if (tecs.isEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: _rose.withOpacity(.07),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _rose.withOpacity(.22))),
              child: Row(children: [
                const Icon(Icons.warning_amber_rounded, color: _rose, size: 14),
                const SizedBox(width: 8),
                Text('Selecione ao menos 1 técnico', style: _ts(12, c: _rose)),
              ]),
            ),
          ] else ...[
            const SizedBox(height: 12),
            ...tecs.map((nome) {
              final fotoRaw = fotos[nome.trim()];
              final String? foto = _fotoValida(fotoRaw) ? fotoRaw! : null;
              final ini = nome
                  .split(' ')
                  .take(2)
                  .map((w) => w.isNotEmpty ? w[0] : '')
                  .join()
                  .toUpperCase();
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: th.surf2,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: th.border),
                ),
                child: Row(children: [
                  Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: _violet.withOpacity(.35), width: 1.5)),
                      child: ClipOval(
                          child: foto != null
                              ? Image.network(foto,
                                  width: 28,
                                  height: 28,
                                  fit: BoxFit.cover,
                                  webHtmlElementStrategy:
                                      WebHtmlElementStrategy.prefer,
                                  errorBuilder: (_, __, ___) =>
                                      _IniBox(ini: ini))
                              : _IniBox(ini: ini))),
                  const SizedBox(width: 10),
                  Expanded(
                      child: Text(nome,
                          style: _ts(13, c: th.ink, b: true),
                          overflow: TextOverflow.ellipsis)),
                  Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                          color: _amber.withOpacity(.10),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: _amber.withOpacity(.30))),
                      child: Text('+${ptCalc.toStringAsFixed(1)} pts',
                          style: _ts(11, c: _amber, b: true))),
                ]),
              );
            }),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                  color: _emerald.withOpacity(.07),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _emerald.withOpacity(.22))),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Cada técnico receberá', style: _ts(12, c: th.ink3)),
                    Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                            gradient: const LinearGradient(
                                colors: [_emerald, Color(0xFF059669)]),
                            borderRadius: BorderRadius.circular(7),
                            boxShadow: th.isDark
                                ? null
                                : [
                                    BoxShadow(
                                        color: _emerald.withOpacity(.25),
                                        blurRadius: 5)
                                  ]),
                        child: Text('+${ptCalc.toStringAsFixed(1)} pts',
                            style: _ts(12, c: Colors.white, b: true))),
                  ]),
            ),
          ],
        ]),
      );
}

// ═══════════════════════════════════════════════════════════════
//  PÁGINA DE PONTOS
// ═══════════════════════════════════════════════════════════════
class OsPontosPage extends StatefulWidget {
  const OsPontosPage(
      {required this.db,
      required this.pontosadd,
      required this.tec1,
      required this.tec2,
      required this.tec3,
      required this.tec4});
  final FirebaseFirestore db;
  final double pontosadd;
  final String tec1, tec2, tec3, tec4;
  @override
  State<OsPontosPage> createState() => OsPontosPageState();
}

class OsPontosPageState extends State<OsPontosPage> {
  List<String> get _ns => [widget.tec1, widget.tec2, widget.tec3, widget.tec4]
      .where((t) => t.isNotEmpty)
      .toSet()
      .toList();
  Map<String, Map<String, dynamic>> _data = {};
  bool _loading = true, _saving = false;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    final ns = _ns;
    if (ns.isEmpty) {
      setState(() => _loading = false);
      return;
    }
    try {
      final snap = await widget.db
          .collection('PONTOS_POR_TECNICO')
          .where('TECNICO', whereIn: ns)
          .get();
      final map = <String, Map<String, dynamic>>{};
      for (final d in snap.docs) {
        final nome = (d.data()['TECNICO'] ?? '').toString().trim();
        if (nome.isNotEmpty) {
          map[nome] = {
            'pontos': _toD(d.data()['PONTOS']),
            'foto': _fotoValida((d.data()['FOTO'] ?? '').toString())
                ? (d.data()['FOTO'] ?? '').toString()
                : '',
          };
        }
      }
      setState(() {
        _data = map;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _salvar() async {
    setState(() => _saving = true);
    try {
      for (final nome in _ns) {
        final snap = await widget.db
            .collection('PONTOS_POR_TECNICO')
            .where('TECNICO', isEqualTo: nome)
            .limit(1)
            .get();
        if (snap.docs.isEmpty) continue;
        final atual = _toD(snap.docs.first.data()['PONTOS']);
        await snap.docs.first.reference.update({
          'PONTOS': atual + widget.pontosadd,
          'DATA_ATUALIZACAO': FieldValue.serverTimestamp(),
        });
      }
      if (mounted) {
        Navigator.pop(context);
        _snack(context, '✅  Pontos adicionados com sucesso!');
      }
    } catch (e) {
      if (mounted) _snack(context, '❌  Erro: $e', err: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final th = _Th(Theme.of(context).brightness == Brightness.dark);
    return Scaffold(
      backgroundColor: th.bg,
      appBar: AppBar(
        backgroundColor: th.surf,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: th.surf3,
              border: Border.all(color: th.border),
            ),
            child: Icon(Icons.close_rounded, size: 18, color: th.ink2),
          ),
        ),
        title: Row(children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_violet, _amber],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(11),
              boxShadow: [
                BoxShadow(
                    color: _violet.withOpacity(.35),
                    blurRadius: 8,
                    offset: const Offset(0, 2))
              ],
            ),
            child: const Icon(Icons.emoji_events_rounded,
                color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('PONTUAÇÃO TÉCNICOS', style: _ts(15, c: th.ink, b: true)),
            Container(
              margin: const EdgeInsets.only(top: 3),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _emerald.withOpacity(.10),
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: _emerald.withOpacity(.30)),
              ),
              child: Text(
                  '+${widget.pontosadd.toStringAsFixed(1)} pts por técnico',
                  style: _ts(10, c: _emerald, b: true)),
            ),
          ]),
        ]),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: th.surf3,
                  border: Border.all(color: th.border),
                ),
                child: Icon(Icons.close_rounded, size: 16, color: th.ink2),
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [_violet, _amber]),
            ),
          ),
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: _cyan, strokeWidth: 2.5))
          : _ns.isEmpty
              ? Center(
                  child: Text('Nenhum técnico selecionado',
                      style: _ts(13, c: th.ink3)))
              : SingleChildScrollView(
                  child: Column(children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: th.surf2,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: th.border),
                        ),
                        child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.format_quote_rounded,
                                  color: _violet.withOpacity(.4), size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                  child: Text(
                                'Cada técnico receberá individualmente a pontuação '
                                'correspondente, baseada em sua atuação nas '
                                'atividades executadas.',
                                style: _ts(12, c: th.ink2, h: 1.5),
                              )),
                            ]),
                      ),
                    ),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      itemCount: _ns.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, i) {
                        final nome = _ns[i];
                        final d = _data[nome];
                        final pontos = d != null ? _toD(d['pontos']) : null;
                        final foto = (d?['foto'] ?? '').toString();
                        final novoT =
                            pontos != null ? pontos + widget.pontosadd : null;
                        final ini = nome
                            .split(' ')
                            .take(2)
                            .map((w) => w.isNotEmpty ? w[0] : '')
                            .join()
                            .toUpperCase();
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: th.surf2,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: _violet.withOpacity(.15)),
                            boxShadow: th.isDark
                                ? null
                                : [BoxShadow(color: th.shadow, blurRadius: 6)],
                          ),
                          child: Row(children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: !_fotoValida(foto)
                                    ? const LinearGradient(
                                        colors: [_violet, _cyan],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight)
                                    : null,
                                border: Border.all(
                                    color: _violet.withOpacity(.4), width: 2),
                                boxShadow: th.isDark
                                    ? null
                                    : [
                                        BoxShadow(
                                            color: _violet.withOpacity(.2),
                                            blurRadius: 8)
                                      ],
                              ),
                              child: ClipOval(
                                  child: _fotoValida(foto)
                                      ? Image.network(foto,
                                          fit: BoxFit.cover,
                                          webHtmlElementStrategy:
                                              WebHtmlElementStrategy.prefer,
                                          errorBuilder: (_, __, ___) =>
                                              _IniBox(ini: ini))
                                      : _IniBox(ini: ini)),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                                child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(nome,
                                    style: _ts(16, c: th.ink, b: true),
                                    overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 4),
                                Text(
                                  pontos != null
                                      ? 'POSSUI ${pontos.toStringAsFixed(1)} PTS'
                                      : 'Carregando...',
                                  style: _ts(10, c: th.ink3, ls: .8, b: true),
                                ),
                                const SizedBox(height: 10),
                                Wrap(spacing: 8, runSpacing: 6, children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: _emerald.withOpacity(.10),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                          color: _emerald.withOpacity(.35)),
                                    ),
                                    child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.add_rounded,
                                              color: _emerald, size: 13),
                                          const SizedBox(width: 3),
                                          Text(
                                            '${widget.pontosadd.toStringAsFixed(1)} pts',
                                            style:
                                                _ts(12, c: _emerald, b: true),
                                          ),
                                        ]),
                                  ),
                                  if (novoT != null)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: _amber.withOpacity(.08),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                            color: _amber.withOpacity(.30)),
                                      ),
                                      child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                                Icons
                                                    .account_balance_wallet_rounded,
                                                color: _amber,
                                                size: 13),
                                            const SizedBox(width: 3),
                                            Text(
                                              'Total: ${novoT.toStringAsFixed(1)} pts',
                                              style:
                                                  _ts(12, c: _amber, b: true),
                                            ),
                                          ]),
                                    ),
                                ]),
                              ],
                            )),
                          ]),
                        );
                      },
                    ),
                  ]),
                ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: _Btn(
            label: _saving ? 'Salvando...' : 'SALVAR PONTOS',
            icon: _saving ? null : Icons.check_circle_rounded,
            loading: _saving,
            onTap: _saving ? null : _salvar,
            gradient:
                const LinearGradient(colors: [_emerald, Color(0xFF06B6D4)]),
            glowColor: _emerald,
            th: th,
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  DIÁLOGO DE CONFIRMAÇÃO
// ═══════════════════════════════════════════════════════════════
class _ConfirmDialog extends StatelessWidget {
  const _ConfirmDialog({required this.numeroOs});
  final String numeroOs;
  @override
  Widget build(BuildContext context) {
    final th = _Th(Theme.of(context).brightness == Brightness.dark);
    return Dialog(
      backgroundColor: th.surf2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Stack(
        children: [
          Padding(
              padding: const EdgeInsets.all(24),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _amber.withOpacity(.10),
                        border: Border.all(color: _amber.withOpacity(.35))),
                    child: const Icon(Icons.help_outline_rounded,
                        color: _amber, size: 28)),
                const SizedBox(height: 16),
                Text('Confirmar alterações', style: _ts(17, b: true)),
                const SizedBox(height: 8),
                Text('A O.S #$numeroOs será atualizada.\nDeseja prosseguir?',
                    style: _ts(14, c: th.ink2, h: 1.5),
                    textAlign: TextAlign.center),
                const SizedBox(height: 22),
                Row(children: [
                  Expanded(
                      child: _Btn(
                          label: 'NÃO',
                          icon: Icons.close_rounded,
                          onTap: () => Navigator.pop(context, false),
                          color: th.ink3,
                          th: th)),
                  const SizedBox(width: 10),
                  Expanded(
                      child: _Btn(
                          label: 'SIM',
                          icon: Icons.check_rounded,
                          onTap: () => Navigator.pop(context, true),
                          gradient:
                              const LinearGradient(colors: [_violet, _cyan]),
                          glowColor: _violet,
                          th: th)),
                ]),
              ])),
          Positioned(
            top: 12,
            right: 12,
            child: GestureDetector(
              onTap: () => Navigator.pop(context, false),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: th.surf,
                  shape: BoxShape.circle,
                  border: Border.all(color: th.border),
                ),
                child: Icon(Icons.close_rounded, size: 16, color: th.ink3),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  SHAKE WIDGET
// ═══════════════════════════════════════════════════════════════
class _ShakeIt extends StatefulWidget {
  const _ShakeIt({required this.trigger, required this.child});
  final bool trigger;
  final Widget child;
  @override
  State<_ShakeIt> createState() => _ShakeItState();
}

class _ShakeItState extends State<_ShakeIt>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 380));
    _anim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0, end: -7), weight: 1),
      TweenSequenceItem(tween: Tween<double>(begin: -7, end: 7), weight: 2),
      TweenSequenceItem(tween: Tween<double>(begin: 7, end: -5), weight: 2),
      TweenSequenceItem(tween: Tween<double>(begin: -5, end: 5), weight: 2),
      TweenSequenceItem(tween: Tween<double>(begin: 5, end: 0), weight: 1),
    ]).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void didUpdateWidget(_ShakeIt old) {
    super.didUpdateWidget(old);
    if (widget.trigger && !old.trigger) _ctrl.forward(from: 0);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _anim,
        child: widget.child,
        builder: (_, child) =>
            Transform.translate(offset: Offset(_anim.value, 0), child: child),
      );
}

// ═══════════════════════════════════════════════════════════════
//  BOTÃO GENÉRICO
// ═══════════════════════════════════════════════════════════════
class _Btn extends StatefulWidget {
  const _Btn(
      {required this.label,
      required this.th,
      this.icon,
      this.color,
      this.gradient,
      this.glowColor,
      this.loading = false,
      required this.onTap});
  final String label;
  final _Th th;
  final IconData? icon;
  final Color? color;
  final LinearGradient? gradient;
  final Color? glowColor;
  final bool loading;
  final VoidCallback? onTap;
  @override
  State<_Btn> createState() => _BtnState();
}

class _BtnState extends State<_Btn> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 100),
        lowerBound: .94,
        upperBound: 1.0,
        value: 1.0);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final th = widget.th;
    final hasG = widget.gradient != null;
    return GestureDetector(
      onTapDown: (_) => _ctrl.reverse(),
      onTapUp: (_) {
        _ctrl.forward();
        widget.onTap?.call();
      },
      onTapCancel: () => _ctrl.forward(),
      child: ScaleTransition(
        scale: _ctrl,
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: hasG ? null : (widget.color?.withOpacity(.08) ?? th.surf3),
            gradient: widget.gradient,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: hasG
                    ? Colors.transparent
                    : (widget.color?.withOpacity(.25) ?? th.border)),
            boxShadow: widget.glowColor != null && !th.isDark
                ? [
                    BoxShadow(
                        color: widget.glowColor!.withOpacity(.25),
                        blurRadius: 10,
                        offset: const Offset(0, 3))
                  ]
                : null,
          ),
          child: Center(
              child: widget.loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2.5))
                  : Row(mainAxisSize: MainAxisSize.min, children: [
                      if (widget.icon != null) ...[
                        Icon(widget.icon,
                            size: 16,
                            color: hasG
                                ? Colors.white
                                : (widget.color ?? th.ink2)),
                        const SizedBox(width: 7),
                      ],
                      Text(widget.label,
                          style: _ts(14,
                              b: true,
                              c: hasG
                                  ? Colors.white
                                  : (widget.color ?? th.ink2))),
                    ])),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  SKELETON
// ═══════════════════════════════════════════════════════════════
class _SkelCard extends StatefulWidget {
  const _SkelCard({required this.th, this.delay = 0});
  final _Th th;
  final int delay;
  @override
  State<_SkelCard> createState() => _SkelCardState();
}

class _SkelCardState extends State<_SkelCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400))
      ..repeat();
    _anim = Tween<double>(begin: -1.5, end: 2.5)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _anim,
        builder: (_, __) => Container(
          height: 170,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                widget.th.surf2,
                widget.th.surf3,
                widget.th.surf3.withOpacity(.8),
                widget.th.surf3,
                widget.th.surf2
              ],
              stops: [
                math.max(0.0, _anim.value - .6),
                math.max(0.0, _anim.value - .2),
                _anim.value.clamp(0.0, 1.0),
                math.min(1.0, _anim.value + .2),
                math.min(1.0, _anim.value + .6),
              ],
            ),
            border: Border.all(color: widget.th.border),
          ),
        ),
      );
}

// ═══════════════════════════════════════════════════════════════
//  PÁGINA DE ORÇAMENTO
// ═══════════════════════════════════════════════════════════════
class _Item {
  _Item({required this.servico, required this.quantia, required this.valor});
  final String servico;
  final int quantia;
  final double valor;
}

class OsOrcamentoPage extends StatefulWidget {
  const OsOrcamentoPage({
    required this.os,
    required this.db,
    required this.onSaved,
    this.embedded = false,
  });
  final Map<String, dynamic> os;
  final FirebaseFirestore db;
  final VoidCallback onSaved;
  final bool embedded;
  @override
  State<OsOrcamentoPage> createState() => OsOrcamentoPageState();
}

class OsOrcamentoPageState extends State<OsOrcamentoPage> {
  final List<_Item> _itens = [];
  final _cNome = TextEditingController();
  final _cValor = TextEditingController();
  final _cQtd = TextEditingController();
  bool _enviando = false;
  String? _tecFoto;

  String _v(dynamic v) => (v ?? '').toString();
  double get _total => _itens.fold(0, (s, i) => s + i.valor * i.quantia);

  @override
  void initState() {
    super.initState();
    _carregarFotoTec();
  }

  Future<void> _carregarFotoTec() async {
    var tec = _v(widget.os['TECNICORESPONSAVEL']).trim();
    if (tec.isEmpty) tec = _v(widget.os['TECNICO']).trim();
    if (tec.isEmpty || tec.toUpperCase() == 'NÃO DEFINIDO') return;
    try {
      final snap = await widget.db
          .collection('PONTOS_POR_TECNICO')
          .where('TECNICO', isEqualTo: tec)
          .limit(1)
          .get();
      String? foto;
      if (snap.docs.isNotEmpty) {
        foto = (snap.docs.first.data()['FOTO'] ?? '').toString();
      } else {
        final all = await widget.db.collection('PONTOS_POR_TECNICO').get();
        final tecLower = tec.toLowerCase();
        for (final d in all.docs) {
          if ((d.data()['TECNICO'] ?? '').toString().trim().toLowerCase() ==
              tecLower) {
            foto = (d.data()['FOTO'] ?? '').toString();
            break;
          }
        }
      }
      if (mounted && _fotoValida(foto)) setState(() => _tecFoto = foto);
    } catch (_) {}
  }

  void _addItem() {
    if (_cNome.text.trim().isEmpty || _cValor.text.trim().isEmpty) {
      showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
                backgroundColor:
                    _Th(Theme.of(context).brightness == Brightness.dark).surf2,
                title: Text('Atenção', style: _ts(16, b: true)),
                content: Text('Preencha o nome e o valor.', style: _ts(14)),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: Text('Ok', style: _ts(13, c: _cyan, b: true)),
                  )
                ],
              ));
      return;
    }
    setState(() {
      _itens.add(_Item(
        servico: _cNome.text.trim(),
        valor: double.tryParse(_cValor.text.replaceAll(',', '.')) ?? 0,
        quantia: int.tryParse(_cQtd.text) ?? 1,
      ));
      _cNome.clear();
      _cValor.clear();
      _cQtd.clear();
    });
  }

  Future<void> _enviar() async {
    if (_itens.isEmpty) {
      _alertDialog('Adicione ao menos um item ao orçamento.');
      return;
    }

    final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
              backgroundColor:
                  _Th(Theme.of(context).brightness == Brightness.dark).surf2,
              title: Text('Enviar orçamento?', style: _ts(16, b: true)),
              content:
                  Text('O cliente será notificado pelo app.', style: _ts(14)),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: Text('NÃO', style: _ts(13, c: _rose, b: true))),
                TextButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: Text('SIM', style: _ts(13, c: _emerald, b: true))),
              ],
            ));
    if (ok != true) return;

    setState(() => _enviando = true);

    final numeroos = _v(widget.os['NUMERODAOS']);
    final email = _v(widget.os['EMAIL']);
    final mes = _v(widget.os['MES']);
    final cliente = _v(widget.os['CLIENTE']);
    final equipamento = _v(widget.os['EQUIPAMENTO']);
    final sala = _v(widget.os['SALA']);
    final setor = _v(widget.os['SETOR']);
    final patrimonio = _v(widget.os['PATRIMONIO']);

    try {
      await widget.db.collection('NOTIFICACAO').add({
        'email': email,
        'visto': false,
        'titulo': '✅ Orçamento Disponível',
        'mensagem':
            'O orçamento da O.S #$numeroos já está disponível. Abra o app HPS Refrigeração ou acesse www.hpsrefri.com.br para aprovar.',
        'status': 'AGUARDANDO APROVAÇÃO',
        'os': numeroos,
        'mes': mes,
        'ano': DateTime.now().year,
        'tipo': 'corretivas',
        'data': FieldValue.serverTimestamp(),
      });

      unawaited(_onesignalPush(
        email: email,
        titulo: '✅ Orçamento Disponível',
        mensagem:
            'O orçamento da O.S #$numeroos já está disponível. Abra o app HPS Refrigeração ou acesse www.hpsrefri.com.br para aprovar.',
      ));

      if (mounted && email.isNotEmpty) {
        setState(() => _enviando = false);
        final emailsSelecionados = await _mostrarDialogoConfirmarEmailOrc(
          email: email,
          numeroos: numeroos,
        );
        setState(() => _enviando = true);
        for (final dest in emailsSelecionados) {
          unawaited(_sendEmailPorStatus(
            toEmail: dest,
            status: 'AGUARDANDO APROVAÇÃO',
            numeroos: numeroos,
            cliente: cliente,
            equipamento: equipamento,
            sala: sala,
            setor: setor,
            patrimonio: patrimonio,
          ));
        }
      }

      final listaPecas =
          _itens.map((i) => '${i.quantia}x ${i.servico}').toList();
      final listaValores = _itens.map((i) => i.valor * i.quantia).toList();

      await widget.db
          .collection('SERVICOSREALIZADOS')
          .doc(widget.os['_id'])
          .update({
        'STATUS': 'AGUARDANDO APROVAÇÃO',
        'PECAS': listaPecas,
        'VALOR': listaValores,
        'DATA_ATUALIZACAO': FieldValue.serverTimestamp(),
      });

      final manSnap = await widget.db
          .collection('MANUTENCAO')
          .where('NUMERO_OS', isEqualTo: numeroos)
          .limit(1)
          .get();
      if (manSnap.docs.isNotEmpty) {
        await manSnap.docs.first.reference.update({
          'STATUS': 'AGUARDANDO APROVAÇÃO',
          'PECAS': listaPecas,
          'VALOR': listaValores,
          'DATA_ATUALIZACAO': FieldValue.serverTimestamp(),
        });
      }

      if (!mounted) return;
      widget.onSaved();
      Navigator.of(context)
        ..pop()
        ..pop();
      _snack(context, '✅  Orçamento enviado! Cliente notificado.');
    } catch (e) {
      if (mounted) _snack(context, '❌  Erro: $e', err: true);
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  static const _oneSignalAppId = '7b01186f-cf76-4b5d-8354-87d83737d40c';
  static const _oneSignalApiKey =
      'Basic ZTdlNjIwZWItMjEyMC00M2RhLWJlZmYtMzc2NTBmNzNmMDdj';
  static const _oneSignalChannelId = '577bba44-d1bf-4ac9-9d11-20d89e09a61a';

  Future<List<String>> _mostrarDialogoConfirmarEmailOrc({
    required String email,
    required String numeroos,
  }) async {
    if (email.isEmpty) return [];

    List<String> emailsAdicionais = [];
    try {
      final snap = await widget.db
          .collection('USUARIOS')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
      if (snap.docs.isNotEmpty) {
        final field = snap.docs.first.data()['emailteste'];
        if (field is List) {
          for (final e in field) {
            final s = (e ?? '').toString().trim();
            if (s.isNotEmpty) emailsAdicionais.add(s);
          }
        } else if (field is String && field.trim().isNotEmpty) {
          emailsAdicionais.add(field.trim());
        }
      }
    } catch (_) {}

    List<String> selecionados = [email];
    const cor = _amber;

    if (!mounted) return [];

    final result = await showDialog<List<String>>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(.6),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) {
          final th = _Th(Theme.of(ctx).brightness == Brightness.dark);

          Widget emailTile({
            required String mail,
            required String badge,
            required Color badgeColor,
          }) {
            final sel = selecionados.contains(mail);
            return GestureDetector(
              onTap: () => setS(() {
                if (sel)
                  selecionados.remove(mail);
                else
                  selecionados.add(mail);
              }),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                margin: const EdgeInsets.only(bottom: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color:
                      sel ? cor.withOpacity(th.isDark ? .10 : .06) : th.surf2,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: sel ? cor.withOpacity(.45) : th.border,
                    width: sel ? 1.5 : 1,
                  ),
                ),
                child: Row(children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: sel ? cor : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: sel
                            ? cor
                            : (th.isDark ? Colors.white24 : Colors.black26),
                        width: 2,
                      ),
                    ),
                    child: sel
                        ? const Icon(Icons.check_rounded,
                            color: Colors.white, size: 13)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(mail,
                        style: _ts(13, c: sel ? th.ink : th.ink2, b: sel),
                        overflow: TextOverflow.ellipsis),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: badgeColor.withOpacity(.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(badge, style: _ts(10, c: badgeColor, b: true)),
                  ),
                ]),
              ),
            );
          }

          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
            child: Container(
              constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(ctx).size.height * .85),
              decoration: BoxDecoration(
                color: th.surf,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(.35),
                      blurRadius: 32,
                      offset: const Offset(0, 8)),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(20, 20, 16, 18),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          cor.withOpacity(th.isDark ? .25 : .12),
                          cor.withOpacity(th.isDark ? .08 : .04),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(24)),
                      border: Border(
                          bottom: BorderSide(color: cor.withOpacity(.18))),
                    ),
                    child: Row(children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: cor.withOpacity(.15),
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: cor.withOpacity(.35), width: 1.5),
                        ),
                        child: const Center(
                          child: Text('📋', style: TextStyle(fontSize: 22)),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Notificar por E-mail',
                                style: _ts(16, c: th.ink, b: true)),
                            const SizedBox(height: 3),
                            Text(
                              'Orçamento disponível — O.S #$numeroos',
                              style: _ts(12, c: th.ink2),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.of(ctx).pop(<String>[]),
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: th.surf3,
                            shape: BoxShape.circle,
                            border: Border.all(color: th.border),
                          ),
                          child: Icon(Icons.close_rounded,
                              size: 16, color: th.ink3),
                        ),
                      ),
                    ]),
                  ),
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: cor.withOpacity(th.isDark ? .08 : .05),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: cor.withOpacity(.22)),
                            ),
                            child: Row(children: [
                              Container(
                                  width: 7,
                                  height: 7,
                                  decoration: const BoxDecoration(
                                      shape: BoxShape.circle, color: cor)),
                              const SizedBox(width: 9),
                              Text('AGUARDANDO APROVAÇÃO',
                                  style: _ts(11, c: cor, b: true, ls: .5)),
                            ]),
                          ),
                          const SizedBox(height: 18),
                          Row(children: [
                            Icon(Icons.people_outline_rounded,
                                size: 14, color: th.ink3),
                            const SizedBox(width: 7),
                            Text('DESTINATÁRIOS',
                                style: _ts(10, c: th.ink3, b: true, ls: 1.2)),
                            const SizedBox(width: 8),
                            if (selecionados.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: cor,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                    '${selecionados.length} selecionado${selecionados.length > 1 ? 's' : ''}',
                                    style: _ts(10, c: Colors.white, b: true)),
                              ),
                          ]),
                          const SizedBox(height: 10),
                          emailTile(
                            mail: email,
                            badge: 'Principal',
                            badgeColor: _emerald,
                          ),
                          ...emailsAdicionais.map((mail) => emailTile(
                                mail: mail,
                                badge: 'Adicional',
                                badgeColor: _violet,
                              )),
                          if (emailsAdicionais.isEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: th.surf3,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: th.border),
                              ),
                              child: Row(children: [
                                Icon(Icons.info_outline_rounded,
                                    size: 13, color: th.ink3),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Nenhum e-mail adicional cadastrado para este cliente.',
                                    style: _ts(12, c: th.ink3, h: 1.4),
                                  ),
                                ),
                              ]),
                            ),
                          const SizedBox(height: 18),
                          Row(children: [
                            Icon(Icons.info_outline_rounded,
                                size: 12, color: th.ink3),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'O e-mail será enviado via Brevo informando que o orçamento está disponível.',
                                style: _ts(11, c: th.ink3, h: 1.5),
                              ),
                            ),
                          ]),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
                    decoration: BoxDecoration(
                      color: th.surf3,
                      borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(24)),
                      border: Border(top: BorderSide(color: th.border)),
                    ),
                    child: Column(children: [
                      GestureDetector(
                        onTap: selecionados.isEmpty
                            ? null
                            : () => Navigator.of(ctx)
                                .pop(List<String>.from(selecionados)),
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 160),
                          opacity: selecionados.isEmpty ? .4 : 1.0,
                          child: Container(
                            width: double.infinity,
                            height: 52,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                  colors: [cor, Color(0xFFD97706)]),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: selecionados.isEmpty
                                  ? null
                                  : [
                                      BoxShadow(
                                          color: cor.withOpacity(.25),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4))
                                    ],
                            ),
                            child: Center(
                              child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.send_rounded,
                                        color: Colors.white, size: 16),
                                    const SizedBox(width: 8),
                                    Text(
                                      selecionados.isEmpty
                                          ? 'Selecione ao menos 1 e-mail'
                                          : 'ENVIAR PARA ${selecionados.length} E-MAIL${selecionados.length > 1 ? 'S' : ''}',
                                      style: _ts(13, c: Colors.white, b: true),
                                    ),
                                  ]),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: () => Navigator.of(ctx).pop(<String>[]),
                        child: Container(
                          width: double.infinity,
                          height: 48,
                          decoration: BoxDecoration(
                            color: th.surf,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: th.border2),
                          ),
                          child: Center(
                            child:
                                Row(mainAxisSize: MainAxisSize.min, children: [
                              Icon(Icons.save_alt_rounded,
                                  color: th.ink2, size: 15),
                              const SizedBox(width: 8),
                              Text('SALVAR SEM ENVIAR E-MAIL',
                                  style: _ts(13, c: th.ink2, b: true)),
                            ]),
                          ),
                        ),
                      ),
                    ]),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
    return result ?? [];
  }

  Future<void> _onesignalPush({
    required String email,
    required String titulo,
    required String mensagem,
  }) async {
    if (email.isEmpty) return;
    try {
      await http.post(
        Uri.parse('https://onesignal.com/api/v1/notifications'),
        headers: {
          'Authorization': _oneSignalApiKey,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'app_id': _oneSignalAppId,
          'filters': [
            {'field': 'tag', 'key': 'Email', 'relation': '=', 'value': email}
          ],
          'headings': {'en': titulo},
          'contents': {'en': mensagem},
          'android_channel_id': _oneSignalChannelId,
          'priority': 10,
        }),
      );
    } catch (e) {
      debugPrint('OneSignal push error: $e');
    }
  }

  Future<void> _alertDialog(String msg) => showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor:
              _Th(Theme.of(context).brightness == Brightness.dark).surf2,
          title: Text('Atenção', style: _ts(16, b: true)),
          content: Text(msg, style: _ts(14)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Ok', style: _ts(13, c: _cyan, b: true)),
            )
          ],
        ),
      );

  // ── helper local para não depender de _v do OsEditPageState ──
  String _osInfo(String key) => (widget.os[key] ?? '').toString();

  @override
  Widget build(BuildContext context) {
    final th = _Th(Theme.of(context).brightness == Brightness.dark);
    final cor = _amber;

    final osStatus = _osInfo('STATUS');
    final osNum = _osInfo('NUMERODAOS');
    final osCli = _osInfo('CLIENTE');
    final osPat = _osInfo('PATRIMONIO');
    final osEq = _osInfo('EQUIPAMENTO');
    final osSala = _osInfo('SALA');
    final osSetor = _osInfo('SETOR');
    final osCad =
        _osInfo('CADASTRO').isNotEmpty ? _osInfo('CADASTRO') : _osInfo('DATA');
    final osMes = _osInfo('MES');
    final osSv =
        _osInfo('SERVICO').isNotEmpty ? _osInfo('SERVICO') : _osInfo('DEFEITO');
    final osDesc = _osInfo('DESCRICAO');
    final osTec = _osInfo('TECNICORESPONSAVEL').trim().isNotEmpty
        ? _osInfo('TECNICORESPONSAVEL')
        : _osInfo('TECNICO');
    final statusCor = _sColor(osStatus);

    return Scaffold(
      backgroundColor: th.bg,
      appBar: AppBar(
        backgroundColor: th.surf,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: !widget.embedded,
        leading: widget.embedded
            ? null
            : IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: th.surf3,
                    border: Border.all(color: th.border),
                  ),
                  child: Icon(Icons.close_rounded, size: 18, color: th.ink2),
                ),
              ),
        title: Row(children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: LinearGradient(
                colors: [cor, cor.withOpacity(.6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                    color: cor.withOpacity(.35),
                    blurRadius: 8,
                    offset: const Offset(0, 2))
              ],
            ),
            child: const Icon(Icons.receipt_long_rounded,
                color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Cadastrar Peças & Serviços',
                style: _ts(15, c: th.ink, b: true)),
            Text('#$osNum', style: _ts(11, c: th.ink3, ls: .4)),
          ]),
        ]),
        actions: widget.embedded ? const [SizedBox(width: 44)] : null,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [cor.withOpacity(.6), cor.withOpacity(.05)]),
              )),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // ── INFORMAÇÕES DA O.S ─────────────────────────────────────────
          _Bloco(
            title: 'INFORMAÇÕES DA ORDEM DE SERVIÇO',
            icon: Icons.assignment_outlined,
            th: th,
            accent: statusCor,
            children: [
              // Número + Cliente + Status pill
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('O.S #$osNum',
                            style: _ts(10, c: th.ink3, ls: 1.5, b: true)),
                        const SizedBox(height: 4),
                        Text(osCli.isNotEmpty ? osCli : '—',
                            style: _ts(19, c: th.ink, b: true, h: 1.1),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  _StatusPill(status: osStatus, cor: statusCor, th: th),
                ],
              ),
              const SizedBox(height: 14),
              // Chips de meta-dados
              Wrap(spacing: 8, runSpacing: 8, children: [
                if (osPat.isNotEmpty)
                  _Chip(
                      icon: Icons.qr_code_2_rounded,
                      label: 'PAT: $osPat',
                      th: th,
                      cor: statusCor),
                if (osEq.isNotEmpty)
                  _Chip(
                      icon: Icons.devices_other_rounded,
                      label: osEq,
                      th: th,
                      cor: statusCor),
                if (osSala.isNotEmpty)
                  _Chip(
                      icon: Icons.meeting_room_rounded,
                      label: osSala,
                      th: th,
                      cor: statusCor),
                if (osSetor.isNotEmpty)
                  _Chip(
                      icon: Icons.grid_view_rounded,
                      label: osSetor,
                      th: th,
                      cor: statusCor),
                if (osCad.isNotEmpty)
                  _Chip(
                      icon: Icons.calendar_today_rounded,
                      label: osCad,
                      th: th,
                      cor: statusCor),
                if (osMes.isNotEmpty)
                  _Chip(
                      icon: Icons.event_note_rounded,
                      label: osMes,
                      th: th,
                      cor: statusCor),
              ]),
              // Defeito / Serviço
              if (osSv.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                  decoration: BoxDecoration(
                    color: statusCor.withOpacity(th.isDark ? .06 : .04),
                    borderRadius: BorderRadius.circular(10),
                    border:
                        Border(left: BorderSide(color: statusCor, width: 3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('DEFEITO RELATADO / SERVIÇO',
                          style: _ts(8,
                              c: statusCor.withOpacity(.7), ls: 1.6, b: true)),
                      const SizedBox(height: 5),
                      Text(osSv, style: _ts(14, c: th.ink2, h: 1.4)),
                    ],
                  ),
                ),
              ],
              // Observações
              if (osDesc.isNotEmpty) ...[
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                  decoration: BoxDecoration(
                    color: th.surf3,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: th.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Icon(Icons.speaker_notes_rounded,
                            size: 12, color: th.ink3),
                        const SizedBox(width: 4),
                        Text('OBSERVAÇÕES',
                            style: _ts(9, c: th.ink3, ls: 1.2, b: true)),
                      ]),
                      const SizedBox(height: 6),
                      Text(osDesc, style: _ts(12, c: th.ink2, h: 1.4)),
                    ],
                  ),
                ),
              ],
              // Técnico responsável
              if (osTec.isNotEmpty && osTec != 'NÃO DEFINIDO') ...[
                const SizedBox(height: 12),
                Divider(height: 1, color: th.border),
                const SizedBox(height: 12),
                _TecAvatar(nome: osTec, fotoUrl: _tecFoto, th: th, size: 34),
              ],
            ],
          ),
          // ── FIM INFORMAÇÕES DA O.S ─────────────────────────────────────

          Text(
              'Gerencie peças, serviços e valores de forma moderna e eficiente',
              style: _ts(13, c: th.ink2, h: 1.4)),
          const SizedBox(height: 16),
          if (_itens.isNotEmpty) ...[
            Container(
              decoration: BoxDecoration(
                color: th.surf2,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: cor.withOpacity(.25)),
              ),
              padding: const EdgeInsets.all(14),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: cor.withOpacity(.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child:
                            Icon(Icons.list_alt_rounded, size: 15, color: cor),
                      ),
                      const SizedBox(width: 10),
                      Text('Lista de peças e serviços',
                          style: _ts(13, c: th.ink, b: true)),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: cor.withOpacity(.10),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: cor.withOpacity(.25)),
                        ),
                        child: Text(
                            '${_itens.length} ite${_itens.length == 1 ? 'm' : 'ns'}',
                            style: _ts(11, c: cor, b: true)),
                      ),
                    ]),
                    Divider(color: th.border, height: 18),
                    ..._itens.asMap().entries.map((e) {
                      final i = e.key;
                      final item = e.value;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: th.surf3,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: th.border),
                        ),
                        child: Row(children: [
                          Icon(Icons.build_rounded, color: cor, size: 16),
                          const SizedBox(width: 10),
                          Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                Text(item.servico,
                                    style: _ts(13, c: th.ink, b: true),
                                    overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 2),
                                Row(children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: th.surf2,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text('${item.quantia}x',
                                        style: _ts(10, c: th.ink3, b: true)),
                                  ),
                                  const SizedBox(width: 6),
                                  Icon(Icons.monetization_on_rounded,
                                      color: _emerald, size: 13),
                                  const SizedBox(width: 3),
                                  Text(
                                      'R\$ ${item.valor.toStringAsFixed(2).replaceAll('.', ',')}',
                                      style: _ts(12, c: _emerald, b: true)),
                                  const SizedBox(width: 8),
                                  Text(
                                      '= R\$ ${(item.valor * item.quantia).toStringAsFixed(2).replaceAll('.', ',')}',
                                      style: _ts(11, c: th.ink2)),
                                ]),
                              ])),
                          IconButton(
                            onPressed: () => setState(() => _itens.removeAt(i)),
                            icon: const Icon(Icons.close_rounded,
                                color: Color(0xD2FF5963), size: 20),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                                minWidth: 28, minHeight: 28),
                          ),
                        ]),
                      );
                    }),
                    Divider(color: th.border, height: 14),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Total estimado:', style: _ts(13, c: th.ink2)),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                  colors: [Color(0xFF059669), _emerald]),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'R\$ ${_total.toStringAsFixed(2).replaceAll('.', ',')}',
                              style: _ts(14, c: Colors.white, b: true),
                            ),
                          ),
                        ]),
                  ]),
            ),
            const SizedBox(height: 16),
          ],
          _Bloco(
            title: 'ADICIONAR ITEM',
            icon: Icons.add_box_rounded,
            th: th,
            accent: cor,
            children: [
              Text('Nome da Peça/Serviço',
                  style: _ts(11, c: th.ink3, ls: 1, b: true)),
              const SizedBox(height: 6),
              _Field(
                th: th,
                ctrl: _cNome,
                label: '',
                hint: 'Ex: Filtro de óleo, Troca de pastilhas',
                type: TextInputType.text,
                accent: cor,
                uppercase: true,
              ),
              Row(children: [
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text('Valor Unitário',
                          style: _ts(11, c: th.ink3, ls: 1, b: true)),
                      const SizedBox(height: 6),
                      _Field(
                        th: th,
                        ctrl: _cValor,
                        label: '',
                        hint: 'R\$ 0,00',
                        type: const TextInputType.numberWithOptions(
                            decimal: true),
                        accent: cor,
                        uppercase: false,
                      ),
                    ])),
                const SizedBox(width: 12),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text('Quantidade',
                          style: _ts(11, c: th.ink3, ls: 1, b: true)),
                      const SizedBox(height: 6),
                      _Field(
                        th: th,
                        ctrl: _cQtd,
                        label: '',
                        hint: '1',
                        type: TextInputType.number,
                        accent: cor,
                        uppercase: false,
                      ),
                    ])),
              ]),
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: _addItem,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      gradient:
                          LinearGradient(colors: [cor, cor.withOpacity(.7)]),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: th.isDark
                          ? null
                          : [
                              BoxShadow(
                                  color: cor.withOpacity(.25),
                                  blurRadius: 6,
                                  offset: const Offset(0, 3))
                            ],
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.add_circle_outline_rounded,
                          color: Colors.white, size: 16),
                      const SizedBox(width: 6),
                      Text('Cadastrar Item',
                          style: _ts(13, c: Colors.white, b: true)),
                    ]),
                  ),
                ),
              ),
            ],
          ),
        ]),
      ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          decoration: BoxDecoration(
            color: th.surf,
            border: Border(top: BorderSide(color: th.border)),
          ),
          child: Row(children: [
            _Btn(
              label: 'Cancelar',
              icon: Icons.close_rounded,
              onTap: () {
                setState(() => _itens.clear());
                Navigator.pop(context);
              },
              color: th.ink3,
              th: th,
            ),
            const SizedBox(width: 12),
            Expanded(
                child: _Btn(
              label: _enviando ? 'Enviando...' : 'Enviar Orçamento',
              icon: _enviando ? null : Icons.send_rounded,
              loading: _enviando,
              onTap: _enviando ? null : _enviar,
              gradient: LinearGradient(colors: [cor, cor.withOpacity(.7)]),
              glowColor: cor,
              th: th,
            )),
          ]),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _cNome.dispose();
    _cValor.dispose();
    _cQtd.dispose();
    super.dispose();
  }
}

// ═══════════════════════════════════════════════════════════════
//  VISUALIZADOR DE IMAGEM TELA CHEIA
// ═══════════════════════════════════════════════════════════════
void _abrirImagemTela(BuildContext context, String url, String titulo, _Th th) {
  Navigator.of(context).push(PageRouteBuilder(
    opaque: false,
    barrierColor: Colors.black,
    pageBuilder: (_, __, ___) =>
        _ImagemTelaCheia(url: url, titulo: titulo, th: th),
    transitionsBuilder: (_, a, __, child) =>
        FadeTransition(opacity: a, child: child),
    transitionDuration: const Duration(milliseconds: 250),
  ));
}

class _ImagemTelaCheia extends StatefulWidget {
  const _ImagemTelaCheia(
      {required this.url, required this.titulo, required this.th});
  final String url;
  final String titulo;
  final _Th th;
  @override
  State<_ImagemTelaCheia> createState() => _ImagemTelaCheiState();
}

class _ImagemTelaCheiState extends State<_ImagemTelaCheia>
    with SingleTickerProviderStateMixin {
  final _transformCtrl = TransformationController();
  late AnimationController _animCtrl;
  Animation<Matrix4>? _animReset;
  bool _barrasVisiveis = true;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _animCtrl.addListener(() {
      if (_animReset != null) {
        _transformCtrl.value = _animReset!.value;
      }
    });
  }

  @override
  void dispose() {
    _transformCtrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  void _resetZoom() {
    _animReset = Matrix4Tween(
      begin: _transformCtrl.value,
      end: Matrix4.identity(),
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _animCtrl.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () => setState(() => _barrasVisiveis = !_barrasVisiveis),
        onDoubleTap: _resetZoom,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                transformationController: _transformCtrl,
                minScale: 0.5,
                maxScale: 5.0,
                child: Image.network(
                  widget.url,
                  fit: BoxFit.contain,
                  width: size.width,
                  errorBuilder: (_, __, ___) => Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.broken_image_rounded,
                          color: Colors.white38, size: 64),
                      const SizedBox(height: 12),
                      Text('Erro ao carregar imagem',
                          style: _ts(14, c: Colors.white54)),
                    ],
                  ),
                  loadingBuilder: (_, child, progress) {
                    if (progress == null) return child;
                    final pct = progress.expectedTotalBytes != null
                        ? progress.cumulativeBytesLoaded /
                            progress.expectedTotalBytes!
                        : null;
                    return SizedBox(
                      height: size.height * .5,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                              value: pct, color: _cyan, strokeWidth: 2.5),
                          const SizedBox(height: 16),
                          Text(
                            pct != null
                                ? '${(pct * 100).toStringAsFixed(0)}%'
                                : 'Carregando...',
                            style: _ts(13, c: Colors.white54),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            AnimatedOpacity(
              opacity: _barrasVisiveis ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black87, Colors.transparent],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(.12),
                            border: Border.all(
                                color: Colors.white.withOpacity(.25)),
                          ),
                          child: const Icon(Icons.arrow_back_rounded,
                              color: Colors.white, size: 20),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(widget.titulo,
                                style: _ts(15, c: Colors.white, b: true),
                                overflow: TextOverflow.ellipsis),
                            Text('Toque 2x para redefinir zoom',
                                style: _ts(11, c: Colors.white54)),
                          ],
                        ),
                      ),
                    ]),
                  ),
                ),
              ),
            ),
            AnimatedOpacity(
              opacity: _barrasVisiveis ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [Colors.black87, Colors.transparent],
                    ),
                  ),
                  padding: EdgeInsets.fromLTRB(
                      20, 20, 20, MediaQuery.of(context).padding.bottom + 16),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.touch_app_rounded,
                            color: Colors.white38, size: 16),
                        const SizedBox(width: 8),
                        Text('Toque na tela para ocultar/mostrar controles',
                            style: _ts(12, c: Colors.white38)),
                      ]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  SNACKBAR
// ═══════════════════════════════════════════════════════════════
void _snack(BuildContext context, String msg, {bool err = false}) =>
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        Icon(err ? Icons.error_outline_rounded : Icons.check_circle_rounded,
            color: Colors.white, size: 18),
        const SizedBox(width: 8),
        Expanded(child: Text(msg, style: _ts(13, c: Colors.white))),
      ]),
      backgroundColor: err ? _rose : _emerald,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 3),
    ));
