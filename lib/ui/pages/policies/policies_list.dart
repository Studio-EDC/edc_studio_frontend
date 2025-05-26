import 'package:edc_studio/ui/widgets/header.dart';
import 'package:flutter/material.dart';

class PoliciesListPage extends StatefulWidget {
  const PoliciesListPage({super.key});

  @override
  State<PoliciesListPage> createState() => _PoliciesListPageState();
}

class _PoliciesListPageState extends State<PoliciesListPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            EDCHeader(currentPage: 'Policies'),
          ],
        ),
      ),
    );
  }
}