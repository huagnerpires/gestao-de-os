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
import '/flutter_flow/custom_functions.dart';

import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';

import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

// ════════════════════════════════════════════════════════════════════════════
// CONSTANTE — substitua pela sua chave imgBB
// ════════════════════════════════════════════════════════════════════════════
const String _kImgBBApiKey = '69b75a9be0857deaa943296636aca90a';

// ════════════════════════════════════════════════════════════════════════════
// LISTA DE PATRIMÔNIOS PARA AUDITORIA (Extraída da imagem)
// ════════════════════════════════════════════════════════════════════════════
const List<String> _patrimoniosAuditoria = [
  '172177',
  '125252',
  '125251',
  '72956',
  '144583',
  '111051',
  '60466',
  '144182',
  '87606',
  '87607',
  '56193',
  '111052',
  '165024',
  '143431',
  '92288',
  '125260',
  '128210',
  '108104',
  '158061',
  '128167',
  '128212',
  '41055',
  '41054',
  '157677',
  '6418',
  '125259',
  '100169',
  '117562',
  '157765',
  '87604',
  '87602',
  '165365',
  '125035',
  '125036',
  '87608',
  '92479',
  '157623',
  '100158',
  '100157',
  '100159',
  '103998',
  '70933',
  '93414',
  '122666',
  '117558',
  '87609',
  '100168',
  '6741',
  '157763',
  '157764',
  '128211',
  '164406',
  '111053',
  '143430',
  '157794',
  '103999',
  '137450',
  '164409',
  '164408',
  '158086',
  '164407',
  '103807',
  '103805',
  '103802',
  '103808',
  '103801',
  '103806',
  '103803',
  '103809',
  '103800',
  '105438',
  '105439',
  '105437',
  '115472',
  '115471',
  '143428',
  '158081',
  '87605',
  '158084',
  '71109',
  '93366',
  '72991',
  '165349',
  '165348',
  '165350',
  '165013',
  '171871',
  '171867',
  '137451'
];

/// ════════════════════════════════════════════════════════════════════════════
/// WIDGET PRINCIPAL
/// ════════════════════════════════════════════════════════════════════════════
class GerenciarImagensWidget extends StatefulWidget {
  const GerenciarImagensWidget({super.key, this.width, this.height});

  final double? width;
  final double? height;

  @override
  State<GerenciarImagensWidget> createState() => _GerenciarImagensWidgetState();
}

