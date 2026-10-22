# Report medium findings resolution

## M2 — Shared units

Report renders saved height in centimeters or feet/inches according to `GeneralSettings.heightImperial`, and weight according to its shared preference. Unit switches in both measurement sheets are explicitly labeled as temporary picker units. They change input presentation only; saving or cancelling cannot change Report's or General Settings' units. Shared settings changes rebuild Report.

## M3 — Dates and week starts

Report and the persisted history calendar use `TrainingCalendar` and the saved profile week-start preference. `DateRolloverBuilder` rebuilds retained screens and open measurement sheets at local midnight and on resume, with timer/observer cleanup on disposal. Weight dates are evaluated again at submission. Chart month and weekly dates therefore refresh across day, week, month, and year boundaries. History follows today's date when viewing today; historical selections and historical month browsing remain unchanged.

## M4 — Responsive layouts

Summary statistics, weight extremes, BMI category, section headings, and height controls use flexible/wrapped layouts. Report's week columns share available width; date numbers scale down within their cells. Measurement sheets scroll within short viewports, and their actions grow with text instead of using a fixed height. The shared calendar uses proportional columns and scrolling content, including its error/retry state.

Real-font layout checks cover 390×844, 320×640, 844×390, and 768×1024, including 200% text on narrow and landscape screens. They exercise Report, both pickers, and All records and verify that sheet actions remain reachable.

## M5 — Accessibility

Log, All records, height editing, unit selection, Save, and Cancel use Material buttons. Main actions have minimum 48-pixel targets, keyboard/focus support, and named semantics; unit controls expose selected state. Shared calendar controls have tooltips. Weight chart semantics describe full dates, values, and displayed units; BMI scale semantics describe its value, range, and numeric markers.

## M6 — BMI geometry

`BmiScaleBar` uses one `BmiScaleGeometry.fraction` mapping for labels, colored segment boundaries, and the pointer. Labels are centered on their numeric positions; overlapping labels move to additional rows. Endpoint padding accommodates label widths. Existing numeric thresholds are unchanged. Geometry tests check every marker at three widths and two text scales, including BMI 25 at 40% of the track.

## Validation

`test/report_medium_test.dart` contains 18 regression checks covering units, real-font layouts, midnight/year/resume changes, historical selection retention, keyboard activation, semantics, and numeric label geometry. Existing persistence and save-failure coverage remains in place.

Full suite: **147 tests passed**. Static analysis of `lib` and `test`: **no issues found**. The 18 medium regression checks also passed after the final font-metric alignment adjustment.
