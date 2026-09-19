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

import 'dart:typed_data';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AssistenteTecnicoIaWidget extends StatefulWidget {
  const AssistenteTecnicoIaWidget({
    super.key,
    this.width,
    this.height,
    this.osNumero,
    this.clienteNome,
    this.equipamentoInfo,
  });

  final double? width;
  final double? height;
  final String? osNumero;
  final String? clienteNome;
  final String? equipamentoInfo;

  @override
  State<AssistenteTecnicoIaWidget> createState() =>
      _AssistenteTecnicoIaWidgetState();
}

class _AssistenteTecnicoIaWidgetState extends State<AssistenteTecnicoIaWidget>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ImagePicker _picker = ImagePicker();

  // Modelos de fallback
  static const List<String> _modelCandidates = [
    'gemini-2.0-flash',
    'gemini-2.5-flash',
    'gemini-1.5-flash',
  ];

  // Tab 1: Gerador de Parecer
  final TextEditingController _notasController = TextEditingController();
  String _estiloSelecionado = 'Laudo Formal';
  String? _parecerGerado;
  bool _gerandoParecer = false;
  String? _erroParecer;

  // Tab 2: Diagnóstico por Imagem / Código
  final TextEditingController _sintomasController = TextEditingController();
  Uint8List? _fotoBytes;
  String? _fotoMime;
  String? _diagnosticoGerado;
  bool _gerandoDiagnostico = false;
  String? _erroDiagnostico;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _notasController.dispose();
    _sintomasController.dispose();
    super.dispose();
  }

  GenerativeModel _getModel(String systemPrompt) {
    for (final name in _modelCandidates) {
      try {
        return FirebaseAI.googleAI().generativeModel(
          model: name,
          systemInstruction: Content.system(systemPrompt),
        );
      } catch (_) {}
    }
    return FirebaseAI.googleAI().generativeModel(
      model: 'gemini-2.0-flash',
      systemInstruction: Content.system(systemPrompt),
    );
  }

  Future<void> _gerarParecer() async {
    final texto = _notasController.text.trim();
    if (texto.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, informe suas anotações ou serviços executados.'),
          backgroundColor: Colors.amber,
        ),
      );
      return;
    }

    setState(() {
      _gerandoParecer = true;
      _erroParecer = null;
      _parecerGerado = null;
    });

    try {
      const systemPrompt =
          'Você é um engenheiro e especialista em manutenção da HPS REFRIGERAÇÃO E GESTÃO DE O.S. '
          'Sua função é transformar anotações rápidas e informais dos técnicos de campo em um relatório técnico impecável. '
          'Use terminologia técnica correta de refrigeração, HVAC e elétrica (pressões em PSI/bar, vácuo em micra, corrente em Amperes, etc). '
          'Sempre responda em português brasileiro bem estruturado.';

      final model = _getModel(systemPrompt);

      String instrucaoEstilo = '';
      if (_estiloSelecionado == 'Laudo Formal') {
        instrucaoEstilo =
            'Formate como LAUDO TÉCNICO FORMAL com as seções:\n'
            '1. IDENTIFICAÇÃO E QUEIXA INICIAL\n'
            '2. DIAGNÓSTICO TÉCNICO CONSTATADO\n'
            '3. SERVIÇOS E AÇÕES CORRETIVAS EXECUTADAS\n'
            '4. MEDIÇÕES E PARÂMETROS FINAIS DE OPERAÇÃO\n'
            '5. RECOMENDAÇÕES AO CLIENTE.';
      } else if (_estiloSelecionado == 'Resumo para Cliente (WhatsApp)') {
        instrucaoEstilo =
            'Formate como uma mensagem clara, educada e profissional pronta para enviar ao CLIENTE no WhatsApp, usando emojis adequados (✅, 🔧, ❄️, 📋), explicando de forma simples o que foi consertado e que o equipamento foi entregue em perfeito funcionamento.';
      } else {
        instrucaoEstilo =
            'Formate como RELATÓRIO PREVENTIVO PMOC detalhando limpeza, higienização, verificação mecânica, elétrica e atestando as condições do sistema.';
      }

      final prompt =
          'Contexto da Manutenção:\n'
          '${widget.osNumero != null ? 'O.S. Nº: ${widget.osNumero}\n' : ''}'
          '${widget.clienteNome != null ? 'Cliente: ${widget.clienteNome}\n' : ''}'
          '${widget.equipamentoInfo != null ? 'Equipamento: ${widget.equipamentoInfo}\n' : ''}'
          'Instrução de Formato: $instrucaoEstilo\n\n'
          'Anotações do técnico no campo:\n"$texto"';

      final response = await model.generateContent([Content.text(prompt)]);
      setState(() {
        _parecerGerado = response.text ?? 'Não foi possível gerar o texto.';
        _gerandoParecer = false;
      });
    } catch (e) {
      setState(() {
        _erroParecer = 'Erro ao processar: $e';
        _gerandoParecer = false;
      });
    }
  }

  Future<void> _capturarFoto(ImageSource source) async {
    try {
      final xfile = await _picker.pickImage(
        source: source,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 85,
      );
      if (xfile == null) return;
      final bytes = await xfile.readAsBytes();
      final mime = xfile.mimeType ?? 'image/jpeg';
      setState(() {
        _fotoBytes = bytes;
        _fotoMime = mime;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Falha ao obter imagem: $e')),
      );
    }
  }

  Future<void> _gerarDiagnostico() async {
    final sintomas = _sintomasController.text.trim();
    if (sintomas.isEmpty && _fotoBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Adicione uma foto ou informe o código de erro/sintomas.'),
          backgroundColor: Colors.amber,
        ),
      );
      return;
    }

    setState(() {
      _gerandoDiagnostico = true;
      _erroDiagnostico = null;
      _diagnosticoGerado = null;
    });

    try {
      const systemPrompt =
          'Você é o Assistente Especialista de Diagnóstico Técnico da HPS (HVAC, Refrigeração Comercial/Industrial, Elétrica e Climatização). '
          'Você analisa imagens de placas eletrônicas, códigos no display de condensadoras/evaporadoras, manômetros e relatórios de campo. '
          'Forneça um guia de diagnóstico prático e direto para o técnico no local.';

      final model = _getModel(systemPrompt);

      final promptText =
          'O técnico está no campo com a seguinte situação:\n'
          '${widget.equipamentoInfo != null ? 'Equipamento: ${widget.equipamentoInfo}\n' : ''}'
          'Sintomas / Código de Erro informado: ${sintomas.isNotEmpty ? sintomas : 'Analise a imagem em anexo'}.\n\n'
          'Por favor, forneça de forma estruturada:\n'
          '1. 🔍 SIGNIFICADO DO ERRO / CAUSAS MAIS PROVÁVEIS\n'
          '2. 🧪 PASSO A PASSO DE TESTES (Quais medições fazer com multímetro, termômetro ou manômetro antes de trocar peças)\n'
          '3. ⚠️ CUIDADOS DE SEGURANÇA (Risco de choque, alta pressão, capacitores carregados)\n'
          '4. 📦 PEÇAS OU COMPONENTES SUSPEITOS PARA POSSÍVEL SUBSTITUIÇÃO';

      Content content;
      if (_fotoBytes != null) {
        content = Content.multi([
          InlineDataPart(_fotoMime ?? 'image/jpeg', _fotoBytes!),
          TextPart(promptText),
        ]);
      } else {
        content = Content.text(promptText);
      }

      final response = await model.generateContent([content]);
      setState(() {
        _diagnosticoGerado = response.text ?? 'Nenhuma resposta recebida.';
        _gerandoDiagnostico = false;
      });
    } catch (e) {
      setState(() {
        _erroDiagnostico = 'Erro no diagnóstico: $e';
        _gerandoDiagnostico = false;
      });
    }
  }

  void _copiarTexto(String texto, String rotulo) {
    Clipboard.setData(ClipboardData(text: texto));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$rotulo copiado para a área de transferência!'),
        backgroundColor: const Color(0xFF047857),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
    final subtitleColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    const primaryColor = Color(0xFF1D4ED8);

    return Container(
      width: widget.width ?? double.infinity,
      height: widget.height ?? double.infinity,
      color: bg,
      child: Column(
        children: [
          // Header Moderno
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: cardBg,
              border: Border(bottom: BorderSide(color: borderColor)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1D4ED8), Color(0xFF0F766E)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.auto_awesome, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Assistente Técnico IA',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      Text(
                        'Inteligência de campo para O.S., Laudos e Diagnósticos',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: subtitleColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // TabBar
          Container(
            color: cardBg,
            child: TabBar(
              controller: _tabController,
              indicatorColor: primaryColor,
              indicatorWeight: 3,
              labelColor: primaryColor,
              unselectedLabelColor: subtitleColor,
              labelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
              tabs: const [
                Tab(
                  icon: Icon(Icons.description_outlined, size: 20),
                  text: 'Gerar Parecer',
                ),
                Tab(
                  icon: Icon(Icons.camera_alt_outlined, size: 20),
                  text: 'Diagnóstico IA',
                ),
                Tab(
                  icon: Icon(Icons.tune_outlined, size: 20),
                  text: 'Guias de Campo',
                ),
              ],
            ),
          ),

          // TabView
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTabParecer(cardBg, textColor, subtitleColor, borderColor, isDark),
                _buildTabDiagnostico(cardBg, textColor, subtitleColor, borderColor, isDark),
                _buildTabGuias(cardBg, textColor, subtitleColor, borderColor, isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // ABA 1: GERADOR DE PARECER
  // -------------------------------------------------------------
  Widget _buildTabParecer(
      Color cardBg, Color textColor, Color subtitleColor, Color borderColor, bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Seletor de Estilo
        Text(
          'Formato Desejado:',
          style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: textColor),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            _estiloChip('Laudo Formal', Icons.article_outlined),
            _estiloChip('Resumo para Cliente (WhatsApp)', Icons.chat_bubble_outline),
            _estiloChip('Preventiva PMOC', Icons.verified_outlined),
          ],
        ),
        const SizedBox(height: 16),

        // Campo de anotações
        Text(
          'Anotações rápidas do serviço executado:',
          style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: textColor),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _notasController,
          maxLines: 4,
          style: GoogleFonts.inter(fontSize: 14, color: textColor),
          decoration: InputDecoration(
            hintText:
                'Ex: cliente informou que split não gelava. pressão sucção estava em 35psi. localizado vazamento na união do evaporador, refeita flange, vácuo em 320 micra, carga de 850g de r410a. pressão normalizou em 118psi e corrente 4.9A.',
            hintStyle: GoogleFonts.inter(fontSize: 13, color: subtitleColor),
            filled: true,
            fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: borderColor),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Botão Gerar
        ElevatedButton.icon(
          onPressed: _gerandoParecer ? null : _gerarParecer,
          icon: _gerandoParecer
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.auto_awesome, size: 20),
          label: Text(
            _gerandoParecer ? 'Transformando com IA...' : 'Gerar Parecer Técnico Profissional',
            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1D4ED8),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),

        if (_erroParecer != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.withOpacity(0.3)),
            ),
            child: Text(
              _erroParecer!,
              style: GoogleFonts.inter(fontSize: 12, color: Colors.red),
            ),
          ),
        ],

        if (_parecerGerado != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.check_circle_outline, color: Color(0xFF047857), size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Parecer Gerado com Sucesso',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF047857),
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy, size: 18),
                      tooltip: 'Copiar texto',
                      onPressed: () => _copiarTexto(_parecerGerado!, 'Parecer Técnico'),
                    ),
                  ],
                ),
                const Divider(),
                SelectableText(
                  _parecerGerado!,
                  style: GoogleFonts.inter(fontSize: 13, height: 1.5, color: textColor),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _copiarTexto(_parecerGerado!, 'Parecer Técnico'),
                        icon: const Icon(Icons.copy, size: 16),
                        label: const Text('Copiar Texto'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _estiloChip(String estilo, IconData icon) {
    final selecionado = _estiloSelecionado == estilo;
    return ChoiceChip(
      avatar: Icon(icon, size: 16, color: selecionado ? Colors.white : const Color(0xFF1D4ED8)),
      label: Text(estilo),
      selected: selecionado,
      onSelected: (val) {
        if (val) setState(() => _estiloSelecionado = estilo);
      },
      selectedColor: const Color(0xFF1D4ED8),
      labelStyle: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: selecionado ? Colors.white : const Color(0xFF1E293B),
      ),
    );
  }

  // -------------------------------------------------------------
  // ABA 2: DIAGNÓSTICO POR FOTO / CÓDIGO
  // -------------------------------------------------------------
  Widget _buildTabDiagnostico(
      Color cardBg, Color textColor, Color subtitleColor, Color borderColor, bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Foto do Display de Erro, Placa ou Componente:',
          style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: textColor),
        ),
        const SizedBox(height: 8),

        // Área de Imagem
        if (_fotoBytes != null)
          Stack(
            children: [
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor),
                  image: DecorationImage(
                    image: MemoryImage(_fotoBytes!),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: CircleAvatar(
                  backgroundColor: Colors.black.withOpacity(0.6),
                  radius: 16,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.close, color: Colors.white, size: 18),
                    onPressed: () => setState(() => _fotoBytes = null),
                  ),
                ),
              ),
            ],
          )
        else
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _capturarFoto(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Tirar Foto'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _capturarFoto(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Galeria'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),

        const SizedBox(height: 16),
        Text(
          'Código de Erro ou Sintomas Observados:',
          style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: textColor),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _sintomasController,
          maxLines: 2,
          style: GoogleFonts.inter(fontSize: 14, color: textColor),
          decoration: InputDecoration(
            hintText: 'Ex: Erro E1 Midea Inverter 12.000 BTU, pisca 3 vezes o LED da condensadora.',
            hintStyle: GoogleFonts.inter(fontSize: 13, color: subtitleColor),
            filled: true,
            fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: borderColor),
            ),
          ),
        ),
        const SizedBox(height: 12),

        ElevatedButton.icon(
          onPressed: _gerandoDiagnostico ? null : _gerarDiagnostico,
          icon: _gerandoDiagnostico
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.troubleshoot, size: 20),
          label: Text(
            _gerandoDiagnostico ? 'Analisando Imagem e Falhas...' : 'Diagnosticar Falha com IA',
            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0F766E),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),

        if (_erroDiagnostico != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.withOpacity(0.3)),
            ),
            child: Text(_erroDiagnostico!, style: GoogleFonts.inter(fontSize: 12, color: Colors.red)),
          ),
        ],

        if (_diagnosticoGerado != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.bolt, color: Color(0xFFB45309), size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Guia de Testes e Diagnóstico',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy, size: 18),
                      tooltip: 'Copiar diagnóstico',
                      onPressed: () => _copiarTexto(_diagnosticoGerado!, 'Diagnóstico'),
                    ),
                  ],
                ),
                const Divider(),
                SelectableText(
                  _diagnosticoGerado!,
                  style: GoogleFonts.inter(fontSize: 13, height: 1.5, color: textColor),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // -------------------------------------------------------------
  // ABA 3: GUIAS TÉCNICOS RÁPIDOS
  // -------------------------------------------------------------
  Widget _buildTabGuias(
      Color cardBg, Color textColor, Color subtitleColor, Color borderColor, bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _guiaCard(
          cardBg: cardBg,
          textColor: textColor,
          subtitleColor: subtitleColor,
          borderColor: borderColor,
          icon: Icons.speed,
          titulo: 'Cálculo de Superaquecimento (SA)',
          descricao:
              'SA = Temperatura da Linha de Sucção (Termômetro) - Temperatura de Evaporação (Manômetro convertida).\n\n'
              '• Alvo típico para Válvula de Expansão: 4°C a 8°C\n'
              '• Alvo típico para Pistão / Capilar: 7°C a 12°C\n'
              '• SA Alto (> 15°C): Pouco fluido (falta de gás) ou capilar obstruído.\n'
              '• SA Baixo (< 3°C): Excesso de gás ou retorno de líquido ao compressor.',
        ),
        const SizedBox(height: 12),
        _guiaCard(
          cardBg: cardBg,
          textColor: textColor,
          subtitleColor: subtitleColor,
          borderColor: borderColor,
          icon: Icons.electric_meter_outlined,
          titulo: 'Tabela de Sensores de Temperatura (NTC)',
          descricao:
              'Valores padrão de resistência a 25°C:\n'
              '• Midea / Carrier / Springer: 10 kΩ (Ambiente) / 20 kΩ ou 50 kΩ (Descarga)\n'
              '• LG / Daikin: 10 kΩ ou 20 kΩ\n'
              '• Samsung: 10 kΩ (Ambiente) / 10 kΩ (Serpentina) / 200 kΩ (Descarga)\n'
              '• Dica: Ao medir com multímetro, teste a 25°C ou coloque o sensor em água com gelo (0°C) para conferir variação.',
        ),
        const SizedBox(height: 12),
        _guiaCard(
          cardBg: cardBg,
          textColor: textColor,
          subtitleColor: subtitleColor,
          borderColor: borderColor,
          icon: Icons.air,
          titulo: 'Procedimento de Vácuo Perfeito',
          descricao:
              '• Vácuo mínimo aceitável: Abaixo de 500 Micras com vacuômetro digital.\n'
              '• Teste de Estanqueidade: Fechar registros da bomba e aguardar 10 minutos.\n'
              '  - Se subir rápido e continuar subindo até a pressão atmosférica: Há VAZAMENTO no sistema.\n'
              '  - Se subir até ~1.000 micras e estabilizar: Há UMIDADE residual nas tubulações (continuar vácuo).',
        ),
      ],
    );
  }

  Widget _guiaCard({
    required Color cardBg,
    required Color textColor,
    required Color subtitleColor,
    required Color borderColor,
    required IconData icon,
    required String titulo,
    required String descricao,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF1D4ED8), size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  titulo,
                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: textColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            descricao,
            style: GoogleFonts.inter(fontSize: 13, height: 1.5, color: subtitleColor),
          ),
        ],
      ),
    );
  }
}
