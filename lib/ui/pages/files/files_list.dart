import 'package:easy_localization/easy_localization.dart';
import 'package:edc_studio/api/models/file.dart';
import 'package:edc_studio/api/models/user.dart';
import 'package:edc_studio/api/services/users_service.dart';
import 'package:edc_studio/ui/widgets/file_card.dart';
import 'package:edc_studio/ui/widgets/header.dart';
import 'package:edc_studio/ui/widgets/menu_drawer.dart';
import 'package:flutter/material.dart';

class FilesListPage extends StatefulWidget {
  const FilesListPage({super.key});

  @override
  State<FilesListPage> createState() => _FilesListPageState();
}

class _FilesListPageState extends State<FilesListPage> {
  final List<Map<String, dynamic>> files = const [
    {
      "username": "itziarmensa",
      "filename": "data_pull_file",
      "size": 5645,
      "modified": "2025-06-23T09:39:05"
    },
    {
      "username": "itziarmensa",
      "filename": "policy_push_backup",
      "size": 12930,
      "modified": "2025-06-24T13:17:10"
    },
    {
      "username": "itziarmensa",
      "filename": "connector_logs",
      "size": 89321,
      "modified": "2025-06-20T18:45:33"
    },
  ];

  final UsersService _usersService = UsersService();

  List<User> listUsers = [];
  List<FileModel> listFiles = [];
  String? selectedUsername;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    final users = await _usersService.getUsers();
    setState(() {
      listUsers = users;
    });
  }

  Future<void> _loadFiles() async {
    final files = await _usersService.getFiles(selectedUsername ?? '');
    setState(() {
      if (files != null) listFiles = files;
    });
  }

  @override
  Widget build(BuildContext context) {

    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      endDrawer: const MenuDrawer(),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          EDCHeader(currentPage: 'files'),
          Padding(
            padding: isMobile
                  ? const EdgeInsets.symmetric(horizontal: 20, vertical: 24)
                  : const EdgeInsets.symmetric(horizontal: 80, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 15),
                Text(
                  'list_files.select_user'.tr(),
                  style: TextStyle(fontSize: 15, color: Theme.of(context).colorScheme.secondary),
                ),
                const SizedBox(height: 24),
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
                        value: selectedUsername,
                        hint: Text('list_files.select_user_hint'.tr()),
                        icon: const Icon(Icons.arrow_drop_down),
                        isExpanded: true,
                        onChanged: (value) {
                          setState(() => selectedUsername = value!);
                          _loadFiles();
                        },
                        items: listUsers.map((user) {
                          return DropdownMenuItem<String>(
                            value: user.username,
                            child: Text(user.username, style: TextStyle(fontSize: 15, color: Theme.of(context).colorScheme.secondary)),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ]
            )
          ),
          Expanded(
            child: listFiles.isEmpty ?
            Center(
              child: Text('list_files.no_data'.tr()),
            )
            :
            SingleChildScrollView(
              child: Wrap(
                spacing: 16,
                runSpacing: 16,
                children: listFiles.map((file) {
                  return SizedBox(
                    width: 450, 
                    height: 150,
                    child: FileCard(
                      username: file.username,
                      filename: file.filename,
                      size: file.size,
                      modified: file.modified.toIso8601String(),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
