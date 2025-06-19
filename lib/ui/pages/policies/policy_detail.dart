// ignore_for_file: use_build_context_synchronously


import 'package:easy_localization/easy_localization.dart';
import 'package:edc_studio/api/models/policy.dart';
import 'package:edc_studio/api/services/edc_service.dart';
import 'package:edc_studio/api/services/policies_service.dart';
import 'package:edc_studio/ui/widgets/header.dart';
import 'package:edc_studio/ui/widgets/menu_drawer.dart';
import 'package:flutter/material.dart';

class PolicyDetailPage extends StatefulWidget {
  final String policyId;
  final String edcId;

  const PolicyDetailPage({
    super.key,
    required this.policyId,
    required this.edcId,
  });

  @override
  State<PolicyDetailPage> createState() => _PolicyDetailPageState();
}

class _PolicyDetailPageState extends State<PolicyDetailPage> {

  final PoliciesService _policyService = PoliciesService();
  final EdcService _edcService = EdcService();

  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _policyIdController = TextEditingController();

  String edcStateSelected = '';

  List<Rule> permissions = [];
  List<Rule> prohibitions = [];
  List<Rule> obligations = [];

  Future<void> _loadPolicy() async {
    final policy = await _policyService.getPolicyByPolicyId(widget.edcId, widget.policyId);
    if (policy != null) {
      setState(() {
        _policyIdController.text = policy.policyId;
        permissions = policy.policy.permission ?? [];
        numPermissions = permissions.length;
        prohibitions = policy.policy.prohibition ?? [];
        numProhibitions = prohibitions.length;
        obligations = policy.policy.obligation ?? [];
        numObligations = obligations.length;
      });
    }

    final connector = await _edcService.getConnectorByID(widget.edcId);
    if (connector != null) {
      setState(() {
        edcStateSelected = connector.state;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadPolicy();
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
                                'update_policy_page.title'.tr(),
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              const SizedBox(height: 24),

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
                                decoration: _inputStyle('new_policy_page.policy_id'.tr()),
                              ),

                              const SizedBox(height: 16),

                              if (numPermissions > 0)
                              Text('new_policy_page.permissions'.tr(), style: TextStyle(fontSize: 15, color: Theme.of(context).colorScheme.secondary)),

                              if (numPermissions > 0)
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

                              if (numProhibitions > 0)
                              Text('new_policy_page.prohibitions'.tr(), style: TextStyle(fontSize: 15, color: Theme.of(context).colorScheme.secondary)),
                              
                              if (numPermissions > 0)
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

                              if (numObligations > 0)
                              Text('new_policy_page.obligations'.tr(), style: TextStyle(fontSize: 15, color: Theme.of(context).colorScheme.secondary)),

                              if (numObligations > 0)
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
                              
                              const SizedBox(height: 32),
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