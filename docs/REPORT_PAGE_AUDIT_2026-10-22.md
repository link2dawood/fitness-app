# Report page audit

**Resolution update:** H1–H4 and M1–M6 have since been addressed. The findings below preserve the original audit evidence. See [medium fixes](REPORT_MEDIUM_RESOLUTION.md) and [measurement save fixes](REPORT_MEASUREMENT_SAVE_RESOLUTION.md) for current behavior and validation.

**Date:** October 22, 2026, Asia/Karachi  
**Findings:** **4 High, 6 Medium, 1 Low.**  
**Result:** Report renders, but its workout statistics, measurement history and calendar are not reliable representations of saved user data.

This is a report-only review. Report production code was not changed; earlier Training/Discover changes were left intact.

## Scope and evidence

Reviewed the Report summary, weekly history/streak, All records calendar, weight logger, weight chart, height picker, BMI calculation/scale, units, save/cancel behavior, persistence, navigation, and accessibility. Traced `HomeViewModel`, onboarding/profile storage, general settings and the persisted workout completion repository.

Static analysis of `report_page.dart` and `history_calendar_view.dart` found **no issues**. A temporary diagnostic harness ran seven scenarios: five layout configurations, saved-data/edit/reopen behavior, and semantic/target-size inspection. The harness records rendering errors rather than failing immediately; its successful execution is not a clean-layout verdict.

Fixtures contained a saved **80 kg / 180 cm** profile, **Monday** week-start preference, metric units, and one completed **600-second** workout today. A real Arial font was used for layout measurements.

## High findings

### H1 — Workout totals and streak remain zero despite saved completions

**Source:** `lib/views/home/pages/report_page.dart:23`, summary at line 673, weekly history at line 752.

Workout count, calories, training minutes and day streak are fixed `final` zero values. The page does not derive them from `TrainingHistoryRepository`. Listening to Home view-model changes rebuilds the same zeros; it does not fix the data source. The week strip only highlights today, not completed workout days.

**Reproduced:** With one saved 10-minute completion today, Report displays **0 Workout, 0 Minute and 0 Day Streak**. Saved history is present in the repository.

**Impact:** Completed training appears to have made no progress.

**Fix direction:** Aggregate completed sessions and their recorded durations from the persisted history repository, use its streak/date logic, and distinguish load failure from a genuine empty report. The current completion model has no calorie field; define a supported estimate or show calories as unavailable rather than inventing a value.

### H2 — Sample weight overrides the profile and produces a wrong BMI

**Source:** `lib/views/home/pages/report_page.dart:20`, line 30 and calculation at line 598.

Report initializes weight to **106.7 lbs**, with a sample chart point on day 6. It never initializes the displayed weight from `profile.weightKg`. BMI combines this sample weight with the saved profile's height. Heaviest/lightest values also include the sample point.

**Reproduced:** An 80 kg / 180 cm saved profile displays **48.4 kg** and **BMI 14.9**. The same app profile's BMI calculation is approximately **24.7**. The page consequently displays a different weight-category label. This comparison uses the app's own arithmetic; it is not a medical assessment.

**Impact:** Users see fabricated measurement data and a misleading BMI/category.

**Fix direction:** Initialize from authoritative measurements/profile data; remove sample points. Use an honest empty state when measurements are unavailable and calculate BMI from the same canonical saved values.

### H3 — Weight logs are not retained, and saving loses decimal precision

**Source:** `lib/views/home/pages/report_page.dart:20`, update helper at line 33, save callback at line 291 and post-dismiss save near line 336; `lib/data/models/user_profile.dart` stores integer `weightKg`.

The weight time series exists only in page state. Save updates a local day-number point and writes only the latest weight to the onboarding profile, rounded to a whole kilogram. No dated weight-history repository is used. Page recreation restores the sample weight/point instead of the saved profile or logs.

**Reproduced:** Logging **72.6 kg** shows 72.6 kg in the current page but persists **73 kg**. Recreating Report displays **48.4 kg** again, while the profile still contains 73 kg. The new chart point is gone. Cancel correctly restored the pre-edit local state in the normal-size scenario.

