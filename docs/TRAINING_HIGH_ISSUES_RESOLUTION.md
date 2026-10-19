# Training high issues — implementation notes

## Workout execution

`lib/data/models/training_workout.dart` defines 81 routines with explicit, stable
exercise IDs referencing the existing original-avatar library. Counts and estimated
times derive from those entries; estimates assume about three seconds per rep and
include inter-exercise rest. Unsupported placeholder programs such as Height
Increase and Kegel are not advertised as runnable routines without matching
exercise content. Routine titles no longer promise a fixed minute count that
disagrees with the actual exercise list.

Training cards, Challenge (including category filters), Popular Goals, Just For
You, Stretch & Warm Up, and search results use shared workout tiles and open the
same workout detail/session flow. The custom workout list also has a Start action.
Custom sequences preserve duplicate exercises, individual targets, and rest values.

Sessions show the original animations and rep/time targets, enforce timed intervals,
offer rest and skip-rest, and support pause/resume. Backgrounding pauses the session;
returning requires an explicit Resume. Rep exercises are confirmed by the user.
Leaving an unfinished session requires confirmation and creates no completion.

After the last exercise, Save completion writes the result. The user sees Progress
saved only after storage succeeds. A failed save leaves a retry action. Session IDs
prevent duplicate credits, writes are serialized, and existing corrupt history is
not silently overwritten. Completion timestamps reflect the end of the exercise
sequence, even if saving is retried later.

## Search

`TrainingSearch.results` combines case-insensitive query tokens with focus,
difficulty, type, and computed-duration predicates. Search displays matching counts
and real workout rows, an empty state, clear-search, and clear-all. Training's
workout-type shortcuts open this search with a query. This is separate from the
custom workout Add Exercises filters, which remain in place.

## Progress and history

`TrainingHistoryRepository` persists `training_completions_v1` in SharedPreferences.
Weekly progress counts distinct completed local dates, rather than counting two
sessions on one day as two workout days. Week start follows the saved Sunday/Monday
preference. Streaks include today when completed, or yesterday while today is still
available; a gap resets the streak. Training listens for repository updates so the
weekly count refreshes after saving without restarting the app.

The day-history sheet displays actual sessions and durations and allows selecting
another date. Unavailable/corrupt history is shown as an error with retry rather
than falsely claiming successful progress. Storage remains local; no cloud service
or credentials are required.

## Responsive behavior

Training now uses content-sized cards and wrapping sections instead of fixed-height
carousels. Its header actions remain reachable, calendar columns flex, category
chips wrap, and large-text workout cards give titles the full available width.
Home navigation gives each tab a flexible share of the available width.

## Verification

- Full application and new test-file analysis: no issues.
- Full automated suite: 48 tests passed.
- Additional Training layout harness: all 3 screen/text-scale scenarios passed,
  capturing zero framework/layout errors in each scenario.
- Existing settings, exercise picker/details, and custom editing tests still pass.
- New tests cover valid catalog references, search combinations/empty state,
  history persistence/deduplication/concurrent writes, distinct-day counting,
  streak/week boundaries, corrupt-storage preservation, new-user zero state,
  immediate weekly updates, detail → Start navigation, leaving without credit,
  custom targets/rest, timed completion guards, pause/resume/background handling,
  and persisted session completion.

The layout harness is `tool/training_page_audit.dart`; latest evidence is under
`build/training-audit`. Native device/release APK validation was not performed in
this task. The session player provides exercise timing and confirmation; automatic
rep sensing, music playback, and spoken coaching are not part of this change.
