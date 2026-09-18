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

import 'dart:convert';
import 'dart:typed_data';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';

class GerenciarUsuariosWidget extends StatefulWidget {
  const GerenciarUsuariosWidget({
    Key? key,
    this.width,
    this.height,
    required this.imgbbApiKey,
  }) : super(key: key);

  final double? width;
  final double? height;
  final String imgbbApiKey;

  @override
  State<GerenciarUsuariosWidget> createState() =>
      _GerenciarUsuariosWidgetState();
}

class _GerenciarUsuariosWidgetState extends State<GerenciarUsuariosWidget> {
  // ─── Modo ─────────────────────────────────────────────────────────────────
  String _modo = 'busca';
  bool _modoEdicao = false;
  String? _docIdEdicao;

  // ─── Busca ────────────────────────────────────────────────────────────────
  List<Map<String, dynamic>> _usuariosList = [];
  bool _carregandoUsuarios = false;

  // ─── Controllers do Formulário ────────────────────────────────────────────
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ScrollController _listScrollCtrl = ScrollController();

  final TextEditingController _nomeCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _senhaCtrl = TextEditingController();
  final TextEditingController _telefoneCtrl = TextEditingController();
  final TextEditingController _phoneNumberCtrl = TextEditingController();
  final TextEditingController _documentoCtrl = TextEditingController();
  final TextEditingController _enderecoCtrl = TextEditingController();
  final TextEditingController _numeroCtrl = TextEditingController();
  final TextEditingController _bairroCtrl = TextEditingController();

  // ─── Variáveis ocultas (Backend apenas) ───────────────────────────────────
  String _uidAtual = '';
  String _onesignalAtual = '';

  // ─── Controller e Lista para 'emailteste' ───────────────────────────────
  final TextEditingController _novoEmailTesteCtrl = TextEditingController();
  List<String> _emailsTeste = [];

  bool _empresa = false;
  String? _tipoContratoSelecionado;

  static const List<String> _opcoesContrato = [
    'ANUAL',
    'MENSAL',
    'AVULSO',
    'PREVENTIVA MENSAL',
    'NENHUM',
  ];

  // ─── Imagem ───────────────────────────────────────────────────────────────
  String? _photoUrlAtual;
  Uint8List? _imagemBytesNova;
  bool _uploadandoImagem = false;
  bool _imagemRemovida = false;

  // ─── Progresso / Validação ────────────────────────────────────────────────
  bool _salvando = false;
  String _etapaSalvando = '';
  bool _tentouSalvar = false;

  final GlobalKey _keyNome = GlobalKey();
  final GlobalKey _keyEmail = GlobalKey();
  final GlobalKey _keySenha = GlobalKey();

  // ─── Tema (tokens escuros do LOGIN — legível no sheet #0B0F17) ────────────
  Color get _bg => const Color(0xFF0B0F17);
  Color get _card => const Color(0xFF131B2E);
  Color get _borda => const Color(0xFF1E293B);
  Color get _texto => Colors.white;
  Color get _sub => const Color(0xFF94A3B8);
  Color get _fill => const Color(0xFF0F172A);
  static const Color _roxo = Color(0xFF3B82F6);
  static const Color _verde = Color(0xFF10B981);
  static const Color _vermelho = Color(0xFFEF4444);
  static const Color _amarelo = Color(0xFFF59E0B);

  @override
  void initState() {
    super.initState();
    _carregarUsuariosBusca();
  }

  @override
  void dispose() {
    for (final c in [
      _nomeCtrl,
      _emailCtrl,
      _senhaCtrl,
      _telefoneCtrl,
      _phoneNumberCtrl,
      _documentoCtrl,
      _enderecoCtrl,
      _numeroCtrl,
      _bairroCtrl,
      _novoEmailTesteCtrl,
    ]) {
      c.dispose();
    }
    _listScrollCtrl.dispose();
    super.dispose();
  }

  // ─── Carregar dados para Busca ────────────────────────────────────────────

  Future<void> _carregarUsuariosBusca() async {
    setState(() => _carregandoUsuarios = true);
    try {
      final snap =
          await FirebaseFirestore.instance.collection('USUARIOS').get();
      final lista = <Map<String, dynamic>>[];
      for (final doc in snap.docs) {
        final d = doc.data();
        final email = (d['email'] ?? '').toString().trim();
        if (email.isNotEmpty) {
          lista.add({
            'id': doc.id,
            'email': email,
            'nome': (d['display_name'] ?? '').toString(),
            'dados': d,
          });
        }
      }
      lista.sort((a, b) => a['email'].compareTo(b['email']));
      setState(() => _usuariosList = lista);
    } catch (e) {
      debugPrint('Erro ao carregar usuários: $e');
    } finally {
      setState(() => _carregandoUsuarios = false);
    }
  }

