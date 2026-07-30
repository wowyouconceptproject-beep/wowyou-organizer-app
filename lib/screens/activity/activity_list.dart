import "package:flutter/material.dart";

import "../../models/activity_event.dart";

import "activity_tile.dart";

class ActivityList
    extends StatelessWidget {
  final List<ActivityEvent>
      activities;

  const ActivityList({
    super.key,
    required this.activities,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return ListView.separated(
      physics:
          const AlwaysScrollableScrollPhysics(),

      itemCount:
          activities.length,

      separatorBuilder:
          (_, __) =>
              const Divider(
        height: 1,
      ),

      itemBuilder:
          (context, index) {
        return ActivityTile(
          activity:
              activities[index],
        );
      },
    );
  }
}