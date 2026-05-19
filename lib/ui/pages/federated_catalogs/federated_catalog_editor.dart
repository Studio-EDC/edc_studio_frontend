// ignore_for_file: use_build_context_synchronously

import 'package:easy_localization/easy_localization.dart';
import 'package:edc_studio/api/models/connector.dart';
import 'package:edc_studio/api/models/federated_catalog_instance.dart';
import 'package:edc_studio/api/services/edc_service.dart';
import 'package:edc_studio/api/services/federated_catalog_instances_service.dart';
import 'package:edc_studio/ui/widgets/header.dart';
import 'package:edc_studio/ui/widgets/loader.dart';
import 'package:edc_studio/ui/widgets/menu_drawer.dart';
import 'package:edc_studio/ui/widgets/snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class FederatedCatalogEditorPage extends StatefulWidget {
  final String? instanceId;

  const FederatedCatalogEditorPage({super.key, this.instanceId});

  @override
  State<FederatedCatalogEditorPage> createState() =>
      _FederatedCatalogEditorPageState();
}

class _FederatedCatalogEditorPageState
    extends State<FederatedCatalogEditorPage> {
  final FederatedCatalogInstancesService _service =
      FederatedCatalogInstancesService();
  final EdcService _edcService = EdcService();
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _slugController = TextEditingController();
  final _apiPortController = TextEditingController(text: '8281');
  final _catalogPortController = TextEditingController(text: '8283');
  final _publicBaseUrlController =
      TextEditingController(text: 'https://api.edcstudio.datagora.eu');
  final _queryPathPrefixController = TextEditingController(text: 'fc');
  final _healthPathPrefixController = TextEditingController(text: 'fc-health');
  final _participantIdController = TextEditingController();
  final _refreshSecondsController = TextEditingController(text: '60');
  final _connectTimeoutController = TextEditingController(text: '10');
  final _readTimeoutController = TextEditingController(text: '30');

  String _providerScopeMode = 'all';
  List<Connector> _providerConnectors = [];
  final Set<String> _selectedProviderIds = {};
  FederatedCatalogInstance? _loadedInstance;

  bool get _isEditing => widget.instanceId != null;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _slugController.dispose();
    _apiPortController.dispose();
    _catalogPortController.dispose();
    _publicBaseUrlController.dispose();
    _queryPathPrefixController.dispose();
    _healthPathPrefixController.dispose();
    _participantIdController.dispose();
    _refreshSecondsController.dispose();
    _connectTimeoutController.dispose();
    _readTimeoutController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final connectors = await _edcService.getAllConnectors() ?? [];
    _providerConnectors =
        connectors.where((connector) => connector.type == 'provider').toList();

    if (_isEditing) {
      final instance = await _service.getInstanceById(widget.instanceId!);
      if (instance != null) {
        _loadedInstance = instance;
        _nameController.text = instance.name;
        _slugController.text = instance.slug;
        _apiPortController.text = instance.api_port.toString();
        _catalogPortController.text = instance.catalog_port.toString();
        _publicBaseUrlController.text = instance.public_base_url;
        _queryPathPrefixController.text = instance.query_path_prefix;
        _healthPathPrefixController.text = instance.health_path_prefix;
        _participantIdController.text = instance.participant_id;
        _refreshSecondsController.text = instance.refresh_seconds.toString();
        _connectTimeoutController.text =
            instance.connect_timeout_seconds.toString();
        _readTimeoutController.text = instance.read_timeout_seconds.toString();
        _providerScopeMode = instance.provider_scope_mode;
        _selectedProviderIds
          ..clear()
          ..addAll(instance.selected_provider_connector_ids);
      }
    }

    if (mounted) {
      setState(() {});
    }
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'required_field'.tr();
    }
    return null;
  }

  String? _numberRequired(String? value) {
    final required = _required(value);
    if (required != null) {
      return required;
    }
    return int.tryParse(value!.trim()) == null ? 'required_field'.tr() : null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final instance = FederatedCatalogInstance(
      id: _loadedInstance?.id ?? '',
      name: _nameController.text.trim(),
      slug: _slugController.text.trim(),
      state: _loadedInstance?.state ?? 'stopped',
      api_port: int.parse(_apiPortController.text.trim()),
      catalog_port: int.parse(_catalogPortController.text.trim()),
      public_base_url: _publicBaseUrlController.text.trim(),
      query_path_prefix: _queryPathPrefixController.text.trim(),
      health_path_prefix: _healthPathPrefixController.text.trim(),
      participant_id: _participantIdController.text.trim(),
      refresh_seconds: int.parse(_refreshSecondsController.text.trim()),
      connect_timeout_seconds: int.parse(_connectTimeoutController.text.trim()),
      read_timeout_seconds: int.parse(_readTimeoutController.text.trim()),
      provider_scope_mode: _providerScopeMode,
      selected_provider_connector_ids:
          _providerScopeMode == 'selected' ? _selectedProviderIds.toList() : [],
      container_name: _loadedInstance?.container_name ?? '',
      runtime_dir: _loadedInstance?.runtime_dir ?? '',
      catalog_base_url: _loadedInstance?.catalog_base_url ?? '',
      query_url: _loadedInstance?.query_url ?? '',
      health_url: _loadedInstance?.health_url ?? '',
      nginx_snippet_path: _loadedInstance?.nginx_snippet_path ?? '',
      last_error: _loadedInstance?.last_error,
      created_at: _loadedInstance?.created_at,
      updated_at: _loadedInstance?.updated_at,
    );

    showLoader(context);
    final error = _isEditing
        ? await _service.updateInstance(instance)
        : await _service.createInstance(instance);
    hideLoader(context);

    if (error == null) {
      FloatingSnackBar.show(
        context,
        message: _isEditing
            ? 'federated_catalogs.updated'.tr()
            : 'federated_catalogs.created'.tr(),
        type: SnackBarType.success,
      );
      context.go('/federated-catalogs');
      return;
    }

    FloatingSnackBar.show(
      context,
      message: '${'federated_catalogs.actions_error'.tr()}: $error',
      type: SnackBarType.error,
      width: 420,
      duration: const Duration(seconds: 4),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      endDrawer: const MenuDrawer(),
      body: Center(
        child: Column(
          children: [
            const EDCHeader(currentPage: 'federated_catalogs'),
            Expanded(
              child: SingleChildScrollView(
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
                          _isEditing
                              ? 'federated_catalogs.edit_title'.tr()
                              : 'federated_catalogs.new_title'.tr(),
                          style: TextStyle(
                            fontSize: 20,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildTextField(
                          controller: _nameController,
                          label: 'federated_catalogs.fields.name'.tr(),
                          validator: _required,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _slugController,
                          label: 'federated_catalogs.fields.slug'.tr(),
                          validator: _required,
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          children: [
                            SizedBox(
                              width: isMobile ? double.infinity : 240,
                              child: _buildTextField(
                                controller: _apiPortController,
                                label: 'federated_catalogs.fields.api_port'.tr(),
                                validator: _numberRequired,
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            SizedBox(
                              width: isMobile ? double.infinity : 240,
                              child: _buildTextField(
                                controller: _catalogPortController,
                                label:
                                    'federated_catalogs.fields.catalog_port'
                                        .tr(),
                                validator: _numberRequired,
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _publicBaseUrlController,
                          label:
                              'federated_catalogs.fields.public_base_url'.tr(),
                          validator: _required,
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          children: [
                            SizedBox(
                              width: isMobile ? double.infinity : 240,
                              child: _buildTextField(
                                controller: _queryPathPrefixController,
                                label:
                                    'federated_catalogs.fields.query_prefix'.tr(),
                                validator: _required,
                              ),
                            ),
                            SizedBox(
                              width: isMobile ? double.infinity : 240,
                              child: _buildTextField(
                                controller: _healthPathPrefixController,
                                label: 'federated_catalogs.fields.health_prefix'
                                    .tr(),
                                validator: _required,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _participantIdController,
                          label:
                              'federated_catalogs.fields.participant_id'.tr(),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          children: [
                            SizedBox(
                              width: isMobile ? double.infinity : 240,
                              child: _buildTextField(
                                controller: _refreshSecondsController,
                                label:
                                    'federated_catalogs.fields.refresh_seconds'
                                        .tr(),
                                validator: _numberRequired,
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            SizedBox(
                              width: isMobile ? double.infinity : 240,
                              child: _buildTextField(
                                controller: _connectTimeoutController,
                                label: 'federated_catalogs.fields.connect_timeout'
                                    .tr(),
                                validator: _numberRequired,
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            SizedBox(
                              width: isMobile ? double.infinity : 240,
                              child: _buildTextField(
                                controller: _readTimeoutController,
                                label:
                                    'federated_catalogs.fields.read_timeout'
                                        .tr(),
                                validator: _numberRequired,
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'federated_catalogs.scope'.tr(),
                          style: TextStyle(
                            fontSize: 15,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Radio<String>(
                              value: 'all',
                              groupValue: _providerScopeMode,
                              onChanged: (value) {
                                setState(() {
                                  _providerScopeMode = value!;
                                });
                              },
                            ),
                            Text('federated_catalogs.scope_all'.tr()),
                            const SizedBox(width: 24),
                            Radio<String>(
                              value: 'selected',
                              groupValue: _providerScopeMode,
                              onChanged: (value) {
                                setState(() {
                                  _providerScopeMode = value!;
                                });
                              },
                            ),
                            Text(
                              'federated_catalogs.scope_selected_short'.tr(),
                            ),
                          ],
                        ),
                        if (_providerScopeMode == 'selected') ...[
                          const SizedBox(height: 16),
                          Text(
                            'federated_catalogs.providers_hint'.tr(),
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 12),
                          if (_providerConnectors.isEmpty)
                            Text('no_providers'.tr())
                          else
                            Container(
                              constraints:
                                  const BoxConstraints(maxHeight: 280),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .secondary,
                                ),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: ListView(
                                shrinkWrap: true,
                                children: _providerConnectors.map((connector) {
                                  final selected =
                                      _selectedProviderIds.contains(connector.id);
                                  return CheckboxListTile(
                                    value: selected,
                                    title: Text(connector.name),
                                    subtitle: Text(
                                      connector.participant_id ?? connector.id,
                                    ),
                                    onChanged: (value) {
                                      setState(() {
                                        if (value == true) {
                                          _selectedProviderIds.add(connector.id);
                                        } else {
                                          _selectedProviderIds.remove(
                                            connector.id,
                                          );
                                        }
                                      });
                                    },
                                  );
                                }).toList(),
                              ),
                            ),
                        ],
                        if (_isEditing && _loadedInstance != null) ...[
                          const SizedBox(height: 24),
                          Text(
                            '${'federated_catalogs.catalog_url'.tr()}: ${_loadedInstance!.catalog_base_url}',
                          ),
                          Text(
                            '${'federated_catalogs.health_url'.tr()}: ${_loadedInstance!.health_url}',
                          ),
                          Text(
                            '${'federated_catalogs.container_name'.tr()}: ${_loadedInstance!.container_name}',
                          ),
                          if ((_loadedInstance!.last_error ?? '').isNotEmpty)
                            Text(
                              '${'federated_catalogs.last_error'.tr()}: ${_loadedInstance!.last_error}',
                              style: const TextStyle(color: Colors.red),
                            ),
                        ],
                        const SizedBox(height: 32),
                        Center(
                          child: ElevatedButton(
                            onPressed: _save,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 14,
                              ),
                            ),
                            child: Text(
                              _isEditing ? 'update'.tr() : 'create'.tr(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    final theme = Theme.of(context);

    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: theme.colorScheme.secondary),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: theme.colorScheme.secondary),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(
            color: theme.colorScheme.primary,
            width: 2.0,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.red.shade700, width: 2.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.red.shade700, width: 2.0),
        ),
      ),
    );
  }
}
