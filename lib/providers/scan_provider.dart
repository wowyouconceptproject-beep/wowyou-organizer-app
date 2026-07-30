import "dart:async";

import "package:flutter/material.dart";
import "package:mobile_scanner/mobile_scanner.dart";

import "../models/scan_result.dart";
import "../services/scan_service.dart";

class ScanProvider extends ChangeNotifier {
  final ScanService _service = ScanService();

  /// Camera controller
  final MobileScannerController camera =
      MobileScannerController();

  bool scanning = false;

  bool busy = false;

  bool torchOn = false;

  String? error;

  ScanResult? result;

  /*
  |--------------------------------------------------------------------------
  | Toggle Flashlight
  |--------------------------------------------------------------------------
  */

  Future<void> toggleTorch() async {
    await camera.toggleTorch();

    torchOn = !torchOn;

    notifyListeners();
  }

  /*
  |--------------------------------------------------------------------------
  | Scan QR
  |--------------------------------------------------------------------------
  */

  Future<void> scan(
    String qrToken,
  ) async {
    if (busy) {
      return;
    }

    busy = true;
    scanning = true;
    error = null;
    result = null;

    notifyListeners();

    try {
      result = await _service.scan(
        qrToken,
      );
    } catch (e) {
      error = e
          .toString()
          .replaceFirst(
            "Exception: ",
            "",
          );
    }

    notifyListeners();

    await Future.delayed(
      const Duration(
        seconds: 2,
      ),
    );

    clear();
  }

  /*
  |--------------------------------------------------------------------------
  | Reset
  |--------------------------------------------------------------------------
  */

  void clear() {
    busy = false;
    scanning = false;
    result = null;
    error = null;

    notifyListeners();
  }

  @override
  void dispose() {
    camera.dispose();
    super.dispose();
  }
}