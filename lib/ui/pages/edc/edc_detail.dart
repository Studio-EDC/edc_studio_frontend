// ignore_for_file: use_build_context_synchronously

import 'package:easy_localization/easy_localization.dart';
import 'package:edc_studio/api/models/connector.dart';
import 'package:edc_studio/api/services/edc_service.dart';
import 'package:edc_studio/ui/widgets/header.dart';
import 'package:edc_studio/ui/widgets/loader.dart';
import 'package:edc_studio/ui/widgets/menu_drawer.dart';
import 'package:edc_studio/ui/widgets/snack_bar.dart';
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

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _apiKeyController = TextEditingController();
  final _managementEndpointUrlController = TextEditingController();
  final _protocolEndpointUrlController = TextEditingController();
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

                // Inicializar solo una vez
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
                            Text('connector_detail_page.title'.tr(),
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Theme.of(context).colorScheme.primary,
                                )),
                            const SizedBox(height: 24),

                            // Mode
                            Text('connector_detail_page.mode_question'.tr(),
                                style: TextStyle(fontSize: 15, color: Theme.of(context).colorScheme.secondary)),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Radio<String>(
                                  value: 'managed',
                                  groupValue: _mode,
                                  onChanged: (value) => setState(() => _mode = value!),
                                ),
                                Text('connector_detail_page.managed'.tr(), style: TextStyle(fontSize: 15, color: Theme.of(context).colorScheme.secondary)),
                                const SizedBox(width: 24),
                                Radio<String>(
                                  value: 'remote',
                                  groupValue: _mode,
                                  onChanged: (value) => setState(() => _mode = value!),
                                ),
                                Text('connector_detail_page.remote'.tr(), style: TextStyle(fontSize: 15, color: Theme.of(context).colorScheme.secondary)),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Name
                            TextFormField(
                              controller: _nameController,
                              decoration: _inputStyle('connector_detail_page.name'.tr()),
                            ),
                            const SizedBox(height: 16),

                            // Description
                            TextFormField(
                              controller: _descriptionController,
                              decoration: _inputStyle('connector_detail_page.description'.tr()),
                            ),
                            const SizedBox(height: 24),

                            // Type
                            Text('connector_detail_page.connector_type'.tr(), style: TextStyle(fontSize: 15, color: Theme.of(context).colorScheme.secondary)),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Radio<String>(
                                  value: 'consumer',
                                  groupValue: _connectorType,
                                  onChanged: (value) => setState(() => _connectorType = value!),
                                ),
                                Text('connector_detail_page.consumer'.tr(), style: TextStyle(fontSize: 15, color: Theme.of(context).colorScheme.secondary)),
                                const SizedBox(width: 24),
                                Radio<String>(
                                  value: 'provider',
                                  groupValue: _connectorType,
                                  onChanged: (value) => setState(() => _connectorType = value!),
                                ),
                                Text('connector_detail_page.provider'.tr(), style: TextStyle(fontSize: 15, color: Theme.of(context).colorScheme.secondary)),
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
                                      );
                                    }

                                    final updatedConnector = Connector(
                                      id: widget.id,
                                      name: _nameController.text,
                                      description: _descriptionController.text,
                                      type: _connectorType,
                                      mode: _mode,
                                      ports: portConfig,
                                      api_key: _apiKeyController.text.isNotEmpty
                                          ? _apiKeyController.text
                                          : null,
                                      state: connector.state,
                                      endpoints_url: endpoints,
                                      domain: _domainController.text.isNotEmpty ? _domainController.text : ''
                                    );

                                    showLoader(context);
                                    final response = await _edcService.updateConnectorByID(widget.id, updatedConnector);
                                    if (response == true) {
                                      FloatingSnackBar.show(
                                        context,
                                        message: 'connector_detail_page.success'.tr(),
                                        type: SnackBarType.success,
                                        duration: Duration(seconds: 3),
                                      );
                                      hideLoader(context);
                                    } else {
                                      FloatingSnackBar.show(
                                        context,
                                        message: 'connector_detail_page.error'.tr(),
                                        type: SnackBarType.error,
                                        duration: Duration(seconds: 3),
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
                                child: Text('update'.tr(), style: TextStyle(color: Colors.white, fontSize: 15)),
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