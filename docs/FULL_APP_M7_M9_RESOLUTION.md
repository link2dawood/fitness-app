# Full app audit: M7–M9 resolution

Date: October 26, 2026 (Asia/Karachi).

## M7 — Honest preferences and real workout destinations

The onboarding completion action now says **Save preferences**. The preparation screen reviews saved measurements, fitness level and focus areas; it no longer claims to analyze a body, adjust fitness level or generate a persistent plan. Missing selections are labeled **Not selected** consistently.

The former Plan Ready screen now summarizes workout preferences. Its card shows the saved goal, all selected focus areas, weekly goal and fitness level. Fabricated daily duration and equipment claims were removed. No generated schedule or saved-plan repository is implied.

**View recommended workouts** opens the real catalog workouts returned by the shared profile-based recommendation service, retaining stable workout IDs and launchable workout details. When a usable fitness level is absent, **Browse workouts** opens the catalog with honest editorial labeling. **Go to homepage** still opens Home; it is a separate destination.

The preparation screen scrolls and its checklist wraps. Large-text layout coverage now exercises all four preparation stages and the populated preference summary as well as the existing onboarding/settings/Pro matrix.

## M8 — Training date refresh

Training uses the shared `DateRolloverBuilder` rather than relying on parent rebuilds or history writes. Its weekly dates, today highlight and completion count refresh at local midnight and on app resume, using the saved first weekday. An injected clock makes boundary behavior deterministic in regression tests.

The open streak sheet also observes date rollover/resume and history updates. The same clock is passed into history opened from Training, preserving the shared calendar's distinction between following today and inspecting a selected past date.

Tests retain the Training widget across Sunday/month, Friday/year and Wednesday/week transitions without tab taps or history reloads. Resume coverage checks both the retained page and an already open streak sheet.

## M9 — Scope progress management to Day 1

The obsolete global **Restart progress** item and its incorrect “progress tracking is not available” dialog were removed. No replacement global reset or data-deletion action was introduced.

The existing working **Restart** remains on the Day 1 challenge page, where its scope is explicit. Confirmation now states that only the current Day 1 session restarts and that exercise edits and completed workout history are kept. Regression coverage verifies Cancel, a fresh restarted session, retained exercise duration edits and unchanged completed history. Opening global workout settings also preserves a seeded saved challenge.

## Validation

- Full Flutter suite: **216 tests passed**.
- `dart analyze lib test`: **No issues found**.
- `git diff --check`: passed.

Permanent tests cover real recommendation IDs and workout-detail destinations, editorial fallback and separate Home routing, honest preparation copy and cancellation, date boundaries/resume, removal of the obsolete settings item and scoped Day 1 restart. Platform media is disabled or mocked in automated tests.

The original audit's M10 and low findings are outside this resolution.