class _GerenciarImagensWidgetState extends State<GerenciarImagensWidget>
    with SingleTickerProviderStateMixin {
  // ── tabs ──────────────────────────────────────────────────────────────────
  late TabController _tabController;

  // ── dados imagens ─────────────────────────────────────────────────────────
  List<Map<String, dynamic>> _imagensComEquipamento = [];
  List<Map<String, dynamic>> _imagensSemEquipamento = [];
  List<Map<String, dynamic>> _todasImagens = [];

  // ── dados auditoria ───────────────────────────────────────────────────────
  List<Map<String, dynamic>> _todosEquipsRaw = [];
  List<String> _emailsDisponiveis = [];
  String? _emailFiltroAuditoria;
  List<String> _patsFaltantes = [];
  List<Map<String, dynamic>> _equipsExcedentes = [];

  // ── status de corrupção ───────────────────────────────────────────────────
  final Map<String, bool> _statusImagem = {};
  bool _verificando = false;
  int _verificados = 0;
  int _totalParaVerificar = 0;
  int _scanKey = 0;

  // ── UI ────────────────────────────────────────────────────────────────────
  bool _carregando = true;
  String _erro = '';
  String _busca = '';
  final TextEditingController _buscaCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _carregarDados();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _buscaCtrl.dispose();
    super.dispose();
  }

  // ── Firestore ─────────────────────────────────────────────────────────────
  Future<void> _carregarDados() async {
    setState(() {
      _carregando = true;
      _erro = '';
      _statusImagem.clear();
      _verificando = false;
    });
    try {
      final snapEquip = await FirebaseFirestore.instance
          .collection('EQUIPAMENTOS_EMPRESA')
          .get();

      final Map<String, Map<String, dynamic>> equipMap = {};
      final List<Map<String, dynamic>> rawEquips = [];
      final Set<String> emailsSet = {};

      for (final doc in snapEquip.docs) {
        final data = doc.data();
        final pat = (data['PATRIMONIO'] ?? '').toString().trim();
        final email = (data['EMAIL'] ?? '').toString().trim();

        rawEquips.add({'docId': doc.id, ...data});

        if (email.isNotEmpty) emailsSet.add(email);
        if (pat.isNotEmpty) equipMap[pat] = {'id': doc.id, ...data};
      }

      final snapImagens =
          await FirebaseFirestore.instance.collection('IMAGENS').get();
      final List<Map<String, dynamic>> comEquip = [];
      final List<Map<String, dynamic>> semEquip = [];
      final List<Map<String, dynamic>> todas = [];

      for (final doc in snapImagens.docs) {
        final data = doc.data();
        final pat = (data['PATRIMONIO'] ?? '').toString().trim();
        final url = (data['IMAGEM'] ?? '').toString().trim();
        final item = {'docId': doc.id, ...data};
        if (url.isEmpty) _statusImagem[doc.id] = false;
        if (equipMap.containsKey(pat)) {
          comEquip.add({...item, '_equipamento': equipMap[pat]});
        } else {
          semEquip.add(item);
        }
        todas.add(item);
      }

      int cmpPat(a, b) => (a['PATRIMONIO'] ?? '')
          .toString()
          .compareTo((b['PATRIMONIO'] ?? '').toString());
      comEquip.sort(cmpPat);
      semEquip.sort(cmpPat);
      todas.sort(cmpPat);

      if (!mounted) return;

      setState(() {
        _imagensComEquipamento = comEquip;
        _imagensSemEquipamento = semEquip;
        _todasImagens = todas;
        _todosEquipsRaw = rawEquips;
        _emailsDisponiveis = emailsSet.toList()..sort();
        _carregando = false;
      });

      if (_emailFiltroAuditoria != null) {
        _executarAuditoria();
      }

      _verificarTodasImagens();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _erro = e.toString();
        _carregando = false;
      });
    }
  }

  // ── AUDITORIA ─────────────────────────────────────────────────────────────
  void _executarAuditoria() {
    if (_emailFiltroAuditoria == null) return;

    final equipsDoEmail = _todosEquipsRaw.where((e) {
      return (e['EMAIL'] ?? '').toString().trim() == _emailFiltroAuditoria;
    }).toList();

    final patsNoBanco = equipsDoEmail
        .map((e) => (e['PATRIMONIO'] ?? '').toString().trim())
        .toSet();
    final baseSet = _patrimoniosAuditoria.toSet();

    setState(() {
      _patsFaltantes = baseSet.difference(patsNoBanco).toList();
      _equipsExcedentes = equipsDoEmail.where((e) {
        final pat = (e['PATRIMONIO'] ?? '').toString().trim();
        return !baseSet.contains(pat);
      }).toList();

      _patsFaltantes.sort();
      _equipsExcedentes.sort((a, b) => (a['PATRIMONIO'] ?? '')
          .toString()
          .compareTo((b['PATRIMONIO'] ?? '').toString()));
    });
  }

  Future<void> _apagarEquipamentoExcedente(String docId, String pat) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(children: [
          Icon(Icons.warning_rounded, color: Colors.red.shade400, size: 28),
          const SizedBox(width: 10),
          const Text('Apagar Equipamento'),
        ]),
        content: Text(
            'Deseja realmente apagar o PAT "$pat" da coleção EQUIPAMENTOS_EMPRESA?\n\nEsta ação não pode ser desfeita.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context, true),
            icon: const Icon(Icons.delete_rounded, size: 18),
            label: const Text('Apagar'),
            style:
                ElevatedButton.styleFrom(backgroundColor: Colors.red.shade600),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await FirebaseFirestore.instance
          .collection('EQUIPAMENTOS_EMPRESA')
          .doc(docId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Equipamento $pat apagado com sucesso.'),
        backgroundColor: Colors.green.shade700,
      ));
      _carregarDados();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Erro ao apagar equipamento: $e'),
        backgroundColor: Colors.red.shade700,
      ));
    }
  }

  // ── verificação HTTP ──────────────────────────────────────────────────────
  Future<void> _verificarTodasImagens() async {
    final paraVerificar = _todasImagens
        .where((img) => !_statusImagem.containsKey(img['docId']))
        .toList();
    if (paraVerificar.isEmpty) return;
    if (!mounted) return;
    setState(() {
      _verificando = true;
      _verificados = 0;
      _totalParaVerificar = paraVerificar.length;
      _scanKey++;
    });
    const lote = 8;
    for (int i = 0; i < paraVerificar.length; i += lote) {
      if (!mounted) return;
      final fim = (i + lote).clamp(0, paraVerificar.length);
      await Future.wait(paraVerificar.sublist(i, fim).map((img) async {
        final docId = img['docId'] as String;
        final url = (img['IMAGEM'] ?? '').toString().trim();
        final ok = await _checarUrl(url);
        if (!mounted) return;
        setState(() {
          _statusImagem[docId] = ok;
          _verificados++;
        });
      }));
    }
    if (!mounted) return;
    setState(() => _verificando = false);
  }

  Future<bool> _checarUrl(String url) async {
    if (url.isEmpty) return false;
    try {
      final uri = Uri.parse(url);
      final resp = await http.head(uri).timeout(const Duration(seconds: 10));
      if (resp.statusCode >= 200 && resp.statusCode < 400) return true;
      final resp2 = await http.get(uri, headers: {
        'Range': 'bytes=0-1023'
      }).timeout(const Duration(seconds: 12));
      return resp2.statusCode >= 200 && resp2.statusCode < 400;
    } catch (_) {
      return false;
    }
  }

  // ── apagar imagem (abas normais) ──────────────────────────────────────────
  Future<void> _apagarImagem(String docId, String patrimonio,
      {bool corrompida = false}) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => _DialogConfirmarExclusao(
          patrimonio: patrimonio, corrompida: corrompida),
    );
    if (confirm != true) return;
    try {
      await FirebaseFirestore.instance
          .collection('IMAGENS')
          .doc(docId)
          .delete();
      _carregarDados();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Erro ao apagar: $e'),
        backgroundColor: Colors.red.shade700,
      ));
    }
  }

  Future<void> _apagarTodasCorrompidas() async {
    final corrompidas = _imagensCorrempidas;
    if (corrompidas.isEmpty) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(children: [
          Icon(Icons.delete_sweep_rounded,
              color: Colors.red.shade400, size: 28),
          const SizedBox(width: 10),
          const Text('Apagar Todas Corrompidas'),
        ]),
        content: Text(
            'Serão apagadas ${corrompidas.length} imagens corrompidas.\n\nEsta ação não pode ser desfeita.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context, true),
            icon: const Icon(Icons.delete_sweep_rounded, size: 18),
            label: Text('Apagar ${corrompidas.length}'),
            style:
                ElevatedButton.styleFrom(backgroundColor: Colors.red.shade600),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    final batch = FirebaseFirestore.instance.batch();
    for (final img in corrompidas) {
      batch.delete(
          FirebaseFirestore.instance.collection('IMAGENS').doc(img['docId']));
    }
    await batch.commit();
    _carregarDados();
  }

  // ── SUBSTITUIR IMAGEM ─────────────────────────────────────────────────────
  Future<void> _substituirImagem(Map<String, dynamic> imgData) async {
    final t = FlutterFlowTheme.of(context);
    final fonte = await showModalBottomSheet<_FonteImagem>(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      useSafeArea: true,
      builder: (_) => _BottomSheetFonteImagem(theme: t),
    );
    if (fonte == null || !mounted) return;

    XFile? arquivo;
    final picker = ImagePicker();
    try {
      if (fonte == _FonteImagem.galeria) {
        arquivo = await picker.pickImage(
            source: ImageSource.gallery, imageQuality: 90);
      } else {
        arquivo = await picker.pickImage(
            source: ImageSource.camera, imageQuality: 90);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            'Erro ao acessar ${fonte == _FonteImagem.galeria ? "galeria" : "câmera"}: $e'),
        backgroundColor: Colors.red.shade700,
      ));
      return;
    }
    if (arquivo == null || !mounted) return;

    Uint8List bytesOriginais = await arquivo.readAsBytes();
    if (!mounted) return;

    final querCrop = await showDialog<bool>(
      context: context,
      builder: (_) => _DialogPerguntaCrop(theme: t),
    );
    if (!mounted) return;

    Uint8List bytesFinais = bytesOriginais;

    if (querCrop == true) {
      final bytesCropados = await showGeneralDialog<Uint8List>(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.black,
        pageBuilder: (dialogCtx, _, __) => _TelaCropImagem(
          bytesOriginais: bytesOriginais,
          theme: t,
          onConcluido: (bytes) => Navigator.of(dialogCtx).pop(bytes),
          onCancelar: () => Navigator.of(dialogCtx).pop(null),
        ),
      );
      if (!mounted) return;
      if (bytesCropados == null) return;
      bytesFinais = bytesCropados;
    }

    final bytes = bytesFinais;
    final confirmar = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: false,
      useSafeArea: true,
      builder: (_) => _BottomSheetConfirmarSalvar(
          theme: t, imagemBytes: bytes, imgData: imgData),
    );
    if (confirmar != true || !mounted) return;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _DialogSalvandoImagem(
        theme: t,
        imagemBytes: bytes,
        docId: imgData['docId'] as String,
        onConcluido: () {
          Navigator.of(context).pop();
          _carregarDados();
        },
        onErro: (msg) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Erro ao salvar: $msg'),
            backgroundColor: Colors.red.shade700,
          ));
        },
      ),
    );
  }

  void _verImagemCompleta(String url) {
    showDialog(
        context: context, builder: (_) => _DialogVisualizarImagem(url: url));
  }

  // ── listas calculadas ─────────────────────────────────────────────────────
  bool _estaCorrempida(String docId) => _statusImagem[docId] == false;

  List<Map<String, dynamic>> get _imagensCorrempidas =>
      _todasImagens.where((img) => _estaCorrempida(img['docId'])).toList();

  List<Map<String, dynamic>> get _filtradosComEquip {
    final q = _busca.toLowerCase();
    return _imagensComEquipamento.where((img) {
      if (q.isEmpty) return true;
      final pat = (img['PATRIMONIO'] ?? '').toString().toLowerCase();
      final equip = img['_equipamento'] as Map<String, dynamic>? ?? {};
      final nome = (equip['EQUIPAMENTO'] ?? '').toString().toLowerCase();
      final setor = (equip['SETOR'] ?? '').toString().toLowerCase();
      return pat.contains(q) || nome.contains(q) || setor.contains(q);
    }).toList();
  }

  List<Map<String, dynamic>> get _filtradosSemEquip {
    final q = _busca.toLowerCase();
    return _imagensSemEquipamento.where((img) {
      if (q.isEmpty) return true;
      return (img['PATRIMONIO'] ?? '').toString().toLowerCase().contains(q);
    }).toList();
  }

  List<Map<String, dynamic>> get _filtradosCorrempidos {
    final q = _busca.toLowerCase();
    return _imagensCorrempidas.where((img) {
      if (q.isEmpty) return true;
      return (img['PATRIMONIO'] ?? '').toString().toLowerCase().contains(q);
    }).toList();
  }

  // ── build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final t = FlutterFlowTheme.of(context);
    return Material(
      color: t.primaryBackground,
      child: SizedBox(
        width: widget.width ?? double.infinity,
        height: widget.height ?? double.infinity,
        child: Column(children: [
          _buildCabecalho(t),
          if (_verificando) _buildBarraProgresso(t),
          _buildBusca(t),
          _buildTabs(t),
          Expanded(
            child: _carregando
                ? _buildCarregando(t)
                : _erro.isNotEmpty
                    ? _buildErro(t)
                    : _buildConteudo(t),
          ),
        ]),
      ),
    );
  }

  Widget _buildCabecalho(FlutterFlowTheme t) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 12, 12),
      decoration: BoxDecoration(
        color: t.secondaryBackground,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withAlpha(30),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: t.primary.withAlpha(26),
              borderRadius: BorderRadius.circular(12)),
          child: Icon(Icons.photo_library_rounded, color: t.primary, size: 26),
        ),
        const SizedBox(width: 14),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Gerenciar Imagens',
                style: t.titleLarge.override(
                    fontFamily: 'Readex Pro', fontWeight: FontWeight.w700)),
            Text('IMAGENS × EQUIPAMENTOS_EMPRESA',
                style: t.labelSmall.override(
                    fontFamily: 'Readex Pro', color: t.secondaryText)),
          ]),
        ),
        // O botão Escanear ficava aqui e foi removido. Mantivemos apenas o botão de atualizar (Recarregar).
        IconButton(
          onPressed: _carregarDados,
          icon: Icon(Icons.refresh_rounded, color: t.primary),
          tooltip: 'Recarregar',
        ),
      ]),
    );
  }

  Widget _buildBarraProgresso(FlutterFlowTheme t) {
    final pct =
        _totalParaVerificar == 0 ? 0.0 : _verificados / _totalParaVerificar;
    return Container(
      color: t.secondaryBackground,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.manage_search_rounded, size: 14, color: t.secondaryText),
          const SizedBox(width: 6),
          Text('Verificando... $_verificados / $_totalParaVerificar',
              style: t.labelSmall
                  .override(fontFamily: 'Readex Pro', color: t.secondaryText)),
          const Spacer(),
          if (_imagensCorrempidas.isNotEmpty)
            Row(children: [
              Icon(Icons.broken_image_rounded,
                  size: 13, color: Colors.red.shade400),
              const SizedBox(width: 4),
              Text('${_imagensCorrempidas.length} corrompida(s)',
                  style: TextStyle(
                      color: Colors.red.shade400,
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
            ]),
        ]),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: pct,
            minHeight: 5,
            backgroundColor: t.primaryBackground,
            valueColor: AlwaysStoppedAnimation(t.primary),
          ),
        ),
      ]),
    );
  }

  Widget _buildBusca(FlutterFlowTheme t) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: TextField(
        controller: _buscaCtrl,
        onChanged: (v) => setState(() => _busca = v.trim()),
        style: t.bodyMedium
            .override(fontFamily: 'Readex Pro', color: t.primaryText),
        decoration: InputDecoration(
          hintText: 'Buscar por patrimônio, equipamento ou setor...',
          hintStyle: t.labelMedium
              .override(fontFamily: 'Readex Pro', color: t.secondaryText),
          prefixIcon:
              Icon(Icons.search_rounded, color: t.secondaryText, size: 20),
          suffixIcon: _busca.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear_rounded,
                      color: t.secondaryText, size: 18),
                  onPressed: () {
                    _buscaCtrl.clear();
                    setState(() => _busca = '');
                  })
              : null,
          filled: true,
          fillColor: t.secondaryBackground,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildTabs(FlutterFlowTheme t) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      decoration: BoxDecoration(
          color: t.secondaryBackground,
          borderRadius: BorderRadius.circular(12)),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        indicator: BoxDecoration(
            color: t.primary, borderRadius: BorderRadius.circular(10)),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Colors.white,
        unselectedLabelColor: t.secondaryText,
        labelStyle: t.labelMedium
            .override(fontFamily: 'Readex Pro', fontWeight: FontWeight.w600),
        unselectedLabelStyle: t.labelMedium.override(fontFamily: 'Readex Pro'),
        padding: const EdgeInsets.all(4),
        tabs: [
          Tab(
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.link_rounded, size: 15),
              const SizedBox(width: 5),
              const Text('Com Equip.'),
              const SizedBox(width: 4),
              _badge(_filtradosComEquip.length, Colors.green.shade600),
            ]),
          ),
          Tab(
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.link_off_rounded, size: 15),
              const SizedBox(width: 5),
              const Text('Sem Equip.'),
              const SizedBox(width: 4),
              _badge(_filtradosSemEquip.length, Colors.orange.shade700),
            ]),
          ),
          Tab(
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.broken_image_rounded, size: 15),
              const SizedBox(width: 5),
              const Text('Corrompidas'),
              const SizedBox(width: 4),
              if (_verificando)
                SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.red.shade400))
              else
                _badge(_filtradosCorrempidos.length, Colors.red.shade600),
            ]),
          ),
          Tab(
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.fact_check_rounded, size: 15),
              const SizedBox(width: 5),
              const Text('Auditoria'),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _badge(int n, Color cor) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
            color: cor.withAlpha(200), borderRadius: BorderRadius.circular(20)),
        child: Text('$n',
            style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w700)),
      );

  Widget _buildConteudo(FlutterFlowTheme t) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildAbaComEquipamento(t),
          _buildAbaSemEquipamento(t),
          _buildAbaCorrempidas(t),
          _buildAbaAuditoria(t),
        ],
      ),
    );
  }

  // ── Aba 1 ─────────────────────────────────────────────────────────────────
  Widget _buildAbaComEquipamento(FlutterFlowTheme t) {
    final lista = _filtradosComEquip;
    if (lista.isEmpty)
      return _vazio(t, 'Nenhuma imagem vinculada a equipamentos');
    final Map<String, List<Map<String, dynamic>>> grupos = {};
    for (final img in lista) {
      final pat = (img['PATRIMONIO'] ?? 'SEM PAT').toString();
      grupos.putIfAbsent(pat, () => []).add(img);
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: grupos.length,
      itemBuilder: (ctx, i) {
        final pat = grupos.keys.elementAt(i);
        final imagens = grupos[pat]!;
        final equip =
            imagens.first['_equipamento'] as Map<String, dynamic>? ?? {};
        final temCorrempida =
            imagens.any((img) => _estaCorrempida(img['docId']));
        return _CartaoGrupo(
          key: ValueKey('grupo_${pat}_$_scanKey'),
          patrimonio: pat,
          equipamento: equip,
          imagens: imagens,
          theme: t,
          statusImagem: _statusImagem,
          verificando: _verificando,
          temCorrempida: temCorrempida,
          onApagar: (docId) => _apagarImagem(docId, pat),
          onSubstituir: (imgData) => _substituirImagem(imgData),
          onVerImagem: _verImagemCompleta,
          onImageError: (docId) {
            if (!mounted) return;
            setState(() => _statusImagem[docId] = false);
          },
          onImageOk: (docId) {
            if (!mounted) return;
            if (_statusImagem[docId] != true)
              setState(() => _statusImagem[docId] = true);
          },
        );
      },
    );
  }

  // ── Aba 2 ─────────────────────────────────────────────────────────────────
  Widget _buildAbaSemEquipamento(FlutterFlowTheme t) {
    final lista = _filtradosSemEquip;
    if (lista.isEmpty) return _vazio(t, 'Nenhuma imagem sem equipamento 🎉');
    return Column(children: [
      _avisoLaranja(
          t, 'Imagens sem equipamento correspondente em EQUIPAMENTOS_EMPRESA.'),
      Expanded(
        child: GridView.builder(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.78),
          itemCount: lista.length,
          itemBuilder: (_, i) {
            final img = lista[i];
            final docId = img['docId'] as String;
            return _CartaoImagem(
              key: ValueKey('orfa_${docId}_$_scanKey'),
              imagem: img,
              theme: t,
              corrompida: _estaCorrempida(docId),
              verificando: _verificando && !_statusImagem.containsKey(docId),
              onApagar: () => _apagarImagem(docId, img['PATRIMONIO'] ?? '',
                  corrompida: _estaCorrempida(docId)),
              onSubstituir: () => _substituirImagem(img),
              onVerImagem: () => _verImagemCompleta(img['IMAGEM'] ?? ''),
              onImageError: () {
                if (!mounted) return;
                setState(() => _statusImagem[docId] = false);
              },
              onImageOk: () {
                if (!mounted) return;
                if (_statusImagem[docId] != true)
                  setState(() => _statusImagem[docId] = true);
              },
            );
          },
        ),
      ),
    ]);
  }

  // ── Aba 3 ─────────────────────────────────────────────────────────────────
  Widget _buildAbaCorrempidas(FlutterFlowTheme t) {
    if (_verificando && _verificados < _totalParaVerificar)
      return _buildVerificandoPlaceholder(t);
    final lista = _filtradosCorrempidos;
    if (lista.isEmpty)
      return _vazio(t,
          'Nenhuma imagem corrompida encontrada ✅\n\nTodas as imagens estão acessíveis.');
    return Column(children: [
      Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
        decoration: BoxDecoration(
          color: Colors.red.shade700.withAlpha(20),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.red.shade700.withAlpha(80)),
        ),
        child: Row(children: [
          Icon(Icons.warning_rounded, color: Colors.red.shade400, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
                '${lista.length} imagem(ns) corrompida(s) ou inacessível(is).',
                style: t.bodySmall.override(
                    fontFamily: 'Readex Pro', color: Colors.red.shade300)),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _apagarTodasCorrompidas,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                  color: Colors.red.shade700,
                  borderRadius: BorderRadius.circular(8)),
              child: Row(mainAxisSize: MainAxisSize.min, children: const [
                Icon(Icons.delete_sweep_rounded, color: Colors.white, size: 16),
                SizedBox(width: 5),
                Text('Apagar todas',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
              ]),
            ),
          ),
        ]),
      ),
      _buildResumoCorrempidas(t, lista),
      Expanded(
        child: GridView.builder(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.78),
          itemCount: lista.length,
          itemBuilder: (_, i) {
            final img = lista[i];
            final docId = img['docId'] as String;
            return _CartaoImagem(
              key: ValueKey('corrompida_${docId}_$_scanKey'),
              imagem: img,
              theme: t,
              corrompida: true,
              verificando: false,
              onApagar: () => _apagarImagem(docId, img['PATRIMONIO'] ?? '',
                  corrompida: true),
              onSubstituir: () => _substituirImagem(img),
              onVerImagem: () => _verImagemCompleta(img['IMAGEM'] ?? ''),
              onImageError: () {},
              onImageOk: () {
                if (!mounted) return;
                setState(() => _statusImagem[docId] = true);
              },
            );
          },
        ),
      ),
    ]);
  }

  // ── ABA 4 (AUDITORIA PAT) ─────────────────────────────────────────────────
  Widget _buildAbaAuditoria(FlutterFlowTheme t) {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: t.secondaryBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: t.primaryText.withAlpha(20)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              hint: Text('Selecione o E-mail para Auditar',
                  style: t.bodyMedium.override(
                      fontFamily: 'Readex Pro', color: t.secondaryText)),
              value: _emailFiltroAuditoria,
              icon: Icon(Icons.keyboard_arrow_down_rounded,
                  color: t.secondaryText),
              dropdownColor: t.secondaryBackground,
              items: _emailsDisponiveis.map((e) {
                return DropdownMenuItem<String>(
                  value: e,
                  child: Text(e,
                      style: t.bodyMedium.override(fontFamily: 'Readex Pro')),
                );
              }).toList(),
              onChanged: (val) {
                setState(() => _emailFiltroAuditoria = val);
                _executarAuditoria();
              },
            ),
          ),
        ),
      ),
      if (_emailFiltroAuditoria == null)
        Expanded(
            child: _vazio(t,
                'Selecione um E-mail acima para iniciar a auditoria da coleção EQUIPAMENTOS_EMPRESA com a lista base.')),
      if (_emailFiltroAuditoria != null)
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            children: [
              // Faltantes
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                    color: t.secondaryBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: Colors.orange.shade700.withAlpha(80))),
                child: Theme(
                  data: Theme.of(context)
                      .copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    initiallyExpanded: true,
                    iconColor: Colors.orange.shade700,
                    collapsedIconColor: Colors.orange.shade700,
                    title: Row(children: [
                      Icon(Icons.warning_amber_rounded,
                          color: Colors.orange.shade700, size: 20),
                      const SizedBox(width: 8),
                      Text('Faltam na Coleção',
                          style: t.titleSmall.override(
                              fontFamily: 'Readex Pro',
                              color: Colors.orange.shade700)),
                      const Spacer(),
                      _badge(_patsFaltantes.length, Colors.orange.shade700)
                    ]),
                    children: [
                      Divider(height: 1, color: t.primaryText.withAlpha(15)),
                      if (_patsFaltantes.isEmpty)
                        Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text('Nenhum PAT faltante! Tudo perfeito.',
                                style: t.bodyMedium.override(
                                    fontFamily: 'Readex Pro',
                                    color: Colors.green)))
                      else
                        ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _patsFaltantes.length,
                            separatorBuilder: (_, __) => Divider(
                                height: 1, color: t.primaryText.withAlpha(10)),
                            itemBuilder: (ctx, i) {
                              return ListTile(
                                  dense: true,
                                  leading: Icon(Icons.tag_rounded,
                                      size: 16, color: t.secondaryText),
                                  title: Text(_patsFaltantes[i],
                                      style: t.bodyMedium.override(
                                          fontFamily: 'Readex Pro',
                                          fontWeight: FontWeight.bold)));
                            })
                    ],
                  ),
                ),
              ),

              // Excedentes (agora com TODOS os detalhes puxados do banco)
              Container(
                decoration: BoxDecoration(
                    color: t.secondaryBackground,
                    borderRadius: BorderRadius.circular(12),
                    border:
                        Border.all(color: Colors.red.shade700.withAlpha(80))),
                child: Theme(
                  data: Theme.of(context)
                      .copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    initiallyExpanded: true,
                    iconColor: Colors.red.shade600,
                    collapsedIconColor: Colors.red.shade600,
                    title: Row(children: [
                      Icon(Icons.playlist_remove_rounded,
                          color: Colors.red.shade600, size: 20),
                      const SizedBox(width: 8),
                      Text('Excedentes na Coleção',
                          style: t.titleSmall.override(
                              fontFamily: 'Readex Pro',
                              color: Colors.red.shade600)),
                      const Spacer(),
                      _badge(_equipsExcedentes.length, Colors.red.shade600)
                    ]),
                    children: [
                      Divider(height: 1, color: t.primaryText.withAlpha(15)),
                      if (_equipsExcedentes.isEmpty)
                        Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text('Nenhum PAT excedente encontrado!',
                                style: t.bodyMedium.override(
                                    fontFamily: 'Readex Pro',
                                    color: Colors.green)))
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _equipsExcedentes.length,
                          separatorBuilder: (_, __) => Divider(
                              height: 1, color: t.primaryText.withAlpha(10)),
                          itemBuilder: (ctx, i) {
                            final eq = _equipsExcedentes[i];
                            return _CartaoEquipamentoAuditoria(
                              equipamento: eq,
                              theme: t,
                              onApagar: () => _apagarEquipamentoExcedente(
                                  eq['docId'],
                                  (eq['PATRIMONIO'] ?? '').toString()),
                            );
                          },
                        )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
    ]);
  }

  Widget _buildResumoCorrempidas(
      FlutterFlowTheme t, List<Map<String, dynamic>> lista) {
    final urlVazia = lista
        .where((img) => (img['IMAGEM'] ?? '').toString().trim().isEmpty)
        .length;
    final urlInvalida = lista.length - urlVazia;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
          color: t.secondaryBackground,
          borderRadius: BorderRadius.circular(10)),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        _resumoItem(
            t, urlVazia, 'URL vazia', Icons.link_off_rounded, Colors.grey),
        Container(height: 30, width: 1, color: t.primaryText.withAlpha(20)),
        _resumoItem(t, urlInvalida, 'Inacessível', Icons.cloud_off_rounded,
            Colors.red.shade400),
      ]),
    );
  }

  Widget _resumoItem(
      FlutterFlowTheme t, int n, String label, IconData icon, Color cor) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, color: cor, size: 18),
      const SizedBox(width: 8),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('$n',
            style: TextStyle(
                color: cor, fontSize: 18, fontWeight: FontWeight.w800)),
        Text(label,
            style: t.labelSmall
                .override(fontFamily: 'Readex Pro', color: t.secondaryText)),
      ]),
    ]);
  }

  Widget _buildVerificandoPlaceholder(FlutterFlowTheme t) => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          SizedBox(
              width: 48,
              height: 48,
              child: CircularProgressIndicator(
                  color: Colors.red.shade400, strokeWidth: 3)),
          const SizedBox(height: 16),
          Text('Verificando $_verificados de $_totalParaVerificar imagens...',
              style: t.bodyMedium
                  .override(fontFamily: 'Readex Pro', color: t.secondaryText)),
          const SizedBox(height: 6),
          Text('A aba será atualizada automaticamente',
              style: t.labelSmall
                  .override(fontFamily: 'Readex Pro', color: t.secondaryText)),
        ]),
      );

  Widget _buildCarregando(FlutterFlowTheme t) => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          CircularProgressIndicator(color: t.primary),
          const SizedBox(height: 16),
          Text('Carregando dados...',
              style: t.bodyMedium
                  .override(fontFamily: 'Readex Pro', color: t.secondaryText)),
        ]),
      );

  Widget _buildErro(FlutterFlowTheme t) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.error_outline_rounded,
                color: Colors.red.shade400, size: 48),
            const SizedBox(height: 12),
            Text('Erro ao carregar',
                style: t.titleMedium
                    .override(fontFamily: 'Readex Pro', color: t.error)),
            const SizedBox(height: 8),
            Text(_erro,
                textAlign: TextAlign.center,
                style: t.bodySmall.override(
                    fontFamily: 'Readex Pro', color: t.secondaryText)),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _carregarDados,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Tentar novamente'),
              style: ElevatedButton.styleFrom(backgroundColor: t.primary),
            ),
          ]),
        ),
      );

  Widget _vazio(FlutterFlowTheme t, String msg) => Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.search_off_rounded,
                color: t.secondaryText.withAlpha(120), size: 52),
            const SizedBox(height: 12),
            Text(msg,
                textAlign: TextAlign.center,
                style: t.bodyMedium.override(
                    fontFamily: 'Readex Pro', color: t.secondaryText)),
          ]),
        ),
      );

  Widget _avisoLaranja(FlutterFlowTheme t, String msg) => Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.orange.shade700.withAlpha(26),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.orange.shade700.withAlpha(80)),
        ),
        child: Row(children: [
          Icon(Icons.warning_amber_rounded,
              color: Colors.orange.shade700, size: 18),
          const SizedBox(width: 10),
          Expanded(
              child: Text(msg,
                  style: t.bodySmall.override(
                      fontFamily: 'Readex Pro',
                      color: Colors.orange.shade800))),
        ]),
      );
}

