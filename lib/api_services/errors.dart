import 'dart:convert';

import 'package:http/http.dart' as http;

abstract class ErrorDisplayable {
  String get message;
}

class ClientError extends Error implements ErrorDisplayable {
  final String message;
  ClientError(this.message);
}

extension ClientErrorMethods on ClientError {
  static ClientError fromErrorResponse(http.Response response) {
    if (response.body == null) {
      return ClientError('未知的錯誤，請嘗試更新版本後再試');
    }
    final String contentType = response.headers['content-type'];
    if (response.body is String &&
        (contentType == null || contentType.contains('text'))) {
      return ClientError(response.body);
    }
    try {
      if (contentType.contains('application/json')) {
        final errorMap = jsonDecode(response.body);
        return ClientError(errorMap['message'] ?? response.body);
      }
      return response.body is String
          ? ClientError(response.body)
          : ClientError('未知的錯誤，請嘗試更新版本後再試');
    } catch (e, stack) {
      print(e);
      print(stack);
      return ClientError('未知的錯誤，請嘗試更新版本後再試');
    }
  }
}
