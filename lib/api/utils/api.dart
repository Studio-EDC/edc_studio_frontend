import 'package:edc_studio/api/utils/auth_interceptor.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http_interceptor/http_interceptor.dart';

class EndpointsApi {
  static final String localBase = dotenv.env['ENDPOINT_BASE'] ?? '';
}

class ApiRoutes {
  static final String localBase = dotenv.env['ENDPOINT_BASE'] ?? '';
  
  static final edc = '$localBase/connectors';
  static final assets = '$localBase/assets';
  static final policies = '$localBase/policies';
  static final contracts = '$localBase/contracts';
  static final transfers = '$localBase/transfers';
  static final users = '$localBase/users/';
  static final token = '$localBase/token';
  static final register = '$localBase/register';
}

class ApiRoutesPond {
  static final String localPond = dotenv.env['ENDPOINT_BASE'] ?? '';

  static final files = '$localPond/files';
  static final download = '$localPond/files/download';
}

class MyApi {
  // Singleton
  static final MyApi _instance = MyApi._internal();
  factory MyApi() => _instance;

  // Cliente HTTP interceptado
  final InterceptedClient client;

  MyApi._internal()
      : client = InterceptedClient.build(
          requestTimeout: const Duration(seconds: 60),
          interceptors: [AuthInterceptor()],
        );

  // Método para cerrar el cliente (opcional)
  void close() {
    client.close();
  }
}