# About Page Ambient Effects Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Bring the three sandbox-validated ambient effects — film grain, an instant-tracking cursor ring, and a water-ripple video strip background — into the shipped `about.html`.

**Architecture:** All three effects are additive modifications to the existing `about.html`'s inline `<style>`/`<script>` blocks. No new files. `drop.mp4` (already in the project root, currently unused anywhere in the site) becomes the strip's background video.

**Tech Stack:** Plain HTML/CSS/JS, no new dependencies.

## Global Constraints

- Grain uses `mix-blend-mode: screen`, not `overlay` — `overlay` is nearly invisible on a `#0a0a0a` base (per spec `docs/superpowers/specs/2026-07-01-about-page-ambient-effects-design.md`).
- The cursor ring tracks the mouse **instantly** (direct assignment in the `mousemove` handler) — no easing/lerp loop. A laggy version was explicitly rejected.
- The water video sits **behind** the glyph (`.glyph` needs `position: relative; z-index: 2`), heavily desaturated/dimmed (`grayscale(1) brightness(0.35) contrast(1.1)`), looped, muted, autoplay.
- This project has no test framework or build step — verification is manual, in a browser, served via `python3 -m http.server 8080` (per `CLAUDE.md`).
- Out of scope: the other open audit findings (mobile signature gap, glyph pacing, `.indent-3` dead rule, nav logo hover, green accent absence, scroll cue, uniform beat height) — none of those are touched by this plan.

---

### Task 1: Film grain overlay