**Impact:** Measurement history disappears, entered precision is lost, and Report contradicts persisted data after reopening.

**Fix direction:** Persist decimal measurement values in a canonical unit with a full calendar date, load the time series on entry, and define same-day replacement behavior. Derive current/heaviest/lightest from real records and keep profile synchronization explicit.

### H4 — All records opens an empty calendar disconnected from real history

**Source:** `lib/views/home/pages/report_page.dart:635`; `lib/views/home/pages/history_calendar_view.dart:15` and day cells at line 170.

Navigation works, but `HistoryCalendarView` uses a permanently empty `_loggedDays` set. It does not read saved completions, mark their dates, allow selecting a date, or show that day's sessions/durations.

**Reproduced:** The seeded saved session is absent from All records. The screen shows calendar dates only. Previous/next month and the custom back control work.

**Impact:** The apparent history destination cannot retrieve workout records. Discover and Training already have a persisted history view, making the discrepancy visible between tabs.

**Fix direction:** Reuse the real persisted history/calendar flow or connect this screen to the same repository, with full-date identity, selection, loading/error/empty states and saved week-start preference.

## Medium findings

### M1 — Measurement saves lack reliable failure handling

**Source:** weight save/post-dismiss path in `report_page.dart`, height save at line 531, `lib/viewmodels/home_viewmodel.dart:70`, and `lib/data/repositories/onboarding_repository.dart:19`.

Source inspection shows that weight Save closes before its unawaited `updateWeight` finishes. Height awaits its write but has no saving state or exception/retry UI. The view model mutates its profile before a durable write, and `saveProfile` ignores the boolean returned by `SharedPreferences.setString`.

**Impact:** A failed write can appear saved, leave optimistic in-memory data, or surface an unhandled asynchronous error. Repeated height taps can also start overlapping saves. Failure injection was not performed in this audit; these paths are established by source inspection.

**Fix direction:** Await writes, check storage results, disable duplicate submits, report failures and retain drafts for retry. Update observable authoritative state after a successful write. Avoid marking onboarding complete merely to save an isolated measurement when no completed profile exists.

### M2 — Height display ignores metric preference

**Source:** `report_page.dart:593`, BMI height row near line 1131, and local weight-unit handlers near lines 186–200.

The height picker starts from `GeneralSettings.heightImperial`, but the main Report height row always renders feet/inches. Weight-sheet unit changes update local Report state without updating the shared persisted unit setting.

**Reproduced:** With both global unit preferences set to metric, the main height row reads **5 ft 11 in** instead of 180 cm. Weight correctly uses the metric unit label, although its source value is wrong under H2.

**Fix direction:** Render height and weight using shared unit preferences. Either persist unit changes through the shared settings service or clearly define them as temporary picker-only choices; avoid divergent page/global preferences.

### M3 — Week-start preference is ignored, and dates become stale overnight

**Source:** `report_page.dart:45`, line 753; `history_calendar_view.dart:119` and month-offset calculation.

Both calendars hardcode Sunday-first ordering. Report captures `_today` and `_weekStart` once in `initState`, and the history screen also captures today once. Home retains Report in an IndexedStack, so dates can remain stale while the app stays open across midnight or a week/month boundary. The weight logger date and log key also use that cached day.

**Reproduced:** A saved Monday preference still shows `S M T W T F S`. Overnight behavior is a source-based lifecycle finding, not an overnight runtime test.

**Fix direction:** Use the shared calendar utilities and profile preference, normalize calendar dates, and refresh on resume/date rollover before rendering or saving a log.

### M4 — Narrow, large-text and landscape layouts overflow

**Source:** `report_page.dart:914`, line 1068, logger heading at line 128, modal columns at lines 113/353; `history_calendar_view.dart:58`, line 103 and line 156.

Measured with a real text font:

