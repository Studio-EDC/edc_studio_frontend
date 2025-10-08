
class EndpointsApi {
  static const String localBase = 'http://localhost:80/api';
  static const String localPond = 'http://localhost:80/pond';
}

class ApiRoutes {
  static const edc = '/connectors/';
  static const assets = '/assets/';
  static const policies = '/policies/';
  static const contracts = '/contracts/';
  static const transfers = '/transfers/';
}

class ApiRoutesPond {
  static const users = '/users/';
  static const token = '/token/';
  static const files = '/files/';
  static const download = '/files/download/';
}
