// ignore_for_file: non_constant_identifier_names

class PortConfig {
  final int http;
  final int management;
  final int protocol;
  final int control;
  final int public;
  final int version;

  PortConfig({
    required this.http,
    required this.management,
    required this.protocol,
    required this.control,
    required this.public,
    required this.version,
  });

  factory PortConfig.fromJson(Map<String, dynamic> json) {
    return PortConfig(
      http: json['http'],
      management: json['management'],
      protocol: json['protocol'],
      control: json['control'],
      public: json['public'],
      version: json['version'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'http': http,
      'management': management,
      'protocol': protocol,
      'control': control,
      'public': public,
      'version': version,
    };
  }
}

class Endpoints {
  final String management;
  final String? protocol;
  final String? public;

  Endpoints({
    required this.management,
    this.protocol,
    this.public,
  });

  factory Endpoints.fromJson(Map<String, dynamic> json) {
    return Endpoints(
      management: json['management'],
      protocol: json['protocol'],
      public: json['public'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'management': management,
      'protocol': protocol,
      'public': public,
    };
  }
}

class IdentityCredentialSummary {
  final String file_name;
  final String? credential_type;
  final String? credential_id;
  final String? issuer_id;
  final String? subject_id;

  IdentityCredentialSummary({
    required this.file_name,
    this.credential_type,
    this.credential_id,
    this.issuer_id,
    this.subject_id,
  });

  factory IdentityCredentialSummary.fromJson(Map<String, dynamic> json) {
    return IdentityCredentialSummary(
      file_name: json['file_name'],
      credential_type: json['credential_type'],
      credential_id: json['credential_id'],
      issuer_id: json['issuer_id'],
      subject_id: json['subject_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'file_name': file_name,
      'credential_type': credential_type,
      'credential_id': credential_id,
      'issuer_id': issuer_id,
      'subject_id': subject_id,
    };
  }
}

class IdentityHubStatus {
  final bool enabled;
  final bool vault_enabled;
  final String? participant_context_did;
  final String? bundle_file_name;
  final String? imported_at;
  final String? imported_by;
  final int credential_count;
  final List<IdentityCredentialSummary> credentials;
  final bool runtime_prepared;
  final bool restart_required;
  final String? last_error;

  IdentityHubStatus({
    required this.enabled,
    required this.vault_enabled,
    this.participant_context_did,
    this.bundle_file_name,
    this.imported_at,
    this.imported_by,
    required this.credential_count,
    required this.credentials,
    required this.runtime_prepared,
    required this.restart_required,
    this.last_error,
  });

  factory IdentityHubStatus.fromJson(Map<String, dynamic> json) {
    return IdentityHubStatus(
      enabled: json['enabled'] ?? false,
      vault_enabled: json['vault_enabled'] ?? false,
      participant_context_did: json['participant_context_did'],
      bundle_file_name: json['bundle_file_name'],
      imported_at: json['imported_at'],
      imported_by: json['imported_by'],
      credential_count: json['credential_count'] ?? 0,
      credentials: ((json['credentials'] ?? []) as List)
          .map((item) => IdentityCredentialSummary.fromJson(item))
          .toList(),
      runtime_prepared: json['runtime_prepared'] ?? false,
      restart_required: json['restart_required'] ?? false,
      last_error: json['last_error'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'vault_enabled': vault_enabled,
      'participant_context_did': participant_context_did,
      'bundle_file_name': bundle_file_name,
      'imported_at': imported_at,
      'imported_by': imported_by,
      'credential_count': credential_count,
      'credentials': credentials.map((item) => item.toJson()).toList(),
      'runtime_prepared': runtime_prepared,
      'restart_required': restart_required,
      'last_error': last_error,
    };
  }
}

class Connector {
  final String id;
  final String name;
  final String? description;
  final String type; // "provider" or "consumer"
  final String mode; // "managed" or "remote"
  final PortConfig? ports;
  final String state; // "running" or "stopped"
  final String? api_key;
  final Endpoints? endpoints_url;
  final String? domain;
  final IdentityHubStatus? identity_hub;

  Connector({
    required this.id,
    required this.name,
    this.description,
    required this.type,
    required this.mode,
    this.ports,
    required this.state,
    this.api_key,
    this.endpoints_url,
    this.domain,
    this.identity_hub,
  });

  factory Connector.fromJson(Map<String, dynamic> json) {
    return Connector(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      type: json['type'],
      mode: json['mode'],
      ports: json['ports'] != null ? PortConfig.fromJson(json['ports']) : null,
      state: json['state'],
      api_key: json['api_key'],
      endpoints_url: json['endpoints_url'] != null ? Endpoints.fromJson(json['endpoints_url']) : null,
      domain: json['domain'],
      identity_hub: json['identity_hub'] != null ? IdentityHubStatus.fromJson(json['identity_hub']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type,
      'mode': mode,
      'ports': ports?.toJson(),
      'state': state,
      'api_key': api_key,
      'endpoints_url': endpoints_url?.toJson(),
      'domain': domain,
      'identity_hub': identity_hub?.toJson(),
    };
  }
}
