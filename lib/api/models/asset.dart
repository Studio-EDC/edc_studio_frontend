class Asset {
  final String? id;
  final String assetId;
  final String name;
  final String contentType;
  final String dataAddressName;
  final String dataAddressType; // "HttpData" o "File"
  final bool dataAddressProxy;
  final String baseUrl;
  final String edc;

  Asset({
    this.id,
    required this.assetId,
    required this.name,
    required this.contentType,
    required this.dataAddressName,
    required this.dataAddressType,
    required this.dataAddressProxy,
    required this.baseUrl,
    required this.edc,
  });

  factory Asset.fromJson(Map<String, dynamic> json) {
    return Asset(
      id: json['id'],
      assetId: json['asset_id'],
      name: json['name'],
      contentType: json['content_type'],
      dataAddressName: json['data_address_name'],
      dataAddressType: json['data_address_type'],
      dataAddressProxy: json['data_address_proxy'],
      baseUrl: json['base_url'],
      edc: json['edc'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'asset_id': assetId,
      'name': name,
      'content_type': contentType,
      'data_address_name': dataAddressName,
      'data_address_type': dataAddressType,
      'data_address_proxy': dataAddressProxy,
      'base_url': baseUrl,
      'edc': edc,
    };
  }
}
