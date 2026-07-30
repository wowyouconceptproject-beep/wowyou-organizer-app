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
  Widget build(BuildContext context) {
    final auth =
        context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        title: const Text(
          "WOWYOU Operations",
        ),
        actions: [

          IconButton(
            onPressed: () {},
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

              PageHeader(
                title:
                    auth.event?.title ??
                        "Event",

                subtitle:
                    auth.event?.venue ??
                        "",
              ),

              AppSpacing.section,

              DashboardHeader(
                staff:
                    auth.staff,
                event:
                    auth.event,
              ),

              AppSpacing.section,

              const QuickActions(),

              AppSpacing.section,

              const LiveStatusCard(),

              AppSpacing.section,

              const RecentActivityCard(),
            ],
          ),
        ),
      ),
    );
  }
}