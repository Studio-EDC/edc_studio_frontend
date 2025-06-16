// ignore_for_file: use_build_context_synchronously

import 'package:easy_localization/easy_localization.dart';
import 'package:edc_studio/api/models/asset.dart';
import 'package:edc_studio/api/services/assets_service.dart';
import 'package:edc_studio/ui/widgets/header.dart';
import 'package:edc_studio/ui/widgets/loader.dart';
import 'package:edc_studio/ui/widgets/menu_drawer.dart';
import 'package:edc_studio/ui/widgets/snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AssetDetailPage extends StatefulWidget {
  final String assetId;
  final String edcId;

  const AssetDetailPage({
    super.key,
    required this.assetId,
    required this.edcId,
  });

  @override
  State<AssetDetailPage> createState() => _AssetDetailPageState();
}

class _AssetDetailPageState extends State<AssetDetailPage> {

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

  Future<void> _loadAsset() async {
    final asset = await _assetService.getAssetByAssetId(widget.edcId, widget.assetId);
    if (asset != null) {
      setState(() {
        _assetIdController.text = asset.assetId;
        _nameController.text = asset.name;
        _contentTypeController.text = asset.contentType;
        _dataAddressNameController.text = asset.dataAddressName;
        _baseURLController.text = asset.baseUrl;
        dataAddressProxyController = asset.dataAddressType;
        dataAddressProxyController = asset.dataAddressProxy ? 'True' : 'False';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadAsset();
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
                                        readOnly: true,
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
                                      final response = await _assetService.updateAsset(widget.edcId, asset);
                                      if (response) {
                                        hideLoader(context);
                                        FloatingSnackBar.show(
                                          context,
                                          message: 'update_asset_page.success'.tr(),
                                          type: SnackBarType.success,
                                          width: 320,
                                          duration: Duration(seconds: 3),
                                        );
                                      } else {
                                        hideLoader(context);
                                        FloatingSnackBar.show(
                                          context,
                                          message: 'update_asset_page.error'.tr(),
                                          type: SnackBarType.error,
                                          width: 320,
                                          duration: Duration(seconds: 3),
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
                                  child: Text('update'.tr(), style: TextStyle(color: Colors.white, fontSize: 15)),
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

