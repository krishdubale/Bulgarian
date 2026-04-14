#!/usr/bin/env bash
set -euo pipefail

echo "[1/5] flutter pub get"
flutter pub get

echo "[2/5] format check"
dart format --set-exit-if-changed .

echo "[3/5] static analysis"
flutter analyze

echo "[4/5] unit tests"
flutter test

echo "[5/5] smoke boot test"
flutter test test/widget_test.dart

echo "All quality gates passed."

