
import 'dart:convert';

import 'package:edc_studio/api/models/connector.dart';
import 'package:edc_studio/api/utils/api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EdcService {
  final MyApi _api = MyApi();

  /// Create a new EDC connector
  Future<String?> createConnector(Connector data) async {
    try {
      await _api.client.post(Uri.parse(ApiRoutes.edc), body: jsonEncode(data.toJson()));
      return null;
    } catch (e) {
      print(e);
      return e.toString();
    }
  }

  /// Start an existing EDC connector by ID
  Future<String?> startConnector(String id) async {
    try {
      final path = '${ApiRoutes.edc}/$id/start';
      await _api.client.post(Uri.parse(path), body: {});
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  /// Stop an existing EDC connector by ID
  Future<String?> stopConnector(String id) async {
    try {
      final path = '${ApiRoutes.edc}/$id/stop';
      await _api.client.post(Uri.parse(path), body: {});
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  /// Get all EDC connectors
  Future<List<Connector>?> getAllConnectors() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      final response = await _api.client.get(Uri.parse(ApiRoutes.edc),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      final data = jsonDecode(response.body);
      return (data as List)
          .map((json) => Connector.fromJson(json))
          .toList();
    } catch (e) {
      return null;
    }
  }

  /// Get EDC by id
  Future<Connector?> getConnectorByID(String id) async {
    try {
      final response = await _api.client.get(Uri.parse('${ApiRoutes.edc}/$id'));
      final data = jsonDecode(response.body);
      return Connector.fromJson(data);
    } catch (e) {
      return null;
    }
  }

  /// Update EDC by id
  Future<bool> updateConnectorByID(String id, Connector connector) async {
    try {
      await _api.client.put(Uri.parse('${ApiRoutes.edc}/$id'), body: jsonEncode(connector.toJson()));
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Delete EDC by id
  Future<bool> deleteConnectorByID(String id) async {
    try {
      final response = await _api.client.delete(Uri.parse('${ApiRoutes.edc}/$id'));
      if (response.statusCode != 200) {
        return false;
      }
      return true;
    } catch (e) {
      return false;
    }
  }
}