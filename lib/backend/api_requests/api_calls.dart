import 'dart:convert';
import 'dart:typed_data';
import '../schema/structs/index.dart';

import 'package:flutter/foundation.dart';

import '/flutter_flow/flutter_flow_util.dart';
import 'api_manager.dart';

export 'api_manager.dart' show ApiCallResponse;

const _kPrivateApiFunctionName = 'ffPrivateApiCall';

class EnviarCall {
  static Future<ApiCallResponse> call({
    String? email = '',
    String? titulo = '',
    String? mensagem = '',
  }) async {
    final ffApiRequestBody = '''
{
  "app_id": "7b01186f-cf76-4b5d-8354-87d83737d40c",
  "filters": [
    {
      "field": "tag",
      "key": "Email",
      "relation": "=",
      "value": "${escapeStringForJson(email)}"
    }
  ],
  "headings": {
    "en": "${escapeStringForJson(titulo)}"
  },
  "contents": {
    "en": "${escapeStringForJson(mensagem)}"},
"android_channel_id": "577bba44-d1bf-4ac9-9d11-20d89e09a61a",
  "priority": 10
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'enviar',
      apiUrl: 'https://onesignal.com/api/v1/notifications',
      callType: ApiCallType.POST,
      headers: {
        'Authorization':
            'Basic ZTdlNjIwZWItMjEyMC00M2RhLWJlZmYtMzc2NTBmNzNmMDdj',
        'Content-Type': 'application/json',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class PostaimagemCall {
  static Future<ApiCallResponse> call({
    String? imagem = '',
  }) async {
    final ffApiRequestBody = '''
{
  "formData": {
    "image": "${escapeStringForJson(imagem)}"
  }
}
''';
    return ApiManager.instance.makeApiCall(
      callName: 'postaimagem',
      apiUrl:
          'https://api.imgbb.com/1/upload?expiration=600&key=69b75a9be0857deaa943296636aca90a',
      callType: ApiCallType.POST,
      headers: {},
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class BomsaldoCall {
  static Future<ApiCallResponse> call() async {
    return ApiManager.instance.makeApiCall(
      callName: 'BOMSALDO',
      apiUrl: 'https://api.beteltecnologia.com/clientes',
      callType: ApiCallType.GET,
      headers: {
        'Content-Type': 'application/json',
        'access-token': '3f9036443a128b5d5c8c6030823a20e2d3229f4a',
        'secret-access-token': '8c14c4452b87be92372c1ff063d5e1fd285096f6',
      },
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static List<String>? nomes(dynamic response) => (getJsonField(
        response,
        r'''$.data[:].nome''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  static List<String>? tipodepessoa(dynamic response) => (getJsonField(
        response,
        r'''$.data[:].tipo_pessoa''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  static List<String>? cpf(dynamic response) => (getJsonField(
        response,
        r'''$.data[:].cpf''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  static List<String>? rg(dynamic response) => (getJsonField(
        response,
        r'''$.data[:].rg''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  static List<String>? datanascimento(dynamic response) => (getJsonField(
        response,
        r'''$.data[:].data_nascimento''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  static List<String>? celular(dynamic response) => (getJsonField(
        response,
        r'''$.data[:].celular''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  static List<String>? pais(dynamic response) => (getJsonField(
        response,
        r'''$.data[:].enderecos[:].endereco.pais''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
}

class BOMSALDOPesquisarCall {
  static Future<ApiCallResponse> call({
    String? nome = '',
  }) async {
    return ApiManager.instance.makeApiCall(
      callName: 'BOMSALDO pesquisar',
      apiUrl: 'https://api.beteltecnologia.com/clientes?nome=${nome}',
      callType: ApiCallType.GET,
      headers: {
        'Content-Type': 'application/json',
        'access-token': '3f9036443a128b5d5c8c6030823a20e2d3229f4a',
        'secret-access-token': '8c14c4452b87be92372c1ff063d5e1fd285096f6',
      },
      params: {
        'nome': nome,
      },
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static List<String>? nomes(dynamic response) => (getJsonField(
        response,
        r'''$.data[:].nome''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  static List<String>? tipodepessoa(dynamic response) => (getJsonField(
        response,
        r'''$.data[:].tipo_pessoa''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  static List<String>? cpf(dynamic response) => (getJsonField(
        response,
        r'''$.data[:].cpf''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  static List<String>? rg(dynamic response) => (getJsonField(
        response,
        r'''$.data[:].rg''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  static List<String>? datanascimento(dynamic response) => (getJsonField(
        response,
        r'''$.data[:].data_nascimento''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  static List<String>? celular(dynamic response) => (getJsonField(
        response,
        r'''$.data[:].celular''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  static List<String>? pais(dynamic response) => (getJsonField(
        response,
        r'''$.data[:].enderecos[:].endereco.pais''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
}

class OsCall {
  static Future<ApiCallResponse> call() async {
    return ApiManager.instance.makeApiCall(
      callName: 'os',
      apiUrl: 'https://api.beteltecnologia.com/ordens_servicos',
      callType: ApiCallType.GET,
      headers: {
        'access-token': '3f9036443a128b5d5c8c6030823a20e2d3229f4a',
        'secret-access-token': '8c14c4452b87be92372c1ff063d5e1fd285096f6',
        'Content-Type': 'application/json',
      },
      params: {
        'nome': "OSMANO DA SILVA",
      },
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static List<String>? id(dynamic response) => (getJsonField(
        response,
        r'''$.data[:].id''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  static String? status(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.data[:].situacao_id''',
      ));
  static List<String>? clienteid(dynamic response) => (getJsonField(
        response,
        r'''$.data[:].cliente_id''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  static List<String>? tecnico(dynamic response) => (getJsonField(
        response,
        r'''$.data[:].nome_tecnico''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  static List<String>? nome(dynamic response) => (getJsonField(
        response,
        r'''$.data[:].nome_cliente''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
}

class CadastrarClientesCall {
  static Future<ApiCallResponse> call({
    String? tipoPessoa = '',
    String? nome = '',
    String? razaoSocial = '',
    String? cnpj = '',
    String? inscricaoEstadual = '',
    String? inscricaoMunicipal = '',
    String? cpf = '',
    String? rg = '',
    String? dataNascimento = '',
    String? telefone = '',
    String? celular = '',
    String? fax = '',
    String? email = '',
    String? ativo = '',
    String? contato = '',
    String? observacao = '',
    String? cargo = '',
    String? cep = '',
    String? logradouro = '',
    String? estado = '',
    String? nomeCidade = '',
    String? cidadeId = '',
    String? bairro = '',
    String? complemento = '',
    String? numero = '',
  }) async {
    final ffApiRequestBody = '''
{
  "tipo_pessoa": "${escapeStringForJson(tipoPessoa)}",
  "nome": "${escapeStringForJson(nome)}",
  "razao_social": "${escapeStringForJson(razaoSocial)}",
  "cnpj": "${escapeStringForJson(cnpj)}",
  "inscricao_estadual": "${escapeStringForJson(inscricaoEstadual)}",
  "inscricao_municipal": "${escapeStringForJson(inscricaoMunicipal)}",
  "cpf": "${escapeStringForJson(cpf)}",
  "rg": "${escapeStringForJson(rg)}",
  "data_nascimento": "${escapeStringForJson(dataNascimento)}",
  "telefone": "${escapeStringForJson(telefone)}",
  "celular": "${escapeStringForJson(celular)}",
  "fax": "${escapeStringForJson(fax)}",
  "email": "${escapeStringForJson(email)}",
  "ativo": "${escapeStringForJson(ativo)}",
  "contatos": [
    {
      "contato": {
        "nome": "${escapeStringForJson(nome)}",
        "contato": "${escapeStringForJson(contato)}",
        "cargo": "${escapeStringForJson(cargo)}",
        "observacao": "${escapeStringForJson(observacao)}"
      }
    }
  ],
  "enderecos": [
    {
      "endereco": {
        "cep": "${escapeStringForJson(cep)}",
        "logradouro": "${escapeStringForJson(logradouro)}",
        "numero": "${escapeStringForJson(numero)}",
        "complemento": "${escapeStringForJson(complemento)}",
        "bairro": "${escapeStringForJson(bairro)}",
        "cidade_id": "${escapeStringForJson(cidadeId)}",
        "nome_cidade": "${escapeStringForJson(nomeCidade)}",
        "estado": "${escapeStringForJson(estado)}"
      }
    }
  ]
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'cadastrar clientes',
      apiUrl: 'https://api.beteltecnologia.com/clientes',
      callType: ApiCallType.POST,
      headers: {
        'access-token': '3f9036443a128b5d5c8c6030823a20e2d3229f4a',
        'secret-access-token': '8c14c4452b87be92372c1ff063d5e1fd285096f6',
        'Content-Type': 'application/json',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static List<String>? id(dynamic response) => (getJsonField(
        response,
        r'''$.data[:].id''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  static String? status(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.data[:].situacao_id''',
      ));
  static List<String>? clienteid(dynamic response) => (getJsonField(
        response,
        r'''$.data[:].cliente_id''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  static List<String>? tecnico(dynamic response) => (getJsonField(
        response,
        r'''$.data[:].nome_tecnico''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  static List<String>? nome(dynamic response) => (getJsonField(
        response,
        r'''$.data[:].nome_cliente''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
}

class ZapCall {
  static Future<ApiCallResponse> call() async {
    final ffApiRequestBody = '''
{
  "messaging_product": "whatsapp",
  "recipient_type": "individual",
  "to": "5577988194630",
  "type": "text",
  "text": {
    "preview_url": false,
    "body": "ola mundo"
  }
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'zap',
      apiUrl: 'https://graph.facebook.com/v22.0/902190519646048/messages',
      callType: ApiCallType.POST,
      headers: {
        'Authorization':
            'Bearer EAAUcNns4h2sBQOZCL9VjhpokIua2Ti52kipDgO50WeuS6fK1dxnFl0u4WCbtUW4FeqruXhHR2RjTvmJFcyIVqBhlTsJb7bNUmJyd6manGtkT6DJrp5vJGwmZAKkV7ZB5Ao8qAA25MbC4sgFLLmZAijZBwZA5V1M76Cx0nZBnf5ZAKYEDIKZBIKHNYzyAwG7HLUBRi6WXeY5fvS7Ddg2B1FV2Qxe1zPJH9v1GtIqaSpZBD60EyDZArSNT5IpVQoXzovyX2Lh1DJgztYqZA1Rc0NuZCSiJl',
        'Content-Type': 'application/json',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class ExternalidCall {
  static Future<ApiCallResponse> call({
    String? externalid = '',
  }) async {
    final ffApiRequestBody = '''
{
  "identity": {
    "external_id": "${escapeStringForJson(externalid)}"
  }
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'externalid',
      apiUrl:
          'https://api.onesignal.com/apps/7b01186f-cf76-4b5d-8354-87d83737d40c/users',
      callType: ApiCallType.POST,
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class EnviaremailCall {
  static Future<ApiCallResponse> call() async {
    final ffApiRequestBody = '''
{
  "sender": {
    "name": "Hps Refrigerações",
    "email": "huagnerpsm@gmail.com"
  },
  "to": [
    {
      "email": "dani15xx15@gmail.com"
    }
  ],
  "subject": "Título do e-mail",
  "htmlContent": "<!DOCTYPE html>\\n<html lang=\\"pt-BR\\">\\n<head>\\n  <meta charset=\\"UTF-8\\">\\n  <title>Hps Refrigerações - Refrigeração</title>\\n</head>\\n<body style=\\"margin:0; padding:0; background-color:#f4f6f8; font-family: Arial, Helvetica, sans-serif;\\">\\n\\n  <table width=\\"100%\\" cellpadding=\\"0\\" cellspacing=\\"0\\" style=\\"background-color:#f4f6f8; padding:20px;\\">\\n    <tr>\\n      <td align=\\"center\\">\\n\\n        <table width=\\"600\\" cellpadding=\\"0\\" cellspacing=\\"0\\" style=\\"background-color:#ffffff; border-radius:6px; overflow:hidden;\\">\\n\\n          <tr>\\n            <td style=\\"background-color:#0b5ed7; padding:20px; text-align:center; color:#ffffff;\\">\\n              <h1 style=\\"margin:0; font-size:22px;\\">Hps Refrigerações</h1>\\n              <p style=\\"margin:5px 0 0; font-size:14px;\\">\\n                Refrigeração • Ar-Condicionado • Climatização\\n              </p>\\n            </td>\\n          </tr>\\n\\n          <tr>\\n            <td style=\\"padding:30px; color:#333333; font-size:14px; line-height:1.6;\\">\\n              \\n              <p>Olá,</p>\\n\\n              <p>\\n                Este e-mail é para informar uma atualização relacionada ao seu\\n                <strong>serviço de refrigeração / ar-condicionado</strong>.\\n              </p>\\n\\n              <p>\\n                Caso tenha solicitado manutenção, instalação ou orçamento,\\n                nossa equipe já está acompanhando sua demanda.\\n              </p>\\n\\n              <p style=\\"margin-top:20px;\\">\\n                <strong>Status do serviço:</strong><br>\\n                🔧 Em andamento\\n              </p>\\n\\n              <p style=\\"margin-top:20px;\\">\\n                Se precisar de qualquer informação adicional, é só responder este e-mail.\\n              </p>\\n\\n              <p style=\\"margin-top:30px;\\">\\n                Atenciosamente,<br>\\n                <strong>Hps Refrigerações</strong><br>\\n                Especialistas em Refrigeração\\n              </p>\\n\\n            </td>\\n          </tr>\\n\\n          <tr>\\n            <td style=\\"background-color:#f0f0f0; padding:15px; text-align:center; font-size:12px; color:#777777;\\">\\n              © 2026 Hps Refrigerações • Todos os direitos reservados<br>\\n              Manutenção e Climatização\\n            </td>\\n          </tr>\\n\\n        </table>\\n\\n      </td>\\n    </tr>\\n  </table>\\n\\n</body>\\n</html>"
}
''';
    return ApiManager.instance.makeApiCall(
      callName: 'enviaremail',
      apiUrl: 'https://api.brevo.com/v3/smtp/email',
      callType: ApiCallType.POST,
      headers: {
        'accept': 'application/json',
        'content-type': 'application/json',
        'api-key':
            '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',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class ApiPagingParams {
  int nextPageNumber = 0;
  int numItems = 0;
  dynamic lastResponse;

  ApiPagingParams({
    required this.nextPageNumber,
    required this.numItems,
    required this.lastResponse,
  });

  @override
  String toString() =>
      'PagingParams(nextPageNumber: $nextPageNumber, numItems: $numItems, lastResponse: $lastResponse,)';
}

String _toEncodable(dynamic item) {
  if (item is DocumentReference) {
    return item.path;
  }
  return item;
}

String _serializeList(List? list) {
  list ??= <String>[];
  try {
    return json.encode(list, toEncodable: _toEncodable);
  } catch (_) {
    if (kDebugMode) {
      print("List serialization failed. Returning empty list.");
    }
    return '[]';
  }
}

String _serializeJson(dynamic jsonVar, [bool isList = false]) {
  jsonVar ??= (isList ? [] : {});
  try {
    return json.encode(jsonVar, toEncodable: _toEncodable);
  } catch (_) {
    if (kDebugMode) {
      print("Json serialization failed. Returning empty json.");
    }
    return isList ? '[]' : '{}';
  }
}

String? escapeStringForJson(String? input) {
  if (input == null) {
    return null;
  }
  return input
      .replaceAll('\\', '\\\\')
      .replaceAll('"', '\\"')
      .replaceAll('\n', '\\n')
      .replaceAll('\t', '\\t');
}
