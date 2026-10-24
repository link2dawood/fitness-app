# Full-app H1 — Durable workout history retries

History loads and completion deduplication now reload the backing preferences store before reading. A cached value from a failed write cannot be mistaken for a durable completion. Failed writes also attempt to restore the preferences cache, preserve the original write error, and leave observable entries unchanged. If recovery reload fails, later operations must still reload successfully before trusting any cached value.

Loads and writes share the repository's operation queue. Refreshes wait for pending commits, and failures do not poison the queue. A repeated ID already present in durable storage refreshes the repository's observable snapshot without another write; a failed ID absent from storage is written again on retry.

Seven permanent tests in `test/training_history_durability_test.dart` cover false and thrown write failures, reload/retry/fresh-cache persistence, concurrent duplicate retries with another session, load ordering during a delayed write, failed recovery reads, durable deduplication, and preservation of corrupt data. Session counts, recorded seconds, weekly days, and streaks are checked against successfully saved records.

Scope: the shared Training/Discover/Report workout completion repository. Other full-app audit findings and other repositories are separate work.

Validation: all **154 permanent tests passed**; static analysis of `lib` and `test` found **no issues**.
