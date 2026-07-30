import "package:flutter/material.dart";

import "../../models/scan_result.dart";

class ScanResultCard extends StatelessWidget {
  final ScanResult? result;

  final String? error;

  const ScanResultCard({
    super.key,
    this.result,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    if (result == null && error == null) {
      return const SizedBox.shrink();
    }

    final success = result != null;

    return AnimatedPositioned(
      duration: const Duration(
        milliseconds: 250,
      ),

      left: 16,
      right: 16,
      top: 24,

      child: Material(
        elevation: 8,
        borderRadius:
            BorderRadius.circular(
          16,
        ),

        child: Container(
          padding:
              const EdgeInsets.all(20),

          decoration: BoxDecoration(
            color: Colors.white,

            borderRadius:
                BorderRadius.circular(
              16,
            ),

            border: Border.all(
              color: success
                  ? Colors.green
                  : Colors.red,
              width: 2,
            ),
          ),

          child: success
              ? _successCard(
                  result!,
                )
              : _errorCard(
                  error!,
                ),
        ),
      ),
    );
  }

  Widget _successCard(
    ScanResult result,
  ) {
    return Column(
      mainAxisSize:
          MainAxisSize.min,

      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [

        const Text(
          "CHECK-IN SUCCESS",
          style: TextStyle(
            fontSize: 22,
            fontWeight:
                FontWeight.bold,
            color: Colors.green,
          ),
        ),

        const SizedBox(
          height: 20,
        ),

        Text(
          result.attendee.fullName,
          style:
              const TextStyle(
            fontSize: 26,
            fontWeight:
                FontWeight.bold,
          ),
        ),

        const SizedBox(
          height: 6,
        ),

        Text(
          result.ticket.name,
          style:
              const TextStyle(
            fontSize: 18,
            color:
                Colors.black54,
          ),
        ),

        const SizedBox(
          height: 24,
        ),

        Row(
          children: [

            Expanded(
              child:
                  _statCard(
                "Checked In",
                result.attendance
                    .toString(),
              ),
            ),

            const SizedBox(
              width: 12,
            ),

            Expanded(
              child:
                  _statCard(
                "Remaining",
                result.remaining
                    .toString(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _errorCard(
    String message,
  ) {
    return Column(
      mainAxisSize:
          MainAxisSize.min,

      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [

        const Text(
          "SCAN FAILED",
          style: TextStyle(
            fontSize: 22,
            fontWeight:
                FontWeight.bold,
            color: Colors.red,
          ),
        ),

        const SizedBox(
          height: 18,
        ),

        Text(
          message,
          style:
              const TextStyle(
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _statCard(
    String label,
    String value,
  ) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        vertical: 14,
      ),

      decoration: BoxDecoration(
        color:
            const Color(
          0xfff6f6f6,
        ),

        borderRadius:
            BorderRadius.circular(
          12,
        ),
      ),

      child: Column(
        children: [

          Text(
            value,
            style:
                const TextStyle(
              fontSize: 28,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(
            height: 6,
          ),

          Text(
            label,
            style:
                const TextStyle(
              color:
                  Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}