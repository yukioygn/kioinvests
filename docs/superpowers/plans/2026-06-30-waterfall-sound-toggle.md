# Waterfall Sound Toggle Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the implicit "unlock audio on first interaction" behavior in the waterfall section of `index.html` with an explicit sound on/off toggle button.

**Architecture:** Single-file change to `index.html` (no build step, no framework — see project `CLAUDE.md`). A new circular icon button is added to the `.tortoise-philosophy` section's markup/CSS, then the existing audio crossfade JS is rewired so playback is gated on a `soundEnabled` flag driven by that button, in addition to the existing scroll-visibility gate.

**Tech Stack:** Plain HTML/CSS/JS, no dependencies for this feature (Chart.js/PapaParse on this page are unrelated to the waterfall audio).

## Global Constraints

- No persistence of the sound preference — every page load starts with sound off (per spec `docs/superpowers/specs/2026-06-30-waterfall-sound-toggle-design.md`).
- Audio only plays when both `soundEnabled` is true AND `.tortoise-philosophy` is intersecting the viewport (existing `IntersectionObserver`, threshold 0.5).
- No changes to video crossfade logic, carousel, or any other section.
- Match the site's existing design system: `var(--text)`, `rgba(232, 230, 224, 0.4)` border, `rgba(232, 230, 224, 0.08)` hover background (see `.hero-cta` styles at index.html:159-174).
- This project has no test framework or build step — verification is manual, in a browser, served via `python3 -m http.server 8080` (per `CLAUDE.md`).

---

### Task 1: Sound toggle button markup and CSS

**Files:**
- Modify: `index.html` (CSS block, after the `.waterfall-overlay` rule, currently at index.html:308-313)
- Modify: `index.html` (HTML, inside `.tortoise-philosophy` section, after the `.philosophy-img-side` div, currently closing at index.html:737, before `</section>` at index.html:739)

**Interfaces:**
- Produces: a `<button id="soundToggle">` element with `aria-pressed="true"|"false"` attribute that Task 2's JS will read/write. Two child `<svg>` elements with classes `sound-icon-off` and `sound-icon-on`, shown/hidden via the `[aria-pressed]` CSS attribute selector — Task 2 does not need to touch their visibility directly, only toggle `aria-pressed` on the button.

- [ ] **Step 1: Add the CSS for the button and its icons**

In `index.html`, immediately after the `.waterfall-overlay` rule (ends at line 313) and before `.philosophy-text-side` (line 315), insert:

```css
    .sound-toggle {
      position: absolute;
      bottom: 2rem;
      right: 2rem;
      z-index: 3;
      width: 44px;
      height: 44px;
      border-radius: 50%;
      border: 0.5px solid rgba(232, 230, 224, 0.4);
      background: rgba(10, 10, 10, 0.3);
      color: var(--text);
      display: flex;
      align-items: center;
      justify-content: center;
      cursor: pointer;
      transition: background 0.3s ease, border-color 0.3s ease;
    }

    .sound-toggle:hover {
      background: rgba(232, 230, 224, 0.08);
      border-color: rgba(232, 230, 224, 0.8);
    }

    .sound-icon {
      width: 20px;
      height: 20px;
    }

    .sound-icon-on {
      display: none;
    }

    .sound-toggle[aria-pressed="true"] .sound-icon-off {
      display: none;
    }

    .sound-toggle[aria-pressed="true"] .sound-icon-on {
      display: block;
    }
```

- [ ] **Step 2: Add the button markup**

In `index.html`, inside the `.tortoise-philosophy` section, after the `.philosophy-img-side` div closes (line 737) and before the section's closing `</section>` tag (line 739), insert:

```html
    <button class="sound-toggle" id="soundToggle" type="button" aria-pressed="false" aria-label="Toggle waterfall sound">
      <svg class="sound-icon sound-icon-off" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">
        <polygon points="3,9 8,9 13,4 13,20 8,15 3,15" fill="currentColor" stroke="none"></polygon>
        <line x1="16" y1="9" x2="22" y2="15"></line>
        <line x1="22" y1="9" x2="16" y2="15"></line>
      </svg>
      <svg class="sound-icon sound-icon-on" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">
        <polygon points="3,9 8,9 13,4 13,20 8,15 3,15" fill="currentColor" stroke="none"></polygon>
        <path d="M16 8.5a5 5 0 0 1 0 7"></path>
        <path d="M18.5 6a8.5 8.5 0 0 1 0 12"></path>
      </svg>
    </button>
```

- [ ] **Step 3: Manually verify the button renders and the icon states are wired to `aria-pressed`**

Run: `cd /Users/yukio/Desktop/kioinvests && python3 -m http.server 8080`

