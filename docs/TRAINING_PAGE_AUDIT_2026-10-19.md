# Training page audit

Date: 19 October 2026 (Asia/Karachi)

## Follow-up implementation status

**All four high findings have been addressed.** The findings and source line
references below describe the original audit snapshot, before these fixes.

| Finding | Implemented fix |
| --- | --- |
| H1: workout actions | One shared catalog of explicit exercise sequences; cards and linked collections open actual workout details and a session player. Custom workouts can also launch with their saved targets/rest values. |
| H2: search | Text, focus, level, type, and duration filter real routines; results show counts, actual metadata, empty states, and working navigation. |
| H3: progress | Completed sessions persist locally with stable session IDs and UTC timestamps. Weekly progress counts distinct local dates; streaks derive from consecutive completed dates. New users start at zero. |
| H4: layout | Content grows with text, category controls wrap, calendar columns flex, and enlarged-text cards use full-width layouts. Normal and enlarged-text audit runs now capture zero overflows. |

See [implementation and verification notes](TRAINING_HIGH_ISSUES_RESOLUTION.md).
Screenshots and JSON under `build/training-audit` now reflect the fixed page;
the original measured failures are recorded in this report's baseline table.
The five original medium findings have now also been addressed in a second
follow-up; see [medium fixes and verification](TRAINING_MEDIUM_ISSUES_RESOLUTION.md).
The three low findings are also resolved; see
[low fixes and verification](TRAINING_LOW_ISSUES_RESOLUTION.md). All 12 original
findings have now been addressed. The findings below remain as the historical
audit snapshot, rather than a list of currently open issues.

## Result

**Training is not ready for a complete workout journey.** It displays a substantial
workout catalog, but the main workout-start actions are not connected to exercise
sequences or a session player. Search and progress tracking also remain incomplete.

Confirmed findings: **0 critical, 4 high, 5 medium, 3 low**.
Critical means a confirmed compilation blocker, crash in the reviewed flow, or data
loss. High means a core journey is blocked or materially misleading. Medium means
an incomplete supporting function or incorrect behavior. Low means polish,
accessibility labeling, or maintenance work. Absence of a critical finding is not
a guarantee that untested device-specific failures do not exist.

This was an audit only. No application behavior was changed.

## Scope and evidence

Reviewed Training, its HomeViewModel, route definitions, shared challenge cards,
Challenge, Search, Just For You, Stretch & Warm Up, the three Popular Goals lists,
and the Custom Workout entry and editor integration. Inspected callbacks, state,
profile usage, catalog connections, image references, and navigation destinations.

Executed a Flutter widget audit with real text/icon fonts, scrolling the Training
page at 390×844 and 320×640 with normal text and at 390×844 with 200% text.
Opened streak and history sheets at normal text sizes. Layout/framework errors
were deliberately recorded rather than treated as successful app behavior.
The diagnostic harness completing successfully only means evidence was collected.

Validation results:

| Check | Result |
| --- | --- |
| Existing automated suite | 40 tests passed |
| Targeted static analysis of Training and linked screens | No errors or warnings; 4 informational lints |
| Referenced image files across reviewed screens | 34 unique assets checked; none missing |
| Training at 390×844, normal text | 0 captured layout/framework errors |
| Training at 320×640, normal text | 2 horizontal overflows: 48 px and 8 px |
| Training at 390×844, 200% text | 10 overflows, including up to 215 px horizontally and 293 px vertically |
| New-user streak sheet | Shows “1 Day Streak!” with empty saved preferences |

No physical Android/iOS device, release APK, screen reader, or performance profiler
was used. Most linked-screen behavior was verified by source inspection, not by
an end-to-end device session. Existing tests primarily cover settings and custom
workouts; their passing result does not establish Training functionality.

## High findings

### H1 — Main workout and challenge actions do not launch training

**Observed:** “START DAY 1” is rendered as a Container without an action in both
shared challenge card factories. Body Focus workout tiles, Recommended Height
Increase, Just For You items, Stretch cards, and Popular Goals items similarly
render content without workout navigation. The corresponding linked workout list
screens use haptic-only tap callbacks. No session launch is attached to these
Training entry points.

**Reproduce:** Open Training and tap START DAY 1, Abs Beginner, a Just For You
workout, or a Stretch card. No workout detail/session is launched. Following a
section's arrow reaches a list, but tapping its workout still does not start one.