// ════════════════════════════════════════════════════════════════════════════
// CARTÃO COMPLETO PARA AUDITORIA DE EXCEDENTES
// ════════════════════════════════════════════════════════════════════════════
class _CartaoEquipamentoAuditoria extends StatelessWidget {
  const _CartaoEquipamentoAuditoria(
      {required this.equipamento, required this.theme, required this.onApagar});
  final Map<String, dynamic> equipamento;
  final FlutterFlowTheme theme;
  final VoidCallback onApagar;

  @override
  Widget build(BuildContext context) {
    final t = theme;
    final eq = equipamento;

    // Mapeamento de todos os 14 campos da coleção mostrados na sua imagem
    final pat = (eq['PATRIMONIO'] ?? '').toString();
    final equip = (eq['EQUIPAMENTO'] ?? '').toString();
    final nome = (eq['NOME'] ?? '').toString();
    final marca = (eq['MARCA'] ?? '').toString();
    final modelo = (eq['MODELO'] ?? '').toString();
    final btus = (eq['BTUS'] ?? '').toString();
    final tipo = (eq['TIPO'] ?? '').toString();
    final fluido = (eq['FLUIDO'] ?? '').toString();
    final tensao = (eq['TENSAO'] ?? '').toString();
    final setor = (eq['SETOR'] ?? '').toString();
    final sala = (eq['SALA'] ?? '').toString();
    final responsavel = (eq['RESPONSAVEL'] ?? '').toString();
    final contrato = eq['CONTRATO'] == true ? 'Sim' : 'Não';
    final email = (eq['EMAIL'] ?? '').toString();

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('PAT: $pat',
                        style: t.titleMedium.override(
                            fontFamily: 'Readex Pro',
                            fontWeight: FontWeight.w800,
                            color: t.primaryText)),
                    if (equip.isNotEmpty)
                      Text(equip,
                          style: t.bodyMedium.override(
                              fontFamily: 'Readex Pro',
                              color: t.secondaryText,
                              fontWeight: FontWeight.w600)),
                  ]),
            ),
            IconButton(
              icon: Icon(Icons.delete_outline_rounded,
                  color: Colors.red.shade400, size: 24),
              onPressed: onApagar,
              tooltip: 'Apagar Excedente',
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: t.primaryBackground,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: t.primaryText.withAlpha(15))),
          child: Column(children: [
            if (nome.isNotEmpty) ...[
              _InfoRow(
                  theme: t,
                  icon: Icons.label_important_rounded,
                  label: 'Nome',
                  valor: nome),
              _DividerCompact(t)
            ],
            if (marca.isNotEmpty) ...[
              _InfoRow(
                  theme: t,
                  icon: Icons.branding_watermark_rounded,
                  label: 'Marca',
                  valor: marca),
              _DividerCompact(t)
            ],
            if (modelo.isNotEmpty) ...[
              _InfoRow(
                  theme: t,
                  icon: Icons.model_training_rounded,
                  label: 'Modelo',
                  valor: modelo),
              _DividerCompact(t)
            ],
            if (btus.isNotEmpty) ...[
              _InfoRow(
                  theme: t,
                  icon: Icons.ac_unit_rounded,
                  label: 'BTUs',
                  valor: btus),
              _DividerCompact(t)
            ],
            if (tipo.isNotEmpty) ...[
              _InfoRow(
                  theme: t,
                  icon: Icons.category_rounded,
                  label: 'Tipo',
                  valor: tipo),
              _DividerCompact(t)
            ],
            if (fluido.isNotEmpty) ...[
              _InfoRow(
                  theme: t,
                  icon: Icons.water_drop_rounded,
                  label: 'Fluido',
                  valor: fluido),
              _DividerCompact(t)
            ],
            if (tensao.isNotEmpty) ...[
              _InfoRow(
                  theme: t,
                  icon: Icons.electrical_services_rounded,
                  label: 'Tensão',
                  valor: tensao),
              _DividerCompact(t)
            ],
            if (setor.isNotEmpty) ...[
              _InfoRow(
                  theme: t,
                  icon: Icons.business_rounded,
                  label: 'Setor',
                  valor: setor),
              _DividerCompact(t)
            ],
            if (sala.isNotEmpty) ...[
              _InfoRow(
                  theme: t,
                  icon: Icons.room_rounded,
                  label: 'Sala',
                  valor: sala),
              _DividerCompact(t)
            ],
            if (responsavel.isNotEmpty) ...[
              _InfoRow(
                  theme: t,
                  icon: Icons.person_rounded,
                  label: 'Responsável',
                  valor: responsavel),
              _DividerCompact(t)
            ],
            _InfoRow(
                theme: t,
                icon: Icons.assignment_turned_in_rounded,
                label: 'Contrato',
                valor: contrato,
                valorCor:
                    eq['CONTRATO'] == true ? t.primary : Colors.red.shade400),
            if (email.isNotEmpty) ...[
              _DividerCompact(t),
              _InfoRow(
                  theme: t,
                  icon: Icons.email_rounded,
                  label: 'Email',
                  valor: email)
            ],
          ]),
        ),
      ]),
    );
  }
}

