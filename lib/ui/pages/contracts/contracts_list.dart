// ignore_for_file: use_build_context_synchronously

import 'package:edc_studio/api/models/connector.dart';
import 'package:edc_studio/api/models/contract.dart';
import 'package:edc_studio/api/services/contracts_service.dart';
import 'package:edc_studio/api/services/edc_service.dart';
import 'package:edc_studio/ui/widgets/header.dart';
import 'package:edc_studio/ui/widgets/menu_drawer.dart';
import 'package:edc_studio/ui/widgets/search_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ContractsListPage extends StatefulWidget {
  const ContractsListPage({super.key});

  @override
  State<ContractsListPage> createState() => _ContractsListPageState();
}

class _ContractsListPageState extends State<ContractsListPage> {

  final EdcService _edcService = EdcService();
  final ContractsService _contractsService = ContractsService();

  List<Contract> _allContracts = [];
  List<Contract> _filteredContracts = [];

  @override
  void initState() {
    super.initState();
    _loadConnectors();
  }

  Future<void> _loadContracts(String id) async {
    final contracts = await _contractsService.getContractsByEdcId(id);
    setState(() {
      _allContracts = contracts;
      _filteredContracts = contracts;
    });
  }

  void _filterContracts(String query) {
    setState(() {
      _filteredContracts = _allContracts
          .where((contract) =>
              contract.contractId.toLowerCase().contains(query.toLowerCase()))
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
        _loadContracts(providers[0].id);
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
            EDCHeader(currentPage: 'Contracts'),
            Padding(
              padding: isMobile
                  ? const EdgeInsets.symmetric(horizontal: 20, vertical: 24)
                  : const EdgeInsets.symmetric(horizontal: 80, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 15),
                  Text(
                    'To ensure an exchange between provider and consumer, the provider must create a contract offer for the asset, on the basis of which a contract agreement can be negotiated. The contract definition associates policies to a selection of assets to generate the contract offers that will be put in the catalog. So, select the provider you want to view the contracts from:',
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
                            _loadContracts(value!);
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
                          hintText: 'Search Contract',
                          onChanged: _filterContracts,
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          onPressed: () => context.go('/new_contract'),
                          icon: Icon(Icons.add, color: Theme.of(context).colorScheme.secondary),
                          label: Text(
                            'New Contract',
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
                          hintText: 'Search Contract',
                          onChanged: _filterContracts,
                        ),
                        OutlinedButton.icon(
                          onPressed: () => context.go('/new_contract'),
                          icon: Icon(Icons.add, color: Theme.of(context).colorScheme.secondary),
                          label: Text(
                            'New Contract',
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
              child: _filteredContracts.isEmpty
                ? const Column(children: [
                    SizedBox(height: 100),
                    Text('No contracts found for this provider.')
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
                          DataColumn(label: Text('Contract ID', style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontSize: 15))),
                          DataColumn(label: Text('Access policy ID', style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontSize: 15))),
                          DataColumn(label: Text('Contract policy ID', style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontSize: 15))),
                          DataColumn(label: Text('Actions', style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontSize: 15))),
                        ],
                        rows: _filteredContracts.map((contract) {
                          return DataRow(cells: [
                            DataCell(Text(contract.contractId, style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontSize: 15))),
                            DataCell(Text(contract.accessPolicyId, style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontSize: 15))),
                            DataCell(Text(contract.contractPolicyId, style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontSize: 15))),
                            DataCell(Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_red_eye),
                                  tooltip: 'View',
                                  onPressed: () {
                                    // Acción de ver detalle
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline),
                                  tooltip: 'Delete',
                                  onPressed: () {
                                    // Acción de eliminar con confirmación
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