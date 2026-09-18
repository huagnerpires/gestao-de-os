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

import '/custom_code/actions/index.dart';
import '/flutter_flow/custom_functions.dart';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

// ============================================================
// CACHE ESTÁTICO
// ============================================================
Uint8List? _cachedLogo;
Uint8List? _cachedAssinatura;
pw.Font? _cachedFontRegular;
pw.Font? _cachedFontBold;

const _urlLogo = 'https://i.ibb.co/VpqNsxXt/Imagem1.jpg';
const _urlAssinatura =
    'https://i.ibb.co/hRvtGhbK/3b004d07-a4a9-4568-9d8b-5abc281dbcee.png';
const _kTimeout = Duration(seconds: 5);

Future<Uint8List?> _fetchBytes(String url) async {
  try {
    final resp = await http.get(Uri.parse(url),
        headers: {'User-Agent': 'Mozilla/5.0'}).timeout(_kTimeout);
    return resp.statusCode == 200 ? resp.bodyBytes : null;
  } catch (_) {
    return null;
  }
}

/// ============================================================ WIDGET
/// PRINCIPAL ============================================================
class SincronizarPDFsWidget extends StatefulWidget {
  const SincronizarPDFsWidget({
    super.key,
    this.width,
    this.height,
  });

  final double? width;
  final double? height;

  @override
  State<SincronizarPDFsWidget> createState() => _SincronizarPDFsWidgetState();
}

