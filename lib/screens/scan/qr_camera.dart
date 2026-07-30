import "package:flutter/material.dart";

import "package:mobile_scanner/mobile_scanner.dart";

class QRCamera extends StatefulWidget {
  final MobileScannerController
      controller;

  final bool enabled;

  final ValueChanged<String>
      onScanned;

  const QRCamera({
    super.key,
    required this.controller,
    required this.enabled,
    required this.onScanned,
  });

  @override
  State<QRCamera> createState() =>
      _QRCameraState();
}

class _QRCameraState
    extends State<QRCamera> {
  bool locked = false;

  @override
  void didUpdateWidget(
    covariant QRCamera oldWidget,
  ) {
    super.didUpdateWidget(
      oldWidget,
    );

    if (widget.enabled &&
        !oldWidget.enabled) {
      locked = false;
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return ClipRRect(
      borderRadius:
          BorderRadius.circular(
        16,
      ),

      child: MobileScanner(
        controller:
            widget.controller,

        onDetect: (
          capture,
        ) {
          if (locked ||
              !widget.enabled) {
            return;
          }

          if (capture
              .barcodes
              .isEmpty) {
            return;
          }

          final value =
              capture
                  .barcodes
                  .first
                  .rawValue;

          if (value == null ||
              value.trim().isEmpty) {
            return;
          }

          locked = true;

          widget.onScanned(
            value.trim(),
          );
        },
      ),
    );
  }
}