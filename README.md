# NostrRide for Android

The Android shell for **NostrRide** — one app with two faces, **Ride** (a passenger)
and **Drive** (a driver). It wraps the web app in a Capacitor shell so Android lets
it keep the location, and the ride's payment loop, running with the screen off
(a foreground service with a notification).

## Where the real files are

This repo is the **build** side. The Gradle project, the manifest, the icons and the
background-location code live next to the web app so the two shells cannot drift
apart:

> `trevthom/nostr-ride` → **`native/android`**, documented in its `native/README.md`

`setup.sh` checks the app out, builds it, installs that shell and assembles the APK.
Nothing committed here is a copy of it.

## Requirements

- **JDK 17** (`java -version`). Gradle 8.2 (the wrapper in the project) does not run
  on Java 21.
- **Android SDK 34** plus build-tools 34: install Android Studio, or the command-line
  tools. Set `ANDROID_HOME` (the script also looks at `~/Library/Android/sdk` and
  `~/Android/Sdk`).
- **Node 22.23.4 or newer** (`node -v`)
- The debug APK is signed with the debug key, so any phone can install it. A Play
  Store build needs your own keystore (below).

## Build it

```bash
bash setup.sh
```

(Or `chmod +x setup.sh` once and run `./setup.sh`.)

That clones `trevthom/nostr-ride` into `app/` (reusing it if it is already there),
runs `npm ci && npm run build`, copies this repo's shell settings in, installs
Capacitor, copies the build into the Gradle project, and runs
`./gradlew assembleDebug`. The APK is copied here as
`nostr-ride-android-debug.apk`.

Pin a different commit with `NR_REF=<tag> bash setup.sh`; use a fork with
`NR_REPO=<git url> bash setup.sh`.

After changing the web app: `cd app && npm run build && cd native && npx cap copy android`,
then `cd android && ./gradlew assembleDebug`. The shell **embeds** the build — it
never loads the site from a server, because the page holds keys and money.

## Install it

```bash
adb install -r nostr-ride-android-debug.apk
```

Or copy the APK to the phone and open it (allow installing from unknown sources).

## What the shell asks for

The manifest requests `ACCESS_FINE_LOCATION`, `ACCESS_BACKGROUND_LOCATION`,
`FOREGROUND_SERVICE`, `FOREGROUND_SERVICE_LOCATION` and `POST_NOTIFICATIONS`.

- **Drive face:** a foreground service with a "Driving with NostrRide" notification
  keeps sharing the car's position with the rider with the screen off.
- **Ride face:** while a ride runs, the same mechanism keeps the page alive so the
  ticks keep being paid with the phone in a pocket. The page still holds the wallet;
  no key or coin is handed to native code.

Android 10+ asks for background location separately. Declining is not fatal: without
it the app works in the foreground, and unpaid ticks are paid when it next wakes.

## Release build

A keystore is a secret you keep: never commit it, never paste it anywhere.

```bash
keytool -genkey -v -keystore ~/nostrride.keystore -alias nostrride \
  -keyalg RSA -keysize 2048 -validity 10000
```

Wire it into `android/app/build.gradle` on your machine (or pass it in through
`~/.gradle/gradle.properties`, which is outside this repo), then:

```bash
cd app/native/android && ./gradlew bundleRelease
```

## Google Play notes

- **Background location** needs a written justification in the Play Console. Use the
  true one: the driver's position is shared with their rider during a trip, and the
  ride is measured on the rider's own phone.
- **Data safety** asks what the app collects. It has no server of its own: the app
  talks to public Nostr relays and an ecash mint that the person chooses, and the
  12-word ecash phrase never leaves the device.
- **App signing**: use Play App Signing, and keep the upload key safe.

## Not verified here

Nothing in this repo has been run on a phone: the APK builds and installs, but real
background behaviour — battery, Doze, the location prompt, a locked screen — must be
tried on a device.
