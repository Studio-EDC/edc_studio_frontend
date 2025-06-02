import 'package:edc_studio/api/models/transfer.dart';
import 'package:edc_studio/api/utils/api.dart';
import 'package:edc_studio/api/utils/communication_service.dart';

class TransfersService {
  final CommunicationService _api = CommunicationService();

  /// Rquest catalog
  Future<Map<String, dynamic>?> requestCatalog(String consumer, String provider) async {
    try {
      final response = await _api.post(
        '${ApiRoutes.transfers}/catalog_request', 
        {
          "consumer": consumer,
          "provider": provider
        }
      );
      return response;
    } catch (e) {
      return null;
    }
  }

  /// Negotiate contract
  Future<Map<String, dynamic>?> negotiateContract(String consumer, String provider, String contractOfferId, String assetId) async {
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
    } catch (e) {
      return null;
    }
  }

  /// Contract agreement
  Future<Map<String, dynamic>?> getContractAgreement(String consumer, String contractNegotiationId) async {
    try {
      final response = await _api.post(
        '${ApiRoutes.transfers}/contract_agreement',
        {
          "consumer": consumer,
          "id_contract_negotiation": contractNegotiationId
        }
      );
      return response;
    } catch (e) {
      return null;
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
  Future<dynamic> startTransfer(String consumer, String provider, String contractAgreementId) async {
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
    } catch (e) {
      return null;
    }
  }

  /// Check transfer
  Future<dynamic> checkTransfer(String consumer, String transferProcessID) async {
    try {
      final response = await _api.post(
        '${ApiRoutes.transfers}/check_transfer', 
        {
          "consumer": consumer,
          "transfer_process_id": transferProcessID
        }
      );
      return response;
    } catch (e) {
      return null;
    }
  }

  /// Create a new policy
  Future<String?> createTransfer(Transfer transfer) async {
    try {
      final response = await _api.post(ApiRoutes.transfers, transfer.toJson());
      return response['id'];
    } catch (e) {
      return null;
    }
  }
}