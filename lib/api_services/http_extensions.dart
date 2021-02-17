import 'dart:async';
import 'dart:convert';
import 'dart:io';

extension HttpClientRequestMethod on HttpClientRequest {
  Future<ResponsePair> send() async {
    final response = await close();
    final body = await response.getBody();
    if (response.statusCode >= 500) {
      throw ServiceError(body ?? '伺服器錯誤，請稍候再試');
    }
    return ResponsePair(response, body);
  }
}

class ResponsePair {
  final HttpClientResponse response;
  final dynamic body;
  ResponsePair(this.response, this.body);
}

extension HttpClientResponseMethod on HttpClientResponse {
  Future<dynamic> getBody() {
    final completer = Completer();
    final buf = StringBuffer();
    this.transform(utf8.decoder).listen(buf.write, onDone: () {
      if (buf.isEmpty) {
        return completer.complete(null);
      }
      final contentType = this.headers.contentType;
      if (contentType.mimeType == ContentType.json.mimeType) {        
        try {
          return completer.complete(jsonDecode(buf.toString()));
        } catch (error) {
          return completer.completeError(error);
        }
      } else if (contentType == ContentType.text ||
          contentType == ContentType.html) {
        return completer.complete(buf.toString());
      } else {
        return completer.complete(buf);
      }
    });
    return completer.future;
  }
}

class ServiceError extends Error {
  final dynamic info;
  ServiceError(this.info);
}
