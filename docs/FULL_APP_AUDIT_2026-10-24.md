# Full app audit

**Resolution update:** H1 and H2 have been fixed and given permanent regression coverage. See [history durability resolution](FULL_APP_H1_HISTORY_DURABILITY_RESOLUTION.md) and [startup/profile recovery resolution](FULL_APP_H2_STARTUP_RECOVERY_RESOLUTION.md). The counts, evidence and findings below retain the original audit snapshot.

**Date:** October 24, 2026 — Asia/Karachi  
**Project:** fitness_pro  
**Findings:** **2 High, 10 Medium, 2 Low. No Critical issue identified in the checks performed.**  
**Scope:** Code review, automated behavior/persistence diagnostics, real-font layout checks, existing regressions, and build checks. No production app code was changed during this audit.

The app's main navigation and the previously corrected Training, Discover, and Report flows pass the existing suite. Remaining problems concentrate in failed-write recovery, startup recovery, onboarding, settings integration, and release preparation. A passing baseline suite does not cover the failures reproduced below.

## Validation results

| Check | Result | Practical limit |
| --- | --- | --- |
| Existing Flutter suite | **147 tests passed** | Primarily widget/unit tests; native services are mocked where required. |
| `dart analyze lib test` | **No issues found** | Static analysis does not detect these behavioral failures. |
| Additional audit harness | **10 checks passed; 1 failed with a reproduced app lifecycle assertion** | Diagnostic checks intentionally record bad states and layout errors; their passing status is not a clean-app verdict. |
| Release web build | **Succeeded** | Compilation only; no browser end-to-end session or web media/device integration certification. |
| Android debug build | **Not validated** | Gradle stopped with `java.io.IOException: Unable to establish loopback connection`, before successful APK assembly. This is an environment/build-tool failure, not proof of a Dart compilation defect. |
| iOS / physical-device execution | **Not run** | No iOS build host or physical-device notification/TTS/media tests in this audit. |

Commands used: `flutter test`, `dart analyze lib test`, `flutter test build/full_app_audit_test.dart`, `flutter build web --release --no-pub`, and `flutter build apk --debug --no-pub`, invoked through the installed Flutter tool snapshot.

Evidence is retained in [docs/audits/full_app_2026-10-24](audits/full_app_2026-10-24/): [diagnostic JSON](audits/full_app_2026-10-24/full-app-audit-results-2026-10-24.json), [diagnostic log](audits/full_app_2026-10-24/full-app-diagnostics-2026-10-24.log), [baseline test log](audits/full_app_2026-10-24/full-app-tests-2026-10-24.log), [analysis log](audits/full_app_2026-10-24/full-app-analysis-2026-10-24.log), and both build logs. The audit harness is included for reproduction; it is separate from the permanent `test/` suite.

## Coverage

| Area | Reviewed / exercised |
| --- | --- |
| Launch and onboarding | Settings initialization, splash routing, profile persistence, all eight onboarding steps, units, week-start selection, skip/complete paths, plan generation and Plan Ready. |
| Home / Training | Four-tab host, weekly goal/date calculations, right-aligned actions, catalog collections, recommendations, navigation, session progression, history and challenge progress. |
| Discover / Search | Existing destination/catalog tests, search routing, profile-based picks and editorial fallback, persisted history, collection destinations and metadata. |
| Custom workouts / exercises | Create/edit/save/delete repository paths, targets/rest values, picker/filter/detail coverage, procedural avatars and routine conversion. Existing regressions exercise these flows. |
| Report | Existing history, dated weight persistence, decimal profile compatibility, save failures, units, date rollover, responsive controls and BMI scale geometry tests. |
| Settings | Workout timers, music/import persistence paths, general settings, reminders, gender/DOB, language preference, feature suggestions, TTS bridge and deferred feature labels. |
| Platform / assets | Android manifest, reminder scheduling and native channel wiring, iOS registration, release configuration, web build and literal asset references. |

This does not claim every catalog workout was completed on a device, every avatar movement was biomechanically validated, or Android notifications were delivered in real background/boot conditions.

## Priority summary

