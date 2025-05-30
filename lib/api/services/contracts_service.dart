import 'package:edc_studio/api/models/contract.dart';
import 'package:edc_studio/api/utils/api.dart';
import 'package:edc_studio/api/utils/communication_service.dart';

class ContractsService {
  final CommunicationService _api = CommunicationService();

  /// Create a new contract
  Future<String?> createContract(Contract contract) async {
    try {
      final response = await _api.post(ApiRoutes.contracts, contract.toJson());
      return response['id'];
    } catch (e) {
      return null;
    }
  }

  /// Get contracts by EDC ID
  Future<List<Contract>> getContractsByEdcId(String edcId) async {
    try {
      final response = await _api.get('${ApiRoutes.contracts}/by-edc/$edcId');
      return (response as List)
          .map((json) => Contract.fromJson(json))
          .toList();
    } catch (e) {
      return [];
    }
  }
}