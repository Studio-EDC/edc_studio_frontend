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

class Connector {
  final String id;
  final String name;
  final String? description;
  final String type; // "provider" or "consumer"
  final String mode; // "managed" or "remote"
  final PortConfig? ports;
  final String state; // "running" or "stopped"
  final String? keystore_password;
  final String? endpoint_url;

  Connector({
    required this.id,
    required this.name,
    this.description,
    required this.type,
    required this.mode,
    this.ports,
    required this.state,
    this.keystore_password,
    this.endpoint_url
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
      keystore_password: json['keystore_password'] ?? '',
      endpoint_url: json['endpoint_url']
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
      'keystore_password': keystore_password,
      'endpoint_url': endpoint_url
    };
  }
}