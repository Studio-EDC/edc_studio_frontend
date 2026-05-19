class FederatedCatalogInstance {
  final String id;
  final String name;
  final String slug;
  final String state;
  final int api_port;
  final int catalog_port;
  final String public_base_url;
  final String query_path_prefix;
  final String health_path_prefix;
  final String participant_id;
  final int refresh_seconds;
  final int connect_timeout_seconds;
  final int read_timeout_seconds;
  final String provider_scope_mode;
  final List<String> selected_provider_connector_ids;
  final String container_name;
  final String runtime_dir;
  final String catalog_base_url;
  final String query_url;
  final String health_url;
  final String nginx_snippet_path;
  final String? last_error;
  final String? created_at;
  final String? updated_at;

  FederatedCatalogInstance({
    required this.id,
    required this.name,
    required this.slug,
    required this.state,
    required this.api_port,
    required this.catalog_port,
    required this.public_base_url,
    required this.query_path_prefix,
    required this.health_path_prefix,
    required this.participant_id,
    required this.refresh_seconds,
    required this.connect_timeout_seconds,
    required this.read_timeout_seconds,
    required this.provider_scope_mode,
    required this.selected_provider_connector_ids,
    required this.container_name,
    required this.runtime_dir,
    required this.catalog_base_url,
    required this.query_url,
    required this.health_url,
    required this.nginx_snippet_path,
    this.last_error,
    this.created_at,
    this.updated_at,
  });

  factory FederatedCatalogInstance.fromJson(Map<String, dynamic> json) {
    return FederatedCatalogInstance(
      id: json['id'],
      name: json['name'],
      slug: json['slug'],
      state: json['state'],
      api_port: json['api_port'],
      catalog_port: json['catalog_port'],
      public_base_url: json['public_base_url'],
      query_path_prefix: json['query_path_prefix'],
      health_path_prefix: json['health_path_prefix'],
      participant_id: json['participant_id'],
      refresh_seconds: json['refresh_seconds'],
      connect_timeout_seconds: json['connect_timeout_seconds'],
      read_timeout_seconds: json['read_timeout_seconds'],
      provider_scope_mode: json['provider_scope_mode'],
      selected_provider_connector_ids:
          ((json['selected_provider_connector_ids'] ?? []) as List)
              .map((item) => item.toString())
              .toList(),
      container_name: json['container_name'],
      runtime_dir: json['runtime_dir'],
      catalog_base_url: json['catalog_base_url'],
      query_url: json['query_url'],
      health_url: json['health_url'],
      nginx_snippet_path: json['nginx_snippet_path'],
      last_error: json['last_error'],
      created_at: json['created_at'],
      updated_at: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'slug': slug,
      'api_port': api_port,
      'catalog_port': catalog_port,
      'public_base_url': public_base_url,
      'query_path_prefix': query_path_prefix,
      'health_path_prefix': health_path_prefix,
      'participant_id': participant_id,
      'refresh_seconds': refresh_seconds,
      'connect_timeout_seconds': connect_timeout_seconds,
      'read_timeout_seconds': read_timeout_seconds,
      'provider_scope_mode': provider_scope_mode,
      'selected_provider_connector_ids': selected_provider_connector_ids,
    };
  }
}
