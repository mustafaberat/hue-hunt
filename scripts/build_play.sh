#!/bin/bash
# Google Play AAB (vX.Y.Z+CODE). İmza: android/key.properties
set -e
cd "$(dirname "$0")/.."
if [ ! -f android/key.properties ]; then
  echo "android/key.properties yok. Upload keystore olmadan Play AAB imzalanamaz."
  exit 1
fi
flutter build appbundle --release
echo "AAB: build/app/outputs/bundle/release/app-release.aab"