class _SincronizarPDFsWidgetState extends State<SincronizarPDFsWidget>
    with TickerProviderStateMixin {
  // ── Estado da UI ──────────────────────────────────────────
  String? _emailSelecionado;
  String? _nomeClienteSelecionado;
  String? _fotoClienteUrl;
  final Set<int> _mesesSelecionados = {};
  int _anoSelecionado = DateTime.now().year;

  bool _carregandoUsuarios = false;
  List<Map<String, dynamic>> _listaUsuarios = [];

  bool _processando = false;
  double _progresso = 0.0;
  String _statusMsg = '';
  String _logMsg = '';
  int _totalPDFs = 0;
  int _pdfsGerados = 0;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  // ── Constantes ────────────────────────────────────────────
  static const _meses = [
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

  // ── Cores por tema ────────────────────────────────────────
  Color _primary(bool dark) =>
      dark ? const Color(0xFF00BFA5) : const Color(0xFF00897B);
  Color _primaryLight(bool dark) =>
      dark ? const Color(0xFF1DE9B6) : const Color(0xFF26A69A);
  Color _surface(bool dark) =>
      dark ? const Color(0xFF1E2736) : const Color(0xFFFFFFFF);
  Color _surfaceVariant(bool dark) =>
      dark ? const Color(0xFF263040) : const Color(0xFFF5F7FA);
  Color _cardBg(bool dark) =>
      dark ? const Color(0xFF243044) : const Color(0xFFFFFFFF);
  Color _border(bool dark) =>
      dark ? const Color(0xFF2E3F55) : const Color(0xFFE0E7EF);
  Color _textPrimary(bool dark) =>
      dark ? const Color(0xFFECF0F6) : const Color(0xFF1A2332);
  Color _textSecondary(bool dark) =>
      dark ? const Color(0xFF8FA8C2) : const Color(0xFF607080);
  Color _chipBg(bool dark) =>
      dark ? const Color(0xFF1A2A3A) : const Color(0xFFE8F5F3);
  Color _chipSelected(bool dark) =>
      dark ? const Color(0xFF00897B) : const Color(0xFF00897B);
  Color _errorColor(bool dark) =>
      dark ? const Color(0xFFFF5252) : const Color(0xFFD32F2F);
  Color _successColor(bool dark) =>
      dark ? const Color(0xFF00E676) : const Color(0xFF2E7D32);

  // ── Lifecycle ─────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.85, end: 1.0).animate(_pulseController);
    _carregarUsuarios();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  // ── Carregar usuários ─────────────────────────────────────
  Future<void> _carregarUsuarios() async {
    setState(() => _carregandoUsuarios = true);
    try {
      final snap =
          await FirebaseFirestore.instance.collection('USUARIOS').get();
      final lista = <Map<String, dynamic>>[];
      for (final doc in snap.docs) {
        final d = doc.data();
        final email = d['email']?.toString().trim() ?? '';
        if (email.isNotEmpty) {
          lista.add({
            'email': email,
            'nome': (d['display_name'] ?? d['nome'] ?? email).toString(),
            'foto': d['photo_url']?.toString().trim() ?? '',
          });
        }
      }
      lista
          .sort((a, b) => a['nome'].toString().compareTo(b['nome'].toString()));
      if (mounted) setState(() => _listaUsuarios = lista);
    } catch (e) {
      _appendLog('Erro ao carregar usuários: $e');
    } finally {
      if (mounted) setState(() => _carregandoUsuarios = false);
    }
  }

  // ── Selecionar cliente via bottom sheet ───────────────────
  void _abrirSeletorCliente(bool dark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      useSafeArea: true,
      builder: (_) => _ClienteSelectorSheet(
        listaUsuarios: _listaUsuarios,
        emailAtual: _emailSelecionado,
        dark: dark,
        surface: _surface(dark),
        surfaceVariant: _surfaceVariant(dark),
        primary: _primary(dark),
        textPrimary: _textPrimary(dark),
        textSecondary: _textSecondary(dark),
        border: _border(dark),
        onSelect: (email, nome, foto) {
          setState(() {
            _emailSelecionado = email;
            _nomeClienteSelecionado = nome;
            _fotoClienteUrl = foto.isNotEmpty ? foto : null;
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  // ── Selecionar ano via bottom sheet ───────────────────────
  void _abrirSeletorAno(bool dark) {
    final anos = List.generate(5, (i) => DateTime.now().year - 2 + i);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      useSafeArea: true,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: _surface(dark),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Expanded(
                child: Text('Selecionar Ano',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _textPrimary(dark))),
              ),
            ]),
            const SizedBox(height: 16),
            ...anos.map((ano) => _AnoTile(
                  ano: ano,
                  selecionado: ano == _anoSelecionado,
                  primary: _primary(dark),
                  textPrimary: _textPrimary(dark),
                  surfaceVariant: _surfaceVariant(dark),
                  onTap: () {
                    setState(() => _anoSelecionado = ano);
                    Navigator.pop(context);
                  },
                )),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // ── Toggle mês ────────────────────────────────────────────
  void _toggleMes(int idx) {
    setState(() {
      if (_mesesSelecionados.contains(idx)) {
        _mesesSelecionados.remove(idx);
      } else {
        _mesesSelecionados.add(idx);
      }
    });
  }

  void _toggleTodosMeses() {
    setState(() {
      if (_mesesSelecionados.length == 12) {
        _mesesSelecionados.clear();
      } else {
        _mesesSelecionados.addAll(List.generate(12, (i) => i));
      }
    });
  }

  // ── Log helpers ───────────────────────────────────────────
  void _appendLog(String msg) {
    if (!mounted) return;
    setState(() => _logMsg = '$msg\n$_logMsg');
  }

  void _setStatus(String msg) {
    if (!mounted) return;
    setState(() => _statusMsg = msg);
  }

  // ── GERAR PDFs ────────────────────────────────────────────
  Future<void> _gerarPDFs() async {
    if (_emailSelecionado == null) return;
    if (_mesesSelecionados.isEmpty) return;

    setState(() {
      _processando = true;
      _progresso = 0.0;
      _statusMsg = 'Iniciando…';
      _logMsg = '';
      _totalPDFs = 0;
      _pdfsGerados = 0;
    });

    final mesSelecionadoList = _mesesSelecionados.toList()..sort();

    try {
      int totalFaltantes = 0;
      // Fase 1: contar faltantes em todos os meses
      for (final mesIdx in mesSelecionadoList) {
        final mesStorage = _meses[mesIdx];
        final mesFirestore = mesStorage.toUpperCase();
        final pastaEmail = _emailSelecionado!.trim();
        final storagePath = '$pastaEmail/$_anoSelecionado/$mesStorage';

        Set<String> pdfsNoStorage = {};
        try {
          final listResult = await firebase_storage.FirebaseStorage.instance
              .ref(storagePath)
              .listAll();
          for (var item in listResult.items) {
            if (item.name.toLowerCase().endsWith('.pdf')) {
              pdfsNoStorage.add(item.name
                  .replaceAll(RegExp(r'\.pdf$', caseSensitive: false), '')
                  .trim());
            }
          }
        } catch (_) {}

        Set<String> patrimoniosFirestore = {};
        final prevQuery = await FirebaseFirestore.instance
            .collection('PREVENTIVAS')
            .where('MES', isEqualTo: mesFirestore)
            .where('ANO', isEqualTo: _anoSelecionado.toString())
            .get();
        for (final doc in prevQuery.docs) {
          final pat = doc.data()['PATRIMONIO']?.toString().trim();
          if (pat != null && pat.isNotEmpty) patrimoniosFirestore.add(pat);
        }

        totalFaltantes += patrimoniosFirestore.difference(pdfsNoStorage).length;
      }

      setState(() => _totalPDFs = totalFaltantes);

      if (totalFaltantes == 0) {
        _setStatus('✅ Tudo já sincronizado!');
        setState(() => _progresso = 1.0);
        await Future.delayed(const Duration(milliseconds: 800));
        setState(() => _processando = false);
        return;
      }

      // Fase 2: gerar PDFs
      int gerado = 0;
      for (final mesIdx in mesSelecionadoList) {
        final mesStorage = _meses[mesIdx];
        final mesFirestore = mesStorage.toUpperCase();
        final pastaEmail = _emailSelecionado!.trim();
        final storagePath = '$pastaEmail/$_anoSelecionado/$mesStorage';

        _setStatus('🔍 Verificando $mesStorage/$_anoSelecionado…');

        Set<String> pdfsNoStorage = {};
        try {
          final listResult = await firebase_storage.FirebaseStorage.instance
              .ref(storagePath)
              .listAll();
          for (var item in listResult.items) {
            if (item.name.toLowerCase().endsWith('.pdf')) {
              pdfsNoStorage.add(item.name
                  .replaceAll(RegExp(r'\.pdf$', caseSensitive: false), '')
                  .trim());
            }
          }
        } catch (_) {}

        Set<String> patrimoniosFirestore = {};
        final prevQuery = await FirebaseFirestore.instance
            .collection('PREVENTIVAS')
            .where('MES', isEqualTo: mesFirestore)
            .where('ANO', isEqualTo: _anoSelecionado.toString())
            .get();
        for (final doc in prevQuery.docs) {
          final pat = doc.data()['PATRIMONIO']?.toString().trim();
          if (pat != null && pat.isNotEmpty) patrimoniosFirestore.add(pat);
        }

        final faltantes = patrimoniosFirestore.difference(pdfsNoStorage);
        if (faltantes.isEmpty) {
          _appendLog('[$mesStorage] Nenhum PDF faltando.');
          continue;
        }

        _appendLog('[$mesStorage] ${faltantes.length} PDFs para gerar…');

        for (final pat in faltantes) {
          _setStatus('📄 Gerando: $pat ($mesStorage)');
          try {
            await _geraPDFPreventivaLogica(
                pat, _emailSelecionado, mesFirestore, _anoSelecionado);
            gerado++;
            _appendLog('✅ $pat — $mesStorage/$_anoSelecionado');
          } catch (e) {
            _appendLog('❌ Erro $pat: $e');
          }
          setState(() {
            _pdfsGerados = gerado;
            _progresso = totalFaltantes > 0 ? gerado / totalFaltantes : 1.0;
          });
        }
      }

      _setStatus('🎉 Concluído! $gerado PDFs gerados.');
    } catch (e) {
      _setStatus('❌ Erro: $e');
      _appendLog('Erro geral: $e');
    } finally {
      if (mounted) setState(() => _processando = false);
    }
  }

  // ============================================================
  // BUILD
  // ============================================================
  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final canGenerate =
        _emailSelecionado != null && _mesesSelecionados.isNotEmpty;

    return Material(
      color: Colors.transparent,
      child: SizedBox(
        width: widget.width ?? double.infinity,
        height: widget.height,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Cabeçalho ──
              _buildHeader(dark),
              const SizedBox(height: 20),

              // ── Card cliente ──
              _buildClienteCard(dark),
              const SizedBox(height: 16),

              // ── Card ano ──
              _buildAnoCard(dark),
              const SizedBox(height: 16),

              // ── Card meses ──
              _buildMesesCard(dark),
              const SizedBox(height: 24),

              // ── Botão principal ──
              _buildBotaoGerar(dark, canGenerate),

              // ── Progresso & log ──
              if (_processando || _statusMsg.isNotEmpty) ...[
                const SizedBox(height: 20),
                _buildProgressCard(dark),
              ],
              if (_logMsg.isNotEmpty) ...[
                const SizedBox(height: 12),
                _buildLogCard(dark),
              ],
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ── Cabeçalho ─────────────────────────────────────────────
  Widget _buildHeader(bool dark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_primary(dark), _primaryLight(dark)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: dark ? const Color(0x4400BFA5) : const Color(0x3300897B),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0x33FFFFFF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.picture_as_pdf_rounded,
                color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Sincronizar PDFs',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                SizedBox(height: 2),
                Text('Gerar relatórios preventivos faltantes',
                    style: TextStyle(fontSize: 12, color: Color(0xCCFFFFFF))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Card cliente ──────────────────────────────────────────
  Widget _buildClienteCard(bool dark) {
    return _SectionCard(
      dark: dark,
      cardBg: _cardBg(dark),
      border: _border(dark),
      title: 'Cliente',
      icon: Icons.business_rounded,
      primary: _primary(dark),
      textPrimary: _textPrimary(dark),
      textSecondary: _textSecondary(dark),
      child: _carregandoUsuarios
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: CircularProgressIndicator(
                    color: _primary(dark), strokeWidth: 2),
              ),
            )
          : GestureDetector(
              onTap: () => _abrirSeletorCliente(dark),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _surfaceVariant(dark),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: _emailSelecionado != null
                          ? _primary(dark)
                          : _border(dark),
                      width: _emailSelecionado != null ? 1.5 : 1.0),
                ),
                child: Row(
                  children: [
                    // Avatar
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _primary(dark).withAlpha(30),
                        border: Border.all(
                            color: _primary(dark).withAlpha(80), width: 1.5),
                        image: (_fotoClienteUrl != null &&
                                _fotoClienteUrl!.isNotEmpty)
                            ? DecorationImage(
                                image: NetworkImage(_fotoClienteUrl!),
                                fit: BoxFit.cover)
                            : null,
                      ),
                      child:
                          (_fotoClienteUrl == null || _fotoClienteUrl!.isEmpty)
                              ? Icon(Icons.person_rounded,
                                  color: _primary(dark), size: 22)
                              : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _emailSelecionado == null
                          ? Text('Selecionar cliente…',
                              style: TextStyle(
                                  color: _textSecondary(dark), fontSize: 14))
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _nomeClienteSelecionado ?? '',
                                  style: TextStyle(
                                      color: _textPrimary(dark),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  _emailSelecionado!,
                                  style: TextStyle(
                                      color: _textSecondary(dark),
                                      fontSize: 11),
                                ),
                              ],
                            ),
                    ),
                    Icon(Icons.keyboard_arrow_down_rounded,
                        color: _textSecondary(dark), size: 22),
                  ],
                ),
              ),
            ),
    );
  }

  // ── Card ano ──────────────────────────────────────────────
  Widget _buildAnoCard(bool dark) {
    return _SectionCard(
      dark: dark,
      cardBg: _cardBg(dark),
      border: _border(dark),
      title: 'Ano',
      icon: Icons.calendar_today_rounded,
      primary: _primary(dark),
      textPrimary: _textPrimary(dark),
      textSecondary: _textSecondary(dark),
      child: GestureDetector(
        onTap: () => _abrirSeletorAno(dark),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: _surfaceVariant(dark),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _primary(dark), width: 1.5),
          ),
          child: Row(
            children: [
              Icon(Icons.event_rounded, color: _primary(dark), size: 20),
              const SizedBox(width: 10),
              Text(
                _anoSelecionado.toString(),
                style: TextStyle(
                    color: _textPrimary(dark),
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Icon(Icons.keyboard_arrow_down_rounded,
                  color: _textSecondary(dark), size: 22),
            ],
          ),
        ),
      ),
    );
  }

  // ── Card meses ────────────────────────────────────────────
  Widget _buildMesesCard(bool dark) {
    final todosSelected = _mesesSelecionados.length == 12;
    return _SectionCard(
      dark: dark,
      cardBg: _cardBg(dark),
      border: _border(dark),
      title: 'Meses',
      icon: Icons.date_range_rounded,
      primary: _primary(dark),
      textPrimary: _textPrimary(dark),
      textSecondary: _textSecondary(dark),
      trailing: GestureDetector(
        onTap: _toggleTodosMeses,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: todosSelected ? _primary(dark) : _surfaceVariant(dark),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _primary(dark), width: 1),
          ),
          child: Text(
            todosSelected ? 'Desmarcar Todos' : 'Todos',
            style: TextStyle(
                fontSize: 11,
                color: todosSelected ? Colors.white : _primary(dark),
                fontWeight: FontWeight.w600),
          ),
        ),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: List.generate(12, (i) {
          final selected = _mesesSelecionados.contains(i);
          return GestureDetector(
            onTap: () => _toggleMes(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: selected ? _chipSelected(dark) : _chipBg(dark),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: selected ? _chipSelected(dark) : _border(dark),
                    width: 1),
                boxShadow: selected
                    ? [
                        BoxShadow(
                            color: _primary(dark).withAlpha(60),
                            blurRadius: 6,
                            offset: const Offset(0, 2))
                      ]
                    : null,
              ),
              child: Text(
                _meses[i].substring(0, 3),
                style: TextStyle(
                    fontSize: 12,
                    color: selected ? Colors.white : _textSecondary(dark),
                    fontWeight: selected ? FontWeight.bold : FontWeight.normal),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ── Botão Gerar ───────────────────────────────────────────
  Widget _buildBotaoGerar(bool dark, bool canGenerate) {
    return AnimatedOpacity(
      opacity: canGenerate ? 1.0 : 0.5,
      duration: const Duration(milliseconds: 250),
      child: GestureDetector(
        onTap: (!canGenerate || _processando) ? null : _gerarPDFs,
        child: Container(
          width: double.infinity,
          height: 54,
          decoration: BoxDecoration(
            gradient: canGenerate
                ? LinearGradient(
                    colors: [_primary(dark), _primaryLight(dark)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  )
                : null,
            color: canGenerate ? null : _border(dark),
            borderRadius: BorderRadius.circular(14),
            boxShadow: canGenerate
                ? [
                    BoxShadow(
                        color: _primary(dark).withAlpha(90),
                        blurRadius: 12,
                        offset: const Offset(0, 4))
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_processando)
                const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
              else
                const Icon(Icons.sync_rounded, color: Colors.white, size: 22),
              const SizedBox(width: 10),
              Text(
                _processando ? 'Gerando PDFs…' : 'Gerar PDFs Faltantes',
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Card de progresso ─────────────────────────────────────
  Widget _buildProgressCard(bool dark) {
    final isDone = !_processando && _statusMsg.isNotEmpty;
    final isSuccess = isDone && _statusMsg.startsWith('🎉');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardBg(dark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: isSuccess ? _successColor(dark) : _border(dark), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (_processando)
                ScaleTransition(
                  scale: _pulseAnim,
                  child: Icon(Icons.autorenew_rounded,
                      color: _primary(dark), size: 18),
                )
              else
                Icon(
                    isSuccess ? Icons.check_circle_rounded : Icons.info_rounded,
                    color: isSuccess ? _successColor(dark) : _primary(dark),
                    size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _statusMsg,
                  style: TextStyle(
                      fontSize: 13,
                      color: _textPrimary(dark),
                      fontWeight: FontWeight.w500),
                ),
              ),
              if (_totalPDFs > 0)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: _primary(dark).withAlpha(25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$_pdfsGerados / $_totalPDFs',
                    style: TextStyle(
                        fontSize: 12,
                        color: _primary(dark),
                        fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
          if (_totalPDFs > 0) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: _progresso,
                minHeight: 6,
                backgroundColor: _border(dark),
                valueColor: AlwaysStoppedAnimation<Color>(_primary(dark)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Card de log ───────────────────────────────────────────
  Widget _buildLogCard(bool dark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF131C28) : const Color(0xFFF0F4F8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border(dark)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.terminal_rounded,
                  color: _textSecondary(dark), size: 14),
              const SizedBox(width: 6),
              Text('Log',
                  style: TextStyle(
                      fontSize: 11,
                      color: _textSecondary(dark),
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5)),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 120,
            child: SingleChildScrollView(
              reverse: false,
              child: Text(
                _logMsg,
                style: TextStyle(
                    fontSize: 11,
                    color: _textSecondary(dark),
                    fontFamily: 'monospace',
                    height: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// WIDGET AUXILIAR: SectionCard
// ============================================================
class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.dark,
    required this.cardBg,
    required this.border,
    required this.title,
    required this.icon,
    required this.primary,
    required this.textPrimary,
    required this.textSecondary,
    required this.child,
    this.trailing,
  });

  final bool dark;
  final Color cardBg;
  final Color border;
  final String title;
  final IconData icon;
  final Color primary;
  final Color textPrimary;
  final Color textSecondary;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border, width: 1),
        boxShadow: [
          BoxShadow(
              color: dark ? const Color(0x1A000000) : const Color(0x0F000000),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: primary.withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: primary, size: 16),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(title,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: textPrimary)),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

// ============================================================
// WIDGET AUXILIAR: Bottom Sheet Seletor de Cliente
// ============================================================
class _ClienteSelectorSheet extends StatefulWidget {
  const _ClienteSelectorSheet({
    required this.listaUsuarios,
    required this.emailAtual,
    required this.dark,
    required this.surface,
    required this.surfaceVariant,
    required this.primary,
    required this.textPrimary,
    required this.textSecondary,
    required this.border,
    required this.onSelect,
  });

  final List<Map<String, dynamic>> listaUsuarios;
  final String? emailAtual;
  final bool dark;
  final Color surface;
  final Color surfaceVariant;
  final Color primary;
  final Color textPrimary;
  final Color textSecondary;
  final Color border;
  final Function(String email, String nome, String foto) onSelect;

  @override
  State<_ClienteSelectorSheet> createState() => _ClienteSelectorSheetState();
}

class _ClienteSelectorSheetState extends State<_ClienteSelectorSheet> {
  String _busca = '';

  @override
  Widget build(BuildContext context) {
    final filtrados = widget.listaUsuarios
        .where((u) =>
            u['nome'].toString().toLowerCase().contains(_busca.toLowerCase()) ||
            u['email'].toString().toLowerCase().contains(_busca.toLowerCase()))
        .toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: widget.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 10, bottom: 8),
            width: 36,
            height: 4,
            decoration: BoxDecoration(
                color: widget.border, borderRadius: BorderRadius.circular(4)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text('Selecionar Cliente',
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: widget.textPrimary)),
                ),
              ],
            ),
          ),
          // Campo de busca
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              onChanged: (v) => setState(() => _busca = v),
              style: TextStyle(color: widget.textPrimary, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Buscar por nome ou e-mail…',
                hintStyle: TextStyle(color: widget.textSecondary, fontSize: 14),
                prefixIcon:
                    Icon(Icons.search_rounded, color: widget.textSecondary),
                filled: true,
                fillColor: widget.surfaceVariant,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
              ),
            ),
          ),
          Divider(height: 1, color: widget.border),
          // Lista
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: filtrados.length,
              itemBuilder: (_, i) {
                final u = filtrados[i];
                final selected = u['email'] == widget.emailAtual;
                final foto = u['foto'].toString();
                return ListTile(
                  onTap: () => widget.onSelect(u['email'], u['nome'], foto),
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.primary.withAlpha(30),
                      image: foto.startsWith('http')
                          ? DecorationImage(
                              image: NetworkImage(foto), fit: BoxFit.cover)
                          : null,
                    ),
                    child: foto.startsWith('http')
                        ? null
                        : Icon(Icons.person_rounded,
                            color: widget.primary, size: 20),
                  ),
                  title: Text(u['nome'],
                      style: TextStyle(
                          color: widget.textPrimary,
                          fontSize: 14,
                          fontWeight:
                              selected ? FontWeight.bold : FontWeight.normal)),
                  subtitle: Text(u['email'],
                      style:
                          TextStyle(color: widget.textSecondary, fontSize: 11)),
                  trailing: selected
                      ? Icon(Icons.check_circle_rounded,
                          color: widget.primary, size: 20)
                      : null,
                  tileColor: selected
                      ? widget.primary.withAlpha(15)
                      : Colors.transparent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// WIDGET AUXILIAR: Tile de Ano
// ============================================================
class _AnoTile extends StatelessWidget {
  const _AnoTile({
    required this.ano,
    required this.selecionado,
    required this.primary,
    required this.textPrimary,
    required this.surfaceVariant,
    required this.onTap,
  });

  final int ano;
  final bool selecionado;
  final Color primary;
  final Color textPrimary;
  final Color surfaceVariant;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selecionado ? primary.withAlpha(20) : surfaceVariant,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: selecionado ? primary : Colors.transparent, width: 1.5),
        ),
        child: Row(
          children: [
            Text(
              ano.toString(),
              style: TextStyle(
                  fontSize: 15,
                  color: selecionado ? primary : textPrimary,
                  fontWeight:
                      selecionado ? FontWeight.bold : FontWeight.normal),
            ),
            const Spacer(),
            if (selecionado)
              Icon(Icons.check_rounded, color: primary, size: 18),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// LÓGICA DE GERAÇÃO DE PDF (adaptada com mês/ano explícito)
// ============================================================
Future<void> _geraPDFPreventivaLogica(String patrimonio, String? emailCliente,
    String mesFirestore, int ano) async {
  pw.TableRow _buildIdentRow(
      String label1, String value1, String label2, String value2) {
    return pw.TableRow(children: [
      pw.Container(
        padding: pw.EdgeInsets.symmetric(vertical: 2, horizontal: 4),
        child: pw.RichText(
          text: pw.TextSpan(children: [
            pw.TextSpan(
                text: '$label1 ',
                style:
                    pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold)),
            pw.TextSpan(text: value1, style: pw.TextStyle(fontSize: 7)),
          ]),
        ),
      ),
      pw.Container(
        decoration: pw.BoxDecoration(
            border: pw.Border(left: pw.BorderSide(width: 0.5))),
        padding: pw.EdgeInsets.symmetric(vertical: 2, horizontal: 4),
        child: pw.RichText(
          text: pw.TextSpan(children: [
            pw.TextSpan(
                text: '$label2 ',
                style:
                    pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold)),
            pw.TextSpan(text: value2, style: pw.TextStyle(fontSize: 7)),
          ]),
        ),
      ),
    ]);
  }

  pw.TableRow _buildCheckRow(String num, String label, bool checked) {
    return pw.TableRow(children: [
      pw.Container(
        padding: pw.EdgeInsets.all(2),
        decoration: pw.BoxDecoration(
            border: pw.Border(right: pw.BorderSide(width: 0.5))),
        child: pw.Center(child: pw.Text(num, style: pw.TextStyle(fontSize: 6))),
      ),
      pw.Container(
        padding: pw.EdgeInsets.only(left: 4, top: 2, bottom: 2),
        child: pw.Text(label, style: pw.TextStyle(fontSize: 6)),
      ),
      pw.Container(
        padding: pw.EdgeInsets.all(2),
        decoration: pw.BoxDecoration(
            border: pw.Border(left: pw.BorderSide(width: 0.5))),
        child: pw.Center(
            child: pw.Text(checked ? 'OK' : '',
                style:
                    pw.TextStyle(fontSize: 6, fontWeight: pw.FontWeight.bold))),
      ),
    ]);
  }

  pw.TableRow _buildValueRow(String num, String label, String value) {
    return pw.TableRow(children: [
      pw.Container(
        padding: pw.EdgeInsets.all(2),
        decoration: pw.BoxDecoration(
            border: pw.Border(right: pw.BorderSide(width: 0.5))),
        child: pw.Center(child: pw.Text(num, style: pw.TextStyle(fontSize: 6))),
      ),
      pw.Container(
        padding: pw.EdgeInsets.only(left: 4, top: 2, bottom: 2),
        child: pw.Text(label, style: pw.TextStyle(fontSize: 6)),
      ),
      pw.Container(
        padding: pw.EdgeInsets.all(2),
        decoration: pw.BoxDecoration(
            border: pw.Border(left: pw.BorderSide(width: 0.5))),
        child: pw.Center(
            child: pw.Text(value,
                style:
                    pw.TextStyle(fontSize: 6, fontWeight: pw.FontWeight.bold))),
      ),
    ]);
  }

  String _formatarData(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

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
    'Dezembro',
  ];

  try {
    final pastaEmail = (emailCliente != null && emailCliente.isNotEmpty)
        ? emailCliente.trim()
        : 'sem_email';

    // Determinar mesStorage a partir de mesFirestore
    final mesStorageIdx = listaMeses
        .indexWhere((m) => m.toUpperCase() == mesFirestore.toUpperCase());
    final mesStorage =
        mesStorageIdx >= 0 ? listaMeses[mesStorageIdx] : mesFirestore;

    final results = await Future.wait([
      _cachedFontRegular != null
          ? Future.value(_cachedFontRegular!)
          : PdfGoogleFonts.openSansRegular(),
      _cachedFontBold != null
          ? Future.value(_cachedFontBold!)
          : PdfGoogleFonts.openSansBold(),
      FirebaseFirestore.instance
          .collection('PREVENTIVAS')
          .where('PATRIMONIO', isEqualTo: patrimonio)
          .where('MES', isEqualTo: mesFirestore)
          .get(),
      FirebaseFirestore.instance
          .collection('IMAGENS')
          .where('PATRIMONIO', isEqualTo: patrimonio)
          .limit(1)
          .get(),
      (emailCliente != null && emailCliente.isNotEmpty)
          ? FirebaseFirestore.instance
              .collection('USUARIOS')
              .where('email', isEqualTo: emailCliente.trim())
              .limit(1)
              .get()
          : Future.value(null),
      _cachedLogo != null ? Future.value(_cachedLogo!) : _fetchBytes(_urlLogo),
      _cachedAssinatura != null
          ? Future.value(_cachedAssinatura!)
          : _fetchBytes(_urlAssinatura),
    ]);

    _cachedFontRegular = results[0] as pw.Font;
    _cachedFontBold = results[1] as pw.Font;
    final logoBytes = results[5] as Uint8List?;
    final assinaturaBytes = results[6] as Uint8List?;
    if (logoBytes != null) _cachedLogo = logoBytes;
    if (assinaturaBytes != null) _cachedAssinatura = assinaturaBytes;

    final fontRegular = _cachedFontRegular!;
    final fontBold = _cachedFontBold!;
    final prevQuery = results[2] as QuerySnapshot<Map<String, dynamic>>;
    final imgQuery = results[3] as QuerySnapshot<Map<String, dynamic>>;
    final usuariosQuery = results[4] as QuerySnapshot<Map<String, dynamic>>?;

    if (prevQuery.docs.isEmpty) return;

    final listaDocs = prevQuery.docs.toList()
      ..sort((a, b) {
        final dataA = (a.data()['DATADAMANUTENCAO'] as Timestamp?)?.toDate();
        final dataB = (b.data()['DATADAMANUTENCAO'] as Timestamp?)?.toDate();
        if (dataA == null) return 1;
        if (dataB == null) return -1;
        return dataB.compareTo(dataA);
      });

    final data = listaDocs.first.data();

    String nomeClienteRodape = '';
    String cnpjClienteRodape = '';
    String? fotoClienteUrl;

    if (usuariosQuery != null && usuariosQuery.docs.isNotEmpty) {
      final userData = usuariosQuery.docs.first.data();
      nomeClienteRodape =
          (userData['display_name'] ?? '').toString().toUpperCase();
      cnpjClienteRodape =
          (userData['CNPJ'] ?? userData['cnpj'] ?? '').toString();
      final photoUrl = userData['photo_url']?.toString().trim();
      if (photoUrl != null && photoUrl.startsWith('http'))
        fotoClienteUrl = photoUrl;
    }

    String? imgEvaporadoraUrl;
    if (imgQuery.docs.isNotEmpty) {
      final url = imgQuery.docs.first.data()['IMAGEM']?.toString().trim();
      if (url != null && url.startsWith('http')) imgEvaporadoraUrl = url;
    }

    String? urlTermo;
    for (final key in const [
      'IMAGEM',
      'THAGEM',
      'TMAGEM',
      'FOTO',
      'foto',
      'imagem'
    ]) {
      final v = data[key]?.toString().trim();
      if (v != null && v.isNotEmpty) {
        urlTermo = v;
        break;
      }
    }

    final imageResults = await Future.wait([
      fotoClienteUrl != null ? _fetchBytes(fotoClienteUrl) : Future.value(null),
      imgEvaporadoraUrl != null
          ? _fetchBytes(imgEvaporadoraUrl)
          : Future.value(null),
      (urlTermo != null && urlTermo.startsWith('http'))
          ? _fetchBytes(urlTermo)
          : Future.value(null),
    ]);

    final imagemCliente =
        imageResults[0] != null ? pw.MemoryImage(imageResults[0]!) : null;
    final imagemEvaporadora =
        imageResults[1] != null ? pw.MemoryImage(imageResults[1]!) : null;
    final imagemTermografia =
        imageResults[2] != null ? pw.MemoryImage(imageResults[2]!) : null;
    final logoEmpresa = logoBytes != null ? pw.MemoryImage(logoBytes) : null;
    final assinaturaHPS =
        assinaturaBytes != null ? pw.MemoryImage(assinaturaBytes) : null;

    bool checkLimpezaCompressor = false;
    const tentativasChave = [
      'LIMPEZAELUBRIFICAODOCOMPRESSO',
      'LIMPEZAELUBRIFICAODOCOMPRESSOR',
      'LIMPEZAELUBRIFICAODOCOMPRESS',
      'LIMPEZAELUBRIFICAODOMOTOR',
      'LIMPEZAELUBRIFICACAODOCOMPRESSOR',
      'LIMPEZAELUBRIFICACAODOCOMPRESSO',
    ];
    for (final key in tentativasChave) {
      if (data[key] == true) {
        checkLimpezaCompressor = true;
        break;
      }
    }
    if (!checkLimpezaCompressor) {
      for (final key in data.keys) {
        final k = key.toUpperCase().replaceAll(' ', '');
        if (k.contains('LUBRIFICA') &&
            (k.contains('COMPRESS') || k.contains('MOTOR')) &&
            data[key] == true) {
          checkLimpezaCompressor = true;
          break;
        }
      }
    }

    final dataInicio = data['DATADAMANUTENCAO'] != null
        ? _formatarData((data['DATADAMANUTENCAO'] as Timestamp).toDate())
        : '';
    final textoObservacao = (data['OBSERVACAO'] ?? '').toString().trim();

    const listaItensServico = [
      'Higienização: Aplicar produtos bactericidas específicos para eliminar microrganismos.',
      'Filtros de Ar: Remover, lavar com água corrente e sabão neutro, secar completamente.',
      'Medir e informar tensão elétrica',
      'Medir e informar corrente elétrica',
      'Limpar carenagem da evaporadora. Verificar ruídos, vazamentos e mau cheiro.',
    ];

    const tableBorder = pw.TableBorder(
      left: pw.BorderSide(width: 0.5),
      right: pw.BorderSide(width: 0.5),
      top: pw.BorderSide(width: 0.5),
      bottom: pw.BorderSide(width: 0.5),
      horizontalInside: pw.BorderSide(width: 0.5),
      verticalInside: pw.BorderSide(width: 0.5),
    );

    final pdf = pw.Document(
        theme: pw.ThemeData.withFont(base: fontRegular, bold: fontBold));

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(20),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Container(
                height: 50,
                decoration: pw.BoxDecoration(border: pw.Border.all(width: 1)),
                child: pw.Row(children: [
                  pw.Expanded(
                    flex: 3,
                    child: pw.Padding(
                      padding: pw.EdgeInsets.all(4),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        mainAxisAlignment: pw.MainAxisAlignment.center,
                        children: [
                          pw.Text('FORNECEDOR',
                              style: pw.TextStyle(
                                  fontSize: 8, fontWeight: pw.FontWeight.bold)),
                          if (logoEmpresa != null)
                            pw.Container(
                                height: 30,
                                alignment: pw.Alignment.centerLeft,
                                child: pw.Image(logoEmpresa,
                                    fit: pw.BoxFit.contain)),
                        ],
                      ),
                    ),
                  ),
                  pw.Expanded(
                    flex: 2,
                    child: pw.Column(
                      mainAxisAlignment: pw.MainAxisAlignment.center,
                      children: [
                        pw.Text('DATA DA MANUTENÇÃO',
                            style: pw.TextStyle(
                                fontSize: 6, fontWeight: pw.FontWeight.bold)),
                        pw.Text(dataInicio,
                            style: pw.TextStyle(
                                fontSize: 9, fontWeight: pw.FontWeight.bold)),
                      ],
                    ),
                  ),
                  pw.Expanded(
                    flex: 2,
                    child: pw.Container(
                      padding: pw.EdgeInsets.all(4),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text('CLIENTE',
                              style: pw.TextStyle(
                                  fontSize: 8, fontWeight: pw.FontWeight.bold)),
                          if (imagemCliente != null)
                            pw.Container(
                                height: 30,
                                width: 80,
                                alignment: pw.Alignment.bottomRight,
                                child: pw.Image(imagemCliente,
                                    fit: pw.BoxFit.contain))
                          else
                            pw.Text(nomeClienteRodape,
                                style: pw.TextStyle(
                                    fontSize: 7,
                                    fontWeight: pw.FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ]),
              ),
              pw.SizedBox(height: 5),
              pw.Container(
                decoration: pw.BoxDecoration(border: pw.Border.all(width: 0.5)),
                child: pw.Column(children: [
                  pw.Container(
                      width: double.infinity,
                      color: PdfColors.grey200,
                      padding: pw.EdgeInsets.symmetric(vertical: 2),
                      child: pw.Center(
                          child: pw.Text('IDENTIFICAÇÃO',
                              style: pw.TextStyle(
                                  fontSize: 8,
                                  fontWeight: pw.FontWeight.bold)))),
                  pw.Divider(height: 1, thickness: 0.5),
                  pw.Table(
                    border: pw.TableBorder.symmetric(
                        inside: pw.BorderSide(width: 0.5)),
                    columnWidths: {
                      0: pw.FlexColumnWidth(1),
                      1: pw.FlexColumnWidth(1)
                    },
                    children: [
                      _buildIdentRow(
                          'APARELHO:',
                          data['EQUIPAMENTO'] ?? 'AR CONDICIONADO',
                          'VOLTAGEM:',
                          data['TENSAO'] ?? '220V'),
                      _buildIdentRow('MODELO:', data['MODELO'] ?? 'SPLIT',
                          'GÁS:', data['FLUIDO'] ?? 'R410A'),
                      _buildIdentRow('TIPO:', data['TIPO'] ?? 'INVERTER',
                          'POTÊNCIA:', data['BTUS'] ?? '12K BTUS'),
                      _buildIdentRow('FABRICANTE:', data['MARCA'] ?? 'LG',
                          'PRÉDIO:', data['SETOR'] ?? ''),
                      _buildIdentRow('PATRIMÔNIO:', data['PATRIMONIO'] ?? '',
                          'LOCALIZAÇÃO:', data['SALA'] ?? ''),
                      _buildIdentRow(
                          'TÉCNICO:',
                          data['TECNICORESPONSAVEL'] ?? 'JONATHAN',
                          'MANUTENÇÃO:',
                          'PREVENTIVA MENSAL'),
                    ],
                  ),
                ]),
              ),
              pw.SizedBox(height: 5),
              pw.Container(
                height: 140,
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                  children: [
                    pw.Expanded(
                        flex: 4,
                        child: pw.Container(
                            decoration: pw.BoxDecoration(
                                border: pw.Border.all(width: 0.5)),
                            child: pw.Column(
                                crossAxisAlignment:
                                    pw.CrossAxisAlignment.stretch,
                                children: [
                                  pw.Container(
                                      color: PdfColors.grey200,
                                      padding:
                                          pw.EdgeInsets.symmetric(vertical: 2),
                                      child: pw.Center(
                                          child: pw.Text('IMAGENS DO APARELHO',
                                              style: pw.TextStyle(
                                                  fontSize: 7,
                                                  fontWeight:
                                                      pw.FontWeight.bold)))),
                                  pw.Divider(height: 1, thickness: 0.5),
                                  pw.Expanded(
                                      child: imagemEvaporadora != null
                                          ? pw.Image(imagemEvaporadora,
                                              fit: pw.BoxFit.cover)
                                          : pw.Center(
                                              child: pw.Text('SEM IMAGEM',
                                                  style: pw.TextStyle(
                                                      fontSize: 8)))),
                                ]))),
                    pw.SizedBox(width: 5),
                    pw.Expanded(
                        flex: 6,
                        child: pw.Container(
                            decoration: pw.BoxDecoration(
                                border: pw.Border.all(width: 0.5)),
                            child: pw.Column(children: [
                              pw.Container(
                                  width: double.infinity,
                                  color: PdfColors.grey200,
                                  padding: pw.EdgeInsets.symmetric(vertical: 2),
                                  child: pw.Center(
                                      child: pw.Text('CONDIÇÃO E VERIFICAÇÃO',
                                          style: pw.TextStyle(
                                              fontSize: 7,
                                              fontWeight:
                                                  pw.FontWeight.bold)))),
                              pw.Table(border: tableBorder, columnWidths: {
                                0: pw.FixedColumnWidth(15),
                                1: pw.FlexColumnWidth(),
                                2: pw.FixedColumnWidth(25)
                              }, children: [
                                _buildCheckRow(
                                    '1',
                                    'LIMPEZA DA EVAPORADORA INTERNA:',
                                    data['LIMPEZADAEVAPORADORA'] ?? false),
                                _buildCheckRow('2', 'LIMPEZA DO FILTRO:',
                                    data['LAVAGEMDOFILTRO'] ?? false),
                                _buildCheckRow('3', 'LIMPEZA COM BACTERICIDA:',
                                    data['LIMPEZACOMBACTERICIDA'] ?? false),
                                _buildCheckRow('4',
                                    'VERIFICAÇÃO DO CONTROLE E PILHAS:', true),
                                _buildCheckRow('5', 'VERIFICAR RUÍDOS:',
                                    data['VERIFICAODERUIDOS'] ?? false),
                                _buildCheckRow(
                                    '6', 'VERIFICAR MAL CHEIRO:', true),
                                _buildValueRow('7', 'CORRENTE ELÉTRICA (A):',
                                    data['AMPERAGEM'] ?? ''),
                                _buildValueRow('8', 'TENSÃO ELÉTRICA (V):',
                                    data['TENSAO'] ?? '220V'),
                              ]),
                            ]))),
                  ],
                ),
              ),
              pw.SizedBox(height: 5),
              pw.Container(
                height: 195,
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                  children: [
                    pw.Expanded(
                        flex: 4,
                        child: pw.Container(
                            decoration: pw.BoxDecoration(
                                border: pw.Border.all(width: 0.5)),
                            child: pw.Column(
                                crossAxisAlignment:
                                    pw.CrossAxisAlignment.stretch,
                                children: [
                                  pw.Container(
                                      color: PdfColors.grey200,
                                      padding:
                                          pw.EdgeInsets.symmetric(vertical: 2),
                                      child: pw.Center(
                                          child: pw.Text('TERMOGRAFIA',
                                              style: pw.TextStyle(
                                                  fontSize: 7,
                                                  fontWeight:
                                                      pw.FontWeight.bold)))),
                                  pw.Divider(height: 1, thickness: 0.5),
                                  pw.Expanded(
                                      child: imagemTermografia != null
                                          ? pw.Image(imagemTermografia,
                                              fit: pw.BoxFit.cover)
                                          : pw.Center(
                                              child: pw.Text('',
                                                  style: pw.TextStyle(
                                                      fontSize: 20)))),
                                ]))),
                    pw.SizedBox(width: 5),
                    pw.Expanded(
                        flex: 6,
                        child: pw.Container(
                            decoration: pw.BoxDecoration(
                                border: pw.Border.all(width: 0.5)),
                            child: pw.Table(border: tableBorder, columnWidths: {
                              0: pw.FixedColumnWidth(15),
                              1: pw.FlexColumnWidth(),
                              2: pw.FixedColumnWidth(25)
                            }, children: [
                              _buildCheckRow('1', 'VERIFICAR DRENO:',
                                  data['VERIFICAODODRENO'] ?? false),
                              _buildCheckRow(
                                  '2', 'VERIFICAR PRESSÃO (PSI):', true),
                              _buildCheckRow('3', 'POLIR CONDENSADORA:',
                                  data['LAVAGEMDACONDENSADORA'] ?? false),
                              _buildCheckRow(
                                  '4', 'VERIFICAR PARTE ELÉTRICA:', true),
                              _buildCheckRow(
                                  '5',
                                  'VERIFICAR ISOLAMENTO TÉRMICO:',
                                  data['VERIFICAODOISOLAMENTOTRMICO'] ?? false),
                              _buildCheckRow('6', 'JATEAMENTO DA CONDENSADORA:',
                                  data['JATEAMENTODACONDENSADOR'] ?? false),
                              _buildCheckRow('7', 'JATEAMENTO DA EVAPORADORA:',
                                  data['JATEAMENTODAEVAPORADORA'] ?? false),
                              _buildCheckRow('8', 'LAVAGEM DO DRENO:',
                                  data['LAVAGEMDODRENO'] ?? false),
                              _buildCheckRow(
                                  '9',
                                  'LAVAGEM DA CARCAÇA EVAPORADORA:',
                                  data['LAVAGEMDACARCAAEVAPORADORA'] ?? false),
                              _buildCheckRow(
                                  '10',
                                  'LAVAGEM DA CARCAÇA CONDENSADORA:',
                                  data['LAVAGEMDACARCAACONDENSADORA'] ??
                                      data['LAVAGEMDACARCAACONDENSADOR'] ??
                                      false),
                              _buildCheckRow(
                                  '11',
                                  'LIMPEZA E LUBRIFICAÇÃO DO COMPRESSOR:',
                                  checkLimpezaCompressor),
                              _buildCheckRow(
                                  '12',
                                  'LAVAGEM DA TURBINA EVAPORADORA:',
                                  data['LAVAGEMDATURBINA'] ?? false),
                              _buildCheckRow('13', 'VERIFICAR PÉS DE BORRACHA:',
                                  data['VERIFICAODOSACABAMENTOS'] ?? false),
                            ]))),
                  ],
                ),
              ),
              pw.SizedBox(height: 5),
              pw.Container(
                decoration: pw.BoxDecoration(border: pw.Border.all(width: 0.5)),
                child: pw.Table(border: tableBorder, columnWidths: {
                  0: pw.FixedColumnWidth(25),
                  1: pw.FlexColumnWidth(),
                  2: pw.FixedColumnWidth(40)
                }, children: [
                  pw.TableRow(
                      decoration: pw.BoxDecoration(color: PdfColors.grey200),
                      children: [
                        pw.Padding(
                            padding: pw.EdgeInsets.all(2),
                            child: pw.Center(
                                child: pw.Text('ITEM',
                                    style: pw.TextStyle(
                                        fontSize: 7,
                                        fontWeight: pw.FontWeight.bold)))),
                        pw.Padding(
                            padding: pw.EdgeInsets.all(2),
                            child: pw.Text('DESCRIÇÃO SERVIÇO',
                                style: pw.TextStyle(
                                    fontSize: 7,
                                    fontWeight: pw.FontWeight.bold))),
                        pw.Padding(
                            padding: pw.EdgeInsets.all(2),
                            child: pw.Center(
                                child: pw.Text('STATUS',
                                    style: pw.TextStyle(
                                        fontSize: 7,
                                        fontWeight: pw.FontWeight.bold)))),
                      ]),
                  for (int i = 0; i < 5; i++)
                    pw.TableRow(children: [
                      pw.Padding(
                          padding: pw.EdgeInsets.all(2),
                          child: pw.Center(
                              child: pw.Text('${i + 1}',
                                  style: pw.TextStyle(fontSize: 7)))),
                      pw.Padding(
                          padding: pw.EdgeInsets.all(2),
                          child: pw.Text(listaItensServico[i],
                              style: pw.TextStyle(fontSize: 7))),
                      pw.Padding(
                          padding: pw.EdgeInsets.all(2),
                          child: pw.Center(
                              child: pw.Text('OK',
                                  style: pw.TextStyle(
                                      fontSize: 7,
                                      fontWeight: pw.FontWeight.bold)))),
                    ]),
                ]),
              ),
              pw.SizedBox(height: 5),
              pw.Container(
                width: double.infinity,
                height: 80,
                decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.black, width: 0.5)),
                padding: pw.EdgeInsets.all(5),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('INFORMAÇÕES ADICIONAIS',
                        style: pw.TextStyle(
                            fontSize: 7, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 2),
                    if (textoObservacao.isNotEmpty)
                      pw.Text(textoObservacao, style: pw.TextStyle(fontSize: 7))
                  ],
                ),
              ),
              pw.Spacer(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Container(
                        height: 40,
                        width: 150,
                        alignment: pw.Alignment.bottomCenter,
                        child: assinaturaHPS != null
                            ? pw.Image(assinaturaHPS, fit: pw.BoxFit.contain)
                            : null,
                      ),
                      pw.Container(
                          width: 150, height: 0.5, color: PdfColors.black),
                      pw.SizedBox(height: 2),
                      pw.Text('HPS REFRIGERAÇÃO',
                          style: pw.TextStyle(
                              fontSize: 7, fontWeight: pw.FontWeight.bold)),
                      pw.Text('CNPJ: 28.340.152/0001-52',
                          style: pw.TextStyle(fontSize: 6)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Container(
                          height: 40,
                          width: 150,
                          alignment: pw.Alignment.bottomCenter),
                      pw.Container(
                          width: 150, height: 0.5, color: PdfColors.black),
                      pw.SizedBox(height: 2),
                      pw.Text(
                          nomeClienteRodape.isNotEmpty
                              ? nomeClienteRodape
                              : 'CLIENTE',
                          style: pw.TextStyle(
                              fontSize: 7, fontWeight: pw.FontWeight.bold)),
                      if (cnpjClienteRodape.isNotEmpty)
                        pw.Text('CNPJ: $cnpjClienteRodape',
                            style: pw.TextStyle(fontSize: 6)),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 10),
              pw.Center(
                  child: pw.Column(children: [
                pw.Text('AV PARÁ 486 IBIRAPUERA VITÓRIA DA CONQUISTA- BA',
                    style: pw.TextStyle(
                        fontSize: 6, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 2),
                pw.Text(
                    'Tel: (77) 98819-4630 / 98861-2447  -  www.hpsrefri.com.br',
                    style: pw.TextStyle(fontSize: 6)),
              ])),
            ],
          );
        },
      ),
    );

    final pdfBytes = await pdf.save();

    final storagePath = '$pastaEmail/$ano/$mesStorage/${patrimonio.trim()}.pdf';

    await firebase_storage.FirebaseStorage.instance
        .ref()
        .child(storagePath)
        .putData(
          pdfBytes,
          firebase_storage.SettableMetadata(contentType: 'application/pdf'),
        );
  } catch (e) {
    print('Erro CRÍTICO no upload do Patrimonio $patrimonio: $e');
    rethrow;
  }
}
