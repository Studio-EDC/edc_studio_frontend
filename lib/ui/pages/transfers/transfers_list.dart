
import 'package:edc_studio/api/models/transfer.dart';
import 'package:edc_studio/api/services/transfers_service.dart';
import 'package:edc_studio/ui/widgets/header.dart';
import 'package:edc_studio/ui/widgets/menu_drawer.dart';
import 'package:edc_studio/ui/widgets/search_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TransfersListPage extends StatefulWidget {
  const TransfersListPage({super.key});

  @override
  State<TransfersListPage> createState() => _TransfersListPageState();
}

class _TransfersListPageState extends State<TransfersListPage> {

  final TransfersService _transfersService = TransfersService();

  List<TransferPopulated> _allTransfers = [];
  List<TransferPopulated> _filteredTransfers = [];

  Future<void> _loadTransfers() async {
    final transfers = await _transfersService.getAll();
    if (transfers != null) {
      setState(() {
        _allTransfers = transfers;
        _filteredTransfers = transfers;
      });
    }
  }

  void _filterTransfers(String query) {
    setState(() {
      _filteredTransfers = _allTransfers
          .where((transfer) =>
              transfer.consumer!.name.toLowerCase().contains(query.toLowerCase()) ||
              transfer.provider!.name.toLowerCase().contains(query.toLowerCase()) ||
              transfer.asset!.assetId.toLowerCase().contains(query.toLowerCase()) ||
              transfer.transferFlow!.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  void initState() {
    super.initState();
    _loadTransfers();
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
            EDCHeader(currentPage: 'Transfers'),
            Padding(
              padding: isMobile
                  ? const EdgeInsets.symmetric(horizontal: 20, vertical: 24)
                  : const EdgeInsets.symmetric(horizontal: 80, vertical: 24),
              child: isMobile
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SearchBarCustom(
                          hintText: 'Search Transfer',
                          onChanged: _filterTransfers,
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          onPressed: () => context.go('/new_transfer'),
                          icon: Icon(Icons.add, color: Theme.of(context).colorScheme.secondary),
                          label: Text(
                            'New Transfer',
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
                          hintText: 'Search Transfer',
                          onChanged: _filterTransfers,
                        ),
                        OutlinedButton.icon(
                          onPressed: () => context.go('/new_transfer'),
                          icon: Icon(Icons.add, color: Theme.of(context).colorScheme.secondary),
                          label: Text(
                            'New Transfer',
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
              child: _filteredTransfers.isEmpty 
                ? const Column(children: [
                    SizedBox(height: 100),
                    Text('No transfers found for this provider.')
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
                          DataColumn(label: Text('Provider', style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontSize: 15))),
                          DataColumn(label: Text('Consumer', style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontSize: 15))),
                          DataColumn(label: Text('Asset', style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontSize: 15))),
                          DataColumn(label: Text('Flow type', style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontSize: 15))),
                          DataColumn(label: Text('Actions', style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontSize: 15))),
                        ],
                        rows: _filteredTransfers.map((transfer) {
                          return DataRow(cells: [
                            DataCell(Text(transfer.provider?.name ?? '', style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontSize: 15))),
                            DataCell(Text(transfer.consumer?.name ?? '', style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontSize: 15))),
                            DataCell(Text(transfer.asset?.assetId ?? '', style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontSize: 15))),
                            DataCell(Text(transfer.transferFlow == 'push' ? 'Provider push' : 'Consumer pull', style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontSize: 15))),
                            DataCell(Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_red_eye),
                                  tooltip: 'View',
                                  onPressed: () {
                                    // Acción de ver detalle
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