
import 'package:edc_studio/main.dart';

class EndpointsApi {
  static final String localBase = getEnvVar('ENDPOINT_BASE');
  static final String localPond = getEnvVar('ENDPOINT_DATA_POND');
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