**Evidence:** `lib/widgets/challenge_cards.dart:113` and `:252`;
`lib/views/home/pages/training_page.dart:1534`, `:1638`, `:1703`, `:1889`;
`lib/views/home/pages/just_for_you_page.dart:116`;
`stretch_warm_up_page.dart:147`; `build_muscle_more_page.dart:206`;
`burn_fat_more_page.dart:166`; `keep_fit_more_page.dart:151`.

**Fix:** Define workout/plan IDs and actual ordered exercise entries, open a
workout detail page, then connect Start to a session flow. The existing exercise
catalog and custom editor do not by themselves implement session playback.

### H2 — Search and workout filters do not produce results

**Observed:** The Training search field navigates to SearchView. Its text change
only rebuilds the widget; body, type, level, and duration selections only change
local highlighting. The page contains filter controls and a request area, with
no query evaluation, result list, or workout selection flow.

**Reproduce:** Open Training search, type “abs,” then select Beginner. No matching
workout results appear. This is separate from the working Add Exercises filters
inside the custom workout editor.

**Evidence:** `lib/views/home/pages/training_page.dart:386`;
`lib/views/search/search_view.dart:143`, `:180`, `:263`, `:386`, `:442`, `:494`.

**Fix:** Search a real workout dataset, apply the selected filter predicates,
display matching counts/results and an empty state, and link results to details.

### H3 — Streak and weekly completion are not based on activity

**Observed:** Weekly completion is the literal `0`; streak is always “1 Day
Streak!” The weekly denominator reads the profile, but the completion numerator
does not. HomeViewModel contains profile and browsing state, with no completed
session history feeding these values.

**Reproduce:** With empty preferences, open the streak icon: it reports a one-day
streak before any session has been completed. Weekly completion always shows 0.

**Evidence:** `lib/views/home/pages/training_page.dart:248`, `:456`;
`lib/viewmodels/home_viewmodel.dart:6`.

**Fix:** Persist completed sessions with timestamps and derive weekly completion
and consecutive-day streaks from those records. A new user should start at zero.

### H4 — Small screens and enlarged text cause clipping and inaccessible controls

**Observed:** At 320×640, the header overflows right by 48 px and the weekly
calendar by 8 px. At 200% text on 390×844, ten layout overflows occur across the
header and fixed-height content. The streak icon's center moves outside the
390 px viewport, preventing a normal tap in the audit.

**Evidence:** `lib/views/home/pages/training_page.dart:312`, `:501`, `:609`,
`:765`, `:1132`, `:1224`; the JSON and screenshots listed below.

**Fix:** Allow the heading and action area to adapt to available width, make the
seven calendar cells flexible, and replace rigid card/section heights with layouts
that accommodate text scaling. Retest narrow screens, 200% text, and landscape.

## Medium findings

### M1 — Weekly goal edit affordance has no action

The pencil beside the weekly goal is a plain Icon with no tap handler. Users
cannot edit their target from this advertised control.

Evidence: `lib/views/home/pages/training_page.dart:475`.
Fix: Open a target-days editor, persist the value, and refresh the profile state.

### M2 — History opens a calendar without workout history or day details

The sheet computes month dates and highlights today, but never loads completed
workouts. Each date's tap callback is empty. It cannot answer what the user did
on a day, even though the entry is labeled History.

Evidence: `lib/views/home/pages/training_page.dart:1948`, `:2102`.
Fix: Connect session records, mark workout days, and show selected-day sessions
or a clear no-workouts state. Keep date navigation separate from activity state.

### M3 — Saved first-day-of-week preference is ignored

The profile defaults to Sunday and stores `firstDayOfWeek`, while Training's
weekly strip always starts Monday. Its history grid always starts Sunday. The
two views use different conventions and do not consult the preference.

Evidence: `lib/data/models/user_profile.dart:78`, `:105`;
`lib/views/home/pages/training_page.dart:489`, `:1975`, `:2061`.
Fix: Apply the saved preference consistently to both date ordering and headers.

### M4 — Recommendations and customized plan content are mostly static

“Just For You” always contains the same four workouts, including advanced HIIT;
Recommended always shows Height Increase. Training's customized challenge uses
profile labels, but defaults to Advanced without a level and always advertises
Full Body Shred. The Challenge listing hardcodes Beginner / Full Body for that
same customized card instead of reading the profile.

