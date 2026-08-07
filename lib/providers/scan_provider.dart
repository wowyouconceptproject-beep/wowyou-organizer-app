import "package:flutter/material.dart";
import "package:mobile_scanner/mobile_scanner.dart";

import "../models/capacity_update.dart";
import "../models/scan_result.dart";

import "../services/nfc_service.dart";
import "../services/pass_service.dart";
import "../services/socket_service.dart";

class ScanProvider extends ChangeNotifier {
  final PassService _passService =
      PassService();

  final SocketService _socket =
      SocketService.instance;

  final NfcService _nfc =
      NfcService();

  /*
  |--------------------------------------------------------------------------
  | Camera
  |--------------------------------------------------------------------------
  */

  final MobileScannerController camera =
      MobileScannerController();

  bool scanning = false;

  bool busy = false;

  bool torchOn = false;

  String? error;

  ScanResult? result;

  CapacityUpdate? capacity;

  /*
  |--------------------------------------------------------------------------
  | Socket
  |--------------------------------------------------------------------------
  */

  Future<void> connectSocket(
    String eventId,
  ) async {
    _socket.connect();

    await _socket.joinEvent(
      eventId,
    );

    _socket.onCapacityUpdated(
      (update) {
        capacity = update;
        notifyListeners();
      },
    );
  }

  void disconnectSocket() {
    _socket.clearListeners();

    _socket.disconnect();
  }

  /*
  |--------------------------------------------------------------------------
  | NFC
  |--------------------------------------------------------------------------
  */

  Future<void> startNfcListener() async {
    await _nfc.startListening(
      onDiscovered: (
        token,
      ) async {
        await onTokenDetected(
          token,
          scanType: "NFC",
        );
      },
    );
  }

  Future<void> stopNfcListener() async {
    await _nfc.stopListening();
  }

  /*
  |--------------------------------------------------------------------------
  | Torch
  |--------------------------------------------------------------------------
  */

  Future<void> toggleTorch() async {
    await camera.toggleTorch();

    torchOn = !torchOn;

    notifyListeners();
  }

  /*
  |--------------------------------------------------------------------------
  | QR
  |--------------------------------------------------------------------------
  */

  Future<void> scanQr(
    String token,
  ) async {
    await onTokenDetected(
      token,
      scanType: "QR",
    );
  }

  /*
  |--------------------------------------------------------------------------
  | NFC
  |--------------------------------------------------------------------------
  */

  Future<void> scanNfc(
    String token,
  ) async {
    await onTokenDetected(
      token,
      scanType: "NFC",
    );
  }

  /*
  |--------------------------------------------------------------------------
  | Unified Entry
  |--------------------------------------------------------------------------
  */

  Future<void> onTokenDetected(
    String token, {
    required String scanType,
    String? station,
    String? deviceId,
  }) async {
    if (busy) {
      return;
    }

    await _performCheckIn(
      token,
      scanType: scanType,
      station: station,
      deviceId: deviceId,
    );
  }

  /*
  |--------------------------------------------------------------------------
  | Check In
  |--------------------------------------------------------------------------
  */

  Future<void> _performCheckIn(
    String token, {
    required String scanType,
    String? station,
    String? deviceId,
  }) async {
    busy = true;

    scanning = true;

    error = null;

    result = null;

    notifyListeners();

    try {
      final response =
          await _passService.checkIn(
        token,
        scanType: scanType,
        station: station,
        deviceId: deviceId,
      );

      result =
          ScanResult.fromJson(
        response,
      );

      if (response["capacity"] !=
          null) {
        capacity =
            CapacityUpdate.fromJson(
          response["capacity"],
        );
      }
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
    stopNfcListener();

    disconnectSocket();

    camera.dispose();

    super.dispose();
  }
}