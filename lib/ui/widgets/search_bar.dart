import 'package:flutter/material.dart';

class SearchBarCustom extends StatelessWidget {
  final String hintText;
  final void Function(String)? onChanged;

  const SearchBarCustom({
    super.key,
    required this.hintText,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      height: 56,
      width: 360,
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.secondary),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                  fontSize: 15,
                ),
                border: InputBorder.none,
              ),
              onChanged: onChanged,
            ),
          ),
          Icon(Icons.search, size: 20, color: Theme.of(context).colorScheme.secondary),
        ],
      ),
    );
  }
}