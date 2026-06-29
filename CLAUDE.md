# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Running locally

No build step. Open any HTML file directly in a browser, or serve the directory with a local server to avoid CORS issues when the chart pages fetch CSV files:

```bash
python3 -m http.server 8080
```

The chart pages use `Papa.parse(..., { download: true })` to fetch CSVs, which requires a server (not `file://`).

## Updating price data

```bash
./update_prices.sh
```

Fetches 10 years of daily close prices for all 7 tickers from Yahoo Finance and overwrites the CSV files. Requires internet access and Python 3.

## Architecture

**Static site — no framework, no bundler.** All CSS and JS live inline in each HTML file. There are no shared stylesheets or external scripts other than two CDN dependencies loaded per-case-page:
- `Chart.js 4.4.1` — price charts
- `PapaParse 5.4.1` — CSV parsing

**Two page types:**

1. **Homepage (`index.html`)** — cinematic landing page with: dual-video crossfade hero, WebGL ink smoke effect over the tortoise image grid (GLSL fragment shader using fbm noise), waterfall section with A/B audio crossfade triggered by `IntersectionObserver`, a 7-card draggable carousel with ticker nav, and `IntersectionObserver`-driven `.fade-in` animations throughout.

2. **Case study pages (`soc.html`, `ewbc.html`, `uec.html`, `nbr.html`)** — each is self-contained with: a metrics bar, a Chart.js line chart loading from the corresponding `*_prices.csv`, and a 3-pillar analysis section. Charts are annotated via a custom `verticalLinePlugin` that draws entry/exit markers and key event labels directly on the canvas using `afterDraw`. Tooltips are disabled; all chart interactivity is custom-drawn.

**Chart data flow:** Each case page hardcodes `ENTRY_DATE`, `ENTRY_PRICE`, and `START_DATE` constants (plus `EXIT_DATE`/`EXIT_PRICE` and `KEY_EVENTS` array where applicable). PapaParse downloads the CSV, filters to `START_DATE`, and Chart.js renders it. The `findDateIdx` helper does nearest-date matching to handle weekends/holidays.

**Design system (no file, lives in each page's `<style>` block):**
- Background: `#0a0a0a`; text: `#e8e6e0`; muted: `rgba(232, 230, 224, 0.45)`
- Accent green (gains, entry dot): `#7eb87e`
- Exit orange: `#ff6b35`; event blue: `#6a9fd8`; sell red: `#c97c6a`
- Fonts: `Georgia` serif for body, `system-ui` sans for labels/nav, `HanyiSenty` (local TTF) for the hero Chinese character on the homepage only

**Nav behavior (`index.html`):** Fixed nav is `opacity: 0` by default, becomes `.visible` when `scrollY > 80` or when mouse hovers within 80px of the top.

**Video crossfade pattern (used in two places):** Two `<video>` elements (A/B) share the same source. `timeupdate` watches the active one; when within 1.5s of end, it starts the inactive video, crossfades opacity, then swaps the active reference. Same pattern drives the waterfall audio with `setInterval`-based volume ramping.

**Image naming convention:** Images are named `{ticker_prefix}{n}.{ext}` — e.g. `soc0.jpg`, `ewb1.png`, `nabors3.png`, `uec0.png`, `baba4.png`, `lulu2.png`, `goog5.png`. The homepage carousel uses `{ticker}0` as the card image.

**Adding a new case study page:** Follow the pattern of `ewbc.html` or `nbr.html`. Hardcode the chart constants at the top of the `<script>` block, add the corresponding `{ticker}_prices.csv` to `update_prices.sh`, and add a card to the `#carouselTrack` in `index.html` plus its ticker to the `tickers` array.
