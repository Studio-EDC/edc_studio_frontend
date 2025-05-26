
import 'package:edc_studio/api/models/connector.dart';
import 'package:edc_studio/api/utils/api.dart';
import 'package:edc_studio/api/utils/communication_service.dart';

class EdcService {
  final CommunicationService _api = CommunicationService();

  /// Create a new EDC connector
  Future<String> createConnector(Connector data) async {
    final result = await _api.post(ApiRoutes.edc, data.toJson());
    return result['id'];
  }

  /// Start an existing EDC connector by ID
  Future<void> startConnector(String id) async {
    final path = '${ApiRoutes.edc}/$id/start';
    await _api.post(path, {});
  }

  /// Stop an existing EDC connector by ID
  Future<void> stopConnector(String id) async {
    final path = '${ApiRoutes.edc}/$id/stop';
    await _api.post(path, {});
  }

  /// Get all EDC connectors
  Future<List<Connector>> getAllConnectors() async {
    final response = await _api.get(ApiRoutes.edc);
    return (response as List)
        .map((json) => Connector.fromJson(json))
        .toList();
  }
}