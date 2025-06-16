import 'package:edc_studio/ui/pages/assets/asset_detail.dart';
import 'package:edc_studio/ui/pages/assets/assets_list.dart';
import 'package:edc_studio/ui/pages/assets/new_asset.dart';
import 'package:edc_studio/ui/pages/contracts/contracts_list.dart';
import 'package:edc_studio/ui/pages/contracts/new_contract.dart';
import 'package:edc_studio/ui/pages/edc/edc_detail.dart';
import 'package:edc_studio/ui/pages/edc/edc_list.dart';
import 'package:edc_studio/ui/pages/edc/new_edc.dart';
import 'package:edc_studio/ui/pages/policies/new_policy.dart';
import 'package:edc_studio/ui/pages/policies/policies_list.dart';
import 'package:edc_studio/ui/pages/policies/policy_detail.dart';
import 'package:edc_studio/ui/pages/transfers/new_transfer.dart';
import 'package:edc_studio/ui/pages/transfers/transfers_list.dart';
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
      path: '/policy-detail/:edcId/:assetId',
      pageBuilder: (context, state) {

        final edcId = state.pathParameters['edcId']!;
        final policyId = state.pathParameters['assetId']!;

        return _buildFadeTransition(
          key: state.pageKey,
          child: PolicyDetailPage(
            policyId: policyId,
            edcId: edcId,
          ),
        );
      },
    ),
    GoRoute(
      path: '/new_policy',
      pageBuilder: (context, state) => _buildFadeTransition(
        key: state.pageKey,
        child: const NewPolicyPage(),
      ),
    ),
    GoRoute(
      path: '/assets',
      pageBuilder: (context, state) => _buildFadeTransition(
        key: state.pageKey,
        child: const AssetsListPage(),
      ),
    ),
    GoRoute(
      path: '/asset-detail/:edcId/:assetId',
      pageBuilder: (context, state) {

        final edcId = state.pathParameters['edcId']!;
        final assetId = state.pathParameters['assetId']!;

        return _buildFadeTransition(
          key: state.pageKey,
          child: AssetDetailPage(
            assetId: assetId,
            edcId: edcId,
          ),
        );
      },
    ),
    GoRoute(
      path: '/new_asset',
      pageBuilder: (context, state) => _buildFadeTransition(
        key: state.pageKey,
        child: const NewAssetPage(),
      ),
    ),
    GoRoute(
      path: '/contracts',
      pageBuilder: (context, state) => _buildFadeTransition(
        key: state.pageKey,
        child: const ContractsListPage(),
      ),
    ),
    GoRoute(
      path: '/new_contract',
      pageBuilder: (context, state) => _buildFadeTransition(
        key: state.pageKey,
        child: const NewContractPage(),
      ),
    ),
    GoRoute(
      path: '/transfers',
      pageBuilder: (context, state) => _buildFadeTransition(
        key: state.pageKey,
        child: const TransfersListPage(),
      ),
    ),
    GoRoute(
      path: '/new_transfer',
      pageBuilder: (context, state) => _buildFadeTransition(
        key: state.pageKey,
        child: const NewTransferPage(),
      ),
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

