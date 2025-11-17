// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:edc_studio/api/models/file.dart';
import 'package:edc_studio/api/models/user.dart';
import 'package:edc_studio/api/utils/api.dart';
import 'package:edc_studio/ui/widgets/snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:html' as html;

class UsersService {
  final MyApi _api = MyApi();

  Future<List<User>> getUsers() async {
    try {
      await getToken('admin', 'admin');
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('admin_token');
      final response = await _api.client.get(Uri.parse(ApiRoutesPond.users),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      final data = jsonDecode(response.body);
      return (data as List)
          .map((json) => User.fromJson(json))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<String?> registerUser(String name, String surnames, String email, String username, String password) async {
    try {
      await _api.client.post(Uri.parse(ApiRoutes.register),
        body: jsonEncode({
          "name": name,
          "surnames": surnames,
          "email": email,
          "username": username,
          "password": password
        })
      );
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> getToken(String username, String password) async {
    try {
      final response = await _api.client.post(Uri.parse(ApiRoutes.token),
        body: jsonEncode({
          "username": username,
          "password": password
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode != 200) {
        return data['detail'] ?? 'Internal error';
      } else {
        if (data.containsKey('access_token')) {
          final token = data['access_token'];
          final prefs = await SharedPreferences.getInstance();
          if (username == 'admin') {
            await prefs.setString('admin_token', token);
          } 
          await prefs.setString('access_token', token);
          await prefs.setString('username', username);
        }
        return null;
      }
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  Future<List<FileModel>?> getFiles(String username) async {
    try {
      await getToken('admin', 'admin');
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('admin_token');
      final response = await _api.client.get(
        Uri.parse('${ApiRoutesPond.files}?username=$username'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      final data = jsonDecode(response.body);
      return (data as List)
          .map((json) => FileModel.fromJson(json))
          .toList();

    } catch (e) {
      return null;
    }
  }

  Future<String?> downloadFile(String filename) async {
    try {
      final response = await _api.client.get(
        Uri.parse('${EndpointsApi.localPond}/files/download/$filename')
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
    final response = await _api.client.get(
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
    final response = await _api.client.get(
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