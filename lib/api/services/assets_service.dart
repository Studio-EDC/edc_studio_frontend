import 'package:edc_studio/api/models/asset.dart';
import 'package:edc_studio/api/utils/api.dart';
import 'package:edc_studio/api/utils/communication_service.dart';

class AssetService {
  final CommunicationService _api = CommunicationService();

  /// Create a new asset
  Future<String?> createAsset(Asset asset) async {
    try {
      final response = await _api.post(ApiRoutes.assets, asset.toJson());
      return response['id'];
    } catch (e) {
      return null;
    }
  }

  /// Get all assets
  Future<List<Asset>> getAllAssets() async {
    try {
      final response = await _api.get(ApiRoutes.assets);
      return (response as List)
          .map((json) => Asset.fromJson(json))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Get asset by ID
  Future<Asset?> getAssetById(String id) async {
    try {
      final response = await _api.get('${ApiRoutes.assets}/$id');
      return Asset.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  /// Get asset by ID
  Future<Asset?> getAssetByAssetId(String assetId) async {
    try {
      final response = await _api.get('${ApiRoutes.assets}/by-asset-id/$assetId');
      return Asset.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  /// Update asset by ID
  Future<bool> updateAsset(String id, Map<String, dynamic> updates) async {
    try {
      await _api.put('${ApiRoutes.assets}/$id', updates);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Delete asset by ID
  Future<bool> deleteAsset(String id) async {
    try {
      await _api.delete('${ApiRoutes.assets}/$id');
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get assets by EDC ID
  Future<List<Asset>> getAssetsByEdcId(String edcId) async {
    try {
      final response = await _api.get('${ApiRoutes.assets}/by-edc/$edcId');
      return (response as List)
          .map((json) => Asset.fromJson(json))
          .toList();
    } catch (e) {
      return [];
    }
  }
}
