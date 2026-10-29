# Day 1 realistic exercise avatars

## Calisthenics additions — 2026-10-28

Eight further sheets were created using the built-in `image_gen.imagegen` tool, matching the existing original demonstrator and studio brief below. All 22 Calisthenics entries now use realistic frame loops in the exercise list, detail sheet and session player. Repeated sets reuse their exercise frames; Cat Cow reuses atlas 5. These are generated discrete-pose animations, not filmed video.

| File | First eight cells | Last eight cells |
| --- | --- | --- |
| atlas_6.png | Cross-Body Shoulder Stretch | Elbow Rotations |
| atlas_7.png | Alternating Side Bends | Spinal Roll Down |
| atlas_8.png | Standing Hip Rotations Left | Kneeling Push-Ups |
| atlas_9.png | Bird Dog | Reverse Hip Raise |
| atlas_10.png | Superman | Leg Scissors |
| atlas_11.png | Suitcase Crunch | Left Pivot Step Lunge |
| atlas_12.png | Prisoner Squat | Hip Flexor Stretch Left |
| atlas_13.png | Straight Arm Plank To Downward Dog | Child's Pose |

The same shared prompt brief below was used with these eight exercise pairs: eight successive controlled movement phases per exercise, including start, extension/flexion and return, with the full body visible. Atlas 8 was regenerated to improve named-leg consistency. Runtime frame orders exclude inconsistent leg/camera cells in hip rotations and spinal roll down, and select returning poses for shoulder stretch, side bends and bird dog. Right-side variants mirror the left-side frames. Playback repeats every 2.8 seconds and respects pause, reduced motion, hidden routes and application lifecycle.

Source outputs in the generated-images directory listed below, in atlas order 6–13:

- `exec-ed4ec32d-959c-4a97-a4f9-76a17bd15207.png`
- `exec-85488a8b-6649-49f9-9f78-27fc82fb6187.png`
- `exec-3fe50324-f1f0-4541-a309-e50778b152ee.png`
- `exec-c4e594f2-9100-4d20-a696-581ceaf23266.png`
- `exec-2e69d3a8-95d9-4336-8002-68abb00b2801.png`
- `exec-c70daef7-6db2-4af5-92c8-ef98bc52d920.png`
- `exec-49cd1528-a412-44ee-a3ac-8e554f80fcbd.png`
- `exec-7e668f15-5083-4ea5-9624-ba32d403cb8e.png`

Created on 2026-10-20 using the built-in `image_gen.imagegen` tool and the imagegen skill. These are original generated human illustrations arranged as animation frames. They are not recordings or extracted artwork from the reference app. No third-party animation pack was imported.

## Saved production assets

| File | Frames 0–7 | Frames 8–15 |
| --- | --- | --- |
| atlas_1.png | Jumping Jacks | Oblique Crossover Crunch Left |
| atlas_2.png | Inchworms | Single Leg Drops |
| atlas_3.png | Body Saw | Bicycle Crunches |
| atlas_4.png | Side Crunches Left | Bent Knee Side Hip Raises Left |
| atlas_5.png | Cat Cow Pose | Lying Twist Stretch Left |

Each PNG contains a 4×4 grid. Runtime code draws eight successive frames per exercise in a 2.8-second loop, trims the grid edges, and mirrors the relevant left-side animation for right-side entries. All 21 default Day 1 entries have this artwork; repeated exercises share frames. Replacements outside these 14 exercise IDs use the existing illustrated avatars, identified in the replacement picker.

The mapping, cropping, animation, reduced-motion handling and lifecycle handling live in `lib/widgets/exercises/challenge_avatar.dart`. Production files are bundled from this directory via `pubspec.yaml`.

## Prompt set / reproducible art brief

Shared brief: create an original photorealistic 3D male fitness demonstrator wearing a plain black T-shirt, black exercise trousers and white trainers. Neutral light-grey studio, dark exercise mat for floor movements, even lighting, consistent camera, person and scale. Produce a square 4×4 contact sheet of 16 equal cells, with eight ordered movement phases for the first exercise followed by eight for the second. Keep the complete body visible in every cell. No text, branding, UI, or reference-app artwork. Use distinct start, intermediate, peak and returning poses suitable for a short loop.

Five exercise-pair briefs:

1. Jumping Jacks: feet together/arms down → jump outward/raise arms → feet wide/arms overhead → return. Oblique Crossover Crunch Left: supine with bent knees, controlled opposite elbow toward the named knee, return without pulling the neck.
2. Inchworms: stand → hinge → walk hands forward to plank → walk back → stand. Single Leg Drops: supine, alternate controlled lowering of a raised leg while the other stays raised, then return.
3. Body Saw: forearm plank with a steady trunk, small forward/backward glides around planted elbows. Bicycle Crunches: alternate opposite elbow and bent knee while extending the other leg, then reverse.
4. Side Crunches Left: side-focused lying crunch with controlled lift and return. Bent Knee Side Hip Raises Left: bent-knee side support, raise hips to align the trunk and lower with control.
5. Cat Cow Pose: hands and knees, alternate rounded and gently extended spine. Lying Twist Stretch Left: supine, controlled bent-knee rotation toward the named side, shoulders staying supported, return gently.

This brief summarizes the generation prompt set for maintenance; it is not a transcript of the tool invocations. Inspect the frame sequence before replacing an atlas: generated frame loops have discrete poses and are not filmed motion capture.

## Original generated outputs

Copied into the project from `C:/Users/M Zubair Akram/.codex/generated_images/01a13d14-763a-7962-a171-d38fff362cc0/`:

1. `exec-49bec377-d98c-4e36-8739-0c7fb6778460.png`
2. `exec-65777aea-ee23-479d-adeb-da72d89e16e9.png`
3. `exec-ed5be44b-97ca-4f04-81e1-c60d5d0fe02f.png`
4. `exec-73a4f14f-2845-4265-9a75-0c7af63e3edd.png`
5. `exec-19af4a76-cdad-4f1f-907f-7b440f827dca.png`
