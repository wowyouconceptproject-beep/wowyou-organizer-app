
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

    debugPrint("[QR] Scanner initialized.");

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        unawaited(_startCamera());
      }
    });
  }

  @override
  void didUpdateWidget(covariant QRCamera oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.enabled != oldWidget.enabled) {
      locked = false;
      _lastLoggedValue = null;

      debugPrint("[QR] Scanner enabled: ${widget.enabled}");
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
      return;
    }

    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached ||
        state == AppLifecycleState.hidden) {
      unawaited(_stopCamera());
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

    debugPrint("[QR] Starting camera...");

    try {
      await widget.controller.start();

      if (!mounted || _disposed) return;

      setState(() {
        starting = false;
        cameraError = null;
      });

      debugPrint("[QR] Camera started.");
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

  Future<void> _stopCamera() async {
    if (_disposed) return;

    try {
      await widget.controller.stop();
      debugPrint("[QR] Camera stopped.");
    } catch (error) {
      debugPrint("[QR] CAMERA STOP ERROR: $error");
    }
  }

  void _handleDetection(BarcodeCapture capture) {
    if (!widget.enabled || locked || _disposed) {
      return;
    }

    for (final barcode in capture.barcodes) {
      if (barcode.format != BarcodeFormat.qrCode) {
        continue;
      }

      final value = barcode.rawValue;

      if (value == null || value.trim().isEmpty) {
        debugPrint(
          "[QR] QR detected, but its decoded value is empty.",
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

      locked = true;

      debugPrint(
        "[QR] Sending decoded QR token to ScanProvider.",
      );

      try {
        widget.onScanned(token);
      } catch (error, stackTrace) {
        locked = false;

        debugPrint("[QR] SCAN CALLBACK ERROR: $error");
        debugPrintStack(stackTrace: stackTrace);
      }

      return;
    }
  }

  @override
  void dispose() {
    _disposed = true;
    WidgetsBinding.instance.removeObserver(this);

    debugPrint("[QR] Scanner disposed.");

    // The parent owns and disposes the controller.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            controller: widget.controller,
            onDetect: _handleDetection,
            errorBuilder: (context, error) {
              debugPrint(
                "[QR] CAMERA PREVIEW ERROR: $error",
              );
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
          if (!starting &&
              cameraError == null &&
              widget.enabled)
            IgnorePointer(
              child: Center(
                child: Container(
                  width: 240,
                  height: 240,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.white,
                      width: 3,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          if (!widget.enabled &&
              cameraError == null &&
              !starting)
            const ColoredBox(
              color: Color(0x66000000),
              child: Center(
                child: Text(
                  "Scanner paused",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
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
                onPressed: _startingCamera
                    ? null
                    : () => unawaited(_startCamera()),
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
