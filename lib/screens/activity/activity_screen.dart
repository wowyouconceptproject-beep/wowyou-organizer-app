import "package:flutter/material.dart";
import "package:provider/provider.dart";

import "../../providers/activity_provider.dart";

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
      context
          .read<ActivityProvider>()
          .load();
    });
  }

  @override
  Widget build(
    BuildContext context,
  ) {
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