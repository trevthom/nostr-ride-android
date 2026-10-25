Installable debug build of the NostrRide Android shell. The build workflow fills in the
size and checksum below, so this page always describes the file you actually get.

- App id `app.nostrride`, label NostrRide. Embeds the web app build, so it opens without a
  network; signing in and riding still need internet.
- Includes the native heartbeat plugin that keeps a pocketed phone paying its ride ticks
  while a ride is under way, even when the phone is not moving.
- **Debug-signed.** Fine for testing on your own phone; not for handing to other people,
  and it will not upgrade over a release build (different signature - uninstall first).

**Install**

1. Open this page on the phone and tap the APK under *Assets*.
2. Tap the finished download, then allow installs from the browser when Android asks.
3. Play Protect's "unknown developer" warning -> *More details* -> *Install anyway*.

`adb install -r nostr-ride-android-debug.apk` works too.

The shell lives in [trevthom/nostr-ride](https://github.com/trevthom/nostr-ride) under
`native/`; this repo only builds it. Steps and caveats: `native/README.md` there.

