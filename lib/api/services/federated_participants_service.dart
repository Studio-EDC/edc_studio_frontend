import 'dart:convert';
import 'dart:html' as html;

import 'package:edc_studio/api/models/federated_participant.dart';
import 'package:edc_studio/api/utils/api.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class FederatedParticipantsService {
  final MyApi _api = MyApi();

  String _extractError(http.Response response, {String fallback = 'Request failed'}) {
    try {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data['detail']?.toString() ??
          data['message']?.toString() ??
          fallback;
    } catch (_) {
      return fallback;
    }
  }

  Future<List<FederatedParticipant>> getAllParticipants() async {
    final response =
        await _api.client.get(Uri.parse(ApiRoutes.federatedParticipants));
    if (response.statusCode != 200) {
      throw Exception(response.body);
    }
    final data = jsonDecode(response.body) as List<dynamic>;
    return data
        .map((item) =>
            FederatedParticipant.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<FederatedParticipant> getParticipantById(String id) async {
    final response = await _api.client
        .get(Uri.parse('${ApiRoutes.federatedParticipants}/$id'));
    if (response.statusCode != 200) {
      throw Exception(response.body);
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return FederatedParticipant.fromJson(data);
  }

  Future<String> createParticipant(FederatedParticipant participant) async {
    final response = await _api.client.post(
      Uri.parse(ApiRoutes.federatedParticipants),
      body: jsonEncode(participant.toJson()),
    );
    if (response.statusCode != 201) {
      throw Exception(response.body);
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return data['id'];
  }

  Future<void> updateParticipant(FederatedParticipant participant) async {
    final response = await _api.client.put(
      Uri.parse('${ApiRoutes.federatedParticipants}/${participant.id}'),
      body: jsonEncode(participant.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception(response.body);
    }
  }

  Future<void> deleteParticipant(String id) async {
    final response = await _api.client
        .delete(Uri.parse('${ApiRoutes.federatedParticipants}/$id'));
    if (response.statusCode != 200) {
      throw Exception(response.body);
    }
  }

  Future<DidDocumentData> getDidDocument(String id) async {
    final response = await _api.client.get(
      Uri.parse('${ApiRoutes.federatedParticipants}/$id/did-document'),
    );
    if (response.statusCode != 200) {
      throw Exception(response.body);
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return DidDocumentData.fromJson(data);
  }

  Future<ManualRegistrationData> getManualRegistration(String id) async {
    final response = await _api.client.get(
      Uri.parse('${ApiRoutes.federatedParticipants}/$id/manual-registration'),
    );
    if (response.statusCode != 200) {
      throw Exception(response.body);
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return ManualRegistrationData.fromJson(data);
  }

  Future<DidValidationData> validateDid(String id) async {
    final response = await _api.client.get(
      Uri.parse('${ApiRoutes.federatedParticipants}/$id/validate-did'),
    );
    if (response.statusCode != 200) {
      throw Exception(response.body);
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return DidValidationData.fromJson(data);
  }

  Future<CredentialBundleInfo> issueCredentials(
    String id, {
    String provider = 'upcxels',
    Map<String, dynamic> options = const {},
  }) async {
    final response = await _api.client.post(
      Uri.parse('${ApiRoutes.federatedParticipants}/$id/issue-credentials'),
      body: jsonEncode({
        'provider': provider,
        'options': options,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception(
        _extractError(response, fallback: 'Credential issuance failed'),
      );
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return CredentialBundleInfo.fromJson(
      data['credentials'] as Map<String, dynamic>,
    );
  }

  Future<CredentialBundleInfo> uploadCredentials(
    String id,
    PlatformFile file,
  ) async {
    if (file.bytes == null || file.bytes!.isEmpty) {
      throw Exception('Selected file is empty');
    }

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${ApiRoutes.federatedParticipants}/$id/upload-credentials'),
    );

    if (token != null && token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    request.headers['Accept'] = 'application/json';
    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        file.bytes!,
        filename: file.name,
      ),
    );

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    if (response.statusCode != 200) {
      throw Exception(
        _extractError(response, fallback: 'Credential upload failed'),
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return CredentialBundleInfo.fromJson(
      data['credentials'] as Map<String, dynamic>,
    );
  }

  Future<void> downloadCredentials(
    String id, {
    String suggestedFileName = 'credentials.zip',
  }) async {
    final response = await _api.client.get(
      Uri.parse('${ApiRoutes.federatedParticipants}/$id/download-credentials'),
    );
    if (response.statusCode != 200) {
      throw Exception(
        _extractError(response, fallback: 'Credential download failed'),
      );
    }

    final blob = html.Blob([response.bodyBytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', suggestedFileName)
      ..click();
    html.Url.revokeObjectUrl(url);
  }

  Future<CredentialBundleInfo> importCredentialsToConnector(String id) async {
    final response = await _api.client.post(
      Uri.parse(
        '${ApiRoutes.federatedParticipants}/$id/import-credentials-to-connector',
      ),
      body: jsonEncode({}),
    );
    if (response.statusCode != 200) {
      throw Exception(
        _extractError(response, fallback: 'Credential import failed'),
      );
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return CredentialBundleInfo.fromJson(
      data['credentials'] as Map<String, dynamic>,
    );
  }
}
