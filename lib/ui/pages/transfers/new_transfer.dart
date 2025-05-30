import 'package:edc_studio/api/models/connector.dart';
import 'package:edc_studio/api/services/edc_service.dart';
import 'package:edc_studio/ui/widgets/header.dart';
import 'package:edc_studio/ui/widgets/menu_drawer.dart';
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
                onStepContinue: () {
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
                          onPressed: () => context.go('/new_transfer'),
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
                    content: const Text('Here goes the target selection form or UI.'),
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
                    content: const Text('Here goes the confirmation and summary.'),
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
                    content: const Text('Here goes the confirmation and summary.'),
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
}