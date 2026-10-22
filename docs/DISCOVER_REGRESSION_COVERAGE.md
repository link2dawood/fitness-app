# Discover L1 — Permanent regression coverage

**Date:** October 22, 2026.

The corrected flows are covered by standard Flutter tests under `test/`. These tests run with `flutter test`; they do not depend on the temporary audit harness or anything in `build/`.

**Verification:** all **111 tests passed** in the full suite, including **40 Discover tests**. Static analysis of `lib` and `test` found no issues.

| Suite | Tests | Coverage |
| --- | ---: | --- |
| `test/discover_navigation_test.dart` | 20 | All 44 carousel workout placements, hero detail/session launch, all six collections and result navigation, real Search routing, catalog IDs/assets, metadata, persisted history, empty state, reopening and corrupt-data retry |
| `test/discover_accessibility_test.dart` | 11 | Eight viewport/text/direction configurations, every carousel position, all 51 semantic buttons and minimum targets, semantic activation, Tab/Enter/Space including an offscreen collection |
| `test/discover_picks_test.dart` | 9 | Beginner/advanced persisted profiles, shared ranking and difficulty eligibility, editorial fallback, Home profile updates, retry, resume refresh and narrow-screen personalization |

The all-placement navigation regression now actually taps each of the 44 carousel placements—including duplicate routines shown in different sections and initially offscreen items—and checks its exact destination ID, metadata, Start action and return navigation. Merely building the page or validating an ID list does not satisfy that test. Missed taps are fatal in this scenario.

The Search regression uses the real app route, enters a query, scrolls to the lazily built result, opens the matching routine and returns through Search to Discover. Existing tests separately exercise the hero's session launch and collection destinations.

## Running the checks

From the project root:

```powershell
flutter analyze
flutter test
```

For Discover only:

```powershell
flutter test test/discover_navigation_test.dart test/discover_accessibility_test.dart test/discover_picks_test.dart
```

Layout exceptions fail the permanent tests. Optional screenshot export is separate from the pass/fail checks. The old investigation harness intentionally collected errors and is not used as the regression gate.

Coverage is widget/model-level; physical-device TalkBack/VoiceOver behavior and release APK installation are not certified by these tests. Production behavior was not changed for L1.
