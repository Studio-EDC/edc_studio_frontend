import 'dart:convert';

import 'package:edc_studio/api/models/contract.dart';
import 'package:edc_studio/api/utils/api.dart';
import 'package:edc_studio/api/utils/handle_message.dart';

class ContractsService {
  final MyApi _api = MyApi();

  /// Create a new contract
  Future<String?> createContract(Contract contract) async {
    try {
      await _api.client.post(Uri.parse(ApiRoutes.contracts), body: jsonEncode(contract.toJson()));
      return null;
    } on Exception catch (e) {
      return extractEdcErrorMessage(e);
    }
  }

  /// Get contracts by EDC ID
  Future<Object> getContractsByEdcId(String edcId) async {
    try {
      final response = await _api.client.get(Uri.parse('${ApiRoutes.contracts}/by-edc/$edcId'));
      final data = jsonDecode(response.body);
      return (data as List)
          .map((json) => Contract.fromJson(json))
          .toList();
    } on Exception catch (e) {
      return extractEdcErrorMessage(e);
    }
  }

  /// Get contract by ID
  Future<Object> getContractByContractId(String edcId, String assetId) async {
    try {
      final response = await _api.client.get(Uri.parse('${ApiRoutes.contracts}/by-contract-id/$edcId/$assetId'));
      final data = jsonDecode(response.body);
      return Contract.fromJson(data);
    } on Exception catch (e) {
      return extractEdcErrorMessage(e);
    }
  }

  /// Update contract by ID
  Future<String?> updateContract(String edcId, Contract contract) async {
    try {
      await _api.client.put(Uri.parse('${ApiRoutes.contracts}/$edcId'), body: jsonEncode(contract.toJson()));
      return null;
    } on Exception catch (e) {
      return extractEdcErrorMessage(e);
    }
  }

  /// Delete contract by ID
  Future<String?> deleteContract(String contractId, String edcId) async {
    try {
      await _api.client.delete(Uri.parse('${ApiRoutes.contracts}/$contractId/$edcId'));
      return null;
    } on Exception catch (e) {
      return extractEdcErrorMessage(e);
    }
  }
}