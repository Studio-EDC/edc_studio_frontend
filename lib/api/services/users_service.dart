// ignore_for_file: use_build_context_synchronously

import 'package:easy_localization/easy_localization.dart';
import 'package:edc_studio/api/models/file.dart';
import 'package:edc_studio/api/models/user.dart';
import 'package:edc_studio/api/utils/api.dart';
import 'package:edc_studio/api/utils/communication_service.dart';
import 'package:edc_studio/ui/widgets/snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:html' as html;

class UsersService {
  final CommunicationService _api = CommunicationService(base: EndpointsApi.localPond);

  Future<List<User>> getUsers() async {
    try {
      await getToken('admin', 'admin');
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('admin_token');
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

  Future<String?> registerUser(String username, String password) async {
    try {
      await getToken('admin', 'admin');
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('admin_token');
      await _api.post(ApiRoutesPond.users,
        {
          "username": username,
          "password": password
        },
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      return null;
    } on ApiException catch (e) {
      if (e.body is Map && e.body['detail'] is String) {
        return e.body['detail'];
      }
      return '';
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

      if (response.containsKey('access_token')) {
        final token = response['access_token'];
        final prefs = await SharedPreferences.getInstance();
        if (username == 'admin') {
          await prefs.setString('admin_token', token);
        } else {
          await prefs.setString('access_token', token);
          await prefs.setString('username', username);
        }
      }
      return null;
    } on ApiException catch (e) {
      if (e.body is Map && e.body['detail'] is String) {
        return e.body['detail'];
      }
      return '';
    }
  }

  Future<List<FileModel>?> getFiles(String username) async {
    try {
      await getToken('admin', 'admin');
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('admin_token');
      final response = await _api.get(
        '${ApiRoutesPond.files}?username=$username',
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      return (response as List)
          .map((json) => FileModel.fromJson(json))
          .toList();

    } catch (e) {
      return null;
    }
  }

  Future<String?> downloadFile(String filename) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      final response = await http.get(
        Uri.parse('${EndpointsApi.localPond}/files/download/$filename'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final blob = html.Blob([response.bodyBytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        // ignore: unused_local_variable
        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download', filename)
          ..click();
        html.Url.revokeObjectUrl(url);
        return null;
      } else {
        return 'Error al descargar: ${response.statusCode} code';
      }
    } catch (e) {
      return 'Exception: $e';
    }
  }

  Future<void> downloadAndUploadFilePull(
    String fileUrl,
    String authorization,
    String filename,
    BuildContext context
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final userToken = prefs.getString('access_token');
    final response = await http.get(
      Uri.parse('${EndpointsApi.localBase}/transfers/proxy_pull?uri=$fileUrl'),
      headers: authorization.isNotEmpty ? {'Authorization': authorization} : null,
    );

    if (response.statusCode == 200) {
      final bytes = response.bodyBytes;

      final request = http.MultipartRequest('POST', Uri.parse('${EndpointsApi.localPond}/files/upload'))
        ..headers['Authorization'] = 'Bearer $userToken'
        ..files.add(http.MultipartFile.fromBytes('file', bytes, filename: filename));

      final uploadResponse = await request.send();

      if (uploadResponse.statusCode == 200) {
        FloatingSnackBar.show(
          context,
          message: 'users_list_page.file_uploaded_succesfully'.tr(),
          type: SnackBarType.success,
          duration: const Duration(seconds: 3),
          width: 600
        );
      } else {
        FloatingSnackBar.show(
          context,
          message: 'users_list_page.error_uploading'.tr(),
          type: SnackBarType.success,
          duration: const Duration(seconds: 3),
          width: 600
        );
      }
    } else {
      FloatingSnackBar.show(
        context,
        message: 'users_list_page.error_uploading'.tr(),
        type: SnackBarType.success,
        duration: const Duration(seconds: 3),
        width: 600
      );
    }
  }

  Future<void> downloadAndUploadFilePush(
    String filename,
    String userToken,
    BuildContext context
  ) async {
    final response = await http.get(
      Uri.parse('${EndpointsApi.localBase}/transfers/proxy_http_logger')
    );

    if (response.statusCode == 200) {
      final bytes = response.bodyBytes;

      final request = http.MultipartRequest('POST', Uri.parse('${EndpointsApi.localPond}/files/upload'))
        ..headers['Authorization'] = 'Bearer $userToken'
        ..files.add(http.MultipartFile.fromBytes('file', bytes, filename: filename));

      final uploadResponse = await request.send();

      if (uploadResponse.statusCode == 200) {
        FloatingSnackBar.show(
          context,
          message: 'users_list_page.file_uploaded_succesfully'.tr(),
          type: SnackBarType.success,
          duration: const Duration(seconds: 3),
          width: 600
        );
      } else {
        FloatingSnackBar.show(
          context,
          message: 'users_list_page.error_uploading'.tr(),
          type: SnackBarType.success,
          duration: const Duration(seconds: 3),
          width: 600
        );
      }
    } else {
      FloatingSnackBar.show(
        context,
        message: 'users_list_page.error_uploading'.tr(),
        type: SnackBarType.success,
        duration: const Duration(seconds: 3),
        width: 600
      );
    }
  }
}