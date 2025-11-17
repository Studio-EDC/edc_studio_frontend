
import 'dart:convert';

import 'package:edc_studio/api/models/asset.dart';
import 'package:edc_studio/api/utils/api.dart';
import 'package:edc_studio/api/utils/handle_message.dart';

class AssetService {
  final MyApi _api = MyApi();

  /// Create a new asset
  Future<String?> createAsset(Asset asset) async {
    try {
      await _api.client.post(Uri.parse(ApiRoutes.assets), body: jsonEncode(asset.toJson()));
      return null;
    } on Exception catch (e) {
      return extractEdcErrorMessage(e);
    }
  }

  /// Get asset by ID
  Future<Object> getAssetByAssetId(String edcId, String assetId) async {
    try {
      final response = await _api.client.get(Uri.parse('${ApiRoutes.assets}/by-asset-id/$edcId/$assetId'));
      final data = jsonDecode(response.body);
      return Asset.fromJson(data);
    } on Exception catch (e) {
      return extractEdcErrorMessage(e);
    }
  }

  /// Update asset by ID
  Future<String?> updateAsset(String edcId, Asset asset) async {
    try {
      await _api.client.put(Uri.parse('${ApiRoutes.assets}/$edcId'), body: jsonEncode(asset.toJson()));
      return null;
    } on Exception catch (e) {
      return extractEdcErrorMessage(e);
    }
  }

  /// Delete asset by ID
  Future<String?> deleteAsset(String assetId, String edcId) async {
    try {
      await _api.client.delete(Uri.parse('${ApiRoutes.assets}/$assetId/$edcId'));
      return null; 
    } on Exception catch (e) {
      return extractEdcErrorMessage(e);
    }
  }

  /// Get assets by EDC ID
  Future<Object> getAssetsByEdcId(String edcId) async {
    try {
      final response = await _api.client.get(Uri.parse('${ApiRoutes.assets}/by-edc/$edcId'));
      final data = jsonDecode(response.body);
      return (data as List)
          .map((json) => Asset.fromJson(json))
          .toList();
    } on Exception catch (e) {
      return extractEdcErrorMessage(e);
    }
  }
}
