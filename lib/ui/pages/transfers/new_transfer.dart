// ignore_for_file: use_build_context_synchronously, dead_code, deprecated_member_use

import 'package:easy_localization/easy_localization.dart';
import 'package:edc_studio/api/models/asset.dart';
import 'package:edc_studio/api/models/connector.dart';
import 'package:edc_studio/api/models/transfer.dart';
import 'package:edc_studio/api/services/assets_service.dart';
import 'package:edc_studio/api/services/edc_service.dart';
import 'package:edc_studio/api/services/transfers_service.dart';
import 'package:edc_studio/api/services/users_service.dart';
import 'package:edc_studio/ui/widgets/header.dart';
import 'package:edc_studio/ui/widgets/link.dart';
import 'package:edc_studio/ui/widgets/loader.dart';
import 'package:edc_studio/ui/widgets/menu_drawer.dart';
import 'package:edc_studio/ui/widgets/snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NewTransferPage extends StatefulWidget {
  const NewTransferPage({super.key});

  @override
  State<NewTransferPage> createState() => _NewTransferPageState();
}

class _NewTransferPageState extends State<NewTransferPage> {
  int _currentStep = 0;

  final EdcService _edcService = EdcService();
  final TransfersService _transfersService = TransfersService();
  final AssetService _assetsService = AssetService();

  List<Connector> _allProviders = [];
  List<Connector> _allConsumers = [];

  String? providerID;
  String? consumerID;

  String providerStateSelected = '';
  String consumerStateSelected = '';

  bool saveData = false;

  Future<void> _loadProviders() async {
    final connectors = await _edcService.getAllConnectors();
    if (connectors != null) {
      final providers = connectors.where((c) => c.type == 'provider').toList();

      if (providers.isNotEmpty) {
        setState(() {
          _allProviders = providers;
        });
      }
    }
  }

