import 'package:flutter_dotenv/flutter_dotenv.dart';

class EndpointsApi {
  static final String localBase = dotenv.env['ENDPOINT_BASE'] ?? '';
  static final String localPond = dotenv.env['ENDPOINT_DATA_POND'] ?? '';
}

class ApiRoutes {
  static const edc = '/connectors';
  static const assets = '/assets';
  static const policies = '/policies';
  static const contracts = '/contracts';
  static const transfers = '/transfers';
  static const users = '/users/';
  static const token = '/token';
  static const register = '/register';
}

class ApiRoutesPond {
  static const users = '/users/';
  static const token = '/token';
  static const files = '/files';
  static const download = '/files/download';
}
