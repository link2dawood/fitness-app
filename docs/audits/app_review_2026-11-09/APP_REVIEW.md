# Fitness Pro — app review

Reviewed 9 November 2026 (Asia/Karachi). Scope: the current working tree, including the recent uncommitted workout UI changes. This was a review only; application code was not modified during this review.

## Assessment

**The app compiles for web and has substantial automated coverage, but this checkout is not ready for a release sign-off.** The complete suite finished with **275 passed and 16 failed**. Some failures are outdated presentation expectations; others require investigation. Android release configuration, progress-save handling, and platform capability gaps also need attention.

The earlier 18 passing session tests covered a narrow subset. They did not establish whole-app correctness.

## Verification performed

| Check | Result |
|---|---|
| Entire `test/` suite | 275 passed, 16 failed; 2m20s |
| Repository-wide static analysis | 23 warnings/information diagnostics, in auxiliary build/audit/tool files |
| Web release compilation | Passed; `build/web` produced; compilation reported 82.8s |
| Code inventory | 113 Dart files under `lib`, 52 test files |
| Asset inventory | 267 files, 436.1 MiB uncompressed source assets |
| Isolated startup tests | 10 passed, 4 failed; same four timeout cases reproduced |
| Application and test source analysis (`lib test`) | Passed: no issues found |

Methods: source review across startup/onboarding, navigation, catalog/search/discovery, workout sessions and editing, reports/measurements/history, settings, persistence, premium UI, and Android/iOS integration; automated widget/unit tests; release compilation. Tests use mocks for several platform services.

**Limits:** no fresh end-to-end physical-device walkthrough, Android/iOS release installation, notification delivery/reboot test, real TTS/audio playback check, screen-reader audit, or measured runtime performance profile. Web compilation is not browser interaction verification. This is not a security penetration test or a medical/content-validity assessment. Asset size is not an APK/download-size measurement.

## Prioritized findings

### 1. P1 — Android release uses debug signing

**Evidence:** [android/app/build.gradle.kts:33](<C:/Users/M Zubair Akram/StudioProjects/fitness_pro/android/app/build.gradle.kts:33>) configures the release build with `signingConfigs.getByName("debug")`. The application ID is still `com.example.fitness_pro`.

**Impact:** the current configuration is a development release setup, not a finalized distribution identity/signing configuration.

**Action:** establish the intended application ID and release signing process; verify a signed release artifact on a device. Do not commit signing credentials.

### 2. P1 — Whole-app verification is red; startup recovery fails in isolation

**Evidence:** `review_tests.log` records 16 failures. Four startup-recovery cases time out in `pumpAndSettle`; an isolated rerun was performed to distinguish suite contention from a repeatable failure.

**Impact:** startup/recovery behavior cannot be signed off from the present automated evidence. A test timeout alone does **not** prove that users see a production startup hang.

**Action:** trace pending animation/timer and storage work in these tests, use bounded pumping where an animation legitimately remains active, and separately verify cold-start retry/reset behavior on a device. Reconcile the remaining UI assertions with the new startup flow without removing behavioral coverage.

### 3. P2 — Paused regular workouts expose actions that silently do nothing

**Evidence:** [lib/widgets/workout_session_view.dart:72](<C:/Users/M Zubair Akram/StudioProjects/fitness_pro/lib/widgets/workout_session_view.dart:72>) keeps Skip/Next enabled. [lib/views/workouts/training_workout_page.dart:529](<C:/Users/M Zubair Akram/StudioProjects/fitness_pro/lib/views/workouts/training_workout_page.dart:529>) returns immediately from `_next` when `paused` is true, including calls with `skip: true`. Challenge sessions use a different controller that can advance while paused.

**Reproduction:** start a regular workout, pause during rest, tap Skip. The button remains enabled but the phase does not change. The same guard affects Skip preparation/Next exercise.

**Action:** define one consistent policy: either disable those controls while paused or permit navigation while keeping the destination paused. Cover both regular and challenge sessions.

### 4. P2 — Exercise progress can appear saved when persistence failed

**Evidence:** [lib/views/workouts/training_workout_page.dart:218](<C:/Users/M Zubair Akram/StudioProjects/fitness_pro/lib/views/workouts/training_workout_page.dart:218>) changes `_completedIndices` before writing, ignores the boolean returned by `setStringList`, and swallows exceptions. `_markExerciseDone` at line 515 also ignores write failure.

