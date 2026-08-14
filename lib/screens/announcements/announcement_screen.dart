import "package:flutter/material.dart";
import "package:provider/provider.dart";

import "../../providers/auth_provider.dart";
import "../../providers/announcement_provider.dart";

import "../../widgets/announcement_card.dart";

import "broadcast_announcement_screen.dart";

class AnnouncementScreen
    extends StatefulWidget {
  const AnnouncementScreen({
    super.key,
  });

  @override
  State<AnnouncementScreen> createState() =>
      _AnnouncementScreenState();
}

class _AnnouncementScreenState
    extends State<AnnouncementScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      if (!mounted) {
        return;
      }

      final auth =
          context.read<AuthProvider>();

      /*
      |--------------------------------------------------------------------------
      | Permission Guard
      |--------------------------------------------------------------------------
      */

      if (!auth.canSendAnnouncement) {
        return;
      }

      context
          .read<AnnouncementProvider>()
          .load();
    });
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final auth =
        context.watch<AuthProvider>();

    /*
    |--------------------------------------------------------------------------
    | Permission Guard
    |--------------------------------------------------------------------------
    */

    if (!auth.canSendAnnouncement) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Announcements",
          ),
        ),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              "You do not have permission to view announcements.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
          ),
        ),
      );
    }

    final provider =
        context.watch<AnnouncementProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Announcements",
        ),
      ),

      /*
      |--------------------------------------------------------------------------
      | Broadcast
      |--------------------------------------------------------------------------
      */

      floatingActionButton:
          auth.canSendAnnouncement
              ? FloatingActionButton.extended(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const BroadcastAnnouncementScreen(),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.campaign,
                  ),
                  label: const Text(
                    "Broadcast",
                  ),
                )
              : null,

      /*
      |--------------------------------------------------------------------------
      | Announcements
      |--------------------------------------------------------------------------
      */

      body: RefreshIndicator(
        onRefresh:
            provider.refresh,

        child: Builder(
          builder: (_) {
            if (provider.loading &&
                provider.announcements.isEmpty) {
              return const Center(
                child:
                    CircularProgressIndicator(),
              );
            }

            if (provider.announcements.isEmpty) {
              return ListView(
                physics:
                    const AlwaysScrollableScrollPhysics(),

                children: const [
                  SizedBox(
                    height: 180,
                  ),

                  Icon(
                    Icons.campaign_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),

                  SizedBox(
                    height: 16,
                  ),

                  Center(
                    child: Text(
                      "No announcements yet.",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              );
            }

            return ListView.separated(
              padding:
                  const EdgeInsets.all(16),

              itemCount:
                  provider.announcements.length,

              separatorBuilder:
                  (_, __) =>
                      const SizedBox(
                height: 12,
              ),

              itemBuilder:
                  (_, index) {
                return AnnouncementCard(
                  announcement:
                      provider.announcements[
                          index],
                );
              },
            );
          },
        ),
      ),
    );
  }
}