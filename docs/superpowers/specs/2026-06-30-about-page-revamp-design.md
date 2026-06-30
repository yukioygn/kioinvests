# About Page Revamp — Design

## Problem

The current `about.html` is an unfinished, never-committed draft: a white/light
two-column layout that doesn't match the rest of the site (dark `#0a0a0a`
theme used by `index.html` and all case-study pages). It was never linked from
anywhere and is being scrapped entirely.

## Goal

Replace it with a new, fully dark-themed About page that reads as "elegant,
minimalist, premium" — a short manifesto rather than a biography, since the
founder stays anonymous/pseudonymous. Reached via the existing `About` nav
link on `index.html` (`index.html:723`, already points to `about.html`, no
change needed there).

## Visual identity

Matches the rest of the site's established design system exactly — no new
colors or typefaces introduced:

- Background `#0a0a0a`, text `#e8e6e0`, muted `rgba(232, 230, 224, 0.45–0.55)`.
- All emotive serif display text (the manifesto statements) is **italic
  Georgia, weight 400, normal letter-spacing** — matching the existing
  `.hero-tagline` / `.pillar-title` / `.lineage-text` / `.invitation-headline`
  pattern across the site. (An earlier draft used upright Georgia with tight
  negative letter-spacing; that was a deviation from the site's voice and was
  corrected during design review.)
- Nav and small labels: `system-ui` sans, small size, wide letter-spacing —
  matching the case-study page nav pattern (`soc.html:475-478`): a simple
  `KIO INVESTS` logo + back-link, not the homepage's full scroll-triggered nav.
- Footer identical to the homepage: `Kio Invests © 2026`.
- Boldness comes from **type scale and asymmetric placement**, not from
  breaking the established font voice.

## Content

Pure manifesto, anonymous voice, no biographical details, no portrait. Content
is organized as a sequence of short statement "beats," each occupying roughly
one viewport height, left-aligned with alternating indentation for visual
rhythm (not centered, not uniform). Final beat count: opener + 4 statements +
closing contact line — roughly 5-6 viewport-heights of scroll total. (This
is longer than the initially-discussed "1.5x viewport" target; the asymmetric
beat-per-statement rhythm read better at this length once mocked up, and was
approved in that form.)

Working copy (subject to future wording refinement, structure is the
approved part):

1. Opener: "Most capital is managed by people paid to do something."
2. "We hold few positions, and we hold them for a long time."
3. "Not because we are slow — because conviction takes years to be
   vindicated, and we are willing to wait for the vindication rather than the
   applause." (muted/smaller treatment)
4. "The work is mostly waiting."
5. "No newsletter. No quarterly letter. No noise. If something changes, the
   case studies change. That is the only communication you should expect
   from us." (muted/smaller treatment)
6. Closing: "Get in touch" label + `hello@kioinvests.com` mailto link.

## Layout

Two-zone flex layout, not the rejected draft's 50/50 split:

- **Left strip** — `20vw` wide, `position: sticky`, full viewport height.
  Holds the signature element (see below). Background near-black (`#050505`),
  thin right border matching the site's hairline border convention.
- **Right column** — `80vw`, holds nav, the manifesto beats, closing CTA, and
  footer, in normal document flow.

## Signature element: the scroll-revealing 靜 character

The single distinctive, on-brand visual device for this page. Background:
the homepage hero already displays 靜 ("stillness") in a custom calligraphy
typeface (`HanyiSenty`, loaded from `Hanyi Senty Vimalakirti Regular.ttf`,
`index.html:15-20,140-147`). The About page reuses the **same character, same
font file** — deliberately, for brand consistency, not a different character.

Instead of a static display, the character is revealed gradually as the user
scrolls through the manifesto, via a CSS `mask-image` linear-gradient wipe
from the bottom up:

- A scroll listener computes `pct = scrollY / (scrollHeight - innerHeight) *
  100`, clamped to `[4, 100]`, and writes it to a CSS custom property
  `--pct` on the glyph element via `style.setProperty('--pct', pct)` (a bare
  number, no unit).
- The mask: `mask-image: linear-gradient(to top, #000 calc(var(--pct) * 1%),
  transparent calc(var(--pct) * 1% + 10%))`. **The `* 1%` is required** —
  multiplying the bare-number custom property by `1%` converts it into a
  valid percentage inside `calc()`. Using `var(--pct, 4%)` directly as a
  gradient stop is invalid once `--pct` is set to a bare number, which
  silently breaks the entire `mask-image` value (this was caught and fixed
  during design review).
- By the final beat, `pct` reaches 100 and the character is fully revealed —
  literally: you only see the whole picture once you've read the whole
  manifesto.

A second variant ("blur-resolve": character always faintly visible, sharpens
via `filter: blur()` + opacity as you scroll) was prototyped and works, but
**ink-wipe is the one being shipped** — it reads as bolder, matching the
brief. Switching is a one-class-name change (`wipe` → `resolve`) if revisited
later.

No other imagery is used on this page — the tortoise/case-study photos
stay homepage-only, keeping About visually distinct rather than repeating
existing assets.

## Implementation notes

- Single self-contained file, `about.html`, following the project's existing
  architecture (`CLAUDE.md`): all CSS/JS inline, no shared stylesheet/script,
  no build step.
- `@font-face` for `HanyiSenty` is declared locally in `about.html` itself
  (same pattern as `index.html`), pointing at the existing
  `Hanyi Senty Vimalakirti Regular.ttf` in the project root — no new font
  asset needed.
- Nav back-link points to `index.html`. `index.html`'s existing `About` nav
  link (`index.html:723`) already points to `about.html` — no change needed
  there.
- Case-study pages (`soc.html` etc.) are **out of scope** — their nav stays
  as-is (logo + "All cases" back-link only).

## Out of scope

- No portrait/headshot, no named founder, no credentials.
- No changes to `index.html` beyond confirming the existing About link works.
- No changes to case-study page navs.
- Final copy wording is not locked — structure and visual treatment are.