class _DividerCompact extends StatelessWidget {
  const _DividerCompact(this.t);
  final FlutterFlowTheme t;
  @override
  Widget build(BuildContext context) =>
      Divider(height: 12, color: t.primaryText.withAlpha(12));
}

// ════════════════════════════════════════════════════════════════════════════
// ENUM fonte imagem
// ════════════════════════════════════════════════════════════════════════════
enum _FonteImagem { galeria, camera }

class _BottomSheetFonteImagem extends StatelessWidget {
  const _BottomSheetFonteImagem({required this.theme});
  final FlutterFlowTheme theme;

  @override
  Widget build(BuildContext context) {
    final t = theme;
    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: t.secondaryBackground,
          borderRadius: BorderRadius.circular(20)),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
            margin: const EdgeInsets.only(top: 10),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
                color: t.secondaryText.withAlpha(80),
                borderRadius: BorderRadius.circular(2))),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 4),
          child: Row(children: [
            Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: t.primary.withAlpha(26),
                    borderRadius: BorderRadius.circular(10)),
                child:
                    Icon(Icons.swap_horiz_rounded, color: t.primary, size: 22)),
            const SizedBox(width: 14),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Substituir Imagem',
                  style: t.titleMedium.override(
                      fontFamily: 'Readex Pro', fontWeight: FontWeight.w700)),
              Text('Escolha a origem da nova imagem',
                  style: t.labelSmall.override(
                      fontFamily: 'Readex Pro', color: t.secondaryText)),
            ]),
          ]),
        ),
        const SizedBox(height: 12),
        Divider(height: 1, color: t.primaryText.withAlpha(15)),
        const SizedBox(height: 8),
        _OpcaoFonte(
            theme: t,
            icon: Icons.photo_library_rounded,
            cor: Colors.blue.shade600,
            titulo: 'Galeria de Fotos',
            subtitulo: 'Selecionar imagem existente',
            onTap: () => Navigator.pop(context, _FonteImagem.galeria)),
        _OpcaoFonte(
            theme: t,
            icon: Icons.camera_alt_rounded,
            cor: Colors.green.shade600,
            titulo: 'Câmera',
            subtitulo: 'Tirar nova foto agora',
            onTap: () => Navigator.pop(context, _FonteImagem.camera)),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: t.secondaryText.withAlpha(60)))),
              child: Text('Cancelar',
                  style: t.bodyMedium.override(
                      fontFamily: 'Readex Pro',
                      color: t.secondaryText,
                      fontWeight: FontWeight.w600)),
            ),
          ),
        ),
      ]),
    );
  }
}

class _OpcaoFonte extends StatelessWidget {
  const _OpcaoFonte(
      {required this.theme,
      required this.icon,
      required this.cor,
      required this.titulo,
      required this.subtitulo,
      required this.onTap});
  final FlutterFlowTheme theme;
  final IconData icon;
  final Color cor;
  final String titulo;
  final String subtitulo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = theme;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(children: [
          Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: cor.withAlpha(26),
                  borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: cor, size: 26)),
          const SizedBox(width: 16),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(titulo,
                    style: t.titleSmall.override(
                        fontFamily: 'Readex Pro', fontWeight: FontWeight.w600)),
                Text(subtitulo,
                    style: t.labelSmall.override(
                        fontFamily: 'Readex Pro', color: t.secondaryText))
              ])),
          Icon(Icons.arrow_forward_ios_rounded,
              size: 16, color: t.secondaryText.withAlpha(120)),
        ]),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// DIALOG — pergunta sobre crop
// ════════════════════════════════════════════════════════════════════════════
class _DialogPerguntaCrop extends StatelessWidget {
  const _DialogPerguntaCrop({required this.theme});
  final FlutterFlowTheme theme;

  @override
  Widget build(BuildContext context) {
    final t = theme;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: t.primary.withAlpha(26), shape: BoxShape.circle),
              child: Icon(Icons.crop_rounded, color: t.primary, size: 36)),
          const SizedBox(height: 16),
          Text('Recortar Imagem?',
              style: t.titleMedium.override(
                  fontFamily: 'Readex Pro', fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          Text(
              'Deseja recortar a imagem antes de usar?\n\nVocê poderá ajustar o enquadramento livremente.',
              textAlign: TextAlign.center,
              style: t.bodySmall
                  .override(fontFamily: 'Readex Pro', color: t.secondaryText)),
          const SizedBox(height: 24),
          Row(children: [
            Expanded(
                child: OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context, false),
                    icon: const Icon(Icons.check_circle_outline_rounded,
                        size: 18),
                    label: const Text('Usar assim'),
                    style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(color: t.secondaryText.withAlpha(80)),
                        foregroundColor: t.secondaryText,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12))))),
            const SizedBox(width: 12),
            Expanded(
                child: ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context, true),
                    icon: const Icon(Icons.crop_rounded, size: 18),
                    label: const Text('Recortar'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: t.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12))))),
          ]),
        ]),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// TELA DE CROP
// ════════════════════════════════════════════════════════════════════════════
class _TelaCropImagem extends StatefulWidget {
  const _TelaCropImagem(
      {required this.bytesOriginais,
      required this.theme,
      required this.onConcluido,
      required this.onCancelar});
  final Uint8List bytesOriginais;
  final FlutterFlowTheme theme;
  final void Function(Uint8List) onConcluido;
  final VoidCallback onCancelar;

  @override
  State<_TelaCropImagem> createState() => _TelaCropImagemState();
}

class _TelaCropImagemState extends State<_TelaCropImagem> {
  ui.Image? _imagem;
  bool _carregando = true;
  bool _processando = false;
  double _cropL = 0.08, _cropT = 0.08, _cropR = 0.92, _cropB = 0.92;

  @override
  void initState() {
    super.initState();
    _decodificarImagem();
  }

  Future<void> _decodificarImagem() async {
    final codec = await ui.instantiateImageCodec(widget.bytesOriginais);
    final frame = await codec.getNextFrame();
    if (!mounted) return;
    setState(() {
      _imagem = frame.image;
      _carregando = false;
    });
  }

  Rect _calcImgRect(Size containerSize) {
    final img = _imagem;
    if (img == null) return Rect.zero;
    final scaleX = containerSize.width / img.width;
    final scaleY = containerSize.height / img.height;
    final scale = math.min(scaleX, scaleY);
    final dispW = img.width * scale;
    final dispH = img.height * scale;
    final offX = (containerSize.width - dispW) / 2;
    final offY = (containerSize.height - dispH) / 2;
    return Rect.fromLTWH(offX, offY, dispW, dispH);
  }

