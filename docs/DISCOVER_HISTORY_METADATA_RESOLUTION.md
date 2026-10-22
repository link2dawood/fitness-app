# Discover M1 and M3 resolution

**Date:** October 22, 2026.

## M1 — Persisted history

The Discover history toolbar button opens the existing history calendar through a storage-loading wrapper. It reloads persisted completions every time the sheet opens, so it works even when entered without an already loaded Home view model and reflects sessions saved since the previous opening.

The wrapper loads the saved first-day-of-week preference, defaults to Sunday when no profile exists, and displays a loading indicator. Storage or profile parsing failures produce a closable error view with Retry instead of presenting stale data or a misleading empty history. Loading/retrying never overwrites the stored records.

Once loaded, the shared history view shows completed dates, selected-day workout titles, actual recorded durations and times, or the genuine empty-day state. Existing Training history entry points retain their current behavior.

## M3 — Authoritative metadata

All Discover workout placements already resolve stable catalog IDs after the H1/H2 changes. This change completes the remaining metadata work:

- The hero title and summary now come from its actual destination workout rather than copied display text.
- Picks and Fast workout share `TrainingWorkout.durationAndLevel` for estimated minutes and difficulty.
- The hero, detail page and collection results use the workout model's summary, including exercise count.
- Other workout card titles continue to come from their destination models. Stay active's count continues to come from its actual collection.

Thus edits to a routine's title, targets, rest, exercise list or level are reflected through the same model. Time is an estimate using the catalog's existing timed-target/rep-pace calculation; it is not substituted for a completed workout's recorded elapsed time in history.

## Verification

Full regression suite: **89 tests passed**. Static analysis of `lib` and `test`: **no issues found**.

Four additional Discover tests cover:

1. Loading a persisted completion without preloading the in-memory repository, including saved Monday calendar preference and recorded duration.
2. A real empty-history state and refreshed data on reopening.
3. Corrupt storage, preservation of the original value, and successful retry after recovery.
4. Hero/card metadata matching the destination and the shared formatter resolving across all 45 placements.

The remaining responsive layout, profile-based recommendation and card accessibility findings are outside this change.

Subsequent update: M2 and M5 were resolved separately; see `DISCOVER_LAYOUT_ACCESSIBILITY_RESOLUTION.md`.
