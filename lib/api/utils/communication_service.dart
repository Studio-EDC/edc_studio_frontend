import 'dart:convert';
import 'package:http/http.dart' as http;

class CommunicationService {
  final String base = 'http://127.0.0.1:8000';

  Future<dynamic> get(String path) async {
    final response = await http.get(Uri.parse('$base$path'));
    return _handleResponse(response);
  }

  Future<dynamic> post(String path, Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$base$path'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    return _handleResponse(response);
  }

  Future<dynamic> put(String path, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$base$path'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    return _handleResponse(response);
  }

  Future<dynamic> delete(String path) async {
    final response = await http.delete(Uri.parse('$base$path'));
    return _handleResponse(response);
  }

  dynamic _handleResponse(http.Response response) {
    final body = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    } else {
      throw Exception('Error ${response.statusCode}: $body');
    }
  }
}