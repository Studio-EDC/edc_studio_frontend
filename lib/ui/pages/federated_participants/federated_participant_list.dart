// ignore_for_file: use_build_context_synchronously

import 'package:easy_localization/easy_localization.dart';
import 'package:edc_studio/api/models/federated_participant.dart';
import 'package:edc_studio/api/services/federated_participants_service.dart';
import 'package:edc_studio/ui/widgets/header.dart';
import 'package:edc_studio/ui/widgets/loader.dart';
import 'package:edc_studio/ui/widgets/menu_drawer.dart';
import 'package:edc_studio/ui/widgets/search_bar.dart';
import 'package:edc_studio/ui/widgets/snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class FederatedParticipantListPage extends StatefulWidget {
  const FederatedParticipantListPage({super.key});

  @override
  State<FederatedParticipantListPage> createState() =>
      _FederatedParticipantListPageState();
}

class _FederatedParticipantListPageState
    extends State<FederatedParticipantListPage> {
  final FederatedParticipantsService _service = FederatedParticipantsService();
  List<FederatedParticipant> _participants = [];
  List<FederatedParticipant> _filteredParticipants = [];

  @override
  void initState() {
    super.initState();
    _loadParticipants();
  }

  Future<void> _loadParticipants() async {
    final participants = await _service.getAllParticipants();
    setState(() {
      _participants = participants;
      _filteredParticipants = participants;
    });
  }

  void _filterParticipants(String query) {
    setState(() {
      _filteredParticipants = _participants.where((participant) {
        final value = query.toLowerCase();
        return participant.legalName.toLowerCase().contains(value) ||
            participant.participantDid.toLowerCase().contains(value) ||
            participant.publicDomain.toLowerCase().contains(value);
      }).toList();
    });
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'READY':
        return Colors.green;
      case 'CREDENTIALS_INSTALLED':
        return Colors.teal;
      case 'REGISTERED_IN_EDC_MANAGER':
        return Colors.orange;
      case 'DID_READY':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      endDrawer: const MenuDrawer(),
      body: Center(
        child: Column(
          children: [
            const EDCHeader(currentPage: 'federated_participants'),
            Padding(
              padding: isMobile
                  ? const EdgeInsets.symmetric(horizontal: 20, vertical: 24)
                  : const EdgeInsets.symmetric(horizontal: 80, vertical: 24),
              child: isMobile
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SearchBarCustom(
                          hintText: 'federated_list_page.search'.tr(),
                          onChanged: _filterParticipants,
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          onPressed: () =>
                              context.go('/federated-participants/new'),
                          icon: Icon(Icons.add,
                              color: Theme.of(context).colorScheme.secondary),
                          label: Text(
                            'federated_list_page.new_participant'.tr(),
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
                          hintText: 'federated_list_page.search'.tr(),
                          onChanged: _filterParticipants,
                        ),
                        OutlinedButton.icon(
                          onPressed: () =>
                              context.go('/federated-participants/new'),
                          icon: Icon(Icons.add,
                              color: Theme.of(context).colorScheme.secondary),
                          label: Text(
                            'federated_list_page.new_participant'.tr(),
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
              child: _filteredParticipants.isEmpty
                  ? Center(child: Text('federated_list_page.empty'.tr()))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _filteredParticipants.length,
                      itemBuilder: (context, index) {
                        final participant = _filteredParticipants[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 8),
                          child: ListTile(
                            title: Text(participant.legalName),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(participant.participantDid),
                                Text(participant.publicDomain),
                                if (participant.connectorName != null)
                                  Text(
                                      '${'federated_form.connector'.tr()}: ${participant.connectorName}'),
                              ],
                            ),
                            trailing: Wrap(
                              spacing: 8,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Chip(
                                  label: Text(participant.status),
                                  backgroundColor:
                                      _statusColor(participant.status)
                                          .withOpacity(0.12),
                                  labelStyle: TextStyle(
                                      color: _statusColor(participant.status)),
                                ),
                                IconButton(
                                  onPressed: () {
                                    context.go(
                                        '/federated-participants/${participant.id}');
                                  },
                                  icon: const Icon(Icons.open_in_new),
                                ),
                                IconButton(
                                  onPressed: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text(
                                              'confirm_deletion_title'.tr()),
                                          content: Text(
                                            'confirm_deletion_message'.tr(
                                              namedArgs: {
                                                'name': participant.legalName
                                              },
                                            ),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(context)
                                                      .pop(false),
                                              child: Text('cancel'.tr()),
                                            ),
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(context)
                                                      .pop(true),
                                              child: Text(
                                                'delete'.tr(),
                                                style: const TextStyle(
                                                    color: Colors.red),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    );

                                    if (confirm == true) {
                                      showLoader(context);
                                      await _service
                                          .deleteParticipant(participant.id);
                                      hideLoader(context);
                                      FloatingSnackBar.show(
                                        context,
                                        message:
                                            'federated_list_page.deleted'.tr(),
                                        type: SnackBarType.success,
                                        duration: const Duration(seconds: 3),
                                      );
                                      _loadParticipants();
                                    }
                                  },
                                  icon: const Icon(Icons.delete_outline),
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
