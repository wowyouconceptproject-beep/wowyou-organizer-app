import "package:flutter/material.dart";

class ScannerStatusBar
    extends StatelessWidget {
  final bool busy;

  final String? error;

  const ScannerStatusBar({
    super.key,
    required this.busy,
    this.error,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    String text;

    Color color;

    if (error != null) {
      text = error!;
      color = Colors.red;
    } else if (busy) {
      text = "Processing pass...";
      color = Colors.orange;
    } else {
      text = "Ready to scan";
      color = Colors.green;
    }

    return Container(
      width: double.infinity,

      padding:
          const EdgeInsets.symmetric(
        vertical: 16,
        horizontal: 20,
      ),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(
          12,
        ),

        border: Border.all(
          color: const Color(
            0xffe5e5e5,
          ),
        ),
      ),

      child: Row(
        children: [

          Container(
            width: 10,
            height: 10,

            decoration:
                BoxDecoration(
              color: color,
              shape:
                  BoxShape.circle,
            ),
          ),

          const SizedBox(
            width: 12,
          ),

          Expanded(
            child: Text(
              text,
              style:
                  const TextStyle(
                fontSize: 16,
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