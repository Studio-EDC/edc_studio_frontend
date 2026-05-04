class ManualChecklist {
  final bool didPublished;
  final bool registeredInEdcManager;
  final bool credentialsInstalled;

  ManualChecklist({
    required this.didPublished,
    required this.registeredInEdcManager,
    required this.credentialsInstalled,
  });

  factory ManualChecklist.fromJson(Map<String, dynamic> json) {
    return ManualChecklist(
      didPublished: json['did_published'] ?? false,
      registeredInEdcManager: json['registered_in_edc_manager'] ?? false,
      credentialsInstalled: json['credentials_installed'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'did_published': didPublished,
      'registered_in_edc_manager': registeredInEdcManager,
      'credentials_installed': credentialsInstalled,
    };
  }
}

class CredentialBundleCredential {
  final String fileName;
  final String? credentialType;
  final String? credentialId;
  final String? issuerId;
  final String? subjectId;

  CredentialBundleCredential({
    required this.fileName,
    this.credentialType,
    this.credentialId,
    this.issuerId,
    this.subjectId,
  });

  factory CredentialBundleCredential.fromJson(Map<String, dynamic> json) {
    return CredentialBundleCredential(
      fileName: json['file_name'] ?? '',
      credentialType: json['credential_type'],
      credentialId: json['credential_id'],
      issuerId: json['issuer_id'],
      subjectId: json['subject_id'],
    );
  }
}

class CredentialBundleInfo {
  final String provider;
  final String status;
  final String? fileName;
  final String? participantDid;
  final String? sourceUrl;
  final DateTime? issuedAt;
  final DateTime? importedToConnectorAt;
  final String? importedToConnectorBy;
  final int credentialCount;
  final List<CredentialBundleCredential> credentials;
  final String? lastError;

  CredentialBundleInfo({
    required this.provider,
    required this.status,
    this.fileName,
    this.participantDid,
    this.sourceUrl,
    this.issuedAt,
    this.importedToConnectorAt,
    this.importedToConnectorBy,
    required this.credentialCount,
    required this.credentials,
    this.lastError,
  });

  factory CredentialBundleInfo.fromJson(Map<String, dynamic> json) {
    return CredentialBundleInfo(
      provider: json['provider'] ?? 'unknown',
      status: json['status'] ?? 'MISSING',
      fileName: json['file_name'],
      participantDid: json['participant_did'],
      sourceUrl: json['source_url'],
      issuedAt: json['issued_at'] != null
          ? DateTime.tryParse(json['issued_at'])
          : null,
      importedToConnectorAt: json['imported_to_connector_at'] != null
          ? DateTime.tryParse(json['imported_to_connector_at'])
          : null,
      importedToConnectorBy: json['imported_to_connector_by'],
      credentialCount: json['credential_count'] ?? 0,
      credentials: (json['credentials'] as List<dynamic>? ?? [])
          .map((item) => CredentialBundleCredential.fromJson(
              item as Map<String, dynamic>))
          .toList(),
      lastError: json['last_error'],
    );
  }
}

class FederatedParticipant {
  final String id;
  final String participantDid;
  final String legalName;
  final String lrnValue;
  final String headquarterAddressCountryCode;
  final String legalAddressCountryCode;
  final String connectorId;
  final String? connectorName;
  final String publicDomain;
  final String? protocolEndpoint;
  final String? notes;
  final ManualChecklist checklist;
  final CredentialBundleInfo? credentials;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  FederatedParticipant({
    required this.id,
    required this.participantDid,
    required this.legalName,
    required this.lrnValue,
    required this.headquarterAddressCountryCode,
    required this.legalAddressCountryCode,
    required this.connectorId,
    this.connectorName,
    required this.publicDomain,
    this.protocolEndpoint,
    this.notes,
    required this.checklist,
    this.credentials,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory FederatedParticipant.fromJson(Map<String, dynamic> json) {
    return FederatedParticipant(
      id: json['id'] ?? '',
      participantDid: json['participant_did'],
      legalName: json['legal_name'],
      lrnValue: json['lrn_value'],
      headquarterAddressCountryCode: json['headquarter_address_country_code'],
      legalAddressCountryCode: json['legal_address_country_code'],
      connectorId: json['connector_id'],
      connectorName: json['connector_name'],
      publicDomain: json['public_domain'],
      protocolEndpoint: json['protocol_endpoint'],
      notes: json['notes'],
      checklist: ManualChecklist.fromJson(json['checklist'] ?? {}),
      credentials: json['credentials'] != null
          ? CredentialBundleInfo.fromJson(
              json['credentials'] as Map<String, dynamic>,
            )
          : null,
      status: json['status'] ?? 'DRAFT',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'participant_did': participantDid,
      'legal_name': legalName,
      'lrn_value': lrnValue,
      'headquarter_address_country_code': headquarterAddressCountryCode,
      'legal_address_country_code': legalAddressCountryCode,
      'connector_id': connectorId,
      'public_domain': publicDomain,
      'protocol_endpoint': protocolEndpoint,
      'notes': notes,
      'checklist': checklist.toJson(),
    };
  }
}

class DidDocumentData {
  final String didDocumentUrl;
  final Map<String, dynamic> didDocument;

  DidDocumentData({
    required this.didDocumentUrl,
    required this.didDocument,
  });

  factory DidDocumentData.fromJson(Map<String, dynamic> json) {
    return DidDocumentData(
      didDocumentUrl: json['did_document_url'],
      didDocument: Map<String, dynamic>.from(json['did_document']),
    );
  }
}

class ManualRegistrationData {
  final Map<String, dynamic> payload;
  final String curlCommand;

  ManualRegistrationData({
    required this.payload,
    required this.curlCommand,
  });

  factory ManualRegistrationData.fromJson(Map<String, dynamic> json) {
    return ManualRegistrationData(
      payload: Map<String, dynamic>.from(json['payload']),
      curlCommand: json['curl_command'],
    );
  }
}

class DidValidationData {
  final String didDocumentUrl;
  final bool didDocumentReachable;
  final int? didDocumentStatusCode;
  final bool didDocumentIdMatches;
  final bool protocolServiceFound;
  final bool protocolServiceMatchesExpected;
  final bool protocolEndpointReachable;
  final int? protocolEndpointStatusCode;
  final String? resolvedProtocolEndpoint;
  final String? expectedProtocolEndpoint;
  final List<String> errors;

  DidValidationData({
    required this.didDocumentUrl,
    required this.didDocumentReachable,
    this.didDocumentStatusCode,
    required this.didDocumentIdMatches,
    required this.protocolServiceFound,
    required this.protocolServiceMatchesExpected,
    required this.protocolEndpointReachable,
    this.protocolEndpointStatusCode,
    this.resolvedProtocolEndpoint,
    this.expectedProtocolEndpoint,
    required this.errors,
  });

  factory DidValidationData.fromJson(Map<String, dynamic> json) {
    return DidValidationData(
      didDocumentUrl: json['did_document_url'],
      didDocumentReachable: json['did_document_reachable'] ?? false,
      didDocumentStatusCode: json['did_document_status_code'],
      didDocumentIdMatches: json['did_document_id_matches'] ?? false,
      protocolServiceFound: json['protocol_service_found'] ?? false,
      protocolServiceMatchesExpected:
          json['protocol_service_matches_expected'] ?? false,
      protocolEndpointReachable: json['protocol_endpoint_reachable'] ?? false,
      protocolEndpointStatusCode: json['protocol_endpoint_status_code'],
      resolvedProtocolEndpoint: json['resolved_protocol_endpoint'],
      expectedProtocolEndpoint: json['expected_protocol_endpoint'],
      errors: (json['errors'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
    );
  }
}
