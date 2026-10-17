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

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

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

    try {
      await widget.controller.start();

      if (!mounted || _disposed) return;

      setState(() {
        starting = false;
        cameraError = null;
      });
    } catch (error) {
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
    if (locked || !widget.enabled) return;

    if (capture.barcodes.isEmpty) return;

    final value = capture.barcodes.first.rawValue;

    if (value == null || value.trim().isEmpty) return;

    locked = true;
    widget.onScanned(value.trim());
  }

  @override
  void dispose() {
    _disposed = true;
    WidgetsBinding.instance.removeObserver(this);
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
                // Camera preview is rendered directly in the available area.
                MobileScanner(
                  controller: widget.controller,
                  onDetect: _handleDetection,
                  errorBuilder: (context, error) {
                    return _buildCameraError(
                      error.toString(),
                    );
                  },
                ),

                // Show loading only while starting, not after startup.
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
                onPressed: starting
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