#!/usr/bin/env bash
# Build the NostrRide Android APK. Needs JDK 17, the Android SDK 34 and Node 22.23.4+.
#   ./setup.sh                 # main branch of trevthom/nostr-ride
#   NR_REF=v1.2.3 ./setup.sh   # a tag or commit
#   NR_REPO=<url> ./setup.sh   # a fork
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
APP_REPO="${NR_REPO:-https://github.com/trevthom/nostr-ride.git}"
APP_REF="${NR_REF:-main}"
APP="$HERE/app"

command -v node >/dev/null 2>&1 || { echo "Node 22.23.4 or newer is required: https://nodejs.org"; exit 1; }
command -v java >/dev/null 2>&1 || { echo "JDK 17 is required (Gradle 8.2 does not run on Java 21)."; exit 1; }

if [ -z "${ANDROID_HOME:-}" ]; then
  for d in "$HOME/Library/Android/sdk" "$HOME/Android/Sdk" "/usr/local/share/android-sdk"; do
    if [ -d "$d" ]; then export ANDROID_HOME="$d"; break; fi
  done
fi
[ -n "${ANDROID_HOME:-}" ] || { echo "Set ANDROID_HOME to your Android SDK (or install Android Studio)."; exit 1; }
export ANDROID_SDK_ROOT="$ANDROID_HOME"

if [ ! -d "$APP/.git" ]; then
  echo "==> Cloning $APP_REPO ($APP_REF)"
  git clone --depth 1 --branch "$APP_REF" "$APP_REPO" "$APP"
else
  echo "==> Reusing $APP"
fi

echo "==> Building the web app"
( cd "$APP" && npm ci && npm run build )

echo "==> Installing the Android shell"
mkdir -p "$APP/native"
cp -R "$HERE/native/." "$APP/native/"

( cd "$APP/native" && npm install && npx cap copy android )

AND="$APP/native/android"
[ -f "$AND/local.properties" ] || echo "sdk.dir=$ANDROID_HOME" > "$AND/local.properties"
chmod +x "$AND/gradlew"

echo "==> Gradle"
( cd "$AND" && ./gradlew assembleDebug )

APK="$AND/app/build/outputs/apk/debug/app-debug.apk"
cp "$APK" "$HERE/nostr-ride-android-debug.apk"
echo
echo "Done: $HERE/nostr-ride-android-debug.apk"
echo "Install it with: adb install -r nostr-ride-android-debug.apk"
