# Full-app H2 — Startup and profile recovery

The app mounts `StartupGate` before reading General Settings, so a settings read failure can display a usable error screen instead of preventing `runApp`. Settings initialization is bounded by a timeout, stages values before publishing them, and supports Retry. A confirmed settings reset removes only the four general-preference keys.

Splash validates saved profile data and onboarding status before routing, including a missing profile marked completed. It catches failures and exposes Retry and a confirmed profile-only reset. Retry never deletes unreadable data. The profile reset preserves workout records, custom workouts, weight logs, reminders, and general settings; it returns to onboarding after the checked deletion succeeds.

`HomeViewModel` now exposes `profileError` independently of `historyError` and always ends its profile loading state on error. Home shows recovery controls instead of mounting the normal tabs with a failed profile. Route-created loads handle their own exceptions, duplicate loads are guarded, and notifications are suppressed after disposal. Profile/storage operations have bounded waits; late profile results cannot overwrite a timed-out result.

The shared recovery view provides named Material actions, a scrollable confirmation dialog, duplicate-submit protection, bounded recovery actions, and retryable reset errors. The existing Settings reset action also reports a failed deletion instead of navigating as though it succeeded.

Fourteen permanent checks in `test/startup_recovery_test.dart` cover malformed JSON, wrong field types, invalid onboarding flags, missing completed profiles, settings and profile timeouts, cold-start and direct-Home-route recovery, cancellation, confirmed resets preserving history, false deletion results, duplicate loading, and model disposal during an outstanding read.

Other medium and low full-app findings remain separate work. No automatic data wipe or silent replacement of unreadable profile data was added.

Validation: **168 permanent tests passed**; static analysis of `lib` and `test` found **no issues**. The app smoke test now exercises the actual fresh-install settings → splash → onboarding path.
