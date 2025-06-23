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

class NewEDCPage extends StatefulWidget {
  const NewEDCPage({super.key});

  @override
  State<NewEDCPage> createState() => _NewEDCPageState();
}

class _NewEDCPageState extends State<NewEDCPage> {

  final EdcService _edcService = EdcService();
  
  final _formKey = GlobalKey<FormState>();

  // Controllers
  String _mode = 'managed';
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _apikeyController = TextEditingController();
  final _managementEndpointUrlController = TextEditingController();
  final _protocolEndpointUrlController = TextEditingController();

  final _portControllers = {
    'http': TextEditingController(),
    'management': TextEditingController(),
    'protocol': TextEditingController(),
    'public': TextEditingController(),
    'control': TextEditingController(),
    'version': TextEditingController(),
  };

  String _connectorType = 'consumer';

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      endDrawer: const MenuDrawer(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            EDCHeader(currentPage: 'New EDC'),
            Expanded(
              child: ScrollConfiguration(
                behavior: const ScrollBehavior().copyWith(overscroll: false, scrollbars: false),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        margin: isMobile 
                          ? const EdgeInsets.all(10) 
                          : const EdgeInsets.only(top: 40),
                        //height: 700,
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
                                'new_connector_page.title'.tr(),
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
                  
                              // Radio
                              Text('connector_detail_page.connector_type'.tr(), style: TextStyle(fontSize: 15, color: Theme.of(context).colorScheme.secondary)),
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
                                  controller: _apikeyController,
                                  obscureText: true,
                                  decoration: _inputStyle('connector_detail_page.api_key'.tr()),
                                ),
                              ] else if (_mode == 'remote') ...[
                                TextFormField(
                                  controller: _managementEndpointUrlController,
                                  decoration: _inputStyle('connector_detail_page.management_url'.tr()),
                                  keyboardType: TextInputType.url,
                                ),
                                if (_connectorType == 'provider')
                                const SizedBox(height: 16),
                                if (_connectorType == 'provider')
                                TextFormField(
                                  controller: _protocolEndpointUrlController,
                                  decoration: _inputStyle('connector_detail_page.protocol_url'.tr()),
                                  keyboardType: TextInputType.url,
                                ),
                              ],
                  
                              const SizedBox(height: 32),
                  
                              Center(
                                child: ElevatedButton(
                                  onPressed: () async {
                                    if (_formKey.currentState!.validate()) {
                                      PortConfig? portConfig;

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

                                      Endpoints? endpoints;

                                      if (_mode == 'remote') {
                                        endpoints = Endpoints(
                                          management: _managementEndpointUrlController.text, 
                                          protocol: _protocolEndpointUrlController.text.isNotEmpty ? _protocolEndpointUrlController.text : null
                                        );
                                      }
                  
                                      Connector connector = Connector(
                                        id: '', 
                                        name: _nameController.text,
                                        description: _descriptionController.text,
                                        type: _connectorType,
                                        mode: _mode,
                                        ports: portConfig,
                                        api_key: _apikeyController.text.isNotEmpty ? _apikeyController.text : null,
                                        state: 'stopped',
                                        endpoints_url: endpoints
                                      );
                  
                                      showLoader(context);
                                      final response = await _edcService.createConnector(connector);
                                      if (response != null) {
                                        hideLoader(context);
                                        FloatingSnackBar.show(
                                          context,
                                          message: 'new_connector_page.success'.tr(),
                                          type: SnackBarType.success,
                                          width: 320,
                                          duration: Duration(seconds: 3),
                                        );
                                      } else {
                                        hideLoader(context);
                                        FloatingSnackBar.show(
                                          context,
                                          message: 'new_connector_page.error'.tr(),
                                          type: SnackBarType.error,
                                          width: 320,
                                          duration: Duration(seconds: 3),
                                        );
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
                                  child: Text('create'.tr(), style: TextStyle(color: Colors.white, fontSize: 15)),
                                ),
                              )
                            ],
                          ),
                        ),
                      )
                    ]
                  ),
                ),
              )
            )
          ]
        )
      ),
    );
  }

  Widget buildPortInputs(bool isMobile) {
    final items = _portControllers.entries.toList();
    if (isMobile) {
      // En móvil, usar Wrap normal
      return Wrap(
        spacing: 16,
        runSpacing: 16,
        children: items.map((entry) {
          final label = '${entry.key[0].toUpperCase()}${entry.key.substring(1)} Port';
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
      // En escritorio, agrupar por filas de 3 elementos
      const itemsPerRow = 3;
      List<Row> rows = [];

      for (var i = 0; i < items.length; i += itemsPerRow) {
        final rowItems = items.skip(i).take(itemsPerRow).map((entry) {
          final label = '${entry.key[0].toUpperCase()}${entry.key.substring(1)} Port';
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

        rows.add(Row(
          children: rowItems,
        ));
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

