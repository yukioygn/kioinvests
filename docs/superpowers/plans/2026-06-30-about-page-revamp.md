# About Page Revamp Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the unfinished, never-committed `about.html` draft (white/light two-column layout) with a new, fully dark-themed manifesto-style About page matching the rest of the site's design system, featuring a scroll-revealing 靜 calligraphy character as its signature visual element.

**Architecture:** Single self-contained file, `about.html`, following the project's existing pattern (`CLAUDE.md`): all CSS and JS inline, no shared stylesheet/script, no build step. Two-zone flex layout — a sticky 20vw left strip holding the signature glyph, and an 80vw right column holding nav, manifesto content, and footer.

**Tech Stack:** Plain HTML/CSS/JS. No new dependencies. Reuses the existing `HanyiSenty` font file (`Hanyi Senty Vimalakirti Regular.ttf`, already in the project root, already used by `index.html`).

## Global Constraints

- Background `#0a0a0a`, text `#e8e6e0`, muted `rgba(232, 230, 224, 0.45–0.55)` — exact match to the rest of the site (per spec `docs/superpowers/specs/2026-06-30-about-page-revamp-design.md`).
- All manifesto statement text is italic Georgia, `font-weight: 400`, normal letter-spacing (no negative tracking) — matches `.hero-tagline` / `.pillar-title` / `.lineage-text` / `.invitation-headline` in `index.html`.
- Nav matches the case-study page pattern (`soc.html:22-50`): `KIO INVESTS` logo (system-ui, 1.1rem, letter-spacing 0.08em) + `← Home` back-link (system-ui, 0.85rem, `rgba(255,255,255,0.4)`, hover `#e8e6e0`), `padding: 1rem 4rem`, `border-bottom: 0.5px solid rgba(255,255,255,0.1)`.
- Footer matches `index.html:672-679,951-953` exactly: `padding: 2rem 4rem`, `border-top: 0.5px solid rgba(255,255,255,0.08)`, system-ui, `0.75rem`, color `rgba(232,230,224,0.25)`, letter-spacing `0.08em`, text "Kio Invests © 2026".
- No portrait, no named founder, no biographical details — anonymous manifesto voice only.
- No new image assets — the only visual element besides typography is the `HanyiSenty`-rendered 靜 character.
- This project has no test framework or build step — verification is manual, in a browser, served via `python3 -m http.server 8080` (per `CLAUDE.md`).

---

### Task 1: Build `about.html`

**Files:**
- Create: `about.html` (replaces the existing untracked draft entirely)

**Interfaces:**
- Consumes: `Hanyi Senty Vimalakirti Regular.ttf` (existing font file in project root, same relative path used by `index.html:17`).
- Produces: a page reachable at `about.html`, linked from `index.html`'s existing nav (`index.html:723`, already points here — no change needed there). The page's own nav links back to `index.html`.

- [ ] **Step 1: Write `about.html` in full**

