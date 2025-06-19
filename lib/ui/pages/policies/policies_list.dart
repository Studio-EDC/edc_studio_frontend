// ignore_for_file: use_build_context_synchronously

import 'package:easy_localization/easy_localization.dart';
import 'package:edc_studio/api/models/connector.dart';
import 'package:edc_studio/api/models/policy.dart';
import 'package:edc_studio/api/services/edc_service.dart';
import 'package:edc_studio/api/services/policies_service.dart';
import 'package:edc_studio/ui/widgets/header.dart';
import 'package:edc_studio/ui/widgets/loader.dart';
import 'package:edc_studio/ui/widgets/menu_drawer.dart';
import 'package:edc_studio/ui/widgets/search_bar.dart';
import 'package:edc_studio/ui/widgets/snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PoliciesListPage extends StatefulWidget {
  const PoliciesListPage({super.key});

  @override
  State<PoliciesListPage> createState() => _PoliciesListPageState();
}

class _PoliciesListPageState extends State<PoliciesListPage> {

  final EdcService _edcService = EdcService();
  final PoliciesService _policiesService = PoliciesService();

  List<Connector> _allConnectors = [];
  String _selectedConnectorId = '';

  List<Policy> _allPolicies = [];
  List<Policy> _filteredPolicies = [];

  Future<void> _loadConnectors() async {
    final connectors = await _edcService.getAllConnectors();
    if (connectors != null) {
      final providers = connectors.where((c) => c.type == 'provider').toList();

      if (providers.isNotEmpty) {
        setState(() {
          _allConnectors = providers;
          _selectedConnectorId = providers[0].id;
        });
        _loadPolicies(providers[0].id);
      }
    }
  }

  Future<void> _loadPolicies(String id) async {
    final policies = await _policiesService.getPoliciesByEdcId(id);
    if (policies is List<Policy>) {
      setState(() {
        _allPolicies = policies;
        _filteredPolicies = policies;
      });
    }
  }

  void _filterPolicies(String query) {
    setState(() {
      _filteredPolicies = _allPolicies
          .where((policy) =>
              policy.policyId.toLowerCase().contains(query.toLowerCase()))
          .toList();
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
          children: <Widget>[
            EDCHeader(currentPage: 'policies'),
            Padding(
              padding: isMobile
                  ? const EdgeInsets.symmetric(horizontal: 20, vertical: 24)
                  : const EdgeInsets.symmetric(horizontal: 80, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 15),
                  Text(
                    'policies_list_page.description'.tr(),
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
                            _loadPolicies(value!);
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
                          hintText: 'policies_list_page.search'.tr(),
                          onChanged: _filterPolicies,
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          onPressed: () => context.go('/new_policy'),
                          icon: Icon(Icons.add, color: Theme.of(context).colorScheme.secondary),
                          label: Text(
                            'policies_list_page.new'.tr(),
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
                          hintText: 'policies_list_page.search'.tr(),
                          onChanged: _filterPolicies,
                        ),
                        OutlinedButton.icon(
                          onPressed: () => context.go('/new_policy'),
                          icon: Icon(Icons.add, color: Theme.of(context).colorScheme.secondary),
                          label: Text(
                            'policies_list_page.new'.tr(),
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
              child: _filteredPolicies.isEmpty
                ? Column(children: [
                    SizedBox(height: 100),
                    Text('policies_list_page.no_policies'.tr())
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
                          DataColumn(label: Text('policies_list_page.columns.policy_id'.tr(), style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontSize: 15))),
                          DataColumn(label: Text('policies_list_page.columns.num_permissions'.tr(), style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontSize: 15))),
                          DataColumn(label: Text('policies_list_page.columns.num_prohibitions'.tr(), style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontSize: 15))),
                          DataColumn(label: Text('policies_list_page.columns.num_obligations'.tr(), style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontSize: 15))),
                          DataColumn(label: Text('policies_list_page.columns.actions'.tr(), style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontSize: 15))),
                        ],
                        rows: _filteredPolicies.map((policy) {
                          return DataRow(cells: [
                            DataCell(Text(policy.policyId, style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontSize: 15))),
                            DataCell(Text(policy.policy.permission!.length.toString(), style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontSize: 15))),
                            DataCell(Text(policy.policy.prohibition!.length.toString(), style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontSize: 15))),
                            DataCell(Text(policy.policy.obligation!.length.toString(), style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontSize: 15))),
                            DataCell(Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_red_eye),
                                  tooltip: 'view'.tr(),
                                  onPressed: () {
                                    context.go('/policy-detail/${policy.edc}/${policy.policyId}');
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
                                            'confirm_deletion_message'.tr(namedArgs: {'name': policy.policyId}),
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
                                      final response = await _policiesService.deletePolicy(policy.policyId, _selectedConnectorId);
                                      hideLoader(context);

                                      if (response == true) {
                                        FloatingSnackBar.show(
                                          context,
                                          message: 'policies_list_page.deleted_success'.tr(),
                                          type: SnackBarType.success,
                                          duration: const Duration(seconds: 3),
                                        );
                                        _loadConnectors();
                                      } else {
                                        FloatingSnackBar.show(
                                          context,
                                          message: 'policies_list_page.deleted_error'.tr(),
                                          type: SnackBarType.error,
                                          duration: const Duration(seconds: 3),
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