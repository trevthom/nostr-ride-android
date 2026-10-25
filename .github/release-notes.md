Installable debug build of the NostrRide Android shell. The build workflow fills in the
size and checksum below, so this page always describes the file you actually get.

- App id `app.nostrride`, label NostrRide. Embeds the web app build, so it opens without a
  network; signing in and riding still need internet.
- Includes the native heartbeat plugin that keeps a pocketed phone paying its ride ticks
  while a ride is under way, even when the phone is not moving.
- **Debug-signed.** Fine for testing on your own phone; not for handing to other people,
  and it will not upgrade over a release build (different signature - uninstall first).

**What this build fixes**

- The white screen after saving the key. Signing in can no longer hang on a relay that accepts
  but never answers, a failed key save no longer blocks the login, and a failure anywhere in the
  app now shows a "NostrRide stopped" screen with the reason and a Reload button instead of a
  blank page.
- Background location and the heartbeat clock now actually reach the shell. The web app shipped
  without Capacitor's runtime, so neither plugin was reachable and the phone found no location
  at all; both are wired in and checked against the bridge this APK injects.
- A saved key that is missing its public key is ignored instead of crashing the unlock screen.

These app fixes are not in `trevthom/nostr-ride` main yet, so this build applies them as a patch
(`nostr-ride-login-fix.patch`) before it builds. Uninstall the previous APK first: this one is
signed with a different debug key, so Android refuses to install it over the old app.

**Install**

1. Open this page on the phone and tap the APK under *Assets*.
2. Tap the finished download, then allow installs from the browser when Android asks.
3. Play Protect's "unknown developer" warning -> *More details* -> *Install anyway*.

`adb install -r nostr-ride-android-debug.apk` works too.

The shell lives in [trevthom/nostr-ride](https://github.com/trevthom/nostr-ride) under
`native/`; this repo only builds it. Steps and caveats: `native/README.md` there.