```html
<!DOCTYPE html>
<html lang="en">

<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>About — Kio Invests</title>
  <style>
    * {
      margin: 0;
      padding: 0;
      box-sizing: border-box;
    }

    @font-face {
      font-family: 'HanyiSenty';
      src: url('Hanyi Senty Vimalakirti Regular.ttf') format('truetype');
      font-weight: normal;
      font-style: normal;
    }

    body {
      background: #0a0a0a;
      color: #e8e6e0;
      font-family: 'Georgia', serif;
      -webkit-font-smoothing: antialiased;
    }

    /* ── Nav (matches case-study page pattern) ── */
    nav {
      padding: 1rem 4rem;
      display: flex;
      justify-content: space-between;
      align-items: center;
      border-bottom: 0.5px solid rgba(255, 255, 255, 0.1);
    }

    .logo {
      font-family: system-ui, sans-serif;
      font-size: 1.1rem;
      letter-spacing: 0.08em;
      color: #e8e6e0;
      text-decoration: none;
    }

    .back-link {
      color: rgba(255, 255, 255, 0.4);
      text-decoration: none;
      font-family: system-ui, sans-serif;
      font-size: 0.85rem;
      letter-spacing: 0.05em;
      transition: color 0.2s;
    }

    .back-link:hover {
      color: #e8e6e0;
    }

    /* ── Two-zone layout ── */
    .frame {
      display: flex;
    }

    .strip {
      position: sticky;
      top: 0;
      width: 20vw;
      height: 100vh;
      overflow: hidden;
      background: #050505;
      border-right: 0.5px solid rgba(255, 255, 255, 0.08);
      flex-shrink: 0;
      display: flex;
      align-items: center;
      justify-content: center;
    }

    .glyph {
      font-family: 'HanyiSenty', serif;
      font-size: 13vw;
      color: #e8e6e0;
      line-height: 1;
      -webkit-mask-image: linear-gradient(to top, #000 calc(var(--pct, 4) * 1%), transparent calc(var(--pct, 4) * 1% + 10%));
      mask-image: linear-gradient(to top, #000 calc(var(--pct, 4) * 1%), transparent calc(var(--pct, 4) * 1% + 10%));
    }

    .main {
      width: 80vw;
    }

    /* ── Manifesto beats ── */
    .beat {
      min-height: 92vh;
      display: flex;
      flex-direction: column;
      justify-content: center;
      padding: 0 4rem;
    }

    .beat.indent-1 { padding-left: 4rem; }
    .beat.indent-2 { padding-left: 9rem; }
    .beat.indent-3 { padding-left: 4rem; }

    .opener {
      font-weight: 400;
      font-style: italic;
      font-size: clamp(3rem, 6.5vw, 5.8rem);
      line-height: 1.1;
      max-width: 15ch;
      color: #e8e6e0;
    }

    .line {
      font-weight: 400;
      font-style: italic;
      font-size: clamp(1.9rem, 3.8vw, 3rem);
      line-height: 1.2;
      max-width: 17ch;
      color: #e8e6e0;
    }

    .line.small {
      font-size: clamp(1.3rem, 2.3vw, 1.7rem);
      color: rgba(232, 230, 224, 0.55);
      max-width: 24ch;
      line-height: 1.55;
    }

    .closing-label {
      font-family: system-ui, sans-serif;
      font-size: 0.78rem;
      letter-spacing: 0.1em;
      text-transform: uppercase;
      color: rgba(232, 230, 224, 0.4);
      margin-bottom: 1.5rem;
    }

    .closing a {
      display: inline-block;
      color: #e8e6e0;
      font-family: 'Georgia', serif;
      font-style: italic;
      font-size: 1.8rem;
      text-decoration: none;
      border-bottom: 0.5px solid rgba(232, 230, 224, 0.3);
    }

    /* ── Footer (matches index.html exactly) ── */
    footer {
      padding: 2rem 4rem;
      border-top: 0.5px solid rgba(255, 255, 255, 0.08);
      font-family: system-ui, sans-serif;
      font-size: 0.75rem;
      color: rgba(232, 230, 224, 0.25);
      letter-spacing: 0.08em;
    }

    @media (max-width: 900px) {
      .strip {
        display: none;
      }
      .main {
        width: 100vw;
      }
      .beat.indent-1, .beat.indent-2, .beat.indent-3 {
        padding-left: 4rem;
      }
    }
  </style>
</head>

<body>

  <div class="frame">
    <div class="strip">
      <div class="glyph" id="glyph">靜</div>
    </div>

    <div class="main">
      <nav>
        <a href="index.html" class="logo">KIO INVESTS</a>
        <a href="index.html" class="back-link">← Home</a>
      </nav>

      <div class="beat indent-1">
        <h1 class="opener">Most capital is managed by people paid to do something.</h1>
      </div>

      <div class="beat indent-2">
        <p class="line">We hold few positions, and we hold them for a long time.</p>
      </div>

      <div class="beat indent-1">
        <p class="line small">Not because we are slow — because conviction takes years to be vindicated, and we are willing to wait for the vindication rather than the applause.</p>
      </div>

      <div class="beat indent-3">
        <p class="line">The work is mostly waiting.</p>
      </div>

      <div class="beat indent-1">
        <p class="line small">No newsletter. No quarterly letter. No noise. If something changes, the case studies change. That is the only communication you should expect from us.</p>
      </div>

      <div class="beat indent-2 closing">
        <p class="closing-label">Get in touch</p>
        <a href="mailto:hello@kioinvests.com">hello@kioinvests.com</a>
      </div>

      <footer>Kio Invests © 2026</footer>
    </div>
  </div>

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

</body>

</html>
```

Note on the `<768px>` breakpoint: the 20vw sticky strip is hidden below 900px (matching the only other responsive breakpoint in the codebase, `index.html:682`) since there isn't enough horizontal room for both the glyph strip and readable manifesto text on mobile — the manifesto content remains fully readable without it.

- [ ] **Step 2: Serve the site locally**

Run: `cd /Users/yukio/Desktop/kioinvests && python3 -m http.server 8080` (skip if already running from prior work).

- [ ] **Step 3: Verify the font loads correctly**

Open `http://localhost:8080/about.html` in a browser. In devtools console, run:
```js
await document.fonts.ready;
[...document.fonts].find(f => f.family.includes('HanyiSenty'))?.status
```
Expected: `"loaded"`. (This exact check caught a real bug during design review — a wrong asset path silently fell back to a system font — so it must be re-verified here against the real file, not assumed from the mockup.)

- [ ] **Step 4: Verify the scroll-reveal signature element**

With the page at the top, the 靜 glyph in the left strip should show only a thin sliver near the bottom (mask at ~4%). Scroll slowly to the bottom of the page. Expected: the glyph progressively reveals from the bottom up, fully visible (mask at 100%) once you reach the closing "Get in touch" section.

- [ ] **Step 5: Verify nav and links**

- Click the `KIO INVESTS` logo: navigates to `index.html`.
- Click `← Home`: navigates to `index.html`.
- From `index.html`, click `About` in the nav (or scroll to reveal it per the homepage's scroll-triggered nav behavior): navigates to `about.html`.
- Click `hello@kioinvests.com`: opens the system mail client with that address (or at least shows the correct `mailto:` href on hover in devtools).

- [ ] **Step 6: Verify responsive layout**

In devtools, toggle device toolbar to a narrow width (e.g. 600px). Expected: the left strip (and glyph) disappears, manifesto text remains fully readable with consistent left padding, no horizontal scrollbar.

- [ ] **Step 7: Check console for errors**

Open devtools console, reload the page, scroll through fully. Expected: no errors logged.

- [ ] **Step 8: Commit**

```bash
git add about.html
git commit -m "$(cat <<'EOF'
Replace About page with dark-themed manifesto design

Scraps the unfinished white/light draft in favor of a layout matching
the rest of the site: italic Georgia manifesto statements with
asymmetric placement, and a scroll-revealing 靜 calligraphy character
(same glyph and font as the homepage hero) as the page's signature
element.
EOF
)"
```
