import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';
// ignore: deprecated_member_use, avoid_web_libraries_in_flutter
import 'dart:html' as html;

class LinkWidget extends StatelessWidget {
  final String url;

  const LinkWidget({super.key, required this.url});

  void _openUrl() async {
    if (kIsWeb) {
      html.window.open(url, '_blank');
    } else {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: TextStyle(
          color: Theme.of(context).colorScheme.secondary,
          fontSize: 15,
        ),
        children: [
          TextSpan(text: 'new_transfer_page.see_data'.tr(), style: TextStyle(fontSize: 15, color: Theme.of(context).colorScheme.secondary)),
          TextSpan(
            text: url,
            style: TextStyle(
              decoration: TextDecoration.underline,
              fontSize: 15, color: Theme.of(context).colorScheme.secondary
            ),
            recognizer: TapGestureRecognizer()..onTap = _openUrl,
          ),
        ],
      ),
    );
  }
}