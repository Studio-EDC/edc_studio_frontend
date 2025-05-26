// ignore_for_file: use_build_context_synchronously

import 'package:edc_studio/api/models/connector.dart';
import 'package:edc_studio/api/services/edc_service.dart';
import 'package:edc_studio/ui/widgets/connector_card.dart';
import 'package:edc_studio/ui/widgets/header.dart';
import 'package:edc_studio/ui/widgets/loader.dart';
import 'package:edc_studio/ui/widgets/menu_drawer.dart';
import 'package:edc_studio/ui/widgets/search_bar.dart';
import 'package:edc_studio/ui/widgets/snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class EDCListPage extends StatefulWidget {
  const EDCListPage({super.key});

  @override
  State<EDCListPage> createState() => _EDCListPageState();
}

class _EDCListPageState extends State<EDCListPage> {

  final EdcService _edcService = EdcService();
  List<Connector> _allConnectors = [];
  List<Connector> _filteredConnectors = [];

  @override
  void initState() {
    super.initState();
    _loadConnectors();
  }

  Future<void> _loadConnectors() async {
    final connectors = await _edcService.getAllConnectors();
    if (connectors != null) {
      setState(() {
        _allConnectors = connectors;
        _filteredConnectors = connectors;
      });
    }
  }

  void _filterConnectors(String query) {
    setState(() {
      _filteredConnectors = _allConnectors
          .where((connector) =>
              connector.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
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
            EDCHeader(currentPage: 'EDC List'),
            Padding(
              padding: isMobile
                  ? const EdgeInsets.symmetric(horizontal: 20, vertical: 24)
                  : const EdgeInsets.symmetric(horizontal: 80, vertical: 24),
              child: isMobile
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SearchBarCustom(
                          hintText: 'Search EDC',
                          onChanged: _filterConnectors,
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          onPressed: () => context.go('/new_edc'),
                          icon: Icon(Icons.add, color: Theme.of(context).colorScheme.secondary),
                          label: Text(
                            'New EDC',
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
                          hintText: 'Search EDC',
                          onChanged: _filterConnectors,
                        ),
                        OutlinedButton.icon(
                          onPressed: () => context.go('/new_edc'),
                          icon: Icon(Icons.add, color: Theme.of(context).colorScheme.secondary),
                          label: Text(
                            'New EDC',
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
              child: _filteredConnectors.isEmpty
                  ? const Center(child: Text('No connectors found.'))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _filteredConnectors.length,
                      itemBuilder: (context, index) {
                        final connector = _filteredConnectors[index];
                        return ConnectorCard(
                          connector: connector,
                          onToggleState: () async {
                            if (connector.state == 'running') {
                              showLoader(context);
                              await _edcService.stopConnector(connector.id);
                              hideLoader(context);
                            } else {
                              showLoader(context);
                              await _edcService.startConnector(connector.id);
                              hideLoader(context);
                            }
                            _loadConnectors();
                          },
                          onDelete: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Confirm Deletion'),
                                  content: Text('Are you sure you want to delete "${connector.name}"?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(false),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(true),
                                      child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                    ),
                                  ],
                                );
                              },
                            );

                            if (confirm == true) {
                              showLoader(context);
                              final response = await _edcService.deleteConnectorByID(connector.id);
                              if (response == true) {
                                hideLoader(context);
                                FloatingSnackBar.show(
                                  context,
                                  message: 'Connector deleted successfully!',
                                  type: SnackBarType.success,
                                  duration: Duration(seconds: 3),
                                );
                                _loadConnectors();
                              } else {
                                hideLoader(context);
                                FloatingSnackBar.show(
                                  context,
                                  message: 'Error deleting connector.',
                                  type: SnackBarType.error,
                                  duration: Duration(seconds: 3),
                                );
                              }
                            }
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}