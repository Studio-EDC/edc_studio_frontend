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
          _buildNavTile(context, icon: Icons.list, label: 'EDC List', route: '/'),
          _buildNavTile(context, icon: Icons.policy, label: 'Policies', route: '/policies'),
          _buildNavTile(context, icon: Icons.layers, label: 'Assets', route: '/assets'),
          _buildNavTile(context, icon: Icons.assignment, label: 'Contracts', route: '/contracts'),
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