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

import '/custom_code/widgets/index.dart';
import '/custom_code/actions/index.dart';
import '/flutter_flow/custom_functions.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

// ─────────────────────────────────────────────────────────────────────────────
// MODELO
// ─────────────────────────────────────────────────────────────────────────────

class FinanceRecord {
  final String docId;
  double valor;
  String setor;
  String data;
  String hora;
  String quem;
  String descricao;
  String tipo; // Receita ou Despesa
  String formaPagamento; // PIX, Cartão, Boleto, Dinheiro...
  String status; // Pago, Pendente
  final DateTime criadoEm;

  FinanceRecord({
    required this.docId,
    required this.valor,
    required this.setor,
    required this.data,
    required this.hora,
    required this.quem,
    required this.descricao,
    required this.tipo,
    required this.formaPagamento,
    required this.status,
    required this.criadoEm,
  });

  factory FinanceRecord.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    DateTime created = DateTime.now();
    if (d['criadoEm'] is Timestamp) {
      created = (d['criadoEm'] as Timestamp).toDate();
    }
    return FinanceRecord(
      docId: doc.id,
      valor: (d['valor'] as num?)?.toDouble() ?? 0.0,
      setor: d['setor'] ?? 'Outros',
      data: d['data'] ?? '',
      hora: d['hora'] ?? '',
      quem: d['quem'] ?? '',
      descricao: d['descricao'] ?? '',
      tipo: d['tipo'] ?? 'Despesa',
      formaPagamento: d['formaPagamento'] ?? 'Outros',
      status: d['status'] ?? 'Pago',
      criadoEm: created,
    );
  }

  Map<String, dynamic> toMap() => {
        'valor': valor,
        'setor': setor,
        'data': data,
        'hora': hora,
        'quem': quem,
        'descricao': descricao,
        'tipo': tipo,
        'formaPagamento': formaPagamento,
        'status': status,
      };
}

// ─────────────────────────────────────────────────────────────────────────────
// WIDGET PRINCIPAL
// ─────────────────────────────────────────────────────────────────────────────

class FinanceDashboardWidget extends StatefulWidget {
  const FinanceDashboardWidget({
    Key? key,
    this.width,
    this.height,
  }) : super(key: key);

  final double? width;
  final double? height;

  @override
  State<FinanceDashboardWidget> createState() => _FinanceDashboardWidgetState();
}

