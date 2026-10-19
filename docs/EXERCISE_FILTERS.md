# Add Exercises filters

Every catalog entry stores explicit `focus`, `difficulty`, `type`, and `equipment`
metadata alongside its existing primary body area, target, and motion. Focus and
equipment support multiple tags. New exercises must supply all four fields.
Difficulty is an app browsing classification, independent of the user's rep target.

The filter panel includes Abs, Chest, Back, Arm, Leg, Glutes, and Shoulder;
Easy, Medium, and Hard; Warm up, Stretch, and Training; and No equipment,
Dumbbell, Band, Chair, Bench, and Mat. Band currently has no matching entries.
Mat tags identify floor exercises that can use an optional mat; those bodyweight
exercises also retain No equipment. Walls and door frames are not portable
equipment and remain under No equipment.

`ExerciseFilters.matches` uses OR within a category and AND across categories.
An empty category accepts all its values. Search is applied in addition to the
filters, and the live count in the panel includes the current search query.

Opening the panel copies the applied filters. Save applies the draft; Cancel,
back, and dismiss discard it. Individual summary chips remove one selection;
the trash action clears all categories in the draft. Exercise selections survive
filter and search changes. Filters live for the lifetime of the Add Exercises
picker and do not change saved workout targets.

## Exercise details and selection

Tapping an exercise row or avatar opens the detail sheet. Only its checkbox
changes the picker selection; previewing and dismissing an exercise preserves
the selection. The same detail sheet is available from the workout editor.

The card offers the original animation, schematic focus illustrations, and a
How to do view, followed by the default rep/time target, instructions, focus
tags, common mistakes, and breathing cues. `exercise_guidance.dart` combines
original movement-family cues with each catalog entry's specific description;
it does not copy the reference app's instruction text. Done and the close icon
dismiss the sheet without adding or removing exercises.
