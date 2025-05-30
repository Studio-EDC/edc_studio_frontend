class Operator {
  String id;

  Operator({required this.id});

  factory Operator.fromJson(Map<String, dynamic> json) {
    return Operator(
      id: json['id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
    };
  }
}

class Constraint {
  String leftOperand;
  Operator operator;
  String rightOperand;

  Constraint({
    required this.leftOperand,
    required this.operator,
    required this.rightOperand,
  });

  factory Constraint.fromJson(Map<String, dynamic> json) {
    return Constraint(
      leftOperand: json['leftOperand'],
      operator: Operator.fromJson(json['operator']),
      rightOperand: json['rightOperand'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'leftOperand': leftOperand,
      'operator': operator.toJson(),
      'rightOperand': rightOperand,
    };
  }
}

class Rule {
  String action; // e.g., USE, READ, WRITE, etc.
  List<Constraint>? constraint;

  Rule({
    required this.action,
    this.constraint,
  });

  factory Rule.fromJson(Map<String, dynamic> json) {
    return Rule(
      action: json['action'],
      constraint: json['constraint'] != null
          ? (json['constraint'] as List)
              .map((c) => Constraint.fromJson(c))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'action': action,
      if (constraint != null)
        'constraint': constraint!.map((c) => c.toJson()).toList(),
    };
  }
}

class PolicyDefinition {
  final List<Rule>? permission;
  final List<Rule>? prohibition;
  final List<Rule>? obligation;
  final String context;
  final String type;

  PolicyDefinition({
    this.permission,
    this.prohibition,
    this.obligation,
    this.context = 'http://www.w3.org/ns/odrl.jsonld',
    this.type = 'Set',
  });

  factory PolicyDefinition.fromJson(Map<String, dynamic> json) {
    return PolicyDefinition(
      permission: json['permission'] != null
          ? (json['permission'] as List)
              .map((r) => Rule.fromJson(r))
              .toList()
          : null,
      prohibition: json['prohibition'] != null
          ? (json['prohibition'] as List)
              .map((r) => Rule.fromJson(r))
              .toList()
          : null,
      obligation: json['obligation'] != null
          ? (json['obligation'] as List)
              .map((r) => Rule.fromJson(r))
              .toList()
          : null,
      context: json['context'] ?? 'http://www.w3.org/ns/odrl.jsonld',
      type: json['type'] ?? 'Set',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (permission != null)
        'permission': permission!.map((r) => r.toJson()).toList(),
      if (prohibition != null)
        'prohibition': prohibition!.map((r) => r.toJson()).toList(),
      if (obligation != null)
        'obligation': obligation!.map((r) => r.toJson()).toList(),
      'context': context,
      'type': type,
    };
  }
}

class Policy {
  final String? id;
  final String edc;
  final String policyId;
  final PolicyDefinition policy;
  final Map<String, dynamic> context;

  Policy({
    this.id,
    required this.edc,
    required this.policyId,
    required this.policy,
    this.context = const {'@vocab': 'https://w3id.org/edc/v0.0.1/ns/'},
  });

  factory Policy.fromJson(Map<String, dynamic> json) {
    return Policy(
      id: json['id'],
      edc: json['edc'],
      policyId: json['policy_id'],
      policy: PolicyDefinition.fromJson(json['policy']),
      context: Map<String, dynamic>.from(json['context'] ??
          {'@vocab': 'https://w3id.org/edc/v0.0.1/ns/'}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'edc': edc,
      'policy_id': policyId,
      'policy': policy.toJson(),
      'context': context,
    };
  }
}