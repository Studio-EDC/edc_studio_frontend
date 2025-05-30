class Contract {
  final String? id;
  final String edc;
  final String contractId;
  final String accessPolicyId;
  final String contractPolicyId;
  final List<String> assetsSelector;
  final Map<String, String> context;

  Contract({
    this.id,
    required this.edc,
    required this.contractId,
    required this.accessPolicyId,
    required this.contractPolicyId,
    required this.assetsSelector,
    required this.context,
  });

  factory Contract.fromJson(Map<String, dynamic> json) {
    return Contract(
      id: json['id'],
      edc: json['edc'],
      contractId: json['contract_id'],
      accessPolicyId: json['accessPolicyId'],
      contractPolicyId: json['contractPolicyId'],
      assetsSelector: List<String>.from(json['assetsSelector']),
      context: Map<String, String>.from(json['context']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'edc': edc,
      'contract_id': contractId,
      'accessPolicyId': accessPolicyId,
      'contractPolicyId': contractPolicyId,
      'assetsSelector': assetsSelector,
      'context': context,
    };
  }
}