**Impact:** a checkmark can show success yet disappear after relaunch; the user has no retry path. This finding concerns per-exercise progress, **not** the main completion-history repository, which checks durable writes and deduplicates completions.

**Action:** check write results, preserve or roll back the displayed state on failure, and expose a retry. Test storage returning false as well as throwing.

### 5. P2 — Reminder and screen-on features lack equivalent non-Android native support

**Evidence:** [lib/core/settings/reminder_repository.dart:93](<C:/Users/M Zubair Akram/StudioProjects/fitness_pro/lib/core/settings/reminder_repository.dart:93>) requires the `fitness_pro/general_settings` channel. Android implements it in `MainActivity.kt`; [ios/Runner/AppDelegate.swift:1](<C:/Users/M Zubair Akram/StudioProjects/fitness_pro/ios/Runner/AppDelegate.swift:1>) only registers generated plugins. `GeneralSettings.setKeepScreenOn` also requires this custom channel. Reminder/settings controls remain available without a capability check.

**Impact:** on platforms without the handler, the exposed action fails with a generic error rather than providing the feature. Real device behavior was not exercised in this review.

**Action:** implement the platform handlers or clearly gate unsupported actions and explain availability before the user configures them.

### 6. P2 — White challenge title has very low contrast on sky blue

**Evidence:** [lib/views/workouts/challenge_day_page.dart:343](<C:/Users/M Zubair Akram/StudioProjects/fitness_pro/lib/views/workouts/challenge_day_page.dart:343>) sets the pinned app-bar foreground to white and background to `#E0F2FE`.

**Reproduction:** open the reference Day 1 challenge and scroll until the header collapses. Its white title and overflow icon sit on the pale background; the separately dark-backed back button is not the affected element.

**Action:** use a dark title/icon color for this header and check both expanded and collapsed states. The regular workout header uses a different implementation.

### 7. P2 — New session tests depend on this Windows machine's font paths

**Evidence:** [test/video_session_flow_test.dart:15](<C:/Users/M Zubair Akram/StudioProjects/fitness_pro/test/video_session_flow_test.dart:15>) reads `C:/flutter/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf` and `C:/Windows/Fonts/arial.ttf` without an existence guard.

**Impact:** the test can fail before exercising any app behavior on Linux/macOS or a differently installed Windows SDK.

**Action:** use bundled test fonts or resolve assets/runtime paths portably; ensure screenshot-only dependencies do not prevent functional tests from running.

### 8. P2 — Workout settings error has a Retry button that does not retry

**Evidence:** [lib/views/workouts/training_workout_page.dart:598](<C:/Users/M Zubair Akram/StudioProjects/fitness_pro/lib/views/workouts/training_workout_page.dart:598>) catches a failed settings reload; the active view's `onRetry` at line 729 only clears `error`.

**Impact:** the error disappears while the session can continue using stale settings. This concerns settings changed during a running workout, not the initial settings-load retry.

**Action:** wire Retry to reload settings and report success/failure without restarting preparation or losing the timer.

### 9. P3 — Session UI migration left unreachable controls and inconsistent behavior

**Evidence:** [lib/views/workouts/challenge_session_page.dart:508](<C:/Users/M Zubair Akram/StudioProjects/fitness_pro/lib/views/workouts/challenge_session_page.dart:508>) returns the shared session screen for all active phases. The old mute button at line 599 is therefore only reachable in the completion screen. The old active-session rendering remains below it. The standard workout screen also retains the superseded active branch after its early return.

**Impact:** direct coaching mute disappeared from the active challenge toolbar, and there are two implementations to maintain. Settings/music sheets also pause challenge sessions without the same automatic-resume policy used by the new details/rest sheets.

**Action:** finish the shared-view migration, explicitly choose which controls belong on active/completion screens, and remove obsolete branches after tests cover the intended behavior.

### 10. P3 — Asset footprint and project documentation need release preparation

The source asset directory is **436.1 MiB**. Three WAV files alone total approximately **30 MiB**. This is a packaging/performance risk to measure, not proof of slow startup. Review image dimensions, animation-atlas memory use, and audio encodings; compare actual release/download size before and after optimization.

[README.md:1](<C:/Users/M Zubair Akram/StudioProjects/fitness_pro/README.md:1>) still describes a splash/onboarding starter archive and tells developers to replace `lib/` and delete/update an old counter test. Replace it with current setup, supported-platform, test, build, and release instructions. Repository-wide lint findings are concentrated in retained audit/build helper files; maintain these or configure analysis scope deliberately.

## Product completeness (not classified as hidden defects)

