# Discover M2 and M5 resolution

**Date:** October 22, 2026.

## M2 — Responsive layouts

- Replaced fixed-height Picks, Fast workout and Stretch viewports with horizontal, content-sized carousels. All labels can wrap fully, and paired cards grow with their content.
- Workout rows switch from image/text columns beside each other to stacked content for larger text.
- Hero, promo, beginner, challenge and equipment photos retain their card presentation, but use minimum heights with text participating in layout rather than fixed overlays that can clip. Full-width banners fill the available page width.
- Equipment copy and its visual CTA are stacked so they do not compete for a narrow row.
- Body focus uses content-sized wrapped cards and a single column on narrow screens with larger text; it no longer depends on a fixed grid aspect ratio.
- The compact app-bar title scales down within its available space, keeping both labeled toolbar actions visible.

## M5 — Accessible controls

- All **51 workout/collection placements** expose one named button action. Workout names include the authoritative summary; collection names include their result count.
- Decorative images, text and the equipment CTA do not create duplicate announcements or duplicate activation targets.
- Native Material InkWell controls provide focus traversal, Enter/Space activation and tap feedback. A blue border makes keyboard focus visible over photos and dark cards.
- Each card has at least a 48×48 logical-pixel target. Search and Workout history retain explicit tooltips and 48-pixel targets.
- Existing ID-based workout/collection navigation and persisted history remain connected.

## Verification

**Full regression suite: 100 tests passed. Static analysis: no issues found.** Eleven new tests cover layout, semantic actions, target sizes and keyboard activation. The final banner-width adjustment was rechecked with all 29 Discover tests, and an additional keyboard run verified traversal to the offscreen equipment collection.

The layout tests traverse every horizontal carousel position in 160-pixel steps and the full vertical page. All eight configurations produced zero rendering exceptions:

| Viewport | Text | Direction |
| --- | --- | --- |
| 320×640 | 100% | LTR |
| 390×844 | 100% | LTR |
| 320×640 | 200% | LTR |
| 320×640 | 300% | LTR |
| 390×844 | 200% | LTR |
| 844×390 landscape | 200% | LTR |
| 768×1024 tablet | 200% | LTR |
| 320×640 | 200% | RTL |

Semantic tests verify all 51 cards have a button role, descriptive label, tap action, minimum target and no child announcements. Semantic activation opens the expected workout/collection. Keyboard tests verify Tab traversal, Enter and Space, including an offscreen collection destination.

Normal and 200%-text screenshots were exported with loaded images/fonts and visually inspected: `build/discover-previews/top-normal.png`, `top-large.png`, `body-normal.png`, and `body-large.png`. The test uses a real font when available, with Flutter's default font as a portable fallback. These are widget-level checks; no physical-device TalkBack/VoiceOver certification is claimed.

Permanent tests: `test/discover_accessibility_test.dart`. The expanded permanent suite also addresses the original Discover-specific coverage gap. Profile-based Picks (M4) remains outside this change.

Subsequent update: M4 was resolved separately; see `DISCOVER_PICKS_RESOLUTION.md`.
