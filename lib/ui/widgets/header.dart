import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class EDCHeader extends StatelessWidget {
  final String currentPage;

  const EDCHeader({
    super.key,
    required this.currentPage,
  });

  String _pageToPath(String page) {
    switch (page) {
      case 'EDC List':
        return '/';
      case 'Policies':
        return '/policies';
      case 'Assets':
        return '/assets';
      case 'Contracts':
        return '/contracts';
      default:
        return '/';
    }
  }

  @override
  Widget build(BuildContext context) {
    final navItems = ['EDC List', 'Assets', 'Policies', 'Contracts'];
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Container(
      height: 80,
      color: Theme.of(context).colorScheme.primary,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (!isMobile) 
                const SizedBox(width: 80)
              else 
                const SizedBox(width: 20),
              Image.asset(
                'assets/edc_logo.png',
                height: 100,
              ),
            ],
          ),

          Row(
            children: [
              if (!isMobile)
                ...navItems.map((item) {
                  final isActive = item == currentPage;
                  return Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: TextButton(
                      onPressed: () => context.go(_pageToPath(item)),
                      child: Text(
                        item,
                        style: TextStyle(
                          color: isActive
                              ? Colors.white
                              : Theme.of(context).colorScheme.secondary,
                          fontFamily: 'Public Sans',
                          fontSize: 15,
                        ),
                      ),
                    ),
                  );
                })
              else
                IconButton(
                  icon: const Icon(Icons.menu, color: Colors.white),
                  onPressed: () {
                    Scaffold.of(context).openEndDrawer();
                  },
                ),
              if (!isMobile) 
                const SizedBox(width: 80)
              else 
                const SizedBox(width: 20),
            ],
          ),
        ],
      ),
    );
  }
}