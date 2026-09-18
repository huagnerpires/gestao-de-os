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

import '/custom_code/widgets/index.dart';
import '/custom_code/actions/index.dart';
import '/flutter_flow/custom_functions.dart';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';

class UploadModerno extends StatefulWidget {
  const UploadModerno({
    Key? key,
    this.width,
    this.height,
    this.larguraEmail = 1000.0,
  }) : super(key: key);

  final double? width;
  final double? height;
  final double larguraEmail;

  @override
  State<UploadModerno> createState() => _UploadModernoState();
}

class _UploadModernoState extends State<UploadModerno> {
  // ── Constantes ───────────────────────────────────────────────
  static const _senderEmail = 'equipe@hpsrefri.com.br';
  static const _senderName = 'HPS Refrigeração';
  static const _emailHPS = 'hpsrefri@gmail.com';
  static const _bannerUrl =
      'https://firebasestorage.googleapis.com/v0/b/h-p-s-modificado-emdcp0.appspot.com/o/Gemini_Generated_Image_2xpdsd2xpdsd2xpd%20(1).png?alt=media&token=be3e052e-a0b8-4e8c-8151-b9365b507ed5';
  static const _osAppId = '7b01186f-cf76-4b5d-8354-87d83737d40c';
  static const _osApiKey = 'ZTdlNjIwZWItMjEyMC00M2RhLWJlZmYtMzc2NTBmNzNmMDdj';
  static const _osChannel = '577bba44-d1bf-4ac9-9d11-20d89e09a61a';

  // ── Estado ───────────────────────────────────────────────────
  String? selEmail;
  String? selDocId;
  String? selNomeCliente;
  List<String> emailsTeste = [];
  Set<String> emailsSelecionados = {};
  List<Map<String, dynamic>> osDoUsuario = [];

  String? selTipo;
  String? selMes;
  PlatformFile? selFile;

  List<Map<String, String>> usuarios = [];
  bool carregando = true;
  bool enviando = false;
  bool buscandoOS = false;
  bool osEncontrada = false;
  double prog = 0;
  String progLabel = '';
  bool ok = false;
  String? erro;

  final _outrosCtrl = TextEditingController();
  final _obsCtrl = TextEditingController();
  bool _showOutrosField = false;

  final _numeroOSCtrl = TextEditingController();
  final _valorCtrl = TextEditingController();
  final _servicoCtrl = TextEditingController();
  final _pecasCtrl = TextEditingController();

  // ── Formulário de recebimento encontrado ─────────────────────
  String? _formularioUrl;
  String? _formularioNome;
  bool _buscandoFormulario = false;
  bool _enviarFormularioJunto = false;

  // ── Mês para filtrar OS ───────────────────────────────────────
  String? selMesOS;
  bool _buscandoOsLista = false;

  final _tipos = [
    'NOTA FISCAL DE SERVIÇO',
    'NOTA FISCAL PREVENTIVAS',
    'NOTA FISCAL DE PRODUTOS',
    'ORDEM DE SERVIÇO',
    'ORÇAMENTO',
    'OUTROS',
  ];

  final _meses = [
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
    'Dezembro',
  ];

  String get _ano => DateTime.now().year.toString();

  String get _tipoFinal {
    if (selTipo == 'OUTROS') {
      final txt = _outrosCtrl.text.trim().toUpperCase();
      return txt.isEmpty ? 'OUTROS' : txt;
    }
    return selTipo ?? '';
  }

  bool get _pronto =>
      selEmail != null &&
      selTipo != null &&
      (selTipo != 'OUTROS' || _outrosCtrl.text.trim().isNotEmpty) &&
      selMes != null &&
      selFile != null &&
      !enviando;

  @override
  void initState() {
    super.initState();
    selMes = _meses[DateTime.now().month - 1];
    _carregar();
  }

  @override
  void dispose() {
    _outrosCtrl.dispose();
    _obsCtrl.dispose();
    _numeroOSCtrl.dispose();
    _valorCtrl.dispose();
    _servicoCtrl.dispose();
    _pecasCtrl.dispose();
    super.dispose();
  }

  // ── Helpers ──────────────────────────────────────────────────
  String _strVal(dynamic v) {
    if (v == null) return '';
    if (v is List) return v.join(', ');
    return v.toString().trim();
  }

  String _valorStr(dynamic v) {
    if (v == null) return '';
    if (v is List) {
      final total =
          v.fold<double>(0, (s, x) => s + (double.tryParse(x.toString()) ?? 0));
      return total > 0 ? total.toStringAsFixed(2) : '';
    }
    return v.toString().trim();
  }

  String _tamanho(int b) {
    if (b < 1024) return '$b B';
    if (b < 1048576) return '${(b / 1024).toStringAsFixed(1)} KB';
    return '${(b / 1048576).toStringAsFixed(1)} MB';
  }

  // ── Brevo ────────────────────────────────────────────────────
  Future<void> _sendEmail({
    required List<String> toEmails,
    required String subject,
    required String htmlBody,
    List<Map<String, String>> attachments = const [],
  }) async {
    String apiKey = '';
    try {
      final snap = await FirebaseFirestore.instance
          .collection('USUARIOS')
          .where('email', isEqualTo: _emailHPS)
          .limit(1)
          .get();
      if (snap.docs.isNotEmpty) {
        apiKey = (snap.docs.first.data()['apibrevo'] ?? '').toString().trim();
      }
    } catch (_) {}
    if (apiKey.isEmpty) throw Exception('apibrevo não configurado');

    final body = <String, dynamic>{
      'sender': {'name': _senderName, 'email': _senderEmail},
      'replyTo': {'name': _senderName, 'email': _senderEmail},
      'to': toEmails.map((e) => {'email': e}).toList(),
      'subject': subject,
      'htmlContent': htmlBody,
    };

    // Anexa arquivos se houver
    if (attachments.isNotEmpty) {
      body['attachment'] = attachments;
    }

    final resp = await http.post(
      Uri.parse('https://api.brevo.com/v3/smtp/email'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'api-key': apiKey,
      },
      body: jsonEncode(body),
    );
    if (resp.statusCode != 200 && resp.statusCode != 201) {
      throw Exception('Brevo ${resp.statusCode}: ${resp.body}');
    }
  }

  // ── OneSignal ────────────────────────────────────────────────
  Future<void> _enviarPush({
    required String email,
    required String titulo,
    required String mensagem,
  }) async {
    if (email.isEmpty) return;
    try {
      await http.post(
        Uri.parse('https://onesignal.com/api/v1/notifications'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Basic $_osApiKey',
        },
        body: jsonEncode({
          'app_id': _osAppId,
          'filters': [
            {'field': 'tag', 'key': 'Email', 'relation': '=', 'value': email}
          ],
          'android_channel_id': _osChannel,
          'headings': {'en': titulo},
          'contents': {'en': mensagem},
          'priority': 10,
        }),
      );
    } catch (_) {}
  }

  // ── Notificação Firestore ────────────────────────────────────
  Future<void> _criarNotificacao({
    required String email,
    required String tipoDocumento,
    required String mes,
    required String ano,
    required String downloadUrl,
  }) async {
    if (email.isEmpty) return;
    try {
      final now = DateTime.now();
      final mn = [
        '',
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
        'DEZEMBRO'
      ];
      await FirebaseFirestore.instance.collection('NOTIFICACAO').add({
        'email': email,
        'visto': false,
        'titulo': 'Documento Enviado',
        'mensagem':
            'O documento "$tipoDocumento" referente a $mes/$ano foi enviado.',
        'status': 'ENVIADO',
        'os': '',
        'mes': mn[now.month],
        'ano': ano,
        'tipo': 'DOCUMENTO',
        'data': FieldValue.serverTimestamp(),
        'url': downloadUrl,
        'tipoDocumento': tipoDocumento,
        'mesReferencia': mes,
      });
    } catch (_) {}
  }