class _FinanceDashboardWidgetState extends State<FinanceDashboardWidget>
    with SingleTickerProviderStateMixin {
  List<FinanceRecord> _allRecords = [];
  bool _loading = true;
  String? _error;

  String _filterSetor = 'Todos';
  String _filterQuem = 'Todos';
  String _filterTipo = 'Todos';
  String _searchQuery = '';

  DateTime? _dateStart;
  DateTime? _dateEnd;

  final Set<String> _selected = {};
  bool _selectMode = false;

  late TabController _tabCtrl;
  final TextEditingController _searchCtrl = TextEditingController();

  String _sortField = 'criadoEm';
  bool _sortAsc = false;

  static const List<String> kSetores = [
    'Todos',
    'Alimentação',
    'Assinaturas',
    'Casa',
    'Combustível',
    'Equipamentos',
    'Funcionário',
    'Hospedagem',
    'Impostos',
    'Limpeza',
    'Loja',
    'Manutenção',
    'Marketing',
    'Material',
    'Serviços',
    'Taxas Bancárias',
    'Transporte',
    'Vendas',
    'Outros',
  ];

  static const List<String> kTipos = ['Receita', 'Despesa'];
  static const List<String> kFormasPgto = [
    'PIX',
    'Dinheiro',
    'Cartão Crédito',
    'Cartão Débito',
    'Boleto',
    'Transferência',
    'Outros'
  ];
  static const List<String> kStatus = ['Pago', 'Pendente'];

  // ── CORES (ATUALIZADAS PARA PRETO E BRANCO ABSOLUTO) ───────────────────────
  bool get isDark => true;

  Color get bg => isDark ? const Color(0xFF0B0F17) : const Color(0xFFF8FAFC);
  Color get surface =>
      isDark ? const Color(0xFF111827) : Colors.white;
  Color get surface2 =>
      isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9);
  Color get primary =>
      const Color(0xFF2563EB); // Cobalt Blue
  Color get danger => const Color(0xFFEF4444);
  Color get success => const Color(0xFF10B981);
  Color get warning => const Color(0xFFF59E0B);

  Color get textMain => isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
  Color get textSub => isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
  Color get border =>
      isDark ? Colors.white.withOpacity(0.08) : const Color(0xFFE2E8F0);

  Color _sectorColor(String s) {
    const cols = [
      Color(0xFF0D9488),
      Color(0xFF6366F1),
      Color(0xFFF59E0B),
      Color(0xFFEF4444),
      Color(0xFF10B981),
      Color(0xFF8B5CF6),
      Color(0xFFEC4899),
      Color(0xFF06B6D4),
    ];
    return cols[s.hashCode.abs() % cols.length];
  }

  // ── CICLO DE VIDA ──────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  // ── DATA HELPERS ───────────────────────────────────────────────────────────
  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  String _fmtVal(double v) =>
      'R\$ ${v.toStringAsFixed(2).replaceAll('.', ',')}';

  // ── FIRESTORE ──────────────────────────────────────────────────────────────
  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final snap = await FirebaseFirestore.instance
          .collection('financeiro')
          .orderBy('criadoEm', descending: true)
          .get();
      setState(() {
        _allRecords = snap.docs.map(FinanceRecord.fromDoc).toList();
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = '$e';
        _loading = false;
      });
    }
  }

  Future<void> _deleteRecord(FinanceRecord rec) async {
    await FirebaseFirestore.instance
        .collection('financeiro')
        .doc(rec.docId)
        .delete();
    setState(() => _allRecords.removeWhere((r) => r.docId == rec.docId));
    _showSnack('Lançamento excluído.', isError: true);
  }

  Future<void> _deleteSelected() async {
    final batch = FirebaseFirestore.instance.batch();
    for (final id in _selected) {
      batch.delete(FirebaseFirestore.instance.collection('financeiro').doc(id));
    }
    await batch.commit();
    setState(() {
      _allRecords.removeWhere((r) => _selected.contains(r.docId));
      _selected.clear();
      _selectMode = false;
    });
    _showSnack('${_selected.length} lançamentos excluídos.', isError: true);
  }

  Future<void> _updateRecord(FinanceRecord rec) async {
    await FirebaseFirestore.instance
        .collection('financeiro')
        .doc(rec.docId)
        .update(rec.toMap());
    _showSnack('Lançamento atualizado!');
    setState(() {});
  }

  // ── FILTROS & CÁLCULOS ─────────────────────────────────────────────────────
  List<FinanceRecord> get _filtered {
    var list = List<FinanceRecord>.from(_allRecords);

    if (_filterSetor != 'Todos') {
      list = list.where((r) => r.setor == _filterSetor).toList();
    }
    if (_filterQuem != 'Todos') {
      list = list.where((r) => r.quem == _filterQuem).toList();
    }
    if (_filterTipo != 'Todos') {
      list = list.where((r) => r.tipo == _filterTipo).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list
          .where((r) =>
              r.descricao.toLowerCase().contains(q) ||
              r.quem.toLowerCase().contains(q) ||
              r.setor.toLowerCase().contains(q) ||
              r.formaPagamento.toLowerCase().contains(q))
          .toList();
    }
    if (_dateStart != null) {
      list = list.where((r) => !r.criadoEm.isBefore(_dateStart!)).toList();
    }
    if (_dateEnd != null) {
      final end =
          DateTime(_dateEnd!.year, _dateEnd!.month, _dateEnd!.day, 23, 59, 59);
      list = list.where((r) => !r.criadoEm.isAfter(end)).toList();
    }

    list.sort((a, b) {
      int cmp;
      switch (_sortField) {
        case 'valor':
          cmp = a.valor.compareTo(b.valor);
          break;
        case 'quem':
          cmp = a.quem.compareTo(b.quem);
          break;
        case 'setor':
          cmp = a.setor.compareTo(b.setor);
          break;
        case 'tipo':
          cmp = a.tipo.compareTo(b.tipo);
          break;
        default:
          cmp = a.criadoEm.compareTo(b.criadoEm);
      }
      return _sortAsc ? cmp : -cmp;
    });

    return list;
  }

  double get _totalReceitas => _filtered
      .where((r) => r.tipo == 'Receita')
      .fold(0.0, (s, r) => s + r.valor);
  double get _totalDespesas => _filtered
      .where((r) => r.tipo == 'Despesa')
      .fold(0.0, (s, r) => s + r.valor);
  double get _saldo => _totalReceitas - _totalDespesas;

  Map<String, double> get _bySector {
    final map = <String, double>{};
    // Agrupa apenas despesas para análise de custos
    for (final r in _filtered.where((r) => r.tipo == 'Despesa')) {
      map[r.setor] = (map[r.setor] ?? 0) + r.valor;
    }
    final sorted = map.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return Map.fromEntries(sorted);
  }

  Map<String, double> get _byPerson {
    final map = <String, double>{};
    for (final r in _filtered) {
      // Somando o volume movimentado (receita ou despesa) por pessoa
      map[r.quem] = (map[r.quem] ?? 0) + r.valor;
    }
    final sorted = map.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return Map.fromEntries(sorted);
  }

  List<String> get _quemList {
    final set = <String>{'Todos'};
    for (final r in _allRecords) set.add(r.quem);
    final list = set.toList()..sort();
    return list;
  }

  bool get _hasFilters =>
      _filterSetor != 'Todos' ||
      _filterQuem != 'Todos' ||
      _filterTipo != 'Todos' ||
      _dateStart != null ||
      _dateEnd != null ||
      _searchQuery.isNotEmpty;

  // ── SNACK ──────────────────────────────────────────────────────────────────
  void _showSnack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(color: Colors.white)),
      backgroundColor: isError ? danger : primary,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      duration: const Duration(seconds: 3),
    ));
  }

  // ── DIALOG EDIÇÃO ──────────────────────────────────────────────────────────
  Future<void> _showEditDialog(FinanceRecord rec) async {
    final valorCtrl = TextEditingController(text: rec.valor.toStringAsFixed(2));
    final descCtrl = TextEditingController(text: rec.descricao);
    final quemCtrl = TextEditingController(text: rec.quem);
    final dataCtrl = TextEditingController(text: rec.data);
    final horaCtrl = TextEditingController(text: rec.hora);

    String setor = rec.setor;
    String tipo = kTipos.contains(rec.tipo) ? rec.tipo : 'Despesa';
    String formaPgto = kFormasPgto.contains(rec.formaPagamento)
        ? rec.formaPagamento
        : 'Outros';
    String status = kStatus.contains(rec.status) ? rec.status : 'Pago';

    final saved = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSt) => Dialog(
          backgroundColor: bg,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: primary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10)),
                    child: Icon(Icons.edit_rounded, color: primary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text('Editar Lançamento',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: textMain)),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    icon: Icon(Icons.close_rounded, color: textSub),
                  ),
                ]),
                const SizedBox(height: 20),

                // Linha 1: Tipo e Valor
                Row(children: [
                  Expanded(
                    flex: 4,
                    child: DropdownButtonFormField<String>(
                      value: tipo,
                      decoration: _deco('Tipo', Icons.swap_vert_rounded),
                      dropdownColor: surface,
                      style: TextStyle(color: textMain, fontSize: 14),
                      items: kTipos
                          .map(
                              (s) => DropdownMenuItem(value: s, child: Text(s)))
                          .toList(),
                      onChanged: (v) => setSt(() => tipo = v ?? tipo),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 5,
                    child: _field('Valor (R\$)', valorCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        icon: Icons.attach_money_rounded),
                  ),
                ]),
                const SizedBox(height: 12),

                // Linha 2: Setor e Status
                Row(children: [
                  Expanded(
                    flex: 5,
                    child: DropdownButtonFormField<String>(
                      value: kSetores.contains(setor) ? setor : 'Outros',
                      decoration: _deco('Setor', Icons.category_rounded),
                      dropdownColor: surface,
                      style: TextStyle(color: textMain, fontSize: 14),
                      items: kSetores
                          .where((s) => s != 'Todos')
                          .map(
                              (s) => DropdownMenuItem(value: s, child: Text(s)))
                          .toList(),
                      onChanged: (v) => setSt(() => setor = v ?? setor),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 4,
                    child: DropdownButtonFormField<String>(
                      value: status,
                      decoration:
                          _deco('Status', Icons.check_circle_outline_rounded),
                      dropdownColor: surface,
                      style: TextStyle(color: textMain, fontSize: 14),
                      items: kStatus
                          .map(
                              (s) => DropdownMenuItem(value: s, child: Text(s)))
                          .toList(),
                      onChanged: (v) => setSt(() => status = v ?? status),
                    ),
                  ),
                ]),
                const SizedBox(height: 12),

                // Linha 3: Forma Pgto
                DropdownButtonFormField<String>(
                  value: formaPgto,
                  decoration:
                      _deco('Forma de Pagamento', Icons.credit_card_rounded),
                  dropdownColor: surface,
                  style: TextStyle(color: textMain, fontSize: 14),
                  items: kFormasPgto
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (v) => setSt(() => formaPgto = v ?? formaPgto),
                ),
                const SizedBox(height: 12),

                _field('Quem realizou', quemCtrl, icon: Icons.person_rounded),
                const SizedBox(height: 12),

                Row(children: [
                  Expanded(
                      child: _field('Data (DD/MM)', dataCtrl,
                          icon: Icons.calendar_today_rounded)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: _field('Hora', horaCtrl,
                          icon: Icons.access_time_rounded)),
                ]),
                const SizedBox(height: 12),

                _field('Descrição', descCtrl,
                    icon: Icons.description_rounded, maxLines: 2),
                const SizedBox(height: 20),

                Row(children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(color: border),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12))),
                      child:
                          Text('Cancelar', style: TextStyle(color: textMain)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pop(ctx, true),
                      icon: const Icon(Icons.save_rounded,
                          size: 18, color: Colors.white),
                      label: const Text('Salvar',
                          style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12))),
                    ),
                  ),
                ]),
              ],
            ),
          ),
        ),
      ),
    );

    if (saved == true) {
      rec.valor = double.tryParse(valorCtrl.text.replaceAll(',', '.').trim()) ??
          rec.valor;
      rec.setor = setor;
      rec.tipo = tipo;
      rec.formaPagamento = formaPgto;
      rec.status = status;
      rec.quem = quemCtrl.text.trim();
      rec.data = dataCtrl.text.trim();
      rec.hora = horaCtrl.text.trim();
      rec.descricao = descCtrl.text.trim();
      await _updateRecord(rec);
    }
  }

  InputDecoration _deco(String label, IconData icon) => InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: textSub),
        prefixIcon: Icon(icon, size: 18, color: primary),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: border)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: border)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: primary, width: 1.5)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        isDense: true,
      );

  Widget _field(String label, TextEditingController ctrl,
          {IconData? icon,
          TextInputType keyboardType = TextInputType.text,
          int maxLines = 1}) =>
      TextFormField(
        controller: ctrl,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: TextStyle(color: textMain, fontSize: 14),
        decoration: _deco(label, icon ?? Icons.edit_rounded),
      );

  // ── CONFIRM DELETE ─────────────────────────────────────────────────────────
  Future<bool> _confirmDelete(String msg) async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: surface,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(children: [
              Icon(Icons.warning_amber_rounded, color: danger),
              const SizedBox(width: 8),
              Text('Confirmar', style: TextStyle(color: textMain)),
            ]),
            content: Text(msg, style: TextStyle(color: textSub)),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: Text('Cancelar', style: TextStyle(color: textSub))),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: ElevatedButton.styleFrom(
                    backgroundColor: danger,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8))),
                child: const Text('Excluir'),
              ),
            ],
          ),
        ) ??
        false;
  }

  // ── PDF ────────────────────────────────────────────────────────────────────
  Future<void> _exportPdf() async {
    if (_filtered.isEmpty) {
      _showSnack('Nenhum dado para exportar.', isError: true);
      return;
    }

    final pdf = pw.Document();
    final dateStr = _fmtDate(DateTime.now());

    pdf.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      header: (_) => pw.Container(
        padding: const pw.EdgeInsets.only(bottom: 10),
        decoration: const pw.BoxDecoration(
            border: pw.Border(
                bottom: pw.BorderSide(color: PdfColors.teal700, width: 2))),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('HPS Refrigeração',
                      style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.teal700)),
                  pw.Text('Relatório Financeiro',
                      style: const pw.TextStyle(
                          fontSize: 10, color: PdfColors.grey600)),
                ]),
            pw.Text('Gerado em $dateStr',
                style:
                    const pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
          ],
        ),
      ),
      footer: (ctx) => pw.Align(
        alignment: pw.Alignment.centerRight,
        child: pw.Text('Página ${ctx.pageNumber}/${ctx.pagesCount}',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
      ),
      build: (ctx) => [
        pw.SizedBox(height: 14),
        pw.Container(
          padding: const pw.EdgeInsets.all(14),
          decoration: pw.BoxDecoration(
              color: PdfColors.grey100,
              borderRadius: pw.BorderRadius.circular(8)),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
            children: [
              _pdfHeaderVal('Receitas', _totalReceitas, PdfColors.green700),
              _pdfHeaderVal('Despesas', _totalDespesas, PdfColors.red700),
              _pdfHeaderVal('Saldo Total', _saldo,
                  _saldo >= 0 ? PdfColors.teal700 : PdfColors.red700),
            ],
          ),
        ),
        pw.SizedBox(height: 16),
        pw.Text('Lançamentos Detalhados',
            style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 6),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
          columnWidths: {
            0: const pw.FlexColumnWidth(1.5),
            1: const pw.FlexColumnWidth(1.5),
            2: const pw.FlexColumnWidth(2),
            3: const pw.FlexColumnWidth(3),
            4: const pw.FlexColumnWidth(1.8),
          },
          children: [
            _pdfRow(['Data', 'Tipo', 'Setor/Pgto', 'Descrição', 'Valor'],
                header: true),
            ..._filtered.asMap().entries.map((e) => pw.TableRow(
                  decoration: e.key.isOdd
                      ? const pw.BoxDecoration(color: PdfColors.grey100)
                      : null,
                  children: [
                    _pdfCell('${e.value.data}\n${e.value.hora}', small: true),
                    _pdfCell('${e.value.tipo}\n${e.value.status}',
                        small: true,
                        color: e.value.tipo == 'Receita'
                            ? PdfColors.green700
                            : PdfColors.red700),
                    _pdfCell('${e.value.setor}\n${e.value.formaPagamento}',
                        small: true),
                    _pdfCell(e.value.descricao),
                    _pdfCell(_fmtVal(e.value.valor),
                        right: true,
                        color: e.value.tipo == 'Receita'
                            ? PdfColors.green700
                            : PdfColors.red700),
                  ],
                )),
          ],
        ),
      ],
    ));

    await Printing.layoutPdf(onLayout: (_) => pdf.save());
  }

  pw.Widget _pdfHeaderVal(String label, double val, PdfColor color) =>
      pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.center, children: [
        pw.Text(label,
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
        pw.Text(_fmtVal(val),
            style: pw.TextStyle(
                fontSize: 16, fontWeight: pw.FontWeight.bold, color: color)),
      ]);

  pw.TableRow _pdfRow(List<String> cols, {bool header = false}) => pw.TableRow(
        decoration:
            header ? const pw.BoxDecoration(color: PdfColors.teal700) : null,
        children:
            cols.map((c) => _pdfCell(c, bold: header, light: header)).toList(),
      );

  pw.Widget _pdfCell(String t,
          {bool bold = false,
          bool light = false,
          bool right = false,
          bool small = false,
          PdfColor? color}) =>
      pw.Padding(
        padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: pw.Text(t,
            textAlign: right ? pw.TextAlign.right : pw.TextAlign.left,
            style: pw.TextStyle(
              fontSize: small ? 8 : 9,
              fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
              color: color ?? (light ? PdfColors.white : PdfColors.black),
            )),
      );

  // ─────────────────────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
      width: widget.width ?? double.infinity,
      height: widget.height,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.07),
              blurRadius: 20,
              offset: const Offset(0, 4))
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(children: [
          _buildHeader(),
          _buildSearchBar(),
          _buildTabBar(),
          Expanded(
            child: _loading
                ? _buildLoading()
                : _error != null
                    ? _buildError()
                    : TabBarView(
                        controller: _tabCtrl,
                        children: [_buildTableTab(), _buildSummaryTab()],
                      ),
          ),
          if (_selectMode && _selected.isNotEmpty) _buildSelectionBar(),
        ]),
      ),
    ),
    );
  }

  // ── HEADER ─────────────────────────────────────────────────────────────────
  Widget _buildHeader() => Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
        decoration: BoxDecoration(
            color: surface, border: Border(bottom: BorderSide(color: border))),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10)),
            child: Icon(Icons.bar_chart_rounded, color: primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Financeiro',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: textMain)),
              Text('HPS Refrigeração',
                  style: TextStyle(fontSize: 11, color: textSub)),
            ]),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
                color: primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20)),
            child: Text('${_filtered.length} reg.',
                style: TextStyle(
                    fontSize: 11, color: primary, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 2),
          IconButton(
            icon: Icon(Icons.tune_rounded,
                color: _hasFilters ? primary : textSub),
            tooltip: 'Filtros',
            onPressed: _showFilters,
          ),
          IconButton(
            icon: Icon(Icons.picture_as_pdf_rounded, color: primary),
            tooltip: 'Exportar PDF',
            onPressed: _exportPdf,
          ),
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: textSub),
            tooltip: 'Atualizar',
            onPressed: _loadData,
          ),
          IconButton(
            icon: Icon(
                _selectMode
                    ? Icons.check_box_rounded
                    : Icons.check_box_outline_blank_rounded,
                color: _selectMode ? primary : textSub),
            tooltip: _selectMode ? 'Cancelar seleção' : 'Selecionar vários',
            onPressed: () => setState(() {
              _selectMode = !_selectMode;
              _selected.clear();
            }),
          ),
        ]),
      );

  // ── SEARCH ─────────────────────────────────────────────────────────────────
  Widget _buildSearchBar() => Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        color: surface,
        child: TextField(
          controller: _searchCtrl,
          onChanged: (v) => setState(() => _searchQuery = v),
          style: TextStyle(fontSize: 14, color: textMain),
          decoration: InputDecoration(
            hintText: 'Pesquisar por descrição, quem, setor ou pgto...',
            hintStyle: TextStyle(fontSize: 13, color: textSub),
            prefixIcon: Icon(Icons.search_rounded, color: textSub, size: 20),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.clear_rounded, color: textSub, size: 18),
                    onPressed: () {
                      _searchCtrl.clear();
                      setState(() => _searchQuery = '');
                    })
                : null,
            filled: true,
            fillColor: bg,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            isDense: true,
          ),
        ),
      );

  // ── TAB BAR ────────────────────────────────────────────────────────────────
  Widget _buildTabBar() => Container(
        color: surface,
        child: TabBar(
          controller: _tabCtrl,
          labelColor: primary,
          unselectedLabelColor: textSub,
          indicatorColor: primary,
          indicatorWeight: 2,
          tabs: const [
            Tab(icon: Icon(Icons.table_rows_rounded, size: 18), text: 'Tabela'),
            Tab(icon: Icon(Icons.pie_chart_rounded, size: 18), text: 'Resumo'),
          ],
        ),
      );

  // ── ABA TABELA ─────────────────────────────────────────────────────────────
  Widget _buildTableTab() {
    final records = _filtered;
    if (records.isEmpty) return _buildEmpty();

    return Column(children: [
      // Cabeçalho ordenável
      Container(
        color: surface2,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(children: [
          if (_selectMode)
            SizedBox(
              width: 36,
              child: Checkbox(
                value:
                    _selected.isNotEmpty && _selected.length == records.length,
                tristate:
                    _selected.isNotEmpty && _selected.length < records.length,
                onChanged: (v) => setState(() => v == true
                    ? _selected.addAll(records.map((r) => r.docId))
                    : _selected.clear()),
                activeColor: primary,
              ),
            ),
          _sortHeader('Data', 'criadoEm', flex: 16),
          _sortHeader('Tipo/Status', 'tipo', flex: 16),
          _sortHeader('Setor/Pgto', 'setor', flex: 20),
          Expanded(
              flex: 22,
              child: Text('Descrição/Quem',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: textSub))),
          _sortHeader('Valor', 'valor', flex: 16, right: true),
          const SizedBox(width: 68),
        ]),
      ),
      Divider(height: 1, color: border),

      Expanded(
        child: ListView.separated(
          itemCount: records.length,
          separatorBuilder: (_, __) => Divider(height: 1, color: border),
          itemBuilder: (ctx, i) => _buildRow(records[i], i),
        ),
      ),

      // Rodapé total (Saldo)
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
            color: surface, border: Border(top: BorderSide(color: border))),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Saldo Atual',
              style: TextStyle(
                  fontSize: 12, color: textSub, fontWeight: FontWeight.bold)),
          Text(_fmtVal(_saldo),
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _saldo >= 0 ? primary : danger)),
        ]),
      ),
    ]);
  }

  Widget _sortHeader(String label, String field,
      {int flex = 1, bool right = false}) {
    final active = _sortField == field;
    return Expanded(
      flex: flex,
      child: GestureDetector(
        onTap: () => setState(() =>
            _sortField == field ? _sortAsc = !_sortAsc : _sortField = field),
        child: Row(
          mainAxisAlignment:
              right ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: active ? primary : textSub)),
            if (active)
              Icon(
                  _sortAsc
                      ? Icons.arrow_upward_rounded
                      : Icons.arrow_downward_rounded,
                  size: 11,
                  color: primary),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(FinanceRecord rec, int index) {
    final isSelected = _selected.contains(rec.docId);
    final isReceita = rec.tipo == 'Receita';
    final valColor = isReceita ? success : danger;

    return Dismissible(
      key: Key(rec.docId),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) =>
          _confirmDelete('Excluir "${rec.descricao}" — ${_fmtVal(rec.valor)}?'),
      onDismissed: (_) => _deleteRecord(rec),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: danger.withOpacity(0.12),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.delete_rounded, color: danger),
          const SizedBox(width: 6),
          Text('Excluir',
              style: TextStyle(color: danger, fontWeight: FontWeight.w600)),
        ]),
      ),
      child: GestureDetector(
        onTap: _selectMode
            ? () => setState(() => isSelected
                ? _selected.remove(rec.docId)
                : _selected.add(rec.docId))
            : null,
        child: Container(
          color: isSelected
              ? primary.withOpacity(0.08)
              : index.isEven
                  ? surface
                  : surface2,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
            if (_selectMode)
              SizedBox(
                width: 36,
                child: Checkbox(
                  value: isSelected,
                  onChanged: (v) => setState(() => v == true
                      ? _selected.add(rec.docId)
                      : _selected.remove(rec.docId)),
                  activeColor: primary,
                  checkColor: Colors.white,
                ),
              ),

            // Data / hora
            Expanded(
              flex: 16,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(rec.data,
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: textMain)),
                    Text(rec.hora,
                        style: TextStyle(fontSize: 10, color: textSub)),
                  ]),
            ),

            // Tipo / Status
            Expanded(
              flex: 16,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                            isReceita
                                ? Icons.arrow_upward_rounded
                                : Icons.arrow_downward_rounded,
                            size: 12,
                            color: valColor),
                        const SizedBox(width: 4),
                        Text(rec.tipo,
                            style: TextStyle(
                                fontSize: 11,
                                color: valColor,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(rec.status,
                        style: TextStyle(
                            fontSize: 10,
                            color: rec.status == 'Pago' ? primary : warning)),
                  ]),
            ),

            // Setor / Forma Pgto
            Expanded(
              flex: 20,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                          color: _sectorColor(rec.setor).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12)),
                      child: Text(rec.setor,
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: _sectorColor(rec.setor)),
                          overflow: TextOverflow.ellipsis),
                    ),
                    const SizedBox(height: 4),
                    Text(rec.formaPagamento,
                        style: TextStyle(fontSize: 10, color: textSub)),
                  ]),
            ),

            // Descrição / Quem
            Expanded(
              flex: 22,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(rec.descricao,
                        style: TextStyle(fontSize: 12, color: textMain),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(Icons.person_rounded, size: 10, color: textSub),
                        const SizedBox(width: 4),
                        Expanded(
                            child: Text(rec.quem,
                                style: TextStyle(fontSize: 10, color: textSub),
                                overflow: TextOverflow.ellipsis)),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Valor
            Expanded(
              flex: 16,
              child: Text(_fmtVal(rec.valor),
                  textAlign: TextAlign.right,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: valColor)),
            ),

            // Botões
            if (!_selectMode)
              Row(mainAxisSize: MainAxisSize.min, children: [
                const SizedBox(width: 6),
                _actionBtn(
                    icon: Icons.edit_rounded,
                    color: Colors.blueAccent,
                    tooltip: 'Editar',
                    onTap: () => _showEditDialog(rec)),
                _actionBtn(
                    icon: Icons.delete_rounded,
                    color: danger,
                    tooltip: 'Excluir',
                    onTap: () async {
                      if (await _confirmDelete('Excluir "${rec.descricao}"?'))
                        _deleteRecord(rec);
                    }),
              ]),
          ]),
        ),
      ),
    );
  }

  Widget _actionBtn(
          {required IconData icon,
          required Color color,
          required String tooltip,
          required VoidCallback onTap}) =>
      Tooltip(
        message: tooltip,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
              padding: const EdgeInsets.all(6),
              child: Icon(icon, size: 17, color: color)),
        ),
      );

  // ── ABA RESUMO ─────────────────────────────────────────────────────────────
  Widget _buildSummaryTab() {
    if (_filtered.isEmpty) return _buildEmpty();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Cards Principais
        Row(children: [
          Expanded(
              child: _summaryCard(
                  label: 'Receitas',
                  value: _fmtVal(_totalReceitas),
                  icon: Icons.arrow_upward_rounded,
                  color: success)),
          const SizedBox(width: 12),
          Expanded(
              child: _summaryCard(
                  label: 'Despesas',
                  value: _fmtVal(_totalDespesas),
                  icon: Icons.arrow_downward_rounded,
                  color: danger)),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
              child: _summaryCard(
                  label: 'Saldo',
                  value: _fmtVal(_saldo),
                  icon: Icons.account_balance_wallet_rounded,
                  color: _saldo >= 0 ? primary : danger)),
          const SizedBox(width: 12),
          Expanded(
              child: _summaryCard(
                  label: 'Lançamentos',
                  value: '${_filtered.length}',
                  icon: Icons.receipt_long_rounded,
                  color: Colors.blueAccent)),
        ]),
        const SizedBox(height: 24),

        Text('Despesas por Setor',
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.bold, color: textMain)),
        const SizedBox(height: 12),
        ..._bySector.entries.map((e) {
          final pct = _totalDespesas > 0 ? e.value / _totalDespesas : 0.0;
          final color = _sectorColor(e.key);
          final count = _filtered
              .where((r) => r.setor == e.key && r.tipo == 'Despesa')
              .length;
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(
                    width: 10,
                    height: 10,
                    decoration:
                        BoxDecoration(color: color, shape: BoxShape.circle)),
                const SizedBox(width: 8),
                Expanded(
                    child: Text(e.key,
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: textMain))),
                Text('$count reg.',
                    style: TextStyle(fontSize: 11, color: textSub)),
                const SizedBox(width: 10),
                Text(_fmtVal(e.value),
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: color)),
                const SizedBox(width: 8),
                Text('${(pct * 100).toStringAsFixed(1)}%',
                    style: TextStyle(fontSize: 11, color: textSub)),
              ]),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                    value: pct,
                    backgroundColor: color.withOpacity(0.12),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    minHeight: 7),
              ),
            ]),
          );
        }),

        const SizedBox(height: 24),
        Text('Movimentação por Pessoa',
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.bold, color: textMain)),
        const SizedBox(height: 12),
        ..._byPerson.entries.map((e) {
          final totalGeral = _totalReceitas + _totalDespesas;
          final pct = totalGeral > 0 ? e.value / totalGeral : 0.0;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: primary.withOpacity(0.12),
                child: Text(e.key.isNotEmpty ? e.key[0].toUpperCase() : '?',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: primary)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(e.key,
                          style: TextStyle(fontSize: 13, color: textMain)),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                            value: pct,
                            backgroundColor: primary.withOpacity(0.1),
                            valueColor: AlwaysStoppedAnimation<Color>(primary),
                            minHeight: 4),
                      ),
                    ]),
              ),
              const SizedBox(width: 12),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(_fmtVal(e.value),
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: textMain)),
                Text('${(pct * 100).toStringAsFixed(1)}%',
                    style: TextStyle(fontSize: 10, color: textSub)),
              ]),
            ]),
          );
        }),
        const SizedBox(height: 16),
      ]),
    );
  }

  Widget _summaryCard(
          {required String label,
          required String value,
          required IconData icon,
          required Color color}) =>
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: border)),
        child: Row(children: [
          Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 18)),
          const SizedBox(width: 10),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label, style: TextStyle(fontSize: 10, color: textSub)),
              const SizedBox(height: 2),
              Text(value,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: textMain),
                  overflow: TextOverflow.ellipsis),
            ]),
          ),
        ]),
      );

  // ── BARRA SELEÇÃO EM LOTE ──────────────────────────────────────────────────
  Widget _buildSelectionBar() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
            color: danger.withOpacity(0.08),
            border: Border(top: BorderSide(color: danger.withOpacity(0.3)))),
        child: Row(children: [
          Icon(Icons.check_circle_rounded, color: danger, size: 20),
          const SizedBox(width: 10),
          Expanded(
              child: Text('${_selected.length} selecionado(s)',
                  style:
                      TextStyle(fontWeight: FontWeight.w600, color: danger))),
          TextButton(
              onPressed: () => setState(() => _selected.clear()),
              child: Text('Limpar', style: TextStyle(color: textSub))),
          ElevatedButton.icon(
            onPressed: () async {
              if (await _confirmDelete(
                  'Excluir ${_selected.length} lançamento(s)?'))
                _deleteSelected();
            },
            icon:
                const Icon(Icons.delete_rounded, size: 16, color: Colors.white),
            label: const Text('Excluir', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
                backgroundColor: danger,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10)),
          ),
        ]),
      );

  // ── FILTROS BOTTOM SHEET ───────────────────────────────────────────────────
  void _showFilters() {
    DateTime? tmpStart = _dateStart;
    DateTime? tmpEnd = _dateEnd;
    String tmpSetor = _filterSetor;
    String tmpQuem = _filterQuem;
    String tmpTipo = _filterTipo;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: bg,
      isDismissible: true,
      enableDrag: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSt) => DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.75,
          maxChildSize: 0.92,
          shouldCloseOnMinExtent: true,
          builder: (_, sc) => SingleChildScrollView(
            controller: sc,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Center(
                  child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                          color: border,
                          borderRadius: BorderRadius.circular(2)))),

              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('Filtros',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textMain)),
                TextButton(
                  onPressed: () {
                    setSt(() {
                      tmpSetor = 'Todos';
                      tmpQuem = 'Todos';
                      tmpTipo = 'Todos';
                      tmpStart = null;
                      tmpEnd = null;
                    });
                    setState(() {
                      _filterSetor = 'Todos';
                      _filterQuem = 'Todos';
                      _filterTipo = 'Todos';
                      _dateStart = null;
                      _dateEnd = null;
                    });
                    Navigator.pop(ctx);
                  },
                  child: Text('Limpar tudo', style: TextStyle(color: danger)),
                ),
              ]),
              const SizedBox(height: 12),

              // Tipo
              Text('Tipo',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: textMain)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ['Todos', ...kTipos].map((t) {
                  final sel = tmpTipo == t;
                  return FilterChip(
                    label: Text(t,
                        style: TextStyle(
                            fontSize: 12, color: sel ? primary : textMain)),
                    backgroundColor: surface,
                    selected: sel,
                    onSelected: (v) => setSt(() => tmpTipo = v ? t : 'Todos'),
                    selectedColor: primary.withOpacity(0.2),
                    checkmarkColor: primary,
                    side: BorderSide(color: sel ? primary : border),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Setor
              Text('Setor',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: textMain)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: kSetores.map((s) {
                  final sel = tmpSetor == s;
                  return FilterChip(
                    label: Text(s,
                        style: TextStyle(
                            fontSize: 12, color: sel ? primary : textMain)),
                    backgroundColor: surface,
                    selected: sel,
                    onSelected: (v) => setSt(() => tmpSetor = v ? s : 'Todos'),
                    selectedColor: primary.withOpacity(0.2),
                    checkmarkColor: primary,
                    side: BorderSide(color: sel ? primary : border),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Pessoa
              Text('Pessoa',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: textMain)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _quemList.map((q) {
                  final sel = tmpQuem == q;
                  return FilterChip(
                    label: Text(q,
                        style: TextStyle(
                            fontSize: 12, color: sel ? primary : textMain)),
                    backgroundColor: surface,
                    selected: sel,
                    onSelected: (v) => setSt(() => tmpQuem = v ? q : 'Todos'),
                    selectedColor: primary.withOpacity(0.2),
                    checkmarkColor: primary,
                    side: BorderSide(color: sel ? primary : border),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Período — data início
              Text('Período',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: textMain)),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(
                  child: _datePicker(
                    label: 'De',
                    value: tmpStart,
                    onPicked: (d) => setSt(() => tmpStart = d),
                    ctx: ctx,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _datePicker(
                    label: 'Até',
                    value: tmpEnd,
                    onPicked: (d) => setSt(() => tmpEnd = d),
                    ctx: ctx,
                    firstDate: tmpStart,
                  ),
                ),
              ]),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _filterSetor = tmpSetor;
                      _filterQuem = tmpQuem;
                      _filterTipo = tmpTipo;
                      _dateStart = tmpStart;
                      _dateEnd = tmpEnd;
                    });
                    Navigator.pop(ctx);
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12))),
                  child: const Text('Aplicar Filtros',
                      style: TextStyle(
                          fontWeight: FontWeight.w600, color: Colors.white)),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _datePicker({
    required String label,
    required DateTime? value,
    required Function(DateTime?) onPicked,
    required BuildContext ctx,
    DateTime? firstDate,
  }) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: ctx,
          initialDate: value ?? DateTime.now(),
          firstDate: firstDate ?? DateTime(2020),
          lastDate: DateTime.now(),
          builder: (c, child) => Theme(
            data: Theme.of(context).copyWith(
                colorScheme: isDark
                    ? const ColorScheme.dark(
                        primary: Color(0xFF0D9488),
                        onPrimary: Colors.white,
                        surface: Color(0xFF1E1E1E),
                        onSurface: Colors.white)
                    : const ColorScheme.light(
                        primary: Color(0xFF0D9488), onPrimary: Colors.white)),
            child: child!,
          ),
        );
        if (picked != null) onPicked(picked);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
            border: Border.all(color: value != null ? primary : border),
            borderRadius: BorderRadius.circular(12),
            color: value != null ? primary.withOpacity(0.06) : surface),
        child: Row(children: [
          Icon(Icons.calendar_today_rounded,
              size: 16, color: value != null ? primary : textSub),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value != null ? _fmtDate(value) : label,
              style: TextStyle(
                  fontSize: 13, color: value != null ? primary : textSub),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (value != null)
            GestureDetector(
              onTap: () => onPicked(null),
              child: Icon(Icons.close_rounded, size: 14, color: textSub),
            ),
        ]),
      ),
    );
  }

  // ── ESTADOS ────────────────────────────────────────────────────────────────
  Widget _buildLoading() => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          CircularProgressIndicator(color: primary, strokeWidth: 2),
          const SizedBox(height: 14),
          Text('Carregando dados...', style: TextStyle(color: textSub)),
        ]),
      );

  Widget _buildError() => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.cloud_off_rounded, color: danger, size: 48),
            const SizedBox(height: 12),
            Text('Erro ao carregar dados',
                style: TextStyle(fontWeight: FontWeight.bold, color: textMain)),
            const SizedBox(height: 6),
            Text(_error ?? '',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: textSub)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh_rounded, color: Colors.white),
              label: const Text('Tentar novamente',
                  style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(backgroundColor: primary),
            ),
          ]),
        ),
      );

  Widget _buildEmpty() => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.inbox_rounded, color: textSub.withOpacity(0.4), size: 52),
          const SizedBox(height: 12),
          Text('Nenhum lançamento encontrado.',
              style: TextStyle(color: textSub, fontSize: 14)),
          if (_hasFilters)
            TextButton(
              onPressed: () => setState(() {
                _filterSetor = 'Todos';
                _filterQuem = 'Todos';
                _filterTipo = 'Todos';
                _dateStart = null;
                _dateEnd = null;
                _searchQuery = '';
                _searchCtrl.clear();
              }),
              child: Text('Limpar filtros', style: TextStyle(color: primary)),
            ),
        ]),
      );
}