  // ─── Preencher Formulario ─────────────────────────────────────────────────

  void _iniciarNovo() {
    _limparFormulario();
    setState(() {
      _modoEdicao = false;
      _modo = 'form';
    });
  }

  void _iniciarEdicao(Map<String, dynamic> usuarioMap) {
    _limparFormulario();
    final d = usuarioMap['dados'] as Map<String, dynamic>;

    _docIdEdicao = usuarioMap['id'];
    _nomeCtrl.text = (d['display_name'] ?? '').toString().toUpperCase();
    _emailCtrl.text = (d['email'] ?? '').toString().toLowerCase();
    _senhaCtrl.text = (d['senha'] ?? '').toString();
    _telefoneCtrl.text = (d['TELEFONE'] ?? '').toString();
    _phoneNumberCtrl.text = (d['phone_number'] ?? '').toString();

    final cnpjStr = (d['CNPJ'] ?? '').toString();
    final cpfStr = (d['CPF'] ?? '').toString();
    _documentoCtrl.text = cnpjStr.isNotEmpty ? cnpjStr : cpfStr;

    _enderecoCtrl.text = (d['ENDERECO'] ?? '').toString().toUpperCase();
    _numeroCtrl.text = (d['NUMERO'] ?? '').toString().toUpperCase();
    _bairroCtrl.text = (d['BAIIRO'] ?? '').toString().toUpperCase();

    _uidAtual = (d['uid'] ?? '').toString();
    _onesignalAtual = (d['ONESIGNAL'] ?? '').toString();

    if (d['emailteste'] != null && d['emailteste'] is List) {
      _emailsTeste = (d['emailteste'] as List)
          .map((e) => e.toString().toLowerCase())
          .toList();
    }

    _empresa = d['empresa'] == true || d['empresa'] == 'true';

    final tc = (d['tipodecontrato'] ?? '').toString().toUpperCase();
    _tipoContratoSelecionado = _opcoesContrato.contains(tc) ? tc : null;

    final url = (d['photo_url'] ?? '').toString();
    if (url.isNotEmpty && !url.contains('Erro: 400')) {
      _photoUrlAtual = url;
    }

    setState(() {
      _modoEdicao = true;
      _modo = 'form';
    });
  }

  void _limparFormulario() {
    for (final c in [
      _nomeCtrl,
      _emailCtrl,
      _senhaCtrl,
      _telefoneCtrl,
      _phoneNumberCtrl,
      _documentoCtrl,
      _enderecoCtrl,
      _numeroCtrl,
      _bairroCtrl,
      _novoEmailTesteCtrl,
    ]) {
      c.clear();
    }
    _uidAtual = '';
    _onesignalAtual = '';
    _emailsTeste.clear();
    _empresa = false;
    _tipoContratoSelecionado = null;
    _photoUrlAtual = null;
    _imagemBytesNova = null;
    _imagemRemovida = false;
    _docIdEdicao = null;
    _tentouSalvar = false;
  }

  // ─── Selecionar imagem ────────────────────────────────────────────────────

  Future<void> _selecionarImagem() async {
    final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery, imageQuality: 80, maxWidth: 800);
    if (picked == null) return;

