# Training medium findings — resolution

All five medium findings from the 19 October 2026 audit are addressed.

| Finding | Result |
| --- | --- |
| M1: weekly goal cannot be edited | An Edit weekly goal action opens a draft editor for 1–7 workout days and Sunday/Monday week start. Save persists before updating the displayed goal; Cancel discards edits. Failed saves retain the draft and offer retry. |
| M2: history has no activity/day details | The month calendar marks completed days. Selecting a date shows actual locally saved workout names, completion times, and durations, or a clear empty state. Month navigation and live repository updates are supported. |
| M3: first-day preference is ignored | Weekly strip and history grid share `TrainingCalendar`. Both honor the saved Sunday/Monday preference, and weekly completion counting uses the same boundary. The editor exposes this preference after onboarding. |
| M4: recommendations/customized cards are static | A shared ranking method uses fitness level, goal, and focus areas. Recommended, Just For You, and the Customized for you cards in Training and Challenge use the same ordered results. Missing fitness level/profile gets a neutral setup message. |
| M5: request actions do not collect feedback | Training and Search both open the existing feature-suggestion form, including the Others text field. Successful submission confirms that the request was saved locally. No external delivery is claimed or required. |

## Persistence and profile handling

Training preference saves merge the latest persisted profile to preserve gender,
level, focus, goal, and other demographic edits. They do not mark onboarding as
complete. The ViewModel updates its profile only after storage succeeds.

Personalization excludes workout difficulty above the user's level, then ranks
by focus coverage, goal relevance, and matching level, with stable ID ordering for
ties. Easier routines remain eligible, particularly for stretching or staying fit.
The Just For You and Challenge routes receive the current profile from Training;
when opened independently, they load the persisted profile and handle load errors
with retry instead of assuming a level.

History uses local calendar dates derived from saved completion timestamps.
Calendar cells have selected-date and workout-completion semantics; weekday
headers and date cells adapt to narrow widths and enlarged text.

## Verification

- Nine new tests cover profile preservation, validation, onboarding-state
  preservation, failed-save retry, cancellation, immediate goal updates, calendar
  week/month alignment, leap/year boundaries, real day-history contents/durations,
  empty states, profile-based ordering, consistency across all personalized entry
  points, feature-request persistence from both pages, and enlarged-text layouts.
- The existing Training screen harness continues to pass at 390×844 and 320×640
  with normal text and at 390×844 with 200% text: zero captured framework/layout
  errors in all three scenarios.
- Full app/test-source analysis: no issues.
- Full regression suite: 57 tests passed.

Key implementation files: `training_goal_sheet.dart`, `training_history_sheet.dart`,
`training_calendar.dart`, `training_recommendations.dart`,
`training_profile_builder.dart`, `onboarding_repository.dart`, and
`test/training_medium_test.dart`.
