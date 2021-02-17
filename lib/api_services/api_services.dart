import 'dart:convert';
import 'dart:io';

import 'package:where_gym/api_services/http_extensions.dart';

final apiBaseUrl = 'https://us-central1-where-gym.cloudfunctions.net/api';

class APIServices {
  static final instances = APIServices(baseUrl: apiBaseUrl);
  APIServices({this.baseUrl});
  final String baseUrl;
  final httpClient = HttpClient();

  Future<ResponsePair> get(String path,
      {Map<String, dynamic> params, String token}) async {
    // ignore: close_sinks
    final request = await httpClient.getUrl(_makeUri(path, params: params));
    if (token != null) {
      request.headers.set('Authorization', 'Bearer $token');
    }
    return request.send();
  }

  Uri _makeUri(String path, {Map<String, dynamic> params}) {
    final uri = Uri.parse(baseUrl + path);
    if (params == null || params.isEmpty) {
      return uri;
    }
    return Uri(
        scheme: uri.scheme,
        host: uri.host,
        path: uri.path,
        port: uri.port,
        queryParameters: params);
  }

  Future<ResponsePair> post(String path, {dynamic body, String token}) async {
    return _postOrPutRequest(
      await httpClient.postUrl(_makeUri(path)),
      body: body,
      token: token,
    );
  }

  Future<ResponsePair> put(String path, {dynamic body, String token}) async {
    return _postOrPutRequest(
      await httpClient.putUrl(_makeUri(path)),
      body: body,
      token: token,
    );
  }

  Future<ResponsePair> _postOrPutRequest(HttpClientRequest request,
      {dynamic body, String token}) async {
    if (token != null) {
      request.headers.set('Authorization', token);
    }
    if (body != null && body.isNotEmpty) {
      request.headers.set('Content-Type', 'application/json');
      request.add(utf8.encode(json.encode(body)));
    }
    return request.send();
  }
}
