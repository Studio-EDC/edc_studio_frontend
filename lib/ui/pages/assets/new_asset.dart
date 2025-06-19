// ignore_for_file: use_build_context_synchronously

import 'package:easy_localization/easy_localization.dart';
import 'package:edc_studio/api/models/asset.dart';
import 'package:edc_studio/api/models/connector.dart';
import 'package:edc_studio/api/services/assets_service.dart';
import 'package:edc_studio/api/services/edc_service.dart';
import 'package:edc_studio/ui/widgets/header.dart';
import 'package:edc_studio/ui/widgets/loader.dart';
import 'package:edc_studio/ui/widgets/menu_drawer.dart';
import 'package:edc_studio/ui/widgets/snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NewAssetPage extends StatefulWidget {
  const NewAssetPage({super.key});

  @override
  State<NewAssetPage> createState() => _NewAssetPageState();
}

class _NewAssetPageState extends State<NewAssetPage> {

  final EdcService _edcService = EdcService();
  final AssetService _assetService = AssetService();

  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _assetIdController = TextEditingController();
  final _nameController = TextEditingController();
  final _contentTypeController = TextEditingController();
  final _dataAddressNameController = TextEditingController();
  final _baseURLController = TextEditingController();

  String edcIdSelected = '';
  String edcStateSelected = '';
  String dataAddressTypeController = 'HttpData';
  String dataAddressProxyController = 'True';

  List<Connector> _allConnectors = [];