Open `http://localhost:8080/index.html` in a browser, scroll to the "Black Tortoise Philosophy" waterfall section. Expected: a circular outline button is visible in the bottom-right corner of the section, showing a speaker-with-X (off) icon, matching the muted thin-line style of the rest of the site (compare to the hero CTA button's border treatment).

In the browser devtools console, run:
```js
document.getElementById('soundToggle').setAttribute('aria-pressed', 'true')
```
Expected: the icon swaps from the "off" (speaker + X) icon to the "on" (speaker + sound waves) icon. Run it again with `'false'` to confirm it swaps back.

- [ ] **Step 4: Commit**

```bash
git add index.html
git commit -m "$(cat <<'EOF'
Add sound toggle button markup and CSS to waterfall section

EOF
)"
```

---

### Task 2: Wire toggle button to audio playback, remove implicit unlock

**Files:**
- Modify: `index.html` (JS, the "Waterfall audio crossfade loop" block, currently index.html:1072-1167)

**Interfaces:**
- Consumes: `#soundToggle` button produced by Task 1 (reads/writes its `aria-pressed` attribute).
- Consumes (unchanged from existing code): `#waterfallAudioA`, `#waterfallAudioB` audio elements (index.html:903-908); `fadeAudioIn()`, `fadeAudioOut()`, `startCrossfadeLoop()` function bodies are reused verbatim.
- Produces: `soundEnabled` boolean (module-scope `let`), replacing the old `audioUnlocked` flag. No other task depends on this.

- [ ] **Step 1: Replace the unlock listeners and `audioObserver` gating**

In `index.html`, the current block (index.html:1072-1167) reads:

```js
    // Waterfall audio crossfade loop
    const audioA = document.getElementById('waterfallAudioA');
    const audioB = document.getElementById('waterfallAudioB');
    audioA.volume = 0;
    audioB.volume = 0;
    let audioUnlocked = false;
    let waterfallVisible = false;
    let targetVolume = 0;
    let currentActive = audioA;
    let currentInactive = audioB;
    let crossfading = false;

    function unlockAudio() {
      if (audioUnlocked) return;
      audioUnlocked = true;
      audioA.load();
      audioB.load();
      if (waterfallVisible) fadeAudioIn();
    }

    document.addEventListener('click', unlockAudio, { once: true });
    document.addEventListener('scroll', unlockAudio, { once: true });
    document.addEventListener('touchstart', unlockAudio, { once: true });

    function startCrossfadeLoop(audio) {
      audio.addEventListener('timeupdate', function () {
        if (audio.duration && audio.currentTime >= audio.duration - 2.5 && !crossfading) {
          crossfading = true;
          const vol = audio.volume;
          currentInactive.currentTime = 0;
          currentInactive.volume = 0;
          currentInactive.play().catch(() => { });

          let step = 0;
          const steps = 25;
          const xfade = setInterval(() => {
            step++;
            const ratio = step / steps;
            audio.volume = Math.max(0, vol * (1 - ratio));
            currentInactive.volume = Math.min(vol, vol * ratio);
            if (step >= steps) {
              clearInterval(xfade);
              audio.pause();
              audio.currentTime = 0;
              const temp = currentActive;
              currentActive = currentInactive;
              currentInactive = temp;
              crossfading = false;
            }
          }, 100);
        }
      });
    }

    startCrossfadeLoop(audioA);
    startCrossfadeLoop(audioB);

    let fadeInterval = null;

    function fadeAudioIn() {
      clearInterval(fadeInterval);
      targetVolume = 0.25;
      currentActive.play().catch(() => { });
      fadeInterval = setInterval(() => {
        if (currentActive.volume < targetVolume) {
          currentActive.volume = Math.min(targetVolume, currentActive.volume + 0.02);
        } else {
          clearInterval(fadeInterval);
        }
      }, 80);
    }

    function fadeAudioOut() {
      clearInterval(fadeInterval);
      targetVolume = 0;
      fadeInterval = setInterval(() => {
        if (currentActive.volume > 0) {
          currentActive.volume = Math.max(0, currentActive.volume - 0.02);
          currentInactive.volume = Math.max(0, currentInactive.volume - 0.02);
        } else {
          clearInterval(fadeInterval);
          currentActive.pause();
          currentInactive.pause();
        }
      }, 80);
    }

    const audioObserver = new IntersectionObserver((entries) => {
      entries.forEach(entry => {
        waterfallVisible = entry.isIntersecting;
        if (entry.isIntersecting && audioUnlocked) fadeAudioIn();
        else fadeAudioOut();
      });
    }, { threshold: 0.5 });

    audioObserver.observe(document.querySelector('.tortoise-philosophy'));
```

Replace it with:

```js
    // Waterfall audio crossfade loop
    const audioA = document.getElementById('waterfallAudioA');
    const audioB = document.getElementById('waterfallAudioB');
    audioA.volume = 0;
    audioB.volume = 0;
    let soundEnabled = false;
    let waterfallVisible = false;
    let targetVolume = 0;
    let currentActive = audioA;
    let currentInactive = audioB;
    let crossfading = false;

    const soundToggle = document.getElementById('soundToggle');

    soundToggle.addEventListener('click', () => {
      soundEnabled = !soundEnabled;
      soundToggle.setAttribute('aria-pressed', String(soundEnabled));

      if (soundEnabled) {
        audioA.load();
        audioB.load();
        if (waterfallVisible) {
          fadeAudioIn();
        } else {
          // Spend this click's user-gesture credit priming the audio element
          // so a later, scroll-triggered (non-gesture) play() isn't blocked
          // by the browser's autoplay-with-sound policy.
          currentActive.play().then(() => currentActive.pause()).catch(() => { });
        }
      } else {
        fadeAudioOut();
      }
    });

    function startCrossfadeLoop(audio) {
      audio.addEventListener('timeupdate', function () {
        if (audio.duration && audio.currentTime >= audio.duration - 2.5 && !crossfading) {
          crossfading = true;
          const vol = audio.volume;
          currentInactive.currentTime = 0;
          currentInactive.volume = 0;
          currentInactive.play().catch(() => { });

          let step = 0;
          const steps = 25;
          const xfade = setInterval(() => {
            step++;
            const ratio = step / steps;
            audio.volume = Math.max(0, vol * (1 - ratio));
            currentInactive.volume = Math.min(vol, vol * ratio);
            if (step >= steps) {
              clearInterval(xfade);
              audio.pause();
              audio.currentTime = 0;
              const temp = currentActive;
              currentActive = currentInactive;
              currentInactive = temp;
              crossfading = false;
            }
          }, 100);
        }
      });
    }

    startCrossfadeLoop(audioA);
    startCrossfadeLoop(audioB);

    let fadeInterval = null;

    function fadeAudioIn() {
      clearInterval(fadeInterval);
      targetVolume = 0.25;
      currentActive.play().catch(() => { });
      fadeInterval = setInterval(() => {
        if (currentActive.volume < targetVolume) {
          currentActive.volume = Math.min(targetVolume, currentActive.volume + 0.02);
        } else {
          clearInterval(fadeInterval);
        }
      }, 80);
    }

    function fadeAudioOut() {
      clearInterval(fadeInterval);
      targetVolume = 0;
      fadeInterval = setInterval(() => {
        if (currentActive.volume > 0) {
          currentActive.volume = Math.max(0, currentActive.volume - 0.02);
          currentInactive.volume = Math.max(0, currentInactive.volume - 0.02);
        } else {
          clearInterval(fadeInterval);
          currentActive.pause();
          currentInactive.pause();
        }
      }, 80);
    }

    const audioObserver = new IntersectionObserver((entries) => {
      entries.forEach(entry => {
        waterfallVisible = entry.isIntersecting;
        if (entry.isIntersecting && soundEnabled) fadeAudioIn();
        else fadeAudioOut();
      });
    }, { threshold: 0.5 });

    audioObserver.observe(document.querySelector('.tortoise-philosophy'));
```

- [ ] **Step 2: Manually verify full behavior in the browser**

Run: `cd /Users/yukio/Desktop/kioinvests && python3 -m http.server 8080` (skip if still running from Task 1).

Open `http://localhost:8080/index.html`. Perform each check:

1. **Default off:** Load the page fresh, scroll to the waterfall section. Expected: button shows the "off" icon (`aria-pressed="false"`), no audio is heard even though the section is in view.
2. **Toggle on while visible:** With the waterfall section in view, click the button. Expected: icon swaps to "on", audio fades in over ~1-2s to a moderate volume.
3. **Scroll away while on:** Scroll the section out of view. Expected: audio fades out and pauses; button still shows "on" (toggle state unchanged).
4. **Scroll back while on:** Scroll the section back into view. Expected: audio fades back in automatically, with no further click needed.
5. **Toggle off while visible:** Click the button again while the section is in view and audio is playing. Expected: icon swaps to "off", audio fades out and pauses.
6. **Toggle on while NOT visible:** Scroll away from the section, then scroll back up so the button is off-screen — actually toggle the button is only reachable while the section is visible since it's positioned inside the section, so this case is covered by check 4 (turning on, then immediately scrolling away, then back) — confirm: turn sound on, scroll away (fades out per check 3), scroll back (fades in per check 4) without any new click. This confirms the "prime" `play()`/`pause()` call from Step 1 successfully unlocked playback for the later non-gesture `play()` call.
7. **Crossfade still works:** Leave the section in view with sound on for the full duration of `waterfall2.mp3` (check its length, e.g. via `document.getElementById('waterfallAudioA').duration` in devtools console once loaded) to confirm the loop still crossfades seamlessly between the two audio elements.
8. **Console check:** Open devtools console throughout all of the above. Expected: no errors logged.

- [ ] **Step 3: Commit**

```bash
git add index.html
git commit -m "$(cat <<'EOF'
Replace implicit audio unlock with explicit sound toggle button

Waterfall section audio now requires the user to opt in via the
sound toggle button, instead of being unlocked by the first
click/scroll/touch anywhere on the page.
EOF
)"
```
