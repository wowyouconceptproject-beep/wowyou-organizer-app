import "package:flutter/material.dart";

class CameraOverlay
    extends StatelessWidget {
  const CameraOverlay({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return IgnorePointer(
      child: Stack(
        children: [

          // Dark overlay
          Container(
            color: Colors.black45,
          ),

          // Transparent scan area
          Center(
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius:
                    BorderRadius.circular(
                  20,
                ),
              ),
            ),
          ),

          // White corners
          Center(
            child: SizedBox(
              width: 260,
              height: 260,
              child: Stack(
                children: [

                  _corner(
                    Alignment.topLeft,
                  ),

                  _corner(
                    Alignment.topRight,
                  ),

                  _corner(
                    Alignment.bottomLeft,
                  ),

                  _corner(
                    Alignment.bottomRight,
                  ),
                ],
              ),
            ),
          ),

          // Instruction
          Positioned(
            bottom: 48,
            left: 24,
            right: 24,
            child: Column(
              children: [

                const Text(
                  "Align the attendee QR code inside the frame",
                  textAlign:
                      TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),

                const SizedBox(
                  height: 8,
                ),

                Text(
                  "Scanning happens automatically.",
                  textAlign:
                      TextAlign.center,
                  style: TextStyle(
                    color: Colors.white
                        .withValues(alpha: 0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _corner(
    Alignment alignment,
  ) {
    return Align(
      alignment: alignment,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          border: Border(
            top: alignment ==
                        Alignment.topLeft ||
                    alignment ==
                        Alignment.topRight
                ? const BorderSide(
                    color:
                        Colors.white,
                    width: 5,
                  )
                : BorderSide.none,

            bottom: alignment ==
                        Alignment.bottomLeft ||
                    alignment ==
                        Alignment.bottomRight
                ? const BorderSide(
                    color:
                        Colors.white,
                    width: 5,
                  )
                : BorderSide.none,

            left: alignment ==
                        Alignment.topLeft ||
                    alignment ==
                        Alignment.bottomLeft
                ? const BorderSide(
                    color:
                        Colors.white,
                    width: 5,
                  )
                : BorderSide.none,

            right: alignment ==
                        Alignment.topRight ||
                    alignment ==
                        Alignment.bottomRight
                ? const BorderSide(
                    color:
                        Colors.white,
                    width: 5,
                  )
                : BorderSide.none,
          ),
        ),
      ),
    );
  }
}