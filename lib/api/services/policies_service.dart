import 'dart:convert';

import 'package:edc_studio/api/models/policy.dart';
import 'package:edc_studio/api/utils/api.dart';
import 'package:edc_studio/api/utils/handle_message.dart';

class PoliciesService {
  final MyApi _api = MyApi();

  /// Create a new policy
  Future<String?> createPolicy(Policy policy) async {
    try {
      await _api.client.post(Uri.parse(ApiRoutes.policies), body: jsonEncode(policy.toJson()));
      return null;
    } on Exception catch (e) {
      return extractEdcErrorMessage(e);
    }
  }

  /// Get policies by EDC ID
  Future<Object> getPoliciesByEdcId(String edcId) async {
    try {
      final response = await _api.client.get(Uri.parse('${ApiRoutes.policies}/by-edc/$edcId'));
      final data = jsonDecode(response.body);
      return (data as List)
          .map((json) => Policy.fromJson(json))
          .toList();
    } on Exception catch (e) {
      return extractEdcErrorMessage(e);
    }
  }

  Future<Policy?> getPolicyByPolicyId(String edcId, String assetId) async {
    try {
      final response = await _api.client.get(Uri.parse('${ApiRoutes.policies}/by-policy-id/$edcId/$assetId'));
      final data = jsonDecode(response.body);
      return Policy.fromJson(data);
    } catch (e) {
      return null;
    }
  }

  Future<bool> updatePolicy(String edcId, Policy policy) async {
    try {
      await _api.client.put(Uri.parse('${ApiRoutes.policies}/$edcId'), body: jsonEncode(policy.toJson()));
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deletePolicy(String policyId, String edcId) async {
    try {
      await _api.client.delete(Uri.parse('${ApiRoutes.policies}/$policyId/$edcId'));
      return true;
    } catch (e) {
      return false;
    }
  }
}