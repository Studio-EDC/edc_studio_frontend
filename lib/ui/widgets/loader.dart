import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

void showLoader(BuildContext context) {
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (_) => Center(
      child: LoadingAnimationWidget.fourRotatingDots(
        color: Theme.of(context).colorScheme.primary,
        size: 50,
      ),
    ),
  );
}

void hideLoader(BuildContext context) {
  Navigator.of(context, rootNavigator: true).pop();
}
