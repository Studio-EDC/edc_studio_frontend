// ignore_for_file: use_build_context_synchronously

import 'package:easy_localization/easy_localization.dart';
import 'package:edc_studio/api/models/connector.dart';
import 'package:edc_studio/api/services/edc_service.dart';
import 'package:edc_studio/ui/widgets/header.dart';
import 'package:edc_studio/ui/widgets/loader.dart';
import 'package:edc_studio/ui/widgets/menu_drawer.dart';
import 'package:edc_studio/ui/widgets/snack_bar.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class EDCDetailPage extends StatefulWidget {
  const EDCDetailPage({super.key, required this.id});
  final String id;

  @override
  State<EDCDetailPage> createState() => _EDCDetailPageState();
}

class _EDCDetailPageState extends State<EDCDetailPage> {
  final EdcService _edcService = EdcService();
  late Future<Connector?> _connectorFuture;

  final _formKey = GlobalKey<FormState>();

  String _mode = 'managed';
  String _connectorType = 'consumer';
  bool _importingCredentials = false;

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _apiKeyController = TextEditingController();
  final _managementEndpointUrlController = TextEditingController();
  final _protocolEndpointUrlController = TextEditingController();
  final _publicEndpointUrlController = TextEditingController();
  final _domainController = TextEditingController();

  final _portControllers = {
    'http': TextEditingController(),
    'management': TextEditingController(),
    'protocol': TextEditingController(),
    'public': TextEditingController(),
    'control': TextEditingController(),
    'version': TextEditingController(),
  };

