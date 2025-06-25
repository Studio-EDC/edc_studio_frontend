
class EndpointsApi {
  static const String localBase = 'http://127.0.0.1:8000';
  static const String remoteBase = 'https://api.tuservidor.com';
  static const String localPond = 'http://127.0.0.1:8080';
}

class ApiRoutes {
  static const edc = '/connectors';
  static const assets = '/assets';
  static const policies = '/policies';
  static const contracts = '/contracts';
  static const transfers = '/transfers';
}

class ApiRoutesPond {
  static const users = '/users/';
  static const token = '/token';
  static const files = '/files';
  static const download = '/files/download';
}