  Future<void> _loadConnectors() async {
    final connectors = await _edcService.getAllConnectors();
    if (connectors != null) {
      final providers = connectors.where((c) => c.type == 'provider').toList();

      if (providers.isNotEmpty) {
        setState(() {
          _allConnectors = providers;
          edcIdSelected = providers[0].id;
          edcStateSelected = providers[0].state;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadConnectors();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      endDrawer: const MenuDrawer(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            EDCHeader(currentPage: 'New Asset'),
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
                                'new_asset_page.title'.tr(),
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              const SizedBox(height: 24),

                              Wrap(
                                alignment: WrapAlignment.center,
                                runAlignment: WrapAlignment.center,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: 16,
                                runSpacing: 16,
                                children: [
                                  Text(
                                    'new_asset_page.select_edc'.tr(),
                                    style: TextStyle(fontSize: 15, color: Theme.of(context).colorScheme.secondary),
                                  ),
                                  SizedBox(
                                    width: isMobile ? null : 300,
                                    height: 40,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey),
                                        borderRadius: BorderRadius.circular(32),
                                      ),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          value: edcIdSelected,
                                          icon: const Icon(Icons.arrow_drop_down),
                                          isExpanded: true,
                                          onChanged: (value) {
                                            setState(() {
                                              edcIdSelected = value!;
                                              final selected = _allConnectors.firstWhere((c) => c.id == value);
                                              edcStateSelected = selected.state;
                                            });
                                          },
                                          items: _allConnectors.map((connector) {
                                            return DropdownMenuItem<String>(
                                              value: connector.id,
                                              child: Text(connector.name, style: TextStyle(fontSize: 15, color: Theme.of(context).colorScheme.secondary)),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              if (edcStateSelected == 'stopped')
                              const SizedBox(height: 16),

                              if (edcStateSelected == 'stopped')
                              Text(
                                'new_asset_page.create_req'.tr(),
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.red
                                ),
                              ),

                              const SizedBox(height: 16),

                              Text(
                                'new_asset_page.properties'.tr(),
                                style: TextStyle(fontSize: 15, color: Theme.of(context).colorScheme.secondary)
                              ),

                              const SizedBox(height: 16),

                              Center(
                                child: Wrap(
                                  spacing: 16,
                                  runSpacing: 16,
                                  alignment: WrapAlignment.center,
                                  runAlignment: WrapAlignment.center,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: isMobile ? double.infinity : 320,
                                      child: TextFormField(
                                        controller: _assetIdController,
                                        decoration: _inputStyle('new_asset_page.asset_id'.tr()),
                                      ),
                                    ),
                                    SizedBox(
                                      width: isMobile ? double.infinity : 320,
                                      child: TextFormField(
                                        controller: _nameController,
                                        decoration: _inputStyle('new_asset_page.name'.tr()),
                                      ),
                                    ),
                                    SizedBox(
                                      width: isMobile ? double.infinity : 320,
                                      child: TextFormField(
                                        controller: _contentTypeController,
                                        decoration: _inputStyle('new_asset_page.content_type'.tr()),
                                      ),
                                    ),
                                  ],
                                ),
                              ),


                              const SizedBox(height: 24),
                  
                              // Radio
                              Text('new_asset_page.data_address'.tr(), style: TextStyle(fontSize: 15, color: Theme.of(context).colorScheme.secondary)),

                              const SizedBox(height: 16),

                              Center(
                                child: Wrap(
                                  spacing: 16,
                                  runSpacing: 16,
                                  alignment: WrapAlignment.center,
                                  runAlignment: WrapAlignment.center,
                                  crossAxisAlignment: WrapCrossAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: isMobile ? double.infinity : 320,
                                      child: TextFormField(
                                        controller: _dataAddressNameController,
                                        decoration: _inputStyle('new_asset_page.data_address_name'.tr()),
                                      ),
                                    ),
                                    const SizedBox(width: 105),
                                    SizedBox(
                                      width: isMobile ? double.infinity : 200,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'new_asset_page.data_address_type'.tr()
                                          ),
                                          const SizedBox(height: 8),
                                          RadioListTile<String>(
                                            value: 'HttpData',
                                            groupValue: dataAddressTypeController,
                                            onChanged: (value) => setState(() => dataAddressTypeController = value!),
                                            title: Text(
                                              'new_asset_page.httpdata'.tr(),
                                              style: TextStyle(
                                                fontSize: 15,
                                                color: Theme.of(context).colorScheme.secondary,
                                              ),
                                            ),
                                            dense: true,
                                            visualDensity: VisualDensity.compact,
                                            contentPadding: EdgeInsets.zero,
                                          ),

                                          RadioListTile<String>(
                                            value: 'File',
                                            groupValue: dataAddressTypeController,
                                            onChanged: (value) => setState(() => dataAddressTypeController = value!),
                                            title: Text(
                                              'new_asset_page.file'.tr(),
                                              style: TextStyle(
                                                fontSize: 15,
                                                color: Theme.of(context).colorScheme.secondary,
                                              ),
                                            ),
                                            dense: true,
                                            visualDensity: VisualDensity.compact,
                                            contentPadding: EdgeInsets.zero,
                                          ),
                                        ],
                                      )
                                    ),
                                    const SizedBox(width: 105),
                                    SizedBox(
                                      width: isMobile ? double.infinity : 200,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'new_asset_page.proxy_path'.tr(),
                                          ),
                                          const SizedBox(height: 8),
                                          RadioListTile<String>(
                                            value: 'True',
                                            groupValue: dataAddressProxyController,
                                            onChanged: (value) => setState(() => dataAddressProxyController = value!),
                                            title: Text(
                                              'new_asset_page.true'.tr(),
                                              style: TextStyle(
                                                fontSize: 15,
                                                color: Theme.of(context).colorScheme.secondary,
                                              ),
                                            ),
                                            dense: true,
                                            visualDensity: VisualDensity.compact,
                                            contentPadding: EdgeInsets.zero,
                                          ),

                                          RadioListTile<String>(
                                            value: 'False',
                                            groupValue: dataAddressProxyController,
                                            onChanged: (value) => setState(() => dataAddressProxyController = value!),
                                            title: Text(
                                              'new_asset_page.false'.tr(),
                                              style: TextStyle(
                                                fontSize: 15,
                                                color: Theme.of(context).colorScheme.secondary,
                                              ),
                                            ),
                                            dense: true,
                                            visualDensity: VisualDensity.compact,
                                            contentPadding: EdgeInsets.zero,
                                          ),
                                        ],
                                      )
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                              TextFormField(
                                controller: _baseURLController,
                                decoration: _inputStyle('new_asset_page.base_url'.tr()),
                              ),
                              
                              const SizedBox(height: 32),

                              Center(
                                child: ElevatedButton(
                                  onPressed: () async {
                                    if (_formKey.currentState!.validate()) {
                  
                                      Asset asset = Asset(
                                        assetId: _assetIdController.text, 
                                        name: _nameController.text, 
                                        contentType: _contentTypeController.text, 
                                        dataAddressName: _dataAddressNameController.text, 
                                        dataAddressType: dataAddressTypeController, 
                                        dataAddressProxy: dataAddressProxyController == 'True' ? true : false, 
                                        baseUrl: _baseURLController.text, 
                                        edc: edcIdSelected
                                      );
                  
                                      showLoader(context);
                                      final response = await _assetService.createAsset(asset);
                                      if (response == null) {
                                        hideLoader(context);
                                        FloatingSnackBar.show(
                                          context,
                                          message: 'new_asset_page.success'.tr(),
                                          type: SnackBarType.success,
                                          width: 320,
                                          duration: Duration(seconds: 3),
                                        );
                                      } else {
                                        hideLoader(context);
                                        FloatingSnackBar.show(
                                          context,
                                          message: '${'new_asset_page.error'.tr()}:$response',
                                          type: SnackBarType.error,
                                          width: 320,
                                          duration: Duration(seconds: 5),
                                        );
                                      }
                                      context.go('/assets');
                  
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

