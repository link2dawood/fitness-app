# Remaining Search badge audit — 2026-11-02

Scope: Butt & Leg, Chest, Back and Shoulder. Audit only; no production code changed during this review.

## Result

All four badges open their dedicated results screen. All 41 rows open a workout detail with a Start workout action; every referenced catalog ID, exercise ID and thumbnail file resolves. These checks did not run all 41 complete exercise sessions.

| Badge | Rows | Distinct destinations within badge | Rows with incorrect duration and/or count | Missing thumbnails |
| --- | ---: | ---: | ---: | ---: |
| Butt & Leg | 21 | 18 | 21 | 0 |
| Chest | 10 | 7 | 10 | 0 |
| Back | 4 | 4 | 4 | 0 |
| Shoulder | 6 | 6 | 6 | 0 |

## H1 — All 41 rows advertise metadata different from the opened routine

Source: `lib/views/search/body_focus_results_view.dart` (`WorkoutEntry` catalog and card subtitle around line 497); `TrainingWorkout.estimatedMinutes` derives duration from targets and rest.

The list hardcodes duration and exercise counts separately from the playable catalog. Examples: Leg Beginner advertises 23 minutes / 23 exercises but opens 5 minutes / 6 exercises; Shoulder & Back Beginner advertises 15 / 17 but opens 5 / 6. Durations below use the model’s default rest assumptions; global session settings can change elapsed time further.

Fix: derive list metadata from the same workout as its destination, or implement/version the intended longer routines before advertising those values.

## H2 — Six pairs of differently named rows share routines and progress

Source: `bodyFocusWorkouts` mappings and `_resolveWorkout()` around line 420; `TrainingWorkout.progressStorageKey` in `lib/data/models/training_workout.dart`.

The following are aliases within a single badge, rather than distinct workout plans:

- Butt & Leg: Butt Blaster Challenge / Intense Leg Power Challenge → `lower_body_challenge`.
- Butt & Leg: 10 Min Butt Workout / Shape and Tighten Butt → `legs_glutes`.
- Butt & Leg: Rounder Booty Shaping / Booty Shaping & Butt Lifting → `rounder_booty_shaping`.
- Chest: Chest Intermediate / Get Rid of Man Boobs HIIT - intermediate → `chest_intermediate`.
- Chest: Chest Advanced / Get Rid of Man Boobs HIIT - advanced → `chest_advanced`.
- Chest: Killer Chest Workout / Killer Chest Routine → `killer_chest_routine`.

Each pair opens the same exercise sequence and uses the same progress key. For example, Killer Chest Workout advertises 29 minutes / 25 exercises and Killer Chest Routine advertises 9 / 8, but both open the same 7-minute / 10-exercise routine. Sharing Shoulder & Back routines between Back and Shoulder is intentional category reuse and is not counted as a duplicate defect.

Fix: provide distinct stable IDs and real routines where the products are intended to differ; otherwise retain one canonical row or explicitly identify an alias.

## M1 — Some labels overstate the specificity of their exercise mix

Source: mapped routines in `lib/data/models/training_workout.dart`.

Examples: Build Wider Shoulders - advanced includes Squat Reach Ups, Star Jumps, Squat Jacks, Slow Mountain Climber and Toy Soldiers; the list implies a shoulder-specific strength routine while the content is a broad conditioning mix. Leg Workout (No Jumping!) resolves to Lose Fat (No Jumping!), including V-hold, Wide Arm Push-ups and Windshield Wipers alongside lower-body work. This is an editorial content-match finding, not a clinical effectiveness assessment.

Fix: review the actual sequences against each title and difficulty; replace inappropriate entries or use accurate mixed-workout labels.

## M2 — Resolver can silently substitute an unrelated workout on missing data

Source: `_resolveWorkout()` around lines 420–449.

Resolution checks display title before stable ID, and if neither resolves it constructs a new ID using `trainingWorkouts.first.exerciseIds`. All current 41 IDs resolve, so this fallback was not triggered in this audit. A future typo/removal can nevertheless open an unrelated routine instead of showing an unavailable state.

Fix: resolve by required stable ID only; surface an explicit missing-workout state and keep titles/images/metadata authoritative.

## Verification

Flutter widget audit opened all four badges and all 41 row destinations, checked the Start action, catalog/exercise references, thumbnail presence, default computed durations/counts and progress keys. Audit passed its navigation/integrity checks; discrepancies are findings above, not asserted away. No APK/device test or full session replay was performed.

## Row-by-row metadata evidence

