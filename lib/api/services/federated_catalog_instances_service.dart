import 'dart:convert';

import 'package:edc_studio/api/models/federated_catalog_instance.dart';
import 'package:edc_studio/api/utils/api.dart';

class FederatedCatalogInstancesService {
  final MyApi _api = MyApi();

  Future<List<FederatedCatalogInstance>> getAllInstances() async {
    try {
      final response = await _api.client.get(
        Uri.parse(ApiRoutes.federatedCatalogInstances),
      );
      if (response.statusCode != 200) {
        return [];
      }

      final data = jsonDecode(response.body) as List;
      return data
          .map((item) => FederatedCatalogInstance.fromJson(item))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<FederatedCatalogInstance?> getInstanceById(String id) async {
    try {
      final response = await _api.client.get(
        Uri.parse('${ApiRoutes.federatedCatalogInstances}/$id'),
      );
      if (response.statusCode != 200) {
        return null;
      }
      return FederatedCatalogInstance.fromJson(jsonDecode(response.body));
    } catch (_) {
      return null;
    }
  }

  Future<String?> createInstance(FederatedCatalogInstance instance) async {
    try {
      final response = await _api.client.post(
        Uri.parse(ApiRoutes.federatedCatalogInstances),
        body: jsonEncode(instance.toJson()),
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return null;
      }
      return response.body;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> updateInstance(FederatedCatalogInstance instance) async {
    try {
      final response = await _api.client.put(
        Uri.parse('${ApiRoutes.federatedCatalogInstances}/${instance.id}'),
        body: jsonEncode(instance.toJson()),
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return null;
      }
      return response.body;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> startInstance(String id) async {
    return _postAction(id, 'start');
  }

  Future<String?> stopInstance(String id) async {
    return _postAction(id, 'stop');
  }

  Future<String?> redeployInstance(String id) async {
    return _postAction(id, 'redeploy');
  }

  Future<bool> deleteInstance(String id) async {
    try {
      final response = await _api.client.delete(
        Uri.parse('${ApiRoutes.federatedCatalogInstances}/$id'),
      );
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (_) {
      return false;
    }
  }

  Future<String?> _postAction(String id, String action) async {
    try {
      final response = await _api.client.post(
        Uri.parse('${ApiRoutes.federatedCatalogInstances}/$id/$action'),
        body: jsonEncode({}),
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return null;
      }
      return response.body;
    } catch (e) {
      return e.toString();
    }
  }
}