  Offset _toNorm(Offset pos, Rect imgRect) {
    final nx = ((pos.dx - imgRect.left) / imgRect.width).clamp(0.0, 1.0);
    final ny = ((pos.dy - imgRect.top) / imgRect.height).clamp(0.0, 1.0);
    return Offset(nx, ny);
  }

  void _handlePan(DragUpdateDetails d, _CropHandle handle, Rect imgRect) {
    final dxN = d.delta.dx / imgRect.width;
    final dyN = d.delta.dy / imgRect.height;
    final posN =
        _toNorm(Offset(d.localPosition.dx, d.localPosition.dy), imgRect);
    const minSize = 0.05;

    setState(() {
      switch (handle) {
        case _CropHandle.topLeft:
          _cropL = posN.dx.clamp(0.0, _cropR - minSize);
          _cropT = posN.dy.clamp(0.0, _cropB - minSize);
          break;
        case _CropHandle.topRight:
          _cropR = posN.dx.clamp(_cropL + minSize, 1.0);
          _cropT = posN.dy.clamp(0.0, _cropB - minSize);
          break;
        case _CropHandle.bottomLeft:
          _cropL = posN.dx.clamp(0.0, _cropR - minSize);
          _cropB = posN.dy.clamp(_cropT + minSize, 1.0);
          break;
        case _CropHandle.bottomRight:
          _cropR = posN.dx.clamp(_cropL + minSize, 1.0);
          _cropB = posN.dy.clamp(_cropT + minSize, 1.0);
          break;
        case _CropHandle.move:
          final w = _cropR - _cropL;
          final h = _cropB - _cropT;
          _cropL = (_cropL + dxN).clamp(0.0, 1.0 - w);
          _cropT = (_cropT + dyN).clamp(0.0, 1.0 - h);
          _cropR = _cropL + w;
          _cropB = _cropT + h;
          break;
      }
    });
  }

  Future<void> _confirmarCrop() async {
    final img = _imagem;
    if (img == null) return;
    setState(() => _processando = true);

    final srcX = (_cropL * img.width).round().clamp(0, img.width);
    final srcY = (_cropT * img.height).round().clamp(0, img.height);
    final srcW =
        ((_cropR - _cropL) * img.width).round().clamp(1, img.width - srcX);
    final srcH =
        ((_cropB - _cropT) * img.height).round().clamp(1, img.height - srcY);

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.drawImageRect(
        img,
        Rect.fromLTWH(
            srcX.toDouble(), srcY.toDouble(), srcW.toDouble(), srcH.toDouble()),
        Rect.fromLTWH(0, 0, srcW.toDouble(), srcH.toDouble()),
        Paint()..filterQuality = FilterQuality.high);
    final picture = recorder.endRecording();
    final cropped = await picture.toImage(srcW, srcH);
    final byteData = await cropped.toByteData(format: ui.ImageByteFormat.png);
    if (!mounted) return;
    if (byteData == null) {
      setState(() => _processando = false);
      return;
    }
    widget.onConcluido(byteData.buffer.asUint8List());
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.theme;

    return Material(
      color: Colors.black,
      child: SafeArea(
        child: Column(children: [
          Container(
            height: 56,
            color: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(children: [
              IconButton(
                  icon: const Icon(Icons.close_rounded,
                      color: Colors.white, size: 24),
                  onPressed: widget.onCancelar,
                  tooltip: 'Cancelar'),
              const Expanded(
                  child: Text('Recortar Imagem',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w600))),
              if (_processando)
                const Padding(
                    padding: EdgeInsets.all(16),
                    child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white)))
              else
                TextButton(
                    onPressed: _confirmarCrop,
                    child: Text('Confirmar',
                        style: TextStyle(
                            color: t.primary,
                            fontSize: 15,
                            fontWeight: FontWeight.w700))),
            ]),
          ),
          Expanded(
            child: _carregando
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.white))
                : LayoutBuilder(builder: (ctx, constraints) {
                    final containerSize =
                        Size(constraints.maxWidth, constraints.maxHeight);
                    final imgRect = _calcImgRect(containerSize);
                    final cL = imgRect.left + _cropL * imgRect.width;
                    final cT = imgRect.top + _cropT * imgRect.height;
                    final cR = imgRect.left + _cropR * imgRect.width;
                    final cB = imgRect.top + _cropB * imgRect.height;
                    final cropRect = Rect.fromLTRB(cL, cT, cR, cB);
                    const hSize = 26.0;

                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onPanUpdate: (d) =>
                          _handlePan(d, _CropHandle.move, imgRect),
                      child: SizedBox(
                        width: containerSize.width,
                        height: containerSize.height,
                        child: Stack(children: [
                          Positioned.fill(
                              child: Image.memory(widget.bytesOriginais,
                                  fit: BoxFit.contain)),
                          Positioned.fill(
                              child: CustomPaint(
                                  painter: _CropPainter(
                                      cropRect: cropRect,
                                      accentColor: t.primary))),
                          _handle(cL, cT, hSize, _CropHandle.topLeft, t.primary,
                              imgRect),
                          _handle(cR, cT, hSize, _CropHandle.topRight,
                              t.primary, imgRect),
                          _handle(cL, cB, hSize, _CropHandle.bottomLeft,
                              t.primary, imgRect),
                          _handle(cR, cB, hSize, _CropHandle.bottomRight,
                              t.primary, imgRect),
                        ]),
                      ),
                    );
                  }),
          ),
          Container(
            color: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.open_with_rounded,
                      color: Colors.white38, size: 15),
                  SizedBox(width: 8),
                  Text('Arraste os pontos para ajustar o recorte',
                      style: TextStyle(color: Colors.white38, fontSize: 12))
                ]),
          ),
        ]),
      ),
    );
  }

  Widget _handle(double cx, double cy, double size, _CropHandle handle,
      Color color, Rect imgRect) {
    return Positioned(
        left: cx - size / 2,
        top: cy - size / 2,
        child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onPanUpdate: (d) => _handlePan(d, handle, imgRect),
            child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2.5),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withAlpha(140),
                          blurRadius: 6,
                          spreadRadius: 1)
                    ]))));
  }
}

enum _CropHandle { topLeft, topRight, bottomLeft, bottomRight, move }

class _CropPainter extends CustomPainter {
  const _CropPainter({required this.cropRect, required this.accentColor});
  final Rect cropRect;
  final Color accentColor;

  @override
  void paint(Canvas canvas, Size size) {
    final overlay = Paint()..color = Colors.black.withAlpha(150);
    final border = Paint()
      ..color = accentColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    final grid = Paint()
      ..color = Colors.white.withAlpha(50)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.7;

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, cropRect.top), overlay);
    canvas.drawRect(
        Rect.fromLTWH(
            0, cropRect.bottom, size.width, size.height - cropRect.bottom),
        overlay);
    canvas.drawRect(
        Rect.fromLTWH(0, cropRect.top, cropRect.left, cropRect.height),
        overlay);
    canvas.drawRect(
        Rect.fromLTWH(cropRect.right, cropRect.top, size.width - cropRect.right,
            cropRect.height),
        overlay);
    canvas.drawRect(cropRect, border);

    final tw = cropRect.width / 3;
    final th = cropRect.height / 3;
    for (int i = 1; i < 3; i++) {
      canvas.drawLine(Offset(cropRect.left + tw * i, cropRect.top),
          Offset(cropRect.left + tw * i, cropRect.bottom), grid);
      canvas.drawLine(Offset(cropRect.left, cropRect.top + th * i),
          Offset(cropRect.right, cropRect.top + th * i), grid);
    }

    final corner = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;
    const cLen = 14.0;
    canvas.drawLine(
        cropRect.topLeft, cropRect.topLeft + const Offset(cLen, 0), corner);
    canvas.drawLine(
        cropRect.topLeft, cropRect.topLeft + const Offset(0, cLen), corner);
    canvas.drawLine(
        cropRect.topRight, cropRect.topRight + const Offset(-cLen, 0), corner);
    canvas.drawLine(
        cropRect.topRight, cropRect.topRight + const Offset(0, cLen), corner);
    canvas.drawLine(cropRect.bottomLeft,
        cropRect.bottomLeft + const Offset(cLen, 0), corner);
    canvas.drawLine(cropRect.bottomLeft,
        cropRect.bottomLeft + const Offset(0, -cLen), corner);
    canvas.drawLine(cropRect.bottomRight,
        cropRect.bottomRight + const Offset(-cLen, 0), corner);
    canvas.drawLine(cropRect.bottomRight,
        cropRect.bottomRight + const Offset(0, -cLen), corner);
  }

  @override
  bool shouldRepaint(_CropPainter old) =>
      old.cropRect != cropRect || old.accentColor != accentColor;
}

// ════════════════════════════════════════════════════════════════════════════
// BOTTOM SHEET — confirmar salvar na coleção IMAGENS com todos os dados
// ════════════════════════════════════════════════════════════════════════════
class _BottomSheetConfirmarSalvar extends StatelessWidget {
  const _BottomSheetConfirmarSalvar(
      {required this.theme, required this.imagemBytes, required this.imgData});
  final FlutterFlowTheme theme;
  final Uint8List imagemBytes;
  final Map<String, dynamic> imgData;