**Files:**
- Modify: `about.html` (add `<style>` rule after line 27's `body` rule; add a `<canvas>` element after `<body>` opens at line 172; add JS at the end of the existing `<script>` block, currently lines 214-223)

**Interfaces:**
- Produces: a `<canvas id="grain">` element and a `drawGrain()`/`grainLoop()` JS pair that redraws it every ~100ms. No dependency on later tasks.

- [ ] **Step 1: Add the grain canvas CSS**

In `about.html`, immediately after the `body { ... }` rule (ends at line 27) and before the `/* ── Nav ── */` comment (line 29), insert:

```css
    .grain {
      position: fixed;
      inset: 0;
      z-index: 60;
      pointer-events: none;
      opacity: 0.07;
      mix-blend-mode: screen;
    }
```

- [ ] **Step 2: Add the canvas element**

In `about.html`, the body currently opens like this (lines 172-177):

```html
<body>

  <div class="frame">
    <div class="strip">
      <div class="glyph" id="glyph">靜</div>
    </div>
```

Change it to:

```html
<body>

  <canvas class="grain" id="grain"></canvas>

  <div class="frame">
    <div class="strip">
      <div class="glyph" id="glyph">靜</div>
    </div>
```

- [ ] **Step 3: Add the grain-drawing JS**

In `about.html`, the current `<script>` block (lines 214-223) reads:

```html
  <script>
    const glyph = document.getElementById('glyph');
    function update() {
      const max = document.body.scrollHeight - window.innerHeight;
      const pct = Math.min(100, Math.max(4, (window.scrollY / max) * 100));
      glyph.style.setProperty('--pct', pct);
    }
    document.addEventListener('scroll', update, { passive: true });
    update();
  </script>
```

Add the grain code before the closing `</script>`:

```html
  <script>
    const glyph = document.getElementById('glyph');
    function update() {
      const max = document.body.scrollHeight - window.innerHeight;
      const pct = Math.min(100, Math.max(4, (window.scrollY / max) * 100));
      glyph.style.setProperty('--pct', pct);
    }
    document.addEventListener('scroll', update, { passive: true });
    update();

    // Film grain — screen blend mode stays visible on a near-black base,
    // unlike overlay which compresses toward the base color when it's this dark.
    const grainCanvas = document.getElementById('grain');
    const gctx = grainCanvas.getContext('2d');
    function resizeGrain() {
      grainCanvas.width = window.innerWidth;
      grainCanvas.height = window.innerHeight;
    }
    resizeGrain();
    window.addEventListener('resize', resizeGrain);

    function drawGrain() {
      const w = grainCanvas.width, h = grainCanvas.height;
      const imageData = gctx.createImageData(w, h);
      const buffer = new Uint32Array(imageData.data.buffer);
      for (let i = 0; i < buffer.length; i++) {
        const shade = (Math.random() * 255) | 0;
        buffer[i] = (255 << 24) | (shade << 16) | (shade << 8) | shade;
      }
      gctx.putImageData(imageData, 0, 0);
    }

    let lastGrainTime = 0;
    function grainLoop(t) {
      if (t - lastGrainTime > 100) {
        drawGrain();
        lastGrainTime = t;
      }
      requestAnimationFrame(grainLoop);
    }
    requestAnimationFrame(grainLoop);
  </script>
```

- [ ] **Step 4: Verify in the browser**

Run: `cd /Users/yukio/Desktop/kioinvests && python3 -m http.server 8080` (skip if already running).

Open `http://localhost:8080/about.html`. In devtools console, run:
```js
const d = gctx.getImageData(0,0,20,20).data; let mn=255,mx=0; for(let i=0;i<d.length;i+=4){mn=Math.min(mn,d[i]);mx=Math.max(mx,d[i]);} [mn,mx]
```
Expected: an array like `[0, 254]` or similar wide range (not `[10,10]` or a narrow range), confirming real per-pixel noise is being drawn. Then zoom into a screenshot of an empty dark area (devtools or the `zoom` action if using Claude in Chrome) and visually confirm a fine speckle texture is visible — it should NOT look identical to flat `#0a0a0a`.

- [ ] **Step 5: Commit**

```bash
git add about.html
git commit -m "$(cat <<'EOF'
Add film grain overlay to About page

Uses mix-blend-mode: screen rather than overlay, which is nearly
invisible on a background this dark.
EOF
)"
```

---

### Task 2: Instant-tracking cursor ring

**Files:**
- Modify: `about.html` (add CSS after the grain rule from Task 1; add `hoverable` classes to the logo, back-link, and email link; add JS to the script block)

**Interfaces:**
- Consumes: none from Task 1.
- Produces: a `.cursor-ring` element and a `.hoverable` CSS class convention that Task 3 does not need but future work could reuse.

- [ ] **Step 1: Add the cursor ring CSS**

In `about.html`, immediately after the `.grain` rule added in Task 1, insert:

```css
    html, body {
      cursor: none;
    }

    .cursor-ring {
      position: fixed;
      top: 0;
      left: 0;
      width: 22px;
      height: 22px;
      border: 1px solid rgba(232, 230, 224, 0.6);
      border-radius: 50%;
      pointer-events: none;
      z-index: 90;
      transition: width 0.25s ease, height 0.25s ease, border-color 0.25s ease;
    }

    .cursor-ring.hover {
      width: 36px;
      height: 36px;
      border-color: #e8e6e0;
    }
```

- [ ] **Step 2: Add the ring element and `hoverable` classes**

In `about.html`, the nav and closing link currently read (lines 180-183 and 205-208):

```html
      <nav>
        <a href="index.html" class="logo">KIO INVESTS</a>
        <a href="index.html" class="back-link">← Home</a>
      </nav>
```

and

```html
      <div class="beat indent-2 closing">
        <p class="closing-label">Get in touch</p>
        <a href="mailto:hello@kioinvests.com">hello@kioinvests.com</a>
      </div>
```

Change them to:

```html
      <nav>
        <a href="index.html" class="logo hoverable">KIO INVESTS</a>
        <a href="index.html" class="back-link hoverable">← Home</a>
      </nav>
```

and

```html
      <div class="beat indent-2 closing">
        <p class="closing-label">Get in touch</p>
        <a href="mailto:hello@kioinvests.com" class="hoverable">hello@kioinvests.com</a>
      </div>
```

Then, immediately after `<canvas class="grain" id="grain"></canvas>` (added in Task 1, right after `<body>`), add:

```html
  <div class="cursor-ring" id="cursorRing"></div>
```

- [ ] **Step 3: Add the cursor-tracking JS**

In `about.html`'s `<script>` block, add this after the grain code from Task 1, before the closing `</script>`:

```js
    // Cursor ring — tracks instantly (no easing/lag), grows on hover
    const ring = document.getElementById('cursorRing');
    document.addEventListener('mousemove', (e) => {
      ring.style.transform = `translate(${e.clientX - 11}px, ${e.clientY - 11}px)`;
    });
    document.querySelectorAll('.hoverable').forEach(el => {
      el.addEventListener('mouseenter', () => ring.classList.add('hover'));
      el.addEventListener('mouseleave', () => ring.classList.remove('hover'));
    });
```

- [ ] **Step 4: Verify in the browser**

Reload `http://localhost:8080/about.html`. Move the mouse around: the default cursor should be gone, replaced by a thin ring that moves with the mouse with no perceptible delay. Hover the `KIO INVESTS` logo, `← Home`, and `hello@kioinvests.com`: the ring should grow from 22px to 36px and brighten. In devtools console, run:
```js
document.querySelectorAll('.hoverable').length
```
Expected: `3`.

- [ ] **Step 5: Commit**

```bash
git add about.html
git commit -m "$(cat <<'EOF'
Add instant-tracking cursor ring to About page

Ring position is set directly and synchronously on mousemove — no
easing/lerp loop. An earlier lagging version was explicitly rejected
in design review.
EOF
)"
```

---

### Task 3: Water-ripple video strip background

**Files:**
- Modify: `about.html` (add `.strip-video` CSS, add `position: relative; z-index: 2` to `.glyph`, add the `<video>` element inside `.strip`)

**Interfaces:**
- Consumes: none from Tasks 1-2.
- Produces: nothing further tasks depend on — this is the last task in this plan.

- [ ] **Step 1: Add `position: relative; z-index: 2` to `.glyph`**

In `about.html`, the `.glyph` rule currently reads (lines 78-85):

```css
    .glyph {
      font-family: 'HanyiSenty', serif;
      font-size: 13vw;
      color: #e8e6e0;
      line-height: 1;
      filter: blur(calc((100 - var(--pct, 4)) * 0.18px)) brightness(calc(0.3 + var(--pct, 4) * 0.007));
      opacity: calc(0.35 + var(--pct, 4) * 0.0065);
    }
```

Change it to:

```css
    .glyph {
      position: relative;
      z-index: 2;
      font-family: 'HanyiSenty', serif;
      font-size: 13vw;
      color: #e8e6e0;
      line-height: 1;
      filter: blur(calc((100 - var(--pct, 4)) * 0.18px)) brightness(calc(0.3 + var(--pct, 4) * 0.007));
      opacity: calc(0.35 + var(--pct, 4) * 0.0065);
    }
```

- [ ] **Step 2: Add the `.strip-video` CSS**

Immediately after the (now-modified) `.glyph` rule, insert:

```css
    .strip-video {
      position: absolute;
      inset: 0;
      width: 100%;
      height: 100%;
      object-fit: cover;
      filter: grayscale(1) brightness(0.35) contrast(1.1);
    }
```

- [ ] **Step 3: Add the `<video>` element**

In `about.html`, the strip currently reads:

```html
    <div class="strip">
      <div class="glyph" id="glyph">靜</div>
    </div>
```

Change it to:

```html
    <div class="strip">
      <video class="strip-video" autoplay muted loop playsinline>
        <source src="drop.mp4" type="video/mp4">
      </video>
      <div class="glyph" id="glyph">靜</div>
    </div>
```

- [ ] **Step 4: Verify in the browser**

Reload `http://localhost:8080/about.html`. In devtools console, run:
```js
const v = document.querySelector('.strip-video'); await new Promise(r => setTimeout(r, 1500)); [v.readyState, v.paused, v.currentTime, v.error]
```
Expected: `readyState` is `4`, `paused` is `false`, `currentTime` is greater than `0` and increasing on repeated calls, `error` is `null`. Then visually confirm: the strip background shows a dim, grayscale, slow-motion water ripple behind the 靜 glyph, not a flat black rectangle.

Scroll to the bottom of the page and confirm the glyph is still legible on top of the video once fully resolved (per the existing blur-resolve behavior), and that the video keeps looping the whole time (check `currentTime` again after scrolling — it should still be advancing/looping, not stalled).

- [ ] **Step 5: Commit**

```bash
git add about.html
git commit -m "$(cat <<'EOF'
Add water-ripple video background to About page strip

Uses drop.mp4 (previously unused anywhere in the site) as a dimmed,
desaturated, looping background behind the glyph — a single drop
rippling outward as a literal expression of the manifesto's patience
theme, and avoids reusing rocks.mp4/waterfall1.mp4 which are already
each page's own established asset.
EOF
)"
```
