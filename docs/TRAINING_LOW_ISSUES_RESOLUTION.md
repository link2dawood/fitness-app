# Training low findings — resolution

All three low findings from the Training audit are addressed.

Subsequent design direction: the user requested the original detailed Training
cards again. Challenge, Custom Workout, Recommended, Stretch & Warm Up, and
Explore cards now intentionally retain their earlier photo/gradient presentation,
including blue/cyan/purple promotional colors. Shared onboarding-green controls
and the functional/accessibility fixes remain in place. These card colors are an
explicit design choice, rather than an accidental theme fallback.

| Finding | Result |
| --- | --- |
| L1: inconsistent blue accent | Training and navigation use the shared onboarding-green token. The shared ColorScheme now also defines green secondary/container colors, and ChipTheme supplies green selected states so filter/category chips do not inherit an unrelated default accent. |
| L2: icon labels and small targets | Training actions use named IconButtons. IconButtonTheme enforces a 48×48 minimum. Workout cards expose one descriptive, tappable screen-reader button containing title and workout metadata. Navigation exposes named, selected tabs with semantic activation and at least 48-pixel height. |
| L3: analyzer maintenance lints | The prior Training `withOpacity` calls and old Challenge constructor were removed during the earlier fixes. Current full-library analysis and accessibility-test analysis report no issues; no obsolete calls were reintroduced. |

## Verification

- Three new accessibility tests verify named icon buttons, button semantics,
  48-pixel icon/navigation targets, screen-reader workout activation, tab
  activation, and selected-tab announcements.
- Full regression suite: 60 tests passed.
- The Training layout harness passes all three prior screen/text-scale scenarios
  with zero framework/layout errors, including the narrow screen and 200% text.
- Full application and new test-source analysis: no issues.

These are Flutter semantics and layout checks, not a physical-device TalkBack or
VoiceOver certification. The changes retain the original onboarding green
(`AppColors.primary`), while using readable dark labels on softly tinted chips.

Key files: `lib/core/theme/app_theme.dart`, `lib/views/home/home_view.dart`,
`lib/views/home/pages/training_collection_page.dart`, and
`test/training_accessibility_test.dart`.
