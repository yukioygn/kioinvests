# Waterfall Sound Toggle — Design

## Problem

The waterfall section (`.tortoise-philosophy` in `index.html`) currently plays ambient
audio (`waterfall2.mp3`) automatically: the first `click`/`scroll`/`touchstart` anywhere
on the page "unlocks" audio, after which it silently fades in/out as the section enters
and leaves the viewport (via `IntersectionObserver`). The visitor has no explicit control
over whether sound plays at all.

## Goal

Replace the implicit unlock-on-first-interaction behavior with an explicit sound on/off
toggle button, so the visitor decides whether to hear audio.

## Behavior

- Sound is **off by default** on every page load. No persistence (no `localStorage`) —
  every fresh visit starts muted.
- A toggle button controls a `soundEnabled` state (on/off).
- Audio plays only when **both** conditions hold: `soundEnabled` is true **and** the
  `.tortoise-philosophy` section is intersecting the viewport (existing
  `IntersectionObserver`, threshold 0.5). Scrolling the section out of view fades audio
  out without changing the toggle state; scrolling back in fades it back in automatically
  if still enabled.
- Turning the toggle off fades audio out and pauses, regardless of scroll position.
- Turning the toggle on, while the section is currently visible, fades audio in
  immediately.
- Turning the toggle on while the section is **not** currently visible still needs to
  "unlock" playback for later, scroll-triggered (non-gesture) `play()` calls, since
  browser autoplay-with-sound policies require a user gesture. We satisfy this within the
  click handler by calling `play()` then immediately `pause()` if the section isn't
  visible at toggle time (mirrors what the old `unlockAudio()` did with `load()`, but
  using `play()`/`pause()` so the gesture is actually spent on the audio element).
- The existing crossfade-looping logic between `waterfallAudioA`/`waterfallAudioB` is
  unchanged.

## UI

- A circular icon button (~44px), placed inside `.tortoise-philosophy`, absolutely
  positioned in a corner (bottom-right) above the `.waterfall-overlay`.
- Visual style matches the site's existing thin-line, muted-tone chrome: subtle
  semi-transparent border/background, hover state.
- Contains two inline SVG speaker icons (sound-on / sound-off), toggled via a CSS class
  on state change.
- `aria-pressed` reflects state; `aria-label="Toggle waterfall sound"`.

## Implementation notes

- Remove the global `document.addEventListener('click'/'scroll'/'touchstart', unlockAudio, { once: true })`
  listeners and the `unlockAudio()` function — the button click becomes the sole
  enable/unlock gesture.
- Keep `audioObserver` (the `IntersectionObserver` on `.tortoise-philosophy`) but gate its
  `fadeAudioIn()`/`fadeAudioOut()` calls on `soundEnabled` in addition to
  `entry.isIntersecting`.
- `fadeAudioIn()` / `fadeAudioOut()` / crossfade loop functions are reused as-is.
- No changes to the video crossfade logic, which is independent of audio.

## Out of scope

- No persistence of the sound preference across page loads.
- No changes to video behavior, carousel, or any other section.
