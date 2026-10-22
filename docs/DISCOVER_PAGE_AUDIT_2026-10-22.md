# Discover page audit

**Date:** October 22, 2026, Asia/Karachi  
**Result:** Discover renders its content, but its main workout and collection actions are not implemented.  
**Findings:** 2 High, 5 Medium, 1 Low. No critical compilation defect found in the reviewed page.

This is a report-only review. Discover production code was not changed. Existing Training card edits were left intact.

**Subsequent resolution:** H1 and H2 were implemented on October 22, 2026. See `DISCOVER_HIGH_ISSUES_RESOLUTION.md`. Findings below describe the audited state before those fixes.

M1 and M3 were subsequently resolved on October 22, 2026. See `DISCOVER_HISTORY_METADATA_RESOLUTION.md` for persisted history, failure/retry behavior and authoritative workout metadata.

M2 and M5 were subsequently resolved on October 22, 2026. See `DISCOVER_LAYOUT_ACCESSIBILITY_RESOLUTION.md` for responsive layouts, accessible controls and verification. Permanent Discover tests now also cover the original L1 regression-coverage gap.

M4 was subsequently resolved on October 22, 2026. See `DISCOVER_PICKS_RESOLUTION.md`: actual profile-based ranking is used when possible, with explicit Featured workouts labeling otherwise.

L1 is retained in three permanent suites with 40 Discover tests, including all-placement navigation and real Search routing. See `DISCOVER_REGRESSION_COVERAGE.md` for the coverage matrix and commands.

## Scope and verification

Reviewed all nine sections: hero, Picks for you, Stay active, For beginners, Fast workout, Challenge, With Equipment, Stretch, and Body focus. Traced every card component's callback, the toolbar actions, Search routing, Home integration, catalog metadata, asset references, and semantics.

Ran static analysis of `discover_page.dart`: **no issues found**. Ran seven diagnostic scenarios covering five viewport/text configurations, navigation/semantics, and asset/catalog inspection. The diagnostic harness deliberately records rendering errors rather than failing immediately; its successful completion does **not** mean the page passed all checks.

Used a real Arial text font to avoid treating Flutter's placeholder test-font wrapping as a device defect. Scrolled the vertical page and sampled the middle/end of each horizontal carousel. This is sampled widget-level verification, not a physical-device, TalkBack, performance, or pixel-perfect visual certification.

| Configuration | Rendering diagnostics |
| --- | --- |
| 390×844, 100% text | None |
| 320×640, 100% text | None |
| 320×640, 200% text | 15 overflow events across four layout families; includes repeated instances |
| 844×390 landscape, 100% text | None |
| 768×1024 tablet, 100% text | None |

All **26 unique image paths** referenced by Discover exist. Search opens `SearchView`. The hero and history action remain on Discover after tapping, as their callbacks predict.

## High findings

### H1 — Workout cards never open a workout

**Source:** `lib/views/home/pages/discover_page.dart`, lines 205, 387, 556, 731, 849, 1083.

The hero and every workout item in Picks for you, For beginners, Fast workout, Challenge, and Stretch execute only `HapticFeedback.selectionClick()`. They have no workout ID, navigation, detail opening, or start action. Across the source lists this affects **45 displayed workout placements**, including repeated titles.

**Reproduce:** Open Discover and tap the hero or a workout in any of these six sections. The device may vibrate, but the screen does not change. The hero behavior was also exercised in the navigation audit.

**Impact:** Discover cannot serve its primary purpose of opening and starting a selected workout. Exercise demonstrations, sessions, saved progress and completion cannot be reached through these cards.

**Recommended fix:** Bind each item to a verified catalog ID or an explicitly implemented challenge, then open the corresponding detail/session flow. Resolve the intended routine for cards whose display title is an alias; do not select a routine by a loose title match.

### H2 — Collection and body-focus entry points do nothing

**Source:** `lib/views/home/pages/discover_page.dart`, lines 442, 901, 1182.

Stay active, the With Equipment banner/“Let's Go!” action, and all four Body focus cards also execute only haptic feedback. The `type` values on Body focus are used for artwork, not filtering. “5 workouts” in the promo is a static label with no linked collection.

**Reproduce:** Tap Stay active, Let's Go!, Chest, Arm & Shoulder, Butt & Leg, or Six pack. No collection or filtered results opens.

**Impact:** Six collection entry points are misleading and unusable.

**Recommended fix:** Create explicit collection definitions and equipment/focus predicates, navigate to their real results, and derive the promo count from that collection.

## Medium findings

### M1 — History toolbar action has an empty callback

**Source:** `lib/views/home/pages/discover_page.dart:49`.

`onPressed: () {}` presents an enabled history action that never opens history. The tap audit confirmed no navigation or dialog.

**Recommended fix:** Connect it to the existing persisted Training history view, including loading failure/retry and the empty-history state.

### M2 — Fixed card heights break at 200% text

**Source:** `lib/views/home/pages/discover_page.dart`, lines 323/345, 667/689, 1048/1057, and 1155/1203.

