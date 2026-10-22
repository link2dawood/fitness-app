# Report H2 resolution

Removed the sample 106.7 lb weight and day-6 chart point. Current weight and BMI now read the same saved profile weight; BMI uses its saved height without fallback measurements. An 80 kg, 180 cm profile displays 80.0 kg and BMI 24.7.

Missing profiles and nonpositive measurements show explicit unavailable states. A profile's current weight has no recorded measurement date, so it does not create a chart point or historical minimum/maximum. Those values remain unavailable until a weight is explicitly logged.

Weight picker positioning is only an editing draft. Opening or cancelling it cannot replace the saved weight used by Report. Profile changes and page recreation continue to use saved measurements.

Validation: four measurement widget tests cover the reproduced profile, updates, page recreation, absent profile, zero weight, and zero height. The three Report history tests also pass. Long-term dated weight persistence and save-error handling remain separate H3/M1 findings.
