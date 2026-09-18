import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/custom_code/widgets/hps_sheet.dart' show HpsCloseButton;
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/index.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'chat_lista_model.dart';
export 'chat_lista_model.dart';

class ChatListaWidget extends StatefulWidget {
  const ChatListaWidget({super.key});

  static String routeName = 'chat_lista';
  static String routePath = '/chat_lista';

  @override
  State<ChatListaWidget> createState() => _ChatListaWidgetState();
}

class _ChatListaWidgetState extends State<ChatListaWidget> {
  late ChatListaModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ChatListaModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: const Color(0xFF0B0F17),
        body: Column(
          children: [
            Material(
              color: Colors.transparent,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF131B2E),
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.white.withOpacity(0.10),
                    ),
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 12.0, 12.0, 12.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Conversas',
                            style: GoogleFonts.interTight(
                              color: Colors.white,
                              fontSize: 16.0,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.0,
                            ),
                          ),
                        ),
                        HpsCloseButton(
                          onPressed: () async {
                            final popped =
                                await Navigator.of(context).maybePop();
                            if (!popped && context.mounted) {
                              context.safePop();
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: StreamBuilder<List<ListaChatRecord>>(
                stream: queryListaChatRecord(),
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
                  List<ListaChatRecord> listViewListaChatRecordList =
                      snapshot.data!;

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(12.0, 16.0, 12.0, 16.0),
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    itemCount: listViewListaChatRecordList.length,
                    itemBuilder: (context, listViewIndex) {
                      final listViewListaChatRecord =
                          listViewListaChatRecordList[listViewIndex];
                      return InkWell(
                        splashColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () async {
                          await listViewListaChatRecord.reference
                              .update(createListaChatRecordData(
                            novaMensagem: false,
                          ));

                          context.pushNamed(
                            BatepapoWidget.routeName,
                            queryParameters: {
                              'email': serializeParam(
                                listViewListaChatRecord.email,
                                ParamType.String,
                              ),
                              'referencia': serializeParam(
                                listViewListaChatRecord.reference,
                                ParamType.DocumentReference,
                              ),
                            }.withoutNulls,
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(18.0),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(
                                sigmaX: 16.0,
                                sigmaY: 16.0,
                              ),
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color:
                                      const Color(0xFF131B2E).withOpacity(0.85),
                                  borderRadius: BorderRadius.circular(18.0),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.10),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Row(
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  StreamBuilder<List<UsuariosRecord>>(
                                    stream: queryUsuariosRecord(
                                      queryBuilder: (usuariosRecord) =>
                                          usuariosRecord.where(
                                        'email',
                                        isEqualTo:
                                            listViewListaChatRecord.email,
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
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                FlutterFlowTheme.of(context)
                                                    .primary,
                                              ),
                                            ),
                                          ),
                                        );
                                      }
                                      List<UsuariosRecord>
                                          circleImageUsuariosRecordList =
                                          snapshot.data!;
                                      // Return an empty Container when the item does not exist.
                                      if (snapshot.data!.isEmpty) {
                                        return Container();
                                      }
                                      final circleImageUsuariosRecord =
                                          circleImageUsuariosRecordList
                                                  .isNotEmpty
                                              ? circleImageUsuariosRecordList
                                                  .first
                                              : null;

                                      return Container(
                                        width: 50.0,
                                        height: 50.0,
                                        clipBehavior: Clip.antiAlias,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                        ),
                                        child: Image.network(
                                          circleImageUsuariosRecord!.photoUrl,
                                          fit: BoxFit.cover,
                                        ),
                                      );
                                    },
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          8.0, 0.0, 0.0, 0.0),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.max,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          StreamBuilder<List<UsuariosRecord>>(
                                            stream: queryUsuariosRecord(
                                              queryBuilder: (usuariosRecord) =>
                                                  usuariosRecord.where(
                                                'email',
                                                isEqualTo:
                                                    listViewListaChatRecord
                                                        .email,
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
                                                    child:
                                                        CircularProgressIndicator(
                                                      valueColor:
                                                          AlwaysStoppedAnimation<
                                                              Color>(
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .primary,
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              }
                                              List<UsuariosRecord>
                                                  textUsuariosRecordList =
                                                  snapshot.data!;
                                              // Return an empty Container when the item does not exist.
                                              if (snapshot.data!.isEmpty) {
                                                return Container();
                                              }
                                              final textUsuariosRecord =
                                                  textUsuariosRecordList
                                                          .isNotEmpty
                                                      ? textUsuariosRecordList
                                                          .first
                                                      : null;

                                              return Text(
                                                valueOrDefault<String>(
                                                  textUsuariosRecord
                                                      ?.displayName,
                                                  'nome',
                                                ),
                                                textAlign: TextAlign.start,
                                                style: GoogleFonts.interTight(
                                                  color: Colors.white,
                                                  fontSize: 16.0,
                                                  fontWeight: FontWeight.w600,
                                                  letterSpacing: 0.0,
                                                ),
                                              );
                                            },
                                          ),
                                          Padding(
                                            padding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    0.0, 4.0, 0.0, 0.0),
                                            child: Text(
                                              listViewListaChatRecord.email,
                                              textAlign: TextAlign.start,
                                              style: GoogleFonts.inter(
                                                color: const Color(0xFF94A3B8),
                                                fontSize: 14.0,
                                                letterSpacing: 0.0,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  if (listViewListaChatRecord.novaMensagem ==
                                      true)
                                    Text(
                                      '+1',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            font: GoogleFonts.inter(
                                              fontWeight:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontWeight,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontStyle,
                                            ),
                                            color: FlutterFlowTheme.of(context)
                                                .primary,
                                            fontSize: 16.0,
                                            letterSpacing: 0.0,
                                            fontWeight:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontWeight,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontStyle,
                                          ),
                                    ),
                                ],
                              ),
                            ),
                          ),
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
        ),
      ),
    );
  }
}
