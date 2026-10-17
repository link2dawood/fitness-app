# Original exercise starter library

The 48 exercise demonstrations in this implementation are drawn and animated by
`lib/widgets/exercises/exercise_avatar.dart`. The character artwork and motion
loops were created in this project. No animation files, GIFs, or character artwork
from the reference app are bundled or downloaded.

The catalog is in `lib/data/models/exercise.dart`. It includes the 48 exercise
names and default rep/time values visible in the supplied reference videos. These
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
12. Arm Scissors
13. Alt V-up
14. Arm Circles Clockwise
15. Alternating Hooks
16. Arm Curls Crunch Left
17. Arm Curls Crunch Right
18. Anterior Shoulder Stretch
19. Arnold Dumbbell Press
20. Alternating Dumbbell Shoulder Press
21. Alternate Hammer Curl
22. Arm Swings with Lateral Steps
23. Bicycle Crunches
24. Bird Dog
25. Bridge
26. Burpees
27. Backward Lunge with Front Kick Right
28. Backward Lunge with Front Kick Left
29. Butt Bridge
30. Box Push-ups
31. Bulgarian Split Squat Left
32. Bottom Leg Lift Right
33. Bottom Leg Lift Left
34. Bulgarian Split Squat Right
35. Backward Lunge
36. Backward Arm Swings
37. Butt Kicks
38. Bent Leg Twist
39. Bird Dog Left
40. Bird Dog Right
41. Bent Over Row
42. Back Bow Pulls
43. Backward Lunge (Timed)
44. Butt Bridge (Timed)
45. Bow Pose
46. Bent Over Dumbbell Rows Left
47. Bent Over Dumbbell Rows Right
48. Back Arches

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

The second October 17 video adds 21 variants. Rep-based and timed Backward Lunge and Butt Bridge entries have separate stable IDs. Equipment requirements appear in preview descriptions. All added artwork and motion remain code-drawn originals.
