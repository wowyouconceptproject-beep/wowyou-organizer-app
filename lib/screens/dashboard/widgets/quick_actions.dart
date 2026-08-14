import "package:flutter/material.dart";
import "package:provider/provider.dart";

import "../../../providers/auth_provider.dart";
import "../../scan/scan_screen.dart";

class QuickActions extends StatelessWidget {
  const QuickActions({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final auth =
        context.watch<AuthProvider>();

    final actions =
        <_QuickAction>[
          if (auth.canScanQr)
            const _QuickAction(
              title: "Scan QR",
              subtitle:
                  "Scan an attendee pass",
              icon:
                  Icons.qr_code_scanner,
            ),

          if (auth.canVerifyPass)
            const _QuickAction(
              title: "Verify Pass",
              subtitle:
                  "Verify attendee access",
              icon:
                  Icons.verified_outlined,
            ),

          if (auth.canSearchAttendee)
            const _QuickAction(
              title: "Search Attendee",
              subtitle:
                  "Find an attendee",
              icon:
                  Icons.person_search_outlined,
            ),

          if (auth.canViewActivity)
            const _QuickAction(
              title: "Activity",
              subtitle:
                  "View live event activity",
              icon:
                  Icons.timeline_outlined,
            ),

          if (auth.canSendNotification)
            const _QuickAction(
              title: "Notification",
              subtitle:
                  "Send event notification",
              icon:
                  Icons.notifications_outlined,
            ),

          if (auth.canSendAnnouncement)
            const _QuickAction(
              title: "Announcement",
              subtitle:
                  "Broadcast an announcement",
              icon:
                  Icons.campaign_outlined,
            ),

          if (auth.canManageStaff)
            const _QuickAction(
              title: "Staff",
              subtitle:
                  "Manage event staff",
              icon:
                  Icons.groups_outlined,
            ),

          if (auth.canManageVendors)
            const _QuickAction(
              title: "Vendors",
              subtitle:
                  "Manage event vendors",
              icon:
                  Icons.storefront_outlined,
            ),

          if (auth.canViewReports)
            const _QuickAction(
              title: "Reports",
              subtitle:
                  "View event reports",
              icon:
                  Icons.bar_chart_outlined,
            ),

          if (auth.canEditEvent)
            const _QuickAction(
              title: "Edit Event",
              subtitle:
                  "Manage event details",
              icon:
                  Icons.edit_outlined,
            ),
        ];

    if (actions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const Text(
          "Quick Actions",
          style: TextStyle(
            fontSize: 18,
            fontWeight:
                FontWeight.w700,
          ),
        ),

        const SizedBox(
          height: 14,
        ),

        GridView.builder(
          shrinkWrap: true,

          physics:
              const NeverScrollableScrollPhysics(),

          itemCount:
              actions.length,

          gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.45,
          ),

          itemBuilder:
              (
                context,
                index,
              ) {
            final action =
                actions[index];

            return _ActionCard(
              action: action,

              onTap: () =>
                  _handleAction(
                context,
                action,
              ),
            );
          },
        ),
      ],
    );
  }

  /*
  |--------------------------------------------------------------------------
  | Action Routing
  |--------------------------------------------------------------------------
  */

  void _handleAction(
    BuildContext context,
    _QuickAction action,
  ) {
    final auth =
        context.read<AuthProvider>();

    switch (action.title) {
      case "Scan QR":
        if (!auth.canScanQr) {
          return;
        }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                const ScanScreen(),
          ),
        );

        return;

      default:
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          SnackBar(
            content: Text(
              "${action.title} selected",
            ),
          ),
        );

        return;
    }
  }
}

/*
|--------------------------------------------------------------------------
| Quick Action Model
|--------------------------------------------------------------------------
*/

class _QuickAction {
  final String title;

  final String subtitle;

  final IconData icon;

  const _QuickAction({
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}

/*
|--------------------------------------------------------------------------
| Action Card
|--------------------------------------------------------------------------
*/

class _ActionCard
    extends StatelessWidget {
  final _QuickAction action;

  final VoidCallback onTap;

  const _ActionCard({
    required this.action,
    required this.onTap,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Material(
      color: Colors.white,

      borderRadius:
          BorderRadius.circular(16),

      child: InkWell(
        onTap: onTap,

        borderRadius:
            BorderRadius.circular(16),

        child: Container(
          padding:
              const EdgeInsets.all(16),

          decoration:
              BoxDecoration(
            border:
                Border.all(
              color:
                  Colors.grey.shade200,
            ),

            borderRadius:
                BorderRadius.circular(16),
          ),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              Icon(
                action.icon,
                size: 28,
              ),

              const Spacer(),

              Text(
                action.title,

                maxLines: 1,

                overflow:
                    TextOverflow.ellipsis,

                style:
                    const TextStyle(
                  fontSize: 15,
                  fontWeight:
                      FontWeight.w700,
                ),
              ),

              const SizedBox(
                height: 4,
              ),

              Text(
                action.subtitle,

                maxLines: 2,

                overflow:
                    TextOverflow.ellipsis,

                style:
                    const TextStyle(
                  fontSize: 12,
                  color:
                      Colors.black54,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}