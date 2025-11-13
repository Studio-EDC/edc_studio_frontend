import 'package:easy_localization/easy_localization.dart';
import 'package:edc_studio/api/services/users_service.dart';
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
      case 'edc_list':
        return '/';
      case 'policies':
        return '/policies';
      case 'assets':
        return '/assets';
      case 'contracts':
        return '/contracts';
      case 'transfers':
        return '/transfers';
      case 'files':
        return '/files';
      default:
        return '/';
    }
  }

  @override
  Widget build(BuildContext context) {
    final navItems = ['edc_list', 'assets', 'policies', 'contracts', 'transfers', 'files'];
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

              if (isMobile)
              Padding(
                padding: const EdgeInsets.only(right: 20),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: context.locale.languageCode,
                    dropdownColor: Colors.white,
                    onChanged: (String? value) {
                      if (value != null) {
                        context.setLocale(Locale(value));
                      }
                    },
                    items: [
                      DropdownMenuItem(
                        value: 'es',
                        child: Image.asset('assets/flags/es.png', width: 24),
                      ),
                      DropdownMenuItem(
                        value: 'ca',
                        child: Image.asset('assets/flags/cat.png', width: 24),
                      ),
                      DropdownMenuItem(
                        value: 'en',
                        child: Image.asset('assets/flags/en.png', width: 24),
                      ),
                    ],
                  ),
                ),
              ),

              if (!isMobile)
                ...navItems.map((item) {
                  final isActive = item == currentPage;
                  return Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: TextButton(
                      onPressed: () => context.go(_pageToPath(item)),
                      child: Text(
                        item.tr(),
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

              if (isMobile) const SizedBox(width: 20),
              
              if (!isMobile)
              Padding(
                padding: const EdgeInsets.only(right: 20),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: context.locale.languageCode,
                    dropdownColor: Colors.white,
                    onChanged: (String? value) {
                      if (value != null) {
                        context.setLocale(Locale(value));
                      }
                    },
                    items: [
                      DropdownMenuItem(
                        value: 'es',
                        child: Image.asset('assets/flags/es.png', width: 24),
                      ),
                      DropdownMenuItem(
                        value: 'ca',
                        child: Image.asset('assets/flags/cat.png', width: 24),
                      ),
                      DropdownMenuItem(
                        value: 'en',
                        child: Image.asset('assets/flags/en.png', width: 24),
                      ),
                    ],
                  ),
                ),
              ),

              // --- LOGOUT BUTTON ---
              if (!isMobile)
                Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: IconButton(
                    onPressed: () async {
                      UsersService userService = UsersService();
                      await userService.logout();
                      context.go('/login');
                    },
                    icon: const Icon(Icons.logout, color: Colors.white),
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: IconButton(
                    icon: const Icon(Icons.logout, color: Colors.white),
                    onPressed: () {
                      context.go('/login');
                    },
                  ),
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