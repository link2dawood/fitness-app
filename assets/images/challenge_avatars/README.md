# Day 1 realistic exercise avatars

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
