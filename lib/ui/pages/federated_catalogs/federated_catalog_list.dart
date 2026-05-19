// ignore_for_file: use_build_context_synchronously

import 'package:easy_localization/easy_localization.dart';
import 'package:edc_studio/api/models/federated_catalog_instance.dart';
import 'package:edc_studio/api/services/federated_catalog_instances_service.dart';
import 'package:edc_studio/ui/widgets/header.dart';
import 'package:edc_studio/ui/widgets/loader.dart';
import 'package:edc_studio/ui/widgets/menu_drawer.dart';
import 'package:edc_studio/ui/widgets/search_bar.dart';
import 'package:edc_studio/ui/widgets/snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class FederatedCatalogListPage extends StatefulWidget {
  const FederatedCatalogListPage({super.key});

  @override
  State<FederatedCatalogListPage> createState() =>
      _FederatedCatalogListPageState();
}

class _FederatedCatalogListPageState extends State<FederatedCatalogListPage> {
  final FederatedCatalogInstancesService _service =
      FederatedCatalogInstancesService();

  List<FederatedCatalogInstance> _instances = [];
  List<FederatedCatalogInstance> _filteredInstances = [];

  @override
  void initState() {
    super.initState();
    _loadInstances();
  }

  Future<void> _loadInstances() async {
    final instances = await _service.getAllInstances();
    setState(() {
      _instances = instances;
      _filteredInstances = instances;
    });
  }

  void _filterInstances(String query) {
    setState(() {
      _filteredInstances = _instances.where((instance) {
        final value = query.toLowerCase();
        return instance.name.toLowerCase().contains(value) ||
            instance.slug.toLowerCase().contains(value) ||
            instance.catalog_base_url.toLowerCase().contains(value);
      }).toList();
    });
  }

  Future<void> _runAction(
    Future<String?> Function(String id) action,
    FederatedCatalogInstance instance,
  ) async {
    showLoader(context);
    final error = await action(instance.id);
    hideLoader(context);
    if (error == null) {
      FloatingSnackBar.show(
        context,
        message: 'federated_catalogs.actions_success'.tr(),
        type: SnackBarType.success,
        duration: const Duration(seconds: 3),
      );
      _loadInstances();
      return;
    }

    FloatingSnackBar.show(
      context,
      message: '${'federated_catalogs.actions_error'.tr()}: $error',
      type: SnackBarType.error,
      width: 420,
      duration: const Duration(seconds: 4),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      endDrawer: const MenuDrawer(),
      body: Center(
        child: Column(
          children: [
            const EDCHeader(currentPage: 'federated_catalogs'),
            Padding(
              padding: isMobile
                  ? const EdgeInsets.symmetric(horizontal: 20, vertical: 24)
                  : const EdgeInsets.symmetric(horizontal: 80, vertical: 24),
              child: isMobile
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SearchBarCustom(
                          hintText: 'federated_catalogs.search'.tr(),
                          onChanged: _filterInstances,
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          onPressed: () => context.go('/federated-catalogs/new'),
                          icon: Icon(
                            Icons.add,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          label: Text(
                            'federated_catalogs.new'.tr(),
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SearchBarCustom(
                          hintText: 'federated_catalogs.search'.tr(),
                          onChanged: _filterInstances,
                        ),
                        OutlinedButton.icon(
                          onPressed: () => context.go('/federated-catalogs/new'),
                          icon: Icon(
                            Icons.add,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          label: Text(
                            'federated_catalogs.new'.tr(),
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
            Expanded(
              child: _filteredInstances.isEmpty
                  ? Center(child: Text('federated_catalogs.empty'.tr()))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _filteredInstances.length,
                      itemBuilder: (context, index) {
                        final instance = _filteredInstances[index];
                        final running = instance.state == 'running';

                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 8,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        instance.name,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    Chip(
                                      label: Text(
                                        running
                                            ? 'edc_list_page.running'.tr()
                                            : 'edc_list_page.stopped'.tr(),
                                      ),
                                      backgroundColor: running
                                          ? Colors.green.withOpacity(0.12)
                                          : Colors.grey.withOpacity(0.12),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text('Slug: ${instance.slug}'),
                                Text(
                                  '${'federated_catalogs.catalog_url'.tr()}: ${instance.catalog_base_url}',
                                ),
                                Text(
                                  '${'federated_catalogs.scope'.tr()}: ${instance.provider_scope_mode == 'all' ? 'federated_catalogs.scope_all'.tr() : 'federated_catalogs.scope_selected'.tr(namedArgs: {'count': instance.selected_provider_connector_ids.length.toString()})}',
                                ),
                                if ((instance.last_error ?? '').isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    '${'federated_catalogs.last_error'.tr()}: ${instance.last_error}',
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                ],
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    OutlinedButton(
                                      onPressed: () => context.go(
                                        '/federated-catalogs/${instance.id}',
                                      ),
                                      child: Text('view'.tr()),
                                    ),
                                    OutlinedButton(
                                      onPressed: () => _runAction(
                                        running
                                            ? _service.stopInstance
                                            : _service.startInstance,
                                        instance,
                                      ),
                                      child: Text(
                                        running
                                            ? 'edc_list_page.stop'.tr()
                                            : 'edc_list_page.start'.tr(),
                                      ),
                                    ),
                                    OutlinedButton(
                                      onPressed: () => _runAction(
                                        _service.redeployInstance,
                                        instance,
                                      ),
                                      child: Text(
                                        'federated_catalogs.redeploy'.tr(),
                                      ),
                                    ),
                                    OutlinedButton(
                                      onPressed: () async {
                                        final confirm = await showDialog<bool>(
                                          context: context,
                                          builder: (dialogContext) {
                                            return AlertDialog(
                                              title: Text(
                                                'confirm_deletion_title'.tr(),
                                              ),
                                              content: Text(
                                                'confirm_deletion_message'.tr(
                                                  namedArgs: {
                                                    'name': instance.name,
                                                  },
                                                ),
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.of(dialogContext)
                                                          .pop(false),
                                                  child: Text('cancel'.tr()),
                                                ),
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.of(dialogContext)
                                                          .pop(true),
                                                  child: Text(
                                                    'delete'.tr(),
                                                    style: const TextStyle(
                                                      color: Colors.red,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            );
                                          },
                                        );

                                        if (confirm == true) {
                                          showLoader(context);
                                          final ok = await _service
                                              .deleteInstance(instance.id);
                                          hideLoader(context);
                                          if (ok) {
                                            FloatingSnackBar.show(
                                              context,
                                              message:
                                                  'federated_catalogs.deleted'
                                                      .tr(),
                                              type: SnackBarType.success,
                                            );
                                            _loadInstances();
                                          } else {
                                            FloatingSnackBar.show(
                                              context,
                                              message:
                                                  'federated_catalogs.delete_error'
                                                      .tr(),
                                              type: SnackBarType.error,
                                            );
                                          }
                                        }
                                      },
                                      child: Text('delete'.tr()),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
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
