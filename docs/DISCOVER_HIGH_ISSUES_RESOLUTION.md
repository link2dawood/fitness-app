# Discover H1 and H2 resolution

**Date:** October 22, 2026.  
**Scope:** Implement the two high findings from `DISCOVER_PAGE_AUDIT_2026-10-22.md`.

## H1 — Real workout destinations

- All 45 workout placements, including the hero and all carousel sections, resolve explicit IDs through `DiscoverCatalog`.
- Each card opens the existing `TrainingWorkoutPage` for that exact routine. Its Start action launches the existing session player, exercise demonstrations and completion flow.
- No title searching, fuzzy matching or fallback to the first workout is used. Unknown IDs fail explicitly and all configured IDs are validated by tests.
- Promotional titles without a matching implemented plan were replaced with the selected catalog routine's real name. For example, the hero now presents Beginner Chest Workout, and the former “12 Min Classic” placement presents Full Body Shred. These are available routines, not claims that the original advertised plans were recreated.
- Routine title, duration and difficulty come from the destination's model. Card images/layout styling remain in place.
- The full card rectangle accepts taps, including blank padding beside short text.

## H2 — Real collections

| Stable collection ID | Destination content |
| --- | --- |
| `stay_active` | Five explicitly selected warm-up/stretch routines |
| `with_equipment` | Catalog routines requiring equipment beyond a mat or no equipment |
| `focus_chest` | Routines whose exercise focus includes Chest |
| `focus_arm_shoulder` | Routines whose exercise focus includes Arm or Shoulder |
| `focus_glutes_leg` | Routines whose exercise focus includes Glutes or Leg |
| `focus_abs` | Routines whose exercise focus includes Abs |

Each entry opens `TrainingCollectionPage`, and each result opens its real workout detail. Collection routes carry `/discover/collection/<id>` as their route name. Focus filtering includes secondary exercise focus; the collection is not restricted to routines whose titles contain the body-area name.

The Stay active workout count is derived from the same collection that opens when tapped.

## Verification

- 14 new tests pass: all 45 IDs/images/exercise references resolve, all six collections are nonempty and unique, equipment/focus predicates hold, every workout-card component opens the expected routine, hero Start launches a session, and every collection opens its expected list and a working routine.
- Full regression suite: **85 tests passed**. Static analysis of `lib` and `test`: **no issues found**.

Production files: `lib/data/models/discover_catalog.dart` and `lib/views/home/pages/discover_page.dart`.

The remaining medium findings are not all resolved by this change. In particular, the history button, profile-based picks, large-text layout defects and accessibility work remain. Catalog-derived card metadata and these new navigation tests also address parts of the metadata/coverage findings.

Subsequent update: M1 (history) and M3 (metadata) are now resolved; see `DISCOVER_HISTORY_METADATA_RESOLUTION.md`. The paragraph above records the scope at the time of the H1/H2 fix.
