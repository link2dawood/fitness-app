# Overall app audit — 2026-11-17

**Project:** `fitness_pro`  
**Scope:** Overall Flutter app review with explicit male and female profile paths, profile editing, Home/Training, Challenge, Body Focus, Search, workout detail/session entry, Report/History, Settings, onboarding, assets, and release metadata.  
**Verdict:** The core navigation and much of the profile-aware artwork work, but the female experience is not consistently applied across Home/Training, and Search advertises workout metadata that does not match the routines users open.

## Priority order

| Priority | Finding | User impact | Evidence |
| --- | --- | --- | --- |
| **P1** | Female artwork/profile context is lost in several Home/Training sections | Female users can see default/male or generic artwork after selecting a female profile; the experience is inconsistent within the same screen. | `lib/views/home/pages/training_page.dart:111`, `:483`, `:504`, `:555`; the existing `test/training_female_artwork_test.dart` expects profile gender on all Training tiles. |
| **P1** | Search Body Focus metadata is disconnected from playable routines | Users are told incorrect duration/exercise counts before starting. The documented audit found all 41 Butt & Leg, Chest, Back, and Shoulder rows mismatched. | `lib/views/search/body_focus_results_view.dart:31-318`; metadata is hard-coded while the destination resolves a separate `TrainingWorkout`. |
| **P2** | Search rows contain duplicate aliases with shared routine/progress IDs | Differently named workouts can open the same session and share progress, making the catalog feel duplicated or misleading. | `lib/views/search/body_focus_results_view.dart:436-472`; examples documented in `docs/REMAINING_SEARCH_BADGES_AUDIT_2026-11-02.md`. |
| **P2** | Four male/default onboarding goal assets are missing | Male/default onboarding silently falls back through `errorBuilder`; the intended goal artwork is never shown. | `lib/views/onboarding/steps/goal_step.dart:69-75`; missing: `assets/images/goal_lose_weight.png`, `goal_build_muscle.png`, `goal_keep_fit.png`, `goal_endurance.png`. |
| **P2** | “Other” gender is saved but treated as the male catalog/artwork path | A profile value offered in Settings does not receive a neutral or explicitly supported experience. | `lib/data/models/user_profile.dart:1-4`; `lib/data/models/training_challenges.dart` selects female only when `gender == Gender.female`, and `challengePosterArtwork` treats non-female as the default/male path. |
| **P3** | Displayed app version is stale and contradicts package metadata | Support/build identification can be wrong. | `pubspec.yaml:19` is `1.0.0+1`; `lib/views/home/pages/settings_page.dart:259` displays `1.7.91`. |

## Profile-path results

### Male profile

- Onboarding exposes the male profile and the male avatar asset.
- Male/default challenge cards use the normal catalog and male/default poster logic.
- Search Body Focus has the expected non-female badge artwork.
- The main remaining male-facing issue is catalog trust: hard-coded Search metadata and missing default goal assets.

### Female profile

- Female Body Focus badge artwork, Body Focus rows, Search results, workout detail overrides, challenge catalog, and challenge poster assets are explicitly wired and covered by tests such as `test/search_body_focus_gender_artwork_test.dart`, `test/body_focus_female_artwork_test.dart`, and `test/training_female_artwork_test.dart`.
- The Home/Training page is incomplete: `_routines()` does not pass `gender`, the Recommended photo uses `recommended.first.image` directly, and the Just For You/Popular Goals routines use the same non-profile-aware path. This creates a visible split where Body Focus can be female-specific but adjacent sections are not.
- The female challenge catalog is intentionally separate and contains ten female workout IDs. No missing female poster files were found in the inspected mappings.

## Detailed findings and fixes

### P1 — Propagate profile gender through all Home/Training cards

`TrainingPage` receives `context.read<HomeViewModel>().profile`, but `_routines()` only passes `workout`, `largeThumbnail`, and optional `imagePath`; it does not pass `gender`. The body-focus call supplies explicit female artwork, but the other `_routines()` calls at lines 504 and 555 do not. The Recommended card at line 483 uses the workout’s base `image` instead of `femaleSearchArtwork(workout)` for female profiles. The Stretch & Warm Up cards also use generic shared images.

