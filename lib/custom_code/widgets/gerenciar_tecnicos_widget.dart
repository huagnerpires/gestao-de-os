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

import 'dart:convert';
import 'dart:typed_data';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class GerenciarTecnicosWidget extends StatefulWidget {
  const GerenciarTecnicosWidget({
    Key? key,
    this.width,
    this.height,
    this.imgbbApiKey = '69b75a9be0857deaa943296636aca90a',
  }) : super(key: key);

  final double? width;
  final double? height;
  final String imgbbApiKey;

  @override
  State<GerenciarTecnicosWidget> createState() =>
      _GerenciarTecnicosWidgetState();
}

class _GerenciarTecnicosWidgetState extends State<GerenciarTecnicosWidget> {
  // ─── Modo ─────────────────────────────────────────────────────────────────
  String _modo = 'busca';
  bool _modoEdicao = false;
  String? _docIdEdicao;
  double _pontosAtual = 0.0;

  // ─── Busca ────────────────────────────────────────────────────────────────
  final TextEditingController _buscaCtrl = TextEditingController();
  List<Map<String, dynamic>> _tecnicosList = [];
  bool _carregandoTecnicos = false;
  String _filtro = '';

  // ─── Controllers do Formulário ────────────────────────────────────────────
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ScrollController _listScrollCtrl = ScrollController();
  final TextEditingController _nomeCtrl = TextEditingController();
  final TextEditingController _senhaCtrl = TextEditingController();
  final GlobalKey _keyNome = GlobalKey();

  // ─── Imagem ───────────────────────────────────────────────────────────────
  String? _photoUrlAtual;
  Uint8List? _imagemBytesNova;
  bool _uploadandoImagem = false;
  bool _imagemRemovida = false;