| ID | Severity | Finding |
| --- | --- | --- |
| H1 | High | Failed workout-history writes become phantom records and can defeat retry. |
| H2 | High | Startup/profile load failures have no reliable recovery path. |
| M1 | Medium | Leaving plan generation during a delay uses a disposed animation controller. |
| M2 | Medium | Onboarding offers seven week-start values; shared calendars support only two. |
| M3 | Medium | Saved workout timer/media settings are not applied consistently to sessions. |
| M4 | Medium | Remaining settings writes can report success without durable storage or save only part of a change. |
| M5 | Medium | Onboarding, Plan Ready, Pro and workout-settings dialogs still overflow. |
| M6 | Medium | Some onboarding/settings actions still lack keyboard behavior and button/selection semantics. |
| M7 | Medium | “Generated plan” is a presentation flow without a persistent, launchable plan. |
| M8 | Medium | Training's weekly calendar depends on unrelated rebuilds at date rollover. |
| M9 | Medium | Restart progress still displays an obsolete no-progress message. |
| M10 | Medium | Android release uses debug signing and a template application identifier. |
| L1 | Low | Displayed version contradicts the package version. |
| L2 | Low | Four primary onboarding goal assets are missing and always use fallbacks. |

## High findings

### H1 — Failed workout-history writes become phantom records and can defeat retry

**Source:** `lib/data/repositories/training_history_repository.dart:38–45`, `:64–83`, particularly the duplicate-ID early return at line 76.

The repository checks the boolean write result before updating `_entries`, which is good. However, SharedPreferences updates its local cache even when the backing store returns false. `load()` and `_complete()` read that cache without reloading durable storage.

**Reproduced:** Inject a false result for `training_completions_v1`, attempt to complete a 60-second session, reload history, then retry the same session after storage recovers. The first attempt throws, but reload returns **one completion**. The retry returns without another write because the cached ID already exists. Total write attempts remain **one**, while durable history is **absent**.

**Impact:** Report/Training can show a completion that was never saved; the UI can consider a retry successful, yet that completion disappears after restart. This is a remaining repository-level problem despite the Report save-state fixes.

**Fix direction:** Base load/deduplication on authoritative persisted data; discard or reload the failed-write cache. Preserve serialized writes and idempotent session IDs. Add a permanent false-write → reload → retry → fresh-process-read regression. Review custom-workout/challenge/reminder repositories for the same cached-write pattern; those additional repositories were not all given this exact failure injection.

### H2 — Startup/profile load failures have no reliable recovery path

**Source:** `lib/viewmodels/home_viewmodel.dart:57–67`; `lib/core/routes/app_routes.dart:77–82`; `lib/main.dart:12–14`; `lib/views/splash/splash_view.dart:49–53`.

Home loads the profile before its history try/catch. A malformed profile or profile read failure escapes the Future, and `_isLoading` never becomes false. Home route creation starts that Future without awaiting or handling it. Startup also awaits General Settings before `runApp`, and splash routing has no user-facing error/retry state for repository failures.

**Reproduced:** Persist `user_profile = "broken"`, then call `HomeViewModel.load()`. It throws **FormatException**, retains **isLoading = true**, and has **historyError = null**. The history retry message cannot recover a profile-load failure.

**Impact:** A damaged local profile can leave the main app in an indefinite loading state. Early storage failures can prevent a usable recovery screen from appearing.

**Fix direction:** Introduce explicit startup/profile loading, ready, and error states. Catch profile/settings failures, preserve unreadable data, offer retry and an explicit recovery/reset path, and guard splash navigation. Handle route-created asynchronous loads rather than leaving errors unobserved.

## Medium findings

### M1 — Leaving plan generation during a delay uses a disposed controller

**Source:** `lib/views/plan/plan_generation_view.dart:46–72`, `:92`.

Mounted checks follow animations, but the 500 ms delays between stages are followed by `_animateTo()` without another mounted check. `_animateTo()` resets/starts the controller after it may have been disposed.

**Reproduced:** Complete the first loading stage, remove the screen during the inter-stage delay, then advance time. The additional audit test fails with **`AnimationController.stop() called after AnimationController.dispose()`**, through `_animateTo` → `_runLoadingSteps` at line 57. See the diagnostic log; this asynchronous exception is recorded there rather than in the JSON's `takeException` field.

