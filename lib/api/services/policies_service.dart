import 'package:edc_studio/api/models/policy.dart';
import 'package:edc_studio/api/utils/api.dart';
import 'package:edc_studio/api/utils/communication_service.dart';

class PoliciesService {
  final CommunicationService _api = CommunicationService();

  /// Create a new policy
  Future<String?> createPolicy(Policy policy) async {
    try {
      final response = await _api.post(ApiRoutes.policies, policy.toJson());
      return response['id'];
    } catch (e) {
      return null;
    }
  }

  /// Get policies by EDC ID
  Future<List<Policy>> getPoliciesByEdcId(String edcId) async {
    try {
      final response = await _api.get('${ApiRoutes.policies}/by-edc/$edcId');
      return (response as List)
          .map((json) => Policy.fromJson(json))
          .toList();
    } catch (e) {
      return [];
    }
  }
}