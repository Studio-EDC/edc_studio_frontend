// ignore_for_file: use_build_context_synchronously

import 'package:easy_localization/easy_localization.dart';
import 'package:edc_studio/api/models/user.dart';
import 'package:edc_studio/api/services/users_service.dart';
import 'package:edc_studio/ui/widgets/search_bar.dart';
import 'package:edc_studio/ui/widgets/snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class UsersSelector extends StatefulWidget {
  const UsersSelector({super.key});

  @override
  State<UsersSelector> createState() => _UsersSelectorState();
}

class _UsersSelectorState extends State<UsersSelector> {
  final UsersService _usersService = UsersService();

  List<User> _allUsers = [];
  List<User> _filteredUsers = [];

  bool list = true;
  bool login = false;
  bool register = false;

  TextEditingController username = TextEditingController();
  TextEditingController password = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    final users = await _usersService.getUsers();
    setState(() {
      _allUsers = users;
      _filteredUsers = users;
    });
  }

  void _filterUsers(String query) {
    setState(() {
      _filteredUsers = _allUsers
          .where((user) => user.username.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _onUserClick(User user) {
    if (list) {
      debugPrint('List mode: ${user.username}');
      setState(() {
        list = false;
        login = true;
        register = false;
        username.text = user.username;
      });
    } else if (login) {
      debugPrint('Login mode: Logging in as ${user.username}');
      // Aquí tu lógica de login
    } else if (register) {
      debugPrint('Register mode: Registering ${user.username}');
      // Aquí tu lógica de registro
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!list && !login && !register) {
      return Container(); // Si no hay ninguno activo
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        if (list)
          const SizedBox(height: 16),
        if (login || register)
          const SizedBox(height: 50),
        Text(
          list
              ? 'users_list_page.title_list'.tr()
              : login
                  ? 'users_list_page.login_title'.tr()
                  : 'users_list_page.title_register'.tr(),
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        if (list)
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SearchBarCustom(
                hintText: 'users_list_page.search'.tr(),
                onChanged: _filterUsers,
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () => context.go('/new_user'),
                icon: Icon(Icons.add, color: Theme.of(context).colorScheme.secondary),
                label: Text(
                  'users_list_page.new_user'.tr(),
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
        if (list)
          Expanded(
            child: _filteredUsers.isEmpty
                ? Column(children: [
                    const SizedBox(height: 100),
                    Text('users_list_page.no_users'.tr())
                  ])
                : ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: double.infinity),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                      child: DataTable(
                        columnSpacing: 20,
                        headingRowColor: WidgetStatePropertyAll(
                          Theme.of(context).colorScheme.tertiary,
                        ),
                        columns: [
                          DataColumn(
                            label: Text(
                              'users_list_page.username'.tr(),
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ],
                        rows: _filteredUsers.map((user) {
                          return DataRow(
                            cells: [
                              DataCell(
                                InkWell(
                                  onTap: () => _onUserClick(user),
                                  hoverColor: Colors.transparent,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    width: double.infinity,
                                    child: Text(
                                      user.username,
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.secondary,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
          ),
        if (login)
          Expanded(
            child: Column(
              children: [
                const SizedBox(height: 16),
                TextField(
                  controller: username,
                  decoration: InputDecoration(
                    hintText: 'users_list_page.username'.tr(),
                    hintStyle: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontSize: 15,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ), // <-- Este es el borde outline
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                        width: 2.0,
                      ),
                    ), // Opcional: define cómo se ve al enfocar
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: password,
                  decoration: InputDecoration(
                    hintText: 'users_list_page.password'.tr(),
                    hintStyle: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontSize: 15,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ), // <-- Este es el borde outline
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                        width: 2.0,
                      ),
                    ), // Opcional: define cómo se ve al enfocar
                  ),
                ),
                const SizedBox(height: 32),
                OutlinedButton.icon(
                  onPressed: () async {
                    final UsersService userService = UsersService();
                    final response = await userService.getToken(username.text, password.text);
                    if (response == null) {
                      FloatingSnackBar.show(
                        context,
                        message: response ?? '',
                        type: SnackBarType.error,
                        duration: const Duration(seconds: 3),
                        width: 600
                      );
                    }
                  },
                  label: Text(
                    'users_list_page.login'.tr(),
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
          )
      ],
    );
  }
}
