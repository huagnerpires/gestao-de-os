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

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class CadastrarEquipamentoWidget extends StatefulWidget {
  const CadastrarEquipamentoWidget({
    Key? key,
    this.width,
    this.height,
    required this.imgbbApiKey,
  }) : super(key: key);

  final double? width;
  final double? height;
  final String imgbbApiKey;

  @override
  State<CadastrarEquipamentoWidget> createState() =>
      _CadastrarEquipamentoWidgetState();
}

class _CadastrarEquipamentoWidgetState
    extends State<CadastrarEquipamentoWidget> {
  // ─── Modo ─────────────────────────────────────────────────────────────────
  String _modo = 'busca';
  bool _modoEdicao = false;
  String? _docIdEdicao;

  // ─── Busca ────────────────────────────────────────────────────────────────
  final TextEditingController _buscaCtrl = TextEditingController();
  bool _buscando = false;
  String? _erroBusca;

  // ─── Controllers ─────────────────────────────────────────────────────────
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ScrollController _listScrollCtrl = ScrollController();

  final TextEditingController _patrimCtrl = TextEditingController();
  final TextEditingController _responsavelCtrl = TextEditingController();
  final TextEditingController _setorCtrl = TextEditingController();
  final TextEditingController _salaCtrl = TextEditingController();
  final TextEditingController _marcaCtrl = TextEditingController();
  final TextEditingController _modeloCtrl = TextEditingController();
  final TextEditingController _fluidoCtrl = TextEditingController();
  final TextEditingController _btusCtrl = TextEditingController();
  final TextEditingController _tensaoCtrl = TextEditingController();
  final FocusNode _tensaoFocus = FocusNode();
  bool _tensaoFocused = false;

  // ─── Seletores ────────────────────────────────────────────────────────────
  String? _equipamentoSelecionado;
  String? _tipoSelecionado;
  String? _emailSelecionado;
  bool _contrato = false;

  // ─── Listas ───────────────────────────────────────────────────────────────
  List<String> _tiposEquipamento = [];
  bool _carregandoEquipamentos = false;
  List<String> _emails = [];
  bool _carregandoEmails = false;

  // ─── Imagem ───────────────────────────────────────────────────────────────
  String? _imagemUrlAtual;
  String? _imagemUrlNova;
  Uint8List? _imagemBytesNova;
  bool _uploadandoImagem = false;
  bool _imagemRemovida = false;

  // ─── Progresso / Validação ────────────────────────────────────────────────
  bool _salvando = false;
  String _etapaSalvando = '';
  bool _tentouSalvar = false;

  // ─── Keys para scroll até erros ───────────────────────────────────────────
  final GlobalKey _keyPatrimonio = GlobalKey();
  final GlobalKey _keyEquipamento = GlobalKey();
  final GlobalKey _keySetor = GlobalKey();
  final GlobalKey _keySala = GlobalKey();

  // ─── Tipos fixos ──────────────────────────────────────────────────────────
  static const List<String> _opcoesTipo = [
    'CONVENCIONAL',
    'INVERTER',
    'JANELA',
    'PISO TETO',
    'K7',
    'NÃO SE APLICA',
  ];

  // ─── Tema ─────────────────────────────────────────────────────────────────
  bool get _escuro => true;
  Color get _bg => const Color(0xFF0B0F17);
  Color get _card => const Color(0xFF131B2E);
  Color get _borda =>
      _escuro ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
  Color get _texto =>
      _escuro ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
  Color get _sub => _escuro ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
  Color get _fill =>
      _escuro ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9);
  static const Color _azul = Color(0xFF1D4ED8);
  static const Color _verde = Color(0xFF047857);
  static const Color _vermelho = Color(0xFFB91C1C);
  static const Color _amarelo = Color(0xFFB45309);

  // ─── Init / Dispose ───────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _carregarEquipamentos();
    _carregarEmails();
    _tensaoFocus.addListener(() {
      if (!_tensaoFocus.hasFocus) {
        final v = _tensaoCtrl.text.trim();
        if (v.isNotEmpty && !v.toUpperCase().endsWith('V')) {
          setState(() {
            _tensaoCtrl.text = v + 'V';
            _tensaoCtrl.selection =
                TextSelection.collapsed(offset: _tensaoCtrl.text.length);
          });
        }
      }
      setState(() => _tensaoFocused = _tensaoFocus.hasFocus);
    });
  }

  @override
  void dispose() {
    for (final c in [
      _buscaCtrl,
      _patrimCtrl,
      _responsavelCtrl,
      _setorCtrl,
      _salaCtrl,
      _marcaCtrl,
      _modeloCtrl,
      _fluidoCtrl,
      _btusCtrl,
      _tensaoCtrl
    ]) c.dispose();
    _tensaoFocus.dispose();
    _listScrollCtrl.dispose();
    super.dispose();
  }

  // ─── Carregar dados ───────────────────────────────────────────────────────

  Future<void> _carregarEquipamentos() async {
    setState(() => _carregandoEquipamentos = true);
    try {
      final snap = await FirebaseFirestore.instance
          .collection('EQUIPAMENTOSCADASTRO')
          .get();
      final lista = <String>[];
      for (final doc in snap.docs) {
        final d = doc.data();
        String nome = '';
        for (final campo in [
          'EQUIPAMENTOS',
          'EQUIPAMENTO',
          'NOME',
          'nome',
          'equipamento',
          'DESCRICAO',
          'descricao'
        ]) {
          final v = (d[campo] ?? '').toString().trim();
          if (v.isNotEmpty) {
            nome = v;
            break;
          }
        }
        if (nome.isEmpty) nome = doc.id;
        final up = nome.toUpperCase();
        if (!lista.contains(up)) lista.add(up);
      }
      lista.sort();
      setState(() => _tiposEquipamento = lista);
    } catch (e) {
      debugPrint('EQUIPAMENTOSCADASTRO erro: $e');
    } finally {
      setState(() => _carregandoEquipamentos = false);
    }
  }

  Future<void> _carregarEmails() async {
    setState(() => _carregandoEmails = true);
    try {
      final snap =
          await FirebaseFirestore.instance.collection('USUARIOS').get();
      final lista = <String>[];
      for (final doc in snap.docs) {
        final email = (doc.data()['email'] ?? doc.data()['EMAIL'] ?? '')
            .toString()
            .trim();
        if (email.isNotEmpty && !lista.contains(email)) lista.add(email);
      }
      lista.sort();
      setState(() => _emails = lista);
    } catch (_) {
    } finally {
      setState(() => _carregandoEmails = false);
    }
  }

  // ─── Busca patrimônio ─────────────────────────────────────────────────────

  Future<void> _buscarPatrimonio() async {
    final pat = _buscaCtrl.text.trim();
    if (pat.isEmpty) return;
    setState(() {
      _buscando = true;
      _erroBusca = null;
    });
    try {
      final snap = await FirebaseFirestore.instance
          .collection('EQUIPAMENTOS_EMPRESA')
          .where('PATRIMONIO', isEqualTo: pat)
          .limit(1)
          .get();
      if (snap.docs.isNotEmpty) {
        _preencherFormulario(snap.docs.first.data(), docId: snap.docs.first.id);
        setState(() {
          _modoEdicao = true;
          _docIdEdicao = snap.docs.first.id;
          _modo = 'form';
        });
      } else {
        _limparFormulario();
        _patrimCtrl.text = pat;
        setState(() {
          _modoEdicao = false;
          _docIdEdicao = null;
          _modo = 'form';
        });
      }
    } catch (e) {
      setState(() => _erroBusca = 'Erro: $e');
    } finally {
      setState(() => _buscando = false);
    }
  }

  void _preencherFormulario(Map<String, dynamic> d, {required String docId}) {
    _patrimCtrl.text = (d['PATRIMONIO'] ?? '').toString();
    _responsavelCtrl.text = (d['RESPONSAVEL'] ?? '').toString();
    _marcaCtrl.text = (d['MARCA'] ?? '').toString();
    _modeloCtrl.text = (d['MODELO'] ?? '').toString();
    _setorCtrl.text = (d['SETOR'] ?? '').toString();
    _salaCtrl.text = (d['SALA'] ?? '').toString();
    _fluidoCtrl.text = (d['FLUIDO'] ?? '').toString();
    _btusCtrl.text = (d['BTUS'] ?? '').toString();
    _tensaoCtrl.text = (d['TENSAO'] ?? '').toString();
    final equip = (d['EQUIPAMENTO'] ?? '').toString().trim();
    _equipamentoSelecionado = equip.isNotEmpty ? equip : null;
    final tipo = (d['TIPO'] ?? '').toString().trim();
    _tipoSelecionado = tipo.isNotEmpty ? tipo : null;
    final email = (d['EMAIL'] ?? '').toString().trim();
    _emailSelecionado = email.isNotEmpty ? email : null;
    _contrato = d['CONTRATO'] == true || d['CONTRATO'] == 'true';
    _imagemUrlAtual = null;
    _imagemUrlNova = null;
    _imagemBytesNova = null;
    _imagemRemovida = false;
    _tentouSalvar = false;
    _buscarImagemExistente(_patrimCtrl.text);
  }

  Future<void> _buscarImagemExistente(String pat) async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('IMAGENS')
          .where('PATRIMONIO', isEqualTo: pat)
          .limit(1)
          .get();
      if (snap.docs.isNotEmpty) {
        final url = (snap.docs.first.data()['IMAGEM'] ?? '').toString();
        if (mounted) setState(() => _imagemUrlAtual = url);
      }
    } catch (_) {}
  }

  void _limparFormulario() {
    for (final c in [
      _patrimCtrl,
      _responsavelCtrl,
      _setorCtrl,
      _salaCtrl,
      _marcaCtrl,
      _modeloCtrl,
      _fluidoCtrl,
      _btusCtrl,
      _tensaoCtrl
    ]) c.clear();
    _equipamentoSelecionado = null;
    _tipoSelecionado = null;
    _emailSelecionado = null;
    _contrato = false;
    _imagemUrlAtual = null;
    _imagemUrlNova = null;
    _imagemBytesNova = null;
    _imagemRemovida = false;
    _docIdEdicao = null;
    _tentouSalvar = false;
  }

  // ─── Selecionar e Cortar Imagem ──────────────────────────────────────────

  Future<void> _escolherFonteImagem() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: _card,
      isDismissible: true,
      enableDrag: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.only(bottom: 24, top: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 4, 0),
              child: Row(children: [
                Expanded(
                  child: Container(
                    height: 4,
                    width: 40,
                    decoration: BoxDecoration(
                        color: _borda, borderRadius: BorderRadius.circular(2)),
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined, color: _azul),
              title: Text('Tirar Foto', style: TextStyle(color: _texto)),
              onTap: () {
                Navigator.pop(ctx);
                _capturarECroparImagem(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined, color: _azul),
              title:
                  Text('Escolher da Galeria', style: TextStyle(color: _texto)),
              onTap: () {
                Navigator.pop(ctx);
                _capturarECroparImagem(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _capturarECroparImagem(ImageSource source) async {
    final picked = await ImagePicker()
        .pickImage(source: source, imageQuality: 85, maxWidth: 1200);
    if (picked == null) return;

    final querRecortar = await showDialog<bool>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: _card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: _azul.withAlpha(30), shape: BoxShape.circle),
              child: const Icon(Icons.crop, color: _azul, size: 32),
            ),
            const SizedBox(height: 16),
            Text('Ajustar Imagem?',
                style: TextStyle(
                    color: _texto, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              'Deseja recortar a imagem antes de anexá-la?',
              textAlign: TextAlign.center,
              style: TextStyle(color: _sub, fontSize: 13, height: 1.5),
            ),
            const SizedBox(height: 24),
            Row(children: [
              Expanded(
                  child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: _sub),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () => Navigator.pop(ctx, false),
                child: Text('Original',
                    style: TextStyle(color: _sub, fontWeight: FontWeight.w600)),
              )),
              const SizedBox(width: 10),
              Expanded(
                  child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _azul,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Recortar',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              )),
            ]),
          ]),
        ),
      ),
    );

    if (querRecortar == null) return;

    setState(() => _uploadandoImagem = true);

    try {
      if (querRecortar) {
        final croppedFile = await ImageCropper().cropImage(
          sourcePath: picked.path,
          compressFormat: ImageCompressFormat.jpg,
          compressQuality: 85,
          uiSettings: [
            AndroidUiSettings(
                toolbarTitle: 'Ajustar Imagem',
                toolbarColor: const Color(0xFF111827),
                toolbarWidgetColor: Colors.white,
                initAspectRatio: CropAspectRatioPreset.original,
                lockAspectRatio: false),
            IOSUiSettings(
              title: 'Recortar',
              aspectRatioLockEnabled: false,
            ),
            WebUiSettings(context: context),
          ],
        );

        if (croppedFile != null) {
          final bytes = await croppedFile.readAsBytes();
          setState(() {
            _imagemBytesNova = bytes;
            _imagemUrlNova = null;
            _imagemRemovida = false;
          });
        }
      } else {
        final bytes = await picked.readAsBytes();
        setState(() {
          _imagemBytesNova = bytes;
          _imagemUrlNova = null;
          _imagemRemovida = false;
        });
      }
    } catch (e) {
      _snack('❌ Erro ao processar a imagem: $e', _vermelho);
    } finally {
      setState(() => _uploadandoImagem = false);
    }
  }

  // ─── Validação rica ───────────────────────────────────────────────────────

  List<Map<String, dynamic>> _validarCampos() {
    final erros = <Map<String, dynamic>>[];
    if (_patrimCtrl.text.trim().isEmpty) {
      erros.add({'label': 'Patrimônio', 'key': _keyPatrimonio});
    }
    if (_equipamentoSelecionado == null || _equipamentoSelecionado!.isEmpty) {
      erros.add({'label': 'Equipamento', 'key': _keyEquipamento});
    }
    if (_setorCtrl.text.trim().isEmpty) {
      erros.add({'label': 'Setor', 'key': _keySetor});
    }
    if (_salaCtrl.text.trim().isEmpty) {
      erros.add({'label': 'Sala', 'key': _keySala});
    }
    return erros;
  }

  void _rolarPara(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(ctx,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOut,
        alignment: 0.1);
  }

  // ─── Excluir Equipamento ──────────────────────────────────────────────────
  Future<void> _excluir() async {
    final pat = _patrimCtrl.text.trim();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: _card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: _vermelho.withAlpha(30), shape: BoxShape.circle),
              child:
                  const Icon(Icons.delete_outline, color: _vermelho, size: 32),
            ),
            const SizedBox(height: 16),
            Text('Excluir Equipamento?',
                style: TextStyle(
                    color: _texto, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              'Deseja realmente excluir o patrimônio $pat e suas imagens associadas? Esta ação não pode ser desfeita.',
              textAlign: TextAlign.center,
              style: TextStyle(color: _sub, fontSize: 13, height: 1.5),
            ),
            const SizedBox(height: 24),
            Row(children: [
              Expanded(
                  child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: _sub),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () => Navigator.pop(ctx, false),
                child: Text('Cancelar',
                    style: TextStyle(color: _sub, fontWeight: FontWeight.w600)),
              )),
              const SizedBox(width: 10),
              Expanded(
                  child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _vermelho,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Excluir',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              )),
            ]),
          ]),
        ),
      ),
    );

    if (confirm != true) return;

    setState(() {
      _salvando = true;
      _etapaSalvando = 'Excluindo equipamento e imagens...';
    });

    try {
      final fs = FirebaseFirestore.instance;

      if (_docIdEdicao != null) {
        await fs.collection('EQUIPAMENTOS_EMPRESA').doc(_docIdEdicao).delete();
      }

      final snapImagens = await fs
          .collection('IMAGENS')
          .where('PATRIMONIO', isEqualTo: pat)
          .get();

      if (snapImagens.docs.isNotEmpty) {
        final batch = fs.batch();
        for (final doc in snapImagens.docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();
      }

      setState(() => _etapaSalvando = 'Exclusão concluída! 🗑️');
      await Future.delayed(const Duration(milliseconds: 500));
      _snack('🗑️ Equipamento e imagens excluídos com sucesso!', _verde);

      setState(() {
        _modo = 'busca';
        _buscaCtrl.clear();
        _limparFormulario();
      });
    } catch (e) {
      _snack('❌ Erro ao excluir: $e', _vermelho);
    } finally {
      setState(() {
        _salvando = false;
        _etapaSalvando = '';
      });
    }
  }

  // ─── Dialogs ──────────────────────────────────────────────────────────────

  void _mostrarErros(List<Map<String, dynamic>> erros) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: _card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: _vermelho.withAlpha(30),
                      borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.error_outline,
                      color: _vermelho, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                    child: Text('Campos obrigatórios',
                        style: TextStyle(
                            color: _texto,
                            fontSize: 15,
                            fontWeight: FontWeight.bold))),
              ]),
              const SizedBox(height: 10),
              Text('Preencha os campos abaixo antes de salvar:',
                  style: TextStyle(color: _sub, fontSize: 13)),
              const SizedBox(height: 14),
              ...erros.map((e) => GestureDetector(
                    onTap: () {
                      Navigator.pop(ctx);
                      Future.delayed(const Duration(milliseconds: 250),
                          () => _rolarPara(e['key'] as GlobalKey));
                    },
                    child: Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 13),
                      decoration: BoxDecoration(
                        color: _vermelho.withAlpha(20),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: _vermelho.withAlpha(100)),
                      ),
                      child: Row(children: [
                        const Icon(Icons.arrow_forward_ios,
                            color: _vermelho, size: 13),
                        const SizedBox(width: 8),
                        Expanded(
                            child: Text(e['label'] as String,
                                style: const TextStyle(
                                    color: _vermelho,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600))),
                        Text('Ir para campo →',
                            style: TextStyle(
                                color: _vermelho.withAlpha(180), fontSize: 11)),
                      ]),
                    ),
                  )),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _azul,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                  ),
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Entendido',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _confirmarSemImagem() async {
    final res = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: _card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                  color: _amarelo.withAlpha(30), shape: BoxShape.circle),
              child: const Icon(Icons.image_not_supported_outlined,
                  color: _amarelo, size: 32),
            ),
            const SizedBox(height: 16),
            Text('Sem imagem',
                style: TextStyle(
                    color: _texto, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              'Nenhuma foto foi adicionada para este equipamento.\nDeseja salvar mesmo assim?',
              textAlign: TextAlign.center,
              style: TextStyle(color: _sub, fontSize: 13, height: 1.5),
            ),
            const SizedBox(height: 24),
            Row(children: [
              Expanded(
                  child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: _azul),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () => Navigator.pop(ctx, false),
                child: Text('Adicionar foto',
                    style:
                        TextStyle(color: _azul, fontWeight: FontWeight.w600)),
              )),
              const SizedBox(width: 10),
              Expanded(
                  child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _amarelo,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Salvar assim',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              )),
            ]),
          ]),
        ),
      ),
    );
    return res ?? false;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // NOTIFICAÇÃO FIREBASE — cria doc na coleção NOTIFICACAO ao salvar equipamento
  // Chamado com unawaited() para não bloquear o fluxo de salvamento.
  // Campo 'os' vazio pois cadastro/edição de equipamento não tem O.S. associada.
  // ═══════════════════════════════════════════════════════════════════════════
  Future<void> _criarNotificacaoFirebase({
    required String email,
    required String patrimonio,
    required String equipamento,
    required bool edicao,
  }) async {
    if (email.isEmpty) return;
    try {
      await FirebaseFirestore.instance.collection('NOTIFICACAO').add({
        'email': email,
        'titulo':
            edicao ? '✏️ Equipamento Atualizado' : '✅ Equipamento Cadastrado',
        'mensagem': edicao
            ? 'Os dados do equipamento $equipamento (Patrimônio: $patrimonio) foram atualizados no sistema.'
            : 'O equipamento $equipamento (Patrimônio: $patrimonio) foi cadastrado com sucesso no sistema.',
        'tipo': 'sistema',
        'visto': false,
        'data': Timestamp.now(),
        'status': edicao ? 'atualizado' : 'cadastrado',
        'os': '',
      });
    } catch (e) {
      debugPrint('Erro ao criar notificação Firebase: $e');
    }
  }

  // ─── Salvar ───────────────────────────────────────────────────────────────

  Future<void> _salvar() async {
    setState(() => _tentouSalvar = true);

    final erros = _validarCampos();
    if (erros.isNotEmpty) {
      await Future.delayed(const Duration(milliseconds: 80));
      _rolarPara(erros.first['key'] as GlobalKey);
      _mostrarErros(erros);
      return;
    }

    final pat = _patrimCtrl.text.trim();

    if (!_modoEdicao) {
      setState(() {
        _salvando = true;
        _etapaSalvando = 'Verificando patrimônio...';
      });
      final existe = await FirebaseFirestore.instance
          .collection('EQUIPAMENTOS_EMPRESA')
          .where('PATRIMONIO', isEqualTo: pat)
          .limit(1)
          .get();
      setState(() => _salvando = false);
      if (existe.docs.isNotEmpty) {
        _snack('⚠️ Patrimônio $pat já cadastrado!', _amarelo);
        return;
      }
    }

    final temImg = !_imagemRemovida &&
        (_imagemBytesNova != null || _imagemUrlAtual != null);
    if (!temImg) {
      final ok = await _confirmarSemImagem();
      if (!ok) return;
    }

    setState(() {
      _salvando = true;
      _etapaSalvando = 'Preparando dados...';
    });

    try {
      final fs = FirebaseFirestore.instance;
      String? urlFinalParaSalvar = _imagemUrlAtual;

      if (_imagemBytesNova != null && !_imagemRemovida) {
        setState(() => _etapaSalvando = 'Fazendo upload da imagem...');

        final base64Str = base64Encode(_imagemBytesNova!);
        final nomeArquivo = pat.replaceAll(RegExp(r'[^a-zA-Z0-9_\-]'), '_');

        final res = await http.post(
          Uri.parse(
              'https://api.imgbb.com/1/upload?key=${widget.imgbbApiKey}&name=${Uri.encodeComponent(nomeArquivo)}'),
          body: {
            'image': base64Str,
            'name': nomeArquivo,
          },
        );

        if (res.statusCode != 200) throw Exception('imgBB ${res.statusCode}');
        urlFinalParaSalvar = jsonDecode(res.body)['data']['url'] as String;
      }

      final tensao = _tensaoCtrl.text.trim().isEmpty
          ? ''
          : _tensaoCtrl.text.trim().toUpperCase().endsWith('V')
              ? _tensaoCtrl.text.trim().toUpperCase()
              : _tensaoCtrl.text.trim().toUpperCase() + 'V';

      final dados = {
        'PATRIMONIO': pat,
        'EQUIPAMENTO': (_equipamentoSelecionado ?? '').toUpperCase(),
        'NOME': (_equipamentoSelecionado ?? '').toUpperCase(),
        'RESPONSAVEL': _responsavelCtrl.text.trim().toUpperCase(),
        'SETOR': _setorCtrl.text.trim().toUpperCase(),
        'SALA': _salaCtrl.text.trim().toUpperCase(),
        'MARCA': _marcaCtrl.text.trim().toUpperCase(),
        'MODELO': _modeloCtrl.text.trim().toUpperCase(),
        'FLUIDO': _fluidoCtrl.text.trim().toUpperCase(),
        'BTUS': _btusCtrl.text.trim().toUpperCase(),
        'TENSAO': tensao,
        'TIPO': (_tipoSelecionado ?? '').toUpperCase(),
        'EMAIL': (_emailSelecionado ?? '').toLowerCase(),
        'CONTRATO': _contrato,
      };

      setState(() => _etapaSalvando = _modoEdicao
          ? 'Atualizando equipamento...'
          : 'Cadastrando equipamento...');

      if (_modoEdicao && _docIdEdicao != null) {
        await fs
            .collection('EQUIPAMENTOS_EMPRESA')
            .doc(_docIdEdicao)
            .update(dados);
      } else {
        await fs.collection('EQUIPAMENTOS_EMPRESA').add(dados);
      }

      setState(() => _etapaSalvando = 'Salvando dados da imagem...');

      if (_imagemRemovida) {
        final snap = await fs
            .collection('IMAGENS')
            .where('PATRIMONIO', isEqualTo: pat)
            .get();
        for (final d in snap.docs) await d.reference.delete();
      } else if (urlFinalParaSalvar != null && urlFinalParaSalvar.isNotEmpty) {
        final snap = await fs
            .collection('IMAGENS')
            .where('PATRIMONIO', isEqualTo: pat)
            .limit(1)
            .get();
        if (snap.docs.isNotEmpty) {
          await snap.docs.first.reference
              .update({'IMAGEM': urlFinalParaSalvar});
        } else {
          await fs.collection('IMAGENS').add({
            'PATRIMONIO': pat,
            'IMAGEM': urlFinalParaSalvar,
            'TIPO': 'imagem',
            'FIXA': true,
          });
        }
      }

      // ── NOVO: notificação Firebase ────────────────────────────────────────
      // Disparo assíncrono com unawaited() — não bloqueia o fluxo de salvamento.
      // Só dispara se houver email do cliente selecionado.
      if ((_emailSelecionado ?? '').isNotEmpty) {
        unawaited(_criarNotificacaoFirebase(
          email: _emailSelecionado!,
          patrimonio: pat,
          equipamento: (_equipamentoSelecionado ?? '').toUpperCase(),
          edicao: _modoEdicao,
        ));
      }
      // ─────────────────────────────────────────────────────────────────────

      setState(() => _etapaSalvando = 'Concluído! ✅');
      await Future.delayed(const Duration(milliseconds: 500));
      _snack(
          _modoEdicao
              ? '✅ Equipamento atualizado!'
              : '✅ Equipamento cadastrado!',
          _verde);
      setState(() {
        _modo = 'busca';
        _buscaCtrl.clear();
        _limparFormulario();
      });
    } catch (e) {
      _snack('❌ Erro ao salvar: $e', _vermelho);
    } finally {
      setState(() {
        _salvando = false;
        _etapaSalvando = '';
      });
    }
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
      _buildHeaderBusca(),
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
                  _iconBox(Icons.search, _azul),
                  const SizedBox(width: 10),
                  Text('Buscar por Patrimônio',
                      style: TextStyle(
                          color: _texto,
                          fontSize: 15,
                          fontWeight: FontWeight.bold)),
                ]),
                const SizedBox(height: 10),
                Text(
                    'Digite o número do patrimônio para editar ou cadastrar novo.',
                    style: TextStyle(color: _sub, fontSize: 13)),
                const SizedBox(height: 16),
                Row(children: [
                  Expanded(
                      child: _input(
                    ctrl: _buscaCtrl,
                    label: 'Número do Patrimônio',
                    icon: Icons.tag,
                    tipo: TextInputType.number,
                    onSubmit: (_) => _buscarPatrimonio(),
                  )),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: _buscando ? null : _buscarPatrimonio,
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                            colors: [_azul, Color(0xFF0077A8)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: _buscando
                          ? const Center(
                              child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2.5)))
                          : const Icon(Icons.arrow_forward,
                              color: Colors.white, size: 22),
                    ),
                  ),
                ]),
                if (_erroBusca != null) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _vermelho.withAlpha(25),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _vermelho.withAlpha(80)),
                    ),
                    child: Row(children: [
                      const Icon(Icons.error_outline,
                          color: _vermelho, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                          child: Text(_erroBusca!,
                              style: const TextStyle(
                                  color: _vermelho, fontSize: 12))),
                    ]),
                  ),
                ],
              ])),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () {
              _limparFormulario();
              setState(() {
                _modoEdicao = false;
                _modo = 'form';
              });
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: _verde.withAlpha(25),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _verde.withAlpha(120)),
              ),
              child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_circle_outline, color: _verde, size: 20),
                    SizedBox(width: 8),
                    Text('Novo Cadastro',
                        style: TextStyle(
                            color: _verde,
                            fontSize: 14,
                            fontWeight: FontWeight.bold)),
                  ]),
            ),
          ),
        ]),
      )),
    ]);
  }

  Widget _buildHeaderBusca() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _card,
        border: Border(bottom: BorderSide(color: _borda)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withAlpha(30),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(children: [
        _iconBox(Icons.devices, _azul),
        const SizedBox(width: 12),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Equipamentos',
              style: GoogleFonts.interTight(
                  color: _texto, fontSize: 16, fontWeight: FontWeight.w700)),
          Text('Cadastrar / Editar',
              style: TextStyle(color: _sub, fontSize: 11)),
        ])),
      ]),
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
              _sec('📷 Imagem do Equipamento'),
              const SizedBox(height: 10),
              _buildCardImagem(),
              const SizedBox(height: 20),
              _sec('🔖 Identificação'),
              const SizedBox(height: 10),
              _card_(
                  child: Column(children: [
                KeyedSubtree(
                  key: _keyPatrimonio,
                  child: _input(
                    ctrl: _patrimCtrl,
                    label: 'Patrimônio *',
                    icon: Icons.tag,
                    tipo: TextInputType.number,
                    readOnly: _modoEdicao,
                    erro: _tentouSalvar && _patrimCtrl.text.trim().isEmpty,
                    validator: (v) =>
                        (v ?? '').trim().isEmpty ? 'Obrigatório' : null,
                  ),
                ),
                const SizedBox(height: 12),
                KeyedSubtree(key: _keyEquipamento, child: _buildSeletorEquip()),
                const SizedBox(height: 12),
                _input(
                    ctrl: _responsavelCtrl,
                    label: 'Responsável',
                    icon: Icons.person_outline,
                    upper: true),
              ])),
              const SizedBox(height: 20),
              _sec('📍 Localização'),
              const SizedBox(height: 10),
              _card_(
                  child: Column(children: [
                KeyedSubtree(
                  key: _keySetor,
                  child: _input(
                      ctrl: _setorCtrl,
                      label: 'Setor *',
                      icon: Icons.apartment,
                      upper: true,
                      erro: _tentouSalvar && _setorCtrl.text.trim().isEmpty),
                ),
                const SizedBox(height: 12),
                KeyedSubtree(
                  key: _keySala,
                  child: _input(
                      ctrl: _salaCtrl,
                      label: 'Sala *',
                      icon: Icons.meeting_room_outlined,
                      upper: true,
                      erro: _tentouSalvar && _salaCtrl.text.trim().isEmpty),
                ),
              ])),
              const SizedBox(height: 20),
              _sec('⚙️ Especificações Técnicas'),
              const SizedBox(height: 10),
              _card_(
                  child: Column(children: [
                _input(
                    ctrl: _marcaCtrl,
                    label: 'Marca',
                    icon: Icons.branding_watermark_outlined,
                    upper: true),
                const SizedBox(height: 12),
                _input(
                    ctrl: _modeloCtrl,
                    label: 'Modelo',
                    icon: Icons.model_training,
                    upper: true),
                const SizedBox(height: 12),
                _input(
                    ctrl: _fluidoCtrl,
                    label: 'Fluido',
                    icon: Icons.water_drop_outlined,
                    upper: true),
                const SizedBox(height: 12),
                _input(
                    ctrl: _btusCtrl,
                    label: 'BTUs / Capacidade / Litros',
                    icon: Icons.thermostat_outlined,
                    upper: true),
                const SizedBox(height: 12),
                _buildTensao(),
                const SizedBox(height: 12),
                _buildSeletorTipo(),
              ])),
              const SizedBox(height: 20),
              _sec('📧 Cliente'),
              const SizedBox(height: 10),
              _card_(child: _buildDropEmail()),
              const SizedBox(height: 20),
              _sec('📋 Contrato'),
              const SizedBox(height: 10),
              _buildCardContrato(),
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
                boxShadow: [
                  BoxShadow(color: Colors.black.withAlpha(100), blurRadius: 30)
                ],
              ),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                SizedBox(
                    width: 70,
                    height: 70,
                    child: CircularProgressIndicator(
                        color: _azul, strokeWidth: 5, backgroundColor: _borda)),
                const SizedBox(height: 24),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    _etapaSalvando.isEmpty ? 'Salvando...' : _etapaSalvando,
                    key: ValueKey(_etapaSalvando),
                    style: TextStyle(
                        color: _texto,
                        fontSize: 15,
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 6),
                Text('Por favor, aguarde',
                    style: TextStyle(color: _sub, fontSize: 12)),
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
        boxShadow: [
          BoxShadow(
              color: Colors.black.withAlpha(30),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(children: [
        _backBtn(() => setState(() {
              _modo = 'busca';
              _limparFormulario();
            })),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _modoEdicao
                  ? [_amarelo, const Color(0xFFB45309)]
                  : [_verde, const Color(0xFF047857)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(_modoEdicao ? Icons.edit : Icons.add,
              color: Colors.white, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(_modoEdicao ? 'Editar Equipamento' : 'Novo Equipamento',
              style: GoogleFonts.interTight(
                  color: _texto, fontSize: 15, fontWeight: FontWeight.w700)),
          Text(
              _modoEdicao
                  ? 'PAT: ${_patrimCtrl.text}'
                  : 'Preencha os campos abaixo',
              style: TextStyle(color: _sub, fontSize: 11)),
        ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: (_modoEdicao ? _amarelo : _verde).withAlpha(30),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: (_modoEdicao ? _amarelo : _verde).withAlpha(120)),
          ),
          child: Text(_modoEdicao ? 'Edição' : 'Novo',
              style: TextStyle(
                  color: _modoEdicao ? _amarelo : _verde,
                  fontSize: 11,
                  fontWeight: FontWeight.bold)),
        ),
      ]),
    );
  }

  Widget _buildCardImagem() {
    final bool temNovaLocal = _imagemBytesNova != null && !_imagemRemovida;
    final String? urlAtual = _imagemRemovida ? null : _imagemUrlAtual;
    final bool temQualquerImagem = temNovaLocal || urlAtual != null;

    return _card_(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: temQualquerImagem
                ? () => _showImgDialog(url: urlAtual, bytes: _imagemBytesNova)
                : (_uploadandoImagem ? null : _escolherFonteImagem),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: double.infinity,
              height: temQualquerImagem ? 260 : 140,
              decoration: BoxDecoration(
                color: _borda,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: temQualquerImagem ? _azul.withAlpha(150) : _borda,
                    width: temQualquerImagem ? 2 : 1),
              ),
              clipBehavior: Clip.antiAlias,
              child: _uploadandoImagem
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: _azul, strokeWidth: 2.5))
                  : temNovaLocal
                      ? Image.memory(_imagemBytesNova!,
                          fit: BoxFit.cover, width: double.infinity)
                      : urlAtual != null
                          ? Image.network(urlAtual,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              errorBuilder: (c, e, s) => const Icon(
                                  Icons.broken_image,
                                  color: _vermelho))
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                  Icon(Icons.image_outlined,
                                      color: _sub, size: 48),
                                  const SizedBox(height: 12),
                                  Text('Toque para adicionar foto',
                                      style:
                                          TextStyle(color: _sub, fontSize: 13)),
                                ]),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _minibtn(
                  temQualquerImagem ? 'Trocar Foto' : 'Adicionar Foto',
                  Icons.add_photo_alternate_outlined,
                  _azul,
                  _uploadandoImagem ? null : _escolherFonteImagem),
              if (temQualquerImagem) ...[
                const SizedBox(width: 12),
                _minibtn('Remover', Icons.delete_outline, _vermelho, () {
                  setState(() {
                    _imagemRemovida = true;
                    _imagemBytesNova = null;
                    _imagemUrlNova = null;
                  });
                }),
              ],
            ],
          ),
        ],
      ),
    );
  }

  void _showImgDialog({String? url, Uint8List? bytes}) {
    showDialog(
        context: context,
        builder: (ctx) => Dialog(
              backgroundColor: const Color(0xFF111827),
              insetPadding: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Row(children: [
                  const Expanded(
                      child: Padding(
                          padding: EdgeInsets.fromLTRB(16, 12, 0, 12),
                          child: Text('Prévia',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)))),
                  IconButton(
                      icon: const Icon(Icons.close, color: Colors.white54),
                      onPressed: () => Navigator.pop(ctx)),
                ]),
                Flexible(
                    child: InteractiveViewer(
                        child: bytes != null
                            ? Image.memory(bytes, fit: BoxFit.contain)
                            : Image.network(url ?? '', fit: BoxFit.contain))),
                const SizedBox(height: 12),
              ]),
            ));
  }

  Widget _buildSeletorEquip() {
    final ok = _equipamentoSelecionado != null;
    final erro = _tentouSalvar && !ok;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _labelRow(Icons.settings, 'Equipamento *', erro: erro),
      const SizedBox(height: 8),
      GestureDetector(
        onTap: _carregandoEquipamentos ? null : _openEquipSheet,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: erro ? _vermelho.withAlpha(15) : _fill,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: erro
                  ? _vermelho
                  : ok
                      ? _azul.withAlpha(150)
                      : _borda,
              width: erro || ok ? 1.5 : 1,
            ),
          ),
          child: Row(children: [
            Icon(ok ? Icons.check_circle_outline : Icons.touch_app_outlined,
                color: erro
                    ? _vermelho
                    : ok
                        ? _azul
                        : _sub,
                size: 18),
            const SizedBox(width: 10),
            Expanded(
                child: _carregandoEquipamentos
                    ? Row(children: [
                        SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                                color: _sub, strokeWidth: 2)),
                        const SizedBox(width: 8),
                        Text('Carregando...',
                            style: TextStyle(color: _sub, fontSize: 13)),
                      ])
                    : Text(
                        _equipamentoSelecionado ?? 'Selecionar equipamento...',
                        style: TextStyle(
                            color: erro
                                ? _vermelho
                                : ok
                                    ? _texto
                                    : _sub,
                            fontSize: 13),
                        overflow: TextOverflow.ellipsis)),
            Icon(Icons.expand_more, color: _sub, size: 20),
          ]),
        ),
      ),
      if (erro)
        Padding(
            padding: const EdgeInsets.only(top: 5, left: 4),
            child: Text('Campo obrigatório',
                style: const TextStyle(color: _vermelho, fontSize: 11))),
      if (ok)
        Padding(
            padding: const EdgeInsets.only(top: 6),
            child: _clearBtn(
                () => setState(() => _equipamentoSelecionado = null))),
    ]);
  }

  void _openEquipSheet() {
    if (_tiposEquipamento.isEmpty) {
      _snack('Nenhum equipamento em EQUIPAMENTOSCADASTRO', _amarelo);
      return;
    }
    final ctrl = TextEditingController();
    List<String> lista = List.from(_tiposEquipamento);
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
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          minChildSize: 0.25,
          shouldCloseOnMinExtent: true,
          expand: false,
          builder: (_, sc) => Column(children: [
            _sheetHandle(),
            _sheetHeader(Icons.settings, 'Selecionar Equipamento',
                badge: '${lista.length} itens'),
            _sheetSearch(
                ctrl,
                'Filtrar equipamentos...',
                (v) => sm(() {
                      lista = _tiposEquipamento
                          .where(
                              (e) => e.toLowerCase().contains(v.toLowerCase()))
                          .toList();
                    })),
            const SizedBox(height: 8),
            Expanded(
                child: lista.isEmpty
                    ? _emptySearch()
                    : ListView.builder(
                        controller: sc,
                        itemCount: lista.length,
                        itemBuilder: (c, i) {
                          final equip = lista[i];
                          final sel = equip == _equipamentoSelecionado;
                          return _sheetItem(equip, sel, Icons.settings_outlined,
                              () {
                            setState(() => _equipamentoSelecionado = equip);
                            Navigator.pop(ctx);
                          });
                        })),
            const SizedBox(height: 8),
          ]),
        ),
      ),
    );
  }

  Widget _buildTensao() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _labelRow(Icons.bolt_outlined, 'Tensão'),
      const SizedBox(height: 8),
      TextFormField(
        controller: _tensaoCtrl,
        focusNode: _tensaoFocus,
        keyboardType: TextInputType.number,
        style: TextStyle(color: _texto, fontSize: 13),
        onChanged: (v) {
          if (v.toUpperCase().endsWith('V') && v.length > 1) {
            final semV = v.substring(0, v.length - 1);
            _tensaoCtrl.value = TextEditingValue(
                text: semV,
                selection: TextSelection.collapsed(offset: semV.length));
          }
        },
        onEditingComplete: () {
          final v = _tensaoCtrl.text.trim();
          if (v.isNotEmpty && !v.toUpperCase().endsWith('V')) {
            _tensaoCtrl.text = v + 'V';
            _tensaoCtrl.selection =
                TextSelection.collapsed(offset: _tensaoCtrl.text.length);
          }
          FocusScope.of(context).nextFocus();
        },
        decoration: InputDecoration(
          hintText: 'Ex: 220',
          hintStyle: TextStyle(color: _sub, fontSize: 13),
          prefixIcon: Icon(Icons.bolt_outlined, color: _sub, size: 18),
          suffixIcon: Padding(
              padding: const EdgeInsets.only(right: 14),
              child: Text('V',
                  style: TextStyle(
                      color: _tensaoFocused ? _azul : _sub,
                      fontSize: 15,
                      fontWeight: FontWeight.bold))),
          suffixIconConstraints:
              const BoxConstraints(minWidth: 0, minHeight: 0),
          filled: true,
          fillColor: _fill,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _borda)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _borda)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _azul, width: 1.5)),
        ),
      ),
    ]);
  }

  Widget _buildSeletorTipo() {
    final ok = _tipoSelecionado != null;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _labelRow(Icons.category_outlined, 'Tipo'),
      const SizedBox(height: 8),
      GestureDetector(
        onTap: _openTipoSheet,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: _fill,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: ok ? _azul.withAlpha(150) : _borda, width: ok ? 1.5 : 1),
          ),
          child: Row(children: [
            Icon(ok ? Icons.check_circle_outline : Icons.touch_app_outlined,
                color: ok ? _azul : _sub, size: 18),
            const SizedBox(width: 10),
            Expanded(
                child: Text(_tipoSelecionado ?? 'Selecionar tipo...',
                    style: TextStyle(color: ok ? _texto : _sub, fontSize: 13),
                    overflow: TextOverflow.ellipsis)),
            Icon(Icons.expand_more, color: _sub, size: 20),
          ]),
        ),
      ),
      if (ok)
        Padding(
            padding: const EdgeInsets.only(top: 6),
            child: _clearBtn(() => setState(() => _tipoSelecionado = null))),
    ]);
  }

  void _openTipoSheet() {
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
          _sheetHandle(),
          _sheetHeader(Icons.category_outlined, 'Tipo do Equipamento'),
          ..._opcoesTipo.map((op) {
            final sel = op == _tipoSelecionado;
            return _sheetItem(op, sel, Icons.category_outlined, () {
              setState(() => _tipoSelecionado = op);
              Navigator.pop(ctx);
            });
          }),
        ]),
      ),
    );
  }

  Widget _buildDropEmail() {
    if (_carregandoEmails) {
      return const SizedBox(
          height: 50,
          child: Center(
              child: CircularProgressIndicator(color: _azul, strokeWidth: 2)));
    }
    final ok = _emailSelecionado != null;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _labelRow(Icons.email_outlined, 'E-mail do Cliente'),
      const SizedBox(height: 8),
      GestureDetector(
        onTap: _openEmailSheet,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: _fill,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: ok ? _azul.withAlpha(150) : _borda),
          ),
          child: Row(children: [
            Expanded(
                child: Text(_emailSelecionado ?? 'Selecionar e-mail...',
                    style: TextStyle(color: ok ? _texto : _sub, fontSize: 13),
                    overflow: TextOverflow.ellipsis)),
            Icon(Icons.expand_more, color: _sub, size: 20),
          ]),
        ),
      ),
      if (ok)
        Padding(
            padding: const EdgeInsets.only(top: 6),
            child: _clearBtn(() => setState(() => _emailSelecionado = null))),
    ]);
  }

  void _openEmailSheet() {
    final ctrl = TextEditingController();
    List<String> lista = List.from(_emails);
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
          initialChildSize: 0.65,
          maxChildSize: 0.9,
          minChildSize: 0.25,
          shouldCloseOnMinExtent: true,
          expand: false,
          builder: (_, sc) => Column(children: [
            _sheetHandle(),
            _sheetHeader(Icons.email_outlined, 'Selecionar E-mail'),
            _sheetSearch(
                ctrl,
                'Filtrar e-mails...',
                (v) => sm(() {
                      lista = _emails
                          .where(
                              (e) => e.toLowerCase().contains(v.toLowerCase()))
                          .toList();
                    })),
            const SizedBox(height: 8),
            Expanded(
                child: lista.isEmpty
                    ? Center(
                        child: Text('Nenhum e-mail',
                            style: TextStyle(color: _sub)))
                    : ListView.builder(
                        controller: sc,
                        itemCount: lista.length,
                        itemBuilder: (c, i) {
                          final email = lista[i];
                          final sel = email == _emailSelecionado;
                          return _sheetItem(email, sel, Icons.email_outlined,
                              () {
                            setState(() => _emailSelecionado = email);
                            Navigator.pop(ctx);
                          });
                        })),
          ]),
        ),
      ),
    );
  }

  Widget _buildCardContrato() {
    return _card_(
        child: Row(children: [
      Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (_contrato ? _verde : _sub).withAlpha(25),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(Icons.article_outlined,
            color: _contrato ? _verde : _sub, size: 22),
      ),
      const SizedBox(width: 14),
      Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('É contrato',
            style: TextStyle(
                color: _texto, fontSize: 14, fontWeight: FontWeight.w600)),
        Text('Marque essa opção', style: TextStyle(color: _sub, fontSize: 12)),
      ])),
      GestureDetector(
        onTap: () => setState(() => _contrato = !_contrato),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 50,
          height: 28,
          decoration: BoxDecoration(
            color: _contrato ? _verde : _borda,
            borderRadius: BorderRadius.circular(14),
          ),
          child: AnimatedAlign(
            duration: const Duration(milliseconds: 200),
            alignment: _contrato ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              margin: const EdgeInsets.all(3),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(11),
                boxShadow: [
                  BoxShadow(color: Colors.black.withAlpha(50), blurRadius: 4)
                ],
              ),
              child: _contrato
                  ? const Icon(Icons.check, color: _verde, size: 14)
                  : null,
            ),
          ),
        ),
      ),
    ]));
  }

  Widget _buildBtnSalvar() {
    return GestureDetector(
      onTap: _salvando ? null : _salvar,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _salvando
                ? [_borda, _borda]
                : _modoEdicao
                    ? [_amarelo, const Color(0xFFB45309)]
                    : [_verde, const Color(0xFF047857)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: _salvando
              ? []
              : [
                  BoxShadow(
                      color: (_modoEdicao ? _amarelo : _verde).withAlpha(80),
                      blurRadius: 12,
                      offset: const Offset(0, 4))
                ],
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(_modoEdicao ? Icons.save : Icons.check_circle_outline,
              color: Colors.white, size: 20),
          const SizedBox(width: 10),
          Text(_modoEdicao ? 'Salvar Alterações' : 'Cadastrar Equipamento',
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
      onTap: _salvando ? null : _excluir,
      child: Container(
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(color: _vermelho.withAlpha(150)),
          borderRadius: BorderRadius.circular(14),
        ),
        child:
            const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.delete_outline, color: _vermelho, size: 20),
          SizedBox(width: 10),
          Text('Excluir Equipamento',
              style: TextStyle(
                  color: _vermelho, fontSize: 15, fontWeight: FontWeight.bold)),
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
          boxShadow: [
            BoxShadow(
                color: Colors.black.withAlpha(_escuro ? 40 : 8),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ],
        ),
        child: child,
      );

  Widget _iconBox(IconData icon, Color cor) => Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [cor, cor.withAlpha(180)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      );

  Widget _backBtn(VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: _escuro ? const Color(0x1AFFFFFF) : const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _borda),
          ),
          child: Icon(Icons.arrow_back_ios_new, color: _texto, size: 15),
        ),
      );

  Widget _labelRow(IconData icon, String label, {bool erro = false}) =>
      Row(children: [
        Icon(icon, color: erro ? _vermelho : _sub, size: 16),
        const SizedBox(width: 8),
        Text(label,
            style: TextStyle(
                color: erro ? _vermelho : _sub,
                fontSize: 12,
                fontWeight: FontWeight.w500)),
      ]);

  Widget _clearBtn(VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.close, color: _sub, size: 12),
          const SizedBox(width: 4),
          Text('Limpar seleção', style: TextStyle(color: _sub, fontSize: 11)),
        ]),
      );

  Widget _minibtn(
          String label, IconData icon, Color cor, VoidCallback? onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: cor.withAlpha(25),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: cor.withAlpha(100)),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, color: cor, size: 14),
            const SizedBox(width: 4),
            Text(label,
                style: TextStyle(
                    color: cor, fontSize: 11, fontWeight: FontWeight.w600)),
          ]),
        ),
      );

  Widget _sheetHandle() => Container(
        margin: const EdgeInsets.only(top: 10, bottom: 8),
        width: 40,
        height: 4,
        decoration: BoxDecoration(
            color: _borda, borderRadius: BorderRadius.circular(2)),
      );

  Widget _sheetHeader(IconData icon, String title, {String? badge}) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
        child: Row(children: [
          Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                  color: _azul.withAlpha(30),
                  borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, color: _azul, size: 18)),
          const SizedBox(width: 10),
          Expanded(
              child: Text(title,
                  style: TextStyle(
                      color: _texto,
                      fontSize: 15,
                      fontWeight: FontWeight.bold))),
          if (badge != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                  color: _azul.withAlpha(25),
                  borderRadius: BorderRadius.circular(8)),
              child: Text(badge,
                  style: const TextStyle(color: _azul, fontSize: 11)),
            ),
        ]),
      );

  Widget _sheetSearch(TextEditingController ctrl, String hint,
          void Function(String) onChanged) =>
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          height: 42,
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
                hintText: hint,
                hintStyle: TextStyle(color: _sub, fontSize: 13),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: onChanged,
            )),
          ]),
        ),
      );

  Widget _sheetItem(
          String label, bool sel, IconData icon, VoidCallback onTap) =>
      Material(
        color: sel ? _azul.withAlpha(20) : Colors.transparent,
        child: ListTile(
          dense: true,
          leading: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: sel ? _azul.withAlpha(40) : _borda.withAlpha(80),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(sel ? Icons.check : icon,
                color: sel ? _azul : _sub, size: 16),
          ),
          title: Text(label,
              style: TextStyle(
                  color: sel ? _azul : _texto,
                  fontSize: 13,
                  fontWeight: sel ? FontWeight.bold : FontWeight.normal)),
          trailing: sel
              ? const Icon(Icons.check_circle, color: _azul, size: 18)
              : null,
          onTap: onTap,
        ),
      );

  Widget _emptySearch() => Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.search_off, color: _sub, size: 40),
        const SizedBox(height: 8),
        Text('Nenhum resultado', style: TextStyle(color: _sub)),
      ]));

  Widget _input({
    required TextEditingController ctrl,
    required String label,
    required IconData icon,
    TextInputType tipo = TextInputType.text,
    bool readOnly = false,
    bool upper = false,
    bool erro = false,
    String? Function(String?)? validator,
    void Function(String)? onSubmit,
  }) {
    final cBorda = erro ? _vermelho : _borda;
    final cFocus = erro ? _vermelho : _azul;
    return TextFormField(
      controller: ctrl,
      keyboardType: tipo,
      readOnly: readOnly,
      textCapitalization:
          upper ? TextCapitalization.characters : TextCapitalization.sentences,
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
      onFieldSubmitted: onSubmit,
      validator: validator,
      style: TextStyle(color: _texto, fontSize: 13),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: erro ? _vermelho : _sub, fontSize: 12),
        prefixIcon: Icon(icon, color: erro ? _vermelho : _sub, size: 18),
        filled: true,
        fillColor: readOnly
            ? _borda.withAlpha(60)
            : erro
                ? _vermelho.withAlpha(15)
                : _fill,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: cBorda)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: cBorda, width: erro ? 1.5 : 1)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: cFocus, width: 1.5)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _vermelho)),
        focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _vermelho, width: 1.5)),
      ),
    );
  }
}