| Badge | Listed workout | Listed min / exercises | Opened min / exercises | Destination ID |
| --- | --- | ---: | ---: | --- |
| Butt & Leg | Leg Beginner | 23 / 23 | 5 / 6 | `leg_beginner` |
| Butt & Leg | Leg Intermediate | 31 / 36 | 6 / 8 | `leg_intermediate` |
| Butt & Leg | Leg Advanced | 40 / 43 | 7 / 10 | `leg_advanced` |
| Butt & Leg | Lower Body Strength | 22 / 27 | 6 / 8 | `lower_body` |
| Butt & Leg | Leg Workout (No Jumping!) | 13 / 13 | 6 / 8 | `lose_fat_no_jumping` |
| Butt & Leg | Butt Blaster Challenge | 21 / 25 | 6 / 8 | `lower_body_challenge` |
| Butt & Leg | Intense Leg Power Challenge | 21 / 25 | 6 / 8 | `lower_body_challenge` |
| Butt & Leg | 10 Min Butt Workout | 10 / 12 | 6 / 8 | `legs_glutes` |
| Butt & Leg | Bigger Strong Quads Leg Workout | 11 / 12 | 6 / 8 | `bigger_strong_quads_leg_workout` |
| Butt & Leg | Shred Your Quads | 19 / 22 | 6 / 8 | `shred_your_quads` |
| Butt & Leg | Intense Leg Transformation | 31 / 30 | 7 / 10 | `intense_leg_transformation` |
| Butt & Leg | 10 Min Leg Workout | 10 / 12 | 6 / 8 | `10_min_leg_workout` |
| Butt & Leg | Butt Lift & Rounder Booty | 9 / 9 | 6 / 8 | `butt_lift_rounder_booty` |
| Butt & Leg | Rounder Booty Shaping | 20 / 23 | 6 / 8 | `rounder_booty_shaping` |
| Butt & Leg | Strong Legs Routine | 13 / 12 | 6 / 8 | `strong_legs_routine` |
| Butt & Leg | Shape and Tighten Butt | 14 / 15 | 6 / 8 | `legs_glutes` |
| Butt & Leg | Bubble Butt Workout | 12 / 13 | 6 / 8 | `bubble_butt_workout` |
| Butt & Leg | Booty Shaping & Butt Lifting | 30 / 32 | 6 / 8 | `rounder_booty_shaping` |
| Butt & Leg | Butt Beginner | 15 / 15 | 4 / 6 | `butt_beginner` |
| Butt & Leg | Butt Intermediate | 19 / 17 | 6 / 8 | `butt_intermediate` |
| Butt & Leg | Butt Advanced | 21 / 18 | 7 / 10 | `butt_advanced` |
| Chest | Chest Beginner | 9 / 11 | 4 / 6 | `chest_beginner` |
| Chest | Chest Intermediate | 13 / 14 | 6 / 8 | `chest_intermediate` |
| Chest | Chest Advanced | 18 / 16 | 7 / 10 | `chest_advanced` |
| Chest | Killer Chest Workout | 29 / 25 | 7 / 10 | `killer_chest_routine` |
| Chest | Get Rid of Man Boobs HIIT - beginner | 17 / 19 | 4 / 6 | `beginner_chest_sculpt` |
| Chest | Get Rid of Man Boobs HIIT - intermediate | 18 / 19 | 6 / 8 | `chest_intermediate` |
| Chest | Get Rid of Man Boobs HIIT - advanced | 22 / 25 | 7 / 10 | `chest_advanced` |
| Chest | Quick Bigger Chest Building | 11 / 12 | 6 / 8 | `quick_bigger_chest_building` |
| Chest | Beginner Chest Workout | 7 / 8 | 4 / 6 | `beginner_chest_workout` |
| Chest | Killer Chest Routine | 9 / 8 | 7 / 10 | `killer_chest_routine` |
| Back | Shoulder & Back Beginner | 15 / 17 | 5 / 6 | `shoulder_back_beginner` |
| Back | Shoulder & Back Intermediate | 19 / 17 | 5 / 8 | `shoulder_back_intermediate` |
| Back | Shoulder & Back Advanced | 21 / 17 | 6 / 10 | `shoulder_back_advanced` |
| Back | Beginner Back Builder | 16 / 12 | 4 / 6 | `beginner_back_builder` |
| Shoulder | Shoulder & Back Beginner | 15 / 17 | 5 / 6 | `shoulder_back_beginner` |
| Shoulder | Shoulder & Back Intermediate | 19 / 17 | 5 / 8 | `shoulder_back_intermediate` |
| Shoulder | Shoulder & Back Advanced | 21 / 17 | 6 / 10 | `shoulder_back_advanced` |
| Shoulder | Build Wider Shoulders - beginner | 15 / 15 | 6 / 8 | `build_wider_shoulders` |
| Shoulder | Build Wider Shoulders - intermediate | 17 / 20 | 6 / 8 | `build_wider_shoulders_intermediate` |
| Shoulder | Build Wider Shoulders - advanced | 26 / 26 | 7 / 10 | `build_wider_shoulders_advanced` |
