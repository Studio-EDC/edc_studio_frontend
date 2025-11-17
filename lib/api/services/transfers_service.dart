import 'dart:convert';

import 'package:edc_studio/api/models/transfer.dart';
import 'package:edc_studio/api/utils/api.dart';
import 'package:edc_studio/api/utils/handle_message.dart';

class TransfersService {
  final MyApi _api = MyApi();

  /// Rquest catalog
  Future<Object> requestCatalog(String consumer, String provider) async {
    try {
      final response = await _api.client.post(
        Uri.parse('${ApiRoutes.transfers}/catalog_request'), 
        body: jsonEncode({
          "consumer": consumer,
          "provider": provider
        })
      );
      final data = jsonDecode(response.body);
      return data;
    } on Exception catch (e) {
      return extractEdcErrorMessage(e);
    }
  }

  /// Negotiate contract
  Future<Object> negotiateContract(String consumer, String provider, String contractOfferId, String assetId) async {
    try {
      final response = await _api.client.post(
        Uri.parse('${ApiRoutes.transfers}/negotiate_contract'), 
        body: jsonEncode({
          "consumer": consumer,
          "provider": provider,
          "contract_offer_id": contractOfferId,
          "asset": assetId
        })
      );
      final data = jsonDecode(response.body);
      return data;
    } on Exception catch (e) {
      return extractEdcErrorMessage(e);
    }
  }

  /// Contract agreement
  Future<Object> getContractAgreement(String consumer, String contractNegotiationId) async {
    try {
      final response = await _api.client.post(
        Uri.parse('${ApiRoutes.transfers}/contract_agreement'),
        body: jsonEncode({
          "consumer": consumer,
          "id_contract_negotiation": contractNegotiationId
        })
      );
      final data = jsonDecode(response.body);
      return data;
    } on Exception catch (e) {
      return extractEdcErrorMessage(e);
    }
  }

  /// Start Http server
  Future<dynamic> startHttpLogger() async {
    try {
      final response = await _api.client.post(
        Uri.parse('${ApiRoutes.transfers}/start_http_server'), body: {}
      );
      final data = jsonDecode(response.body);
      return data;
    } catch (e) {
      return null;
    }
  }

  /// Stop Http server
  Future<dynamic> stopHttpLogger() async {
    try {
      final response = await _api.client.post(
        Uri.parse('${ApiRoutes.transfers}/stop_http_server'), body: {}
      );
      final data = jsonDecode(response.body);
      return data;
    } catch (e) {
      return null;
    }
  }

  /// Start transfer
  Future<Object> startTransfer(String consumer, String provider, String contractAgreementId) async {
    try {
      final response = await _api.client.post(
        Uri.parse('${ApiRoutes.transfers}/start_transfer'), 
        body: jsonEncode({
          "consumer": consumer,
          "provider": provider,
          "contract_agreement_id": contractAgreementId
        })
      );
      final data = jsonDecode(response.body);
      return data;
    } on Exception catch (e) {
      return extractEdcErrorMessage(e);
    }
  }

  /// Check transfer
  Future<Object> checkTransfer(String consumer, String transferProcessID) async {
    try {
      final response = await _api.client.post(
        Uri.parse('${ApiRoutes.transfers}/check_transfer'), 
        body: jsonEncode({
          "consumer": consumer,
          "transfer_process_id": transferProcessID
        })
      );
      final data = jsonDecode(response.body);
      return data;
    } on Exception catch (e) {
      return extractEdcErrorMessage(e);
    }
  }

  /// Create a new policy
 Future<Object> createTransfer(Transfer transfer) async {
    try {
      final response = await _api.client.post(Uri.parse(ApiRoutes.transfers), body: jsonEncode(transfer.toJson()));
      final data = jsonDecode(response.body);
      return data;
    } on Exception catch (e) {
      return extractEdcErrorMessage(e);
    }
  }

  /// Get all
  Future<Object> getAll() async {
    try {
      final response = await _api.client.get(Uri.parse(ApiRoutes.transfers));
      final data = jsonDecode(response.body);
      final transfers = (data as List)
          .map((json) => TransferPopulated.fromJson(json))
          .toList();
      return transfers;
    } on Exception catch (e) {
      return extractEdcErrorMessage(e);
    }
  }

  /// Start transfer pull
  Future<dynamic> startTransferPull(String consumer, String provider, String contractAgreementId) async {
    try {
      final response = await _api.client.post(
        Uri.parse('${ApiRoutes.transfers}/start_transfer_pull'), 
        body: jsonEncode({
          "consumer": consumer,
          "provider": provider,
          "contract_agreement_id": contractAgreementId
        })
      );
      final data = jsonDecode(response.body);
      return data;
    } on Exception catch (e) {
      return extractEdcErrorMessage(e);
    }
  }

  /// Check transfer
  Future<dynamic> checkDataPull(String consumer, String transferProcessID) async {
    try {
      final response = await _api.client.post(
        Uri.parse('${ApiRoutes.transfers}/check_data_pull'), 
        body: jsonEncode({
          "consumer": consumer,
          "transfer_process_id": transferProcessID
        })
      );
      final data = jsonDecode(response.body);
      return data;
    } on Exception catch (e) {
      return extractEdcErrorMessage(e);
    }
  }
}