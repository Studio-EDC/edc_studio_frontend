import 'package:edc_studio/api/models/contract.dart';
import 'package:edc_studio/api/utils/api.dart';
import 'package:edc_studio/api/utils/communication_service.dart';

class ContractsService {
  final CommunicationService _api = CommunicationService();

  /// Create a new contract
  Future<String?> createContract(Contract contract) async {
    try {
      final response = await _api.post(ApiRoutes.contracts, contract.toJson());
      return response;
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

  /// Get contract by ID
  Future<Contract?> getContractByContractId(String edcId, String assetId) async {
    try {
      final response = await _api.get('${ApiRoutes.contracts}/by-contract-id/$edcId/$assetId');
      return Contract.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  /// Update contract by ID
  Future<bool> updateContract(String edcId, Contract contract) async {
    try {
      await _api.put('${ApiRoutes.contracts}/$edcId', contract.toJson());
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Delete contract by ID
  Future<bool> deleteContract(String contractId, String edcId) async {
    try {
      await _api.delete('${ApiRoutes.contracts}/$contractId/$edcId');
      return true;
    } catch (e) {
      return false;
    }
  }
}