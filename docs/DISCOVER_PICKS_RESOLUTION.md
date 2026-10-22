# Discover M4 resolution

**Date:** October 22, 2026.

Discover now uses `TrainingRecommendations.forProfile`, shared with Training and Just For You. The section displays the top seven ranked catalog workouts, grouped in pairs, with the existing responsive, accessible card component.

The shared ranking considers fitness level, selected focus areas and goal. It excludes routines above the user's chosen difficulty level. Selected cards retain stable workout IDs and use the selected routine's image, title and metadata.

## Profile sources and honest labels

- Inside Home, the section observes `HomeViewModel` and updates when its loaded profile changes.
- When Home has not loaded a profile, or Discover is opened independently, it loads the persisted onboarding profile. Independent entry also refreshes that stored profile when the app resumes.
- A usable profile produces **Picks for you** with actual ranked recommendations.
- Missing/incomplete profiles, including those without a fitness level, produce **Featured workouts** using the editorial catalog selection and an explanation that a fitness profile is needed for personalized picks.
- Loading keeps editorial content available with a progress indicator. A profile-reading failure keeps the honest Featured label, explains the failure, and offers **Retry personalized picks**. Retrying does not modify the saved profile.

The fallback is deliberately editorial; it does not claim the static selection is tailored to the user. No new ranking rules, remote service, account requirement or permissions were introduced.

## Verification

Full regression suite: **109 tests passed**. Static analysis of `lib` and `test`: **no issues found**.

Nine new tests cover persisted beginner/advanced profiles, equality with the shared ranking, difficulty eligibility, real card destinations, missing and incomplete profiles, live Home profile updates, corrupt-data retry, standalone resume refresh, a narrow 200%-text layout, and error recovery while Home is still loading.

The existing navigation, persisted history, responsive layout and accessibility tests also pass with the editorial fallback.

Production change: `lib/views/home/pages/discover_page.dart`. Permanent tests: `test/discover_picks_test.dart`.
