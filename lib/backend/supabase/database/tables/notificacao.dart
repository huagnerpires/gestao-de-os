import '../database.dart';

class NotificacaoTable extends SupabaseTable<NotificacaoRow> {
  @override
  String get tableName => 'Notificacao';

  @override
  NotificacaoRow createRow(Map<String, dynamic> data) => NotificacaoRow(data);
}

class NotificacaoRow extends SupabaseDataRow {
  NotificacaoRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => NotificacaoTable();

  int get id => getField<int>('id')!;
  set id(int value) => setField<int>('id', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  String? get titulo => getField<String>('titulo');
  set titulo(String? value) => setField<String>('titulo', value);

  String? get mensagem => getField<String>('mensagem');
  set mensagem(String? value) => setField<String>('mensagem', value);

  int? get patrimonio => getField<int>('patrimonio');
  set patrimonio(int? value) => setField<int>('patrimonio', value);

  bool? get visto => getField<bool>('visto');
  set visto(bool? value) => setField<bool>('visto', value);

  String? get email => getField<String>('email');
  set email(String? value) => setField<String>('email', value);

  DateTime? get dataField => getField<DateTime>('data');
  set dataField(DateTime? value) => setField<DateTime>('data', value);

  String? get mes => getField<String>('mes');
  set mes(String? value) => setField<String>('mes', value);

  int? get ano => getField<int>('ano');
  set ano(int? value) => setField<int>('ano', value);

  String? get tipo => getField<String>('tipo');
  set tipo(String? value) => setField<String>('tipo', value);

  DateTime? get dataProduto => getField<DateTime>('data_produto');
  set dataProduto(DateTime? value) => setField<DateTime>('data_produto', value);

  String? get os => getField<String>('os');
  set os(String? value) => setField<String>('os', value);

  String? get status => getField<String>('status');
  set status(String? value) => setField<String>('status', value);
}
