#!/bin/bash
set -e
cd "$(dirname "$0")/.."
lsof -ti:8080 | xargs kill -9 2>/dev/null || true
flutter run -d chrome --web-port=8080
