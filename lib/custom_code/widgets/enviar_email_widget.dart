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

import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

// ─────────────────────────────────────────────────────────────────────────────
//  Envio de email via Brevo
//  A apiKey é buscada do campo 'apibrevo' do documento hpsrefri@gmail.com
//  na coleção USUARIOS — nunca hardcoded.
// ─────────────────────────────────────────────────────────────────────────────
Future<bool> _sendEmail({
  required List<String> toEmails,
  List<String> ccEmails = const [],
  required String subject,
  required String message,
}) async {
  const senderEmail = 'equipe@hpsrefri.com.br';
  const senderName = 'HPS Refrigeração';
  const imgUrl =
      'https://firebasestorage.googleapis.com/v0/b/h-p-s-modificado-emdcp0.appspot.com/o/Gemini_Generated_Image_2xpdsd2xpdsd2xpd%20(1).png?alt=media&token=be3e052e-a0b8-4e8c-8151-b9365b507ed5';

  // ── Busca apibrevo do Firestore ──────────────────────────────
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
  if (apiKey.isEmpty) return false;

  final htmlBody = '''
<!DOCTYPE html>
<html lang="pt-BR">
<head>
  <meta charset="UTF-8">
  <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
  <title>$subject</title>
</head>
<body style="margin:0;padding:0;background-color:#f4f6f8;font-family:Arial,Helvetica,sans-serif;">
  <table width="100%" cellpadding="0" cellspacing="0" border="0" style="background-color:#f4f6f8;padding:20px 0;">
    <tr><td align="center">
      <table width="600" cellpadding="0" cellspacing="0" border="0"
             style="background:#ffffff;border-radius:12px;overflow:hidden;max-width:1400px;width:100%;">
        <tr>
          <td style="padding:0;margin:0;line-height:0;">
            <img src="$imgUrl" alt="HPS Refrigeração" width="600"
                 style="display:block;width:100%;max-width:1400px;height:auto;border:0;"/>
          </td>
        </tr>
        <tr>
          <td style="background-color:#1A3C34;padding:12px 24px;">
            <table width="100%" cellpadding="0" cellspacing="0" border="0">
              <tr>
                <td></td>
                <td align="right">
                  <span style="background:#ffffff20;color:#ffffff;font-size:11px;font-weight:bold;padding:4px 10px;border-radius:20px;font-family:Arial,sans-serif;">Notificação Automática</span>
                </td>
              </tr>
            </table>
          </td>
        </tr>
        <tr>
          <td style="padding:28px;color:#333333;font-size:15px;line-height:1.7;font-family:Arial,Helvetica,sans-serif;">
            $message
          </td>
        </tr>
        <tr><td style="padding:0 28px;"><hr style="border:none;border-top:1px solid #e8ecf0;margin:0;"></td></tr>
        <tr>
          <td style="padding:20px 28px;font-family:Arial,Helvetica,sans-serif;">
            <table cellpadding="0" cellspacing="0" border="0">
              <tr>
                <td style="width:44px;vertical-align:top;">
                  <div style="width:40px;height:40px;background:#1A3C34;border-radius:50%;text-align:center;line-height:40px;">
                    <span style="color:#ffffff;font-size:18px;font-weight:bold;font-family:Arial,sans-serif;">H</span>
                  </div>
                </td>
                <td style="padding-left:12px;vertical-align:top;">
                  <span style="font-size:15px;font-weight:bold;color:#1A3C34;font-family:Arial,sans-serif;">Huagner Pires</span><br>
                  <span style="font-size:13px;color:#555555;font-family:Arial,sans-serif;">Especialista em Refrigeração &middot; </span><br>
                  <span style="font-size:12px;color:#888888;font-family:Arial,sans-serif;">hpsrefri.com.br</span>
                </td>
              </tr>
            </table>
          </td>
        </tr>
        <tr>
          <td style="background:#f1f5f9;padding:14px 28px;text-align:center;font-size:12px;color:#94a3b8;font-family:Arial,Helvetica,sans-serif;border-top:1px solid #e2e8f0;">
            &copy; 2026 HPS Refrigeração &middot; Todos os direitos reservados<br>
            <span style="font-size:11px;">Esta é uma mensagem automática, por favor não responda diretamente.</span>
          </td>
        </tr>
      </table>
    </td></tr>
  </table>
</body>
</html>
''';

  final body = <String, dynamic>{
    'sender': {'name': senderName, 'email': senderEmail},
    'replyTo': {'name': senderName, 'email': senderEmail},
    'to': toEmails.map((e) => {'email': e}).toList(),
    'subject': subject,
    'htmlContent': htmlBody,
  };

  if (ccEmails.isNotEmpty) {
    body['cc'] = ccEmails.map((e) => {'email': e}).toList();
  }

  final response = await http.post(
    Uri.parse('https://api.brevo.com/v3/smtp/email'),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'api-key': apiKey,
    },
    body: jsonEncode(body),
  );

  if (response.statusCode == 200 || response.statusCode == 201) {
    return true;
  } else {
    throw Exception('Erro ${response.statusCode}: ${response.body}');
  }
}

class EnviarEmailWidget extends StatefulWidget {
  const EnviarEmailWidget({
    super.key,
    this.width,
    this.height,
    this.onCancelar,
  });

  final double? width;
  final double? height;
  final Future<dynamic> Function()? onCancelar;

  @override
  State<EnviarEmailWidget> createState() => _EnviarEmailWidgetState();
}