| Area | Current evidence | Release decision |
|---|---|---|
| Premium purchases/restoration | Explicitly unavailable in Pro UI; no purchase integration in declared dependencies | Keep unavailable or implement and test billing before marketing it as purchasable |
| Privacy/terms | Screens state documents are not published | Supply actual product documents |
| Backup/restore | UI explicitly says data is device-local | Decide whether local-only is acceptable; do not promise cloud recovery |
| Language | Preference is saved; dialog explicitly says translations are unavailable | Keep disclosure or implement localization |
| Calories | Report explicitly says calories are not recorded | Preserve honest empty-state behavior |
| Pro testimonials | Static reviews and “Join 100M+ Happy Users” appear in source | Verify provenance and applicability; remove unsupported promotional content |

## Area-by-area review coverage

| Area | Evidence / status |
|---|---|
| Splash, startup, onboarding, plan setup | Recovery paths and persistence inspected; startup test timeouts remain unresolved |
| Home navigation, training, discovery, search | Broad route/catalog tests; several expectations stale after header changes |
| Workout startup and sessions | New flow tests pass within full run; paused navigation, retry, and persistence issues above |
| Challenge editing and custom routines | Existing edit/reorder/replacement tests included; separate session engines remain |
| History, calendars, reports, measurements | Tests included; history writes are serialized and deduplicated, weight writes serialized |
| Settings, reminders, voice/audio | Dart and Android integration reviewed; actual native delivery/playback not verified |
| Premium and account-related UI | Explicitly unfinished features documented above |
| Responsive layout and accessibility | Existing narrow/large-text tests included; no new full visual or assistive-technology audit |
| Release configuration and assets | Web build passed; Android signing unfinished; large source asset footprint |

## Suggested repair order

1. Restore a trustworthy green suite: isolate startup timeouts, update stale UI assertions, and verify controls after scrolling.
2. Fix paused navigation, failed progress writes, and the nonfunctional settings Retry action.
3. Correct header contrast and complete the session UI migration.
4. Gate or implement platform-specific features and make tests portable.
5. Finalize signing, identity, policies, product claims, asset sizing, and documentation; then run Android/iOS device acceptance checks.

## Failed tests from the full run

The failures below are observations, not 16 independently confirmed product bugs. Text differences (`Start` versus `Start workout`, `00:02` versus `2 seconds`, and `READY TO GO!` versus `Get ready`) explain several failures. The new tall/lazy header also means tests must scroll before acting on exercise controls. A progress assertion failure followed a tap outside the viewport and is not sufficient evidence of a storage bug by itself.

- beginner_search_collection_test.dart: Beginner badge opens every workout using its own thumbnail
- discover_navigation_test.dart: Every editorial workout placement opens its exact routine, including offscreen cards
- full_body_search_collection_test.dart: Search Full Body badge opens the collection and every routine
- medium_duration_search_test.dart: Duration badge opens all 49 correct workout destinations and thumbnails
- medium_duration_search_test.dart: Expanded routines isolate old set indices and retain recorded history
- startup_recovery_test.dart: main startup renders UI before storage completes and retry recovers
- startup_recovery_test.dart: hung settings load times out into retryable UI
- training_flow_test.dart: Row launches details and Start launches a session; abandoning saves nothing
- training_flow_test.dart: Session honors custom targets, pauses timers and saves exactly once after final exercise
- startup_recovery_test.dart: corrupt general settings are preserved until confirmed reset; user records survive
- training_flow_test.dart: Shared preparation and Off rest apply to a generic workout
- training_flow_test.dart: Unreadable session settings offer retry before clocks start
- startup_recovery_test.dart: reset storage failure remains retryable and does not navigate
- workout_type_collections_test.dart: with_equipment badge opens its list and every working destination
- workout_type_collections_test.dart: build_muscle badge opens its list and every working destination
- workout_type_collections_test.dart: fat_burning badge opens its list and every working destination

## Evidence files

- [Full test output](review_tests.log)
- [Repository analysis](review_analysis.log)
- [Web build output](review_web_build.log)

## Final verification addendum

The isolated startup rerun finished with **10 passed, 4 failed**, reproducing the same four recovery-test timeout cases. Focused static analysis of **`lib` and `test` passed with no issues**; the 23 repository-wide diagnostics are from auxiliary files rather than application/test sources.

- [Isolated startup rerun](review_startup_recheck.log)
- [Application/test source analysis](review_source_analysis.log)

No fixes were applied in this review. The application changes already present at the start of the review were preserved.
