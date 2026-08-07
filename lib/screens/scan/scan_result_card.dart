import "package:flutter/material.dart";

import "../../models/scan_result.dart";

class ScanResultCard extends StatelessWidget {
  final ScanResult? result;

  final String? error;

  const ScanResultCard({
    super.key,
    required this.result,
    required this.error,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    if (error != null) {
      return Align(
        alignment: Alignment.topCenter,
        child: Container(
          margin:
              const EdgeInsets.all(20),

          padding:
              const EdgeInsets.all(18),

          decoration:
              BoxDecoration(
            color:
                Colors.red.shade50,

            borderRadius:
                BorderRadius.circular(
              16,
            ),
          ),

          child: Row(
            children: [

              const Icon(
                Icons.error_outline,
                color: Colors.red,
              ),

              const SizedBox(
                width: 12,
              ),

              Expanded(
                child: Text(
                  error!,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (result == null) {
      return const SizedBox();
    }

    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        margin:
            const EdgeInsets.all(
          20,
        ),

        padding:
            const EdgeInsets.all(
          20,
        ),

        decoration:
            BoxDecoration(
          color:
              Colors.white,

          borderRadius:
              BorderRadius.circular(
            18,
          ),

          boxShadow: const [

            BoxShadow(
              color:
                  Colors.black12,

              blurRadius: 12,
            ),
          ],
        ),

        child: Column(
          mainAxisSize:
              MainAxisSize.min,

          crossAxisAlignment:
              CrossAxisAlignment
                  .start,

          children: [

            Row(
              children: [

                Icon(
                  result!
                          .alreadyCheckedIn
                      ? Icons.warning
                      : Icons
                          .check_circle,

                  color:
                      result!.alreadyCheckedIn
                          ? Colors.orange
                          : Colors.green,
                ),

                const SizedBox(
                  width: 12,
                ),

                Expanded(
                  child: Text(
                    result!
                            .alreadyCheckedIn
                        ? "Already Checked In"
                        : "Check In Successful",

                    style:
                        const TextStyle(
                      fontSize: 18,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 20,
            ),

            Text(
              result!
                  .attendee.name,
              style:
                  const TextStyle(
                fontSize: 22,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 6,
            ),

            Text(
              result!
                  .attendee.email,
            ),

            const Divider(
              height: 32,
            ),

            _item(
              "Ticket",
              result!
                  .ticket.name,
            ),

            _item(
              "Event",
              result!
                  .event.title,
            ),

            if (result!
                    .checkedInBy !=
                null)

              _item(
                "Station",
                result!
                    .checkedInBy!
                    .station,
              ),

            if (result!
                    .checkedInBy !=
                null)

              _item(
                "Checked In At",
                result!
                    .checkedInBy!
                    .checkedInAt,
              ),
          ],
        ),
      ),
    );
  }

  Widget _item(
    String label,
    String value,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 10,
      ),

      child: Row(
        children: [

          SizedBox(
            width: 100,
            child: Text(
              label,
              style:
                  const TextStyle(
                color: Colors.grey,
              ),
            ),
          ),

          Expanded(
            child: Text(
              value,
              style:
                  const TextStyle(
                fontWeight:
                    FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}