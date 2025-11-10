// ignore_for_file: use_build_context_synchronously


import 'package:easy_localization/easy_localization.dart';
import 'package:edc_studio/api/models/connector.dart';
import 'package:edc_studio/api/models/policy.dart';
import 'package:edc_studio/api/services/edc_service.dart';
import 'package:edc_studio/api/services/policies_service.dart';
import 'package:edc_studio/ui/widgets/header.dart';
import 'package:edc_studio/ui/widgets/loader.dart';
import 'package:edc_studio/ui/widgets/menu_drawer.dart';
import 'package:edc_studio/ui/widgets/snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NewPolicyPage extends StatefulWidget {
  const NewPolicyPage({super.key});

  @override
  State<NewPolicyPage> createState() => _NewPolicyPageState();
}

class _NewPolicyPageState extends State<NewPolicyPage> {

  final EdcService _edcService = EdcService();
  final PoliciesService _policyService = PoliciesService();

  final _formKey = GlobalKey<FormState>();

  String? requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'required_field'.tr();
    }
    return null;
  }

  // Controllers
  final _policyIdController = TextEditingController();

  String edcIdSelected = '';
  String edcStateSelected = '';

  List<Connector> _allConnectors = [];
  List<Rule> permissions = [];
  List<Rule> prohibitions = [];
  List<Rule> obligations = [];

  Future<void> _loadConnectors() async {
    final connectors = await _edcService.getAllConnectors();
    if (connectors != null) {
      final providers = connectors.where((c) => c.type == 'provider').toList();

      if (providers.isNotEmpty) {
        setState(() {
          _allConnectors = providers;
          edcIdSelected = providers[0].id;
          edcStateSelected = providers[0].state;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadConnectors();
  }

  int numPermissions = 0;
  int numProhibitions = 0;
  int numObligations = 0;

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      endDrawer: const MenuDrawer(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            EDCHeader(currentPage: 'New Policy'),
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
                                'new_policy_page.title'.tr(),
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
                                    'new_policy_page.select_edc'.tr(),
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
                                          icon: const Icon(Icons.arrow_drop_down),
                                          isExpanded: true,
                                          onChanged: (value) {
                                            setState(() {
                                              edcIdSelected = value!;
                                              final selected = _allConnectors.firstWhere((c) => c.id == value);
                                              edcStateSelected = selected.state;
                                            });
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
                                'new_policy_page.create_req'.tr(),
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.red
                                ),
                              ),

                              const SizedBox(height: 16),

                              TextFormField(
                                controller: _policyIdController,
                                validator: requiredValidator,
                                decoration: _inputStyle('new_policy_page.policy_id'.tr()),
                              ),

                              const SizedBox(height: 16),

                              Text('new_policy_page.permissions'.tr(), style: TextStyle(fontSize: 15, color: Theme.of(context).colorScheme.secondary)),

                              const SizedBox(height: 16),

                              Column(
                                children: List.generate(numPermissions, (index) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: SizedBox(
                                      width: double.infinity,
                                      child: Wrap(
                                        alignment: WrapAlignment.center,
                                        crossAxisAlignment: WrapCrossAlignment.center,
                                        runAlignment: WrapAlignment.center,
                                        runSpacing: 16,
                                        children: _buildPermissionFields(index, 'permission')
                                      )
                                    ),
                                  );
                                }),
                              ),

                              const SizedBox(height: 16),

                              Center(
                                child: OutlinedButton.icon(
                                  onPressed: () => setState(() {
                                    numPermissions ++;
                                  }),
                                  icon: Icon(Icons.add, color: Theme.of(context).colorScheme.secondary),
                                  label: Text(
                                    'new_policy_page.new_permission'.tr(),
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
                              ),

                              const SizedBox(height: 16),

                              Text('new_policy_page.prohibitions'.tr(), style: TextStyle(fontSize: 15, color: Theme.of(context).colorScheme.secondary)),

                              const SizedBox(height: 16),

                              Column(
                                children: List.generate(numProhibitions, (index) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: SizedBox(
                                      width: double.infinity,
                                      child: Wrap(
                                        alignment: WrapAlignment.center,
                                        crossAxisAlignment: WrapCrossAlignment.center,
                                        runAlignment: WrapAlignment.center,
                                        runSpacing: 16,
                                        children: _buildPermissionFields(index, 'prohibition')
                                      )
                                    ),
                                  );
                                }),
                              ),

                              const SizedBox(height: 16),

                              Center(
                                child: OutlinedButton.icon(
                                  onPressed: () => setState(() {
                                    numProhibitions ++;
                                  }),
                                  icon: Icon(Icons.add, color: Theme.of(context).colorScheme.secondary),
                                  label: Text(
                                    'new_policy_page.new_prohibition'.tr(),
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
                              ),

                              const SizedBox(height: 16),

                              Text('new_policy_page.obligations'.tr(), style: TextStyle(fontSize: 15, color: Theme.of(context).colorScheme.secondary)),

                              const SizedBox(height: 16),

                              Column(
                                children: List.generate(numObligations, (index) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: SizedBox(
                                      width: double.infinity,
                                      child: Wrap(
                                        alignment: WrapAlignment.center,
                                        crossAxisAlignment: WrapCrossAlignment.center,
                                        runAlignment: WrapAlignment.center,
                                        runSpacing: 16,
                                        children: _buildPermissionFields(index, 'obligation')
                                      )
                                    ),
                                  );
                                }),
                              ),

                              const SizedBox(height: 16),

                              Center(
                                child: OutlinedButton.icon(
                                  onPressed: () => setState(() {
                                    numObligations ++;
                                  }),
                                  icon: Icon(Icons.add, color: Theme.of(context).colorScheme.secondary),
                                  label: Text(
                                    'new_policy_page.new_obligation'.tr(),
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
                              ),
                              
                              const SizedBox(height: 32),

                              Center(
                                child: ElevatedButton(
                                  onPressed: () async {
                                    if (_formKey.currentState!.validate()) {

                                      PolicyDefinition policyDef = PolicyDefinition(
                                        permission: permissions,
                                        obligation: obligations,
                                        prohibition: prohibitions
                                      );

                                      Policy policy = Policy(
                                        edc: edcIdSelected, 
                                        policyId: _policyIdController.text, 
                                        policy: policyDef,
                                      );
                  
                                      showLoader(context);
                                      final response = await _policyService.createPolicy(policy);
                                      if (response == null) {
                                        hideLoader(context);
                                        FloatingSnackBar.show(
                                          context,
                                          message: 'new_policy_page.success'.tr(),
                                          type: SnackBarType.success,
                                          width: 320,
                                          duration: Duration(seconds: 3),
                                        );
                                      } else {
                                        hideLoader(context);
                                        FloatingSnackBar.show(
                                          context,
                                          message: '${'new_policy_page.error'.tr()}: $response',
                                          type: SnackBarType.error,
                                          width: 320,
                                          duration: Duration(seconds: 3),
                                        );
                                      }
                                      context.go('/policies');
                  
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

  List<Rule> _getRuleList(String type) {
    switch (type) {
      case 'permission':
        return permissions;
      case 'prohibition':
        return prohibitions;
      case 'obligation':
        return obligations;
      default:
        return [];
    }
  }

  List<Widget> _buildPermissionFields(int index, String type) {
    final List<Rule> ruleList = _getRuleList(type);

    // Aseguramos que el índice existe en la lista
    if (ruleList.length <= index) {
      ruleList.add(
        Rule(action: '', constraint: [Constraint(leftOperand: '', operator: Operator(id: ''), rightOperand: '')]),
      );
    }

    final rule = ruleList[index];
    final constraint = (rule.constraint != null && rule.constraint!.isNotEmpty)
        ? rule.constraint![0]
        : Constraint(leftOperand: '', operator: Operator(id: ''), rightOperand: '');

    // Aseguramos que la constraint esté inicializada si no existe
    rule.constraint ??= [constraint];
    if (rule.constraint!.isEmpty) {
      rule.constraint!.add(constraint);
    }

    return [
      // Action
      SizedBox(
        width: 240,
        child: DropdownButtonFormField<String>(
          decoration: _inputStyle('new_policy_page.action'.tr()),
          value: rule.action.isNotEmpty ? rule.action : null,
          items: ['USE', 'READ', 'WRITE', 'MODIFY', 'DELETE', 'LOG', 'NOTIFY', 'ANONYMIZE']
              .map((action) => DropdownMenuItem(value: action, child: Text(action)))
              .toList(),
          onChanged: (value) {
            ruleList[index].action = value ?? '';
          },
        ),
      ),
      const SizedBox(width: 8),

      // Left Operand
      SizedBox(
        width: 240,
        child: TextFormField(
          decoration: _inputStyle('new_policy_page.left_operand'.tr()),
          initialValue: constraint.leftOperand,
          onChanged: (value) {
            ruleList[index].constraint![0].leftOperand = value;
          },
        ),
      ),
      const SizedBox(width: 8),

      // Operator
      SizedBox(
        width: 240,
        child: TextFormField(
          decoration: _inputStyle('new_policy_page.operator'.tr()),
          initialValue: constraint.operator.id,
          onChanged: (value) {
            ruleList[index].constraint![0].operator.id = value;
          },
        ),
      ),
      const SizedBox(width: 8),

      // Right Operand
      SizedBox(
        width: 240,
        child: TextFormField(
          decoration: _inputStyle('new_policy_page.right_operand'.tr()),
          initialValue: constraint.rightOperand,
          onChanged: (value) {
            ruleList[index].constraint![0].rightOperand = value;
          },
        ),
      ),
    ];
  }

}

