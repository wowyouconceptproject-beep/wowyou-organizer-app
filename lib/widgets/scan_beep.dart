import "package:flutter/services.dart";

class ScanBeep {
  static Future<void>
      success() async {
    await SystemSound.play(
      SystemSoundType.click,
    );
  }

  static Future<void>
      error() async {
    await SystemSound.play(
      SystemSoundType.alert,
    );
  }
}