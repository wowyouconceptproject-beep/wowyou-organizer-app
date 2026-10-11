import "dart:async";

import "package:flutter/material.dart";
import "package:mobile_scanner/mobile_scanner.dart";

import "../models/capacity_update.dart";
import "../models/scan_result.dart";

import "../services/nfc_service.dart";
import "../services/pass_service.dart";
import "../services/socket_service.dart";

class ScanProvider extends ChangeNotifier {
  final PassService _passService = PassService();
  final SocketService _socket = SocketService.instance;
  final NfcService _nfc = NfcService();

  /*
  |--------------------------------------------------------------------------
  | Camera
  |--------------------------------------------------------------------------
  */

  final MobileScannerController camera = MobileScannerController();

  bool scanning = false;
  bool busy = false;
  bool torchOn = false;

  String? error;
  ScanResult? result;
  CapacityUpdate? capacity;

  Timer? _clearTimer;

  /*
  |--------------------------------------------------------------------------
  | Staff
  |--------------------------------------------------------------------------
  */

  String? _staffId;

  String? get staffId => _staffId;

  /*
  |--------------------------------------------------------------------------
  | Configure Staff
  |--------------------------------------------------------------------------
  |
  | The backend requires the EventStaff ID for every check-in.
  |
  */

  void setStaffId(String id) {
    final normalizedId = id.trim();

    if (normalizedId.isEmpty) {
      return;
    }

    if (_staffId == normalizedId) {
      return;
    }

    _staffId = normalizedId;
    notifyListeners();
  }

  void clearStaffId() {
    if (_staffId == null) {
      return;
    }

    _staffId = null;
    notifyListeners();
  }

  /*
  |--------------------------------------------------------------------------
  | Socket
  |--------------------------------------------------------------------------
  */

  Future<void> connectSocket(String eventId) async {
    final normalizedEventId = eventId.trim();

    if (normalizedEventId.isEmpty) {
      return;
    }

    _socket.connect();

    await _socket.joinEvent(normalizedEventId);

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
      onDiscovered: (token) async {
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

  Future<void> scanQr(String token) async {
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

  Future<void> scanNfc(String token) async {
    await onTokenDetected(
      token,
      scanType: "NFC",
    );
  }

  /*
  |--------------------------------------------------------------------------
  | Manual
  |--------------------------------------------------------------------------
  */

  Future<void> scanManual(String token) async {
    await onTokenDetected(
      token,
      scanType: "MANUAL",
    );
  }

  /*
  |--------------------------------------------------------------------------
  | Unified Token Entry
  |--------------------------------------------------------------------------
  */

  Future<void> onTokenDetected(
    String token, {
    required String scanType,
    String? station,
    String? deviceId,
  }) async {
    final normalizedToken = token.trim();

    /*
    |--------------------------------------------------------------------------
    | Empty Token
    |--------------------------------------------------------------------------
    */

    if (normalizedToken.isEmpty) {
      error = "Invalid pass token.";
      result = null;

      notifyListeners();

      return;
    }

    /*
    |--------------------------------------------------------------------------
    | Prevent Duplicate Scans
    |--------------------------------------------------------------------------
    */

    if (busy) {
      return;
    }

    /*
    |--------------------------------------------------------------------------
    | Staff Validation
    |--------------------------------------------------------------------------
    */

    final currentStaffId = _staffId;

    if (currentStaffId == null || currentStaffId.isEmpty) {
      error = "Staff session is not available.";
      result = null;

      notifyListeners();

      return;
    }

    await _performCheckIn(
      normalizedToken,
      scanType: scanType,
      staffId: currentStaffId,
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
    required String staffId,
    String? station,
    String? deviceId,
  }) async {
    busy = true;
    scanning = true;
    error = null;
    result = null;

    _clearTimer?.cancel();
    _clearTimer = null;

    notifyListeners();

    try {
      /*
      |--------------------------------------------------------------------------
      | Backend Check-In
      |--------------------------------------------------------------------------
      */

      final response = await _passService.checkIn(
        token,
        scanType: scanType,
        staffId: staffId,
        station: station,
        deviceId: deviceId,
      );

      /*
      |--------------------------------------------------------------------------
      | Parse Result
      |--------------------------------------------------------------------------
      */

      result = ScanResult.fromJson(response);

      /*
      |--------------------------------------------------------------------------
      | Capacity
      |--------------------------------------------------------------------------
      */

      final responseCapacity = response["capacity"];

      if (responseCapacity is Map) {
        capacity = CapacityUpdate.fromJson(
          Map<String, dynamic>.from(responseCapacity),
        );
      }

      /*
      |--------------------------------------------------------------------------
      | Successful Response
      |--------------------------------------------------------------------------
      |
      | This includes:
      |
      | • New successful check-in
      | • Already checked-in attendee
      |
      | Both are valid backend responses.
      |
      */

      error = null;
    } catch (e) {
      /*
      |--------------------------------------------------------------------------
      | Error
      |--------------------------------------------------------------------------
      */

      result = null;
      error = _cleanErrorMessage(e);
    }

    busy = false;
    scanning = false;

    notifyListeners();

    /*
    |--------------------------------------------------------------------------
    | Auto Clear
    |--------------------------------------------------------------------------
    |
    | Keep the result visible long enough for the scanner UI to show it.
    |
    | Do not await this delay here. ScanScreen needs immediate access
    | to result/error after scanQr(), scanNfc(), or scanManual().
    |
    */

    _scheduleClear();
  }

  /*
  |--------------------------------------------------------------------------
  | Error Message
  |--------------------------------------------------------------------------
  */

  String _cleanErrorMessage(Object error) {
    return error
        .toString()
        .replaceFirst("Exception: ", "")
        .trim();
  }

  /*
  |--------------------------------------------------------------------------
  | Schedule Clear
  |--------------------------------------------------------------------------
  */

  void _scheduleClear() {
    _clearTimer?.cancel();

    _clearTimer = Timer(
      const Duration(seconds: 3),
      () {
        clear();
      },
    );
  }

  /*
  |--------------------------------------------------------------------------
  | Reset
  |--------------------------------------------------------------------------
  */

  void clear() {
    _clearTimer?.cancel();
    _clearTimer = null;

    result = null;
    error = null;

    busy = false;
    scanning = false;

    notifyListeners();
  }

  /*
  |--------------------------------------------------------------------------
  | Reset Scan Only
  |--------------------------------------------------------------------------
  */

  void clearResult() {
    _clearTimer?.cancel();
    _clearTimer = null;

    result = null;
    error = null;

    notifyListeners();
  }

  /*
  |--------------------------------------------------------------------------
  | Dispose
  |--------------------------------------------------------------------------
  */

  @override
  void dispose() {
    _clearTimer?.cancel();

    stopNfcListener();
    disconnectSocket();

    camera.dispose();

    super.dispose();
  }
}