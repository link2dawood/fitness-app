# Report H3 resolution

Weight logs now persist under `weight_history_v1` through `WeightHistoryRepository`. Records contain decimal kilograms and a local calendar date (`YYYY-MM-DD`), independent of display units. Logging again on the same date replaces that date's record; different months and years remain separate. Writes are serialized and storage failures are surfaced without replacing observable records.

Report loads records on entry and on app resume, with loading and retry states. Current weight and BMI use the latest dated record when present, otherwise the saved profile. Heaviest/lightest use all actual records; the chart displays only records from the current month. No dated record is manufactured from a profile value.

The profile accepts both legacy integer and decimal weights. Report preserves picker precision (kilogram conversion normalized to four decimal places) and awaits history persistence, then explicitly synchronizes the profile. A profile-sync failure is identified separately and Save retries the idempotent same-date write. The history remains authoritative if profile synchronization fails. Cancel and picker changes do not write either store.

Tests cover decimal round trips, calendar-date identity and replacement, corrupt history preservation, legacy profiles, saving 72.6 kg through the actual picker, cancellation, and page recreation. Historic logs lost before this fix cannot be reconstructed.
