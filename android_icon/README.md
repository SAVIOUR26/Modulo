# Modulo app icon (vector, no raster files needed)

These four files are a complete Android **adaptive icon** built entirely
from vector paths — a stylised brass "♯" on the dark panel background,
matching the in-app palette. No PNG generation step required.

This relies on `minSdk 26` (Android 8+) so there is no legacy raster
fallback to provide — every device the app targets resolves the icon
through `mipmap-anydpi-v26`.

## Where each file goes

Copy after `flutter create` has generated the `android/` folder:

| This folder                     | Goes to                                                              |
|----------------------------------|-----------------------------------------------------------------------|
| `ic_launcher_background.xml`     | `android/app/src/main/res/drawable/ic_launcher_background.xml`        |
| `ic_launcher_foreground.xml`     | `android/app/src/main/res/drawable/ic_launcher_foreground.xml`        |
| `ic_launcher.xml`                | `android/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml`          |
| `ic_launcher_round.xml`          | `android/app/src/main/res/mipmap-anydpi-v26/ic_launcher_round.xml`    |

Delete the default `mipmap-*dpi/ic_launcher*.png` files Flutter
generates (they're only needed below API 26) and confirm
`android/app/build.gradle` has `minSdk = 26` (or higher).
