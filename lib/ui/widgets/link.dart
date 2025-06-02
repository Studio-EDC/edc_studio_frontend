import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:html' as html; // solo se usa en web

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
          TextSpan(text: 'You can see the data here: ', style: TextStyle(fontSize: 15, color: Theme.of(context).colorScheme.secondary)),
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