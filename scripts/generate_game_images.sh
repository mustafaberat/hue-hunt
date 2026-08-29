#!/bin/bash
# Play Console görselleri: play/gorseller/{ozellik-grafik,telefon,tablet,pc,chromebook}
set -e
cd "$(dirname "$0")/.."
flutter test tool/capture_play_shots.dart
echo "Görseller: play/gorseller"
open play/gorseller
