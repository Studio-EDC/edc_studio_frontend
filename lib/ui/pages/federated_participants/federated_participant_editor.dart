// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:edc_studio/api/models/connector.dart';
import 'package:edc_studio/api/models/federated_participant.dart';
import 'package:edc_studio/api/services/edc_service.dart';
import 'package:edc_studio/api/services/federated_participants_service.dart';
import 'package:edc_studio/ui/widgets/header.dart';
import 'package:edc_studio/ui/widgets/loader.dart';
import 'package:edc_studio/ui/widgets/menu_drawer.dart';
import 'package:edc_studio/ui/widgets/snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class FederatedParticipantEditorPage extends StatefulWidget {
  const FederatedParticipantEditorPage({super.key, this.participantId});

  final String? participantId;

  @override
  State<FederatedParticipantEditorPage> createState() =>
      _FederatedParticipantEditorPageState();
}

class _FederatedParticipantEditorPageState
    extends State<FederatedParticipantEditorPage> {
  final FederatedParticipantsService _service = FederatedParticipantsService();
  final EdcService _edcService = EdcService();
  final _formKey = GlobalKey<FormState>();

  final _participantDidController = TextEditingController();
  final _legalNameController = TextEditingController();
  final _lrnValueController = TextEditingController();
  final _hqCountryCodeController = TextEditingController();
  final _legalCountryCodeController = TextEditingController();
  final _publicDomainController = TextEditingController();
  final _protocolEndpointController = TextEditingController();
  final _notesController = TextEditingController();

  List<Connector> _connectors = [];
  String? _selectedConnectorId;
  bool _didPublished = false;
  bool _registeredInEdcManager = false;
  bool _credentialsInstalled = false;
  FederatedParticipant? _participant;
  DidDocumentData? _didDocumentData;
  ManualRegistrationData? _manualRegistrationData;
  DidValidationData? _didValidationData;
  bool _loading = true;

  bool get _isCreate => widget.participantId == null;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final connectors = await _edcService.getAllConnectors() ?? [];
    FederatedParticipant? participant;
    DidDocumentData? didDocumentData;
    ManualRegistrationData? manualRegistrationData;

    if (!_isCreate) {
      participant = await _service.getParticipantById(widget.participantId!);
      didDocumentData = await _service.getDidDocument(widget.participantId!);
      manualRegistrationData =
          await _service.getManualRegistration(widget.participantId!);
      _populateForm(participant, connectors);
    }

    setState(() {
      _connectors = connectors;
      _participant = participant;
      _didDocumentData = didDocumentData;
      _manualRegistrationData = manualRegistrationData;
      _loading = false;
    });
  }

  void _populateForm(
      FederatedParticipant participant, List<Connector> connectors) {
    _participantDidController.text = participant.participantDid;
    _legalNameController.text = participant.legalName;
    _lrnValueController.text = participant.lrnValue;
    _hqCountryCodeController.text = participant.headquarterAddressCountryCode;
    _legalCountryCodeController.text = participant.legalAddressCountryCode;
    _publicDomainController.text = participant.publicDomain;
    _protocolEndpointController.text = participant.protocolEndpoint ?? '';
    _notesController.text = participant.notes ?? '';
    _selectedConnectorId = participant.connectorId;
    _didPublished = participant.checklist.didPublished;
    _registeredInEdcManager = participant.checklist.registeredInEdcManager;
    _credentialsInstalled = participant.checklist.credentialsInstalled;

    for (final connector in connectors) {
      if (connector.id == participant.connectorId) {
        _hydrateFromConnector(connector, force: false);
        break;
      }
    }
  }

  void _hydrateFromConnector(Connector connector, {required bool force}) {
    if (force || _publicDomainController.text.trim().isEmpty) {
      if ((connector.domain ?? '').isNotEmpty) {
        _publicDomainController.text = connector.domain!;
      }
    }

    if (force || _protocolEndpointController.text.trim().isEmpty) {
      if ((connector.endpoints_url?.protocol ?? '').isNotEmpty) {
        _protocolEndpointController.text = connector.endpoints_url!.protocol!;
      } else if ((connector.domain ?? '').isNotEmpty) {
        _protocolEndpointController.text =
            'https://${connector.domain}/protocol';
      }
    }
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'required_field'.tr();
    }
    return null;
  }

  Future<void> _reloadGeneratedData(String id) async {
    final didDocumentData = await _service.getDidDocument(id);
    final manualRegistrationData = await _service.getManualRegistration(id);
    final participant = await _service.getParticipantById(id);
    setState(() {
      _participant = participant;
      _didDocumentData = didDocumentData;
      _manualRegistrationData = manualRegistrationData;
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _selectedConnectorId == null) {
      return;
    }

    final participant = FederatedParticipant(
      id: widget.participantId ?? '',
      participantDid: _participantDidController.text.trim(),
      legalName: _legalNameController.text.trim(),
      lrnValue: _lrnValueController.text.trim(),
      headquarterAddressCountryCode: _hqCountryCodeController.text.trim(),
      legalAddressCountryCode: _legalCountryCodeController.text.trim(),
      connectorId: _selectedConnectorId!,
      publicDomain: _publicDomainController.text.trim(),
      protocolEndpoint: _protocolEndpointController.text.trim().isEmpty
          ? null
          : _protocolEndpointController.text.trim(),
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      checklist: ManualChecklist(
        didPublished: _didPublished,
        registeredInEdcManager: _registeredInEdcManager,
        credentialsInstalled: _credentialsInstalled,
      ),
      status: _participant?.status ?? 'DRAFT',
      createdAt: _participant?.createdAt,
      updatedAt: _participant?.updatedAt,
    );

    showLoader(context);
    try {
      if (_isCreate) {
        final createdId = await _service.createParticipant(participant);
        hideLoader(context);
        FloatingSnackBar.show(
          context,
          message: 'federated_form.created'.tr(),
          type: SnackBarType.success,
          duration: const Duration(seconds: 3),
        );
        context.go('/federated-participants/$createdId');
        return;
      }

      await _service.updateParticipant(participant);
      await _reloadGeneratedData(widget.participantId!);
      hideLoader(context);
      FloatingSnackBar.show(
        context,
        message: 'federated_form.updated'.tr(),
        type: SnackBarType.success,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      hideLoader(context);
      FloatingSnackBar.show(
        context,
        message: '${'general_error'.tr()} $e',
        type: SnackBarType.error,
        duration: const Duration(seconds: 4),
      );
    }
  }

  Future<void> _validateDid() async {
    if (_isCreate || widget.participantId == null) {
      return;
    }

    showLoader(context);
    try {
      final validation = await _service.validateDid(widget.participantId!);
      setState(() {
        _didValidationData = validation;
      });
      hideLoader(context);
    } catch (e) {
      hideLoader(context);
      FloatingSnackBar.show(
        context,
        message: '${'general_error'.tr()} $e',
        type: SnackBarType.error,
        duration: const Duration(seconds: 4),
      );
    }
  }

  Widget _buildJsonPanel(String title, String content) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE1E1E8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          SelectableText(
            content,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildValidationPanel() {
    if (_didValidationData == null) {
      return const SizedBox.shrink();
    }

    final validation = _didValidationData!;
    final rows = <String>[
      'did.json URL: ${validation.didDocumentUrl}',
      'did.json reachable: ${validation.didDocumentReachable}',
      'did.json status: ${validation.didDocumentStatusCode ?? '-'}',
      'DID id matches: ${validation.didDocumentIdMatches}',
      'ProtocolEndpoint found: ${validation.protocolServiceFound}',
      'ProtocolEndpoint matches expected: ${validation.protocolServiceMatchesExpected}',
      'Protocol endpoint reachable: ${validation.protocolEndpointReachable}',
      'Protocol endpoint status: ${validation.protocolEndpointStatusCode ?? '-'}',
      'Resolved protocol endpoint: ${validation.resolvedProtocolEndpoint ?? '-'}',
      'Expected protocol endpoint: ${validation.expectedProtocolEndpoint ?? '-'}',
    ];

    if (validation.errors.isNotEmpty) {
      rows.add('Errors:');
      rows.addAll(validation.errors.map((error) => '- $error'));
    }

    return _buildJsonPanel(
      'federated_form.did_validation'.tr(),
      rows.join('\n'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    Connector? selectedConnector;
    for (final connector in _connectors) {
      if (connector.id == _selectedConnectorId) {
        selectedConnector = connector;
        break;
      }
    }

    return Scaffold(
      endDrawer: const MenuDrawer(),
      body: Column(
        children: [
          const EDCHeader(currentPage: 'federated_participants'),
          if (_loading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else
            Expanded(
              child: SingleChildScrollView(
                child: Center(
                  child: Container(
                    margin: isMobile
                        ? const EdgeInsets.all(10)
                        : const EdgeInsets.only(top: 40, bottom: 40),
                    width: 1070,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(40),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.tertiary,
                        width: 5,
                      ),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isCreate
                                ? 'federated_form.new_title'.tr()
                                : 'federated_form.detail_title'.tr(),
                            style: TextStyle(
                              fontSize: 20,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          if (_participant != null) ...[
                            const SizedBox(height: 8),
                            Text(
                                '${'federated_form.status'.tr()}: ${_participant!.status}'),
                          ],
                          const SizedBox(height: 24),
                          DropdownButtonFormField<String>(
                            value: _connectors.any(
                              (connector) =>
                                  connector.id == _selectedConnectorId,
                            )
                                ? _selectedConnectorId
                                : null,
                            decoration:
                                _inputStyle('federated_form.connector'.tr()),
                            items: _connectors.map((connector) {
                              return DropdownMenuItem<String>(
                                value: connector.id,
                                child: Text(connector.name),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedConnectorId = value;
                                for (final connector in _connectors) {
                                  if (connector.id == value) {
                                    _hydrateFromConnector(connector,
                                        force: false);
                                    break;
                                  }
                                }
                              });
                            },
                            validator: (value) =>
                                value == null ? 'required_field'.tr() : null,
                          ),
                          if (selectedConnector != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              '${selectedConnector.name} (${selectedConnector.type}/${selectedConnector.mode})',
                              style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.secondary),
                            ),
                          ],
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _participantDidController,
                            validator: _requiredValidator,
                            decoration: _inputStyle(
                                'federated_form.participant_did'.tr()),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _legalNameController,
                            validator: _requiredValidator,
                            decoration:
                                _inputStyle('federated_form.legal_name'.tr()),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _lrnValueController,
                            validator: _requiredValidator,
                            decoration: _inputStyle('federated_form.lrn'.tr()),
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 16,
                            runSpacing: 16,
                            children: [
                              SizedBox(
                                width: isMobile ? double.infinity : 494,
                                child: TextFormField(
                                  controller: _hqCountryCodeController,
                                  validator: _requiredValidator,
                                  decoration: _inputStyle(
                                      'federated_form.headquarter_country'
                                          .tr()),
                                ),
                              ),
                              SizedBox(
                                width: isMobile ? double.infinity : 494,
                                child: TextFormField(
                                  controller: _legalCountryCodeController,
                                  validator: _requiredValidator,
                                  decoration: _inputStyle(
                                      'federated_form.legal_country'.tr()),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _publicDomainController,
                            validator: _requiredValidator,
                            decoration: _inputStyle(
                                'federated_form.public_domain'.tr()),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _protocolEndpointController,
                            decoration: _inputStyle(
                                'federated_form.protocol_endpoint'.tr()),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _notesController,
                            maxLines: 3,
                            decoration:
                                _inputStyle('federated_form.notes'.tr()),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'federated_form.checklist'.tr(),
                            style: TextStyle(
                              fontSize: 16,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          CheckboxListTile(
                            value: _didPublished,
                            title: Text('federated_form.did_published'.tr()),
                            contentPadding: EdgeInsets.zero,
                            onChanged: (value) =>
                                setState(() => _didPublished = value ?? false),
                          ),
                          CheckboxListTile(
                            value: _registeredInEdcManager,
                            title: Text('federated_form.registered'.tr()),
                            contentPadding: EdgeInsets.zero,
                            onChanged: (value) => setState(
                                () => _registeredInEdcManager = value ?? false),
                          ),
                          CheckboxListTile(
                            value: _credentialsInstalled,
                            title: Text(
                                'federated_form.credentials_installed'.tr()),
                            contentPadding: EdgeInsets.zero,
                            onChanged: (value) => setState(
                                () => _credentialsInstalled = value ?? false),
                          ),
                          const SizedBox(height: 24),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              ElevatedButton(
                                onPressed: _save,
                                child: Text(
                                    _isCreate ? 'create'.tr() : 'update'.tr()),
                              ),
                              if (!_isCreate)
                                OutlinedButton(
                                  onPressed: _validateDid,
                                  child:
                                      Text('federated_form.validate_did'.tr()),
                                ),
                              OutlinedButton(
                                onPressed: () =>
                                    context.go('/federated-participants'),
                                child: Text('federated_form.back_to_list'.tr()),
                              ),
                            ],
                          ),
                          if (!_isCreate &&
                              _didDocumentData != null &&
                              _manualRegistrationData != null) ...[
                            const SizedBox(height: 32),
                            _buildJsonPanel(
                              'federated_form.did_document'.tr(),
                              const JsonEncoder.withIndent('  ')
                                  .convert(_didDocumentData!.didDocument),
                            ),
                            const SizedBox(height: 16),
                            _buildJsonPanel(
                              'federated_form.did_document_url'.tr(),
                              _didDocumentData!.didDocumentUrl,
                            ),
                            const SizedBox(height: 16),
                            _buildJsonPanel(
                              'federated_form.manual_payload'.tr(),
                              const JsonEncoder.withIndent('  ')
                                  .convert(_manualRegistrationData!.payload),
                            ),
                            const SizedBox(height: 16),
                            _buildJsonPanel(
                              'federated_form.manual_curl'.tr(),
                              _manualRegistrationData!.curlCommand,
                            ),
                            const SizedBox(height: 16),
                            _buildValidationPanel(),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  InputDecoration _inputStyle(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Theme.of(context).colorScheme.secondary),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.primary,
          width: 2.0,
        ),
      ),
    );
  }
}