  @override
  void initState() {
    super.initState();
    _connectorFuture = _edcService.getConnectorByID(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      endDrawer: const MenuDrawer(),
      body: Column(
        children: [
          EDCHeader(currentPage: 'Connector Details'),
          Expanded(
            child: FutureBuilder<Connector?>(
              future: _connectorFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData) {
                  return Center(child: Text('connector_detail_page.not_found'.tr()));
                }

                final connector = snapshot.data!;

                if (_nameController.text.isEmpty) {
                  _nameController.text = connector.name;
                  _descriptionController.text = connector.description ?? '';
                  _connectorType = connector.type;
                  _mode = connector.mode;
                  _domainController.text = connector.domain ?? '';

                  if (connector.mode == 'managed' && connector.ports != null) {
                    _portControllers['http']!.text = connector.ports!.http.toString();
                    _portControllers['management']!.text = connector.ports!.management.toString();
                    _portControllers['protocol']!.text = connector.ports!.protocol.toString();
                    _portControllers['control']!.text = connector.ports!.control.toString();
                    _portControllers['public']!.text = connector.ports!.public.toString();
                    _portControllers['version']!.text = connector.ports!.version.toString();
                    _apiKeyController.text = connector.api_key ?? '';
                  }

                  if (connector.mode == 'remote' && connector.endpoints_url != null) {
                    _managementEndpointUrlController.text = connector.endpoints_url!.management;
                    _protocolEndpointUrlController.text = connector.endpoints_url!.protocol ?? '';
                    _publicEndpointUrlController.text = connector.endpoints_url!.public ?? '';
                  }
                }

                return ScrollConfiguration(
                  behavior: const ScrollBehavior().copyWith(overscroll: false, scrollbars: false),
                  child: SingleChildScrollView(
                    child: Container(
                      margin: isMobile ? const EdgeInsets.all(10) : const EdgeInsets.only(top: 40),
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
                              'connector_detail_page.title'.tr(),
                              style: TextStyle(
                                fontSize: 20,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'connector_detail_page.mode_question'.tr(),
                              style: TextStyle(fontSize: 15, color: Theme.of(context).colorScheme.secondary),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Radio<String>(
                                  value: 'managed',
                                  groupValue: _mode,
                                  onChanged: (value) => setState(() => _mode = value!),
                                ),
                                Text(
                                  'connector_detail_page.managed'.tr(),
                                  style: TextStyle(fontSize: 15, color: Theme.of(context).colorScheme.secondary),
                                ),
                                const SizedBox(width: 24),
                                Radio<String>(
                                  value: 'remote',
                                  groupValue: _mode,
                                  onChanged: (value) => setState(() => _mode = value!),
                                ),
                                Text(
                                  'connector_detail_page.remote'.tr(),
                                  style: TextStyle(fontSize: 15, color: Theme.of(context).colorScheme.secondary),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            TextFormField(
                              controller: _nameController,
                              decoration: _inputStyle('connector_detail_page.name'.tr()),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _descriptionController,
                              decoration: _inputStyle('connector_detail_page.description'.tr()),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'connector_detail_page.connector_type'.tr(),
                              style: TextStyle(fontSize: 15, color: Theme.of(context).colorScheme.secondary),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Radio<String>(
                                  value: 'consumer',
                                  groupValue: _connectorType,
                                  onChanged: (value) => setState(() => _connectorType = value!),
                                ),
                                Text(
                                  'connector_detail_page.consumer'.tr(),
                                  style: TextStyle(fontSize: 15, color: Theme.of(context).colorScheme.secondary),
                                ),
                                const SizedBox(width: 24),
                                Radio<String>(
                                  value: 'provider',
                                  groupValue: _connectorType,
                                  onChanged: (value) => setState(() => _connectorType = value!),
                                ),
                                Text(
                                  'connector_detail_page.provider'.tr(),
                                  style: TextStyle(fontSize: 15, color: Theme.of(context).colorScheme.secondary),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            if (_mode == 'managed') ...[
                              buildPortInputs(isMobile),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _apiKeyController,
                                obscureText: true,
                                decoration: _inputStyle('connector_detail_page.api_key'.tr()),
                              ),
                              const SizedBox(height: 16),
                              Text('connector_detail_page.domain_explanation'.tr()),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _domainController,
                                decoration: _inputStyle('connector_detail_page.domain'.tr()),
                              ),
                            ] else if (_mode == 'remote') ...[
                              TextFormField(
                                controller: _managementEndpointUrlController,
                                decoration: _inputStyle('connector_detail_page.management_url'.tr()),
                                keyboardType: TextInputType.url,
                              ),
                              if (_connectorType == 'provider') ...[
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _protocolEndpointUrlController,
                                  decoration: _inputStyle('connector_detail_page.protocol_url'.tr()),
                                  keyboardType: TextInputType.url,
                                ),
                              ],
                              if (_connectorType == 'provider') ...[
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _publicEndpointUrlController,
                                  decoration: _inputStyle('connector_detail_page.public_url'.tr()),
                                  keyboardType: TextInputType.url,
                                ),
                              ],
                            ],
                            if (connector.mode == 'managed') ...[
                              const SizedBox(height: 32),
                              _buildIdentityHubSection(connector),
                            ],
                            const SizedBox(height: 32),
                            Center(
                              child: ElevatedButton(
                                onPressed: () async {
                                  if (_formKey.currentState!.validate()) {
                                    PortConfig? portConfig;
                                    Endpoints? endpoints;

                                    if (_mode == 'managed') {
                                      portConfig = PortConfig(
                                        http: int.parse(_portControllers['http']!.text),
                                        management: int.parse(_portControllers['management']!.text),
                                        protocol: int.parse(_portControllers['protocol']!.text),
                                        control: int.parse(_portControllers['control']!.text),
                                        public: int.parse(_portControllers['public']!.text),
                                        version: int.parse(_portControllers['version']!.text),
                                      );
                                    }

                                    if (_mode == 'remote') {
                                      endpoints = Endpoints(
                                        management: _managementEndpointUrlController.text,
                                        protocol: _protocolEndpointUrlController.text.isNotEmpty
                                            ? _protocolEndpointUrlController.text
                                            : null,
                                        public: _publicEndpointUrlController.text.isNotEmpty
                                            ? _publicEndpointUrlController.text
                                            : null,
                                      );
                                    }

                                    final updatedConnector = Connector(
                                      id: widget.id,
                                      name: _nameController.text,
                                      description: _descriptionController.text,
                                      type: _connectorType,
                                      mode: _mode,
                                      ports: portConfig,
                                      api_key: _apiKeyController.text.isNotEmpty ? _apiKeyController.text : null,
                                      state: connector.state,
                                      endpoints_url: endpoints,
                                      domain: _domainController.text.isNotEmpty ? _domainController.text : '',
                                      identity_hub: connector.identity_hub,
                                    );

                                    showLoader(context);
                                    final response = await _edcService.updateConnectorByID(widget.id, updatedConnector);
                                    if (response == true) {
                                      FloatingSnackBar.show(
                                        context,
                                        message: 'connector_detail_page.success'.tr(),
                                        type: SnackBarType.success,
                                        duration: const Duration(seconds: 3),
                                      );
                                      hideLoader(context);
                                    } else {
                                      FloatingSnackBar.show(
                                        context,
                                        message: 'connector_detail_page.error'.tr(),
                                        type: SnackBarType.error,
                                        duration: const Duration(seconds: 3),
                                      );
                                      hideLoader(context);
                                    }

                                    context.go('/');
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(context).colorScheme.primary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                                ),
                                child: Text('update'.tr(), style: const TextStyle(color: Colors.white, fontSize: 15)),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildPortInputs(bool isMobile) {
    final items = _portControllers.entries.toList();
    if (isMobile) {
      return Wrap(
        spacing: 16,
        runSpacing: 16,
        children: items.map((entry) {
          final label = 'connector_detail_page.ports.${entry.key}'.tr();
          return SizedBox(
            width: double.infinity,
            child: TextFormField(
              controller: entry.value,
              decoration: _inputStyle(label),
              keyboardType: TextInputType.number,
            ),
          );
        }).toList(),
      );
    } else {
      const itemsPerRow = 3;
      List<Row> rows = [];

      for (var i = 0; i < items.length; i += itemsPerRow) {
        final rowItems = items.skip(i).take(itemsPerRow).map((entry) {
          final label = 'connector_detail_page.ports.${entry.key}'.tr();
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: TextFormField(
                controller: entry.value,
                decoration: _inputStyle(label),
                keyboardType: TextInputType.number,
              ),
            ),
          );
        }).toList();

        rows.add(Row(children: rowItems));
      }

      return Column(
        children: rows
            .map((row) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: row,
                ))
            .toList(),
      );
    }
  }

  Widget _buildIdentityHubSection(Connector connector) {
    final identityHub = connector.identity_hub;
    final credentials = identityHub?.credentials ?? const <IdentityCredentialSummary>[];
    final importedAt = identityHub?.imported_at;
    final formattedImportedAt = importedAt == null || importedAt.isEmpty
        ? null
        : importedAt.replaceFirst('T', ' ').replaceFirst('Z', '');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFD),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Theme.of(context).colorScheme.tertiary),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'connector_detail_page.identity_hub.title'.tr(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'connector_detail_page.identity_hub.description'.tr(),
            style: TextStyle(color: Theme.of(context).colorScheme.secondary),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildStatusChip(
                identityHub?.enabled == true
                    ? 'connector_detail_page.identity_hub.status_imported'.tr()
                    : 'connector_detail_page.identity_hub.status_pending'.tr(),
                identityHub?.enabled == true ? Colors.green.shade700 : Colors.orange.shade700,
              ),
              _buildStatusChip(
                identityHub?.vault_enabled == true
                    ? 'connector_detail_page.identity_hub.vault_enabled'.tr()
                    : 'connector_detail_page.identity_hub.vault_pending'.tr(),
                identityHub?.vault_enabled == true ? Colors.blue.shade700 : Colors.grey.shade700,
              ),
              _buildStatusChip(
                identityHub?.runtime_prepared == true
                    ? 'connector_detail_page.identity_hub.runtime_ready'.tr()
                    : 'connector_detail_page.identity_hub.runtime_pending'.tr(),
                identityHub?.runtime_prepared == true ? Colors.teal.shade700 : Colors.grey.shade700,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 24,
            runSpacing: 16,
            children: [
              _buildInfoItem(
                'connector_detail_page.identity_hub.bundle'.tr(),
                identityHub?.bundle_file_name ?? 'connector_detail_page.identity_hub.not_imported'.tr(),
              ),
              _buildInfoItem(
                'connector_detail_page.identity_hub.participant_did'.tr(),
                identityHub?.participant_context_did ?? '-',
              ),
              _buildInfoItem(
                'connector_detail_page.identity_hub.imported_at'.tr(),
                formattedImportedAt ?? '-',
              ),
              _buildInfoItem(
                'connector_detail_page.identity_hub.imported_by'.tr(),
                identityHub?.imported_by ?? '-',
              ),
              _buildInfoItem(
                'connector_detail_page.identity_hub.credential_count'.tr(),
                '${identityHub?.credential_count ?? 0}',
              ),
            ],
          ),
          if (identityHub?.restart_required == true) ...[
            const SizedBox(height: 16),
            Text(
              'connector_detail_page.identity_hub.restart_required'.tr(),
              style: TextStyle(
                color: Colors.orange.shade900,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          if (identityHub?.last_error != null && identityHub!.last_error!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(identityHub.last_error!, style: const TextStyle(color: Colors.red)),
          ],
          const SizedBox(height: 20),
          Text(
            'connector_detail_page.identity_hub.credentials'.tr(),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 12),
          if (credentials.isEmpty)
            Text(
              'connector_detail_page.identity_hub.no_credentials'.tr(),
              style: TextStyle(color: Theme.of(context).colorScheme.secondary),
            )
          else
            Column(
              children: credentials
                  .map(
                    (credential) => Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            credential.file_name,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            credential.credential_type ?? '-',
                            style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                          ),
                          if (credential.subject_id != null && credential.subject_id!.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              credential.subject_id!,
                              style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                            ),
                          ],
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerLeft,
            child: ElevatedButton.icon(
              onPressed: _importingCredentials ? null : _importCredentialsZip,
              icon: _importingCredentials
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.upload_file),
              label: Text(
                _importingCredentials
                    ? 'connector_detail_page.identity_hub.importing'.tr()
                    : 'connector_detail_page.identity_hub.import_button'.tr(),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return SizedBox(
      width: 220,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(value),
        ],
      ),
    );
  }

  Future<void> _importCredentialsZip() async {
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['zip'],
      withData: true,
    );
    if (picked == null || picked.files.isEmpty) {
      return;
    }

    setState(() => _importingCredentials = true);
    final error = await _edcService.importIdentityHubCredentials(widget.id, picked.files.single);
    if (!mounted) {
      return;
    }

    setState(() => _importingCredentials = false);
    if (error == null) {
      FloatingSnackBar.show(
        context,
        message: 'connector_detail_page.identity_hub.import_success'.tr(),
        type: SnackBarType.success,
        duration: const Duration(seconds: 3),
      );
      setState(() {
        _connectorFuture = _edcService.getConnectorByID(widget.id);
      });
      return;
    }

    FloatingSnackBar.show(
      context,
      message: '${'connector_detail_page.identity_hub.import_error'.tr()}: $error',
      type: SnackBarType.error,
      duration: const Duration(seconds: 4),
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