  @override
  Widget build(BuildContext context) {
    final t = theme;
    final pat = (imgData['PATRIMONIO'] ?? 'N/A').toString();
    final tipoImg = (imgData['TIPO'] ?? '').toString();
    final urlAtual = (imgData['IMAGEM'] ?? '').toString();
    final fixa = imgData['FIXA'] == true;

    // Mapeamento de todos os campos da coleção mostrados na imagem
    final equip = imgData['_equipamento'] as Map<String, dynamic>? ?? {};
    final nomeEquip = (equip['EQUIPAMENTO'] ?? '').toString();
    final nome = (equip['NOME'] ?? '').toString();
    final marca = (equip['MARCA'] ?? '').toString();
    final modelo = (equip['MODELO'] ?? '').toString();
    final btus = (equip['BTUS'] ?? '').toString();
    final tipoEquip = (equip['TIPO'] ?? '').toString();
    final fluido = (equip['FLUIDO'] ?? '').toString();
    final tensao = (equip['TENSAO'] ?? '').toString();
    final setor = (equip['SETOR'] ?? '').toString();
    final sala = (equip['SALA'] ?? '').toString();
    final resp = (equip['RESPONSAVEL'] ?? '').toString();
    final email = (equip['EMAIL'] ?? '').toString();
    final contrato = equip['CONTRATO'] == true ? 'Sim' : 'Não';

    final tamanhoKB = (imagemBytes.lengthInBytes / 1024).toStringAsFixed(1);
    final screenH = MediaQuery.of(context).size.height;

    // Checa se tem algum dado de equipamento para renderizar a caixa
    final temEquip = nomeEquip.isNotEmpty ||
        nome.isNotEmpty ||
        marca.isNotEmpty ||
        modelo.isNotEmpty ||
        setor.isNotEmpty;

    return Container(
      height: screenH * 0.92,
      decoration: BoxDecoration(
          color: t.primaryBackground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
      child: Column(children: [
        Container(
            margin: const EdgeInsets.only(top: 10, bottom: 4),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
                color: t.secondaryText.withAlpha(80),
                borderRadius: BorderRadius.circular(2))),
        Container(
          padding: const EdgeInsets.fromLTRB(20, 10, 16, 14),
          child: Row(children: [
            Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: t.primary.withAlpha(26),
                    borderRadius: BorderRadius.circular(12)),
                child: Icon(Icons.cloud_upload_rounded,
                    color: t.primary, size: 22)),
            const SizedBox(width: 14),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text('Salvar na Coleção IMAGENS',
                      style: t.titleMedium.override(
                          fontFamily: 'Readex Pro',
                          fontWeight: FontWeight.w700)),
                  Text('Verifique a imagem e os dados antes de confirmar',
                      style: t.labelSmall.override(
                          fontFamily: 'Readex Pro', color: t.secondaryText)),
                ])),
            IconButton(
                onPressed: () => Navigator.pop(context, false),
                icon: Icon(Icons.close_rounded,
                    color: t.secondaryText, size: 22)),
          ]),
        ),
        Divider(height: 1, color: t.primaryText.withAlpha(15)),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('NOVA IMAGEM',
                  style: TextStyle(
                      color: t.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0)),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(children: [
                  Image.memory(imagemBytes,
                      width: double.infinity, height: 220, fit: BoxFit.cover),
                  Positioned(
                      bottom: 10,
                      right: 10,
                      child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                              color: Colors.black.withAlpha(180),
                              borderRadius: BorderRadius.circular(20)),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            const Icon(Icons.photo_size_select_actual_rounded,
                                color: Colors.white70, size: 12),
                            const SizedBox(width: 5),
                            Text('$tamanhoKB KB',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600))
                          ]))),
                  Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                              color: t.primary,
                              borderRadius: BorderRadius.circular(20)),
                          child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.fiber_new_rounded,
                                    color: Colors.white, size: 14),
                                SizedBox(width: 4),
                                Text('NOVA',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.8))
                              ]))),
                ]),
              ),
              const SizedBox(height: 20),
              if (urlAtual.isNotEmpty) ...[
                Text('IMAGEM ATUAL (será substituída)',
                    style: TextStyle(
                        color: t.secondaryText,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8)),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(children: [
                    CachedNetworkImage(
                        imageUrl: urlAtual,
                        width: double.infinity,
                        height: 110,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(
                            height: 110,
                            color: t.secondaryBackground,
                            child: Center(
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: t.primary))),
                        errorWidget: (_, __, ___) => Container(
                            height: 110,
                            color: t.secondaryBackground,
                            child: Center(
                                child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                  Icon(Icons.broken_image_rounded,
                                      color: Colors.red.shade400, size: 24),
                                  const SizedBox(width: 8),
                                  Text('Imagem corrompida',
                                      style: TextStyle(
                                          color: Colors.red.shade400,
                                          fontSize: 12))
                                ])))),
                    Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                                color: Colors.black.withAlpha(160),
                                borderRadius: BorderRadius.circular(12)),
                            child: const Text('ATUAL',
                                style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700)))),
                  ]),
                ),
                const SizedBox(height: 20),
              ],
              Text('DADOS DA COLEÇÃO IMAGENS',
                  style: TextStyle(
                      color: t.secondaryText,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8)),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: t.secondaryBackground,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: t.primaryText.withAlpha(15))),
                child: Column(children: [
                  _InfoRow(
                      theme: t,
                      icon: Icons.tag_rounded,
                      label: 'Patrimônio',
                      valor: pat,
                      valorCor: t.primary),
                  if (tipoImg.isNotEmpty) ...[
                    _Divider(t),
                    _InfoRow(
                        theme: t,
                        icon: Icons.label_outline_rounded,
                        label: 'Tipo',
                        valor: tipoImg)
                  ],
                  _Divider(t),
                  _InfoRow(
                      theme: t,
                      icon: Icons.push_pin_rounded,
                      label: 'Fixa',
                      valor: fixa ? 'Sim' : 'Não',
                      valorCor: fixa ? t.primary : null),
                ]),
              ),
              if (temEquip) ...[
                const SizedBox(height: 16),
                Text('DADOS COMPLETOS DO EQUIPAMENTO VINCULADO',
                    style: TextStyle(
                        color: t.secondaryText,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8)),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      color: t.secondaryBackground,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: Colors.green.shade600.withAlpha(60))),
                  child: Column(children: [
                    if (nomeEquip.isNotEmpty) ...[
                      _InfoRow(
                          theme: t,
                          icon: Icons.memory_rounded,
                          label: 'Equipamento',
                          valor: nomeEquip),
                      _DividerCompact(t)
                    ],
                    if (nome.isNotEmpty) ...[
                      _InfoRow(
                          theme: t,
                          icon: Icons.label_important_rounded,
                          label: 'Nome',
                          valor: nome),
                      _DividerCompact(t)
                    ],
                    if (marca.isNotEmpty) ...[
                      _InfoRow(
                          theme: t,
                          icon: Icons.branding_watermark_rounded,
                          label: 'Marca',
                          valor: marca),
                      _DividerCompact(t)
                    ],
                    if (modelo.isNotEmpty) ...[
                      _InfoRow(
                          theme: t,
                          icon: Icons.model_training_rounded,
                          label: 'Modelo',
                          valor: modelo),
                      _DividerCompact(t)
                    ],
                    if (btus.isNotEmpty) ...[
                      _InfoRow(
                          theme: t,
                          icon: Icons.ac_unit_rounded,
                          label: 'BTUs',
                          valor: btus),
                      _DividerCompact(t)
                    ],
                    if (tipoEquip.isNotEmpty) ...[
                      _InfoRow(
                          theme: t,
                          icon: Icons.category_rounded,
                          label: 'Tipo',
                          valor: tipoEquip),
                      _DividerCompact(t)
                    ],
                    if (fluido.isNotEmpty) ...[
                      _InfoRow(
                          theme: t,
                          icon: Icons.water_drop_rounded,
                          label: 'Fluido',
                          valor: fluido),
                      _DividerCompact(t)
                    ],
                    if (tensao.isNotEmpty) ...[
                      _InfoRow(
                          theme: t,
                          icon: Icons.electrical_services_rounded,
                          label: 'Tensão',
                          valor: tensao),
                      _DividerCompact(t)
                    ],
                    if (setor.isNotEmpty) ...[
                      _InfoRow(
                          theme: t,
                          icon: Icons.business_rounded,
                          label: 'Setor',
                          valor: setor),
                      _DividerCompact(t)
                    ],
                    if (sala.isNotEmpty) ...[
                      _InfoRow(
                          theme: t,
                          icon: Icons.room_rounded,
                          label: 'Sala',
                          valor: sala),
                      _DividerCompact(t)
                    ],
                    if (resp.isNotEmpty) ...[
                      _InfoRow(
                          theme: t,
                          icon: Icons.person_rounded,
                          label: 'Responsável',
                          valor: resp),
                      _DividerCompact(t)
                    ],
                    _InfoRow(
                        theme: t,
                        icon: Icons.assignment_turned_in_rounded,
                        label: 'Contrato',
                        valor: contrato,
                        valorCor: equip['CONTRATO'] == true
                            ? t.primary
                            : Colors.red.shade400),
                    if (email.isNotEmpty) ...[
                      _DividerCompact(t),
                      _InfoRow(
                          theme: t,
                          icon: Icons.email_rounded,
                          label: 'Email',
                          valor: email)
                    ],
                  ]),
                ),
              ],
              const SizedBox(height: 24),
            ]),
          ),
        ),
        Container(
          padding: EdgeInsets.fromLTRB(
              16, 12, 16, MediaQuery.of(context).padding.bottom + 16),
          decoration: BoxDecoration(
              color: t.primaryBackground,
              border:
                  Border(top: BorderSide(color: t.primaryText.withAlpha(15)))),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context, true),
                icon: const Icon(Icons.cloud_upload_rounded, size: 20),
                label: const Text('Salvar na Coleção IMAGENS',
                    style:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(
                    backgroundColor: t.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.pop(context, false),
                icon: const Icon(Icons.close_rounded, size: 18),
                label: const Text('Cancelar',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(color: t.secondaryText.withAlpha(80)),
                    foregroundColor: t.secondaryText,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14))),
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider(this.t);
  final FlutterFlowTheme t;
  @override
  Widget build(BuildContext context) =>
      Divider(height: 16, color: t.primaryText.withAlpha(12));
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(
      {required this.theme,
      required this.icon,
      required this.label,
      required this.valor,
      this.valorCor});
  final FlutterFlowTheme theme;
  final IconData icon;
  final String label;
  final String valor;
  final Color? valorCor;

  @override
  Widget build(BuildContext context) {
    final t = theme;
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(icon, size: 15, color: t.secondaryText)),
      const SizedBox(width: 8),
      Text('$label:',
          style: t.labelSmall
              .override(fontFamily: 'Readex Pro', color: t.secondaryText)),
      const SizedBox(width: 6),
      Expanded(
          child: Text(valor,
              style: t.labelMedium.override(
                  fontFamily: 'Readex Pro',
                  fontWeight: FontWeight.w600,
                  color: valorCor ?? t.primaryText),
              maxLines: 2,
              overflow: TextOverflow.ellipsis)),
    ]);
  }
}

// ════════════════════════════════════════════════════════════════════════════
// DIALOG — salvando imagem com animação
// ════════════════════════════════════════════════════════════════════════════
class _DialogSalvandoImagem extends StatefulWidget {
  const _DialogSalvandoImagem(
      {required this.theme,
      required this.imagemBytes,
      required this.docId,
      required this.onConcluido,
      required this.onErro});
  final FlutterFlowTheme theme;
  final Uint8List imagemBytes;
  final String docId;
  final VoidCallback onConcluido;
  final void Function(String) onErro;

  @override
  State<_DialogSalvandoImagem> createState() => _DialogSalvandoImagemState();
}

