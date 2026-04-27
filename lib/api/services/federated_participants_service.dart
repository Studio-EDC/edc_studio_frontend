import 'dart:convert';

import 'package:edc_studio/api/models/federated_participant.dart';
import 'package:edc_studio/api/utils/api.dart';

class FederatedParticipantsService {
  final MyApi _api = MyApi();

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
}
