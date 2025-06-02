// ignore_for_file: use_build_context_synchronously, dead_code, deprecated_member_use

import 'package:edc_studio/api/models/asset.dart';
import 'package:edc_studio/api/models/connector.dart';
import 'package:edc_studio/api/models/transfer.dart';
import 'package:edc_studio/api/services/assets_service.dart';
import 'package:edc_studio/api/services/edc_service.dart';
import 'package:edc_studio/api/services/transfers_service.dart';
import 'package:edc_studio/ui/widgets/header.dart';
import 'package:edc_studio/ui/widgets/link.dart';
import 'package:edc_studio/ui/widgets/loader.dart';
import 'package:edc_studio/ui/widgets/menu_drawer.dart';
import 'package:edc_studio/ui/widgets/snack_bar.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
                    showLoader(context);
                    Asset? asset = await _assetsService.getAssetByAssetId(_selectedAssetId ?? '');
                    if (asset != null) {
                      Transfer transfer = Transfer(
                        consumer: consumerID ?? '', 
                        provider: providerID ?? '', 
                        asset: asset.id ?? '', 
                        hasPolicyId: _selectedHasPolicyId ?? '', 
                        negotiateContractId: contractNegotiationId ?? '', 
                        contractAgreementId: contractAgreementId ?? '',
                        transferProcessID: transferProcessID ?? '',
                        transferFlow: _selectedTransferFlow ?? ''
                      );
                      final response = await _transfersService.createTransfer(transfer);
                      if (response != null) {
                        hideLoader(context);
                        FloatingSnackBar.show(
                          context,
                          message: 'Transfer created successfully!',
                          type: SnackBarType.success,
                          width: 320,
                          duration: Duration(seconds: 3),
                        );
                      } else {
                        hideLoader(context);
                        FloatingSnackBar.show(
                          context,
                          message: 'Error creating transfer.',
                          type: SnackBarType.error,
                          width: 320,
                          duration: Duration(seconds: 3),
                        );
                      }
                    } else {
                      hideLoader(context);
                      FloatingSnackBar.show(
                        context,
                        message: 'Error creating transfer.',
                        type: SnackBarType.error,
                        width: 320,
                        duration: Duration(seconds: 3),
                      );
                    }
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
                      'Select consumer, provider and asset',
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
                              'Select the provider you want to start the transfer:',
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
                                    hint: Text('Select the provider', style: TextStyle(fontSize: 15, color: Theme.of(context).colorScheme.secondary)),
                                    icon: const Icon(Icons.arrow_drop_down),
                                    isExpanded: true,
                                    onChanged: (value) {
                                      setState(() => providerID = value!);
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
                        const SizedBox(height: 50),
                        Wrap(
                          alignment: WrapAlignment.center,
                          runAlignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 16,
                          runSpacing: 16,
                          children: [
                            Text(
                              'Select the consumer you want to start the transfer:',
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
                                    hint: Text('Select the consumer', style: TextStyle(fontSize: 15, color: Theme.of(context).colorScheme.secondary)),
                                    icon: const Icon(Icons.arrow_drop_down),
                                    isExpanded: true,
                                    onChanged: (value) {
                                      setState(() => consumerID = value!);
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
                        const SizedBox(height: 50),
                        OutlinedButton.icon(
                          onPressed: () async {
                            showLoader(context);
                            final response = await _transfersService.requestCatalog(consumerID ?? '', providerID ?? '');
                            if (response != null) {
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
                                message: 'Error requesting catalog.',
                                type: SnackBarType.error,
                                width: 320,
                                duration: Duration(seconds: 3),
                              );
                            }
                          },
                          label: Text(
                            'Request the catalog',
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
                              'Select an asset:',
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
                              'Select a policy:',
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
                      'Negotiate contract',
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
                          'In order to request any data, a contract must first be negotiated between the provider and the consumer. '
                          'This process results in a contract agreement.',
                          style: TextStyle(fontSize: 15, color: Theme.of(context).colorScheme.secondary),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'The consumer now needs to initiate the contract negotiation sequence with the provider. This sequence proceeds as follows:',
                          style: TextStyle(fontSize: 15, color: Theme.of(context).colorScheme.secondary),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '1. The consumer sends a contract offer to the provider (currently, this offer must exactly match the provider’s own offer).\n'
                          '2. The provider validates the received offer against its own.\n'
                          '3. Based on the validation result, the provider either sends back a contract agreement or a rejection.\n'
                          '4. If validation is successful, both the provider and the consumer store the resulting agreement for future reference.',
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

                            if (response != null) {
                              final negotiationId = response['@id'];
                              setState(() {
                                contractNegotiationId = negotiationId;
                              });

                              Map<String, dynamic>? responseAgreement;
                              String state = '';

                              // Intentar obtener el contrato hasta que sea FINALIZED o se agote el número de intentos
                              for (int i = 0; i < 10; i++) {
                                await Future.delayed(const Duration(seconds: 2));
                                responseAgreement = await _transfersService.getContractAgreement(consumerID ?? '', negotiationId);

                                if (responseAgreement != null) {
                                  state = responseAgreement['state'] ?? '';
                                  if (state == 'FINALIZED') break;
                                }
                              }

                              hideLoader(context);

                              if (responseAgreement != null && state == 'FINALIZED') {
                                setState(() {
                                  contractAgreementId = responseAgreement!['contractAgreementId'];
                                  contractState = state;
                                });
                              } else {
                                FloatingSnackBar.show(
                                  context,
                                  message: 'Failed to finalize contract negotiation.',
                                  type: SnackBarType.error,
                                  width: 320,
                                  duration: const Duration(seconds: 3),
                                );
                              }
                            } else {
                              hideLoader(context);
                              FloatingSnackBar.show(
                                context,
                                message: 'Error negotiating contract.',
                                type: SnackBarType.error,
                                width: 320,
                                duration: const Duration(seconds: 3),
                              );
                            }
                          },
                          label: Text(
                            'Negotiate contract',
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
                          'Contract negotitation ID obtained: $contractNegotiationId',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                            fontSize: 15,
                          )
                        ),
                        if (contractNegotiationId != null)
                        const SizedBox(height: 16),
                        if (contractAgreementId != null)
                        Text(
                          'Contract agreement ID obtained: $contractAgreementId',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                            fontSize: 15,
                          )
                        ),
                        if (contractAgreementId != null)
                        const SizedBox(height: 16),
                        if (contractState != null)
                        Text(
                          'Contract state obtained: $contractState',
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
                      'Select the Http transfer flow',
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
                      'Obtain the data',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        fontSize: 15,
                      ),
                    ),
                    content: _selectedTransferFlow == 'push' ?
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Performing a file transfer',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '• The consumer will initiate a file transfer.\n'
                          '• The Provider Control Plane retrieves the DataAddress of the actual data source and creates a DataFlowRequest.\n'
                          '• The Provider Data Plane fetches data from the actual data source.\n'
                          '• The Provider Data Plane pushes data to the consumer service.',
                          style: TextStyle(fontSize: 15, color: Theme.of(context).colorScheme.secondary),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          '1. Start a HTTP server',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'As a pre-requisite, you need to have a logging webserver that runs on port 4000 and logs all the incoming requests. The data will be sent to this server.',
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
                                  message: 'Failed to start HTTP server.',
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
                                  message: 'Failed to start HTTP server.',
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
                            httpLoggerStarted ? 'Stop HTTP server' : 'Start HTTP server',
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
                          '2. Start the transfer',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'By clicking the button below, the system will automatically initiate the data transfer using the previously negotiated contract agreement, selected asset and policy.',
                          style: TextStyle(
                            fontSize: 15,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'All necessary information will be included in the request, and the provider will begin sending the data to the configured destination.',
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
                            if (response != null) {
                              setState(() {
                                transferProcessID = response['@id'];
                              });

                              Map<String, dynamic>? responseCheck;
                              String state = '';

                              for (int i = 0; i < 10; i++) {
                                await Future.delayed(const Duration(seconds: 2));
                                responseCheck = await _transfersService.checkTransfer(consumerID ?? '', response['@id'] ?? '');

                                if (responseCheck != null) {
                                  setState(() {
                                    transferState = responseCheck!['state'];
                                  });
                                  state = responseCheck['state'] ?? '';
                                  if (state == 'COMPLETED') break;
                                }
                              }

                              hideLoader(context);
                            } else {
                              hideLoader(context);
                              FloatingSnackBar.show(
                                context,
                                message: 'Failed to finalize transfer process.',
                                type: SnackBarType.error,
                                width: 320,
                                duration: Duration(seconds: 3),
                              );
                            }
                          },
                          label: Text(
                            'Start the transfer',
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
                          'Transfer process ID obtained: $transferProcessID',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                            fontSize: 15,
                          )
                        ),
                        if (transferProcessID != null)
                        const SizedBox(height: 16),
                        if (transferState != null)
                        Text(
                          'Transfer state obtained: $transferState',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                            fontSize: 15,
                          )
                        ),
                        if (transferState != null)
                        const SizedBox(height: 16),
                        LinkWidget(url: 'http://localhost:4000/data'),
                        if (transferState != null)
                        const SizedBox(height: 50),
                      ],
                    ) : 
                    Column(
                      children: [],
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
}