Picks for you and Fast workout force two variable-height rows into a 190-pixel carousel. Stretch forces two cards into 330 pixels. Body focus uses a fixed grid aspect ratio with a padded column. These constraints do not grow with text.

**Reproduce:** Use a 320×640 viewport with 200% text, then scroll the page/carousels. With a real font, the audit recorded:

- Picks for you and Fast workout: up to **155 pixels** of bottom overflow.
- Stretch: **30 pixels** of bottom overflow.
- Body focus: up to **68 pixels** of bottom overflow.

**Impact:** Enlarged text and card contents can overlap or be cut off. Normal-size sampled configurations did not produce these diagnostics.

**Recommended fix:** Use content-driven row/card heights, responsive text layouts and an accessible grid/list arrangement. Verify all carousel pages, not only the first visible pair.

### M3 — Duration labels disagree with the workout catalog

**Source:** `lib/views/home/pages/discover_page.dart`, lines 286–311 and 606–607; catalog estimates in `lib/data/models/training_workout.dart`.

Discover keeps separate title/subtitle maps instead of using the workout model. Current examples:

| Workout | Discover label | Catalog estimate |
| --- | --- | --- |
| Build Wider Shoulders | 17 min | ~6 min |
| Fat Burning HIIT | 14 min | ~6 min |
| Before Workout Warm-Up | 5 min | ~4 min |

Fast workout also contradicts itself: “7 Min HIIT Fat Burning” displays 8 min, and “10 Min Abs Workout” displays 9 min. Catalog estimates include the model's assumed rep pace and rest; these are comparisons of app metadata, not measured exercise times.

**Impact:** Users cannot reliably choose a routine that fits their available time. Wiring navigation alone would expose different metadata on the destination screen.

**Recommended fix:** Resolve stable IDs first, then derive duration and difficulty from the same model as the destination. Keep any editorial duration claim consistent with the actual plan definition.

### M4 — “Picks for you” ignores the user's profile

**Source:** `lib/views/home/pages/discover_page.dart:271`; integration in `lib/views/home/home_view.dart:22`.

The section is a static const list. Discover does not read a profile, fitness level, goal, focus areas or recommendation service. Every user receives the same items and order, including intermediate routines.

**Reproduce:** Compare users with different onboarding goals/levels. Discover's selection cannot change because there is no profile input or recommendation lookup.

**Recommended fix:** Use the existing profile-based recommendation service, or rename the section to describe editorial picks accurately. Define a fallback for a missing profile.

### M5 — Toolbar labels and actionable-card semantics are incomplete

**Source:** `lib/views/home/pages/discover_page.dart`, lines 32, 43 and the GestureDetector card callbacks.

Both toolbar `IconButton` tooltips are null. Card gestures are not exposed through explicit button semantics. The sampled hero semantics contains a tap action and `isImage`, but no button role. The equipment CTA is a styled Container, not an independent semantic button.

**Impact:** Assistive technology lacks clear names/roles for some primary actions; keyboard users also do not receive standard button behavior from bare gesture detectors.

**Recommended fix:** Add Search/Workout history labels and use standard Material buttons or explicitly labeled button semantics with focus/keyboard support. Avoid duplicate semantic actions for a single card.

## Low finding

### L1 — Discover-specific regression coverage is missing

**Evidence:** Existing tests reference the Discover navigation tab, but there is no committed Discover page test covering its card navigation, collection filters, metadata, or responsive layouts. The investigation harness created for this review is under ignored `build/`, not part of the permanent suite.

**Impact:** Placeholder callbacks and layout regressions can remain undetected while the existing suite passes. This is a test-coverage finding, not a separate runtime failure.

**Recommended fix:** When implementing the fixes, add focused tests proving actual destinations, catalog-derived labels, history behavior and large-text layouts. Do not treat a successful page build as proof that its actions work.

## Additional observations, not counted as defects

- `MuscleSilhouettePainter.shouldRepaint` always returns false (`discover_page.dart:1342`). Its current four card types are static, so no current visible failure was established. If cards become reusable/filterable, compare the old and new `type` to avoid stale artwork.
- The main sliver contains one large Column of all sections. Lazy section construction may help as content grows, but frame-time/memory profiling was not performed; no performance defect is claimed.
- No runtime failure from a missing Discover image was found. The existing Search route is present and opens correctly.
- On-device notification, audio, workout execution and completion behavior cannot be exercised through Discover while its workout callbacks remain disconnected. This audit does not imply those downstream systems were validated again.

## Suggested implementation order

1. H1 and H2: establish stable workout/collection IDs and real destinations.
2. M1 and M3: wire persisted history and authoritative metadata.
3. M2 and M5: fix responsive layouts and accessible controls.
4. M4: implement profile-based picks or honest editorial labeling.
5. L1: retain regression coverage for the corrected flows.

Diagnostic evidence: `build/discover_audit_test.dart` and `build/discover-audit-results.json`. These files are local audit artifacts and may be removed by a clean build.
