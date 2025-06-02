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

  Transfer({
    this.id,
    required this.consumer,
    required this.provider,
    required this.asset,
    required this.hasPolicyId,
    required this.negotiateContractId,
    required this.contractAgreementId,
    required this.transferProcessID,
    required this.transferFlow
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
      transferFlow: json['transfer_flow']
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
      'transfer_flow': transferFlow
    };
  }
}