    setState(() => _uploadandoImagem = true);
    try {
      final bytes = await picked.readAsBytes();
      setState(() {
        _imagemBytesNova = bytes;
        _imagemRemovida = false;
      });
    } catch (e) {
      _snack('❌ Erro ao ler a imagem: $e', _vermelho);
    } finally {
      setState(() => _uploadandoImagem = false);
    }
  }

  // ─── Salvar ───────────────────────────────────────────────────────────────

  Future<void> _salvar() async {
    setState(() => _tentouSalvar = true);

    if (_nomeCtrl.text.trim().isEmpty) {
      _rolarPara(_keyNome);
      return;
    }
    if (_emailCtrl.text.trim().isEmpty || !_emailCtrl.text.contains('@')) {
      _rolarPara(_keyEmail);
      _snack('Insira um e-mail válido', _vermelho);
      return;
    }
    if (!_modoEdicao && _senhaCtrl.text.trim().length < 6) {
      _rolarPara(_keySenha);
      _snack('A senha precisa ter pelo menos 6 caracteres', _vermelho);
      return;
    }

    final email = _emailCtrl.text.trim().toLowerCase(); // Força minúsculo

    if (!_modoEdicao) {
      setState(() {
        _salvando = true;
        _etapaSalvando = 'Verificando e-mail...';
      });
      final existe = await FirebaseFirestore.instance
          .collection('USUARIOS')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
      if (existe.docs.isNotEmpty) {
        setState(() => _salvando = false);
        _snack('⚠️ O e-mail $email já está cadastrado no BD!', _amarelo);
        return;
      }
    } else {
      setState(() => _salvando = true);
    }

    try {
      if (!_modoEdicao) {
        setState(() => _etapaSalvando = 'Criando Autenticação...');
        try {
          FirebaseApp tempApp = await Firebase.initializeApp(
            name: 'tempSession_${DateTime.now().millisecondsSinceEpoch}',
            options: Firebase.app().options,
          );

          UserCredential userCred = await FirebaseAuth.instanceFor(app: tempApp)
              .createUserWithEmailAndPassword(
            email: email,
            password: _senhaCtrl.text.trim(),
          );

          _uidAtual = userCred.user!.uid;
          await userCred.user!
              .updateDisplayName(_nomeCtrl.text.trim().toUpperCase());
          await tempApp.delete();
        } catch (authError) {
          throw Exception('Erro no Authentication: $authError');
        }
      }

      String finalPhotoUrl = _imagemRemovida ? '' : (_photoUrlAtual ?? '');

      if (_imagemBytesNova != null && !_imagemRemovida) {
        setState(() => _etapaSalvando = 'Salvando foto de perfil...');
        final base64Str = base64Encode(_imagemBytesNova!);
        final nomeArquivo = email.replaceAll('@', '_').replaceAll('.', '_');

        final res = await http.post(
          Uri.parse(
              'https://api.imgbb.com/1/upload?key=${widget.imgbbApiKey}&name=${Uri.encodeComponent(nomeArquivo)}'),
          body: {
            'image': base64Str,
            'name': nomeArquivo,
          },
        );
        if (res.statusCode == 200) {
          finalPhotoUrl = jsonDecode(res.body)['data']['url'] as String;
        } else {
          throw Exception('imgBB erro ${res.statusCode}');
        }
      }

      setState(() => _etapaSalvando = 'Salvando dados do usuário...');
      final fs = FirebaseFirestore.instance;

      final dados = {
        'display_name':
            _nomeCtrl.text.trim().toUpperCase(), // Forçado em maiúsculo
        'email': email,
        'senha': _senhaCtrl.text.trim(),
        'TELEFONE': _telefoneCtrl.text.trim(),
        'phone_number': _phoneNumberCtrl.text.trim(),
        'CNPJ': _empresa ? _documentoCtrl.text.trim() : '',
        'CPF': !_empresa ? _documentoCtrl.text.trim() : '',
        'ENDERECO': _enderecoCtrl.text.trim().toUpperCase(),
        'NUMERO': _numeroCtrl.text.trim().toUpperCase(),
        'BAIIRO': _bairroCtrl.text.trim().toUpperCase(),
        'emailteste': _emailsTeste,
        'ONESIGNAL': _onesignalAtual,
        'uid': _uidAtual,
        'empresa': _empresa,
        'tipodecontrato': _tipoContratoSelecionado ?? '',
        'photo_url': finalPhotoUrl,
      };

      if (_modoEdicao && _docIdEdicao != null) {
        await fs.collection('USUARIOS').doc(_docIdEdicao).update(dados);
      } else {
        await fs.collection('USUARIOS').add(dados);
      }

      setState(() => _etapaSalvando = 'Concluído! ✅');
      await Future.delayed(const Duration(milliseconds: 500));
      _snack(_modoEdicao ? '✅ Usuário atualizado!' : '✅ Usuário cadastrado!',
          _verde);

      await _carregarUsuariosBusca();
      setState(() {
        _modo = 'busca';
        _limparFormulario();
      });
    } catch (e) {
      _snack('❌ Erro: $e', _vermelho);
    } finally {
      setState(() {
        _salvando = false;
        _etapaSalvando = '';
      });
    }
  }

  void _rolarPara(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(ctx,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOut,
        alignment: 0.1);
  }

  void _snack(String msg, Color cor) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(color: Colors.white)),
      backgroundColor: cor,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  // =========================================================================
  //  BUILD
  // =========================================================================

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _bg,
      child: SafeArea(
        child: SizedBox(
          width: widget.width ?? double.infinity,
          height: widget.height ?? double.infinity,
          child: _modo == 'busca' ? _buildTelaBusca() : _buildTelaForm(),
        ),
      ),
    );
  }

  // ─── TELA BUSCA ───────────────────────────────────────────────────────────

  Widget _buildTelaBusca() {
    return Column(children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: _card,
          border: Border(bottom: BorderSide(color: _borda)),
        ),
        child: Row(children: [
          _iconBox(Icons.people_alt, _roxo),
          const SizedBox(width: 12),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text('Gerenciar Usuários',
                    style: GoogleFonts.interTight(
                        color: _texto,
                        fontSize: 16,
                        fontWeight: FontWeight.w700)),
                Text('Coleção USUARIOS e Auth',
                    style: TextStyle(color: _sub, fontSize: 11)),
              ])),
        ]),
      ),
      Expanded(
          child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
            20, 20, 20, 20 + MediaQuery.of(context).padding.bottom),
        child: Column(children: [
          _card_(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Row(children: [
                  Icon(Icons.edit_document, color: _roxo, size: 20),
                  const SizedBox(width: 8),
                  Text('Editar Usuário Existente',
                      style: TextStyle(
                          color: _texto,
                          fontSize: 15,
                          fontWeight: FontWeight.bold)),
                ]),
                const SizedBox(height: 10),
                Text('Selecione o e-mail do usuário que deseja atualizar.',
                    style: TextStyle(color: _sub, fontSize: 13)),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: _carregandoUsuarios ? null : _openSearchSheet,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      color: _fill,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _borda),
                    ),
                    child: Row(children: [
                      Icon(Icons.search, color: _sub, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                          child: _carregandoUsuarios
                              ? Text('Carregando usuários...',
                                  style: TextStyle(color: _sub, fontSize: 13))
                              : Text('Buscar por e-mail...',
                                  style: TextStyle(color: _sub, fontSize: 13))),
                      Icon(Icons.arrow_drop_down, color: _sub),
                    ]),
                  ),
                ),
              ])),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(child: Divider(color: _borda)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text('OU',
                  style: TextStyle(
                      color: _sub, fontSize: 12, fontWeight: FontWeight.bold)),
            ),
            Expanded(child: Divider(color: _borda)),
          ]),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: _iniciarNovo,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: _verde.withAlpha(25),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _verde.withAlpha(120)),
              ),
              child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.person_add_alt_1, color: _verde, size: 22),
                    SizedBox(width: 8),
                    Text('Cadastrar Novo Usuário',
                        style: TextStyle(
                            color: _verde,
                            fontSize: 15,
                            fontWeight: FontWeight.bold)),
                  ]),
            ),
          ),
        ]),
      )),
    ]);
  }

  void _openSearchSheet() {
    final ctrl = TextEditingController();
    List<Map<String, dynamic>> lista = List.from(_usuariosList);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: _card,
      isDismissible: true,
      enableDrag: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (_, sm) => DraggableScrollableSheet(
          initialChildSize: 0.7,
          maxChildSize: 0.9,
          minChildSize: 0.25,
          shouldCloseOnMinExtent: true,
          expand: false,
          builder: (_, sc) => Column(children: [
            Container(
              margin: const EdgeInsets.only(top: 10, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: _borda, borderRadius: BorderRadius.circular(2)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: Row(children: [
                Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                        color: _roxo.withAlpha(30),
                        borderRadius: BorderRadius.circular(8)),
                    child: Icon(Icons.alternate_email, color: _roxo, size: 18)),
                const SizedBox(width: 10),
                Expanded(
                    child: Text('Selecionar Usuário',
                        style: TextStyle(
                            color: _texto,
                            fontSize: 15,
                            fontWeight: FontWeight.bold))),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                    color: _fill,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _borda)),
                child: Row(children: [
                  Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Icon(Icons.search, color: _sub, size: 18)),
                  Expanded(
                      child: TextField(
                    controller: ctrl,
                    style: TextStyle(color: _texto, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Digite o e-mail ou nome...',
                      hintStyle: TextStyle(color: _sub, fontSize: 13),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                    onChanged: (v) => sm(() {
                      lista = _usuariosList.where((e) {
                        final mail = e['email'].toString().toLowerCase();
                        final nome = e['nome'].toString().toLowerCase();
                        final term = v.toLowerCase();
                        return mail.contains(term) || nome.contains(term);
                      }).toList();
                    }),
                  )),
                ]),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
                child: lista.isEmpty
                    ? Center(
                        child: Text('Nenhum usuário encontrado.',
                            style: TextStyle(color: _sub)))
                    : ListView.separated(
                        controller: sc,
                        itemCount: lista.length,
                        separatorBuilder: (_, __) =>
                            Divider(color: _borda, height: 1),
                        itemBuilder: (c, i) {
                          final usr = lista[i];
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 4),
                            leading: CircleAvatar(
                              backgroundColor: _roxo.withAlpha(30),
                              child: Icon(Icons.person, color: _roxo),
                            ),
                            title: Text(usr['email'],
                                style: TextStyle(
                                    color: _texto,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14)),
                            subtitle: Text(
                                usr['nome'].toString().isEmpty
                                    ? 'Sem nome'
                                    : usr['nome'],
                                style: TextStyle(color: _sub, fontSize: 12)),
                            trailing: Icon(Icons.chevron_right, color: _sub),
                            onTap: () {
                              Navigator.pop(ctx);
                              _iniciarEdicao(usr);
                            },
                          );
                        })),
          ]),
        ),
      ),
    );
  }

  // ─── TELA FORM ────────────────────────────────────────────────────────────

  Widget _buildTelaForm() {
    return Stack(children: [
      Column(children: [
        _buildHeaderForm(),
        Expanded(
            child: Form(
          key: _formKey,
          child: ListView(
            controller: _listScrollCtrl,
            padding: EdgeInsets.fromLTRB(
                16, 16, 16, 16 + MediaQuery.of(context).padding.bottom),
            children: [
              // ── Foto ──
              _sec('🖼️ Foto de Perfil (photo_url)'),
              const SizedBox(height: 10),
              _buildCardImagem(),
              const SizedBox(height: 20),

              // ── Dados Básicos ──
              _sec('👤 Dados Básicos e Auth'),
              const SizedBox(height: 10),
              _card_(
                  child: Column(children: [
                KeyedSubtree(
                  key: _keyNome,
                  child: _input(
                      ctrl: _nomeCtrl,
                      label: 'Nome (display_name) *',
                      icon: Icons.person_outline,
                      upper: true,
                      erro: _tentouSalvar && _nomeCtrl.text.isEmpty),
                ),
                const SizedBox(height: 12),
                KeyedSubtree(
                  key: _keyEmail,
                  child: _input(
                      ctrl: _emailCtrl,
                      label: 'E-mail principal *',
                      icon: Icons.email_outlined,
                      tipo: TextInputType.emailAddress,
                      erro: _tentouSalvar && _emailCtrl.text.isEmpty),
                ),
                const SizedBox(height: 12),
                KeyedSubtree(
                  key: _keySenha,
                  child: _input(
                      ctrl: _senhaCtrl,
                      label: 'Senha (mínimo 6 caracteres)',
                      icon: Icons.lock_outline,
                      erro: _tentouSalvar &&
                          !_modoEdicao &&
                          _senhaCtrl.text.length < 6),
                ),
              ])),
              const SizedBox(height: 20),

              // ── Contato ──
              _sec('📞 Contato'),
              const SizedBox(height: 10),
              _card_(
                  child: Column(children: [
                _input(
                  ctrl: _telefoneCtrl,
                  label: 'Telefone Principal',
                  icon: Icons.phone_outlined,
                  tipo: TextInputType.number,
                  formatters: [TelefoneInputFormatter()],
                ),
                const SizedBox(height: 12),
                _input(
                  ctrl: _phoneNumberCtrl,
                  label: 'Phone Number (Secundário)',
                  icon: Icons.phone_android_outlined,
                  tipo: TextInputType.number,
                  formatters: [TelefoneInputFormatter()],
                ),
                const SizedBox(height: 20),

                // --- SEÇÃO: Lista de E-mails Teste ---
                _buildListaEmailsTeste(),
              ])),
              const SizedBox(height: 20),

              // ── Endereço ──
              _sec('📍 Endereço'),
              const SizedBox(height: 10),
              _card_(
                  child: Column(children: [
                _input(
                    ctrl: _enderecoCtrl,
                    label: 'Endereço',
                    icon: Icons.map_outlined,
                    upper: true),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(
                      flex: 2,
                      child: _input(
                          ctrl: _numeroCtrl,
                          label: 'Número',
                          icon: Icons.numbers,
                          upper: true)),
                  const SizedBox(width: 12),
                  Expanded(
                      flex: 3,
                      child: _input(
                          ctrl: _bairroCtrl,
                          label: 'Bairro (BAIIRO)',
                          icon: Icons.location_city_outlined,
                          upper: true)),
                ]),
              ])),
              const SizedBox(height: 20),

              // ── Comercial ──
              _sec('🏢 Informações Comerciais'),
              const SizedBox(height: 10),
              _card_(
                  child: Column(children: [
                _buildCheckboxEmpresa(),
                const SizedBox(height: 16),
                _input(
                  ctrl: _documentoCtrl,
                  label: _empresa ? 'CNPJ' : 'CPF',
                  icon:
                      _empresa ? Icons.business_outlined : Icons.badge_outlined,
                  tipo: TextInputType.number,
                  formatters: [CpfCnpjInputFormatter(isCnpj: _empresa)],
                ),
                const SizedBox(height: 12),
                _buildSeletorContrato(),
              ])),
              const SizedBox(height: 32),

              _buildBtnSalvar(),
              const SizedBox(height: 24),
            ],
          ),
        )),
      ]),
      if (_salvando)
        Container(
          color: Colors.black.withAlpha(175),
          child: Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 40),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 36),
              decoration: BoxDecoration(
                color: _card,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                CircularProgressIndicator(color: _roxo, strokeWidth: 5),
                const SizedBox(height: 24),
                Text(_etapaSalvando.isEmpty ? 'Processando...' : _etapaSalvando,
                    style: TextStyle(
                        color: _texto,
                        fontSize: 15,
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center),
              ]),
            ),
          ),
        ),
    ]);
  }

  Widget _buildHeaderForm() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _card,
        border: Border(bottom: BorderSide(color: _borda)),
      ),
      child: Row(children: [
        GestureDetector(
          onTap: () => setState(() {
            _modo = 'busca';
            _limparFormulario();
          }),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _fill,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _borda),
            ),
            child: Icon(Icons.arrow_back_ios_new, color: _texto, size: 15),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _modoEdicao ? _amarelo : _verde,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(_modoEdicao ? Icons.edit : Icons.person_add,
              color: Colors.white, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(_modoEdicao ? 'Editar Usuário' : 'Novo Usuário',
              style: GoogleFonts.interTight(
                  color: _texto, fontSize: 15, fontWeight: FontWeight.w700)),
          Text(_modoEdicao ? _emailCtrl.text : 'Preencha os dados',
              style: TextStyle(color: _sub, fontSize: 11),
              overflow: TextOverflow.ellipsis),
        ])),
      ]),
    );
  }

  Widget _buildCardImagem() {
    final bool temNovaLocal = _imagemBytesNova != null && !_imagemRemovida;
    final String? urlAtual = _imagemRemovida ? null : _photoUrlAtual;
    final bool temQualquerImagem = temNovaLocal || urlAtual != null;

    return _card_(
        child: Row(children: [
      AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: _borda,
          shape: BoxShape.circle,
          border:
              Border.all(color: temQualquerImagem ? _roxo : _borda, width: 2),
        ),
        clipBehavior: Clip.antiAlias,
        child: _uploadandoImagem
            ? const Center(
                child: CircularProgressIndicator(color: _roxo, strokeWidth: 2))
            : temNovaLocal
                ? Image.memory(_imagemBytesNova!, fit: BoxFit.cover)
                : urlAtual != null
                    ? Image.network(urlAtual,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            Icon(Icons.broken_image, color: _sub))
                    : Icon(Icons.person, color: _sub, size: 40),
      ),
      const SizedBox(width: 16),
      Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(temQualquerImagem ? 'Foto adicionada' : 'Nenhuma foto',
            style: TextStyle(
                color: _texto, fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        Row(children: [
          GestureDetector(
            onTap: _selecionarImagem,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                  color: _roxo.withAlpha(25),
                  borderRadius: BorderRadius.circular(8)),
              child: Text(temQualquerImagem ? 'Trocar' : 'Adicionar',
                  style: TextStyle(
                      color: _roxo, fontSize: 11, fontWeight: FontWeight.bold)),
            ),
          ),
          if (temQualquerImagem) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => setState(() {
                _imagemRemovida = true;
                _imagemBytesNova = null;
              }),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                    color: _vermelho.withAlpha(25),
                    borderRadius: BorderRadius.circular(8)),
                child: const Text('Remover',
                    style: TextStyle(
                        color: _vermelho,
                        fontSize: 11,
                        fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ]),
      ])),
    ]));
  }

  Widget _buildListaEmailsTeste() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Icon(Icons.checklist_rtl_outlined, color: _sub, size: 16),
          const SizedBox(width: 8),
          Text('E-mails Adicionais / Relatório (emailteste)',
              style: TextStyle(
                  color: _sub, fontSize: 12, fontWeight: FontWeight.w500)),
        ]),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _input(
                ctrl: _novoEmailTesteCtrl,
                label: 'Adicionar E-mail',
                icon: Icons.alternate_email,
                tipo: TextInputType.emailAddress,
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                final novoEmail = _novoEmailTesteCtrl.text.trim().toLowerCase();
                if (novoEmail.isEmpty || !novoEmail.contains('@')) {
                  _snack('Insira um e-mail válido para adicionar.', _vermelho);
                  return;
                }
                if (_emailsTeste.contains(novoEmail)) {
                  _snack('E-mail já está na lista.', _amarelo);
                  return;
                }
                setState(() {
                  _emailsTeste.add(novoEmail);
                  _novoEmailTesteCtrl.clear();
                });
              },
              child: Container(
                height: 52,
                width: 52,
                decoration: BoxDecoration(
                  color: _roxo,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 28),
              ),
            ),
          ],
        ),
        if (_emailsTeste.isNotEmpty) ...[
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _emailsTeste.map((email) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: _roxo.withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _roxo.withAlpha(60)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(email, style: TextStyle(color: _texto, fontSize: 13)),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => setState(() => _emailsTeste.remove(email)),
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                            color: _vermelho.withAlpha(30),
                            shape: BoxShape.circle),
                        child:
                            const Icon(Icons.close, color: _vermelho, size: 14),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildCheckboxEmpresa() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _empresa = !_empresa;
          _documentoCtrl.clear();
        });
      },
      child: Row(children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: _empresa ? _roxo : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _empresa ? _roxo : _sub.withAlpha(150),
              width: 2,
            ),
          ),
          child: _empresa
              ? const Icon(Icons.check, color: Colors.white, size: 18)
              : null,
        ),
        const SizedBox(width: 12),
        Text('Empresa?',
            style: TextStyle(
                color: _texto, fontSize: 16, fontWeight: FontWeight.w600)),
      ]),
    );
  }

  Widget _buildSeletorContrato() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Icon(Icons.assignment_outlined, color: _sub, size: 16),
        const SizedBox(width: 8),
        Text('Tipo de Contrato',
            style: TextStyle(
                color: _sub, fontSize: 12, fontWeight: FontWeight.w500)),
      ]),
      const SizedBox(height: 8),
      GestureDetector(
        onTap: _openContratoSheet,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: _fill,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: _tipoContratoSelecionado != null
                    ? _roxo.withAlpha(150)
                    : _borda),
          ),
          child: Row(children: [
            Expanded(
                child: Text(_tipoContratoSelecionado ?? 'Selecionar tipo...',
                    style: TextStyle(
                        color: _tipoContratoSelecionado != null ? _texto : _sub,
                        fontSize: 13))),
            Icon(Icons.expand_more, color: _sub, size: 20),
          ]),
        ),
      ),
    ]);
  }

  void _openContratoSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: _card,
      isDismissible: true,
      enableDrag: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: _borda, borderRadius: BorderRadius.circular(2))),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 4, 0),
            child: Row(children: [
              Expanded(
                child: Text('Tipo de Contrato',
                    style: TextStyle(
                        color: _texto,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
              ),
            ]),
          ),
          ..._opcoesContrato.map((op) {
            final sel = op == _tipoContratoSelecionado;
            return ListTile(
              leading: Icon(sel ? Icons.check_circle : Icons.circle_outlined,
                  color: sel ? _roxo : _sub),
              title: Text(op,
                  style: TextStyle(
                      color: sel ? _roxo : _texto,
                      fontWeight: sel ? FontWeight.bold : FontWeight.normal)),
              onTap: () {
                setState(() => _tipoContratoSelecionado = op);
                Navigator.pop(ctx);
              },
            );
          }),
        ]),
      ),
    );
  }

  Widget _buildBtnSalvar() {
    return GestureDetector(
      onTap: _salvar,
      child: Container(
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          color: _modoEdicao ? _amarelo : _verde,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(_modoEdicao ? Icons.save : Icons.check_circle_outline,
              color: Colors.white, size: 20),
          const SizedBox(width: 10),
          Text(_modoEdicao ? 'Salvar Alterações' : 'Cadastrar Usuário',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold)),
        ]),
      ),
    );
  }

  // ─── Helpers UI ───────────────────────────────────────────────────────────

  Widget _sec(String t) => Padding(
        padding: const EdgeInsets.only(left: 2, bottom: 2),
        child: Text(t,
            style: TextStyle(
                color: _texto, fontSize: 13, fontWeight: FontWeight.bold)),
      );

  Widget _card_({required Widget child}) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _borda),
        ),
        child: child,
      );

  Widget _iconBox(IconData icon, Color cor) => Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
            color: cor.withAlpha(30), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: cor, size: 20),
      );

  Widget _input({
    required TextEditingController ctrl,
    required String label,
    required IconData icon,
    TextInputType tipo = TextInputType.text,
    bool erro = false,
    bool readOnly = false,
    bool upper = false, // <-- Propriedade que força maiúsculas
    List<TextInputFormatter>? formatters,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: tipo,
      readOnly: readOnly,
      inputFormatters: formatters,
      textCapitalization:
          upper ? TextCapitalization.characters : TextCapitalization.none,
      onChanged: (v) {
        if (upper) {
          final u = v.toUpperCase();
          if (u != v) {
            ctrl.value = TextEditingValue(
                text: u, selection: TextSelection.collapsed(offset: u.length));
          }
        }
        if (erro) setState(() {});
      },
      style: TextStyle(color: _texto, fontSize: 13),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: erro ? _vermelho : _sub, fontSize: 12),
        prefixIcon: Icon(icon, color: erro ? _vermelho : _sub, size: 18),
        filled: true,
        fillColor: readOnly
            ? _borda.withAlpha(50)
            : erro
                ? _vermelho.withAlpha(15)
                : _fill,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: erro ? _vermelho : _borda)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: erro ? _vermelho : _borda)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                BorderSide(color: erro ? _vermelho : _roxo, width: 1.5)),
      ),
    );
  }
}

