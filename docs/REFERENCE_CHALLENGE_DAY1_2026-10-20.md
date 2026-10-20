# First reference challenge: Intense Belly Fat Burn / Day 1

Implemented from the three October 20 reference recordings and the supplied Day 1 screenshot. Open **Training → Challenge → INTENSE BELLY FAT BURN → START DAY 1**. This is one upgraded challenge prototype; the other training cards retain their existing flows.

## Included behavior

| Reference behavior | Implementation |
| --- | --- |
| Hero, day heading, duration and exercise count | Day 1 page with existing belly-fat hero, computed duration and saved plan count |
| Exercise sequence | Exact 21-entry order from the recording, including repeated exercises and left/right variants; 30 seconds per default entry |
| Human exercise demonstrations | Original generated realistic human frame animations for all default entries |
| Exercise detail card | Animation, muscle information, instructions, common mistakes, breathing cues, previous/next navigation and duration controls |
| Plan editing | Reorder, replace, remove, change duration in 5-second steps, reset defaults, Save/Cancel, and a back-navigation save/discard prompt |
| Start / Continue / Restart | Persistent session ID, exercise index, phase and remaining milliseconds; Continue opens paused; Restart retains plan edits |
| Preparation and automatic playback | Configured preparation time, timed exercises, automatic rest and exercise transitions |
| Rest screen | Next-exercise preview, countdown, +20 seconds, Skip and editable rest duration |
| Playback controls | Previous, Pause/Resume, Next, instructions and overall progress; primary controls stay at the bottom |
| Audio | Built-in and previously imported saved music queue, track selection, previous/next, repeat, volume, mute, device TTS cues and workout settings |
| Background/exit | Pause on background; saved checkpoint every second and at phase changes; Save and leave protects the current countdown |
| Completion | Stable-ID history entry, retry on storage failure, and protection against duplicate credit on reopening |

## Scope and intentional differences

- Only this new Training challenge card has the complete reference Day 1 flow. No unrecorded later days were invented.
- Duration is computed from the current plan and settings. The default sequence is 20 minutes 45 seconds including preparation/rest, displayed as approximately 21 minutes rather than the reference's fixed 20-minute label.
- Avatars are original generated eight-frame loops, not the reference app's filmed animations. Mirroring provides corresponding right-side demonstrations. Other optional replacement exercises retain the established illustrated avatars.
- Body Saw is scoped to this challenge; the existing 366-item custom-workout catalog is unchanged.
- Plan and progress are stored locally under `challenge_intense_belly_day1_v1`; edits that would invalidate an active session require a clear reset confirmation. Completed history is retained.

## Validation

- Static analysis of `lib` and `test`: no issues.
- Full Flutter test suite: **71 passed**, including 11 new challenge tests.
- New coverage: exact sequence, avatar coverage, automatic phase transitions, pause, rest editing, resume/restart, persisted edits, corrupt-data protection, replacement identity, completion deduplication, and layouts at 320×640 with 100% and 200% text.
- Visual previews exported and inspected at 390×844: `build/challenge-previews/day1.png`, `exercise.png`, and `rest.png`.
- Android build attempted, including direct Kotlin compilation retries. Gradle fails before compiling project code with `java.io.IOException: Unable to establish loopback connection` / `SocketException: Invalid argument: connect` in the local JDK selector. IPv4 and Windows-selector retries did not resolve it. No new APK is claimed; native TTS and audio still need a device run after the build environment is repaired.

Asset generation details and prompt briefs: `assets/images/challenge_avatars/README.md`.
