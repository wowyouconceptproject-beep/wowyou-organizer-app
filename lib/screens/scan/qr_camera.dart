
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

class _QRCameraState extends State<QRCamera> {
  bool locked = false;
  bool starting = true;
  bool cameraReady = false;
  String? cameraError;

  bool _disposed = false;
  bool _startingCamera = false;

  @override
  void initState() {
    super.initState();

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
    }

    if (oldWidget.controller != widget.controller) {
      cameraReady = false;
      cameraError = null;
      starting = true;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          unawaited(_startCamera());
        }
      });
    }
  }

  Future<void> _startCamera() async {
    if (_disposed || _startingCamera) return;

    _startingCamera = true;

    if (mounted) {
      setState(() {
        starting = true;
        cameraError = null;
      });
    }

    try {
      await widget.controller.start();

      if (!mounted || _disposed) return;

      setState(() {
        cameraReady = true;
        starting = false;
        cameraError = null;
      });
    } catch (error) {
      if (!mounted || _disposed) return;

      setState(() {
        cameraReady = false;
        starting = false;
        cameraError = error.toString();
      });
    } finally {
      _startingCamera = false;
    }
  }

  void _handleDetection(BarcodeCapture capture) {
    if (locked || !widget.enabled || !cameraReady) {
      return;
    }

    if (capture.barcodes.isEmpty) {
      return;
    }

    final value = capture.barcodes.first.rawValue;

    if (value == null || value.trim().isEmpty) {
      return;
    }

    locked = true;
    widget.onScanned(value.trim());
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (cameraError == null)
            MobileScanner(
              controller: widget.controller,
              onDetect: _handleDetection,
              errorBuilder: (context, error) {
                return _buildCameraError(error.toString());
              },
            ),

          if (starting && cameraError == null)
            Container(
              color: const Color(0xff101010),
              alignment: Alignment.center,
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    color: Colors.white,
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Starting camera...",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

          if (cameraError != null)
            _buildCameraError(cameraError!),
        ],
      ),
    );
  }

  Widget _buildCameraError(String message) {
    return Container(
      color: const Color(0xff171717),
      padding: const EdgeInsets.all(24),
      alignment: Alignment.center,
      child: SingleChildScrollView(
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
              "Camera unavailable",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Check camera permission and make sure no other app "
              "is using the camera.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white70,
                height: 1.5,
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
              onPressed: starting ? null : _startCamera,
              icon: const Icon(Icons.refresh),
              label: const Text("Retry camera"),
            ),
          ],
        ),
      ),
    );
  }
}
