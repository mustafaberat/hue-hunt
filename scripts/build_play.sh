#!/bin/bash
# Google Play AAB (vX.Y.Z+CODE). İmza: android/key.properties
set -e
cd "$(dirname "$0")/.."
if [ ! -f android/key.properties ]; then
  echo "android/key.properties yok. Upload keystore olmadan Play AAB imzalanamaz."
  exit 1
fi
# AAB ve APK aynı anda; biri bitene kadar diğeri beklemesin.
flutter build appbundle --release --obfuscate --split-debug-info=build/symbols &
aab_pid=$!
flutter build apk --release --target-platform android-arm,android-arm64 &
apk_pid=$!

aab_ec=0
apk_ec=0
wait "$aab_pid" || aab_ec=$?
wait "$apk_pid" || apk_ec=$?
if [ "$aab_ec" -ne 0 ] || [ "$apk_ec" -ne 0 ]; then
  echo "AAB exit ${aab_ec}, APK exit ${apk_ec}" >&2
  exit 1
fi

ver=$(awk '/^version:/{print $2; exit}' pubspec.yaml | cut -d+ -f1)
mkdir -p play
cp build/app/outputs/bundle/release/app-release.aab "play/hue-hunt-${ver}.aab"
cp build/app/outputs/flutter-apk/app-release.apk "play/hue-hunt-${ver}.apk"
echo "AAB: play/hue-hunt-${ver}.aab"
echo "APK: play/hue-hunt-${ver}.apk"
open play
