import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MenuDrawer extends StatelessWidget {
  const MenuDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Image.asset(
              'assets/edc_logo.png',
              height: 100,
            ),
          ),
          _buildNavTile(context, icon: Icons.list, label: 'edc_list'.tr(), route: '/'),
          _buildNavTile(context, icon: Icons.layers, label: 'assets'.tr(), route: '/assets'),
          _buildNavTile(context, icon: Icons.policy, label: 'policies'.tr(), route: '/policies'),
          _buildNavTile(context, icon: Icons.assignment, label: 'contracts'.tr(), route: '/contracts'),
          _buildNavTile(context, icon: Icons.swap_horiz, label: 'transfers'.tr(), route: '/transfers'),
        ],
      ),
    );
  }

  Widget _buildNavTile(BuildContext context, {
    required IconData icon,
    required String label,
    required String route,
  }) {
    final bool isActive = GoRouter.of(context).routerDelegate.currentConfiguration.uri.toString() == route;

    final color = isActive
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.secondary;

    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        label,
        style: TextStyle(fontSize: 15, color: color),
      ),
      onTap: () {
        Navigator.of(context).pop();
        context.go(route);
      },
    );
  }

}