| Configuration | Report | Weight logger | Height picker | All records |
| --- | --- | --- | --- | --- |
| 390×844, 100% text | No diagnostics | No diagnostics | No diagnostics | No diagnostics |
| 320×640, 100% text | No diagnostics | No diagnostics | No diagnostics | Six right overflows of 8 px |
| 320×640, 200% text | Weight/BMI rows overflow right by 87/127 px | Heading overflows right by 33 px | No diagnostics | Six right overflows of 8 px |
| 844×390 landscape, 100% text | No diagnostics | Bottom overflow 43 px | Bottom overflow 11 px | Bottom overflow 40 px |
| 768×1024, 100% text | No diagnostics | No diagnostics | No diagnostics | No diagnostics |

The calendar allocates seven fixed 40-pixel cells inside a 272-pixel content width on a 320-pixel screen. The modals and calendar use non-scrolling Columns, and summary/measurement rows do not accommodate growing labels.

**Fix direction:** Use flexible/wrapped layouts and responsive date-cell widths, and make sheets/calendar content scrollable with reachable actions in short viewports.

### M5 — Core actions have undersized targets and incomplete semantics

**Source:** GestureDetector actions in `report_page.dart`, including `_unitBtn`, `_blueButton`, section-header actions and the height row; calendar icon buttons have no tooltips.

Measured at 390×844, 100% text:

| Action | Target size | Explicit button role |
| --- | --- | --- |
| Log | Approximately 68×40 | Missing |
| All records | Approximately 69×20 | Missing |
| Edit height row | 322×23 | Missing |

These bare gesture targets do not provide standard keyboard button behavior. Unit toggles lack selected-state semantics. The custom-painted chart/scale do not provide equivalent accessible descriptions of plotted dates/values.

**Fix direction:** Use named Material controls with minimum 48-pixel targets, keyboard/focus support, selected semantics for units, calendar tooltips, and readable chart summaries. Preserve a single semantic action per control.

### M6 — BMI scale labels do not align with the scale's numeric positions

**Source:** `report_page.dart` `_BmiScaleBar` labels near line 1466 and `_ScaleBarPainter` mapping near line 1511.

The painted bar and pointer map BMI linearly over 15–40. The labels `15, 16, 18.5, 25, 30, 35, 40` are arranged using a Row with `spaceBetween`, despite their unequal numeric gaps. For example, the pointer for 25 is at 40% of the bar, while the fourth label sits roughly near the middle.

**Impact:** The visible scale can suggest a different numeric position from the pointer's actual value, even after the input-weight issue is fixed.

**Fix direction:** Position each label using the same numeric-to-pixel mapping as the bar and pointer, with responsive collision handling. Verify geometry at the displayed breakpoints. No change to clinical thresholds is proposed by this finding.

## Low finding

### L1 — Report-specific regression tests are missing

The permanent suite checks the Report navigation-tab label but has no Report-specific tests for aggregation, measurement persistence, BMI input consistency, All records, edit failure behavior or responsive sheets. This audit's harness is in ignored `build/`, not the permanent regression suite.

**Fix direction:** Retain focused tests with seeded persisted data and failed writes when correcting these flows. Include save/cancel/reopen, unit conversion, calendar preference/rollover and large-text/landscape behavior.

## Recommended fix order

1. **H1/H4:** Connect totals, streak, completed-day markers and All records to the existing persisted workout history.
2. **H2/H3:** Replace sample measurements with a canonical, decimal, dated measurement store and consistent BMI inputs.
3. **M1/M2/M3:** Make saves durable/retryable and unify unit/calendar/date behavior.
4. **M4/M5/M6:** Repair responsive layouts, accessible controls and scale geometry.
5. **L1:** Retain regression tests for the corrected behavior.

## Limits and local evidence

Evidence: `build/report_audit_test.dart` and `build/report-audit-results.json`. The harness's seven scenarios completed; recorded rendering failures are included above. Temporary files may be removed by a clean build.

This was source plus widget-level verification. It did not include physical-device assistive-technology testing, APK installation, injected storage failures, or medical validation of BMI categories. No production fixes or health recommendations were made.