Evidence: `lib/views/home/pages/training_page.dart:299`, `:617`, `:1047`,
`:1142`; `lib/views/home/pages/challenge_page.dart:107`;
`lib/widgets/challenge_cards.dart:70`.
Fix: Derive selections and labels from one plan/recommendation model using the
profile. Use a neutral unavailable/setup state when profile data is missing.

### M5 — “Tell us what you need” does not collect requests

Training's request action only triggers haptics. The related search request
action only displays a snackbar. Neither opens an input form or stores a request.

Evidence: `lib/views/home/pages/training_page.dart:1437`;
`lib/views/search/search_view.dart:573`.
Fix: Reuse the existing feature-suggestion flow or add a local request form with
an honest saved state. External feedback delivery remains deferred per the
earlier project decision and is not required to implement local collection.

## Low findings

### L1 — Training uses a different accent from the current green theme

Training, shared challenge buttons, filter chips, and Home navigation hardcode
blue (`0xFF0062FF`) instead of using AppColors.primary (`0xFF7AC143`).

Evidence: `lib/views/home/pages/training_page.dart:459`, `:1513`;
`lib/widgets/challenge_cards.dart:134`; `lib/views/home/home_view.dart:105`.
Fix: Use shared color tokens for interactive accents; preserve intentional
illustration/category colors where appropriate.

### L2 — Icon-only actions lack explicit accessible names and standard controls

Streak and section arrows use GestureDetector plus icons without descriptive
tooltips/semantic button labels. Several section arrows are roughly 28×28,
smaller than the commonly used 48 px Material interaction target.

Evidence: `lib/views/home/pages/training_page.dart:329`, `:579`, `:1107`, `:1199`.
Fix: Use labeled IconButtons or explicit Semantics with suitably sized hit areas;
verify focus order and spoken labels on a device screen reader.

### L3 — Four static-analysis maintenance lints remain

Three deprecated `withOpacity` calls are in Training at lines 591, 1115, and 1207.
ChallengePage's constructor can use a super parameter at line 5. No analyzed
compilation errors or warnings were reported.

Fix: Use `withValues(alpha: ...)` and the modern constructor syntax when editing
these components. These are maintenance issues, not compilation blockers.

## Section coverage

| Area | Current state |
| --- | --- |
| Header / Pro | Pro route exists; streak opens, but its value is fixed |
| Weekly goal | Profile target displays; completion fixed; edit missing |
| Calendar / History | Month navigation and today highlight exist; no activity data |
| Challenges | Section navigation/category filtering exist; Start actions missing |
| Body Focus | Seven categories and carousel state exist; workout tiles have no action |
| Workout-type badges | Display only; not wired as filters |
| Custom Workout | Entry route exists; create/edit/save/details covered by passing existing tests; no session player is attached to this entry |
| Recommended | Static card without a launch action |
| Just For You | Section route exists; static items; linked taps only haptic |
| Stretch & Warm Up | Section route exists; linked taps only haptic |
| Popular Goals | Tabs change the displayed lists; More routes exist; workout taps do not launch |
| Explore More | Callback changes HomeViewModel tab to Discover |
| Feedback request | Haptic only on Training; no request capture |
| Images | No missing referenced image files in reviewed scope |

## Suggested implementation order

1. Introduce real workout/plan definitions and a working detail → session →
   completion flow; wire all workout and challenge actions to those IDs.
2. Persist completions and derive progress, streaks, and history from them.
3. Implement workout search/results and its filters against that dataset.
4. Fix narrow-screen and large-text layouts before adding more card content.
5. Connect goal editing, week preferences, recommendations, and local feedback.
6. Unify theme tokens, improve accessibility controls, and clear maintenance lints.

## Reproduction artifacts

- Audit harness: `tool/training_page_audit.dart` (diagnostic only; intentionally
  records layout failures, so a green harness result is not a clean UI result).
- Normal screen screenshots: `build/training-audit/390-1-0.png`,
  `390-1-420.png`, `390-1-840.png`, `390-1-1260.png`.
- Narrow-screen screenshot: `build/training-audit/320-1-0.png`.
- Large-text screenshot: `build/training-audit/390-2-0.png`.
- Captured diagnostics: `build/training-audit/390-1.json`, `320-1.json`,
  `390-2.json`.
- Asset audit: `build/training-audit/assets.json`.

Build artifacts may be removed by flutter clean. Recreate the directory before
running the harness: `New-Item -ItemType Directory -Force build/training-audit`.
Run it with `flutter test --no-pub tool/training_page_audit.dart` on this Windows
setup (it loads system Arial and Flutter's cached Material icon font).