  // ── Busca formulário de recebimento no Storage ────────────────
  Future<void> _buscarFormularioRecebimento() async {
    final nos = _numeroOSCtrl.text.trim().toUpperCase();
    if (nos.isEmpty || selEmail == null) return;

    setState(() {
      _buscandoFormulario = true;
      _formularioUrl = null;
      _formularioNome = null;
      _enviarFormularioJunto = false;
    });

    // Padrão exato gerado pelo FormularioRecebimentoWidget:
    // RECEBIMENTO_OS{NOS}_{dd-MM-yyyy_HHhMM}.pdf
    // Varre todos os meses pois o formulário pode ter sido gerado em mês diferente
    const meses = [
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

    try {
      String? urlEncontrada;
      String? nomeEncontrado;

      for (final mes in meses) {
        if (urlEncontrada != null) break;
        try {
          final pasta = '$selEmail/$_ano/$mes/NOTAS FISCAIS/';
          final ref = FirebaseStorage.instance.ref().child(pasta);
          final list = await ref.listAll();

          for (final item in list.items) {
            // Padrão: RECEBIMENTO_OS{NOS}_*.pdf
            final n = item.name.toUpperCase();
            if (n.startsWith('RECEBIMENTO_OS') && n.contains(nos)) {
              urlEncontrada = await item.getDownloadURL();
              nomeEncontrado = item.name;
              break;
            }
          }
        } catch (_) {
          // Pasta do mês não existe — continua
        }
      }

      if (mounted) {
        setState(() {
          _formularioUrl = urlEncontrada;
          _formularioNome = nomeEncontrado;
          _buscandoFormulario = false;
        });
        if (urlEncontrada != null) {
          await _mostrarPopupFormulario(nos, nomeEncontrado!);
        }
      }
    } catch (e) {
      if (mounted) setState(() => _buscandoFormulario = false);
    }
  }

  // ── Popup formulário encontrado ───────────────────────────────
  Future<void> _mostrarPopupFormulario(String nos, String nomeArquivo) async {
    final resultado = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF00C896).withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.description_outlined,
                  color: Color(0xFF00C896), size: 32),
            ),
            const SizedBox(height: 16),
            const Text('Formulário Encontrado!',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E2A35))),
            const SizedBox(height: 8),
            Text(
              'Foi localizado um Formulário de Recebimento para a O.S. #$nos:',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: Color(0xFF4A5568)),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(8),
                border:
                    Border.all(color: const Color(0xFF00C896).withOpacity(0.4)),
              ),
              child: Row(children: [
                const Icon(Icons.picture_as_pdf,
                    color: Color(0xFF00C896), size: 18),
                const SizedBox(width: 8),
                Expanded(
                    child: Text(nomeArquivo,
                        style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF1E2A35),
                            fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis)),
              ]),
            ),
            const SizedBox(height: 16),
            const Text(
                'Deseja enviar este formulário junto com o documento atual?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Color(0xFF4A5568))),
            const SizedBox(height: 20),
            Row(children: [
              Expanded(
                  child: OutlinedButton(
                onPressed: () => Navigator.pop(ctx, false),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  side: const BorderSide(color: Color(0xFFD6DCE4)),
                ),
                child: const Text('Não',
                    style: TextStyle(color: Color(0xFF4A5568))),
              )),
              const SizedBox(width: 12),
              Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pop(ctx, true),
                    icon: const Icon(Icons.attach_file,
                        size: 16, color: Colors.white),
                    label: const Text('Sim, enviar junto',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w700)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00C896),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      elevation: 2,
                    ),
                  )),
            ]),
          ]),
        ),
      ),
    );

    if (mounted) {
      setState(() => _enviarFormularioJunto = resultado ?? false);
    }
  }

  // ── HTML email ───────────────────────────────────────────────
  String _buildHtml({
    required String nomeCliente,
    required String tipoDocumento,
    required String mes,
    required String ano,
    required String downloadUrl,
    String observacao = '',
    String numeroOS = '',
    String valor = '',
    String servico = '',
    String pecas = '',
    String? formularioUrl,
  }) {
    final w = widget.larguraEmail.toInt().toString();

    final obsHtml = observacao.isNotEmpty
        ? '<div style="background:#fffbeb;border-left:4px solid #f59e0b;padding:15px;margin-bottom:25px;border-radius:4px;color:#92400e;font-size:14px;">'
            '<strong>Informações:</strong><br>${observacao.replaceAll('\n', '<br>')}</div>'
        : '';

    final buf = StringBuffer();
    if (numeroOS.isNotEmpty)
      buf.write(
          '<tr><td style="padding:8px 0;color:#555;font-size:14px;width:160px;vertical-align:top;"><strong>Nº da O.S.:</strong></td>'
          '<td style="padding:8px 0;color:#1A3C34;font-size:14px;font-weight:bold;">$numeroOS</td></tr>');
    if (valor.isNotEmpty)
      buf.write(
          '<tr><td style="padding:8px 0;color:#555;font-size:14px;vertical-align:top;"><strong>Valor:</strong></td>'
          '<td style="padding:8px 0;color:#1A3C34;font-size:14px;font-weight:bold;">R\$ $valor</td></tr>');
    if (servico.isNotEmpty)
      buf.write(
          '<tr><td style="padding:8px 0;color:#555;font-size:14px;vertical-align:top;"><strong>Serviço:</strong></td>'
          '<td style="padding:8px 0;color:#333;font-size:14px;">${servico.replaceAll('\n', '<br>')}</td></tr>');
    if (pecas.isNotEmpty)
      buf.write(
          '<tr><td style="padding:8px 0;color:#555;font-size:14px;vertical-align:top;"><strong>Peças:</strong></td>'
          '<td style="padding:8px 0;color:#333;font-size:14px;">${pecas.replaceAll('\n', '<br>')}</td></tr>');

    final detalhesHtml = buf.isNotEmpty
        ? '<div style="background:#f0fdf4;border:1px solid #bbf7d0;border-radius:8px;padding:20px 25px;margin-bottom:25px;">'
            '<p style="margin:0 0 12px 0;color:#1A3C34;font-size:13px;font-weight:bold;">📋 Detalhes do Serviço</p>'
            '<table cellpadding="0" cellspacing="0" border="0" width="100%">$buf</table></div>'
        : '';

    // Botão adicional para o formulário de recebimento
    final formularioBotao = (formularioUrl != null && formularioUrl.isNotEmpty)
        ? '<div style="text-align:center;margin:10px 0 20px 0;">'
            '<a href="$formularioUrl" target="_blank" style="background:#3D5A80;color:#fff;text-decoration:none;padding:12px 28px;border-radius:8px;font-weight:bold;font-size:14px;display:inline-block;">📋 Baixar Formulário de Recebimento</a>'
            '</div>'
        : '';

    final cli = nomeCliente.isNotEmpty ? nomeCliente : 'Cliente';
    final yr = DateTime.now().year;

    return '<!DOCTYPE html><html lang="pt-BR"><head><meta charset="UTF-8"><title>Documento</title></head>'
        '<body style="margin:0;padding:0;background:#f4f6f8;font-family:Arial,sans-serif;">'
        '<table width="100%" cellpadding="0" cellspacing="0" border="0" style="background:#f4f6f8;padding:20px 0;"><tr><td align="center">'
        '<table width="$w" cellpadding="0" cellspacing="0" border="0" style="background:#fff;border-radius:12px;overflow:hidden;max-width:${w}px;width:100%;">'
        '<tr><td style="padding:0;line-height:0;"><img src="$_bannerUrl" width="$w" style="display:block;width:100%;height:auto;border:0;"/></td></tr>'
        '<tr><td style="background:#1A3C34;padding:15px 30px;"><span style="background:#ffffff20;color:#fff;font-size:12px;font-weight:bold;padding:5px 12px;border-radius:20px;">Documento de Serviço</span></td></tr>'
        '<tr><td style="padding:40px;color:#333;font-size:16px;line-height:1.8;">'
        '<p style="margin:0 0 20px 0;">Olá, <strong>$cli</strong>,</p>'
        '<p style="margin:0 0 20px 0;">O arquivo já está disponível para você!</p>'
        '<table width="100%" cellpadding="0" cellspacing="0" border="0" style="background:#f0fdf4;border-left:5px solid #1A3C34;border-radius:0 8px 8px 0;margin-bottom:25px;">'
        '<tr><td style="padding:20px 25px;font-size:15px;color:#1A3C34;"><strong>Documento:</strong> $tipoDocumento<br><strong>Período:</strong> $mes / $ano</td></tr></table>'
        '$detalhesHtml$obsHtml'
        '<div style="text-align:center;margin-bottom:${formularioBotao.isNotEmpty ? '10px' : '20px'};">'
        '<a href="$downloadUrl" target="_blank" style="background:#1A3C34;color:#fff;text-decoration:none;padding:15px 35px;border-radius:8px;font-weight:bold;font-size:15px;display:inline-block;">📥 Baixar arquivo</a>'
        '</div>'
        '$formularioBotao'
        '</td></tr>'
        '<tr><td style="padding:0 40px;"><hr style="border:none;border-top:1px solid #e8ecf0;margin:0;"></td></tr>'
        '<tr><td style="padding:30px 40px;"><table cellpadding="0" cellspacing="0" border="0"><tr>'
        '<td style="width:50px;vertical-align:top;"><div style="width:45px;height:45px;background:#1A3C34;border-radius:50%;text-align:center;line-height:45px;"><span style="color:#fff;font-size:20px;font-weight:bold;">H</span></div></td>'
        '<td style="padding-left:15px;vertical-align:top;"><span style="font-size:16px;font-weight:bold;color:#1A3C34;">Huagner Pires</span><br><span style="font-size:14px;color:#555;">HPS Refrigeração</span><br><span style="font-size:13px;color:#888;">www.hpsrefri.com.br</span></td>'
        '</tr></table></td></tr>'
        '<tr><td style="background:#f8fafc;padding:20px 40px;text-align:center;font-size:12px;color:#94a3b8;border-top:1px solid #e2e8f0;">© $yr HPS Refrigeração · Todos os direitos reservados</td></tr>'
        '</table></td></tr></table></body></html>';
  }

  // ── Carrega usuários ─────────────────────────────────────────
  Future<void> _carregar() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('USUARIOS')
          .orderBy('display_name')
          .get();
      final lista = <Map<String, String>>[];
      for (final d in snap.docs) {
        final email = d.data()['email']?.toString().trim() ?? '';
        if (email.isEmpty) continue;
        final nome = d.data()['display_name']?.toString().trim() ?? email;
        lista.add({'email': email, 'docId': d.id, 'nome': nome});
      }
      if (mounted)
        setState(() {
          usuarios = lista;
          carregando = false;
        });
    } catch (_) {
      // Tenta sem orderBy se índice não existir
      try {
        final snap =
            await FirebaseFirestore.instance.collection('USUARIOS').get();
        final lista = <Map<String, String>>[];
        for (final d in snap.docs) {
          final email = d.data()['email']?.toString().trim() ?? '';
          if (email.isEmpty) continue;
          final nome = d.data()['display_name']?.toString().trim() ?? email;
          lista.add({'email': email, 'docId': d.id, 'nome': nome});
        }
        lista.sort((a, b) => (a['nome']!).compareTo(b['nome']!));
        if (mounted)
          setState(() {
            usuarios = lista;
            carregando = false;
          });
      } catch (e) {
        if (mounted) setState(() => carregando = false);
      }
    }
  }

  // ── Seleciona usuário ────────────────────────────────────────
  Future<void> _selecionarUsuario(
      String email, String docId, String nome) async {
    setState(() {
      selEmail = email;
      selDocId = docId;
      selNomeCliente = nome;
      emailsTeste = [];
      emailsSelecionados = {};
      osDoUsuario = [];
      ok = false;
      erro = null;
      osEncontrada = false;
      _formularioUrl = null;
      _formularioNome = null;
      _enviarFormularioJunto = false;
      _numeroOSCtrl.clear();
      _valorCtrl.clear();
      _servicoCtrl.clear();
      _pecasCtrl.clear();
    });
    try {
      // Carrega emailteste
      final userDoc = await FirebaseFirestore.instance
          .collection('USUARIOS')
          .doc(docId)
          .get();
      final lista = <String>[];
      final ud = userDoc.data();
      if (ud != null) {
        final field = ud['emailteste'];
        if (field is List) {
          for (final e in field) {
            final s = e?.toString().trim() ?? '';
            if (s.isNotEmpty) lista.add(s);
          }
        } else if (field is String && field.trim().isNotEmpty) {
          lista.add(field.trim());
        }
      }
      if (mounted) setState(() => emailsTeste = lista);
    } catch (_) {}

    // Busca OS separado
    await _buscarOsDoUsuario();
  }

  // ── Busca OS na coleção CORRETIVAS pelo campo EMAIL ───────────
  Future<void> _buscarOsDoUsuario() async {
    if (selEmail == null) return;
    setState(() {
      _buscandoOsLista = true;
      osDoUsuario = [];
    });

    final Set<String> nosVistos = {};
    final osList = <Map<String, dynamic>>[];

    void processar(List<QueryDocumentSnapshot> docs) {
      for (final doc in docs) {
        final d = doc.data() as Map<String, dynamic>;
        final nos = (d['NUMERODAOS'] ?? d['NUMERO_OS'] ?? '').toString().trim();
        if (nos.isEmpty || nosVistos.contains(nos)) continue;

        // Filtra por mês se selecionado
        if (selMesOS != null && selMesOS!.isNotEmpty) {
          final mesIdx = _meses.indexOf(selMesOS!) + 1; // 1-12
          final data = (d['DATADAMANUTENCAO'] ?? d['INICIO'] ?? '').toString();
          // tenta extrair mês da data (formato dd/MM/yyyy ou MM/dd/yyyy ou yyyy-MM-dd)
          bool mesOk = false;
          // dd/MM/yyyy
          final partes = data.split(RegExp(r'[/\-]'));
          if (partes.length >= 2) {
            final m1 = int.tryParse(partes[1]); // dd/MM/yyyy → partes[1] = mês
            final m2 = int.tryParse(partes[0]); // MM/dd → partes[0] = mês
            if (m1 == mesIdx || m2 == mesIdx) mesOk = true;
          }
          if (!mesOk) continue;
        }

        nosVistos.add(nos);
        osList.add({
          'nos': nos,
          'defeito': (d['DEFEITO'] ?? '').toString().trim(),
          'descricao': (d['DESCRICAODOSERVICO'] ?? '').toString().trim(),
          'pecas': _strVal(d['PREVISAODAPECA'] ?? d['PECAS']),
          'valor': _valorStr(d['VALOR']),
          'status': (d['STATUS'] ?? '').toString().trim(),
          'data':
              (d['DATADAMANUTENCAO'] ?? d['INICIO'] ?? '').toString().trim(),
        });
      }
    }

    // Busca pelo campo EMAIL (campo principal nas CORRETIVAS)
    try {
      final snap = await FirebaseFirestore.instance
          .collection('CORRETIVAS')
          .where('EMAIL', isEqualTo: selEmail)
          .orderBy('DATADAMANUTENCAO', descending: true)
          .get();
      processar(snap.docs);
    } catch (_) {
      try {
        final snap = await FirebaseFirestore.instance
            .collection('CORRETIVAS')
            .where('EMAIL', isEqualTo: selEmail)
            .get();
        processar(snap.docs);
      } catch (_) {}
    }

    // Fallback: campo CLIENTE == display_name
    if (osList.isEmpty && selNomeCliente != null) {
      try {
        final snap = await FirebaseFirestore.instance
            .collection('CORRETIVAS')
            .where('CLIENTE', isEqualTo: selNomeCliente)
            .orderBy('DATADAMANUTENCAO', descending: true)
            .get();
        processar(snap.docs);
      } catch (_) {
        try {
          final snap = await FirebaseFirestore.instance
              .collection('CORRETIVAS')
              .where('CLIENTE', isEqualTo: selNomeCliente)
              .get();
          processar(snap.docs);
        } catch (_) {}
      }
    }

    // Ordena por data
    osList.sort((a, b) => b['data'].toString().compareTo(a['data'].toString()));

    if (mounted)
      setState(() {
        osDoUsuario = osList;
        _buscandoOsLista = false;
      });
  }

  void _preencherComOS(Map<String, dynamic> os) {
    setState(() {
      _numeroOSCtrl.text = os['nos'].toString().toUpperCase();
      final def = os['defeito'].toString();
      final desc = os['descricao'].toString();
      _servicoCtrl.text = (def.isNotEmpty ? def : desc).toUpperCase();
      if (def.isNotEmpty && desc.isNotEmpty) _obsCtrl.text = desc.toUpperCase();
      _pecasCtrl.text = os['pecas'].toString().toUpperCase();
      _valorCtrl.text = os['valor'].toString();
      osEncontrada = true;
      // Limpa formulário anterior ao trocar OS
      _formularioUrl = null;
      _formularioNome = null;
      _enviarFormularioJunto = false;
    });
    // Busca formulário automaticamente ao selecionar OS
    Future.delayed(
        const Duration(milliseconds: 300), _buscarFormularioRecebimento);
  }

  Future<void> _buscarDadosOS() async {
    final nos = _numeroOSCtrl.text.trim().toUpperCase();
    if (nos.isEmpty) return;
    setState(() {
      buscandoOS = true;
      osEncontrada = false;
    });
    try {
      QuerySnapshot snap = await FirebaseFirestore.instance
          .collection('CORRETIVAS')
          .where('NUMERODAOS', isEqualTo: nos)
          .limit(1)
          .get();
      if (snap.docs.isEmpty) {
        snap = await FirebaseFirestore.instance
            .collection('CORRETIVAS')
            .where('NUMERO_OS', isEqualTo: nos)
            .limit(1)
            .get();
      }
      if (snap.docs.isEmpty) {
        if (mounted) setState(() => buscandoOS = false);
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(SnackBar(
          content: Text('O.S #$nos não encontrada.'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ));
        return;
      }
      final d = snap.docs.first.data() as Map<String, dynamic>;
      setState(() {
        _servicoCtrl.text =
            (d['DEFEITO'] ?? '').toString().trim().toUpperCase();
        if ((d['DEFEITO'] ?? '').toString().isNotEmpty &&
            (d['DESCRICAODOSERVICO'] ?? '').toString().isNotEmpty)
          _obsCtrl.text =
              d['DESCRICAODOSERVICO'].toString().trim().toUpperCase();
        _pecasCtrl.text =
            _strVal(d['PREVISAODAPECA'] ?? d['PECAS']).toUpperCase();
        _valorCtrl.text = _valorStr(d['VALOR']);
        buscandoOS = false;
        osEncontrada = true;
      });
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(SnackBar(
        content: Text('✅ Dados da O.S #$nos carregados!'),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ));
      // Busca formulário automaticamente após carregar OS
      await _buscarFormularioRecebimento();
    } catch (_) {
      if (mounted) setState(() => buscandoOS = false);
    }
  }

  void _toggleEmail(String email) =>
      setState(() => emailsSelecionados.contains(email)
          ? emailsSelecionados.remove(email)
          : emailsSelecionados.add(email));

  void _toggleTodos() =>
      setState(() => emailsSelecionados.length == emailsTeste.length
          ? emailsSelecionados.clear()
          : emailsSelecionados = Set.from(emailsTeste));

  // ── Sheets ───────────────────────────────────────────────────
  void _abrirSelecaoOS() {
    if (osDoUsuario.isEmpty) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1D27),
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.92,
        shouldCloseOnMinExtent: true,
        builder: (_, ctrl) => SafeArea(
            child: Column(children: [
          Container(
              margin: const EdgeInsets.only(top: 12, bottom: 4),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: const Color(0xFF00C896).withOpacity(.3),
                  borderRadius: BorderRadius.circular(2))),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(children: [
              const Icon(Icons.assignment_outlined,
                  color: Color(0xFF00C896), size: 18),
              const SizedBox(width: 8),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    const Text('Selecionar O.S',
                        style: TextStyle(
                            color: Color(0xFFEEF0F8),
                            fontSize: 15,
                            fontWeight: FontWeight.w700)),
                    Text('${osDoUsuario.length} O.S encontrada(s)',
                        style: const TextStyle(
                            color: Color(0xFF8A90B0), fontSize: 11)),
                  ])),
            ]),
          ),
          Divider(color: const Color(0xFF00C896).withOpacity(.2), height: 1),
          Expanded(
              child: ListView.builder(
            controller: ctrl,
            itemCount: osDoUsuario.length,
            itemBuilder: (context, i) {
              final os = osDoUsuario[i];
              final nos = os['nos'].toString();
              final sel = _numeroOSCtrl.text.toUpperCase() == nos.toUpperCase();
              Color sc = const Color(0xFF8A90B0);
              final st = os['status'].toString();
              if (st.contains('CONCLU'))
                sc = const Color(0xFF10B981);
              else if (st.contains('AGUARD'))
                sc = const Color(0xFFF59E0B);
              else if (st.contains('CANCEL')) sc = Colors.redAccent;
              return InkWell(
                onTap: () {
                  Navigator.pop(context);
                  _preencherComOS(os);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: sel
                        ? const Color(0xFF00C896).withOpacity(.1)
                        : const Color(0xFF0F1117),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: sel
                            ? const Color(0xFF00C896)
                            : const Color(0xFF2C3050),
                        width: sel ? 1.5 : 1),
                  ),
                  child: Row(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                            colors: [Color(0xFF00C896), Color(0xFF059669)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text('OS\n#$nos',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              height: 1.3)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          if (os['defeito'].toString().isNotEmpty)
                            Text(os['defeito'].toString().toUpperCase(),
                                style: const TextStyle(
                                    color: Color(0xFFEEF0F8),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 4),
                          Row(children: [
                            if (st.isNotEmpty) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                    color: sc.withOpacity(.15),
                                    borderRadius: BorderRadius.circular(4),
                                    border:
                                        Border.all(color: sc.withOpacity(.4))),
                                child: Text(st,
                                    style: TextStyle(
                                        color: sc,
                                        fontSize: 9,
                                        fontWeight: FontWeight.w700)),
                              ),
                              const SizedBox(width: 6),
                            ],
                            if (os['data'].toString().isNotEmpty)
                              Text(os['data'].toString(),
                                  style: const TextStyle(
                                      color: Color(0xFF8A90B0), fontSize: 10)),
                            if (os['valor'].toString().isNotEmpty) ...[
                              const SizedBox(width: 6),
                              Text('R\$ ${os['valor']}',
                                  style: const TextStyle(
                                      color: Color(0xFF10B981),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700)),
                            ],
                          ]),
                        ])),
                    if (sel)
                      const Icon(Icons.check_circle,
                          color: Color(0xFF00C896), size: 18),
                  ]),
                ),
              );
            },
          )),
          const SizedBox(height: 16),
        ])),
      ),
    );
  }

  void _abrirSelecaoUsuario() {
    String filtro = '';
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1D27),
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setLocal) {
          final filtrados = filtro.isEmpty
              ? usuarios
              : usuarios
                  .where((u) =>
                      (u['nome'] ?? '')
                          .toLowerCase()
                          .contains(filtro.toLowerCase()) ||
                      (u['email'] ?? '')
                          .toLowerCase()
                          .contains(filtro.toLowerCase()))
                  .toList();
          return DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.7,
            maxChildSize: 0.95,
            shouldCloseOnMinExtent: true,
            builder: (_, ctrl) => SafeArea(
                child: Column(children: [
              Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 4),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: const Color(0xFF4F8EF7).withOpacity(.3),
                      borderRadius: BorderRadius.circular(2))),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        const Expanded(
                          child: Text('Selecionar Usuário',
                              style: TextStyle(
                                  color: Color(0xFFEEF0F8),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700)),
                        ),
                      ]),
                      const SizedBox(height: 10),
                      // Campo de busca
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F1117),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFF2C3050)),
                        ),
                        child: TextField(
                          autofocus: true,
                          style: const TextStyle(
                              color: Color(0xFFEEF0F8), fontSize: 13),
                          onChanged: (v) => setLocal(() => filtro = v),
                          decoration: const InputDecoration(
                            hintText: 'Buscar por nome ou email...',
                            hintStyle: TextStyle(
                                color: Color(0xFF8A90B0), fontSize: 12),
                            prefixIcon: Icon(Icons.search,
                                color: Color(0xFF8A90B0), size: 18),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 12),
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text('${filtrados.length} usuário(s)',
                          style: const TextStyle(
                              color: Color(0xFF8A90B0), fontSize: 10)),
                    ]),
              ),
              Divider(
                  color: const Color(0xFF4F8EF7).withOpacity(.2), height: 1),
              Expanded(
                  child: filtrados.isEmpty
                      ? const Center(
                          child: Text('Nenhum usuário encontrado.',
                              style: TextStyle(
                                  color: Color(0xFF8A90B0), fontSize: 13)))
                      : ListView.builder(
                          controller: ctrl,
                          itemCount: filtrados.length,
                          itemBuilder: (context, i) {
                            final u = filtrados[i];
                            final sel = u['email'] == selEmail;
                            return InkWell(
                              onTap: () {
                                Navigator.pop(context);
                                _selecionarUsuario(
                                    u['email']!, u['docId']!, u['nome']!);
                              },
                              child: _sheetItem(
                                  u['nome']!, sel, const Color(0xFF4F8EF7),
                                  sub: u['email']),
                            );
                          },
                        )),
              const SizedBox(height: 16),
            ])),
          );
        },
      ),
    );
  }

  void _abrirSelecaoLista(String titulo, Color cor, List<String> opcoes,
      String? atual, void Function(String) onSelect) {
    _abrirSheet(
      titulo: titulo,
      cor: cor,
      builder: (sc) => ListView.builder(
        controller: sc,
        itemCount: opcoes.length,
        itemBuilder: (context, i) {
          final op = opcoes[i];
          final sel = op == atual;
          return InkWell(
            onTap: () {
              Navigator.pop(context);
              onSelect(op);
            },
            child: _sheetItem(op, sel, cor),
          );
        },
      ),
    );
  }

  void _abrirSheet(
      {required String titulo,
      required Color cor,
      required Widget Function(ScrollController) builder}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1D27),
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.5,
        maxChildSize: 0.9,
        shouldCloseOnMinExtent: true,
        builder: (_, ctrl) => SafeArea(
            child: Column(children: [
          Container(
              margin: const EdgeInsets.only(top: 12, bottom: 4),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: cor.withOpacity(.3),
                  borderRadius: BorderRadius.circular(2))),
          Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 4, 12),
              child: Row(children: [
                Expanded(
                  child: Text(titulo,
                      style: const TextStyle(
                          color: Color(0xFFEEF0F8),
                          fontSize: 15,
                          fontWeight: FontWeight.w700)),
                ),
              ])),
          Divider(color: cor.withOpacity(.2), height: 1),
          Expanded(child: builder(ctrl)),
          const SizedBox(height: 16),
        ])),
      ),
    );
  }

  Widget _sheetItem(String label, bool sel, Color cor, {String? sub}) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        color: sel ? cor.withOpacity(.1) : Colors.transparent,
        child: Row(children: [
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(label,
                    style: TextStyle(
                        color: sel ? cor : const Color(0xFFEEF0F8),
                        fontSize: 13,
                        fontWeight: sel ? FontWeight.w600 : FontWeight.normal)),
                if (sub != null && sub != label)
                  Text(sub,
                      style: const TextStyle(
                          color: Color(0xFF8A90B0), fontSize: 11)),
              ])),
          if (sel) Icon(Icons.check_circle, color: cor, size: 18),
        ]),
      );

  Future<void> _selecionarArquivo() async {
    try {
      final r = await FilePicker.platform.pickFiles(withData: true);
      if (r != null && r.files.isNotEmpty && mounted)
        setState(() {
          selFile = r.files.first;
          erro = null;
          ok = false;
        });
    } catch (_) {
      if (mounted) setState(() => erro = 'Erro ao selecionar arquivo.');
    }
  }

  // ── ENVIAR ────────────────────────────────────────────────────
  Future<void> _enviar() async {
    if (!_pronto) return;
    setState(() {
      enviando = true;
      prog = 0;
      progLabel = 'Fazendo upload...';
      erro = null;
      ok = false;
    });
    try {
      await _setProgress(0.1, 'Enviando arquivo...');

      final ext = (selFile!.extension?.isNotEmpty == true)
          ? '.${selFile!.extension}'
          : '';
      final numOS = _numeroOSCtrl.text.trim().toUpperCase();
      final now = DateTime.now();
      final dh =
          '${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}'
          '_${now.hour.toString().padLeft(2, '0')}h${now.minute.toString().padLeft(2, '0')}';
      final nome =
          numOS.isNotEmpty ? 'OS_${numOS}_$dh$ext' : '$_tipoFinal-$dh$ext';
      final path = '${selEmail!}/$_ano/$selMes/NOTAS FISCAIS/$nome';
      final ref = FirebaseStorage.instance.ref().child(path);

      if (selFile!.bytes == null) throw Exception('Arquivo vazio.');
      final task = ref.putData(selFile!.bytes!);
      task.snapshotEvents.listen((s) {
        if (mounted)
          setState(() {
            prog = 0.1 +
                (s.bytesTransferred / (s.totalBytes == 0 ? 1 : s.totalBytes)) *
                    0.5;
            progLabel = 'Enviando... ${(prog * 100).toStringAsFixed(0)}%';
          });
      });
      await task;
      final downloadUrl = await ref.getDownloadURL();

      await _setProgress(0.65, 'Salvando notificação...');
      await _criarNotificacao(
        email: selEmail!,
        tipoDocumento: _tipoFinal,
        mes: selMes!,
        ano: _ano,
        downloadUrl: downloadUrl,
      );

      if (emailsSelecionados.isNotEmpty) {
        await _setProgress(0.75, 'Enviando email...');
        await _sendEmail(
          toEmails: emailsSelecionados.toList(),
          subject: 'Novo Documento: $_tipoFinal – $selMes/$_ano',
          htmlBody: _buildHtml(
            nomeCliente: selNomeCliente ?? '',
            tipoDocumento: _tipoFinal,
            mes: selMes!,
            ano: _ano,
            downloadUrl: downloadUrl,
            observacao: _obsCtrl.text.trim(),
            numeroOS: _numeroOSCtrl.text.trim(),
            valor: _valorCtrl.text.trim(),
            servico: _servicoCtrl.text.trim(),
            pecas: _pecasCtrl.text.trim(),
            formularioUrl: _enviarFormularioJunto ? _formularioUrl : null,
          ),
        );
      }

      await _setProgress(0.88, 'Enviando push...');
      await Future.wait([
        _enviarPush(
            email: selEmail!,
            titulo: '📄 Novo Documento Disponível',
            mensagem:
                'O documento "$_tipoFinal" de $selMes/$_ano foi emitido.'),
        _enviarPush(
            email: _emailHPS,
            titulo: '📤 Documento Enviado',
            mensagem:
                'Documento "$_tipoFinal" enviado para ${selNomeCliente ?? selEmail} ($selMes/$_ano).'),
      ]);

      await _setProgress(1.0, 'Concluído!');
      if (mounted)
        setState(() {
          enviando = false;
          ok = true;
          _obsCtrl.clear();
          _numeroOSCtrl.clear();
          _valorCtrl.clear();
          _servicoCtrl.clear();
          _pecasCtrl.clear();
          osEncontrada = false;
          _formularioUrl = null;
          _formularioNome = null;
          _enviarFormularioJunto = false;
        });
    } catch (e) {
      if (mounted)
        setState(() {
          enviando = false;
          erro = 'Erro: $e';
        });
    }
  }

  Future<void> _setProgress(double alvo, String label) async {
    if (!mounted) return;
    setState(() => progLabel = label);
    final ini = prog;
    for (int i = 1; i <= 15; i++) {
      await Future.delayed(const Duration(milliseconds: 18));
      if (!mounted) return;
      setState(() => prog = ini + (alvo - ini) * (i / 15));
    }
  }

  // ══════════════════════════════════════════════════════════════
  //  BUILD
  // ══════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: widget.width ?? double.infinity,
        height: widget.height ?? 860,
        decoration: BoxDecoration(
            color: const Color(0xFF0F1117),
            borderRadius: BorderRadius.circular(20)),
        child: Stack(children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Row(children: [
                    Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            color: const Color(0x264F8EF7),
                            borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.cloud_upload,
                            color: Color(0xFF4F8EF7), size: 24)),
                    const SizedBox(width: 12),
                    const Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Text('Upload de Documentos',
                              style: TextStyle(
                                  color: Color(0xFFEEF0F8),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700)),
                          SizedBox(height: 2),
                          Text('Firebase Storage · Brevo · OneSignal',
                              style: TextStyle(
                                  color: Color(0xFF8A90B0), fontSize: 11)),
                        ])),
                  ]),
                  const SizedBox(height: 24),

                  // Usuário
                  _rotulo('USUÁRIO', Icons.person_outline),
                  const SizedBox(height: 8),
                  _botaoSelecao(
                    valor: selEmail,
                    hint: carregando
                        ? 'Carregando...'
                        : usuarios.isEmpty
                            ? 'Nenhum usuário encontrado'
                            : 'Selecionar usuário',
                    icone: Icons.email_outlined,
                    onTap: carregando ? null : _abrirSelecaoUsuario,
                  ),
                  const SizedBox(height: 18),

                  // OS do usuário
                  if (selEmail != null) _secaoOSUsuario(),
                  if (selEmail != null) const SizedBox(height: 18),

                  // Tipo
                  _rotulo('TIPO DE DOCUMENTO', Icons.description_outlined),
                  const SizedBox(height: 8),
                  _botaoSelecao(
                      valor: selTipo,
                      hint: 'Selecionar tipo',
                      icone: Icons.category_outlined,
                      onTap: () => _abrirSelecaoLista('Tipo de Documento',
                              const Color(0xFF4F8EF7), _tipos, selTipo, (v) {
                            setState(() {
                              selTipo = v;
                              _showOutrosField = v == 'OUTROS';
                              if (v != 'OUTROS') _outrosCtrl.clear();
                              ok = false;
                              erro = null;
                            });
                          })),
                  if (_showOutrosField) ...[
                    const SizedBox(height: 12),
                    _campoTexto(
                        controller: _outrosCtrl,
                        hint: 'NOME DO DOCUMENTO',
                        icone: Icons.edit_outlined,
                        forcarMaiusculo: true),
                  ],
                  const SizedBox(height: 18),

                  // Mês
                  _rotulo('MÊS DE REFERÊNCIA', Icons.calendar_today_outlined),
                  const SizedBox(height: 8),
                  _botaoSelecao(
                      valor: selMes,
                      hint: 'Selecionar mês',
                      icone: Icons.calendar_month_outlined,
                      onTap: () => _abrirSelecaoLista('Mês de Referência',
                              const Color(0xFF7C3AED), _meses, selMes, (v) {
                            setState(() {
                              selMes = v;
                              ok = false;
                              erro = null;
                            });
                          })),
                  const SizedBox(height: 18),

                  // Arquivo
                  _rotulo('ARQUIVO', Icons.attach_file),
                  const SizedBox(height: 8),
                  _areaSelecionarArquivo(),
                  const SizedBox(height: 22),

                  // Detalhes
                  _secaoDetalhesServico(),
                  const SizedBox(height: 18),

                  // Observação
                  _rotulo(
                      'MENSAGEM NO E-MAIL (OPCIONAL)', Icons.message_outlined),
                  const SizedBox(height: 8),
                  _campoTexto(
                      controller: _obsCtrl,
                      hint: 'DIGITE ALGUMA OBSERVAÇÃO...',
                      icone: Icons.edit_note_outlined,
                      forcarMaiusculo: true,
                      maxLines: 3),

                  // Formulário de recebimento encontrado
                  if (_formularioUrl != null || _buscandoFormulario) ...[
                    const SizedBox(height: 18),
                    _secaoFormularioRecebimento(),
                  ],

                  // Preview caminho
                  if (selEmail != null && selTipo != null && selMes != null)
                    Padding(
                        padding: const EdgeInsets.only(top: 14),
                        child: _previewCaminho()),

                  // Emails
                  if (selEmail != null) ...[
                    const SizedBox(height: 18),
                    _secaoEmails()
                  ],

                  // Sucesso
                  if (ok)
                    Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Column(children: [
                          _faixa(
                              const Color(0xFF00C896),
                              Icons.check_circle_outline,
                              'Arquivo enviado com sucesso!'),
                          const SizedBox(height: 8),
                          _faixa(
                              const Color(0xFF4F8EF7),
                              Icons.notifications_active_outlined,
                              'Notificação registrada para $selEmail.'),
                          if (emailsSelecionados.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            _faixa(
                                const Color(0xFF8B5CF6),
                                Icons.email_outlined,
                                'Email enviado via Brevo para ${emailsSelecionados.length} destinatário(s).'),
                          ],
                          const SizedBox(height: 8),
                          _faixa(
                              const Color(0xFFF59E0B),
                              Icons.campaign_outlined,
                              'Push OneSignal enviado.'),
                        ])),

                  // Erro
                  if (erro != null)
                    Padding(
                        padding: const EdgeInsets.only(top: 14),
                        child: _faixa(
                            Colors.redAccent, Icons.error_outline, erro!)),

                  const SizedBox(height: 24),

                  // Botão enviar
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: _pronto ? _enviar : null,
                      icon: const Icon(Icons.cloud_upload, size: 20),
                      label: const Text('Enviar Documento',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w700)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _pronto
                            ? const Color(0xFF4F8EF7)
                            : const Color(0xFF2C3050),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: const Color(0xFF2C3050),
                        disabledForegroundColor: const Color(0xFF8A90B0),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        elevation: _pronto ? 4 : 0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ]),
          ),

          // Overlay progresso
          if (enviando)
            Positioned.fill(
                child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                color: Colors.black.withOpacity(.7),
                child: Center(
                    child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 32),
                  padding: const EdgeInsets.all(26),
                  decoration: BoxDecoration(
                      color: const Color(0xFF1A1D27),
                      borderRadius: BorderRadius.circular(16)),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                            color: const Color(0xFF4F8EF7).withOpacity(.15),
                            shape: BoxShape.circle),
                        child: const Icon(Icons.cloud_upload,
                            color: Color(0xFF4F8EF7), size: 30)),
                    const SizedBox(height: 16),
                    const Text('Enviando documento',
                        style: TextStyle(
                            color: Color(0xFFEEF0F8),
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text(progLabel,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: Color(0xFF8A90B0), fontSize: 13)),
                    const SizedBox(height: 20),
                    ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                            value: prog,
                            minHeight: 10,
                            backgroundColor: const Color(0xFF2C3050),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                Color(0xFF4F8EF7)))),
                    const SizedBox(height: 8),
                    Align(
                        alignment: Alignment.centerRight,
                        child: Text('${(prog * 100).toStringAsFixed(0)}%',
                            style: const TextStyle(
                                color: Color(0xFF4F8EF7),
                                fontSize: 12,
                                fontWeight: FontWeight.bold))),
                  ]),
                )),
              ),
            )),
        ]),
      ),
    );
  }

  // ── Seção Formulário de Recebimento ───────────────────────────
  Widget _secaoFormularioRecebimento() {
    const cor = Color(0xFF3D5A80);
    if (_buscandoFormulario) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1D27),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: cor.withOpacity(.3)),
        ),
        child: const Row(children: [
          SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: Color(0xFF3D5A80))),
          SizedBox(width: 12),
          Text('Buscando formulário de recebimento...',
              style: TextStyle(color: Color(0xFF8A90B0), fontSize: 12)),
        ]),
      );
    }

    if (_formularioUrl == null) return const SizedBox.shrink();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _enviarFormularioJunto
            ? cor.withOpacity(.1)
            : const Color(0xFF1A1D27),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: _enviarFormularioJunto ? cor : cor.withOpacity(.4),
            width: _enviarFormularioJunto ? 1.5 : 1),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                  color: cor.withOpacity(.15),
                  borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.description_outlined,
                  color: Color(0xFF3D5A80), size: 18)),
          const SizedBox(width: 12),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                const Text('FORMULÁRIO DE RECEBIMENTO ENCONTRADO',
                    style: TextStyle(
                        color: Color(0xFF3D5A80),
                        fontSize: 11,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(_formularioNome ?? '',
                    style:
                        const TextStyle(color: Color(0xFF8A90B0), fontSize: 10),
                    overflow: TextOverflow.ellipsis),
              ])),
        ]),
        const SizedBox(height: 12),
        // Toggle enviar junto
        GestureDetector(
          onTap: () =>
              setState(() => _enviarFormularioJunto = !_enviarFormularioJunto),
          child: Row(children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: _enviarFormularioJunto ? cor : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                    color:
                        _enviarFormularioJunto ? cor : const Color(0xFF4A5080),
                    width: 1.5),
              ),
              child: _enviarFormularioJunto
                  ? const Icon(Icons.check, color: Colors.white, size: 14)
                  : null,
            ),
            const SizedBox(width: 10),
            const Expanded(
                child: Text(
                    'Enviar este formulário junto com o documento no email',
                    style: TextStyle(color: Color(0xFFEEF0F8), fontSize: 12))),
          ]),
        ),
      ]),
    );
  }

  // ── Seções originais ─────────────────────────────────────────
  Widget _secaoOSUsuario() {
    final temOS = osDoUsuario.isNotEmpty;
    const cor = Color(0xFF00C896);
    final osSel = _numeroOSCtrl.text.trim();

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // ── Seletor de mês para filtrar OS ──────────────────────
      Row(children: [
        const Icon(Icons.filter_list, size: 13, color: Color(0xFF8A90B0)),
        const SizedBox(width: 6),
        const Text('FILTRAR O.S POR MÊS',
            style: TextStyle(
                color: Color(0xFF8A90B0),
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8)),
        const Spacer(),
        if (selMesOS != null)
          GestureDetector(
            onTap: () {
              setState(() => selMesOS = null);
              _buscarOsDoUsuario();
            },
            child: const Text('Limpar filtro',
                style: TextStyle(
                    color: Color(0xFF00C896),
                    fontSize: 10,
                    fontWeight: FontWeight.w600)),
          ),
      ]),
      const SizedBox(height: 8),
      GestureDetector(
        onTap: () => _abrirSelecaoLista(
          'Filtrar por Mês',
          cor,
          _meses,
          selMesOS,
          (v) {
            setState(() => selMesOS = v);
            _buscarOsDoUsuario();
          },
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1D27),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: selMesOS != null
                    ? cor.withOpacity(.6)
                    : const Color(0xFF2C3050)),
          ),
          child: Row(children: [
            Icon(Icons.calendar_month_outlined,
                size: 15,
                color: selMesOS != null ? cor : const Color(0xFF8A90B0)),
            const SizedBox(width: 10),
            Text(selMesOS ?? 'Todos os meses',
                style: TextStyle(
                    color: selMesOS != null
                        ? const Color(0xFFEEF0F8)
                        : const Color(0xFF8A90B0),
                    fontSize: 13)),
            const Spacer(),
            const Icon(Icons.keyboard_arrow_down,
                color: Color(0xFF8A90B0), size: 18),
          ]),
        ),
      ),
      const SizedBox(height: 10),

      // ── Botão de OS ─────────────────────────────────────────
      _buscandoOsLista
          ? Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                  color: const Color(0xFF1A1D27),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF2C3050))),
              child: const Row(children: [
                SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Color(0xFF00C896))),
                SizedBox(width: 12),
                Text('Buscando O.S...',
                    style: TextStyle(color: Color(0xFF8A90B0), fontSize: 12)),
              ]),
            )
          : GestureDetector(
              onTap: temOS ? _abrirSelecaoOS : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1D27),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: osSel.isNotEmpty
                          ? cor
                          : temOS
                              ? cor.withOpacity(.4)
                              : const Color(0xFF2C3050)),
                ),
                child: Row(children: [
                  Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                          color: temOS
                              ? cor.withOpacity(.15)
                              : const Color(0xFF2C3050),
                          borderRadius: BorderRadius.circular(10)),
                      child: Icon(
                          osSel.isNotEmpty
                              ? Icons.assignment_turned_in_outlined
                              : Icons.assignment_outlined,
                          color: temOS ? cor : const Color(0xFF8A90B0),
                          size: 18)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text(
                          osSel.isNotEmpty
                              ? 'O.S #$osSel SELECIONADA'
                              : temOS
                                  ? 'SELECIONAR O.S DO CLIENTE'
                                  : 'NENHUMA O.S ENCONTRADA',
                          style: TextStyle(
                              color: osSel.isNotEmpty
                                  ? cor
                                  : temOS
                                      ? const Color(0xFFEEF0F8)
                                      : const Color(0xFF8A90B0),
                              fontSize: 12,
                              fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          temOS
                              ? '${osDoUsuario.length} O.S encontrada(s)${selMesOS != null ? ' em $selMesOS' : ''} · toque para selecionar'
                              : selMesOS != null
                                  ? 'Nenhuma O.S em $selMesOS — tente outro mês'
                                  : 'Nenhum registro em CORRETIVAS para este cliente',
                          style: const TextStyle(
                              color: Color(0xFF8A90B0), fontSize: 10),
                        ),
                      ])),
                  if (temOS)
                    Icon(Icons.keyboard_arrow_down,
                        color: osSel.isNotEmpty ? cor : const Color(0xFF8A90B0),
                        size: 20),
                ]),
              ),
            ),
    ]);
  }

  Widget _secaoDetalhesServico() {
    const cor = Color(0xFF00C896);
    final temAlgo = _numeroOSCtrl.text.isNotEmpty ||
        _valorCtrl.text.isNotEmpty ||
        _servicoCtrl.text.isNotEmpty ||
        _pecasCtrl.text.isNotEmpty;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1D27),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: temAlgo ? cor.withOpacity(.4) : const Color(0xFF2C3050)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.build_outlined, size: 14, color: Color(0xFF00C896)),
          const SizedBox(width: 6),
          const Text('DETALHES DO SERVIÇO (OPCIONAL)',
              style: TextStyle(
                  color: Color(0xFF00C896),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8)),
          const Spacer(),
          Text('aparece no e-mail',
              style: TextStyle(color: cor.withOpacity(.5), fontSize: 9)),
        ]),
        const SizedBox(height: 14),
        _rotuloMini('Nº DA O.S.', Icons.tag),
        const SizedBox(height: 6),
        Row(children: [
          Expanded(
              child: _campoTextoCompacto(
                  controller: _numeroOSCtrl,
                  hint: 'Ex: 1042 ou PREVENTIVA-03',
                  icone: Icons.numbers,
                  forcarMaiusculo: true)),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: buscandoOS ? null : _buscarDadosOS,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                gradient: buscandoOS
                    ? null
                    : const LinearGradient(
                        colors: [Color(0xFF00C896), Color(0xFF059669)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight),
                color: buscandoOS ? const Color(0xFF2C3050) : null,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                  child: buscandoOS
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(
                              osEncontrada
                                  ? Icons.check_circle_rounded
                                  : Icons.search_rounded,
                              color: Colors.white,
                              size: 15),
                          const SizedBox(width: 5),
                          Text(osEncontrada ? 'OK' : 'BUSCAR',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700)),
                        ])),
            ),
          ),
        ]),
        const SizedBox(height: 14),
        _rotuloMini('VALOR (R\$)', Icons.attach_money),
        const SizedBox(height: 6),
        _campoTextoCompacto(
            controller: _valorCtrl,
            hint: 'Ex: 350,00',
            icone: Icons.attach_money,
            tipoTeclado: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]'))
            ]),
        const SizedBox(height: 14),
        _rotuloMini('SERVIÇO REALIZADO', Icons.handyman_outlined),
        const SizedBox(height: 6),
        _campoTexto(
            controller: _servicoCtrl,
            hint: 'DESCREVA O SERVIÇO EXECUTADO...',
            icone: Icons.handyman_outlined,
            forcarMaiusculo: true,
            maxLines: 3,
            minLines: 2,
            corBorda: cor),
        const SizedBox(height: 14),
        _rotuloMini('PEÇAS UTILIZADAS', Icons.settings_outlined),
        const SizedBox(height: 6),
        _campoTexto(
            controller: _pecasCtrl,
            hint: 'LISTE AS PEÇAS UTILIZADAS...',
            icone: Icons.settings_outlined,
            forcarMaiusculo: true,
            maxLines: 3,
            minLines: 2,
            corBorda: cor),
      ]),
    );
  }

  Widget _secaoEmails() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1D27),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: emailsSelecionados.isNotEmpty
                ? const Color(0xFF8B5CF6).withOpacity(.5)
                : const Color(0xFF2C3050)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.email_outlined, size: 14, color: Color(0xFF8B5CF6)),
          const SizedBox(width: 6),
          const Text('NOTIFICAR POR EMAIL (emailteste)',
              style: TextStyle(
                  color: Color(0xFF8B5CF6),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8)),
          const Spacer(),
          if (emailsTeste.isNotEmpty)
            GestureDetector(
              onTap: _toggleTodos,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: emailsSelecionados.length == emailsTeste.length
                      ? const Color(0xFF8B5CF6).withOpacity(.15)
                      : const Color(0xFF2C3050),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                      color: emailsSelecionados.length == emailsTeste.length
                          ? const Color(0xFF8B5CF6)
                          : const Color(0xFF4A5080)),
                ),
                child: Text(
                    emailsSelecionados.length == emailsTeste.length
                        ? 'Desmarcar todos'
                        : 'Selecionar todos',
                    style: TextStyle(
                        color: emailsSelecionados.length == emailsTeste.length
                            ? const Color(0xFF8B5CF6)
                            : const Color(0xFF8A90B0),
                        fontSize: 10,
                        fontWeight: FontWeight.w600)),
              ),
            ),
        ]),
        const SizedBox(height: 12),
        if (emailsTeste.isEmpty)
          Row(children: [
            Icon(Icons.info_outline,
                size: 14, color: Colors.amber.withOpacity(.7)),
            const SizedBox(width: 6),
            const Expanded(
                child: Text('Nenhum emailteste cadastrado para este usuário',
                    style: TextStyle(color: Color(0xFF8A90B0), fontSize: 11))),
          ])
        else
          ...emailsTeste.map((email) {
            final sel = emailsSelecionados.contains(email);
            return GestureDetector(
              onTap: () => _toggleEmail(email),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                margin: const EdgeInsets.only(bottom: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                decoration: BoxDecoration(
                  color: sel
                      ? const Color(0xFF8B5CF6).withOpacity(.1)
                      : const Color(0xFF0F1117),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: sel
                          ? const Color(0xFF8B5CF6)
                          : const Color(0xFF2C3050),
                      width: sel ? 1.5 : 1),
                ),
                child: Row(children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                        color: sel
                            ? const Color(0xFF8B5CF6)
                            : const Color(0xFF2C3050),
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                            color: sel
                                ? const Color(0xFF8B5CF6)
                                : const Color(0xFF4A5080))),
                    child: sel
                        ? const Icon(Icons.check, color: Colors.white, size: 13)
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Icon(Icons.alternate_email,
                      size: 14,
                      color: sel
                          ? const Color(0xFF8B5CF6)
                          : const Color(0xFF8A90B0)),
                  const SizedBox(width: 8),
                  Expanded(
                      child: Text(email,
                          style: TextStyle(
                              color: sel
                                  ? const Color(0xFFEEF0F8)
                                  : const Color(0xFF8A90B0),
                              fontSize: 12,
                              fontWeight:
                                  sel ? FontWeight.w600 : FontWeight.normal),
                          overflow: TextOverflow.ellipsis)),
                ]),
              ),
            );
          }),
        if (emailsTeste.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            emailsSelecionados.isEmpty
                ? 'Nenhum selecionado — email não será enviado'
                : '${emailsSelecionados.length}/${emailsTeste.length} selecionado(s) · enviado via Brevo',
            style: TextStyle(
                color: emailsSelecionados.isEmpty
                    ? const Color(0xFF8A90B0)
                    : const Color(0xFF8B5CF6),
                fontSize: 10,
                fontWeight: emailsSelecionados.isEmpty
                    ? FontWeight.normal
                    : FontWeight.w600),
          ),
        ],
      ]),
    );
  }

  // ── Helpers UI ───────────────────────────────────────────────
  Widget _rotulo(String texto, IconData icone) => Row(children: [
        Icon(icone, size: 13, color: const Color(0xFF8A90B0)),
        const SizedBox(width: 6),
        Text(texto,
            style: const TextStyle(
                color: Color(0xFF8A90B0),
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8)),
      ]);

  Widget _rotuloMini(String texto, IconData icone) => Row(children: [
        Icon(icone, size: 11, color: const Color(0xFF8A90B0)),
        const SizedBox(width: 5),
        Text(texto,
            style: const TextStyle(
                color: Color(0xFF8A90B0),
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.6)),
      ]);

  Widget _botaoSelecao(
          {required String? valor,
          required String hint,
          required IconData icone,
          required VoidCallback? onTap}) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1D27),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: valor != null
                    ? const Color(0xFF4F8EF7)
                    : const Color(0xFF2C3050)),
          ),
          child: Row(children: [
            Icon(icone,
                size: 16,
                color: valor != null
                    ? const Color(0xFF4F8EF7)
                    : const Color(0xFF8A90B0)),
            const SizedBox(width: 10),
            Expanded(
                child: Text(valor ?? hint,
                    style: TextStyle(
                        color: valor != null
                            ? const Color(0xFFEEF0F8)
                            : const Color(0xFF8A90B0),
                        fontSize: 13),
                    overflow: TextOverflow.ellipsis)),
            const Icon(Icons.keyboard_arrow_down,
                color: Color(0xFF8A90B0), size: 20),
          ]),
        ),
      );

  Widget _campoTextoCompacto({
    required TextEditingController controller,
    required String hint,
    required IconData icone,
    TextInputType tipoTeclado = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    bool forcarMaiusculo = false,
  }) =>
      Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0F1117),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: controller.text.trim().isNotEmpty
                  ? const Color(0xFF00C896)
                  : const Color(0xFF2C3050)),
        ),
        child: TextField(
          controller: controller,
          keyboardType: tipoTeclado,
          inputFormatters: inputFormatters,
          textCapitalization: forcarMaiusculo
              ? TextCapitalization.characters
              : TextCapitalization.none,
          style: const TextStyle(
              color: Color(0xFFEEF0F8),
              fontSize: 13,
              fontWeight: FontWeight.w600),
          onChanged: (v) {
            if (forcarMaiusculo) {
              final upper = v.toUpperCase();
              if (v != upper)
                controller.value = controller.value.copyWith(
                    text: upper,
                    selection: TextSelection.collapsed(offset: upper.length));
            }
            setState(() {});
          },
          decoration: InputDecoration(
              hintText: hint,
              hintStyle:
                  const TextStyle(color: Color(0xFF8A90B0), fontSize: 11),
              prefixIcon: Icon(icone, color: const Color(0xFF8A90B0), size: 14),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              isDense: true),
        ),
      );

  Widget _campoTexto({
    required TextEditingController controller,
    required String hint,
    required IconData icone,
    bool forcarMaiusculo = false,
    int maxLines = 1,
    int minLines = 1,
    Color corBorda = const Color(0xFF4F8EF7),
  }) =>
      Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A1D27),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: controller.text.trim().isNotEmpty
                  ? corBorda
                  : const Color(0xFF2C3050)),
        ),
        child: TextField(
          controller: controller,
          maxLines: maxLines,
          minLines: minLines,
          textCapitalization: forcarMaiusculo
              ? TextCapitalization.characters
              : TextCapitalization.sentences,
          style: const TextStyle(color: Color(0xFFEEF0F8), fontSize: 13),
          onChanged: (v) {
            if (forcarMaiusculo) {
              final upper = v.toUpperCase();
              if (v != upper)
                controller.value = controller.value.copyWith(
                    text: upper,
                    selection: TextSelection.collapsed(offset: upper.length));
            }
            setState(() {});
          },
          decoration: InputDecoration(
              hintText: hint,
              hintStyle:
                  const TextStyle(color: Color(0xFF8A90B0), fontSize: 12),
              prefixIcon: Icon(icone, color: const Color(0xFF8A90B0), size: 16),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 14)),
        ),
      );

  Widget _areaSelecionarArquivo() {
    if (selFile == null) {
      return GestureDetector(
        onTap: enviando ? null : _selecionarArquivo,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 28),
          decoration: BoxDecoration(
              color: const Color(0xFF1A1D27),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF2C3050))),
          child: const Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.cloud_upload_outlined,
                color: Color(0xFF8A90B0), size: 36),
            SizedBox(height: 10),
            Text('Toque para selecionar arquivo',
                style: TextStyle(
                    color: Color(0xFFEEF0F8),
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
            SizedBox(height: 4),
            Text('PDF, DOCX, XLSX, PNG, JPG',
                style: TextStyle(color: Color(0xFF8A90B0), fontSize: 11)),
          ]),
        ),
      );
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: const Color(0x0D4F8EF7),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF4F8EF7), width: 1.5)),
      child: Row(children: [
        const Icon(Icons.insert_drive_file, color: Color(0xFF4F8EF7), size: 28),
        const SizedBox(width: 12),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(selFile!.name,
              style: const TextStyle(
                  color: Color(0xFFEEF0F8),
                  fontSize: 12,
                  fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 3),
          Text(selFile!.size > 0 ? _tamanho(selFile!.size) : 'Selecionado',
              style: const TextStyle(color: Color(0xFF8A90B0), fontSize: 11)),
        ])),
        GestureDetector(
            onTap: () => setState(() => selFile = null),
            child: const Icon(Icons.close, color: Color(0xFF8A90B0), size: 18)),
      ]),
    );
  }

  Widget _previewCaminho() {
    final ext = (selFile?.extension?.isNotEmpty == true)
        ? '.${selFile!.extension}'
        : '';
    final numOS = _numeroOSCtrl.text.trim().toUpperCase();
    final nomeP = numOS.isNotEmpty
        ? 'OS_${numOS}_DD-MM-AAAA_HHhMM$ext'
        : '$_tipoFinal-DD-MM-AAAA_HHhMM$ext';
    final cam = '${selEmail!}/$_ano/$selMes/NOTAS FISCAIS/$nomeP';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: const Color(0xFF21253A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF2C3050))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(children: [
          Icon(Icons.folder_outlined, size: 13, color: Color(0xFF00C896)),
          SizedBox(width: 5),
          Text('Caminho no Storage',
              style: TextStyle(
                  color: Color(0xFF00C896),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5)),
        ]),
        const SizedBox(height: 6),
        Text(cam,
            style: const TextStyle(
                color: Color(0xFFEEF0F8), fontSize: 10, height: 1.5)),
      ]),
    );
  }

  Widget _faixa(Color cor, IconData icone, String msg) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
            color: cor.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: cor.withOpacity(0.4), width: 1.2)),
        child: Row(children: [
          Icon(icone, color: cor, size: 20),
          const SizedBox(width: 10),
          Expanded(
              child: Text(msg,
                  style: TextStyle(
                      color: cor, fontSize: 12, fontWeight: FontWeight.w500))),
        ]),
      );
}
