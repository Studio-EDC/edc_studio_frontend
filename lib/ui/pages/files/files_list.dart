import 'package:easy_localization/easy_localization.dart';
import 'package:edc_studio/api/models/file.dart';
import 'package:edc_studio/api/services/users_service.dart';
import 'package:edc_studio/ui/widgets/file_card.dart';
import 'package:edc_studio/ui/widgets/header.dart';
import 'package:edc_studio/ui/widgets/menu_drawer.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FilesListPage extends StatefulWidget {
  const FilesListPage({super.key});

  @override
  State<FilesListPage> createState() => _FilesListPageState();
}

class _FilesListPageState extends State<FilesListPage> {

  final UsersService _usersService = UsersService();

  List<FileModel> listFiles = [];
  String? selectedUsername;

  @override
  void initState() {
    super.initState();
    _loadFiles();
  }

  Future<void> _loadFiles() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username');
    final files = await _usersService.getFiles(username ?? '');
    setState(() {
      if (files != null) {
        files.sort((a, b) => b.modified.compareTo(a.modified));
        listFiles = files;
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      endDrawer: const MenuDrawer(),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          EDCHeader(currentPage: 'files'),
          const SizedBox(height: 30),
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
