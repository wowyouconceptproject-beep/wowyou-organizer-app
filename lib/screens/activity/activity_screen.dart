import "package:flutter/material.dart";
import "package:provider/provider.dart";

import "../../providers/activity_provider.dart";
import "../../providers/auth_provider.dart";

import "activity_list.dart";
import "empty_activity.dart";

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({
    super.key,
  });

  @override
  State<ActivityScreen> createState() =>
      _ActivityScreenState();
}

class _ActivityScreenState
    extends State<ActivityScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance
        .addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      final auth =
          context.read<AuthProvider>();

      if (!auth.canViewActivity) {
        return;
      }

      context
          .read<ActivityProvider>()
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

    if (!auth.canViewActivity) {
      return Scaffold(
        backgroundColor:
            Colors.white,

        appBar: AppBar(
          title:
              const Text("Activity"),
          centerTitle: true,
        ),

        body: const Center(
          child: Padding(
            padding:
                EdgeInsets.all(24),
            child: Text(
              "You do not have permission to view event activity.",
              textAlign:
                  TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color:
                    Colors.black54,
              ),
            ),
          ),
        ),
      );
    }

    final provider =
        context.watch<ActivityProvider>();

    return Scaffold(
      backgroundColor:
          Colors.white,

      appBar: AppBar(
        title:
            const Text("Activity"),
        centerTitle: true,
      ),

      body: provider.loading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : provider.history.isEmpty
              ? const EmptyActivity()
              : RefreshIndicator(
                  onRefresh:
                      provider.refresh,

                  child:
                      ActivityList(
                    activities:
                        provider.history,
                  ),
                ),
    );
  }
}