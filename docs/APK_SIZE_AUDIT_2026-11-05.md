# APK size audit — 5 November 2026

## Measured result

Inspected `build/app/outputs/flutter-apk/app-release.apk` as a ZIP archive, plus `pubspec.yaml`, Android build configuration, and source assets. Sizes below use decimal MB (1,000,000 bytes).

- Release APK: **358.03 MB** (341.44 MiB).
- Debug APK: **384.16 MB**.
- The duplicate APK paths under `outputs/apk` and `outputs/flutter-apk` are separate build outputs, not files bundled inside one APK.
- An earlier 160 MB APK was not available for a direct before/after comparison.

| Packaged category | MB |
|---|---:|
| Workout photos and covers | 210.82 |
| Exercise animation atlases and small reference documents | 44.33 |
| Three WAV music tracks | 31.47 |
| Other images: UI, body, reviews, profile avatars | 13.71 |
| ARM64 native libraries | 19.19 |
| ARM32 native libraries | 16.73 |
| x86_64 native libraries | 20.65 |
| Other code/resources | 0.91 |

Approximately **300.30 MB / 84%** of the APK is bundled media. PNG files alone account for **239.51 MB**. Image/audio entries inspected in this APK are stored without additional ZIP compression.

## Main cause of the increase

Recent original artwork groups in the source tree:

| Group | Images | MB |
|---|---:|---:|
| Beginner PNGs | 46 | 96.11 |
| Advanced PNGs | 15 | 31.21 |
| Intermediate PNGs | 6 | 12.15 |
| Duration PNGs | 4 | 7.93 |
| Reverted UI's retained cutout PNGs | 3 | 5.32 |
| Total | 74 | 152.72 |

These groups alone are about 77% of the reported 198 MB increase. This is strong evidence for the main cause, not an exact historical attribution without the old APK.

Many new workout photos are **1254 × 1254 RGB PNGs**, commonly around 2 MB each, even where the app displays a 56 logical-pixel thumbnail. Adding a new exercise definition is cheap; bundling its full-resolution photo is comparatively expensive.

`pubspec.yaml` includes whole asset directories. Files inside those directories can be bundled even when no Dart code references them. The three retained cutout files are present in the APK and have no current source references. They were restored to resolve a live hot-restart missing-file error; exclude them through an audited asset list or remove them only with a stopped session and a fresh build, rather than deleting files during hot restart again.

## Recommended sequence

1. **Optimize workout photos first.** Convert photographic PNGs to JPEG or WebP and create sizes appropriate to their largest actual display, commonly 256–512 pixels for thumbnail-only images and larger variants for full-card/detail photos. Update every explicit and dynamically constructed path. Keep unique photos; reduce encoded size rather than sacrificing variety. Preserve transparency where needed. Compare visual quality before replacing originals. Exact savings require a conversion trial and rebuilt APK.
2. **Compress music.** Replace the three WAV tracks with AAC/M4A or MP3, then update both workout settings and the challenge audio service. Confirm looping and playback. The current input total is 31.47 MB; savings depend on duration and chosen bitrate.
3. **Exclude unused assets.** Prefer an explicit maintained asset list or a separate nonbundled source-art directory. Review dynamic atlas/image paths before deciding that a file is unused. The three cutouts alone provide a confirmed 5.32 MB opportunity.
4. **Build per architecture for direct APK sharing.** `flutter build apk --release --split-per-abi`. The current universal APK includes three architectures. Removing the other two native-library groups from the ARM64 package would save approximately **37.38 MB**, suggesting roughly **321 MB** before asset optimization. This is an estimate, not a rebuilt result; ABI splitting does not remove the shared image library.
5. **Use an app bundle for Google Play.** `flutter build appbundle --release`. Play generates device-targeted APKs. It does not automatically resize Flutter's bundled photo assets or remove arbitrary unused Flutter assets.
6. **Optimize animation atlases separately.** They total 44.33 MB. Preserve frame grids, timing, fine outlines, and source-rectangle assumptions. Do not apply a thumbnail resizing rule blindly to sprite sheets. Consider tested encoding changes or optional downloaded exercise packs if offline access to everything is not required.
7. **Track size per release.** Generate `flutter build apk --release --analyze-size --target-platform=android-arm64`, inspect the analysis in Flutter DevTools, and compare like-for-like architecture/build modes. Set an asset-size budget for every new photo.

## APK size versus RAM

This audit measures the APK file, not running-process RAM or installed storage. A fully decoded 1254 × 1254 image can take approximately 6.3 MB at four bytes per pixel despite a smaller encoded file. Use decode sizing such as `cacheWidth`/`cacheHeight` appropriate to device pixel ratio for small images, lazy lists, and bounded preloading. Decode sizing helps RAM; it does not make the packaged PNG file smaller. Cache clearing and `flutter clean` do not solve oversized source assets.

## Sources

- Flutter size measurement: https://docs.flutter.dev/perf/app-size
- Flutter Android release / ABI splitting: https://docs.flutter.dev/deployment/android
- Android size reduction and image formats: https://developer.android.com/topic/performance/reduce-apk-size

No application code, assets, or build configuration were changed as part of this audit. Only this report was added.
