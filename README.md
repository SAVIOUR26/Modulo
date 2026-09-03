# Modulo

**Designed by Saviour Najuna · Powered by Thirdsan**

Modulo listens live through the phone's microphone while someone sings or
plays, works out what key they're actually in, and tells a keyboardist
exactly what to set their transpose to — so they can keep playing the
same familiar chord shapes (F♯ by default) no matter what key the room
lands on.

This isn't note-by-note pitch detection ("you're singing a C right now").
It listens to several seconds of melody, builds a small histogram of
what's been sung, and scores that against all twelve possible major keys
to find the tonal center — the same way you'd start to recognise "oh,
that's in G" after hearing a phrase or two.

## What's in this repo

This is the **application source** — everything Dart/Flutter, fully
written and internally consistent. It does **not** yet contain the
generated Android platform folder (`android/`), because that's
environment-specific boilerplate best generated fresh by the actual
Flutter toolchain rather than hand-authored here. See "Handoff to Claude
Code" below for the exact steps to finish it.

```
lib/
  main.dart, app.dart          — entry point, root MaterialApp
  music/
    note.dart                  — pitch-class <-> note name <-> MIDI/frequency
    key_transpose.dart         — the transpose-chart math, generalised to any reference key
    chord_theory.dart          — builds the I–vii° diatonic chords for a major key
  audio/
    pitch_detector.dart        — autocorrelation fundamental-frequency estimator (pure Dart)
    key_estimator.dart         — rolling 8s pitch-class histogram scored against a
                                  Krumhansl–Kessler major-key profile
    pitch_sample.dart          — small data class used by the estimator
  state/
    listener_controller.dart   — owns the mic stream (via `record`), feeds it through
                                  pitch detection + key estimation, exposes results
    settings_controller.dart   — persists the chosen reference key (default F♯)
  theme/                       — dark "stage gear" palette (brass/ivory on near-black)
  screens/                     — HomeScreen (main readout), SettingsScreen (pick reference key)
  widgets/                     — BrandHeader, StatusBar, KeyReadout, TransposeReadout, ChordGrid

android_icon/                  — a complete adaptive app icon, as vector XML (see its own README)
.github/workflows/             — a starter CI workflow that builds a release APK
```

## Design notes worth knowing

- **Reference key is a setting, not a hardcode.** Saviour plays in F♯, so
  that's the default, but `KeyTranspose` and `ChordTheory` both take any
  pitch class — the settings screen lets any keyboardist pick their own
  comfortable key.
- **Chord names use pitch-class spelling (sharps only)**, not full
  key-signature spelling. F♯ major's vii° prints as `F°` rather than the
  stricter enharmonic `E♯°` — same pitch, simpler to read at a glance
  mid-song. Documented in `chord_theory.dart`.
- **Major keys only in v1.** A minor-key song will be matched to its
  closest major key, which can mislead. Worth flagging to users; a
  minor-profile pass is the natural v2 addition to `key_estimator.dart`.
- No external audio/DSP packages — the pitch detector and key estimator
  are hand-written, dependency-free Dart, easy to unit test and to reason
  about.

## Handoff to Claude Code (finishing the release build)

This project intentionally stops short of the generated Android
platform folder — that's best produced by the real Flutter toolchain
rather than hand-authored, since Gradle/AGP versions move fast. Claude
Code has both, so the remaining steps are:

1. **Generate the Android platform folder in a scratch project**, then
   copy it in, rather than running `flutter create .` directly on top of
   this repo (which risks overwriting the hand-written `lib/`):
   ```bash
   flutter create --platforms=android --org com.thirdsan --project-name modulo /tmp/modulo_scratch
   cp -r /tmp/modulo_scratch/android ./android
   rm -rf /tmp/modulo_scratch
   ```

2. **Set the minimum SDK to 26** in `android/app/build.gradle` (needed
   because the provided app icon is adaptive-only, no legacy raster
   fallback) and confirm `compileSdk`/`targetSdk` are current.

3. **Add the microphone permission** to
   `android/app/src/main/AndroidManifest.xml`, just above the
   `<application>` tag:
   ```xml
   <uses-permission android:name="android.permission.RECORD_AUDIO" />
   ```

4. **Drop in the app icon** — copy the four files from `android_icon/`
   to the paths listed in `android_icon/README.md`, and delete the
   default `mipmap-*dpi/ic_launcher*.png` files Flutter generated.

5. **Set the app display name** to "Modulo" in the same
   `AndroidManifest.xml` (`android:label="Modulo"`).

6. Install dependencies and build:
   ```bash
   flutter pub get
   flutter build apk --release
   ```
   For a Play Store–ready bundle instead: `flutter build appbundle --release`,
   after setting up a signing keystore per Flutter's official Android
   deployment guide (`key.properties` + `android/app/build.gradle`
   signing config — not included here since it's per-developer secret
   material).

7. Push to GitHub and, if desired, let `.github/workflows/build-android.yml`
   build the APK on every push to `main` — bump the pinned
   `flutter-version` in that file to whatever's current stable first.

## Known limits (worth testing before relying on it live)

- Major keys only, not minor.
- Works best on a clear solo vocal/melodic line — a full band mix with
  drums will confuse the pitch detector.
- No chord-progression tracking yet (following "1→4→1→5" live is a
  natural v2 feature, once key detection is proven reliable on-stage).