class _DialogSalvandoImagemState extends State<_DialogSalvandoImagem>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<double> _pulseAnim;
  double _progresso = 0.0;
  String _etapaLabel = 'Preparando imagem...';
  int _etapa = 0;
  bool _erro = false;
  String _erroMsg = '';

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _pulseAnim = Tween<double>(begin: 0.95, end: 1.05)
        .animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeInOut));
    _animCtrl.repeat(reverse: true);
    _executar();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _executar() async {
    try {
      await _atualizarEstado(0, 0.08, 'Preparando imagem...');
      await Future.delayed(const Duration(milliseconds: 400));
      await _atualizarEstado(1, 0.15, 'Enviando para imgBB...');
      final base64Img = base64Encode(widget.imagemBytes);
      final novaUrl = await _uploadImgBB(base64Img);
      await _atualizarEstado(2, 0.80, 'Salvando no banco de dados...');
      await Future.delayed(const Duration(milliseconds: 200));
      await FirebaseFirestore.instance
          .collection('IMAGENS')
          .doc(widget.docId)
          .update({'IMAGEM': novaUrl});
      await _atualizarEstado(3, 1.0, 'Imagem salva com sucesso! ✅');
      _animCtrl.stop();
      await Future.delayed(const Duration(milliseconds: 1200));
      widget.onConcluido();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _erro = true;
        _erroMsg = e.toString();
      });
      _animCtrl.stop();
      await Future.delayed(const Duration(milliseconds: 800));
      widget.onErro(e.toString());
    }
  }

  Future<void> _atualizarEstado(
      int etapa, double progresso, String label) async {
    if (!mounted) return;
    setState(() {
      _etapa = etapa;
      _etapaLabel = label;
    });
    final inicio = _progresso;
    final passos = 20;
    for (int i = 1; i <= passos; i++) {
      await Future.delayed(const Duration(milliseconds: 18));
      if (!mounted) return;
      setState(() => _progresso = inicio + (progresso - inicio) * (i / passos));
    }
  }

  Future<String> _uploadImgBB(String base64Img) async {
    final timer = Timer.periodic(const Duration(milliseconds: 120), (t) async {
      if (!mounted || _etapa != 1) {
        t.cancel();
        return;
      }
      final novoValor = (_progresso + 0.025).clamp(0.15, 0.75);
      if (mounted) setState(() => _progresso = novoValor);
    });

    try {
      final resp = await http.post(
        Uri.parse('https://api.imgbb.com/1/upload?key=$_kImgBBApiKey'),
        body: {'image': base64Img},
      ).timeout(const Duration(seconds: 60));
      timer.cancel();

      if (resp.statusCode != 200)
        throw Exception('imgBB retornou ${resp.statusCode}: ${resp.body}');
      final json = jsonDecode(resp.body) as Map<String, dynamic>;
      if (json['success'] != true)
        throw Exception('imgBB falhou: ${json['error']}');
      final url = json['data']?['url']?.toString() ?? '';
      if (url.isEmpty) throw Exception('URL retornada pelo imgBB está vazia');
      return url;
    } catch (e) {
      timer.cancel();
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.theme;
    final porcentagem = (_progresso * 100).toInt();

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
            color: t.secondaryBackground,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withAlpha(60),
                  blurRadius: 30,
                  spreadRadius: 2)
            ]),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ScaleTransition(
            scale: _pulseAnim,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _erro
                      ? Colors.red.shade700.withAlpha(26)
                      : _etapa == 3
                          ? Colors.green.shade600.withAlpha(26)
                          : t.primary.withAlpha(26),
                  border: Border.all(
                      color: _erro
                          ? Colors.red.shade700.withAlpha(100)
                          : _etapa == 3
                              ? Colors.green.shade600.withAlpha(100)
                              : t.primary.withAlpha(100),
                      width: 2)),
              child: _erro
                  ? Icon(Icons.error_rounded,
                      color: Colors.red.shade400, size: 38)
                  : _etapa == 3
                      ? Icon(Icons.check_circle_rounded,
                          color: Colors.green.shade500, size: 38)
                      : _etapa == 1
                          ? Icon(Icons.cloud_upload_rounded,
                              color: t.primary, size: 38)
                          : _etapa == 2
                              ? Icon(Icons.storage_rounded,
                                  color: t.primary, size: 38)
                              : Icon(Icons.image_rounded,
                                  color: t.primary, size: 38),
            ),
          ),
          const SizedBox(height: 20),
          Text(
              _erro
                  ? 'Erro ao salvar'
                  : _etapa == 3
                      ? 'Salvo com Sucesso!'
                      : 'Salvando imagem...',
              style: t.titleMedium.override(
                  fontFamily: 'Readex Pro', fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(_erro ? _erroMsg : _etapaLabel,
              textAlign: TextAlign.center,
              style: t.bodySmall.override(
                  fontFamily: 'Readex Pro',
                  color: _erro ? Colors.red.shade400 : t.secondaryText),
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 24),
          Stack(children: [
            ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                    value: _progresso,
                    minHeight: 10,
                    backgroundColor: t.primaryBackground,
                    valueColor: AlwaysStoppedAnimation(_erro
                        ? Colors.red.shade600
                        : _etapa == 3
                            ? Colors.green.shade500
                            : t.primary))),
            if (!_erro && _etapa < 3)
              AnimatedBuilder(
                  animation: _animCtrl,
                  builder: (_, __) => Positioned(
                      left: _progresso *
                          (MediaQuery.of(context).size.width - 100) *
                          (_animCtrl.value * 0.3 + 0.7),
                      top: 0,
                      child: Container(
                          width: 40,
                          height: 10,
                          decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [
                            Colors.white.withAlpha(0),
                            Colors.white.withAlpha(80),
                            Colors.white.withAlpha(0)
                          ]))))),
          ]),
          const SizedBox(height: 10),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Row(children: [
              _EtapaIndicador(
                  ativa: _etapa >= 0, concluida: _etapa > 0, cor: t.primary),
              const SizedBox(width: 4),
              _EtapaIndicador(
                  ativa: _etapa >= 1, concluida: _etapa > 1, cor: t.primary),
              const SizedBox(width: 4),
              _EtapaIndicador(
                  ativa: _etapa >= 2, concluida: _etapa > 2, cor: t.primary),
              const SizedBox(width: 4),
              _EtapaIndicador(
                  ativa: _etapa >= 3,
                  concluida: _etapa >= 3,
                  cor: Colors.green.shade500),
            ]),
            Text('$porcentagem%',
                style: TextStyle(
                    color: _etapa == 3 ? Colors.green.shade500 : t.primary,
                    fontSize: 16,
                    fontWeight: FontWeight.w800)),
          ]),
        ]),
      ),
    );
  }
}

class _EtapaIndicador extends StatelessWidget {
  const _EtapaIndicador(
      {required this.ativa, required this.concluida, required this.cor});
  final bool ativa;
  final bool concluida;
  final Color cor;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: concluida
            ? 16
            : ativa
                ? 12
                : 8,
        height: 8,
        decoration: BoxDecoration(
            color: ativa ? cor : cor.withAlpha(50),
            borderRadius: BorderRadius.circular(4)));
  }
}

// ════════════════════════════════════════════════════════════════════════════
// CARTÃO GRUPO (Aba 1)
// ════════════════════════════════════════════════════════════════════════════
class _CartaoGrupo extends StatefulWidget {
  const _CartaoGrupo(
      {super.key,
      required this.patrimonio,
      required this.equipamento,
      required this.imagens,
      required this.theme,
      required this.statusImagem,
      required this.verificando,
      required this.temCorrempida,
      required this.onApagar,
      required this.onSubstituir,
      required this.onVerImagem,
      required this.onImageError,
      required this.onImageOk});
  final String patrimonio;
  final Map<String, dynamic> equipamento;
  final List<Map<String, dynamic>> imagens;
  final FlutterFlowTheme theme;
  final Map<String, bool> statusImagem;
  final bool verificando;
  final bool temCorrempida;
  final void Function(String docId) onApagar;
  final void Function(Map<String, dynamic> imgData) onSubstituir;
  final void Function(String url) onVerImagem;
  final void Function(String docId) onImageError;
  final void Function(String docId) onImageOk;

  @override
  State<_CartaoGrupo> createState() => _CartaoGrupoState();
}

class _CartaoGrupoState extends State<_CartaoGrupo> {
  bool _expandido = false;

  @override
  Widget build(BuildContext context) {
    final t = widget.theme;
    final e = widget.equipamento;
    final nCorrompidas = widget.imagens
        .where((img) => widget.statusImagem[img['docId']] == false)
        .length;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
          color: t.secondaryBackground,
          borderRadius: BorderRadius.circular(16),
          border: widget.temCorrempida
              ? Border.all(
                  color: Colors.red.shade700.withAlpha(140), width: 1.5)
              : null,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withAlpha(20),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        InkWell(
          onTap: () => setState(() => _expandido = !_expandido),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(children: [
              Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: widget.temCorrempida
                          ? Colors.red.shade700.withAlpha(26)
                          : t.primary.withAlpha(26),
                      borderRadius: BorderRadius.circular(10)),
                  child: Icon(
                      widget.temCorrempida
                          ? Icons.broken_image_rounded
                          : Icons.memory_rounded,
                      color: widget.temCorrempida
                          ? Colors.red.shade400
                          : t.primary,
                      size: 22)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Flexible(
                            child: Text('PAT: ${widget.patrimonio}',
                                style: t.titleSmall.override(
                                    fontFamily: 'Readex Pro',
                                    fontWeight: FontWeight.w700))),
                        if (widget.temCorrempida) ...[
                          const SizedBox(width: 8),
                          _TagCorrempida(count: nCorrompidas)
                        ],
                      ]),
                      if ((e['EQUIPAMENTO'] ?? '').toString().isNotEmpty)
                        Text(e['EQUIPAMENTO'].toString(),
                            style: t.bodySmall.override(
                                fontFamily: 'Readex Pro',
                                color: t.secondaryText),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Wrap(spacing: 6, runSpacing: 4, children: [
                        if ((e['SETOR'] ?? '').toString().isNotEmpty)
                          _Chip(
                              label: e['SETOR'].toString(),
                              icon: Icons.business_rounded,
                              color: Colors.blue.shade600),
                        if ((e['SALA'] ?? '').toString().isNotEmpty)
                          _Chip(
                              label: e['SALA'].toString(),
                              icon: Icons.room_rounded,
                              color: Color(0xFF3730A3)),
                        if ((e['MARCA'] ?? '').toString().isNotEmpty)
                          _Chip(
                              label: e['MARCA'].toString(),
                              icon: Icons.branding_watermark_rounded,
                              color: Colors.teal.shade600),
                        if ((e['BTUS'] ?? '').toString().isNotEmpty)
                          _Chip(
                              label: e['BTUS'].toString(),
                              icon: Icons.ac_unit_rounded,
                              color: Color(0xFF0F766E)),
                      ]),
                    ]),
              ),
              Row(children: [
                Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                        color: t.primary.withAlpha(26),
                        borderRadius: BorderRadius.circular(20)),
                    child: Text('${widget.imagens.length} img',
                        style: TextStyle(
                            color: t.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600))),
                const SizedBox(width: 8),
                Icon(
                    _expandido
                        ? Icons.expand_less_rounded
                        : Icons.expand_more_rounded,
                    color: t.secondaryText),
              ]),
            ]),
          ),
        ),
        if (_expandido) ...[
          Divider(height: 1, color: t.primaryText.withAlpha(20)),
          Padding(
            padding: const EdgeInsets.all(14),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 0.82),
              itemCount: widget.imagens.length,
              itemBuilder: (ctx, i) {
                final img = widget.imagens[i];
                final docId = img['docId'] as String;
                return _MiniCartaoImagem(
                  imagem: img,
                  theme: t,
                  corrompida: widget.statusImagem[docId] == false,
                  verificando: widget.verificando &&
                      !widget.statusImagem.containsKey(docId),
                  onApagar: () => widget.onApagar(docId),
                  onSubstituir: () => widget.onSubstituir(img),
                  onVer: () => widget.onVerImagem(img['IMAGEM'] ?? ''),
                  onImageError: () => widget.onImageError(docId),
                  onImageOk: () => widget.onImageOk(docId),
                );
              },
            ),
          ),
        ],
      ]),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// CARTÃO IMAGEM GRANDE (Abas 2 e 3)
// ════════════════════════════════════════════════════════════════════════════
class _CartaoImagem extends StatelessWidget {
  const _CartaoImagem(
      {super.key,
      required this.imagem,
      required this.theme,
      required this.corrompida,
      required this.verificando,
      required this.onApagar,
      required this.onSubstituir,
      required this.onVerImagem,
      required this.onImageError,
      required this.onImageOk});
  final Map<String, dynamic> imagem;
  final FlutterFlowTheme theme;
  final bool corrompida;
  final bool verificando;
  final VoidCallback onApagar;
  final VoidCallback onSubstituir;
  final VoidCallback onVerImagem;
  final VoidCallback onImageError;
  final VoidCallback onImageOk;

