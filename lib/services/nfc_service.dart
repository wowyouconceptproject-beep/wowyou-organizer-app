import "dart:async";
import "dart:convert";

import "package:nfc_manager/nfc_manager.dart";

typedef NfcDiscoveredCallback =
    Future<void> Function(
  String token,
);

class NfcService {
  bool _running = false;

  bool get isRunning =>
      _running;

  /*
  |--------------------------------------------------------------------------
  | Availability
  |--------------------------------------------------------------------------
  */

  Future<bool> isAvailable() {
    return NfcManager.instance
        .isAvailable();
  }

  /*
  |--------------------------------------------------------------------------
  | Start Listening
  |--------------------------------------------------------------------------
  */

  Future<void> startListening({
    required
        NfcDiscoveredCallback
            onDiscovered,
  }) async {
    if (_running) {
      return;
    }

    final available =
        await isAvailable();

    if (!available) {
      throw Exception(
        "NFC is not available on this device.",
      );
    }

    _running = true;

    await NfcManager.instance
        .startSession(
      onDiscovered:
          (NfcTag tag) async {
        try {
          final token =
              _extractToken(
            tag,
          );

          if (token != null &&
              token.isNotEmpty) {
            await onDiscovered(
              token,
            );
          }
        } finally {
          await stopListening();
        }
      },
    );
  }

  /*
  |--------------------------------------------------------------------------
  | Stop Listening
  |--------------------------------------------------------------------------
  */

  Future<void> stopListening() async {
    if (!_running) {
      return;
    }

    try {
      await NfcManager.instance
          .stopSession();
    } finally {
      _running = false;
    }
  }

  /*
  |--------------------------------------------------------------------------
  | Extract Token
  |--------------------------------------------------------------------------
  */

  String? _extractToken(
    NfcTag tag,
  ) {
    /*
    |--------------------------------------------------------------------------
    | NDEF Message
    |--------------------------------------------------------------------------
    */

    final ndef =
        Ndef.from(tag);

    if (ndef != null) {
      final message =
          ndef.cachedMessage;

      if (message != null &&
          message.records
              .isNotEmpty) {
        final payload =
            message
                .records
                .first
                .payload;

        if (payload.length <= 3) {
          return null;
        }

        try {
          final languageLength =
              payload.first;

          return utf8.decode(
            payload.sublist(
              languageLength + 1,
            ),
          );
        } catch (_) {
          return null;
        }
      }
    }

    /*
    |--------------------------------------------------------------------------
    | Fallback
    |--------------------------------------------------------------------------
    */

    try {
      return jsonEncode(
        tag.data,
      );
    } catch (_) {
      return null;
    }
  }
}