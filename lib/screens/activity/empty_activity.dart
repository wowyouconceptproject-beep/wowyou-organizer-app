import "package:flutter/material.dart";

class EmptyActivity
    extends StatelessWidget {
  const EmptyActivity({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return const Center(
      child: Column(
        mainAxisSize:
            MainAxisSize.min,
        children: [

          Icon(
            Icons.history,
            size: 64,
            color: Colors.grey,
          ),

          SizedBox(
            height: 16,
          ),

          Text(
            "No activity yet.",
            style: TextStyle(
              fontSize: 18,
              fontWeight:
                  FontWeight.w600,
            ),
          ),

          SizedBox(
            height: 8,
          ),

          Text(
            "Check-ins and staff actions will appear here.",
            textAlign:
                TextAlign.center,
          ),
        ],
      ),
    );
  }
}