  @override
  Widget build(BuildContext context) {
    final t = theme;
    final url = imagem['IMAGEM'] ?? '';
    final pat = imagem['PATRIMONIO'] ?? 'S/N';
    final tipo = imagem['TIPO'] ?? '';
    final fixa = imagem['FIXA'] == true;

    return Container(
      decoration: BoxDecoration(
          color: t.secondaryBackground,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: corrompida
                  ? Colors.red.shade700.withAlpha(200)
                  : Colors.orange.shade700.withAlpha(100),
              width: corrompida ? 2 : 1.5),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withAlpha(18),
                blurRadius: 6,
                offset: const Offset(0, 2))
          ]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(
          child: GestureDetector(
            onTap: onVerImagem,
            child: Stack(children: [
              ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(13)),
                  child: _buildImg(t, url)),
              if (corrompida)
                ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(13)),
                    child: Container(
                        color: Colors.red.shade900.withAlpha(190),
                        child: Center(
                            child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                              Icon(Icons.broken_image_rounded,
                                  color: Colors.red.shade200, size: 40),
                              const SizedBox(height: 6),
                              Text('CORROMPIDA',
                                  style: TextStyle(
                                      color: Colors.red.shade100,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1.2)),
                              const SizedBox(height: 2),
                              Text('Toque para substituir',
                                  style: TextStyle(
                                      color: Colors.red.shade300, fontSize: 9))
                            ])))),
              if (verificando)
                ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(13)),
                    child: Container(
                        color: Colors.black.withAlpha(110),
                        child: Center(
                            child: CircularProgressIndicator(
                                strokeWidth: 2.5, color: t.primary)))),
            ]),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 6, 6, 6),
          child: Column(children: [
            Row(children: [
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('PAT: $pat',
                          style: t.labelMedium.override(
                              fontFamily: 'Readex Pro',
                              fontWeight: FontWeight.w700,
                              color: corrompida
                                  ? Colors.red.shade400
                                  : Colors.orange.shade700),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      Row(children: [
                        if (tipo.isNotEmpty)
                          Flexible(
                              child: Text(tipo,
                                  style: t.labelSmall.override(
                                      fontFamily: 'Readex Pro',
                                      color: t.secondaryText),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis)),
                        if (fixa) ...[
                          const SizedBox(width: 4),
                          Icon(Icons.push_pin_rounded,
                              size: 12, color: t.primary)
                        ],
                      ]),
                    ]),
              ),
            ]),
            const SizedBox(height: 6),
            Row(children: [
              Expanded(
                  child: GestureDetector(
                      onTap: onSubstituir,
                      child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          decoration: BoxDecoration(
                              color: t.primary.withAlpha(26),
                              borderRadius: BorderRadius.circular(8)),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.swap_horiz_rounded,
                                    color: t.primary, size: 14),
                                const SizedBox(width: 4),
                                Text('Substituir',
                                    style: TextStyle(
                                        color: t.primary,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600))
                              ])))),
              const SizedBox(width: 6),
              GestureDetector(
                  onTap: onApagar,
                  child: Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                          color: Colors.red.shade700.withAlpha(20),
                          borderRadius: BorderRadius.circular(8)),
                      child: Icon(Icons.delete_outline_rounded,
                          color: Colors.red.shade400, size: 16))),
            ]),
          ]),
        ),
      ]),
    );
  }

  Widget _buildImg(FlutterFlowTheme t, String url) {
    if (url.isEmpty)
      return Container(
          color: t.primaryBackground,
          child: Center(
              child: Icon(Icons.link_off_rounded,
                  color: Colors.red.shade400, size: 32)));
    return CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.cover,
        width: double.infinity,
        placeholder: (_, __) => Container(
            color: t.primaryBackground,
            child: Center(
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: t.primary))),
        errorWidget: (_, __, ___) {
          WidgetsBinding.instance.addPostFrameCallback((_) => onImageError());
          return Container(
              color: t.primaryBackground,
              child: Center(
                  child: Icon(Icons.broken_image_rounded,
                      color: Colors.red.shade400, size: 32)));
        },
        imageBuilder: (_, imageProvider) {
          WidgetsBinding.instance.addPostFrameCallback((_) => onImageOk());
          return Image(
              image: imageProvider,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity);
        });
  }
}

// ════════════════════════════════════════════════════════════════════════════
// MINI CARTÃO IMAGEM (Aba 1 expandida)
// ════════════════════════════════════════════════════════════════════════════
class _MiniCartaoImagem extends StatelessWidget {
  const _MiniCartaoImagem(
      {required this.imagem,
      required this.theme,
      required this.corrompida,
      required this.verificando,
      required this.onApagar,
      required this.onSubstituir,
      required this.onVer,
      required this.onImageError,
      required this.onImageOk});
  final Map<String, dynamic> imagem;
  final FlutterFlowTheme theme;
  final bool corrompida;
  final bool verificando;
  final VoidCallback onApagar;
  final VoidCallback onSubstituir;
  final VoidCallback onVer;
  final VoidCallback onImageError;
  final VoidCallback onImageOk;

  @override
  Widget build(BuildContext context) {
    final t = theme;
    final url = imagem['IMAGEM'] ?? '';
    final tipo = imagem['TIPO'] ?? '';
    final fixa = imagem['FIXA'] == true;

    return GestureDetector(
      onTap: onVer,
      child: Container(
        decoration: BoxDecoration(
            color: t.primaryBackground,
            borderRadius: BorderRadius.circular(10),
            border: corrompida
                ? Border.all(color: Colors.red.shade600, width: 1.5)
                : null,
            boxShadow: [
              BoxShadow(color: Colors.black.withAlpha(15), blurRadius: 4)
            ]),
        child: Column(children: [
          Expanded(
            child: Stack(children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(10)),
                child: url.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: url,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        placeholder: (_, __) => Center(
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: t.primary)),
                        errorWidget: (_, __, ___) {
                          WidgetsBinding.instance
                              .addPostFrameCallback((_) => onImageError());
                          return Container(
                              color: Colors.red.shade900.withAlpha(60),
                              child: Center(
                                  child: Icon(Icons.broken_image_rounded,
                                      color: Colors.red.shade400, size: 24)));
                        },
                        imageBuilder: (_, imageProvider) {
                          WidgetsBinding.instance
                              .addPostFrameCallback((_) => onImageOk());
                          return Image(
                              image: imageProvider,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity);
                        })
                    : Container(
                        color: Colors.red.shade900.withAlpha(50),
                        child: Center(
                            child: Icon(Icons.link_off_rounded,
                                color: Colors.red.shade400, size: 24))),
              ),
              if (corrompida)
                Positioned(
                    top: 4,
                    left: 4,
                    child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                            color: Colors.red.shade700,
                            borderRadius: BorderRadius.circular(6)),
                        child: const Text('CORR.',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w800)))),
              if (verificando)
                Positioned.fill(
                    child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(10)),
                        child: Container(
                            color: Colors.black.withAlpha(90),
                            child: Center(
                                child: SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2, color: t.primary)))))),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
            child: Column(children: [
              Row(children: [
                if (fixa)
                  Padding(
                      padding: const EdgeInsets.only(right: 3),
                      child: Icon(Icons.push_pin_rounded,
                          size: 10, color: t.primary)),
                Expanded(
                    child: Text(tipo.isNotEmpty ? tipo : 'imagem',
                        style: t.labelSmall.override(
                            fontFamily: 'Readex Pro',
                            color: corrompida
                                ? Colors.red.shade400
                                : t.secondaryText),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis)),
              ]),
              const SizedBox(height: 4),
              Row(children: [
                Expanded(
                    child: GestureDetector(
                        onTap: onSubstituir,
                        child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            decoration: BoxDecoration(
                                color: t.primary.withAlpha(26),
                                borderRadius: BorderRadius.circular(6)),
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.swap_horiz_rounded,
                                      color: t.primary, size: 11),
                                  const SizedBox(width: 3),
                                  Text('Trocar',
                                      style: TextStyle(
                                          color: t.primary,
                                          fontSize: 9,
                                          fontWeight: FontWeight.w600))
                                ])))),
                const SizedBox(width: 4),
                GestureDetector(
                    onTap: onApagar,
                    child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                            color: Colors.red.shade700.withAlpha(20),
                            borderRadius: BorderRadius.circular(6)),
                        child: Icon(Icons.delete_outline_rounded,
                            size: 13, color: Colors.red.shade400))),
              ]),
            ]),
          ),
        ]),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// AUXILIARES
// ════════════════════════════════════════════════════════════════════════════
class _TagCorrempida extends StatelessWidget {
  const _TagCorrempida({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
        decoration: BoxDecoration(
            color: Colors.red.shade700, borderRadius: BorderRadius.circular(6)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.broken_image_rounded, color: Colors.white, size: 10),
          const SizedBox(width: 3),
          Text('$count CORROMPIDA${count > 1 ? 'S' : ''}',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5))
        ]));
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.icon, required this.color});
  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
            color: color.withAlpha(26),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withAlpha(80))),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  color: color, fontSize: 11, fontWeight: FontWeight.w600))
        ]));
  }
}

class _DialogConfirmarExclusao extends StatelessWidget {
  const _DialogConfirmarExclusao(
      {required this.patrimonio, this.corrompida = false});
  final String patrimonio;
  final bool corrompida;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(children: [
        Icon(Icons.delete_forever_rounded,
            color: Colors.red.shade400, size: 28),
        const SizedBox(width: 10),
        const Text('Apagar Imagem')
      ]),
      content: Text(corrompida
          ? 'Apagar imagem corrompida do patrimônio "$patrimonio"?\n\nEsta ação não pode ser desfeita.'
          : 'Apagar imagem do patrimônio "$patrimonio"?\n\nEsta ação não pode ser desfeita.'),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar')),
        ElevatedButton.icon(
            onPressed: () => Navigator.pop(context, true),
            icon: const Icon(Icons.delete_rounded, size: 18),
            label: const Text('Apagar'),
            style:
                ElevatedButton.styleFrom(backgroundColor: Colors.red.shade600)),
      ],
    );
  }
}

class _DialogVisualizarImagem extends StatelessWidget {
  const _DialogVisualizarImagem({required this.url});
  final String url;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Stack(children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: url.isEmpty
              ? Container(
                  color: Colors.grey.shade900,
                  width: 300,
                  padding: const EdgeInsets.all(40),
                  child:
                      Column(mainAxisSize: MainAxisSize.min, children: const [
                    Icon(Icons.link_off_rounded,
                        color: Colors.white54, size: 64),
                    SizedBox(height: 12),
                    Text('URL vazia ou inválida',
                        style: TextStyle(color: Colors.white54))
                  ]))
              : InteractiveViewer(
                  child: CachedNetworkImage(
                      imageUrl: url,
                      fit: BoxFit.contain,
                      placeholder: (_, __) => Container(
                          color: Colors.black,
                          width: 300,
                          height: 300,
                          child: const Center(
                              child: CircularProgressIndicator(
                                  color: Colors.white))),
                      errorWidget: (_, __, ___) => Container(
                          color: Colors.grey.shade900,
                          width: 300,
                          padding: const EdgeInsets.all(40),
                          child:
                              Column(mainAxisSize: MainAxisSize.min, children: [
                            Icon(Icons.broken_image_rounded,
                                color: Colors.red.shade400, size: 64),
                            const SizedBox(height: 12),
                            const Text('Imagem corrompida ou inacessível',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.white70)),
                            const SizedBox(height: 8),
                            Text(url,
                                textAlign: TextAlign.center,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    color: Colors.white38, fontSize: 10))
                          ])))),
        ),
        Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                        color: Colors.black.withAlpha(160),
                        shape: BoxShape.circle),
                    child: const Icon(Icons.close_rounded,
                        color: Colors.white, size: 22)))),
      ]),
    );
  }
}