**Fix direction:** Cancel the loading sequence on disposal, check mounted before every controller operation after a delay, and handle cancelled animations. Retain a navigation-away regression.

### M2 — Seven selectable week starts do not match the shared calendar contract

**Source:** `lib/views/onboarding/steps/weekly_goal_step.dart:12–20`, `:69`; `lib/data/models/training_calendar.dart:2–5`, `:14`; `lib/data/repositories/training_history_repository.dart:93–96`.

Onboarding accepts Sunday through Saturday. Calendar utilities special-case Monday and treat everything else as Sunday. Weekly completion counting accepts only a Sunday-first boolean, so an unsupported saved value can also make the date strip and count use different week boundaries.

**Reproduced:** Save **TUESDAY** through onboarding. For October 24, 2026, `TrainingCalendar.week()` begins on **Sunday, October 18**, not Tuesday, October 20. The stored preference remains TUESDAY.

**Impact:** Training, Report and All records can ignore a valid UI selection and disagree about weekly totals.

**Fix direction:** Either support all seven weekday offsets consistently, including weekly totals, or restrict onboarding to the same supported choices and migrate existing saved values. Test all allowed values and month/year boundaries.

### M3 — Workout settings are not consistently connected to sessions

**Source:** `lib/views/workouts/training_workout_page.dart:148–160`; `lib/data/models/training_workout.dart:23`; `lib/views/workouts/challenge_day_page.dart:77–81`; compare `lib/views/workouts/challenge_session_page.dart:90–137`.

Generic catalog/custom sessions start the active exercise immediately and use routine rest values; they do not read the saved prep setting or integrate the saved music/TTS configuration. The special reference challenge does read settings, but its rest loader treats every non-Custom value, including **Off**, as 30 seconds.

**Reproduced:** With prep set to **45 seconds** and rest **Off**, a generic session immediately displays its first exercise and its catalog rest remains **15 seconds**. With the reference challenge's rest **Off**, the launched session receives **rest = 30**.

**Impact:** The same settings screen produces different behavior depending on which workout is started. In particular, disabling rest does not disable challenge rest.

**Fix direction:** Define one shared session-settings contract and apply it to every supported session type. Resolve routine-specific rest overrides explicitly, honor Off, implement prep consistently, and either connect media settings or label their supported scope. Coach tips already say “coming soon” and are not counted as a new defect.

### M4 — Some settings writes still ignore storage failure and partial updates

**Source:** `lib/views/settings/workout_settings_view.dart:104–117`, `:1342–1351`; `lib/core/settings/general_settings.dart:32–40`, `:52–58`.

Workout Settings awaits preference calls but ignores their boolean results. Modal Done handlers update local state, call `_savePreferences()` without awaiting it, and dismiss. General Settings' screen-on write ignores its storage result, while unit changes use two independent writes without rollback.

**Reproduced:**

- Return false for the prep preference write: the page displays **25 secs**, no save-error message appears, and durable prep is absent.
- Return false for keep-screen-on persistence: the method reports no failure and observable state becomes **true**, while no durable value exists.
- Fail the second unit write: durable weight becomes imperial, durable height remains unchanged, while observable settings still show the old pair.

**Impact:** Settings can silently revert or change partially after restart. Native screen behavior can also disagree with saved settings.

**Fix direction:** Check every result, await modal commits, retain drafts for retry, and publish observable state only after successful persistence. Use an atomic settings record or rollback strategy, including restoration of native screen state when needed. Do not undo the measurement-only save improvements already implemented.

### M5 — Remaining layouts overflow on narrow/large-text and short screens

**Source:** fixed/non-scrolling layout constraints in `lib/views/plan/plan_ready_view.dart:49–104`, `lib/views/onboarding/steps/gender_step.dart:21–30`, onboarding weekly/body metric rows, `lib/views/pro/pro_plan_view.dart`, and Workout Settings music/rest/prep/sound modals.

The real-font audit captured these remaining diagnostics:

