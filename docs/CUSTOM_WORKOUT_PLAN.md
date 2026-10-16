# Custom Workout — implementation plan

Date: 16 October 2026
Status: planning only; no app implementation changes made for this request.

## Feasibility

Yes. The Flutter application can support an exercise library with looping avatar demonstrations, search, body-area filters, exercise selection, an editable workout builder, and saved custom workouts.

The recording demonstrates appearance and behavior. It does not provide the original GIF files or complete animation loops for every exercise. The thumbnails could be rendered from GIFs, videos, or another animation system; their original format cannot be established from a screen recording alone.

For reference-quality avatar media, use supplied or licensed animation files, or create original animations. A consistent original 2D avatar is feasible; matching the reference's rendered character exactly would require suitable source artwork or a rig and animation assets. Begin with a small motion prototype before producing the whole set. Static AI-generated artwork alone is not a finished exercise animation.

## Existing project

- `lib/views/home/pages/custom_workout_page.dart` contains an empty state and a creation sheet with workout name and difficulty.
- The Create Workout action currently closes the sheet and displays a success message. It does not create or persist a workout.
- No exercise animation assets were found in the current asset library.
- Existing local settings, music playback, TTS integration, and shared theme colors can be reused where appropriate.

## Exercises identifiable in the video

The recording is approximately 13.5 seconds long. Eleven distinct exercise entries are identifiable. Values below are copied from the reference UI, not independently prescribed training recommendations.

| Exercise | Reference value | Reference placement |
| --- | --- | --- |
| Wall Push-ups | 10 reps | Recommended |
| Punches | 20 seconds | Recommended |
| Side Arm Raise | 20 seconds | Recommended |
| Forward Arm Swings | 20 seconds | Recommended |
| Elbows Back | 20 seconds | Recommended |
| 90/90 Crunch | 10 reps | Numeric section |
| Abdominal Crunches | 10 reps | A section |
| Arm Circles | 10 reps | A section |
| Arm Raises | 20 seconds | A section |
| Adductor Stretch in Standing | 10 reps | A section |
| Arm Circles Counterclockwise | 20 seconds | A section |

The reference filter says “All Areas (370)”. The clip does not show that full catalog. The initial app must show its actual available exercise count.

## Proposed first-stage flow

1. Custom Workout → Create → enter name and difficulty.
2. Open a workout builder with an Add Exercises action.
3. Show a near-full-height Add Exercises sheet matching the video: rounded top corners, close icon, body-area filter, search field, Recommended section, alphabetical sections, avatar thumbnails, exercise names, rep/time values, and selection controls.
4. Use the app's onboarding green (`AppColors.primary`, #7AC143) for selected states and action buttons.
5. Show an “Add N exercises” action once exercises are selected. Close or cancel without committing the pending selection.
6. In the builder, reorder or remove exercises and edit repetition counts, timed durations, and rest periods.
7. Save the named workout and restore it when the app reopens. Allow saved workouts to be reopened and edited.
8. Tapping an exercise opens a larger looping demonstration with its details. Keep playback to visible thumbnails or the active preview to avoid decoding every animation at once.

## Data and persistence

Introduce an exercise catalog with stable IDs, names, body-area tags, difficulty, repetition/timed mode, default values, recommended status, thumbnail path, and animation path.

Store a custom workout's ID, name, difficulty, ordered exercise entries, per-entry repetitions or duration, rest duration, and created/updated timestamps. Use separate IDs for workout entries so the same exercise can be added deliberately more than once. Save versioned JSON through a repository; validate loaded data and report failed writes instead of showing false success.

Store media separately from workout JSON and reference it by stable exercise ID. Bundled starter exercises should work offline. Do not silently replace a missing animation with a different exercise.

## Avatar asset plan

1. Agree on supplied/licensed reference-style assets or an original avatar style.
2. Prototype Wall Push-ups, Punches, and Abdominal Crunches. These cover wall-based, standing, and floor movements.
3. Review the avatar, motion, viewing angle, loop transitions, and visibility at thumbnail size before creating the remaining eight.
4. Keep the character, clothing, background, scale, and framing consistent across exercises.
5. GIF is supported directly by Flutter. Compare GIF, animated WebP, and short muted video for quality, decoding cost, and APK size before finalizing the format.
6. Verify that the animation represents the named exercise and obtain exercise-form review before claiming professional coaching accuracy.

A short screen recording can help prototype appearance, but scrolling, small thumbnails, and incomplete cycles make it unsuitable as the final source for every animation.

## Delivery stages

### Stage 1 — catalog and asset prototype

Confirm the eleven exercise records and their reference values; produce or integrate three demonstration animations and check the visual direction.

### Stage 2 — exercise picker and workout builder

Implement search, filters, recommended/alphabetical grouping, multi-selection, exercise details, reordering, value editing, and real workout creation.

### Stage 3 — complete starter library and persistence

Integrate all eleven approved animations; implement saved-workout loading/editing, offline operation, and clear error states. Measure animation performance and APK size on an Android phone.

### Stage 4 — verification and delivery

Test creation, selection cancellation, duplicate exercise entries, search/filter combinations, invalid values, save failures, reopening, reordering, and missing media. Verify scrolling performance, animation lifecycle, small-screen layout, and accessibility. Build a new APK after the implementation passes checks.

A timed workout player with preparation/rest timers, music, TTS coaching, and completed-session history is a separate follow-on stage unless explicitly included in the implementation scope.

## Inputs and decisions needed before asset production

- Whether original animation files are available and reusable.
- If they are unavailable, whether to use licensed files or an original avatar style.
- Approval of the three-animation prototype before producing all eleven.

## Recommended scope

Start with the eleven visible exercises, a real saved-workout builder, and original or licensed looping avatar assets. Expand the catalog after this complete starter flow works on the phone. Estimate production time after the animation source and prototype quality are settled.
