import 'package:edc_studio/ui/pages/edc_detail.dart';
import 'package:edc_studio/ui/pages/edc_list.dart';
import 'package:edc_studio/ui/pages/new_edc.dart';
import 'package:edc_studio/ui/pages/policies_list.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      pageBuilder: (context, state) => _buildFadeTransition(
        key: state.pageKey,
        child: const EDCListPage(),
      ),
    ),
    GoRoute(
      path: '/new_edc',
      pageBuilder: (context, state) => _buildFadeTransition(
        key: state.pageKey,
        child: const NewEDCPage(),
      ),
    ),
    GoRoute(
      path: '/edc_detail/:id',
      pageBuilder: (context, state) {
        final id = state.pathParameters['id']!;
        return _buildFadeTransition(
          key: state.pageKey,
          child: EDCDetailPage(id: id),
        );
      },
    ),
    GoRoute(
      path: '/policies',
      pageBuilder: (context, state) => _buildFadeTransition(
        key: state.pageKey,
        child: const PoliciesListPage(),
      ),
    ),
    GoRoute(
      path: '/assets',
      builder: (context, state) => const PoliciesListPage(),
    ),
    GoRoute(
      path: '/contracts',
      builder: (context, state) => const PoliciesListPage(),
    ),
  ],
);

CustomTransitionPage _buildFadeTransition({
  required LocalKey key,
  required Widget child,
}) {
  return CustomTransitionPage(
    key: key,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation,
        child: child,
      );
    },
  );
}

