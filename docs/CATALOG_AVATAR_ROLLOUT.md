# Realistic exercise avatar rollout — 7 November 2026

Every exercise in the 392-entry catalog now has realistic animation frames. Before the rollout, 104 catalog entries had realistic frames and 288 used the illustrated fallback.

Added 214 movement sequences in five stages: core (34), upper body (62), lower body (54), full body/cardio (36), and stretching (28). The remaining 74 entries use existing or new equivalent movement sequences, including mirrored sides and rep/timed variants. New original artwork is stored as `assets/images/challenge_avatars/atlas_48.png` through `atlas_103.png`; sheet 103 corrects four poses after visual review. [The artwork manifest](CATALOG_AVATAR_ARTWORK_MANIFEST.json) records every saved asset and its built-in imagegen prompt. The Belly Fat Burn demonstrator in sheet 1 was used as the style reference.

The existing shared exercise renderer serves workout lists, exercise details, sessions, search exercise pickers, and editors. The new sheets contain four key poses per movement; the original eight-frame and video-derived animations retain their existing playback. Loading stays still and playback begins when the image is ready. Reduced motion, pause/resume and retry remain supported.

The custom workout card still uses the original illustrated avatar. Neither `custom_workout_page.dart` nor `exercise_avatar.dart` was changed by this rollout. Exercise names, targets, plans, and stored progress were preserved.

Validation: visually reviewed the staged renders, passed 62 targeted tests, and rebuilt the Flutter assets and Android release APK. All 103 referenced sheets were checked against their source files inside both the app asset folder and the APK. The coverage test checks every exercise ID and frame range, and exercises the renderer with each sheet. These are generated pose loops; the rollout did not include a device performance benchmark or the deferred APK-size optimization.

Release APK: `build/app/outputs/flutter-apk/app-release.apk`.
