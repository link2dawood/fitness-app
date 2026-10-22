# Report M01 resolution

Weight and height writes are awaited; both pickers reject duplicate submits while saving and retain their draft after failure. Height failures now show an inline retry message instead of escaping as unhandled errors. Weight history failures and profile-sync failures remain separately identified.

`HomeViewModel` publishes measurement changes only after a successful repository write. The repository merges the latest stored profile, serializes measurement writes, checks storage's boolean result, and leaves onboarding completion untouched. Missing profiles receive only the requested measurement; the other measurement remains unavailable. The explicit onboarding completion write also checks its result.

Profile and weight-history reads reload persisted preferences before decoding. This prevents failed writes left in the preferences cache from appearing as durable measurements after reopening or retrying.

`test/measurement_save_test.dart` injects false storage results and delayed writes to verify authoritative state, draft retention, retry, duplicate submit prevention, preserved history, and unchanged onboarding status.
