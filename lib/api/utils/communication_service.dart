import 'dart:convert';
import 'package:http/http.dart' as http;

class CommunicationService {
  final String base;

  CommunicationService({required this.base});

  Future<dynamic> get(String path, {Map<String, String>? headers}) async {
    final mergedHeaders = {...?headers};
    final response = await http.get(
      Uri.parse('$base$path'),
      headers: mergedHeaders,
    );
    return _handleResponse(response);
  }

  Future<dynamic> post(
    String path,
    Map<String, dynamic> data, {
    Map<String, String>? headers,
    bool asFormUrlEncoded = false,
  }) async {
    Map<String, String> mergedHeaders;
    Object body;

    if (asFormUrlEncoded) {
      mergedHeaders = {'Content-Type': 'application/x-www-form-urlencoded', ...?headers};
      body = data.map((key, value) => MapEntry(key, value.toString()));
    } else {
      mergedHeaders = {'Content-Type': 'application/json', ...?headers};
      body = jsonEncode(data);
    }

    final response = await http.post(
      Uri.parse('$base$path'),
      headers: mergedHeaders,
      body: body,
    );

    return _handleResponse(response);
  }

  Future<dynamic> put(String path, Map<String, dynamic> data, {Map<String, String>? headers}) async {
    final defaultHeaders = {'Content-Type': 'application/json'};
    final mergedHeaders = {...defaultHeaders, ...?headers};

    final response = await http.put(
      Uri.parse('$base$path'),
      headers: mergedHeaders,
      body: jsonEncode(data),
    );
    return _handleResponse(response);
  }

  Future<dynamic> delete(String path, {Map<String, String>? headers}) async {
    final mergedHeaders = {...?headers};
    final response = await http.delete(
      Uri.parse('$base$path'),
      headers: mergedHeaders,
    );
    return _handleResponse(response);
  }

  dynamic _handleResponse(http.Response response) {
    try {
      final body = jsonDecode(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return body;
      } else {
        print(response.body);
        throw ApiException(response.statusCode, body);
      }
    } catch (e) {
      throw ApiException(response.statusCode, response.body);
    }
  }
}

class ApiException implements Exception {
  final int statusCode;
  final dynamic body;

  ApiException(this.statusCode, this.body);

  @override
  String toString() {
    return 'ApiException($statusCode): $body';
  }
}