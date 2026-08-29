/// Kısa sistem sesi ve haptic. Asset yok; platform desteklemezse sessizce geçer.
library;

import 'package:flutter/services.dart';

class PlayerFeedback {
  static void play({
    required bool correct,
    required bool sound,
    required bool haptic,
  }) {
    if (sound) {
      SystemSound.play(
        correct ? SystemSoundType.click : SystemSoundType.alert,
      );
    }
    if (haptic) {
      try {
        if (correct) {
          HapticFeedback.lightImpact();
        } else {
          HapticFeedback.mediumImpact();
        }
      } catch (_) {
        // Web / masaüstü haptic API'si yoksa yut.
      }
    }
  }
}
