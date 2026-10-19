import "dart:async";

import "package:flutter/material.dart";
import "package:mobile_scanner/mobile_scanner.dart";

class QRCamera extends StatefulWidget {
  final MobileScannerController controller;
  final bool enabled;
  final ValueChanged<String> onScanned;

  const QRCamera({
    super.key,
    required this.controller,
    required this.enabled,
    required this.onScanned,
  });

  @override
  State<QRCamera> createState() => _QRCameraState();
}

class _QRCameraState extends State<QRCamera>
    with WidgetsBindingObserver {
  bool locked = false;
  bool starting = true;
  String? cameraError;

  bool _startingCamera = false;
  bool _disposed = false;
  String? _lastLoggedValue;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    debugPrint("[QR] Scanner widget initialized.");

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        unawaited(_startCamera());
      }
    });
  }

  @override
  void didUpdateWidget(covariant QRCamera oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.enabled && !oldWidget.enabled) {
      locked = false;
      _lastLoggedValue = null;
      debugPrint("[QR] Scanner re-enabled.");
    }

    if (oldWidget.controller != widget.controller) {
      starting = true;
      cameraError = null;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          unawaited(_startCamera());
        }
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    debugPrint("[QR] App lifecycle: $state");

    if (state == AppLifecycleState.resumed) {
      unawaited(_startCamera());
    }
  }

  Future<void> _startCamera() async {
    if (_disposed || _startingCamera || !mounted) {
      return;
    }

    _startingCamera = true;

    setState(() {
      starting = true;
      cameraError = null;
    });

    debugPrint("[QR] Starting camera.");

    try {
      await widget.controller.start();

      if (!mounted || _disposed) return;

      setState(() {
        starting = false;
        cameraError = null;
      });

      debugPrint("[QR] Camera started successfully.");
    } catch (error, stackTrace) {
      debugPrint("[QR] CAMERA START ERROR: $error");
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted || _disposed) return;

      setState(() {
        starting = false;
        cameraError = error.toString();
      });
    } finally {
      _startingCamera = false;
    }
  }

  void _handleDetection(BarcodeCapture capture) {
    if (!widget.enabled || locked) return;

    if (capture.barcodes.isEmpty) return;

    for (final barcode in capture.barcodes) {
      final value = barcode.rawValue;

      if (value == null || value.trim().isEmpty) {
        debugPrint(
          "[QR] Barcode detected, but rawValue is empty. "
          "Format: ${barcode.format}",
        );
        continue;
      }

      final token = value.trim();

      if (_lastLoggedValue != token) {
        _lastLoggedValue = token;

        debugPrint(
          "[QR] DECODE SUCCESS | "
          "format=${barcode.format} | "
          "length=${token.length} | "
          "looksLikeJwt=${token.split(".").length == 3}",
        );
      }

      if (barcode.format != BarcodeFormat.qrCode) {
        debugPrint("[QR] Ignoring non-QR barcode.");
        continue;
      }

      locked = true;

      debugPrint("[QR] Passing decoded QR token to ScanProvider.");

      widget.onScanned(token);
      return;
    }
  }

  @override
  void dispose() {
    _disposed = true;
    WidgetsBinding.instance.removeObserver(this);
    debugPrint("[QR] Scanner widget disposed.");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SizedBox(
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            child: Stack(
              fit: StackFit.expand,
              children: [
                MobileScanner(
                  controller: widget.controller,
                  onDetect: _handleDetection,
                  errorBuilder: (context, error) {
                    debugPrint("[QR] CAMERA PREVIEW ERROR: $error");
                    return _buildCameraError(error.toString());
                  },
                ),
                if (starting && cameraError == null)
                  const ColoredBox(
                    color: Colors.black,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    ),
                  ),
                if (cameraError != null)
                  _buildCameraError(cameraError!),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCameraError(String message) {
    return ColoredBox(
      color: const Color(0xff171717),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.no_photography_outlined,
                size: 54,
                color: Colors.white70,
              ),
              const SizedBox(height: 16),
              const Text(
                "Camera preview unavailable",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.orangeAccent,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed:
                    starting ? null : () => unawaited(_startCamera()),
                icon: const Icon(Icons.refresh),
                label: const Text("Retry camera"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}