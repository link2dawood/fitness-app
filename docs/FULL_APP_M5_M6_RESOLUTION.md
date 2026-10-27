# Full app audit: M5–M6 resolution

Date: October 26, 2026 (Asia/Karachi).

## M5 — Responsive onboarding, settings and Pro

- Onboarding headings and option bodies scroll when text or viewport height needs more space. The primary action remains outside the scroll body and has a minimum height instead of a fixed height.
- Goal cards grow with their labels. Weekly section headings wrap, body-unit controls wrap, and large-text focus selection uses readable option rows instead of squeezing labels into the annotated figure. Normal-size focus selection retains its avatar and connectors.
- Plan Ready scrolls and its plan card uses natural content height. Artwork adapts to narrow widths; metadata wraps in its columns. Existing navigation behavior is unchanged by this layout fix.
- Workout music, rest, preparation and sound sheets use safe, scrollable natural-height content. Save controls remain reachable by scrolling. Rest and preparation choices use named Material controls; sound labels wrap beside their switches. Music controls wrap rather than requiring one fixed horizontal row. The playing queue header also wraps.
- Pro prices and discount labels wrap within growing plan cards. Feature labels wrap, trial text grows beside its switch, reviews allow additional space for large text, legal controls wrap, and the footer label grows within a minimum-height action.

## M6 — Keyboard and screen-reader controls

Custom onboarding, queue and Pro cards use a shared Material action with a visible focus outline, keyboard activation, button role, a minimum 48-pixel target, and explicit selected state. Gender and goal cards no longer depend on pointer-only gesture handlers. Week-start and unit choices expose selection.

Settings Done buttons are standard named, focusable buttons. Saving disables the control; failed commits retain drafts for retry. Prep/rest chips, switches, playback buttons and sliders have labels or descriptive tooltips. The music seek slider announces elapsed and total time. Existing save durability remains covered.

Onboarding measurement rulers have named slider semantics, current and next values, screen-reader increase/decrease actions, arrow-key adjustment, and visible focus. Minimum and maximum values suppress unavailable adjustment actions.

Pro close has a name and 48-pixel target; plan cards expose selection, review navigation has named previous/next buttons, and legal controls open an honest unavailable-document explanation instead of doing nothing. Purchases remain unavailable as previously requested.

## Validation

- Full Flutter suite: **207 tests passed**.
- `dart analyze lib test`: **No issues found**.
- `git diff --check`: passed.

The permanent real-font test matrix covers all eight onboarding steps, Plan Ready, Pro, and all four workout settings sheets at:

| Viewport | Text scale |
| --- | --- |
| 390 × 844 | 100% |
| 320 × 640 | 200% |
| 844 × 390 | 100% |
| 768 × 1024 | 100% |

Checks reject framework layout diagnostics and verify that sheet Done controls and Plan Ready actions can be reached. Separate semantics and keyboard regressions cover gender selection, settings submission, Pro selection/close, and measurement adjustment/bounds. Native media channels are mocked. TalkBack/VoiceOver device testing remains a practical verification step; no device certification is claimed.

M7–M10 and the original low findings are outside this resolution.
