import 'package:edc_studio/api/models/policy.dart';
import 'package:edc_studio/api/utils/api.dart';
import 'package:edc_studio/api/utils/communication_service.dart';
import 'package:edc_studio/api/utils/handle_message.dart';

class PoliciesService {
  final CommunicationService _api = CommunicationService();

  /// Create a new policy
  Future<String?> createPolicy(Policy policy) async {
    try {
      await _api.post(ApiRoutes.policies, policy.toJson());
      return null;
    } on Exception catch (e) {
      return extractEdcErrorMessage(e);
    }
  }

  /// Get policies by EDC ID
  Future<Object> getPoliciesByEdcId(String edcId) async {
    try {
      final response = await _api.get('${ApiRoutes.policies}/by-edc/$edcId');
      return (response as List)
          .map((json) => Policy.fromJson(json))
          .toList();
    } on Exception catch (e) {
      return extractEdcErrorMessage(e);
    }
  }

  Future<Policy?> getPolicyByPolicyId(String edcId, String assetId) async {
    try {
      final response = await _api.get('${ApiRoutes.policies}/by-policy-id/$edcId/$assetId');
      return Policy.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  Future<bool> updatePolicy(String edcId, Policy policy) async {
    try {
      await _api.put('${ApiRoutes.policies}/$edcId', policy.toJson());
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deletePolicy(String policyId, String edcId) async {
    try {
      await _api.delete('${ApiRoutes.policies}/$policyId/$edcId');
      return true;
    } catch (e) {
      return false;
    }
  }
}