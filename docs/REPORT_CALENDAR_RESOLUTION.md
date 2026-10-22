# Report H4 resolution

Replaced Report's disconnected calendar implementation with the shared `PersistedTrainingHistorySheet`, hosted by the existing `HistoryCalendarView` route. All records now reloads persisted completions and the profile's saved week-start preference before rendering the calendar.

The shared flow marks full local calendar dates, supports month navigation and date selection, and lists each selected day's sessions with recorded minutes, seconds, and completion time. Loading, failed load with Retry, and successful empty-day states remain distinct. The close control returns to Report.

Regression tests in `test/report_calendar_test.dart` enter through Report's actual All records action and cover multiple sessions, precise durations, prior-month selection, empty days, saved Monday-first preference, return navigation, corrupt storage preservation, and retry recovery. Existing Discover navigation/history tests validate the same shared flow.
