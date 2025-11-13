// ignore_for_file: use_build_context_synchronously

import 'package:easy_localization/easy_localization.dart';
import 'package:edc_studio/api/models/asset.dart';
import 'package:edc_studio/api/models/connector.dart';
import 'package:edc_studio/api/services/assets_service.dart';
import 'package:edc_studio/api/services/edc_service.dart';
import 'package:edc_studio/ui/widgets/header.dart';
import 'package:edc_studio/ui/widgets/loader.dart';
import 'package:edc_studio/ui/widgets/menu_drawer.dart';
import 'package:edc_studio/ui/widgets/search_bar.dart';
import 'package:edc_studio/ui/widgets/snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AssetsListPage extends StatefulWidget {
  const AssetsListPage({super.key});

  @override
  State<AssetsListPage> createState() => _AssetsListPageState();
}

class _AssetsListPageState extends State<AssetsListPage> {

  final EdcService _edcService = EdcService();
  final AssetService _assetsService = AssetService();

  List<Asset> _allAssets = [];
  List<Asset> _filteredAssets = [];

  @override
  void initState() {
    super.initState();
    _loadConnectors();
  }

  Future<void> _loadAssets(String id) async {
    final assets = await _assetsService.getAssetsByEdcId(id);
    if (assets is List<Asset>) {
      setState(() {
        _allAssets = assets;
        _filteredAssets = assets;
      });
    }
  }

  void _filterAssets(String query) {
    setState(() {
      _filteredAssets = _allAssets
          .where((asset) =>
              asset.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  List<Connector> _allConnectors = [];
  String _selectedConnectorId = '';

  Future<void> _loadConnectors() async {
    final connectors = await _edcService.getAllConnectors();
    if (connectors != null) {
      final providers = connectors.where((c) => c.type == 'provider').toList();

      if (providers.isNotEmpty) {
        setState(() {
          _allConnectors = providers;
          _selectedConnectorId = providers[0].id;
        });
        _loadAssets(providers[0].id);
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      endDrawer: const MenuDrawer(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            EDCHeader(currentPage: 'assets'),
            Padding(
              padding: isMobile
                  ? const EdgeInsets.symmetric(horizontal: 20, vertical: 24)
                  : const EdgeInsets.symmetric(horizontal: 80, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 15),
                  Text(
                    'assets_list_page.description'.tr(),
                    style: TextStyle(fontSize: 15, color: Theme.of(context).colorScheme.secondary),
                  ),
                  const SizedBox(height: 24),
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
                          value: _selectedConnectorId,
                          icon: const Icon(Icons.arrow_drop_down),
                          isExpanded: true,
                          onChanged: (value) {
                            setState(() => _selectedConnectorId = value!);
                            _loadAssets(value!);
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
            ),
            Padding(
              padding: isMobile
                  ? const EdgeInsets.symmetric(horizontal: 20, vertical: 24)
                  : const EdgeInsets.symmetric(horizontal: 80, vertical: 24),
              child: isMobile
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SearchBarCustom(
                          hintText: 'assets_list_page.search'.tr(),
                          onChanged: _filterAssets,
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          onPressed: () => context.go('/new_asset'),
                          icon: Icon(Icons.add, color: Theme.of(context).colorScheme.secondary),
                          label: Text(
                            'assets_list_page.new_asset'.tr(),
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                              fontSize: 15,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(32),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                          ),
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SearchBarCustom(
                          hintText: 'assets_list_page.search'.tr(),
                          onChanged: _filterAssets,
                        ),
                        OutlinedButton.icon(
                          onPressed: () => context.go('/new_asset'),
                          icon: Icon(Icons.add, color: Theme.of(context).colorScheme.secondary),
                          label: Text(
                            'assets_list_page.new_asset'.tr(),
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                              fontSize: 15,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(32),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                          ),
                        ),
                      ],
                    ),
            ),
            Expanded(
              child: (_filteredAssets.isEmpty && _allConnectors.isNotEmpty)

                ? Column(children: [
                    SizedBox(height: 100),
                    Text('assets_list_page.no_assets'.tr())
                  ]) 

                : (_allConnectors.isEmpty)

                ? Column(children: [
                    SizedBox(height: 100),
                    Text('no_providers'.tr())
                  ]) 

                : ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: double.infinity),
                    child: Padding(
                      padding: isMobile
                        ? const EdgeInsets.symmetric(horizontal: 20, vertical: 24)
                        : const EdgeInsets.symmetric(horizontal: 80, vertical: 24),
                      child: DataTable(
                        columnSpacing: 20,
                        headingRowColor: WidgetStatePropertyAll(
                          Theme.of(context).colorScheme.tertiary,
                        ),
                        columns: [
                          DataColumn(label: Text('assets_list_page.asset_id'.tr(), style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontSize: 15))),
                          DataColumn(label: Text('assets_list_page.name'.tr(), style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontSize: 15))),
                          DataColumn(label: Text('assets_list_page.content_type'.tr(), style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontSize: 15))),
                          DataColumn(label: Text('assets_list_page.base_url'.tr(), style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontSize: 15))),
                          DataColumn(label: Text('assets_list_page.proxy'.tr(), style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontSize: 15))),
                          DataColumn(label: Text('actions'.tr(), style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontSize: 15))),
                        ],
                        rows: _filteredAssets.map((asset) {
                          return DataRow(cells: [
                            DataCell(Text(asset.assetId, style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontSize: 15))),
                            DataCell(Text(asset.name, style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontSize: 15))),
                            DataCell(Text(asset.contentType, style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontSize: 15))),
                            DataCell(Text(asset.baseUrl, style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontSize: 15))),
                            DataCell(Icon(
                              asset.dataAddressProxy ? Icons.check_circle : Icons.cancel,
                              color: asset.dataAddressProxy ? Colors.green : Colors.red,
                              size: 20,
                            )),
                            DataCell(Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_red_eye),
                                  tooltip: 'view'.tr(),
                                  onPressed: () {
                                    context.go('/asset-detail/${asset.edc}/${asset.assetId}');
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline),
                                  tooltip: 'delete'.tr(),
                                  onPressed: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text('confirm_deletion_title'.tr()),
                                          content: Text(
                                            'confirm_deletion_message'.tr(namedArgs: {'name': asset.assetId}),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.of(context).pop(false),
                                              child: Text('cancel'.tr()),
                                            ),
                                            TextButton(
                                              onPressed: () => Navigator.of(context).pop(true),
                                              child: Text(
                                                'delete'.tr(),
                                                style: const TextStyle(color: Colors.red),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    );

                                    if (confirm == true) {
                                      showLoader(context);
                                      final response = await _assetsService.deleteAsset(asset.assetId, _selectedConnectorId);
                                      hideLoader(context);

                                      if (response == null) {
                                        FloatingSnackBar.show(
                                          context,
                                          message: 'assets_list_page.deleted_success'.tr(),
                                          type: SnackBarType.success,
                                          duration: const Duration(seconds: 3),
                                        );
                                        _loadConnectors();
                                      } else {
                                        FloatingSnackBar.show(
                                          context,
                                          message: '${'assets_list_page.deleted_error'.tr()}: $response',
                                          type: SnackBarType.error,
                                          duration: const Duration(seconds: 3),
                                          width: 600
                                        );
                                      }
                                    }
                                  },
                                ),
                              ],
                            )),
                          ]);
                        }).toList(),
                      ),
                    ),
                ),
            )
          ],
        ),
      ),
    );
  }
}