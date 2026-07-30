import "package:flutter/material.dart";

import "../../../models/event.dart";
import "../../../models/staff.dart";

class DashboardHeader extends StatelessWidget {
  final Staff? staff;

  final Event? event;

  const DashboardHeader({
    super.key,
    this.staff,
    this.event,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,

      padding:
          const EdgeInsets.all(
        20,
      ),

      decoration: BoxDecoration(
        borderRadius:
            BorderRadius.circular(
                12),

        border: Border.all(
          color:
              const Color(
            0xffE5E7EB,
          ),
        ),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          Text(
            staff?.name ??
                "",
            style:
                const TextStyle(
              fontSize: 24,
              fontWeight:
                  FontWeight.w700,
            ),
          ),

          const SizedBox(
            height: 8,
          ),

          Text(
            staff?.role ??
                "",
            style:
                const TextStyle(
              color:
                  Colors.grey,
            ),
          ),

          if (staff?.station !=
              null) ...[

            const SizedBox(
              height: 8,
            ),

            Text(
              "Station ${staff!.station}",
              style:
                  const TextStyle(
                fontWeight:
                    FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}