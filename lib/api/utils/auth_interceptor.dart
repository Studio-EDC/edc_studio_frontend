
import 'package:edc_studio/api/services/users_service.dart';
import 'package:edc_studio/routes.dart';
import 'package:http_interceptor/http_interceptor.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthInterceptor extends InterceptorContract {
  bool _alreadyHandled401 = false;

  @override
  Future<BaseRequest> interceptRequest({required BaseRequest request}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    request.headers['content-type'] = 'application/json';
    request.headers['accept'] = 'application/json';

    if (!request.headers.containsKey('Authorization') && token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    return request;
  }

  @override
  Future<BaseResponse> interceptResponse({required BaseResponse response}) async {
    if (response.statusCode == 401 && !_alreadyHandled401) {
      _alreadyHandled401 = true;

      final userService = UsersService();
      await userService.logout();

      appRouter.go('/login');
    }

    return response;
  }
}
