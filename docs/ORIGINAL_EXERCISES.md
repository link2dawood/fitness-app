# Original exercise starter library

The 11 exercise demonstrations in this implementation are drawn and animated by
`lib/widgets/exercises/exercise_avatar.dart`. The character artwork and motion
loops were created in this project. No animation files, GIFs, or character artwork
from the reference app are bundled or downloaded.

The catalog is in `lib/data/models/exercise.dart`. It includes the 11 exercise
names and default rep/time values visible in the supplied reference video. These
are illustrative 2D exercise demonstrations, not an assertion of professionally
reviewed coaching form.

The application renders the avatar directly with Flutter. GIFs in
`build/exercise-previews` are optional review exports of the same original code,
not runtime dependencies. Drawing directly avoids bundling a duplicate bitmap
animation for each exercise. Loops respect reduced-motion preferences and app
backgrounding, and are isolated in repaint boundaries.

## Included exercises

1. Wall Push-ups
2. Punches
3. Side Arm Raise
4. Forward Arm Swings
5. Elbows Back
6. 90/90 Crunch
7. Abdominal Crunches
8. Arm Circles
9. Arm Raises
10. Adductor Stretch in Standing
11. Arm Circles Counterclockwise

## Included workout flow

Create a named workout with difficulty; search/filter exercises; preview and
select exercises; edit repetitions, time, and rest; reorder or remove entries;
save and reopen workouts. Duplicate exercise entries are supported. Pending
changes prompt before being discarded. The actual available catalog count is
shown. Corrupt saved data is not silently replaced by a new save.

The persistent schema is versioned JSON under `custom_workouts_v1`, implemented by
`lib/data/repositories/custom_workout_repository.dart`. Exercise entries have
separate IDs so repeated exercises preserve their order and individual targets.

A timed session player and completed-session history remain a separate stage.
This implementation does not show a fake Start or completion action.

## Review exports

On the current Windows development environment:

```
flutter test --dart-define=EXPORT_EXERCISE_PREVIEWS=true test/custom_workout_test.dart
python tool/export_exercise_previews.py
```

The export-only tests load local review fonts; normal tests do not depend on
those font files. Pillow is needed only for assembling GIF previews. No new
runtime package was added for the exercise animations.