| Surface | 390×844, 100% | 320×640, 200% | 844×390, 100% |
| --- | --- | --- | --- |
| Plan Ready | None | Bottom **695 px** | Bottom **221 px** |
| Pro | None | Several right overflows, up to **251 px**; bottom up to **176 px** | None |
| Onboarding gender | None | Bottom **60 px** | None |
| Onboarding focus area | None | Bottom **44 px** | None |
| Onboarding fitness level | None | Bottom **2 px** | None |
| Onboarding weekly goal | None | Right **56 px**, bottom **16 px** | None |
| Onboarding body metrics | None | Right **3.6 px** | None |
| Settings music modal | None | Bottom **16 px** | Bottom **100 px** |
| Settings rest modal | None | Bottom **168 px** | Bottom **45 px** |
| Settings prep modal | None | Bottom **5 px** | None |
| Settings sound modal | None | Right up to **187 px** | None |
| Generic session / initial Home tab tree | None | None in exercised view | None in exercised view |

These are rendering diagnostics, not proof that every offscreen control was reachable. The earlier Report/Discover responsive fixes pass their permanent tests and are not being re-reported here.

**Fix direction:** Use scrollable plan/sheet bodies, growing button/card heights, flexible option rows and wrapped headings. Keep primary actions reachable in short viewports. Expand real-font layout coverage to the remaining onboarding and settings screens.

### M6 — Onboarding/settings controls still omit keyboard and role semantics

**Source:** `lib/views/onboarding/steps/gender_step.dart:83`, `lib/views/onboarding/steps/goal_step.dart:95`; bare GestureDetector controls throughout `lib/views/settings/workout_settings_view.dart`, including prep Done at line 1342.

Several interactive cards and modal actions remain pointer-only GestureDetectors. Their visual selected state is not consistently exposed, and they do not gain Material button keyboard behavior.

**Reproduced:** The prep Done control's semantic node has **tap action and label “Done”**, but **no button or focusable flag**. Its size was adequate in that fixture; the reproduced failure is semantics/focus, not an undersized target.

**Fix direction:** Use Material buttons or explicit Focus/Actions controls, expose selected/checked state for selection cards, and maintain one semantic action per control. Retain keyboard and screen-reader checks across onboarding and settings, matching the improved Home/Report actions.

### M7 — “Generated plan” has no persistent, launchable plan behind it

**Source:** `lib/views/plan/plan_generation_view.dart:46–79`; `lib/views/plan/plan_ready_view.dart:11–35`, `:250`, `:272`.

Generation advances through timed animations and passes the profile onward; it does not create a workout schedule or saved plan. Plan Ready derives its title/metadata from profile fields, while **START NOW** and **Go to homepage** both navigate to Home. Skipping fitness level also yields a Beginner fallback during generation but an Advanced fallback on Plan Ready.

**Evidence level:** Source-traced product behavior; no generated plan repository/model/write exists in this flow. Profile-based recommendations on Home/Discover are real and separate.

**Impact:** Users are told a plan is ready but cannot identify, resume, or start the promised plan from that confirmation.

**Fix direction:** Either select/persist a real catalog plan with stable IDs and start its first workout, or describe this flow honestly as profile setup/recommendation preparation. Use consistent fallback metadata and distinct destinations for primary/secondary actions.

### M8 — Training's weekly dates can remain stale overnight

**Source:** `lib/views/home/pages/training_page.dart:26`, `:114–122`; compare `lib/core/widgets/date_rollover_builder.dart` and its Report/shared-calendar consumers.

Training calculates the current date only when its widget rebuilds. It does not subscribe directly to date rollover or lifecycle resume. The retained tab can therefore keep yesterday's highlight/week and weekly goal count across midnight until another action triggers a parent rebuild. Report's midnight rollover rebuilds its own subtree; it does not by itself rebuild Training. A successful Report history reload on resume currently refreshes Training indirectly through the shared repository; that does not address an idle foreground midnight transition.

**Evidence level:** Source-based lifecycle finding; a real overnight device run was not performed. Existing injected-clock rollover tests cover Report/shared history, not Training.

**Fix direction:** Reuse the shared date-rollover mechanism for Training and its streak presentation. Verify an idle retained tab across midnight, week/month change, and resume without relying on tab taps.

