import 'package:edc_studio/api/models/contract.dart';
import 'package:edc_studio/api/utils/api.dart';
import 'package:edc_studio/api/utils/communication_service.dart';
import 'package:edc_studio/api/utils/handle_message.dart';

class ContractsService {
  final CommunicationService _api = CommunicationService(base: EndpointsApi.localBase);

  /// Create a new contract
  Future<String?> createContract(Contract contract) async {
    try {
      await _api.post(ApiRoutes.contracts, contract.toJson());
      return null;
    } on Exception catch (e) {
      return extractEdcErrorMessage(e);
    }
  }

  /// Get contracts by EDC ID
  Future<Object> getContractsByEdcId(String edcId) async {
    try {
      final response = await _api.get('${ApiRoutes.contracts}/by-edc/$edcId');
      return (response as List)
          .map((json) => Contract.fromJson(json))
          .toList();
    } on Exception catch (e) {
      return extractEdcErrorMessage(e);
    }
  }

  /// Get contract by ID
  Future<Object> getContractByContractId(String edcId, String assetId) async {
    try {
      final response = await _api.get('${ApiRoutes.contracts}/by-contract-id/$edcId/$assetId');
      return Contract.fromJson(response);
    } on Exception catch (e) {
      return extractEdcErrorMessage(e);
    }
  }

  /// Update contract by ID
  Future<String?> updateContract(String edcId, Contract contract) async {
    try {
      await _api.put('${ApiRoutes.contracts}/$edcId', contract.toJson());
      return null;
    } on Exception catch (e) {
      return extractEdcErrorMessage(e);
    }
  }

  /// Delete contract by ID
  Future<String?> deleteContract(String contractId, String edcId) async {
    try {
      await _api.delete('${ApiRoutes.contracts}/$contractId/$edcId');
      return null;
    } on Exception catch (e) {
      return extractEdcErrorMessage(e);
    }
  }
}