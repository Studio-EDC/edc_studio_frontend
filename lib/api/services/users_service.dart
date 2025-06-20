import 'package:edc_studio/api/models/user.dart';
import 'package:edc_studio/api/utils/api.dart';
import 'package:edc_studio/api/utils/communication_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UsersService {
  final CommunicationService _api = CommunicationService(base: EndpointsApi.localPond);

  Future<List<User>> getUsers() async {
    try {
      await getToken('admin', 'admin');
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      final response = await _api.get(ApiRoutesPond.users,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      return (response as List)
          .map((json) => User.fromJson(json))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<String?> getToken(String username, String password) async {
    try {
      final response = await _api.post(ApiRoutesPond.token,
        {
          "username": username,
          "password": password
        },
        asFormUrlEncoded: true,
      );
      final token = response['access_token'];
      if (token != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', token);
      }
      return null;
    } on ApiException catch (e) {
      if (e.body is Map && e.body['detail'] is String) {
        print('Detail: ${e.body['detail']}');
      } else {
        print('Body: ${e.body}');
      }
      return '';
    }
  }
}