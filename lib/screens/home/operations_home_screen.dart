import "package:flutter/material.dart";
import "package:provider/provider.dart";

import "../../providers/auth_provider.dart";
import "../../providers/realtime_provider.dart";

import "../dashboard/dashboard_screen.dart";

class OperationsHomeScreen
    extends StatelessWidget {
  const OperationsHomeScreen({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final auth =
        context.watch<AuthProvider>();

    /*
    |--------------------------------------------------------------------------
    | Dashboard
    |--------------------------------------------------------------------------
    |
    | OWNER and OPERATIONS have VIEW_DASHBOARD.
    |
    */

    if (auth.canViewDashboard) {
      return const DashboardScreen();
    }

    /*
    |--------------------------------------------------------------------------
    | Check-In Operations
    |--------------------------------------------------------------------------
    */

    if (auth.canScanQr ||
        auth.canVerifyPass ||
        auth.canSearchAttendee) {
      return const _PermissionHomeScreen(
        title:
            "Check-In Operations",
        subtitle:
            "Manage attendee verification and event access.",
      );
    }

    /*
    |--------------------------------------------------------------------------
    | Activity
    |--------------------------------------------------------------------------
    */

    if (auth.canViewActivity) {
      return const _PermissionHomeScreen(
        title:
            "Event Operations",
        subtitle:
            "Monitor live event activity.",
      );
    }

    /*
    |--------------------------------------------------------------------------
    | Vendor Management
    |--------------------------------------------------------------------------
    */

    if (auth.canManageVendors) {
      return const _PermissionHomeScreen(
        title:
            "Vendor Management",
        subtitle:
            "Manage event vendors and marketplace activity.",
      );
    }

    /*
    |--------------------------------------------------------------------------
    | Fallback
    |--------------------------------------------------------------------------
    */

    return const _PermissionHomeScreen(
      title:
          "Operations",
      subtitle:
          "Your account has been authenticated, but no operational permissions are available.",
    );
  }
}

/*
|--------------------------------------------------------------------------
| Permission Home
|--------------------------------------------------------------------------
*/

class _PermissionHomeScreen
    extends StatelessWidget {
  final String title;

  final String subtitle;

  const _PermissionHomeScreen({
    required this.title,
    required this.subtitle,
  });

  /*
  |--------------------------------------------------------------------------
  | Logout
  |--------------------------------------------------------------------------
  */

  Future<void> _logout(
    BuildContext context,
  ) async {
    final auth =
        context.read<AuthProvider>();

    final realtime =
        context.read<RealtimeProvider>();

    await auth.logout(
      realtime,
    );

    if (!context.mounted) {
      return;
    }

    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(
      "/",
      (route) => false,
    );
  }

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
            tooltip:
                "Sign out",

            onPressed: () =>
                _logout(context),

            icon: const Icon(
              Icons.logout,
            ),
          ),
        ],
      ),

      body: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.all(24),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              const SizedBox(
                height: 24,
              ),

              /*
              |--------------------------------------------------------------------------
              | Page Title
              |--------------------------------------------------------------------------
              */

              Text(
                title,

                style:
                    const TextStyle(
                  fontSize: 28,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(
                height: 8,
              ),

              Text(
                subtitle,

                style:
                    const TextStyle(
                  fontSize: 15,
                  color:
                      Colors.black54,
                  height: 1.5,
                ),
              ),

              const SizedBox(
                height: 32,
              ),

              /*
              |--------------------------------------------------------------------------
              | Staff
              |--------------------------------------------------------------------------
              */

              Text(
                auth.staffName,

                style:
                    const TextStyle(
                  fontSize: 18,
                  fontWeight:
                      FontWeight.w600,
                ),
              ),

              const SizedBox(
                height: 4,
              ),

              Text(
                auth.role,

                style:
                    const TextStyle(
                  color:
                      Colors.black54,
                ),
              ),

              const SizedBox(
                height: 24,
              ),

              /*
              |--------------------------------------------------------------------------
              | Available Permissions
              |--------------------------------------------------------------------------
              */

              const Text(
                "Your access",

                style:
                    TextStyle(
                  fontSize: 16,
                  fontWeight:
                      FontWeight.w600,
                ),
              ),

              const SizedBox(
                height: 12,
              ),

              if (auth.permissions.isEmpty)
                const Text(
                  "No operational permissions assigned.",

                  style:
                      TextStyle(
                    color:
                        Colors.black54,
                  ),
                )
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,

                  children:
                      auth.permissions
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
          ),
        ),
      ),
    );
  }

  /*
  |--------------------------------------------------------------------------
  | Permission Formatting
  |--------------------------------------------------------------------------
  */

  String _formatPermission(
    String permission,
  ) {
    return permission
        .toLowerCase()
        .split("_")
        .map(
          (word) {
            if (word.isEmpty) {
              return "";
            }

            return word[0]
                    .toUpperCase() +
                word.substring(1);
          },
        )
        .join(" ");
  }
}