**Fix:** Make the tile/card builders accept `Gender?`; for female profiles resolve every workout image through the same `femaleSearchArtwork`/female artwork policy used by Search. Add a widget test that checks Recommended, Just For You, Stretch & Warm Up, Popular Goals, Challenge, and detail entry for both male and female profiles.

### P1 — Derive Search metadata from the destination workout

`WorkoutEntry` stores independent `durationMins` and `exerciseCount` values, then `_resolveWorkout()` opens a catalog routine. This makes the list and detail disagree. The existing audit evidence records examples such as Leg Beginner **23 min / 23 exercises** opening a **5 min / 6 exercise** routine and Killer Chest Workout **29 min / 25 exercises** opening a **7 min / 10 exercise** routine.

**Fix:** Store only a stable workout ID and derive title, duration, count, difficulty, and progress key from the resolved `TrainingWorkout`; or make the catalog routine match the advertised editorial values. Missing IDs should show an unavailable state instead of silently substituting another workout.

### P2 — Remove or label Search aliases

Several distinct labels resolve to the same routine/progress key. Examples include Butt Blaster Challenge / Intense Leg Power Challenge, 10 Min Butt Workout / Shape and Tighten Butt, Rounder Booty Shaping / Booty Shaping & Butt Lifting, and multiple Chest pairs.

**Fix:** Give genuinely different products distinct IDs and routines. Otherwise keep one canonical row or label the second entry as an alias and avoid presenting duplicate progress.

### P2 — Restore or replace missing default goal assets

The four default goal paths are absent while female goal JPGs exist. The current fallback masks the failure, so this is not a crash, but it is a persistent visual defect and an avoidable failed asset lookup.

**Fix:** Add the four intended assets and declare them, or change the default path to an existing bundled asset. Add an asset-existence test for every onboarding goal and both gender branches.

### P2 — Define behavior for `Gender.other`

Settings allows Male, Female, and Other, but onboarding only offers Male/Female. Downstream selection is binary: only Female gets the female catalog; all other values follow the default/male path.

**Fix:** Either remove `Other` until a neutral catalog is available, or make it a deliberate neutral path with neutral artwork/content and tests. Do not silently map it to male.

### P3 — Use package/build metadata for the displayed version

Replace the hard-coded settings label with the installed package version/build number (or update it as part of release automation). Add a regression test against the package metadata source.

## Historical findings rechecked

The previous 2026-10-24 audit reported H1/H2 and M1–M9. The current source shows meaningful fixes for the most severe items: durable history reload/queueing is present in `training_history_repository.dart`, startup recovery UI exists in `startup_gate.dart`/`splash_view.dart`, plan-generation delays are cancellable, Training is wrapped in `DateRolloverBuilder`, and the old Report/Training recovery paths are present. Those items are not repeated as current defects here without a fresh failing reproduction.

## Validation limits

- Repository inspection and asset-path validation were completed on 2026-11-17.
- The checked asset scan found **186 referenced asset paths** and **4 missing paths**, all four being the default goal assets listed above.
- Existing profile-specific widget tests were inspected and used as expected behavior contracts.
- `flutter test` and `dart analyze lib test` were attempted, but the installed Flutter tool produced no output and did not complete in the available run window; therefore this report does not claim a fresh passing test count.
- No production code was changed during this audit.

## Recommended implementation order

1. Fix P1 gender propagation and add one end-to-end male/female Home/Training artwork contract test.
2. Replace Search’s duplicated metadata with model-derived metadata and make unresolved IDs fail visibly.
3. Decide the `Gender.other` product behavior.
4. Restore default goal assets and add asset integrity coverage.
5. Remove/label duplicate Search aliases.
6. Replace the hard-coded version and complete a real Windows/Android release smoke test.

## Follow-up implementation

The P1 Home/Training gender-propagation fix was implemented after this audit snapshot in `lib/views/home/pages/training_page.dart`, with male/female regression coverage added to `test/training_female_artwork_test.dart`. A fresh Flutter test run remains pending because the local Flutter tool stalled without output during verification.