  // ─── Progresso / Validação ────────────────────────────────────────────────
  bool _salvando = false;
  String _etapaSalvando = '';
  bool _tentouSalvar = false;
  bool _excluindo = false;

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
    _carregarTecnicosBusca();
  }

  @override
  void dispose() {
    _buscaCtrl.dispose();
    _nomeCtrl.dispose();
    _senhaCtrl.dispose();
    _listScrollCtrl.dispose();
    super.dispose();
  }

  bool _fotoValida(String? url) {
    if (url == null) return false;
    final u = url.trim();
    return u.startsWith('http') && !u.contains('Erro:');
  }

  String _iniciais(String nome) {
    final parts = nome
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  String _fmtPontos(double p) {
    if (p == p.roundToDouble()) return p.toInt().toString();
    return p.toStringAsFixed(1);
  }

  List<Map<String, dynamic>> get _tecnicosFiltrados {
    final term = _filtro.trim().toLowerCase();
    if (term.isEmpty) return _tecnicosList;
    return _tecnicosList
        .where((t) => t['nome'].toString().toLowerCase().contains(term))
        .toList();
  }

  // ─── Carregar dados para Busca ────────────────────────────────────────────

  Future<void> _carregarTecnicosBusca() async {
    setState(() => _carregandoTecnicos = true);
    try {
      final records = await queryPontosPorTecnicoRecordOnce();
      final lista = <Map<String, dynamic>>[];
      for (final r in records) {
        lista.add({
          'id': r.reference.id,
          'nome': r.tecnico,
          'foto': r.foto,
          'senha': r.senha,
          'pontos': r.pontos,
        });
      }
      lista.sort((a, b) =>
          a['nome'].toString().toUpperCase().compareTo(
                b['nome'].toString().toUpperCase(),
              ));
      if (!mounted) return;
      setState(() => _tecnicosList = lista);
    } catch (e) {
      debugPrint('Erro ao carregar técnicos: $e');
      _snack('❌ Erro ao carregar técnicos: $e', _vermelho);
    } finally {
      if (mounted) setState(() => _carregandoTecnicos = false);
    }
  }

  // ─── Preencher Formulário ─────────────────────────────────────────────────

  void _iniciarNovo() {
    _limparFormulario();
    setState(() {
      _modoEdicao = false;
      _modo = 'form';
    });
  }

  void _iniciarEdicao(Map<String, dynamic> tecnicoMap) {
    _limparFormulario();
    _docIdEdicao = tecnicoMap['id']?.toString();
    _nomeCtrl.text = tecnicoMap['nome'].toString().toUpperCase();
    _senhaCtrl.text = (tecnicoMap['senha'] ?? '').toString();
    _pontosAtual = (tecnicoMap['pontos'] is num)
        ? (tecnicoMap['pontos'] as num).toDouble()
        : 0.0;

    final url = (tecnicoMap['foto'] ?? '').toString();
    if (_fotoValida(url)) {
      _photoUrlAtual = url.trim();
    }

    setState(() {
      _modoEdicao = true;
      _modo = 'form';
    });
  }

  void _limparFormulario() {
    _nomeCtrl.clear();
    _senhaCtrl.clear();
    _photoUrlAtual = null;
    _imagemBytesNova = null;
    _imagemRemovida = false;
    _docIdEdicao = null;
    _pontosAtual = 0.0;
    _tentouSalvar = false;
  }

  // ─── Selecionar imagem ────────────────────────────────────────────────────

  Future<void> _selecionarImagem() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 800,
    );
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
      if (mounted) setState(() => _uploadandoImagem = false);
    }
  }

  Future<String> _enviarFotoImgBb(Uint8List bytes, String nomeArquivo) async {
    final base64Str = base64Encode(bytes);
    final res = await http.post(
      Uri.parse(
          'https://api.imgbb.com/1/upload?key=${widget.imgbbApiKey}&name=${Uri.encodeComponent(nomeArquivo)}'),
      body: {
        'image': base64Str,
        'name': nomeArquivo,
      },
    );
    if (res.statusCode != 200) {
      throw Exception('imgBB erro ${res.statusCode}');
    }
    final url = jsonDecode(res.body)['data']['url'] as String?;
    if (!_fotoValida(url)) {
      throw Exception('URL de foto inválida');
    }
    return url!.trim();
  }

  // ─── Salvar ───────────────────────────────────────────────────────────────

  Future<void> _salvar() async {
    setState(() => _tentouSalvar = true);

    if (_nomeCtrl.text.trim().isEmpty) {
      _rolarPara(_keyNome);
      _snack('Informe o nome do técnico', _vermelho);
      return;
    }

    setState(() {
      _salvando = true;
      _etapaSalvando = _modoEdicao ? 'Atualizando técnico...' : 'Salvando técnico...';
    });

    try {
      String finalPhotoUrl = _imagemRemovida ? '' : (_photoUrlAtual ?? '');
      if (!_fotoValida(finalPhotoUrl)) {
        finalPhotoUrl = '';
      }

      if (_imagemBytesNova != null && !_imagemRemovida) {
        setState(() => _etapaSalvando = 'Salvando foto...');
        final nomeArquivo = _nomeCtrl.text
            .trim()
            .toUpperCase()
            .replaceAll(RegExp(r'\s+'), '_');
        finalPhotoUrl = await _enviarFotoImgBb(_imagemBytesNova!, nomeArquivo);
      }

      setState(() => _etapaSalvando = 'Salvando dados do técnico...');
      final dados = createPontosPorTecnicoRecordData(
        tecnico: _nomeCtrl.text.trim().toUpperCase(),
        foto: finalPhotoUrl,
        senha: _senhaCtrl.text.trim(),
        pontos: _modoEdicao ? _pontosAtual : 0.0,
      );

      if (_modoEdicao && _docIdEdicao != null) {
        await PontosPorTecnicoRecord.collection.doc(_docIdEdicao).update(dados);
      } else {
        await PontosPorTecnicoRecord.collection.doc().set(dados);
      }

      setState(() => _etapaSalvando = 'Concluído! ✅');
      await Future.delayed(const Duration(milliseconds: 400));
      _snack(
        _modoEdicao ? '✅ Técnico atualizado!' : '✅ Técnico cadastrado!',
        _verde,
      );

      await _carregarTecnicosBusca();
      if (!mounted) return;
      setState(() {
        _modo = 'busca';
        _limparFormulario();
      });
    } catch (e) {
      _snack('❌ Erro ao salvar: $e', _vermelho);
    } finally {
      if (mounted) {
        setState(() {
          _salvando = false;
          _etapaSalvando = '';
        });
      }
    }
  }

  Future<void> _confirmarExcluir() async {
    if (!_modoEdicao || _docIdEdicao == null) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Excluir técnico',
            style: TextStyle(color: _texto, fontWeight: FontWeight.bold)),
        content: Text(
          'Deseja realmente excluir "${_nomeCtrl.text.trim()}"?\n\n'
          'Esta ação não apaga ordens de serviço já registradas.',
          style: TextStyle(color: _sub, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancelar', style: TextStyle(color: _sub)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Excluir',
                style: TextStyle(
                    color: _vermelho, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    if (ok == true) await _excluir();
  }

  Future<void> _excluir() async {
    if (_docIdEdicao == null) return;
    setState(() {
      _excluindo = true;
      _salvando = true;
      _etapaSalvando = 'Excluindo técnico...';
    });
    try {
      await PontosPorTecnicoRecord.collection.doc(_docIdEdicao).delete();
      _snack('✅ Técnico excluído. O.S anteriores foram mantidas.', _verde);
      await _carregarTecnicosBusca();
      if (!mounted) return;
      setState(() {
        _modo = 'busca';
        _limparFormulario();
      });
    } catch (e) {
      _snack('❌ Erro ao excluir: $e', _vermelho);
    } finally {
      if (mounted) {
        setState(() {
          _excluindo = false;
          _salvando = false;
          _etapaSalvando = '';
        });
      }
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
    final lista = _tecnicosFiltrados;
    return Column(children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: _card,
          border: Border(bottom: BorderSide(color: _borda)),
        ),
        child: Row(children: [
          _iconBox(Icons.engineering_rounded, _roxo),
          const SizedBox(width: 12),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text('Gerenciar Técnicos',
                    style: GoogleFonts.interTight(
                        color: _texto,
                        fontSize: 16,
                        fontWeight: FontWeight.w700)),
                Text('Coleção PONTOS_POR_TECNICO',
                    style: TextStyle(color: _sub, fontSize: 11)),
              ])),
        ]),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Container(
          height: 46,
          decoration: BoxDecoration(
            color: _fill,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _borda),
          ),
          child: Row(children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Icon(Icons.search, color: _sub, size: 20),
            ),
            Expanded(
              child: TextField(
                controller: _buscaCtrl,
                style: TextStyle(color: _texto, fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Buscar por nome...',
                  hintStyle: TextStyle(color: _sub, fontSize: 13),
                  border: InputBorder.none,
                  isDense: true,
                ),
                onChanged: (v) => setState(() => _filtro = v),
              ),
            ),
            if (_filtro.isNotEmpty)
              IconButton(
                icon: Icon(Icons.close, color: _sub, size: 18),
                onPressed: () {
                  _buscaCtrl.clear();
                  setState(() => _filtro = '');
                },
              ),
          ]),
        ),
      ),
      Expanded(
        child: _carregandoTecnicos
            ? const Center(
                child: CircularProgressIndicator(color: _roxo, strokeWidth: 3))
            : lista.isEmpty
                ? Center(
                    child: Text(
                      _tecnicosList.isEmpty
                          ? 'Nenhum técnico cadastrado.'
                          : 'Nenhum técnico encontrado.',
                      style: TextStyle(color: _sub, fontSize: 14),
                    ),
                  )
                : ListView.separated(
                    padding: EdgeInsets.fromLTRB(
                        16, 8, 16, 8 + MediaQuery.of(context).padding.bottom),
                    itemCount: lista.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) {
                      final t = lista[i];
                      final nome = t['nome'].toString();
                      final foto = t['foto'].toString();
                      final pontos = (t['pontos'] is num)
                          ? (t['pontos'] as num).toDouble()
                          : 0.0;
                      return GestureDetector(
                        onTap: () => _iniciarEdicao(t),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: _card,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: _borda),
                          ),
                          child: Row(children: [
                            _avatar(nome: nome, fotoUrl: foto, size: 48),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    nome.isEmpty ? 'Sem nome' : nome,
                                    style: TextStyle(
                                      color: _texto,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${_fmtPontos(pontos)} pts',
                                    style:
                                        TextStyle(color: _sub, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            Icon(Icons.chevron_right, color: _sub),
                          ]),
                        ),
                      );
                    },
                  ),
      ),
      Padding(
        padding: EdgeInsets.fromLTRB(
            16, 8, 16, 16 + MediaQuery.of(context).padding.bottom),
        child: GestureDetector(
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
                  Text('Novo técnico',
                      style: TextStyle(
                          color: _verde,
                          fontSize: 15,
                          fontWeight: FontWeight.bold)),
                ]),
          ),
        ),
      ),
    ]);
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
              _sec('🖼️ Foto do técnico'),
              const SizedBox(height: 10),
              _buildCardImagem(),
              const SizedBox(height: 20),
              _sec('👤 Dados do técnico'),
              const SizedBox(height: 10),
              _card_(
                  child: Column(children: [
                KeyedSubtree(
                  key: _keyNome,
                  child: _input(
                    ctrl: _nomeCtrl,
                    label: 'Nome do técnico *',
                    icon: Icons.badge_outlined,
                    tipo: TextInputType.text,
                    upper: true,
                    erro: _tentouSalvar && _nomeCtrl.text.trim().isEmpty,
                  ),
                ),
                const SizedBox(height: 12),
                _input(
                  ctrl: _senhaCtrl,
                  label: 'Senha (opcional)',
                  icon: Icons.lock_outline,
                  tipo: TextInputType.text,
                  obscure: true,
                ),
              ])),
              if (_modoEdicao) ...[
                const SizedBox(height: 12),
                Text(
                  'Pontos atuais: ${_fmtPontos(_pontosAtual)} (mantidos ao salvar)',
                  style: TextStyle(color: _sub, fontSize: 12),
                ),
              ],
              const SizedBox(height: 32),
              _buildBtnSalvar(),
              if (_modoEdicao) ...[
                const SizedBox(height: 12),
                _buildBtnExcluir(),
              ],
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
          Text(_modoEdicao ? 'Editar técnico' : 'Novo técnico',
              style: GoogleFonts.interTight(
                  color: _texto, fontSize: 15, fontWeight: FontWeight.w700)),
          Text(_modoEdicao ? _nomeCtrl.text : 'Preencha os dados',
              style: TextStyle(color: _sub, fontSize: 11),
              overflow: TextOverflow.ellipsis),
        ])),
      ]),
    );
  }

  Widget _buildCardImagem() {
    final bool temNovaLocal = _imagemBytesNova != null && !_imagemRemovida;
    final String? urlAtual =
        _imagemRemovida ? null : (_fotoValida(_photoUrlAtual) ? _photoUrlAtual : null);
    final bool temQualquerImagem = temNovaLocal || urlAtual != null;
    final nome = _nomeCtrl.text;

    return _card_(
        child: Row(children: [
      GestureDetector(
        onTap: _selecionarImagem,
        child: AnimatedContainer(
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
                  child:
                      CircularProgressIndicator(color: _roxo, strokeWidth: 2))
              : temNovaLocal
                  ? Image.memory(_imagemBytesNova!, fit: BoxFit.cover)
                  : urlAtual != null
                      ? Image.network(
                          urlAtual,
                          fit: BoxFit.cover,
                          webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
                          errorBuilder: (_, __, ___) => Center(
                            child: Text(
                              _iniciais(nome),
                              style: TextStyle(
                                color: _sub,
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                              ),
                            ),
                          ),
                        )
                      : Center(
                          child: Text(
                            _iniciais(nome),
                            style: TextStyle(
                              color: _sub,
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                          ),
                        ),
        ),
      ),
      const SizedBox(width: 16),
      Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(temQualquerImagem ? 'Foto adicionada' : 'Toque na foto para escolher',
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

  Widget _buildBtnSalvar() {
    return GestureDetector(
      onTap: _salvando ? null : _salvar,
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
          Text(_modoEdicao ? 'Salvar alterações' : 'Cadastrar técnico',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold)),
        ]),
      ),
    );
  }

  Widget _buildBtnExcluir() {
    return GestureDetector(
      onTap: _excluindo ? null : _confirmarExcluir,
      child: Container(
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          color: _vermelho.withAlpha(20),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _vermelho.withAlpha(140)),
        ),
        child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.delete_outline, color: _vermelho, size: 20),
          SizedBox(width: 10),
          Text('Excluir técnico',
              style: TextStyle(
                  color: _vermelho, fontSize: 15, fontWeight: FontWeight.bold)),
        ]),
      ),
    );
  }

  Widget _avatar({
    required String nome,
    required String fotoUrl,
    double size = 48,
  }) {
    final valida = _fotoValida(fotoUrl);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _roxo.withAlpha(30),
        shape: BoxShape.circle,
        border: Border.all(color: _borda),
      ),
      clipBehavior: Clip.antiAlias,
      child: valida
          ? Image.network(
              fotoUrl.trim(),
              fit: BoxFit.cover,
              webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
              errorBuilder: (_, __, ___) => Center(
                child: Text(
                  _iniciais(nome),
                  style: TextStyle(
                    color: _roxo,
                    fontWeight: FontWeight.bold,
                    fontSize: size * 0.36,
                  ),
                ),
              ),
            )
          : Center(
              child: Text(
                _iniciais(nome),
                style: TextStyle(
                  color: _roxo,
                  fontWeight: FontWeight.bold,
                  fontSize: size * 0.36,
                ),
              ),
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
    bool upper = false,
    bool obscure = false,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: tipo,
      readOnly: readOnly,
      obscureText: obscure,
      enableSuggestions: !obscure,
      autocorrect: !obscure,
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