  Future<void> _loadConsumers() async {
    final connectors = await _edcService.getAllConnectors();
    if (connectors != null) {
      final consumers = connectors.where((c) => c.type == 'consumer').toList();

      if (consumers.isNotEmpty) {
        setState(() {
          _allConsumers = consumers;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadConsumers();
    _loadProviders();
  }

  List<String> _assetIds = [];
  List<String> _availablePolicies = [];
  String? _selectedAssetId;
  String? _selectedHasPolicyId;
  Map<String, dynamic>? _catalog;
  String? contractNegotiationId;
  String? contractAgreementId;
  String? contractState;

  String? finalIdTransfer;

  List<String> extractDatasetIds(Map<String, dynamic> catalog) {
    final datasetField = catalog['dcat:dataset'];

    if (datasetField == null) return [];

    // Si es una lista de datasets
    if (datasetField is List) {
      return datasetField
          .map((dataset) => dataset['@id'] as String?)
          .whereType<String>()
          .toList();
    }

    // Si es un solo dataset
    if (datasetField is Map<String, dynamic>) {
      final id = datasetField['@id'];
      return id is String ? [id] : [];
    }

    return [];
  }

  List<String> _getPoliciesForAsset(String? assetId) {
    if (_catalog == null || assetId == null) return [];

    final datasetField = _catalog!['dcat:dataset'];

    dynamic dataset;

    if (datasetField is List) {
      dataset = datasetField.firstWhere((d) => d['@id'] == assetId, orElse: () => null);
    } else if (datasetField is Map<String, dynamic> && datasetField['@id'] == assetId) {
      dataset = datasetField;
    }

    if (dataset == null) return [];

    final policies = dataset['odrl:hasPolicy'];

    if (policies == null) return [];

    if (policies is List) {
      return policies.map((p) => p['@id'] as String?).whereType<String>().toList();
    }

    if (policies is Map<String, dynamic>) {
      final id = policies['@id'];
      return id is String ? [id] : [];
    }

    return [];
  }

  String? _selectedTransferFlow;
  bool httpLoggerStarted = false;

  String? transferProcessID;
  String? transferState;
  String? authorization;
  String? endpoint;
  String? originalEndpoint;

  saveTransfer () async {
    showLoader(context);
    Object asset = await _assetsService.getAssetByAssetId(providerID ?? '', _selectedAssetId ?? '');
    if (asset is Asset) {
      Transfer transfer = Transfer(
        consumer: consumerID ?? '', 
        provider: providerID ?? '', 
        asset: asset.assetId, 
        hasPolicyId: _selectedHasPolicyId ?? '', 
        negotiateContractId: contractNegotiationId ?? '', 
        contractAgreementId: contractAgreementId ?? '',
        transferProcessID: transferProcessID ?? '',
        transferFlow: _selectedTransferFlow ?? '',
        endpoint: endpoint,
        authorization: authorization
      );
      final response = await _transfersService.createTransfer(transfer);
      if (response is String) {
        hideLoader(context);
        FloatingSnackBar.show(
          context,
          message: '${'new_transfer_page.error'.tr()}: $response',
          type: SnackBarType.error,
          width: 320,
          duration: Duration(seconds: 3),
        );
        
      } else {
        hideLoader(context);
        FloatingSnackBar.show(
          context,
          message: 'new_transfer_page.success'.tr(),
          type: SnackBarType.success,
          width: 320,
          duration: Duration(seconds: 3),
        );

        setState(() {
          if (response is Map<String, dynamic>) finalIdTransfer = response['id'];
        });

      }
    } else {
      hideLoader(context);
      FloatingSnackBar.show(
        context,
        message: '${'new_transfer_page.error'.tr()}: $asset',
        type: SnackBarType.error,
        width: 320,
        duration: Duration(seconds: 3),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      endDrawer: const MenuDrawer(),
      body: Column(
        children: [
          EDCHeader(currentPage: 'New Transfer'),
          Expanded(
            child: Padding(
              padding: isMobile
                  ? const EdgeInsets.symmetric(horizontal: 20, vertical: 24)
                  : const EdgeInsets.symmetric(horizontal: 80, vertical: 24),
              child: Stepper(
                elevation: 0,
                type: isMobile ? StepperType.vertical : StepperType.horizontal,
                currentStep: _currentStep,
                onStepTapped: (step) => setState(() => _currentStep = step),
                onStepContinue: () async {
                  if (_currentStep == 3) {
                    context.go('/transfers');
                  }
                  if (_currentStep < 3) {
                    setState(() => _currentStep += 1);
                  }
                },
                onStepCancel: () {
                  if (_currentStep > 0) {
                    setState(() => _currentStep -= 1);
                  }
                },
                steps: [
                  Step(
                    title: Text(
                      'new_transfer_page.select_all'.tr(),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        fontSize: 15,
                      ),
                    ),
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        Wrap(
                          alignment: WrapAlignment.center,
                          runAlignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 16,
                          runSpacing: 16,
                          children: [
                            Text(
                              'new_transfer_page.select_provider'.tr(),
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
                                    value: providerID,
                                    hint: Text('new_transfer_page.select_prov'.tr(), style: TextStyle(fontSize: 15, color: Theme.of(context).colorScheme.secondary)),
                                    icon: const Icon(Icons.arrow_drop_down),
                                    isExpanded: true,
                                    onChanged: (value) {
                                      setState(() {
                                        providerID = value!;
                                        final selected = _allProviders.firstWhere((c) => c.id == value);
                                        providerStateSelected = selected.state;
                                      });
                                    },
                                    items: _allProviders.map((connector) {
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
                        if (providerStateSelected == 'stopped')
                        const SizedBox(height: 16),

                        if (providerStateSelected == 'stopped' && (_allProviders.firstWhere(
                          (p) => p.id == providerID
                        )).type == 'managed') 
                        Text(
                          'new_transfer_page.create_req'.tr(),
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.red
                          ),
                        ),
                        const SizedBox(height: 50),
                        Wrap(
                          alignment: WrapAlignment.center,
                          runAlignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 16,
                          runSpacing: 16,
                          children: [
                            Text(
                              'new_transfer_page.select_consumer'.tr(),
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
                                    value: consumerID,
                                    hint: Text('new_transfer_page.select_cons'.tr(), style: TextStyle(fontSize: 15, color: Theme.of(context).colorScheme.secondary)),
                                    icon: const Icon(Icons.arrow_drop_down),
                                    isExpanded: true,
                                    onChanged: (value) {
                                      setState(() {
                                        consumerID = value!;
                                        final selected = _allConsumers.firstWhere((c) => c.id == value);
                                        consumerStateSelected = selected.state;
                                      });
                                    },
                                    items: _allConsumers.map((connector) {
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

                        if (consumerStateSelected == 'stopped')
                        const SizedBox(height: 16),

                        if (consumerStateSelected == 'stopped')
                        Text(
                          'new_transfer_page.create_req'.tr(),
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.red
                          ),
                        ),
                        const SizedBox(height: 50),
                        OutlinedButton.icon(
                          onPressed: () async {
                            showLoader(context);
                            final response = await _transfersService.requestCatalog(consumerID ?? '', providerID ?? '');
                            if (response is Map<String, dynamic>) {
                              hideLoader(context);
                              final ids = extractDatasetIds(response);
                              setState(() {
                                _catalog = response;
                                final selectedAsset = ids.isNotEmpty ? ids[0] : null;
                                final policies = _getPoliciesForAsset(selectedAsset);
                                _assetIds = ids;
                                _selectedAssetId = selectedAsset;
                                _availablePolicies = policies;
                                _selectedHasPolicyId = policies.isNotEmpty ? policies[0] : null;
                              });
                            } else {
                              hideLoader(context);
                              FloatingSnackBar.show(
                                context,
                                message: '${'new_transfer_page.error_catalog'.tr()}: $response',
                                type: SnackBarType.error,
                                width: 320,
                                duration: Duration(seconds: 3),
                              );
                            }
                          },
                          label: Text(
                            'new_transfer_page.request_catalog'.tr(),
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
                        const SizedBox(height: 50),
                        if (_assetIds.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 16),
                            Text(
                              'new_transfer_page.select_asset'.tr(),
                              style: TextStyle(fontSize: 15, color: Theme.of(context).colorScheme.secondary),
                            ),
                            const SizedBox(height: 8),
                            ..._assetIds.map((id) {
                              return RadioListTile<String>(
                                title: Text(id, style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.secondary)),
                                value: id,
                                groupValue: _selectedAssetId,
                                onChanged: (value) {
                                  final policies = _getPoliciesForAsset(value);
                                  setState(() {
                                    _selectedAssetId = value;
                                    _availablePolicies = policies;
                                    _selectedHasPolicyId = policies.isNotEmpty ? policies[0] : null;
                                  });
                                },

                                activeColor: Theme.of(context).colorScheme.primary,
                                contentPadding: EdgeInsets.zero,
                              );
                            }),
                          ],
                        ),
                        if (_assetIds.isNotEmpty)
                        const SizedBox(height: 50),
                        if (_availablePolicies.length > 1)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 16),
                            Text(
                              'new_transfer_page.select_policy'.tr(),
                              style: TextStyle(fontSize: 15, color: Theme.of(context).colorScheme.secondary),
                            ),
                            const SizedBox(height: 8),
                            ..._availablePolicies.map((policyId) {
                              return RadioListTile<String>(
                                title: Text(policyId, style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.secondary)),
                                value: policyId,
                                groupValue: _selectedHasPolicyId,
                                onChanged: (value) {
                                  setState(() => _selectedHasPolicyId = value);
                                },
                                activeColor: Theme.of(context).colorScheme.primary,
                                contentPadding: EdgeInsets.zero,
                              );
                            }),
                          ],
                        ),
                        if (_availablePolicies.length > 1)
                        const SizedBox(height: 50),
                      ],
                    ),
                    isActive: _currentStep >= 0,
                    state: _currentStep > 0 ? StepState.complete : StepState.indexed,
                  ),
                  Step(
                    title: Text(
                      'new_transfer_page.negotiate'.tr(),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        fontSize: 15,
                      ),
                    ),
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        Text(
                          '${'new_transfer_page.negotiate_explanation.1'.tr()}'
                          '${'new_transfer_page.negotiate_explanation.2'.tr()}',
                          style: TextStyle(fontSize: 15, color: Theme.of(context).colorScheme.secondary),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'new_transfer_page.negotiate_explanation.3'.tr(),
                          style: TextStyle(fontSize: 15, color: Theme.of(context).colorScheme.secondary),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '${'new_transfer_page.negotiate_explanation.4'.tr()}\n'
                          '${'new_transfer_page.negotiate_explanation.5'.tr()}\n'
                          '${'new_transfer_page.negotiate_explanation.6'.tr()}\n'
                          '${'new_transfer_page.negotiate_explanation.7'.tr()}',
                          style: TextStyle(fontSize: 15, color: Theme.of(context).colorScheme.secondary),
                        ),
                        const SizedBox(height: 50),
                        OutlinedButton.icon(
                          onPressed: () async {
                            showLoader(context);

                            final response = await _transfersService.negotiateContract(
                              consumerID ?? '',
                              providerID ?? '',
                              _selectedHasPolicyId ?? '',
                              _selectedAssetId ?? '',
                            );

                            if (response is Map<String, dynamic>) {
                              final negotiationId = response['@id'];
                              setState(() {
                                contractNegotiationId = negotiationId;
                              });

                              Object? responseAgreement;
                              String state = '';

                              // Intentar obtener el contrato hasta que sea FINALIZED o se agote el número de intentos
                              for (int i = 0; i < 10; i++) {
                                await Future.delayed(const Duration(seconds: 2));
                                responseAgreement = await _transfersService.getContractAgreement(consumerID ?? '', negotiationId);

                                if (responseAgreement is Map<String, dynamic>) {
                                  state = responseAgreement['state'] ?? '';
                                  if (state == 'FINALIZED') break;
                                } 
                              }

                              hideLoader(context);

                              if (responseAgreement is Map<String, dynamic> && state == 'FINALIZED') {
                                setState(() {
                                  if (responseAgreement is Map<String, dynamic>) contractAgreementId = responseAgreement['contractAgreementId'];
                                  contractState = state;
                                });
                              } else {
                                FloatingSnackBar.show(
                                  context,
                                  message: '${'new_transfer_page.error_contract'.tr()}: $responseAgreement',
                                  type: SnackBarType.error,
                                  width: 320,
                                  duration: const Duration(seconds: 3),
                                );
                              }
                            } else {
                              hideLoader(context);
                              FloatingSnackBar.show(
                                context,
                                message: '${'new_transfer_page.error_neg_contract'.tr()}: $response',
                                type: SnackBarType.error,
                                width: 320,
                                duration: const Duration(seconds: 3),
                              );
                            }
                          },
                          label: Text(
                            'new_transfer_page.negotiate'.tr(),
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
                        const SizedBox(height: 50),
                        if (contractNegotiationId != null)
                        Text(
                          '${'new_transfer_page.neg_id'.tr()} $contractNegotiationId',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                            fontSize: 15,
                          )
                        ),
                        if (contractNegotiationId != null)
                        const SizedBox(height: 16),
                        if (contractAgreementId != null)
                        Text(
                          '${'new_transfer_page.cont_id'.tr()} $contractAgreementId',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                            fontSize: 15,
                          )
                        ),
                        if (contractAgreementId != null)
                        const SizedBox(height: 16),
                        if (contractState != null)
                        Text(
                          '${'new_transfer_page.cont_state'.tr()} $contractState',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                            fontSize: 15,
                          )
                        ),
                        if (contractState != null)
                        const SizedBox(height: 50),
                      ],
                    ),
                    isActive: _currentStep >= 1,
                    state: _currentStep > 1 ? StepState.complete : StepState.indexed,
                  ),
                  Step(
                    title: Text(
                      'new_transfer_page.select_http'.tr(),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        fontSize: 15,
                      ),
                    ),
                    content: Center(
                      child: Wrap(
                        spacing: 50,
                        runSpacing: 16,
                        children: [
                          _buildTransferOptionCard(
                            context,
                            label: 'Provider Push',
                            icon: Icons.upload,
                            value: 'push',
                          ),
                          _buildTransferOptionCard(
                            context,
                            label: 'Consumer Pull',
                            icon: Icons.download,
                            value: 'pull',
                          ),
                        ],
                      ),
                    ),
                    isActive: _currentStep >= 2,
                    state: _currentStep > 2 ? StepState.complete : StepState.indexed,
                  ),
                  Step(
                    title: Text(
                      'new_transfer_page.obtain_data'.tr(),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        fontSize: 15,
                      ),
                    ),
                    content: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _selectedTransferFlow == 'push' 
                        ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'new_transfer_page.file_transfer'.tr(),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'new_transfer_page.push_flow_steps'.tr(),
                              style: TextStyle(fontSize: 15, color: Theme.of(context).colorScheme.secondary),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'new_transfer_page.start_http_server'.tr(),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'new_transfer_page.pre_requisit'.tr(),
                              style: TextStyle(fontSize: 15, color: Theme.of(context).colorScheme.secondary),
                            ),
                            const SizedBox(height: 16),
                            OutlinedButton.icon(
                              onPressed: () async {
                                if (httpLoggerStarted) {
                                  showLoader(context);
                                  final success = await _transfersService.stopHttpLogger();
                                  hideLoader(context);

                                  if (success == null) {
                                    FloatingSnackBar.show(
                                      context,
                                      message: 'new_transfer_page.error_start_http'.tr(),
                                      type: SnackBarType.error,
                                      width: 320,
                                      duration: Duration(seconds: 3),
                                    );
                                  } else {
                                    setState(() {
                                      httpLoggerStarted = false;
                                    });
                                  }
                                } else {
                                  showLoader(context);
                                  final success = await _transfersService.startHttpLogger();
                                  hideLoader(context);

                                  if (success == null) {
                                    FloatingSnackBar.show(
                                      context,
                                      message: 'new_transfer_page.error_start_http'.tr(),
                                      type: SnackBarType.error,
                                      width: 320,
                                      duration: Duration(seconds: 3),
                                    );
                                  } else {
                                    setState(() {
                                      httpLoggerStarted = true;
                                    });
                                  }
                                }
                              },
                              icon: httpLoggerStarted ?  const Icon(Icons.stop, color: Colors.red) : const Icon(Icons.play_arrow, color: Colors.green),
                              label: Text(
                                httpLoggerStarted ? 'new_transfer_page.stop'.tr() : 'new_transfer_page.start'.tr(),
                                style: TextStyle(
                                  color: httpLoggerStarted ?  Colors.red : Colors.green,
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
                            const SizedBox(height: 50),
                            Text(
                              'new_transfer_page.start_transfer_numbered'.tr(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'new_transfer_page.click'.tr(),
                              style: TextStyle(
                                fontSize: 15,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'new_transfer_page.info'.tr(),
                              style: TextStyle(
                                fontSize: 15,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            OutlinedButton.icon(
                              onPressed: () async {
                                showLoader(context);
                                final response = await _transfersService.startTransfer(consumerID ?? '', providerID ?? '', contractAgreementId ?? '');
                                if (response is Map<String, dynamic>) {
                                  setState(() {
                                    transferProcessID = response['@id'];
                                  });

                                  Object responseCheck;
                                  String state = '';

                                  for (int i = 0; i < 10; i++) {
                                    await Future.delayed(const Duration(seconds: 2));
                                    responseCheck = await _transfersService.checkTransfer(consumerID ?? '', response['@id'] ?? '');

                                    if (responseCheck is Map<String, dynamic>) {
                                      setState(() {
                                        if (responseCheck is Map<String, dynamic>)  transferState = responseCheck['state'];
                                      });
                                      state = responseCheck['state'] ?? '';
                                      if (state == 'COMPLETED') {
                                        await saveTransfer();
                                        break;
                                      }
                                    }
                                  }

                                  hideLoader(context);
                                } else {
                                  hideLoader(context);
                                  FloatingSnackBar.show(
                                    context,
                                    message: 'new_transfer_page.error_transfer_process'.tr(),
                                    type: SnackBarType.error,
                                    width: 320,
                                    duration: Duration(seconds: 3),
                                  );
                                }
                              },
                              label: Text(
                                'new_transfer_page.start_transfer'.tr(),
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
                            const SizedBox(height: 50),
                            if (transferProcessID != null)
                            Text(
                              '${'new_transfer_page.transfer_process_id'.tr()} $transferProcessID',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary,
                                fontSize: 15,
                              )
                            ),
                            if (transferProcessID != null)
                            const SizedBox(height: 16),
                            if (transferState != null)
                            Text(
                              '${'new_transfer_page.transfer_state'.tr()} $transferState',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary,
                                fontSize: 15,
                              )
                            ),
                            if (transferState != null)
                            const SizedBox(height: 16),
                            if (transferState == 'COMPLETED')
                            LinkWidget(url: 'http://localhost:4000/data'),
                            if (transferState != null)
                            const SizedBox(height: 50),
                          ],
                        ) 
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'new_transfer_page.file_transfer'.tr(),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.secondary,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'new_transfer_page.pull_flow_steps'.tr(),
                                style: TextStyle(fontSize: 15, color: Theme.of(context).colorScheme.secondary),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'new_transfer_page.start_transfer_2'.tr(),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Theme.of(context).colorScheme.secondary,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'new_transfer_page.click'.tr(),
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Theme.of(context).colorScheme.secondary,
                                ),
                              ),
                              const SizedBox(height: 16),
                              OutlinedButton.icon(
                                onPressed: () async {
                                  showLoader(context);
                                  final response = await _transfersService.startTransferPull(
                                    consumerID ?? '', 
                                    providerID ?? '', 
                                    contractAgreementId ?? '',
                                  );

                                  if (!context.mounted) return;

                                  if (response is Map<String, dynamic>) {
                                    setState(() {
                                      transferProcessID = response['@id'];
                                    });

                                    Object? responseCheck;
                                    String state = '';

                                    for (int i = 0; i < 10; i++) {
                                      await Future.delayed(const Duration(seconds: 2));
                                      responseCheck = await _transfersService.checkTransfer(consumerID ?? '', response['@id'] ?? '');

                                      if (responseCheck is Map<String, dynamic>) {
                                        setState(() {
                                          if (responseCheck is Map<String, dynamic>) transferState = responseCheck['state'];
                                        });
                                        state = responseCheck['state'] ?? '';
                                        if (state == 'STARTED') break;
                                      }
                                    }

                                    if (!context.mounted) return;

                                    if (responseCheck is Map<String, dynamic>) {
                                      setState(() {
                                        if (responseCheck is Map<String, dynamic>) transferState = responseCheck['state'];
                                      });

                                      final responseData = await _transfersService.checkDataPull(
                                        consumerID ?? '', 
                                        response['@id'] ?? '',
                                      );

                                      if (!context.mounted) return;

                                      if (responseData is Map<String, dynamic>) {
                                        setState(() {
                                          final original = responseData['endpoint'] as String;
                                          originalEndpoint = original;

                                          final provider = _allProviders.firstWhere(
                                            (p) => p.id == providerID
                                          );

                                          final hasDomain = provider.domain != null && provider.domain!.isNotEmpty;

                                          final portMatch = RegExp(r':(\d+)').firstMatch(original);
                                          final port = portMatch?.group(1);

                                          String replacementBase;

                                          if (hasDomain) {
                                            replacementBase = 'https://${provider.domain}';
                                          } else {
                                            replacementBase = port != null
                                                ? 'http://localhost:$port'
                                                : 'http://localhost';
                                          }

                                          endpoint = original.replaceFirstMapped(
                                            RegExp(r'^http:\/\/edc-provider-[\w\d\-]+(:\d+)?'),
                                            (match) => replacementBase,
                                          );
                                          
                                          authorization = responseData['authorization'];
                                        });

                                        await saveTransfer();

                                      } else {
                                        if (context.mounted) {
                                          hideLoader(context);
                                          FloatingSnackBar.show(
                                            context,
                                            message: '${'new_transfer_page.error_transfer_process'.tr()}: $response',
                                            type: SnackBarType.error,
                                            width: 320,
                                            duration: Duration(seconds: 3),
                                          );
                                        }
                                        return;
                                      }
                                    } else {
                                      if (context.mounted) {
                                        hideLoader(context);
                                        FloatingSnackBar.show(
                                          context,
                                          message: '${'new_transfer_page.error_transfer_process'.tr()}: $responseCheck',
                                          type: SnackBarType.error,
                                          width: 320,
                                          duration: Duration(seconds: 3),
                                        );
                                      }
                                      return;
                                    }

                                    if (context.mounted) {
                                      hideLoader(context);
                                    }

                                  } else {
                                    if (context.mounted) {
                                      hideLoader(context);
                                      FloatingSnackBar.show(
                                        context,
                                        message: '${'new_transfer_page.error_transfer_process'.tr()}: $response',
                                        type: SnackBarType.error,
                                        width: 320,
                                        duration: Duration(seconds: 3),
                                      );
                                    }
                                  }
                                },
                                label: Text(
                                  'new_transfer_page.start_transfer'.tr(),
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
                              const SizedBox(height: 16),
                              Text(
                                'new_transfer_page.tp_started_note'.tr(),
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.secondary,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 50),
                              if (transferProcessID != null)
                              Text(
                                '${'new_transfer_page.transfer_process_id'.tr()} $transferProcessID',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.secondary,
                                  fontSize: 15,
                                )
                              ),
                              if (transferProcessID != null)
                              const SizedBox(height: 16),
                              if (transferState != null)
                              Text(
                                '${'new_transfer_page.transfer_state'.tr()} $transferState',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.secondary,
                                  fontSize: 15,
                                )
                              ),
                              if (authorization != null)
                              const SizedBox(height: 16),
                              if (authorization != null)
                              Text(
                                'new_transfer_page.authorization_obtained'.tr(),
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.secondary,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold
                                )
                              ),
                              if (authorization != null)
                              const SizedBox(height: 12),
                              if (authorization != null)
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      '$authorization',
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.secondary,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.copy, size: 20),
                                    onPressed: () {
                                      Clipboard.setData(ClipboardData(text: authorization ?? ''));
                                    },
                                    tooltip: 'new_transfer_page.copy_authorization'.tr(),
                                  ),
                                ],
                              ),
                              if (endpoint != null)
                              const SizedBox(height: 18),
                              if (endpoint != null)
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${'new_transfer_page.endpoint'.tr()} $endpoint',
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.secondary,
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.copy, size: 20),
                                    onPressed: () {
                                      Clipboard.setData(ClipboardData(text: endpoint ?? ''));
                                    },
                                    tooltip: 'new_transfer_page.copy_endpoint'.tr(),
                                  ),
                                ],
                              ),
                              if (endpoint != null && authorization != null)
                              const SizedBox(height: 16),
                              if (endpoint != null && authorization != null)
                              Text(
                                'new_transfer_page.obtain_data_instruction'.tr(),
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.secondary,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold
                                )
                              ),
                              if (endpoint != null && authorization != null)
                              const SizedBox(height: 12),
                              if (endpoint != null && authorization != null)
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      'curl --location --request GET "$endpoint" --header "Authorization: $authorization"',
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.secondary,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.copy, size: 20),
                                    onPressed: () {
                                      Clipboard.setData(
                                        ClipboardData(text: 'curl --location --request GET "$endpoint" --header "Authorization: $authorization"'),
                                      );
                                    },
                                    tooltip: 'new_transfer_page.copy_curl_command'.tr(),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 50),
                            ],
                          ),

                        if (endpoint != null || transferState == 'COMPLETED')
                        Text(
                          'new_transfer_page.save_data'.tr(),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                            fontSize: 15
                          )
                        ),
                        if (endpoint != null || transferState == 'COMPLETED')
                        const SizedBox(height: 16),
                        if (endpoint != null || transferState == 'COMPLETED')
                        OutlinedButton.icon(
                          onPressed: () async {
                            /* await showModalBottomSheet(
                              context: context,
                              isScrollControlled: true, 
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                              ),
                              builder: (context) {
                                return FractionallySizedBox(
                                  heightFactor: 0.8, 
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      children: [
                                        Expanded(
                                          child: UsersSelector(
                                            transferFlow: _selectedTransferFlow,
                                            endpoint: originalEndpoint,
                                            authorization: authorization,
                                            transferID: finalIdTransfer,
                                          ),
                                        ),
                                        ElevatedButton(
                                          onPressed: () => Navigator.of(context).pop(),
                                          child: Text('close'.tr()),
                                        )
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ); */
                            final prefs = await SharedPreferences.getInstance();
                            final token = prefs.getString('access_token');
                            final username = prefs.getString('username');
                            await handleTransferDataUpload(username ?? '', token ?? '');
                          },
                          label: Text(
                            'new_transfer_page.save_data_button'.tr(),
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
                    isActive: _currentStep >= 3,
                    state: _currentStep > 3 ? StepState.complete : StepState.indexed,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransferOptionCard(
    BuildContext context, {
    required String label,
    required IconData icon,
    required String value,
  }) {
    final isSelected = _selectedTransferFlow == value;

    return StatefulBuilder(
      builder: (context, setInnerState) {
        bool isHovering = false;

        return MouseRegion(
          onEnter: (_) => setInnerState(() => isHovering = true),
          onExit: (_) => setInnerState(() => isHovering = false),
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedTransferFlow = value;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 200,
              height: 200,
              padding: const EdgeInsets.all(16),
              transform: isHovering ? Matrix4.translationValues(0, -6, 0) : Matrix4.identity(),
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                    : Colors.white,
                border: Border.all(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey.shade300,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: isHovering
                        ? Colors.black.withOpacity(0.1)
                        : Colors.black.withOpacity(0.05),
                    blurRadius: isHovering ? 8 : 4,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 48, color: Theme.of(context).colorScheme.secondary),
                  const SizedBox(height: 12),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> handleTransferDataUpload(String username, String token) async {
    final UsersService usersService = UsersService();
    
    if (_selectedTransferFlow == 'pull') {
      if (endpoint != null && authorization != null) {
        await usersService.downloadAndUploadFilePull(
          endpoint ?? '',
          authorization!,
          'data_pull_file_$finalIdTransfer',
          context
        );
        context.go('/transfers');
      } else {
        FloatingSnackBar.show(
          context,
          message: 'users_list_page.error_uploading'.tr(),
          type: SnackBarType.error,
          duration: const Duration(seconds: 3),
          width: 600
        );
      }
    } else if (_selectedTransferFlow == 'push') {
      await usersService.downloadAndUploadFilePush(
        'data_push_file_$finalIdTransfer',
        token,
        context
      );
      context.go('/transfers');
    } else {
      FloatingSnackBar.show(
        context,
        message: 'users_list_page.error_uploading'.tr(),
        type: SnackBarType.error,
        duration: const Duration(seconds: 3),
        width: 600
      );
    }
  }
}