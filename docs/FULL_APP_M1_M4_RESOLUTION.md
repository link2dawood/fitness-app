# Full app audit: M1–M4 resolution

Date: October 26, 2026 (Asia/Karachi).

## M1 — Cancel asynchronous plan generation

Plan generation cancels pending delay timers and awaits cancellable animation futures. Disposing the page completes its pending delay with a cancellation result; every subsequent animation, state change and navigation checks that the page is still mounted. Progress listens to the current animation.

Regression coverage leaves during the initial delay, an animation and the delay between stages. No disposed-controller assertion or late navigation is allowed.

## M2 — One weekday contract

`TrainingCalendar.firstDays` supplies all seven supported values. Onboarding, goal editing, saved-profile validation, week/month geometry and persisted-history weekly counts use this contract. Date arithmetic normalizes calendar dates and works across year boundaries. The older `sundayFirst` history argument remains compatible.

Tests cover every offered weekday, full-date week/month alignment, persisted preference round trips, and exclusion of sessions before the selected week starts.

## M3 — Shared session settings

Catalog and custom workout sessions load durable settings before starting their clocks, with a retry state on load failure. They use the saved preparation countdown and shared rest resolution: Default preserves the routine rest, Off skips rest, and Custom overrides it. Legacy values such as `45s` remain readable. Reference challenge details and session settings use the same rest resolution, including Off.

Generic sessions also use shared music, mute, coaching/effect switches and voice volume through the existing media services. Media follows pause, resume, completion and disposal. Unsupported native media does not block exercise timing. Generic session media initialization currently uses the existing native TTS capability probe; native playback remains a device-validation step.

## M4 — Checked settings commits

General and workout settings now commit each change as one JSON record. Existing individual keys migrate on the first successful save. Reads and writes are serialized, reload durable storage, merge the latest record, check false write results and repair cached state after failure. Paired units and rest-mode/duration changes cannot partially commit. General-settings recovery removes the new record as well as legacy keys.

Workout timer, music and sound sheets await storage before publishing state or dismissing. Duplicate Done taps are guarded; failed saves leave the local draft available for retry. A failed initial settings read offers Retry instead of editable defaults. Imported music metadata, selection and enabled state commit together. Challenge audio controls publish their preference only after durable storage succeeds. Challenge rest editing retains its draft after failure; mute errors are visible. Screen-on saves roll back the native flag if storage fails.

## Validation

- Full Flutter regression suite: **179 tests passed**.
- `dart analyze lib test`: **No issues found**.
- `git diff --check`: passed.

Permanent tests include atomic failure/retry, concurrent merge, native screen rollback, modal duplicate submits and retained drafts, generic preparation/rest behavior, settings-load retry, all seven week starts, and plan cancellation.

Native audio and screen behavior use mocked platform channels in automated tests. No Android device playback claim is made by these checks. The original audit's M5–M10 and low findings are outside this resolution.
