import 'package:edc_studio/api/models/connector.dart';

class Transfer {
  final String? id;
  final String consumer;
  final String provider;
  final String asset;
  final String hasPolicyId;
  final String negotiateContractId;
  final String contractAgreementId;
  final String transferProcessID;
  final String transferFlow;
  final String? endpoint;
  final String? authorization;

  Transfer({
    this.id,
    required this.consumer,
    required this.provider,
    required this.asset,
    required this.hasPolicyId,
    required this.negotiateContractId,
    required this.contractAgreementId,
    required this.transferProcessID,
    required this.transferFlow,
    this.endpoint,
    this.authorization
  });

  factory Transfer.fromJson(Map<String, dynamic> json) {
    return Transfer(
      id: json['id'],
      consumer: json['consumer'],
      provider: json['provider'],
      asset: json['asset'],
      hasPolicyId: json['has_policy_id'],
      negotiateContractId: json['negotiate_contract_id'],
      contractAgreementId: json['contract_agreement_id'],
      transferProcessID: json['transfer_process_id'],
      transferFlow: json['transfer_flow'],
      endpoint: json['endpoint'],
      authorization: json['authorization'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'consumer': consumer,
      'provider': provider,
      'asset': asset,
      'has_policy_id': hasPolicyId,
      'negotiate_contract_id': negotiateContractId,
      'contract_agreement_id': contractAgreementId,
      'transfer_process_id': transferProcessID,
      'transfer_flow': transferFlow,
      'endpoint': endpoint,
      'authorization': authorization
    };
  }
}

class TransferPopulated {
  final String id;
  final String? hasPolicyId;
  final String? negotiateContractId;
  final String? contractAgreementId;
  final String? transferProcessID;
  final String? transferFlow;
  final Connector? consumer;
  final Connector? provider;
  final String? asset;
  final String? endpoint;
  final String? authorization;

  TransferPopulated({
    required this.id,
    this.hasPolicyId,
    this.negotiateContractId,
    this.contractAgreementId,
    this.transferProcessID,
    this.transferFlow,
    this.consumer,
    this.provider,
    this.asset,
    this.endpoint,
    this.authorization
  });

  factory TransferPopulated.fromJson(Map<String, dynamic> json) {
    return TransferPopulated(
      id: json['id'] ?? '',
      hasPolicyId: json['has_policy_id'],
      negotiateContractId: json['negotiate_contract_id'],
      contractAgreementId: json['contract_agreement_id'],
      transferProcessID: json['transfer_process_id'],
      transferFlow: json['transfer_flow'],
      consumer: json['consumer'] != null ? Connector.fromJson(json['consumer']) : null,
      provider: json['provider'] != null ? Connector.fromJson(json['provider']) : null,
      asset: json['asset'],
      endpoint: json['endpoint'],
      authorization: json['authorization'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'consumer': consumer?.toJson(),
      'provider': provider?.toJson(),
      'asset': asset,
      'has_policy_id': hasPolicyId,
      'negotiate_contract_id': negotiateContractId,
      'contract_agreement_id': contractAgreementId,
      'transfer_process_id': transferProcessID,
      'transfer_flow': transferFlow,
      'endpoint': endpoint,
      'authorization': authorization
    };
  }
}