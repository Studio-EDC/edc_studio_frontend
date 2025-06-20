
import 'package:edc_studio/api/models/asset.dart';
import 'package:edc_studio/api/utils/api.dart';
import 'package:edc_studio/api/utils/communication_service.dart';
import 'package:edc_studio/api/utils/handle_message.dart';

class AssetService {
  final CommunicationService _api = CommunicationService(base: EndpointsApi.localBase);

  /// Create a new asset
  Future<String?> createAsset(Asset asset) async {
    try {
      await _api.post(ApiRoutes.assets, asset.toJson());
      return null;
    } on Exception catch (e) {
      return extractEdcErrorMessage(e);
    }
  }

  /// Get asset by ID
  Future<Object> getAssetByAssetId(String edcId, String assetId) async {
    try {
      final response = await _api.get('${ApiRoutes.assets}/by-asset-id/$edcId/$assetId');
      return Asset.fromJson(response);
    } on Exception catch (e) {
      return extractEdcErrorMessage(e);
    }
  }

  /// Update asset by ID
  Future<String?> updateAsset(String edcId, Asset asset) async {
    try {
      await _api.put('${ApiRoutes.assets}/$edcId', asset.toJson());
      return null;
    } on Exception catch (e) {
      return extractEdcErrorMessage(e);
    }
  }

  /// Delete asset by ID
  Future<String?> deleteAsset(String assetId, String edcId) async {
    try {
      await _api.delete('${ApiRoutes.assets}/$assetId/$edcId');
      return null; 
    } on Exception catch (e) {
      return extractEdcErrorMessage(e);
    }
  }

  /// Get assets by EDC ID
  Future<Object> getAssetsByEdcId(String edcId) async {
    try {
      final response = await _api.get('${ApiRoutes.assets}/by-edc/$edcId');
      return (response as List)
          .map((json) => Asset.fromJson(json))
          .toList();
    } on Exception catch (e) {
      return extractEdcErrorMessage(e);
    }
  }
}
