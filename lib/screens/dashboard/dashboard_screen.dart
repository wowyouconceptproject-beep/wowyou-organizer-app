import "package:flutter/material.dart";
import "package:provider/provider.dart";

import "../../providers/auth_provider.dart";

import "../../constants/app_spacing.dart";

import "../../widgets/common/page_header.dart";

import "widgets/dashboard_header.dart";
import "widgets/quick_actions.dart";
import "widgets/live_status_card.dart";
import "widgets/recent_activity_card.dart";

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final auth =
        context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor:
          Colors.white,

      appBar: AppBar(
        title: const Text(
          "WOWYOU Operations",
        ),

        actions: [
          IconButton(
            onPressed: () {
              /*
              |--------------------------------------------------------------------------
              | Logout
              |--------------------------------------------------------------------------
              |
              | Logout handling should eventually be connected to the auth
              | provider and realtime provider.
              |
              */
            },

            icon: const Icon(
              Icons.logout,
            ),
          ),
        ],
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding:
              AppSpacing.page,

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              /*
              |--------------------------------------------------------------------------
              | Event Header
              |--------------------------------------------------------------------------
              */

              PageHeader(
                title:
                    auth.event?.title ??
                        "Event",

                subtitle:
                    auth.event?.venue ??
                        "",
              ),

              AppSpacing.section,

              /*
              |--------------------------------------------------------------------------
              | Staff Header
              |--------------------------------------------------------------------------
              */

              DashboardHeader(
                staff:
                    auth.staff,

                event:
                    auth.event,
              ),

              /*
              |--------------------------------------------------------------------------
              | Dashboard
              |--------------------------------------------------------------------------
              |
              | Only staff with VIEW_DASHBOARD should see dashboard-specific
              | information.
              |
              */

              if (auth.canViewDashboard) ...[
                AppSpacing.section,

                const QuickActions(),

                AppSpacing.section,

                const LiveStatusCard(),

                AppSpacing.section,

                const RecentActivityCard(),
              ],

              /*
              |--------------------------------------------------------------------------
              | Activity-only Staff
              |--------------------------------------------------------------------------
              */

              if (!auth.canViewDashboard &&
                  auth.canViewActivity) ...[
                AppSpacing.section,

                const RecentActivityCard(),
              ],

              /*
              |--------------------------------------------------------------------------
              | No Dashboard Permission
              |--------------------------------------------------------------------------
              |
              | Some roles, such as SECURITY and CHECK_IN, do not have
              | VIEW_DASHBOARD. They should not be shown an empty dashboard.
              |
              */

              if (!auth.canViewDashboard &&
                  !auth.canViewActivity)
                ...[
                  AppSpacing.section,

                  _AccessSummary(
                    auth: auth,
                  ),
                ],
            ],
          ),
        ),
      ),
    );
  }
}

/*
|--------------------------------------------------------------------------
| Access Summary
|--------------------------------------------------------------------------
*/

class _AccessSummary
    extends StatelessWidget {
  final AuthProvider auth;

  const _AccessSummary({
    required this.auth,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final permissions =
        auth.permissions;

    return Container(
      width:
          double.infinity,

      padding:
          const EdgeInsets.all(20),

      decoration:
          BoxDecoration(
        color:
            Colors.grey.shade100,

        borderRadius:
            BorderRadius.circular(
          16,
        ),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Text(
            auth.role.isEmpty
                ? "Staff Access"
                : auth.role,

            style:
                const TextStyle(
              fontSize: 18,
              fontWeight:
                  FontWeight.w700,
            ),
          ),

          const SizedBox(
            height: 8,
          ),

          const Text(
            "You are signed in successfully. Your account is limited to the permissions assigned to your role.",

            style:
                TextStyle(
              color:
                  Colors.black54,

              height:
                  1.5,
            ),
          ),

          if (permissions.isNotEmpty) ...[
            const SizedBox(
              height: 16,
            ),

            Wrap(
              spacing: 8,
              runSpacing: 8,

              children:
                  permissions
                      .map(
                        (
                          permission,
                        ) =>
                            Chip(
                          label:
                              Text(
                            _formatPermission(
                              permission,
                            ),
                          ),
                        ),
                      )
                      .toList(),
            ),
          ],
        ],
      ),
    );
  }

  String _formatPermission(
    String permission,
  ) {
    return permission
        .toLowerCase()
        .split("_")
        .map(
          (word) =>
              word.isEmpty
                  ? ""
                  : "${word[0].toUpperCase()}${word.substring(1)}",
        )
        .join(" ");
  }
}