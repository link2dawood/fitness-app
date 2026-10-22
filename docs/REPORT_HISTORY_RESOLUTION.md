# Report H1 resolution

Report loads `TrainingHistoryRepository` independently and listens for persisted completion changes. Its all-time session count includes each completed session, and its duration sums recorded seconds before conversion to minutes. Exact minutes and seconds are also displayed.

The week strip uses `TrainingCalendar` and the profile's first-day preference. Completed dates use the repository's local-day normalization; the streak uses `TrainingHistoryRepository.streak`, including its yesterday fallback. Returning from the background reloads history and refreshes dates.

Loading, failure with Retry, and a successful empty history are separate states. Failed loads hide totals and completion markers instead of displaying stale data or empty-report zeros.

Calories display as unavailable, with an explanation that completion records do not contain calories. No calorie estimate is fabricated.

Regression coverage: `test/report_history_test.dart` exercises empty history, short-session aggregation, live persisted completion updates, date markers, streak behavior, corrupt storage, and retry recovery. Other Report audit findings remain outside this H1 change.
