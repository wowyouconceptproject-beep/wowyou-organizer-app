import "package:nfc_manager/nfc_manager.dart";

class NfcWriterService {
  /*
  |--------------------------------------------------------------------------
  | Availability
  |--------------------------------------------------------------------------
  */

  Future<bool> isAvailable() {
    return NfcManager.instance.isAvailable();
  }

  /*
  |--------------------------------------------------------------------------
  | Write Secure Pass
  |--------------------------------------------------------------------------
  */

  Future<void> writePassToken(
    String token,
  ) async {
    final available =
        await isAvailable();

    if (!available) {
      throw Exception(
        "NFC is unavailable.",
      );
    }

    await NfcManager.instance.startSession(
      onDiscovered:
          (NfcTag tag) async {
        try {
          final ndef =
              Ndef.from(tag);

          if (ndef == null) {
            throw Exception(
              "This NFC tag does not support NDEF.",
            );
          }

          if (!ndef.isWritable) {
            throw Exception(
              "This NFC tag is read-only.",
            );
          }

          final message =
              NdefMessage([
            NdefRecord.createText(
              token,
            ),
          ]);

          await ndef.write(
            message,
          );

          await NfcManager.instance
              .stopSession();
        } catch (e) {
          await NfcManager.instance
              .stopSession(
            errorMessage:
                e.toString(),
          );

          rethrow;
        }
      },
    );
  }
}