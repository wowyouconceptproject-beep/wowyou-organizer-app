import "package:flutter/material.dart";

import "../../models/activity_event.dart";

class ActivityTile
    extends StatelessWidget {
  final ActivityEvent
      activity;

  const ActivityTile({
    super.key,
    required this.activity,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return ListTile(
      leading: CircleAvatar(
        child: Text(
          activity.type
              .substring(
            0,
            1,
          ),
        ),
      ),

      title: Text(
        activity.title,
        style:
            const TextStyle(
          fontWeight:
              FontWeight.bold,
        ),
      ),

      subtitle: Column(
        crossAxisAlignment:
            CrossAxisAlignment
                .start,
        children: [

          Text(
            activity.description,
          ),

          const SizedBox(
            height: 4,
          ),

          Text(
            activity.createdAt
                .toLocal()
                .toString(),
            style:
                const TextStyle(
              fontSize: 12,
              color:
                  Colors.grey,
            ),
          ),
        ],
      ),

      isThreeLine: true,
    );
  }
}