class _EnviarEmailWidgetState extends State<EnviarEmailWidget>
    with TickerProviderStateMixin {
  List<Map<String, dynamic>> _usuarios = [];
  String? _emailPrincipal;
  List<String> _emailsAdicionais = [];
  List<String> _emailsExtraSelecionados = [];
  bool _loadingUsuarios = true;

  final TextEditingController _patrimonioCtrl = TextEditingController();

  // ─── TENTATIVAS ───
  int _tentativas = 1;

  // ─── DEBOUNCE PATRIMÔNIO ───
  Timer? _debouncePatrimonio;

  Map<String, dynamic>? _equipamento;
  bool _buscandoEquipamento = false;

  String? _motivo;
  // ── MOTIVOS ──────────────────────────────────────────────
  final List<String> _motivos = [
    'Sala trancada',
    'Sala em reunião',
    'Sala em treinamento',
    'Sala em atendimento médico',
    'Não autorizou a entrada da equipe',
    'Em manutenção',
    'Aguardando peça',
  ];

  // ─── DATA E HORÁRIO ───
  DateTime? _dataSelecionada;
  TimeOfDay? _horarioSelecionado;

  String _assunto = '';
  String _msgDisplay = '';
  String _msgHtml = '';

  // ─── EDIÇÃO MANUAL DA MENSAGEM ───────────────────────────
  bool _editandoMensagem = false;
  late final TextEditingController _msgEditCtrl = TextEditingController();

  bool _enviando = false;
  double _progresso = 0.0;
  String _progressoLabel = '';
  bool _enviado = false;

  // ─── ID DO DOCUMENTO SALVO NO FIRESTORE ───
  String? _pendenciaId;

  late final AnimationController _successCtrl;
  late final Animation<double> _successAnim;

  @override
  void initState() {
    super.initState();
    _successCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _successAnim =
        CurvedAnimation(parent: _successCtrl, curve: Curves.elasticOut);
    _carregarUsuarios();
  }

  @override
  void dispose() {
    _patrimonioCtrl.dispose();
    _msgEditCtrl.dispose();
    _debouncePatrimonio?.cancel();
    _successCtrl.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────
  //  CONVERTER TEXTO EDITADO MANUALMENTE → HTML SIMPLES
  // ─────────────────────────────────────────────────────────
  String _textoParaHtml(String texto) {
    return texto
        .split('\n')
        .map((linha) => linha.trim().isEmpty
            ? '<br>'
            : '<p style="margin:0 0 10px 0;font-size:15px;color:#333333;line-height:1.7;font-family:Arial,sans-serif;">$linha</p>')
        .join('');
  }

  // ─────────────────────────────────────────────────────────
  //  CARREGAR USUÁRIOS
  // ─────────────────────────────────────────────────────────
  Future<void> _carregarUsuarios() async {
    try {
      final snap =
          await FirebaseFirestore.instance.collection('USUARIOS').get();
      final List<Map<String, dynamic>> lista = [];
      for (final doc in snap.docs) {
        final data = doc.data();
        final emailP = data['email']?.toString().trim() ?? '';
        if (emailP.isEmpty) continue;
        final nome = data['display_name']?.toString().trim() ?? emailP;
        final List<String> extras = [];
        final field = data['emailteste'];
        if (field is List) {
          for (final e in field) {
            final s = e?.toString().trim() ?? '';
            if (s.isNotEmpty) extras.add(s);
          }
        } else if (field is String && field.trim().isNotEmpty) {
          extras.add(field.trim());
        }
        lista.add({'email': emailP, 'nome': nome, 'emailteste': extras});
      }
      if (mounted) {
        setState(() {
          _usuarios = lista;
          _loadingUsuarios = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingUsuarios = false);
    }
  }

  void _selecionarUsuario(String? email) {
    if (email == null) return;
    final u = _usuarios.firstWhere(
      (u) => u['email'] == email,
      orElse: () => {},
    );
    setState(() {
      _emailPrincipal = email;
      _emailsExtraSelecionados = [];
      _emailsAdicionais = List<String>.from(u['emailteste'] ?? []);
    });
  }

  // ─────────────────────────────────────────────────────────
  //  SELETOR DE DATA
  // ─────────────────────────────────────────────────────────
  Future<void> _selecionarData() async {
    final hoje = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dataSelecionada ?? hoje,
      firstDate: DateTime(hoje.year - 1),
      lastDate: DateTime(hoje.year + 1),
      locale: const Locale('pt', 'BR'),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF1A3C34),
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _dataSelecionada = picked);
      _gerarEmail();
    }
  }

  // ─────────────────────────────────────────────────────────
  //  SELETOR DE HORÁRIO
  // ─────────────────────────────────────────────────────────
  Future<void> _selecionarHorario() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _horarioSelecionado ?? TimeOfDay.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF1A3C34),
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _horarioSelecionado = picked);
      _gerarEmail();
    }
  }

  String get _dataFormatada {
    if (_dataSelecionada == null) return '';
    final d = _dataSelecionada!;
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  String get _horarioFormatado {
    if (_horarioSelecionado == null) return '';
    final h = _horarioSelecionado!;
    return '${h.hour.toString().padLeft(2, '0')}:${h.minute.toString().padLeft(2, '0')}';
  }

  // ─────────────────────────────────────────────────────────
  //  BUSCAR EQUIPAMENTO
  // ─────────────────────────────────────────────────────────
  Future<void> _buscarEquipamento() async {
    final pat = _patrimonioCtrl.text.trim();
    if (pat.isEmpty) {
      _toast('Digite o número do patrimônio');
      return;
    }
    setState(() {
      _buscandoEquipamento = true;
      _equipamento = null;
    });
    try {
      final snap = await FirebaseFirestore.instance
          .collection('EQUIPAMENTOS_EMPRESA')
          .where('PATRIMONIO', isEqualTo: pat)
          .limit(1)
          .get();
      if (!mounted) return;
      if (snap.docs.isEmpty) {
        _toast('Equipamento não encontrado para "$pat"');
        setState(() => _buscandoEquipamento = false);
        return;
      }
      final data = snap.docs.first.data();
      setState(() => _buscandoEquipamento = false);

      final isDark = Theme.of(context).brightness == Brightness.dark;
      final textColor = isDark ? Colors.white : Colors.black87;

      final confirmado = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1E2530) : Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: Row(children: [
            Icon(Icons.inventory_2_outlined, size: 20, color: textColor),
            const SizedBox(width: 8),
            Text('Confirmar Equipamento',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor)),
          ]),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Divider(color: isDark ? Colors.white12 : Colors.black12),
              _rowInfo(
                  Icons.settings, 'Equipamento', data['EQUIPAMENTO'], isDark),
              _rowInfo(
                  Icons.door_front_door_outlined, 'Sala', data['SALA'], isDark),
              _rowInfo(Icons.category_outlined, 'Setor', data['SETOR'], isDark),
              _rowInfo(Icons.person_outline, 'Responsável', data['RESPONSAVEL'],
                  isDark),
            ],
          ),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actions: [
            OutlinedButton(
                onPressed: () => Navigator.pop(ctx, false),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                      color: isDark ? Colors.white24 : Colors.black26),
                ),
                child: Text('Cancelar', style: TextStyle(color: textColor))),
            FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF1A3C34)),
                child: const Text('Confirmar',
                    style: TextStyle(color: Colors.white))),
          ],
        ),
      );
      if (confirmado == true) {
        setState(() => _equipamento = data);
        _gerarEmail();
      }
    } catch (e) {
      if (mounted) setState(() => _buscandoEquipamento = false);
      _toast('Erro: $e');
    }
  }

  // ─────────────────────────────────────────────────────────
  //  GERAR EMAIL
  // ─────────────────────────────────────────────────────────
  void _gerarEmail() {
    if (_equipamento == null || _motivo == null) return;
    final equipNome = _equipamento!['EQUIPAMENTO']?.toString() ?? '-';
    final sala = _equipamento!['SALA']?.toString() ?? '-';
    final setor = _equipamento!['SETOR']?.toString() ?? '-';
    final responsavel = _equipamento!['RESPONSAVEL']?.toString() ?? '-';
    final patrimonio = _patrimonioCtrl.text.trim();
    final dataHora = [
      if (_dataFormatada.isNotEmpty) _dataFormatada,
      if (_horarioFormatado.isNotEmpty) _horarioFormatado,
    ].join(' às ');

    final tentativaTexto =
        _tentativas == 1 ? '1 tentativa' : '$_tentativas tentativas';

    String motivoTexto;
    String detalhe;
    switch (_motivo) {
      case 'Sala trancada':
        motivoTexto = 'sala estava trancada';
        detalhe =
            'Solicitamos que providencie o acesso ao local para que possamos reagendar e executar a manutenção o mais breve possível.';
        break;
      case 'Sala em reunião':
        motivoTexto = 'sala estava em reunião';
        detalhe =
            'Solicitamos que nos indique um horário mais adequado para que possamos reagendar a manutenção sem causar interrupções.';
        break;
      case 'Sala em treinamento':
        motivoTexto = 'sala estava sendo utilizada para treinamento';
        detalhe =
            'Solicitamos que nos comunique a disponibilidade do espaço para que possamos reagendar a visita técnica.';
        break;
      case 'Sala em atendimento médico':
        motivoTexto = 'sala estava sendo utilizada para atendimento médico';
        detalhe =
            'Solicitamos que nos indique um horário mais adequado para que possamos reagendar a manutenção sem interromper os atendimentos.';
        break;
      case 'Não autorizou a entrada da equipe':
        motivoTexto = 'entrada da equipe técnica não foi autorizada';
        detalhe =
            'Solicitamos que providencie a autorização necessária para que possamos reagendar e executar o serviço adequadamente.';
        break;
      case 'Em manutenção':
        motivoTexto = 'Equipamento em manutenção.';
        detalhe =
            'Informamos que o equipamento está em manutenção e inoperante, tem uma o.s aberta que está em andamento.';
        break;
      case 'Aguardando peça':
        motivoTexto =
            'manutenção preventiva não pôde ser concluída pois o equipamento está aguardando a chegada de peça(s) de reposição';
        detalhe =
            'Após a instalação da(s) peça(s) daremos prosseguimento a manutenção preventiva.';
        break;
      default:
        motivoTexto = _motivo!.toLowerCase();
        detalhe = 'Solicitamos o reagendamento para a execução do serviço.';
    }

    final dataHoraDisplay =
        dataHora.isNotEmpty ? '\nData/Horário da visita: $dataHora' : '';
    final dataHoraHtml = dataHora.isNotEmpty
        ? '<tr><td style="padding:10px 14px;font-weight:bold;color:#374151;">Data / Horário</td><td style="padding:10px 14px;color:#1f2937;">$dataHora</td></tr>'
        : '';

    final bool usaMotivoCustom =
        _motivo == 'Em manutenção' || _motivo == 'Aguardando peça';

    final String tentativasHtml = usaMotivoCustom
        ? ''
        : '''
  <tr style="background:#f8fafc;">
    <td style="padding:10px 14px;font-weight:bold;color:#374151;border-bottom:1px solid #e2e8f0;">Tentativas de Acesso</td>
    <td style="padding:10px 14px;color:#1f2937;border-bottom:1px solid #e2e8f0;">$tentativaTexto</td>
  </tr>''';

    final String paragrafoIntroHtml = usaMotivoCustom
        ? '''<p style="margin:0 0 20px 0;font-size:15px;color:#333333;line-height:1.7;font-family:Arial,sans-serif;">
  Informamos que a manutenção preventiva do equipamento
  <strong>$equipNome</strong> (Patrimônio: <strong>$patrimonio</strong>),
  localizado na <strong>sala $sala</strong>, setor <strong>$setor</strong>,
  <span style="color:#c0392b;font-weight:bold;">NÃO PÔDE SER REALIZADA</span>
  pois $motivoTexto.
</p>'''
        : '''<p style="margin:0 0 20px 0;font-size:15px;color:#333333;line-height:1.7;font-family:Arial,sans-serif;">
  Informamos que a manutenção preventiva do equipamento
  <strong>$equipNome</strong> (Patrimônio: <strong>$patrimonio</strong>),
  localizado na <strong>sala $sala</strong>, setor <strong>$setor</strong>,
  <span style="color:#c0392b;font-weight:bold;">NÃO PÔDE SER REALIZADA</span>
  pois a&nbsp;$motivoTexto no momento da visita técnica.
</p>''';

    final newMsgDisplay = usaMotivoCustom
        ? 'Prezados,\n\n'
            'Informamos que a manutenção preventiva do equipamento $equipNome '
            '(Patrimônio: $patrimonio), localizado na sala $sala, setor $setor, '
            'NÃO PÔDE SER REALIZADA pois $motivoTexto.$dataHoraDisplay\n\n'
            '$detalhe'
        : 'Prezados,\n\n'
            'Informamos que a manutenção preventiva do equipamento $equipNome '
            '(Patrimônio: $patrimonio), localizado na sala $sala, setor $setor, '
            'NÃO PÔDE SER REALIZADA pois a $motivoTexto no momento da visita técnica.$dataHoraDisplay\n'
            'Número de tentativas de acesso: $tentativaTexto\n\n'
            '$detalhe';

    setState(() {
      _assunto = 'Manutenção Preventiva Não Realizada';
      _msgDisplay = newMsgDisplay;
      if (!_editandoMensagem) {
        _msgEditCtrl.text = newMsgDisplay;
      }
      _msgHtml = '''
<p style="margin:0 0 6px 0;font-size:15px;color:#333333;font-family:Arial,sans-serif;">Prezados,</p>
$paragrafoIntroHtml

<table width="100%" cellpadding="0" cellspacing="0" border="0"
       style="border-collapse:collapse;border-radius:8px;overflow:hidden;border:1px solid #e2e8f0;margin-bottom:20px;font-size:14px;font-family:Arial,sans-serif;">
  <tr>
    <td colspan="2" style="background:#1A3C34;padding:10px 14px;">
      <span style="color:#ffffff;font-size:13px;font-weight:bold;letter-spacing:0.5px;">DETALHES DA OCORRÊNCIA</span>
    </td>
  </tr>
  <tr style="background:#f8fafc;">
    <td style="padding:10px 14px;font-weight:bold;color:#374151;width:160px;border-bottom:1px solid #e2e8f0;">Equipamento</td>
    <td style="padding:10px 14px;color:#1f2937;border-bottom:1px solid #e2e8f0;">$equipNome</td>
  </tr>
  <tr>
    <td style="padding:10px 14px;font-weight:bold;color:#374151;border-bottom:1px solid #e2e8f0;">Patrimônio</td>
    <td style="padding:10px 14px;color:#1f2937;border-bottom:1px solid #e2e8f0;">$patrimonio</td>
  </tr>
  <tr style="background:#f8fafc;">
    <td style="padding:10px 14px;font-weight:bold;color:#374151;border-bottom:1px solid #e2e8f0;">Sala</td>
    <td style="padding:10px 14px;color:#1f2937;border-bottom:1px solid #e2e8f0;">$sala</td>
  </tr>
  <tr>
    <td style="padding:10px 14px;font-weight:bold;color:#374151;border-bottom:1px solid #e2e8f0;">Setor</td>
    <td style="padding:10px 14px;color:#1f2937;border-bottom:1px solid #e2e8f0;">$setor</td>
  </tr>
  <tr style="background:#f8fafc;">
    <td style="padding:10px 14px;font-weight:bold;color:#374151;border-bottom:1px solid #e2e8f0;">Responsável</td>
    <td style="padding:10px 14px;color:#1f2937;border-bottom:1px solid #e2e8f0;">$responsavel</td>
  </tr>
  <tr>
    <td style="padding:10px 14px;font-weight:bold;color:#374151;border-bottom:1px solid #e2e8f0;">Motivo</td>
    <td style="padding:10px 14px;color:#c0392b;font-weight:bold;border-bottom:1px solid #e2e8f0;">$_motivo</td>
  </tr>
  $tentativasHtml
  $dataHoraHtml
</table>

<table width="100%" cellpadding="0" cellspacing="0" border="0"
       style="background:#f0fdf4;border-left:4px solid #1A3C34;border-radius:0 6px 6px 0;margin-bottom:8px;">
  <tr>
    <td style="padding:12px 16px;font-size:14px;color:#1A3C34;line-height:1.6;font-family:Arial,sans-serif;">
      i&nbsp;&nbsp;$detalhe
    </td>
  </tr>
</table>''';
    });
  }

  // ─────────────────────────────────────────────────────────
  //  SALVAR PENDÊNCIA NO FIRESTORE
  // ─────────────────────────────────────────────────────────
  Future<String> _salvarPendencia() async {
    Timestamp? timestampVisita;
    if (_dataSelecionada != null && _horarioSelecionado != null) {
      final dt = DateTime(
        _dataSelecionada!.year,
        _dataSelecionada!.month,
        _dataSelecionada!.day,
        _horarioSelecionado!.hour,
        _horarioSelecionado!.minute,
      );
      timestampVisita = Timestamp.fromDate(dt);
    } else if (_dataSelecionada != null) {
      timestampVisita = Timestamp.fromDate(_dataSelecionada!);
    }

    final mensagemFinal =
        _editandoMensagem ? _msgEditCtrl.text.trim() : _msgDisplay;

    final docRef =
        await FirebaseFirestore.instance.collection('PENDENCIAS').add({
      'criadoEm': FieldValue.serverTimestamp(),
      'atualizadoEm': FieldValue.serverTimestamp(),
      'status': 'pendente',
      'emailPrincipal': _emailPrincipal ?? '',
      'emailsAdicionais': _emailsExtraSelecionados,
      'assunto': _assunto,
      'mensagemTexto': mensagemFinal,
      'mensagemEditadaManualmente': _editandoMensagem,
      'patrimonio': _patrimonioCtrl.text.trim(),
      'equipamento': _equipamento!['EQUIPAMENTO']?.toString() ?? '',
      'sala': _equipamento!['SALA']?.toString() ?? '',
      'setor': _equipamento!['SETOR']?.toString() ?? '',
      'responsavel': _equipamento!['RESPONSAVEL']?.toString() ?? '',
      'motivo': _motivo ?? '',
      'tentativas': _tentativas,
      'dataVisitaFormatada': _dataFormatada.isNotEmpty ? _dataFormatada : null,
      'horarioVisitaFormatado':
          _horarioFormatado.isNotEmpty ? _horarioFormatado : null,
      'dataHoraVisitaTexto': [
        if (_dataFormatada.isNotEmpty) _dataFormatada,
        if (_horarioFormatado.isNotEmpty) _horarioFormatado,
      ].join(' às '),
      'timestampVisita': timestampVisita,
      'remetente': 'equipe@hpsrefri.com.br',
      'remetenteNome': 'Huagner Pires',
      'resolvidoEm': null,
      'resolvidoPor': null,
      'observacaoResolucao': null,
    });

    return docRef.id;
  }

  Future<void> _criarNotificacaoFirebase({
    required String email,
    required String equipamento,
    required String motivo,
    required String sala,
  }) async {
    if (email.isEmpty) return;
    try {
      await FirebaseFirestore.instance.collection('NOTIFICACAO').add({
        'email': email,
        'titulo': '⚠️ Pendência de Manutenção',
        'mensagem':
            'Manutenção preventiva NÃO REALIZADA no equipamento $equipamento '
                '— Sala: $sala. Motivo: $motivo.',
        'tipo': 'alerta',
        'visto': false,
        'data': Timestamp.now(),
        'status': 'pendente',
        'os': '',
      });
    } catch (e) {
      debugPrint('Erro ao criar notificação Firebase: $e');
    }
  }

  // ─────────────────────────────────────────────────────────
  //  ENVIAR EMAIL + SALVAR PENDÊNCIA
  // ─────────────────────────────────────────────────────────
  Future<void> _enviar() async {
    if (_emailPrincipal == null) {
      _toast('Selecione o email principal do cliente');
      return;
    }

    if (_emailsExtraSelecionados.isEmpty) {
      _toast(
          'Selecione pelo menos um e-mail adicional para receber a notificação');
      return;
    }

    if (_equipamento == null) {
      _toast('Confirme o equipamento pelo patrimônio');
      return;
    }
    if (_motivo == null) {
      _toast('Selecione o motivo');
      return;
    }

    String htmlParaEnvio;
    if (_editandoMensagem) {
      final textoEditado = _msgEditCtrl.text.trim();
      htmlParaEnvio = _textoParaHtml(textoEditado);
      setState(() {
        _msgDisplay = textoEditado;
        _editandoMensagem = false;
      });
    } else {
      htmlParaEnvio = _msgHtml;
    }

    setState(() {
      _enviando = true;
      _progresso = 0.0;
      _progressoLabel = 'Preparando email...';
    });

    try {
      await _step(0.15, 'Preparando email...');
      await _step(0.40, 'Conectando ao servidor...');
      await _step(0.60, 'Enviando mensagem...');

      final destinatarios = [..._emailsExtraSelecionados];

      await _sendEmail(
        toEmails: destinatarios,
        ccEmails: ['equipe@hpsrefri.com.br'],
        subject: _assunto,
        message: htmlParaEnvio,
      );

      await _step(0.75, 'Salvando pendência no sistema...');

      final docId = await _salvarPendencia();
      setState(() => _pendenciaId = docId);

      await _step(0.88, 'Criando notificação...');
      if (_equipamento != null) {
        await _criarNotificacaoFirebase(
          email: _emailPrincipal ?? '',
          equipamento: _equipamento!['EQUIPAMENTO']?.toString() ?? '',
          motivo: _motivo ?? '',
          sala: _equipamento!['SALA']?.toString() ?? '',
        );
      }

      await _step(1.0, 'Concluído!');
      if (!mounted) return;

      setState(() {
        _enviado = true;
        _enviando = false;
      });
      _successCtrl.forward();

      await Future.delayed(const Duration(milliseconds: 2800));
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        setState(() {
          _enviando = false;
          _progresso = 0.0;
        });
        _toast('Erro ao enviar: $e');
      }
    }
  }

  Future<void> _step(double alvo, String label) async {
    if (!mounted) return;
    setState(() => _progressoLabel = label);
    final ini = _progresso;
    final delta = alvo - ini;
    for (int i = 1; i <= 20; i++) {
      await Future.delayed(const Duration(milliseconds: 20));
      if (!mounted) return;
      setState(() => _progresso = ini + delta * (i / 20));
    }
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), duration: const Duration(seconds: 3)));
  }

  // ─────────────────────────────────────────────────────────
  //  HELPERS DE UI
  // ─────────────────────────────────────────────────────────
  Widget _rowInfo(IconData icon, String label, dynamic value, bool isDark) {
    final textColor = isDark ? Colors.white : Colors.black87;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, size: 17, color: Colors.blueGrey),
        const SizedBox(width: 8),
        Text('$label: ',
            style: TextStyle(
                fontWeight: FontWeight.w600, fontSize: 14, color: textColor)),
        Expanded(
            child: Text(value?.toString() ?? '-',
                style: TextStyle(fontSize: 14, color: textColor))),
      ]),
    );
  }

  Widget _chip(String label, dynamic value, bool isDark) {
    final textColor = isDark ? Colors.white : Colors.black87;
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('$label: ',
            style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w600, color: textColor)),
        Expanded(
            child: Text(value?.toString() ?? '-',
                style: TextStyle(fontSize: 13, color: textColor))),
      ]),
    );
  }

  Widget _badge(String label, Color cor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
          color: cor.withAlpha(30), borderRadius: BorderRadius.circular(4)),
      child: Text(label,
          style:
              TextStyle(fontSize: 10, color: cor, fontWeight: FontWeight.w600)),
    );
  }

  InputDecoration _input(String hint, bool isDark) {
    final border = isDark ? Colors.white12 : Colors.black12;
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: isDark ? Colors.white54 : Colors.black54),
      filled: true,
      fillColor: isDark ? const Color(0xFF252D3A) : const Color(0xFFF4F6F8),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: border)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: border)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF1A3C34), width: 1.8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    );
  }

  Widget _seletorBtn({
    required IconData icon,
    required String label,
    required String valor,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    const verde = Color(0xFF1A3C34);
    final temValor = valor.isNotEmpty;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF252D3A) : const Color(0xFFF4F6F8),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color:
                  temValor ? verde : (isDark ? Colors.white12 : Colors.black12),
              width: temValor ? 1.6 : 1.0),
        ),
        child: Row(children: [
          Icon(icon, size: 18, color: temValor ? verde : Colors.grey),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              temValor ? valor : label,
              style: TextStyle(
                fontSize: 14,
                color: temValor
                    ? (isDark ? Colors.white : Colors.black87)
                    : Colors.grey,
                fontStyle: temValor ? FontStyle.normal : FontStyle.italic,
              ),
            ),
          ),
          if (temValor)
            GestureDetector(
              onTap: () => setState(() {
                if (icon == Icons.calendar_today_outlined) {
                  _dataSelecionada = null;
                } else {
                  _horarioSelecionado = null;
                }
                _gerarEmail();
              }),
              child: const Icon(Icons.close, size: 16, color: Colors.grey),
            ),
        ]),
      ),
    );
  }

  Widget _seletorTentativas(bool isDark) {
    const verde = Color(0xFF1A3C34);
    final borderColor = isDark ? Colors.white12 : Colors.black12;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF252D3A) : const Color(0xFFF4F6F8),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor),
      ),
      child: Row(children: [
        InkWell(
          onTap: _tentativas > 1
              ? () {
                  setState(() => _tentativas--);
                  _gerarEmail();
                }
              : null,
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(10), bottomLeft: Radius.circular(10)),
          child: Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            child: Icon(Icons.remove,
                size: 20,
                color: _tentativas > 1 ? verde : Colors.grey.shade400),
          ),
        ),
        Container(width: 1, height: 32, color: borderColor),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$_tentativas',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              Text(
                _tentativas == 1 ? 'tentativa' : 'tentativas',
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
        ),
        Container(width: 1, height: 32, color: borderColor),
        InkWell(
          onTap: _tentativas < 10
              ? () {
                  setState(() => _tentativas++);
                  _gerarEmail();
                }
              : null,
          borderRadius: const BorderRadius.only(
              topRight: Radius.circular(10), bottomRight: Radius.circular(10)),
          child: Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            child: Icon(Icons.add,
                size: 20,
                color: _tentativas < 10 ? verde : Colors.grey.shade400),
          ),
        ),
      ]),
    );
  }

  // ─────────────────────────────────────────────────────────
  //  BUILD
  // ─────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    const isDark = true;
    const cardColor = Color(0xFF0B0F17);
    const borderColor = Color(0x1FFFFFFF);
    const primaryTextColor = Colors.white;
    const verde = Color(0xFF1A3C34);

    if (_enviado) {
      final enviados = <String>[
        ..._emailsExtraSelecionados,
        'equipe@hpsrefri.com.br (CC)'
      ];
      return SafeArea(
        child: Container(
        width: widget.width,
        padding: EdgeInsets.fromLTRB(
            36, 36, 36, 36 + MediaQuery.of(context).padding.bottom),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withAlpha(25), blurRadius: 20)
          ],
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ScaleTransition(
            scale: _successAnim,
            child: Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.green.shade300, width: 3)),
              child: const Icon(Icons.mark_email_read_rounded,
                  color: Colors.green, size: 46),
            ),
          ),
          const SizedBox(height: 22),
          const Text('Email enviado com sucesso!',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green)),
          const SizedBox(height: 10),
          Text(
            'Enviado para:\n${enviados.join("\n")}',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.white54 : Colors.black54,
                height: 1.6),
          ),
          const SizedBox(height: 14),
          if (_pendenciaId != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                  color: verde.withAlpha(20),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: verde.withAlpha(64))),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.cloud_done_outlined, size: 16, color: verde),
                const SizedBox(width: 8),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Pendência registrada no sistema',
                      style: TextStyle(
                          fontSize: 12,
                          color: verde,
                          fontWeight: FontWeight.w600)),
                  Text('ID: $_pendenciaId',
                      style: const TextStyle(fontSize: 10, color: Colors.grey)),
                ]),
              ]),
            ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
                color: Colors.green.withAlpha(20),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.green.shade600)),
              const SizedBox(width: 10),
              Text('Fechando automaticamente...',
                  style: TextStyle(
                      fontSize: 13,
                      color: Colors.green.shade600,
                      fontWeight: FontWeight.w500)),
            ]),
          ),
        ]),
      ),
      );
    }

    final form = SafeArea(
      child: Container(
      width: widget.width,
      padding: EdgeInsets.fromLTRB(
          20, 20, 20, 20 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withAlpha(isDark ? 100 : 20),
              blurRadius: 20,
              offset: const Offset(0, 4))
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                'https://firebasestorage.googleapis.com/v0/b/h-p-s-modificado-emdcp0.appspot.com/o/Gemini_Generated_Image_2xpdsd2xpdsd2xpd%20(1).png?alt=media&token=be3e052e-a0b8-4e8c-8151-b9365b507ed5',
                width: double.infinity,
                height: 120,
                fit: BoxFit.cover,
                loadingBuilder: (_, child, prog) => prog == null
                    ? child
                    : Container(
                        height: 120,
                        color: verde.withAlpha(25),
                        child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 2))),
                errorBuilder: (_, __, ___) => Container(
                  height: 80,
                  decoration: BoxDecoration(
                      color: verde, borderRadius: BorderRadius.circular(12)),
                  child: const Center(
                      child: Text('HPS Refrigeração',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18))),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                  color: verde.withAlpha(isDark ? 38 : 18),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: verde.withAlpha(46))),
              child: Row(children: [
                CircleAvatar(
                    radius: 18,
                    backgroundColor: verde,
                    child: const Text('H',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15))),
                const SizedBox(width: 10),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Huagner Pires',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: primaryTextColor)),
                  Text('equipe@hpsrefri.com.br',
                      style: TextStyle(
                          fontSize: 12,
                          color:
                              isDark ? Colors.white54 : Colors.grey.shade500)),
                ]),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                      color: verde, borderRadius: BorderRadius.circular(12)),
                  child: const Text('Remetente',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600)),
                ),
              ]),
            ),
            const SizedBox(height: 12),
            Center(
                child: Text('Notificação de manutenção não realizada',
                    style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white54 : Colors.black54))),
            const SizedBox(height: 14),
            Divider(color: borderColor),
            const SizedBox(height: 12),
            Text('Cliente (Email Principal)',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: primaryTextColor)),
            const SizedBox(height: 4),
            const Text('Selecione para carregar a lista de e-mails',
                style: TextStyle(fontSize: 11, color: Colors.grey)),
            const SizedBox(height: 6),
            _loadingUsuarios
                ? const Center(
                    child: Padding(
                        padding: EdgeInsets.all(12),
                        child: CircularProgressIndicator(strokeWidth: 2)))
                : DropdownButtonFormField<String>(
                    value: _emailPrincipal,
                    hint: Text('Selecione o cliente',
                        style: TextStyle(
                            color: isDark ? Colors.white54 : Colors.black54)),
                    isExpanded: true,
                    decoration: _input('Selecione o cliente', isDark),
                    dropdownColor:
                        isDark ? const Color(0xFF252D3A) : Colors.white,
                    style: TextStyle(color: primaryTextColor),
                    items: _usuarios.map((u) {
                      final email = u['email']?.toString() ?? '';
                      final nome = u['nome']?.toString() ?? email;
                      return DropdownMenuItem<String>(
                        value: email,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(nome,
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: primaryTextColor),
                                overflow: TextOverflow.ellipsis),
                            Text(email,
                                style: TextStyle(
                                    fontSize: 12,
                                    color: isDark
                                        ? Colors.white54
                                        : Colors.grey.shade500),
                                overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: _selecionarUsuario,
                  ),
            const SizedBox(height: 16),
            if (_emailPrincipal != null) ...[
              Row(children: [
                Text('Destinatários (Para)',
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: primaryTextColor)),
                const SizedBox(width: 8),
                if (_emailsExtraSelecionados.isNotEmpty)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                        color: verde, borderRadius: BorderRadius.circular(10)),
                    child: Text('+${_emailsExtraSelecionados.length}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600)),
                  ),
              ]),
              const SizedBox(height: 4),
              const Text('Marque os e-mails que vão receber a notificação',
                  style: TextStyle(fontSize: 11, color: Colors.grey)),
              const SizedBox(height: 6),
              _emailsAdicionais.isEmpty
                  ? Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF252D3A)
                              : const Color(0xFFF4F6F8),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: borderColor)),
                      child: const Text('Nenhum email adicional cadastrado',
                          style: TextStyle(fontSize: 13, color: Colors.grey)),
                    )
                  : Container(
                      decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF252D3A)
                              : const Color(0xFFF4F6F8),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: borderColor)),
                      child: Column(
                        children: List.generate(
                          _emailsAdicionais.length,
                          (idx) {
                            final email = _emailsAdicionais[idx];
                            final sel =
                                _emailsExtraSelecionados.contains(email);
                            final isFirst = idx == 0;
                            final isLast = idx == _emailsAdicionais.length - 1;
                            return Column(children: [
                              if (!isFirst)
                                Divider(height: 1, color: borderColor),
                              InkWell(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(isFirst ? 10 : 0),
                                  topRight: Radius.circular(isFirst ? 10 : 0),
                                  bottomLeft: Radius.circular(isLast ? 10 : 0),
                                  bottomRight: Radius.circular(isLast ? 10 : 0),
                                ),
                                onTap: () => setState(() {
                                  if (sel) {
                                    _emailsExtraSelecionados.remove(email);
                                  } else {
                                    _emailsExtraSelecionados.add(email);
                                  }
                                }),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 11),
                                  child: Row(children: [
                                    AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 200),
                                      width: 22,
                                      height: 22,
                                      decoration: BoxDecoration(
                                        color: sel ? verde : Colors.transparent,
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                            color: sel
                                                ? verde
                                                : (isDark
                                                    ? Colors.white30
                                                    : Colors.grey.shade400),
                                            width: 2),
                                      ),
                                      child: sel
                                          ? const Icon(Icons.check,
                                              color: Colors.white, size: 14)
                                          : null,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(email,
                                          style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: sel
                                                  ? FontWeight.w600
                                                  : FontWeight.normal,
                                              color: sel
                                                  ? verde
                                                  : primaryTextColor)),
                                    ),
                                  ]),
                                ),
                              ),
                            ]);
                          },
                        ),
                      ),
                    ),
              const SizedBox(height: 16),
            ],
            Text('Patrimônio',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: primaryTextColor)),
            const SizedBox(height: 6),
            Row(children: [
              Expanded(
                child: TextFormField(
                  controller: _patrimonioCtrl,
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: primaryTextColor),
                  decoration: _input('Digite o número do equipamento', isDark),
                  onChanged: (val) {
                    _debouncePatrimonio?.cancel();
                    if (val.trim().isEmpty) {
                      setState(() => _equipamento = null);
                      return;
                    }
                    _debouncePatrimonio = Timer(
                      const Duration(milliseconds: 600),
                      _buscarEquipamento,
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _buscandoEquipamento ? null : _buscarEquipamento,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: verde,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10))),
                  child: _buscandoEquipamento
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.search, color: Colors.white),
                ),
              ),
            ]),
            if (_equipamento != null) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: Colors.green.withAlpha(isDark ? 38 : 20),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.green.shade400, width: 1)),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 16),
                        SizedBox(width: 6),
                        Text('Equipamento confirmado',
                            style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                                fontSize: 13)),
                      ]),
                      const SizedBox(height: 8),
                      _chip(
                          'Equipamento', _equipamento!['EQUIPAMENTO'], isDark),
                      _chip('Sala', _equipamento!['SALA'], isDark),
                      _chip('Setor', _equipamento!['SETOR'], isDark),
                      _chip(
                          'Responsável', _equipamento!['RESPONSAVEL'], isDark),
                    ]),
              ),
            ],
            const SizedBox(height: 16),
            Text('Motivo',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: primaryTextColor)),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: _motivo,
              hint: Text('Selecione o motivo',
                  style: TextStyle(
                      color: isDark ? Colors.white54 : Colors.black54)),
              isExpanded: true,
              decoration: _input('Selecione o motivo', isDark),
              dropdownColor: isDark ? const Color(0xFF252D3A) : Colors.white,
              style: TextStyle(color: primaryTextColor),
              items: _motivos
                  .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                  .toList(),
              onChanged: (v) {
                setState(() {
                  _motivo = v;
                  _editandoMensagem = false;
                });
                _gerarEmail();
              },
            ),
            const SizedBox(height: 16),
            if (_motivo != 'Em manutenção' && _motivo != 'Aguardando peça') ...[
              Row(children: [
                Text('Tentativas de Acesso',
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: primaryTextColor)),
                const SizedBox(width: 8),
                _badge('automático no email', Colors.orange.shade700),
              ]),
              const SizedBox(height: 4),
              const Text('Quantas vezes a equipe tentou acessar o equipamento',
                  style: TextStyle(fontSize: 11, color: Colors.grey)),
              const SizedBox(height: 8),
              _seletorTentativas(isDark),
              const SizedBox(height: 16),
            ],
            Text('Data e Horário da Visita',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: primaryTextColor)),
            const SizedBox(height: 6),
            Row(children: [
              Expanded(
                child: _seletorBtn(
                  icon: Icons.calendar_today_outlined,
                  label: 'Selecionar data',
                  valor: _dataFormatada,
                  onTap: _selecionarData,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _seletorBtn(
                  icon: Icons.access_time_outlined,
                  label: 'Selecionar horário',
                  valor: _horarioFormatado,
                  onTap: _selecionarHorario,
                  isDark: isDark,
                ),
              ),
            ]),
            const SizedBox(height: 16),
            Row(children: [
              Text('Assunto',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: primaryTextColor)),
              const SizedBox(width: 6),
              _badge('automático', verde),
            ]),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF252D3A)
                      : const Color(0xFFF4F6F8),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: borderColor)),
              child: Text(
                _assunto.isEmpty
                    ? 'Manutenção Preventiva Não Realizada'
                    : _assunto,
                style: TextStyle(
                    fontSize: 14,
                    color: _assunto.isEmpty ? Colors.grey : primaryTextColor,
                    fontStyle:
                        _assunto.isEmpty ? FontStyle.italic : FontStyle.normal),
              ),
            ),
            const SizedBox(height: 16),
            Row(children: [
              Text('Mensagem',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: primaryTextColor)),
              const SizedBox(width: 6),
              _editandoMensagem
                  ? _badge('editando manualmente', Colors.orange.shade700)
                  : _badge('automática', verde),
              const Spacer(),
              if (_msgDisplay.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    if (_editandoMensagem) {
                      setState(() {
                        _editandoMensagem = false;
                        _msgEditCtrl.text = _msgDisplay;
                      });
                    } else {
                      setState(() {
                        _msgEditCtrl.text = _msgDisplay;
                        _editandoMensagem = true;
                      });
                    }
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _editandoMensagem
                          ? Colors.orange.withAlpha(25)
                          : verde.withAlpha(20),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _editandoMensagem
                            ? Colors.orange.shade300
                            : verde.withAlpha(76),
                      ),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(
                        _editandoMensagem
                            ? Icons.restart_alt_rounded
                            : Icons.edit_outlined,
                        size: 13,
                        color:
                            _editandoMensagem ? Colors.orange.shade700 : verde,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _editandoMensagem ? 'Restaurar' : 'Editar',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _editandoMensagem
                              ? Colors.orange.shade700
                              : verde,
                        ),
                      ),
                    ]),
                  ),
                ),
            ]),
            const SizedBox(height: 6),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              child: _editandoMensagem
                  ? TextFormField(
                      key: const ValueKey('msg_edit'),
                      controller: _msgEditCtrl,
                      maxLines: null,
                      minLines: 6,
                      style: TextStyle(
                          fontSize: 13, color: primaryTextColor, height: 1.6),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: isDark
                            ? const Color(0xFF252D3A)
                            : const Color(0xFFF4F6F8),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                BorderSide(color: Colors.orange.shade300)),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                BorderSide(color: Colors.orange.shade300)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                                color: Colors.orange.shade600, width: 1.8)),
                        contentPadding: const EdgeInsets.all(12),
                        hintText: 'Digite a mensagem personalizada...',
                        hintStyle: const TextStyle(color: Colors.grey),
                      ),
                    )
                  : Container(
                      key: const ValueKey('msg_display'),
                      width: double.infinity,
                      constraints: const BoxConstraints(minHeight: 100),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF252D3A)
                              : const Color(0xFFF4F6F8),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: borderColor)),
                      child: Text(
                        _msgDisplay.isEmpty
                            ? 'A mensagem será gerada após confirmar o equipamento e selecionar o motivo...'
                            : _msgDisplay,
                        style: TextStyle(
                            fontSize: 13,
                            color: _msgDisplay.isEmpty
                                ? Colors.grey
                                : primaryTextColor,
                            fontStyle: _msgDisplay.isEmpty
                                ? FontStyle.italic
                                : FontStyle.normal,
                            height: 1.6),
                      ),
                    ),
            ),
            const SizedBox(height: 24),
            Row(children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.onCancelar != null
                      ? () => widget.onCancelar!()
                      : null,
                  style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      side: BorderSide(
                          color: isDark ? Colors.white24 : Colors.black26)),
                  child: Text('Cancelar',
                      style: TextStyle(color: primaryTextColor)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.send_rounded,
                      size: 16, color: Colors.white),
                  label: const Text('Enviar Email',
                      style: TextStyle(color: Colors.white)),
                  onPressed: _enviando ? null : _enviar,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: verde,
                      elevation: 1,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10))),
                ),
              ),
            ]),
          ],
        ),
      ),
    ),
    );

    if (_enviando) {
      return Stack(children: [
        form,
        Positioned.fill(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              color: Colors.black.withAlpha(140),
              child: Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 32),
                  padding: const EdgeInsets.all(26),
                  decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withAlpha(76), blurRadius: 24)
                      ]),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Container(
                      width: 66,
                      height: 66,
                      decoration: BoxDecoration(
                          color: verde.withAlpha(30), shape: BoxShape.circle),
                      child: const Icon(Icons.email_outlined,
                          color: verde, size: 34),
                    ),
                    const SizedBox(height: 16),
                    Text('Enviando Email',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: primaryTextColor)),
                    const SizedBox(height: 6),
                    Text(_progressoLabel,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 13,
                            color: isDark ? Colors.white54 : Colors.black54)),
                    const SizedBox(height: 20),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: _progresso,
                        minHeight: 10,
                        backgroundColor:
                            isDark ? Colors.white12 : Colors.grey.shade200,
                        valueColor: const AlwaysStoppedAnimation<Color>(verde),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '${(_progresso * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(
                            fontSize: 12,
                            color: verde,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ]),
                ),
              ),
            ),
          ),
        ),
      ]);
    }

    return form;
  }
}
