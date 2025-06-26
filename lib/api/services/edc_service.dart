
import 'package:edc_studio/api/models/connector.dart';
import 'package:edc_studio/api/utils/api.dart';
import 'package:edc_studio/api/utils/communication_service.dart';

class EdcService {
  final CommunicationService _api = CommunicationService(base: EndpointsApi.localBase);

  /// Create a new EDC connector
  Future<String?> createConnector(Connector data) async {
    try {
      final result = await _api.post(ApiRoutes.edc, data.toJson());
      return result['id'];
    } catch (e) {
      return null;
    }
  }

  /// Start an existing EDC connector by ID
  Future<String?> startConnector(String id) async {
    try {
      final path = '${ApiRoutes.edc}/$id/start';
      await _api.post(path, {});
      return null;
    } on ApiException catch (e) {
      if (e.body is Map && e.body['detail'] is String) {
        return e.body['detail'];
      }
      return '';
    }
  }

  /// Stop an existing EDC connector by ID
  Future<String?> stopConnector(String id) async {
    try {
      final path = '${ApiRoutes.edc}/$id/stop';
      await _api.post(path, {});
      return null;
    } on ApiException catch (e) {
      if (e.body is Map && e.body['detail'] is String) {
        return e.body['detail'];
      }
      return '';
    }
  }

  /// Get all EDC connectors
  Future<List<Connector>?> getAllConnectors() async {
    try {
      final response = await _api.get(ApiRoutes.edc);
      return (response as List)
          .map((json) => Connector.fromJson(json))
          .toList();
    } catch (e) {
      return null;
    }
  }

  /// Get EDC by id
  Future<Connector?> getConnectorByID(String id) async {
    try {
      final response = await _api.get('${ApiRoutes.edc}/$id');
      return Connector.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  /// Update EDC by id
  Future<bool> updateConnectorByID(String id, Connector connector) async {
    try {
      await _api.put('${ApiRoutes.edc}/$id', connector.toJson());
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Delete EDC by id
  Future<bool> deleteConnectorByID(String id) async {
    try {
      await _api.delete('${ApiRoutes.edc}/$id');
      return true;
    } catch (e) {
      return false;
    }
  }
}