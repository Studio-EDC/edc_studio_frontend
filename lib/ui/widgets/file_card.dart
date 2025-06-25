// ignore_for_file: use_build_context_synchronously

import 'package:easy_localization/easy_localization.dart';
import 'package:edc_studio/api/services/users_service.dart';
import 'package:edc_studio/ui/widgets/snack_bar.dart';
import 'package:edc_studio/ui/widgets/user_selector.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FileCard extends StatelessWidget {
  final String username;
  final String filename;
  final int size;
  final String modified;

  const FileCard({
    super.key,
    required this.username,
    required this.filename,
    required this.size,
    required this.modified,
  });

  String get formattedDate {
    final dateTime = DateTime.parse(modified);
    return DateFormat('dd MMM yyyy – HH:mm').format(dateTime);
  }

  String get formattedSize {
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(2)} KB';
    return '${(size / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.insert_drive_file_rounded,
              size: 40,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center, 
                children: [
                  Text(
                    filename,
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${'list_files.modified'.tr()}: $formattedDate',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    '${'list_files.size'.tr()}: $formattedSize',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                final usernamePrefs = prefs.getString('username');
                if (usernamePrefs == username) {
                  final UsersService userService = UsersService();
                  final response = await userService.downloadFile(filename);
                  if (response != null) {
                    FloatingSnackBar.show(
                      context,
                      message: response,
                      type: SnackBarType.error,
                      duration: const Duration(seconds: 3),
                      width: 600
                    );
                  }
                } else {
                  await showModalBottomSheet(
                    context: context,
                    isScrollControlled: true, 
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    builder: (context) {
                      return FractionallySizedBox(
                        heightFactor: 0.8, 
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Expanded(
                                child: UsersSelector(
                                  mode: 'login',
                                  username: username,
                                  filename: filename,
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: Text('close'.tr()),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
              }, 
              icon: Icon(Icons.download, color: Theme.of(context).colorScheme.primary),
            )
          ],
        ),
      ),
    );
  }
}