// ─── CLasses Para Formatação (MÁSCARAS) ───────────────────────────────────

class TelefoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digits.length > 11) digits = digits.substring(0, 11);

    String formatted = '';
    if (digits.isNotEmpty) {
      formatted = '(' + digits;
      if (digits.length > 2) {
        formatted = '(' + digits.substring(0, 2) + ') ' + digits.substring(2);
      }
      if (digits.length > 6) {
        if (digits.length == 11) {
          formatted = '(' +
              digits.substring(0, 2) +
              ') ' +
              digits.substring(2, 7) +
              '-' +
              digits.substring(7);
        } else {
          formatted = '(' +
              digits.substring(0, 2) +
              ') ' +
              digits.substring(2, 6) +
              '-' +
              digits.substring(6);
        }
      }
    }
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class CpfCnpjInputFormatter extends TextInputFormatter {
  final bool isCnpj;
  CpfCnpjInputFormatter({required this.isCnpj});

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    int maxLength = isCnpj ? 14 : 11;
    if (digits.length > maxLength) digits = digits.substring(0, maxLength);

    String formatted = '';
    if (isCnpj) {
      if (digits.isNotEmpty) {
        formatted = digits;
        if (digits.length > 2)
          formatted = digits.substring(0, 2) + '.' + digits.substring(2);
        if (digits.length > 5)
          formatted = formatted.substring(0, 6) + '.' + digits.substring(5);
        if (digits.length > 8)
          formatted = formatted.substring(0, 10) + '/' + digits.substring(8);
        if (digits.length > 12)
          formatted = formatted.substring(0, 15) + '-' + digits.substring(12);
      }
    } else {
      if (digits.isNotEmpty) {
        formatted = digits;
        if (digits.length > 3)
          formatted = digits.substring(0, 3) + '.' + digits.substring(3);
        if (digits.length > 6)
          formatted = formatted.substring(0, 7) + '.' + digits.substring(6);
        if (digits.length > 9)
          formatted = formatted.substring(0, 11) + '-' + digits.substring(9);
      }
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