### M9 — Restart progress is an obsolete stub

**Source:** `lib/views/settings/workout_settings_view.dart:1663–1681`; compare `lib/data/repositories/challenge_day_repository.dart` and `lib/views/workouts/challenge_session_page.dart:165–172`.

Restart progress always says there is no saved progress and progress tracking is unavailable. The reference challenge now stores resumable progress, and completed history also exists.

**Impact:** This setting cannot perform its advertised action and describes the app incorrectly, even when a challenge has saved progress.

**Fix direction:** Define whether it resets the active challenge, selected routine, or other progress. Connect it to the actual repository with confirmation and failure handling, explicitly preserving completed history unless the user requests deletion. Otherwise remove or accurately disable the action.

### M10 — Android release configuration is still a development template

**Source:** `android/app/build.gradle.kts:19`, `:28–32`.

The application ID is `com.example.fitness_pro` and the release build explicitly uses the **debug signing configuration**.

**Impact:** This checkout is not configured as the intended distributable release identity/signing setup. This is separate from the loopback error that blocked this audit's Android build check.

**Fix direction:** Establish the intended application identifier and release signing configuration before release distribution. Keep signing secrets outside committed source. Re-run debug and release builds once the local Gradle connection problem is resolved. No signing credentials were requested or changed in this audit.

## Low findings

### L1 — Displayed version is incorrect

`lib/views/home/pages/settings_page.dart:260` displays **1.7.91**, while `pubspec.yaml` declares **1.0.0+1**.

**Impact / fix:** Support reports can identify the wrong build. Display package/build metadata from the installed application rather than a hardcoded value.

### L2 — Four primary goal images do not exist

`lib/views/onboarding/steps/goal_step.dart:68–75` references `assets/images/goal_lose_weight.png`, `goal_build_muscle.png`, `goal_keep_fit.png`, and `goal_endurance.png`. Those files are absent. The `errorBuilder` at lines 166–168 masks the missing assets by loading fallback images.

**Impact / fix:** Male/default onboarding always shows fallback art and performs avoidable failed asset lookups. Point directly to intended bundled assets or supply the missing files and declare their asset directory. Existing fallbacks prevent this from being a screen crash.

## Deferred features and platform limits — not newly counted defects

The following are intentionally unavailable or explicitly limited in the current app, consistent with earlier instructions:

- **Health Connect:** removed; not requested to be reinstated.
- **Cloud backup, store purchases/restoration, sharing/rating links and external feedback delivery:** show unavailable states pending configuration. No false successful purchase or cloud synchronization was observed in reviewed paths.
- **Language options:** save a preference and explicitly state that app translations are not available. This is not counted as a new localization defect.
- **Feature suggestions:** explicitly say they are saved on this device; there is no claim that an external team received them.
- **Privacy policy:** the app explicitly displays that a policy is not published. Supplying the actual policy remains product/release work; no legal compliance assessment was performed.
- **Native integrations:** Android TTS/reminder/screen-control implementations are present. Equivalent custom iOS/web channels are absent; some surfaces report unavailability. Web compilation does not demonstrate native feature parity.
- **Assets:** roughly **79 MiB** of source assets are bundled. That is an asset-size observation, not an APK-size or runtime-memory measurement.

## Recommended repair order

1. **H1:** Fix failed-write cache recovery and retry durability before trusting completion counts under storage failure.
2. **H2:** Add startup/profile recovery so local corruption cannot trap the app in loading.
3. **M1, M2, M3, M4:** Fix asynchronous lifecycle cancellation, shared weekday/settings contracts and remaining settings commits.
4. **M5, M6:** Finish responsive and accessible onboarding/settings/Pro controls.
5. **M7, M8, M9:** Connect or relabel plan/progress actions and refresh Training dates consistently.
6. **M10, L1, L2:** Complete release identity/signing and small metadata/asset cleanup, then verify an actual Android build and device flows.

After fixes, promote the reproductions into permanent regression tests. Add a real-device pass for notification permission denial, alarm delivery/boot/timezone changes, TTS engine/language installation, music import/reopen, lifecycle interruptions, offline cold start, and release installation. These native behaviors remain unverified by mocked widget tests.
