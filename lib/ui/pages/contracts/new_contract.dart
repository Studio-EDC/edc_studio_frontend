// ignore_for_file: use_build_context_synchronously


import 'package:easy_localization/easy_localization.dart';
import 'package:edc_studio/api/models/asset.dart';
import 'package:edc_studio/api/models/connector.dart';
import 'package:edc_studio/api/models/contract.dart';
import 'package:edc_studio/api/models/policy.dart';
import 'package:edc_studio/api/services/assets_service.dart';
import 'package:edc_studio/api/services/contracts_service.dart';
import 'package:edc_studio/api/services/edc_service.dart';
import 'package:edc_studio/api/services/policies_service.dart';
import 'package:edc_studio/ui/widgets/header.dart';
import 'package:edc_studio/ui/widgets/loader.dart';
import 'package:edc_studio/ui/widgets/menu_drawer.dart';
import 'package:edc_studio/ui/widgets/snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NewContractPage extends StatefulWidget {
  const NewContractPage({super.key});

  @override
  State<NewContractPage> createState() => _NewContractPageState();
}

class _NewContractPageState extends State<NewContractPage> {

  final EdcService _edcService = EdcService();
  final PoliciesService _policyService = PoliciesService();
  final AssetService _assetsService = AssetService();
  final ContractsService _contractsService = ContractsService();

  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _contractIdController = TextEditingController();

  String? edcIdSelected;
  String edcStateSelected = '';
  String? accessPolicyIdSelected;
  String? contractPolicyIdSelected;

  List<Connector> _allConnectors = [];
  List<Asset> _allAssets = [];
  List<Policy> _allPolicies = [];

  List<String> selectedAssetIds = [];

  Future<void> _loadConnectors() async {
    final connectors = await _edcService.getAllConnectors();
    if (connectors != null) {
      final providers = connectors.where((c) => c.type == 'provider').toList();

      if (providers.isNotEmpty) {
        setState(() {
          _allConnectors = providers;
          _loadAssets(edcIdSelected ?? '');
          _loadPolicies(edcIdSelected ?? '');
        });
      }
    }
  }

  Future<void> _loadAssets(String id) async {
    final assets = await _assetsService.getAssetsByEdcId(id);
    setState(() {
      _allAssets = assets;
    });
  }

  Future<void> _loadPolicies(String id) async {
    final policies = await _policyService.getPoliciesByEdcId(id);
    setState(() {
      _allPolicies = policies;
    });
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
            EDCHeader(currentPage: 'New Contract'),
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
                                'new_contract_page.title'.tr(),
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
                                    'new_contract_page.edc_select'.tr(),
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
                                          hint: Text('new_contract_page.select_connector'.tr()),
                                          icon: const Icon(Icons.arrow_drop_down),
                                          isExpanded: true,
                                          onChanged: (value) {
                                            setState(() {
                                              edcIdSelected = value!;
                                              final selected = _allConnectors.firstWhere((c) => c.id == value);
                                              edcStateSelected = selected.state;
                                            });
                                            _loadPolicies(value!);
                                            _loadAssets(value);
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
                                'new_contract_page.create_req'.tr(),
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.red
                                ),
                              ),

                              const SizedBox(height: 16),

                              TextFormField(
                                controller: _contractIdController,
                                decoration: _inputStyle('new_contract_page.contract_id'.tr()),
                              ),

                              const SizedBox(height: 16),

                              Wrap(
                                alignment: WrapAlignment.center,
                                runAlignment: WrapAlignment.center,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: 16,
                                runSpacing: 16,
                                children: [
                                  Text(
                                    'new_contract_page.access_policy'.tr(),
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
                                          value: _allPolicies.any((p) => p.id == accessPolicyIdSelected) ? accessPolicyIdSelected : null,
                                          hint: Text('new_contract_page.select_access_policy'.tr()),
                                          icon: const Icon(Icons.arrow_drop_down),
                                          isExpanded: true,
                                          onChanged: (value) {
                                            setState(() => accessPolicyIdSelected = value!);
                                          },
                                          items: _allPolicies.map((policie) {
                                            return DropdownMenuItem<String>(
                                              value: policie.id,
                                              child: Text(policie.policyId, style: TextStyle(fontSize: 15, color: Theme.of(context).colorScheme.secondary)),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 16),

                              Wrap(
                                alignment: WrapAlignment.center,
                                runAlignment: WrapAlignment.center,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: 16,
                                runSpacing: 16,
                                children: [
                                  Text(
                                    'new_contract_page.contract_policy'.tr(),
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
                                          value: _allPolicies.any((p) => p.id == contractPolicyIdSelected) ? contractPolicyIdSelected : null,
                                          icon: const Icon(Icons.arrow_drop_down),
                                          hint: Text('new_contract_page.select_contract_policy'.tr()),
                                          isExpanded: true,
                                          onChanged: (value) {
                                            setState(() => contractPolicyIdSelected = value!);
                                          },
                                          items: _allPolicies.map((policie) {
                                            return DropdownMenuItem<String>(
                                              value: policie.id,
                                              child: Text(policie.policyId, style: TextStyle(fontSize: 15, color: Theme.of(context).colorScheme.secondary)),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              if (_allAssets.isNotEmpty)
                              const SizedBox(height: 16),

                              if (_allAssets.isNotEmpty)
                              Text(
                                'new_contract_page.select_assets'.tr(),
                                style: TextStyle(fontSize: 15, color: Theme.of(context).colorScheme.secondary),
                              ),

                              if (_allAssets.isNotEmpty)
                              const SizedBox(height: 16),

                              if (_allAssets.isNotEmpty)
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _allAssets.length,
                                itemBuilder: (context, index) {
                                  final asset = _allAssets[index];
                                  final isSelected = selectedAssetIds.contains(asset.id);

                                  return CheckboxListTile(
                                    title: Text(asset.assetId, style: TextStyle(fontSize: 15, color: Theme.of(context).colorScheme.secondary)),
                                    value: isSelected,
                                    onChanged: (bool? selected) {
                                      setState(() {
                                        if (selected == true) {
                                          selectedAssetIds.add(asset.id!);
                                        } else {
                                          selectedAssetIds.remove(asset.id!);
                                        }
                                      });
                                    },
                                    controlAffinity: ListTileControlAffinity.leading,
                                  );
                                },
                              ),

                              
                              const SizedBox(height: 32),

                              Center(
                                child: ElevatedButton(
                                  onPressed: () async {
                                    if (_formKey.currentState!.validate()) {

                                      Contract contract = Contract(
                                        edc: edcIdSelected ?? '', 
                                        contractId: _contractIdController.text, 
                                        accessPolicyId: accessPolicyIdSelected ?? '', 
                                        contractPolicyId: contractPolicyIdSelected ?? '', 
                                        assetsSelector: selectedAssetIds,
                                        context: {
                                          "@vocab": "https://w3id.org/edc/v0.0.1/ns/"
                                        }
                                      );
                  
                                      showLoader(context);
                                      final response = await _contractsService.createContract(contract);
                                      if (response != null) {
                                        hideLoader(context);
                                        FloatingSnackBar.show(
                                          context,
                                          message: 'new_contract_page.success'.tr(),
                                          type: SnackBarType.success,
                                          width: 320,
                                          duration: Duration(seconds: 3),
                                        );
                                      } else {
                                        hideLoader(context);
                                        FloatingSnackBar.show(
                                          context,
                                          message: 'new_contract_page.error'.tr(),
                                          type: SnackBarType.error,
                                          width: 320,
                                          duration: Duration(seconds: 3),
                                        );
                                      }
                                      context.go('/contracts');
                  
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