import 'package:edc_studio/api/models/transfer.dart';
import 'package:edc_studio/api/utils/api.dart';
import 'package:edc_studio/api/utils/communication_service.dart';
import 'package:edc_studio/api/utils/handle_message.dart';

class TransfersService {
  final CommunicationService _api = CommunicationService(base: EndpointsApi.localBase);

  /// Rquest catalog
  Future<Object> requestCatalog(String consumer, String provider) async {
    try {
      final response = await _api.post(
        '${ApiRoutes.transfers}/catalog_request', 
        {
          "consumer": consumer,
          "provider": provider
        }
      );
      return response;
    } on Exception catch (e) {
      return extractEdcErrorMessage(e);
    }
  }

  /// Negotiate contract
  Future<Object> negotiateContract(String consumer, String provider, String contractOfferId, String assetId) async {
    try {
      final response = await _api.post(
        '${ApiRoutes.transfers}/negotiate_contract', 
        {
          "consumer": consumer,
          "provider": provider,
          "contract_offer_id": contractOfferId,
          "asset": assetId
        }
      );
      return response;
    } on Exception catch (e) {
      return extractEdcErrorMessage(e);
    }
  }

  /// Contract agreement
  Future<Object> getContractAgreement(String consumer, String contractNegotiationId) async {
    try {
      final response = await _api.post(
        '${ApiRoutes.transfers}/contract_agreement',
        {
          "consumer": consumer,
          "id_contract_negotiation": contractNegotiationId
        }
      );
      return response;
    } on Exception catch (e) {
      return extractEdcErrorMessage(e);
    }
  }

  /// Start Http server
  Future<dynamic> startHttpLogger() async {
    try {
      final response = await _api.post(
        '${ApiRoutes.transfers}/start_http_server', {}
      );
      return response;
    } catch (e) {
      return null;
    }
  }

  /// Stop Http server
  Future<dynamic> stopHttpLogger() async {
    try {
      final response = await _api.post(
        '${ApiRoutes.transfers}/stop_http_server', {}
      );
      return response;
    } catch (e) {
      return null;
    }
  }

  /// Start transfer
  Future<Object> startTransfer(String consumer, String provider, String contractAgreementId) async {
    try {
      final response = await _api.post(
        '${ApiRoutes.transfers}/start_transfer', 
        {
          "consumer": consumer,
          "provider": provider,
          "contract_agreement_id": contractAgreementId
        }
      );
      return response;
    } on Exception catch (e) {
      return extractEdcErrorMessage(e);
    }
  }

  /// Check transfer
  Future<Object> checkTransfer(String consumer, String transferProcessID) async {
    try {
      final response = await _api.post(
        '${ApiRoutes.transfers}/check_transfer', 
        {
          "consumer": consumer,
          "transfer_process_id": transferProcessID
        }
      );
      return response;
    } on Exception catch (e) {
      return extractEdcErrorMessage(e);
    }
  }

  /// Create a new policy
  Future<String?> createTransfer(Transfer transfer) async {
    try {
      await _api.post(ApiRoutes.transfers, transfer.toJson());
      return null;
    } on Exception catch (e) {
      return extractEdcErrorMessage(e);
    }
  }

  /// Get all
  Future<Object> getAll() async {
    try {
      final response = await _api.get(ApiRoutes.transfers);
      final transfers = (response as List)
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
      final response = await _api.post(
        '${ApiRoutes.transfers}/start_transfer_pull', 
        {
          "consumer": consumer,
          "provider": provider,
          "contract_agreement_id": contractAgreementId
        }
      );
      return response;
    } on Exception catch (e) {
      return extractEdcErrorMessage(e);
    }
  }

  /// Check transfer
  Future<dynamic> checkDataPull(String consumer, String transferProcessID) async {
    try {
      final response = await _api.post(
        '${ApiRoutes.transfers}/check_data_pull', 
        {
          "consumer": consumer,
          "transfer_process_id": transferProcessID
        }
      );
      return response;
    } on Exception catch (e) {
      return extractEdcErrorMessage(e);
    }
  }
}