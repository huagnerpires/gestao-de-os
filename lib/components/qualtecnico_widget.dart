import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'qualtecnico_model.dart';
export 'qualtecnico_model.dart';

class QualtecnicoWidget extends StatefulWidget {
  const QualtecnicoWidget({super.key});

  @override
  State<QualtecnicoWidget> createState() => _QualtecnicoWidgetState();
}

class _QualtecnicoWidgetState extends State<QualtecnicoWidget> {
  late QualtecnicoModel _model;
  Map<String, String> _fotosPorNome = {};

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => QualtecnicoModel());
    _carregarFotosTecnicos();

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
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

  Future<void> _carregarFotosTecnicos() async {
    try {
      final lista = await queryPontosPorTecnicoRecordOnce();
      final map = <String, String>{};
      for (final t in lista) {
        final nome = t.tecnico.trim();
        if (nome.isEmpty) continue;
        if (_fotoValida(t.foto)) {
          map[nome.toUpperCase()] = t.foto.trim();
        }
      }
      if (!mounted) return;
      setState(() => _fotosPorNome = map);
    } catch (_) {}
  }

  Widget _avatarTecnico(String nome) {
    final foto = _fotosPorNome[nome.trim().toUpperCase()] ?? '';
    final ini = _iniciais(nome);
    final cor = FlutterFlowTheme.of(context).primary;
    return Container(
      width: 40.0,
      height: 40.0,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: cor.withOpacity(0.12),
      ),
      clipBehavior: Clip.antiAlias,
      child: _fotoValida(foto)
          ? Image.network(
              foto,
              fit: BoxFit.cover,
              webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
              errorBuilder: (_, __, ___) => Center(
                child: Text(
                  ini,
                  style: TextStyle(
                    color: cor,
                    fontWeight: FontWeight.w700,
                    fontSize: 14.0,
                  ),
                ),
              ),
            )
          : Center(
              child: Text(
                ini,
                style: TextStyle(
                  color: cor,
                  fontWeight: FontWeight.w700,
                  fontSize: 14.0,
                ),
              ),
            ),
    );
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return Material(
      color: Colors.transparent,
      elevation: 5.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
      ),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.0),
            topRight: Radius.circular(16.0),
          ),
        ),
        child: StreamBuilder<List<ServicosrealizadosRecord>>(
          stream: queryServicosrealizadosRecord(
            queryBuilder: (servicosrealizadosRecord) =>
                servicosrealizadosRecord.where(
              'NUMERODAOS',
              isEqualTo: FFAppState().os.toString(),
            ),
            singleRecord: true,
          ),
          builder: (context, snapshot) {
            // Customize what your widget looks like when it's loading.
            if (!snapshot.hasData) {
              return Center(
                child: SizedBox(
                  width: 50.0,
                  height: 50.0,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      FlutterFlowTheme.of(context).primary,
                    ),
                  ),
                ),
              );
            }
            List<ServicosrealizadosRecord> columnServicosrealizadosRecordList =
                snapshot.data!;
            // Return an empty Container when the item does not exist.
            if (snapshot.data!.isEmpty) {
              return Container();
            }
            final columnServicosrealizadosRecord =
                columnServicosrealizadosRecordList.isNotEmpty
                    ? columnServicosrealizadosRecordList.first
                    : null;

            return Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0.0, 12.0, 0.0, 0.0),
                  child: Container(
                    width: 50.0,
                    height: 4.0,
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).primaryBackground,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
                Padding(
                  padding:
                      EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 0.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Text(
                        'Qual técnico deseja editar?',
                        style:
                            FlutterFlowTheme.of(context).headlineSmall.override(
                                  font: GoogleFonts.interTight(
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .headlineSmall
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .headlineSmall
                                        .fontStyle,
                                  ),
                                  letterSpacing: 0.0,
                                  fontWeight: FlutterFlowTheme.of(context)
                                      .headlineSmall
                                      .fontWeight,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .headlineSmall
                                      .fontStyle,
                                ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 32.0),
                  child: StreamBuilder<List<ServicosrealizadosRecord>>(
                    stream: queryServicosrealizadosRecord(
                      queryBuilder: (servicosrealizadosRecord) =>
                          servicosrealizadosRecord.where(
                        'NUMERODAOS',
                        isEqualTo: FFAppState().os.toString(),
                      ),
                    ),
                    builder: (context, snapshot) {
                      // Customize what your widget looks like when it's loading.
                      if (!snapshot.hasData) {
                        return Center(
                          child: SizedBox(
                            width: 50.0,
                            height: 50.0,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                FlutterFlowTheme.of(context).primary,
                              ),
                            ),
                          ),
                        );
                      }
                      List<ServicosrealizadosRecord>
                          listViewServicosrealizadosRecordList = snapshot.data!;

                      return ListView.builder(
                        padding: EdgeInsets.zero,
                        primary: false,
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        itemCount: listViewServicosrealizadosRecordList.length,
                        itemBuilder: (context, listViewIndex) {
                          final listViewServicosrealizadosRecord =
                              listViewServicosrealizadosRecordList[
                                  listViewIndex];
                          return Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                16.0, 12.0, 16.0, 0.0),
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context)
                                    .secondaryBackground,
                                borderRadius: BorderRadius.circular(8.0),
                                border: Border.all(
                                  color: FlutterFlowTheme.of(context).alternate,
                                  width: 2.0,
                                ),
                              ),
                              child: Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    16.0, 12.0, 8.0, 12.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Row(
                                        children: [
                                          _avatarTecnico(
                                            valueOrDefault<String>(
                                              listViewServicosrealizadosRecord
                                                  .tecnico,
                                              '0',
                                            ),
                                          ),
                                          SizedBox(width: 12.0),
                                          Expanded(
                                            child: Text(
                                              valueOrDefault<String>(
                                                listViewServicosrealizadosRecord
                                                    .tecnico,
                                                '0',
                                              ),
                                              style: FlutterFlowTheme.of(
                                                      context)
                                                  .bodyLarge
                                                  .override(
                                                    font: GoogleFonts.inter(
                                                      fontWeight:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyLarge
                                                              .fontWeight,
                                                      fontStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyLarge
                                                              .fontStyle,
                                                    ),
                                                    letterSpacing: 0.0,
                                                    fontWeight:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodyLarge
                                                            .fontWeight,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodyLarge
                                                            .fontStyle,
                                                  ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      Icons.chevron_right_rounded,
                                      color: Color(0xFF7C8791),
                                      size: 24.0,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
