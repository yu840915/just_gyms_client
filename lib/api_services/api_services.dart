import 'dart:convert';
import 'package:http/http.dart' as http;

// final apiBaseUrl = 'http://localhost:5001/where-gym/us-central1/api';

final apiBaseUrl = 'https://us-central1-where-gym.cloudfunctions.net/api';

class APIServices {
  static final instances = APIServices(baseUrl: apiBaseUrl);
  APIServices({this.baseUrl});
  final String baseUrl;
  final httpClient = http.Client();

  Future<http.Response> get(String path,
      {Map<String, dynamic> params, String token}) async {
    final headers = Map<String, String>();
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    final response =
        await httpClient.get(_makeUri(path, params: params), headers: headers);
    _checkResponse(response);
    return response;
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

  Future<http.Response> post(String path, {dynamic body, String token}) async {
    final headers = Map<String, String>();
    dynamic postBody = body;
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    if (body is Map<String, dynamic>) {
      postBody = jsonEncode(body);
      headers['Content-Type'] = 'application/json; charset=UTF-8';
    }
    final response = await httpClient.post(
      _makeUri(path),
      headers: headers,
      body: postBody,
    );
    _checkResponse(response);
    return response;
  }

  Future<http.Response> put(String path, {dynamic body, String token}) async {
    final headers = Map<String, String>();
    dynamic putBody = body;
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    if (body is Map<String, dynamic>) {
      putBody = jsonEncode(body);
      headers['Content-Type'] = 'application/json; charset=UTF-8';
    }
    final response = await httpClient.put(
      _makeUri(path),
      headers: headers,
      body: putBody,
    );
    _checkResponse(response);
    return response;
  }

  void _checkResponse(http.Response response) {
    if (response.statusCode >= 500) {
      throw ServiceError(response.body ?? '伺服器錯誤，請稍候再試');
    }
  }
}

class ServiceError extends Error {
  final dynamic info;
  ServiceError(this.info);
}
