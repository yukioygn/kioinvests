# About Page Ambient Effects — Design

## Problem

`about.html` shipped with the manifesto structure and the scroll-resolving 靜
glyph as its sole signature element (see
`docs/superpowers/specs/2026-06-30-about-page-revamp-design.md`). A follow-up
brainstorm explored three additional effects to make the page feel more
sophisticated, premium, and differentiated. All three were prototyped in the
visual companion sandbox, iterated on to fix real bugs, and approved. This
spec locks in the final, verified versions for implementation in the real
page.

## Effect 1: Film grain

A faint animated noise texture over the whole page, giving the flat `#0a0a0a`
background a tactile, non-digital quality.

- A `<canvas>` fixed to the viewport, `z-index` above content, `pointer-events:
  none`.
- Redrawn every ~100ms with fully random per-pixel grayscale noise (not a
  static texture — the flicker is part of the effect).
- `opacity: 0.07`, **`mix-blend-mode: screen`** — not `overlay`. `overlay` was
  the first attempt and was nearly invisible: on a base as dark as `#0a0a0a`
  (luminance ≈ 0.04), the overlay blend formula compresses toward the base
  color, producing a real but imperceptible ~0.5/255 difference. `screen`
  always adds light regardless of base darkness, so the grain reads as
  visible fine speckle. Verified by direct pixel sampling in the sandbox
  (background near-black, grain pixels ranging 0–254) and by zoomed
  screenshot inspection.

## Effect 2: Cursor ring

A small circular ring replaces the default cursor and grows on hover over
interactive elements.

- `html, body { cursor: none; }`, plus a fixed-position `div.cursor-ring`
  (22px circle, thin `rgba(232,230,224,0.6)` border).
- **Tracks the mouse instantly** — position is set directly and
  synchronously in the `mousemove` handler. An earlier version eased the
  ring toward the cursor with a lerp loop (`requestAnimationFrame` +
  `ringX += (mouseX - ringX) * 0.15`); that lagging behavior was explicitly
  rejected ("i dont like the cursor delay") in favor of instant tracking,
  while keeping the ring shape itself.
- Grows to 36px and brightens its border on hover over `.hoverable` elements:
  the nav logo, the `← Home` back-link, and the `hello@kioinvests.com` link.

## Effect 3: Water-ripple strip background

Replaces the strip's flat `#050505` background with a looping video of a
single drop hitting water and rippling outward (`drop.mp4`), sitting behind
the glyph.

- Rationale: `rocks.mp4` and `waterfall1.mp4` are already used elsewhere on
  the site (homepage hero, waterfall section) — reusing either here would
  contradict the existing "About stays visually distinct, no repeated
  assets" principle. `drop.mp4` is in the project root but unused anywhere
  in the shipped site, and its content (a single drop, ripples spreading
  outward, eventually settling) is a literal visual match for the
  manifesto's argument about patience and time. It also ties to 玄武's own
  water-element association in feng shui lore, so the pairing isn't
  arbitrary.
- `<video autoplay muted loop playsinline>` positioned `absolute; inset: 0`
  inside `.strip`, `object-fit: cover`, sitting behind the glyph (`.glyph`
  gets `position: relative; z-index: 2` so it stays on top).
- Heavily dimmed and desaturated to stay ambient rather than competing for
  attention: `filter: grayscale(1) brightness(0.35) contrast(1.1)` — the
  same grayscale/dim treatment already used elsewhere on the site (e.g. the
  homepage tortoise grid).
- Verified actually playing in the sandbox (`readyState: 4`, `currentTime`
  advancing, no video errors) after fixing an unrelated asset-path bug from
  earlier prototyping (irrelevant to production, since `about.html` already
  references same-directory assets directly, not through the sandbox's
  `/files/` proxy).

## Combined outcome

All three effects were checked together in the sandbox (grain toggle on/off
while the video plays) and read as complementary rather than competing: the
video and glyph occupy the strip, the cursor ring is a page-wide micro-detail,
and the grain is a whole-page texture underneath everything. None of them
alter the manifesto text, layout, nav, or footer.

## Implementation notes

- All three effects are added directly into `about.html`'s existing inline
  `<style>`/`<script>` blocks — no new files, no shared assets beyond the
  already-present `drop.mp4` in the project root.
- No new dependencies.

## Out of scope

- The other audit findings from the aesthetic review (mobile signature gap,
  glyph reveal pacing, the dead `.indent-3` CSS rule, the nav logo missing a
  hover state, the absent green accent, no scroll-affordance cue, uniform
  92vh beat pacing) are **not** addressed by this spec — they remain open
  decisions for a separate pass.
