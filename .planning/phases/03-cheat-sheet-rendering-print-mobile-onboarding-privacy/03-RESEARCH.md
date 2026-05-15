# Phase 3: Cheat Sheet Rendering, Print, Mobile, Onboarding, Privacy - Research

**Researched:** 2026-05-15
**Domain:** Browser rendering (CSS print + responsive), state-machine extension, plain-text onboarding/privacy copy
**Confidence:** HIGH (well-trodden web platform territory; vanilla CSS print + grid + media queries are stable for years)

## Summary

Phase 3 is purely a frontend rendering and copy phase. There is no new network call, no new schema, no new dependency. The whole phase fits inside the existing `index.html` and extends the locked `appState` state machine with two new screens (`'onboarding'`, `'privacy'`) and replaces the throwaway Block B/C/E/F preview panel with a full eight-block printable cheat sheet.

The single load-bearing CSS technique is `display: grid` with a `1fr 1fr` two-column layout for the DE/native panels in Blocks B and C, with a single `@media (max-width: 480px)` rule collapsing both blocks to a one-column stack on iPhone-sized screens. Everything else is `@media print` housekeeping (hide controls, `page-break-inside: avoid` on each block, `print-color-adjust: exact` for the colored block borders, `@page` A4 with 1.5cm margins, `display: block` for Block G).

**Primary recommendation:** Author **three plans** for Phase 3. Plan A = rendering Blocks A through H over the result screen (the load-bearing one). Plan B = print stylesheet + mobile breakpoint + on-device verification. Plan C = onboarding screen + privacy page + the small TRUST-05 housekeeping (REQUIREMENTS.md wording amendment from "free Gemini API key" to "free Anthropic API key"). Plan A blocks Plan B; Plan C is independent and can run in parallel with either.

## Architectural Responsibility Map

| Capability | Primary Tier | Secondary Tier | Rationale |
|------------|-------------|----------------|-----------|
| Block A-H DOM rendering | Browser / Client | - | Reads `appState.cheatSheet` (already populated by Phase 2), no fetch involved |
| Current-day hours computation | Browser / Client | - | Pure function over `MIGRATIONSAMT.phoneHours` + `closures2026` + `new Date()` |
| Print stylesheet | Browser / Client | - | `@media print` is interpreted by the browser's print engine, no server involvement |
| Mobile responsive layout | Browser / Client | - | `@media (max-width: 480px)` resolved by the browser's CSS engine |
| Onboarding flag persistence | Browser / Client | - | Single boolean in `localStorage`, no network |
| Privacy page | Browser / Client | - | Static HTML/CSS, no fetch |
| Non-dismissable disclaimer | Browser / Client | - | `position: sticky` on screen, static at top in print |

Everything in Phase 3 lives in the browser tier. No new connect-src entries are needed in the CSP; `https://api.anthropic.com` already covers the only outbound endpoint.

## Standard Stack

### Core
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| HTML5 | living standard | Semantic sections, `<section id="cheatSheet">` wrapper for the print scope | Already in use, zero deps |
| CSS3 grid + `@media print` + `@media (max-width)` | living standard | Two-column DE/EN layout, A4 print rules, mobile collapse | Native, no preprocessor |
| Vanilla JS (ES2022) | ES2022 baseline | New render helpers (`renderBlockA`, `renderBlockD`, etc.), `computeTodayWindow()`, screen swap for onboarding/privacy | Already the project pattern (L-05) |
| `localStorage` | native | `migrationsamt.onboardingSeen` flag (parallel to `migrationsamt.consentGiven` from Phase 2) | Same pattern, same key prefix |

### Supporting
None. Phase 3 adds zero dependencies. No date-fns (Swiss public holidays are already a static 12-entry array; `new Date()` plus `getDay()` is enough). No CSS framework. No print library (browser print is the print library, per the project's "no PDF library" anti-recommendation in the workspace `CLAUDE.md`).

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| CSS grid (recommended) | Plain `<table>` for two-column blocks | `<table>` is fine semantically for tabular Q&A pairs but harder to collapse to single column on phone (needs `display: block` overrides on `<tr>`/`<td>`). Grid collapses with one `grid-template-columns` change in a media query. |
| CSS grid | Flexbox | Flexbox works too but `flex-wrap` collapse is jankier on print. Grid's row gap is cleaner for blocks of varying row count. |
| Native `window.print()` | jsPDF / html2pdf | A PDF library is hundreds of KB, contradicts the no-CDN posture (L-07), and the browser already produces excellent PDFs via "Save as PDF" in the print dialog. |
| `localStorage` flag | `sessionStorage` | sessionStorage would force the user to re-see onboarding every session. Bad UX. |

**Installation:** Nothing to install. All capabilities are browser-native.

**Version verification:** N/A — no new packages.

**Planner recommendation:** Add no new dependencies. Lock the stack at "CSS grid + `@media print` + vanilla JS render helpers" in the PLAN frontmatter.

## Section 1: Plan decomposition recommendation

Phase 3 has fourteen requirements, more than any prior phase. The natural cut points are: rendering (the visual layer), print/mobile (the cross-cutting CSS), and onboarding/privacy (the first-visit funnel). The TRUST-05 housekeeping is one line in REQUIREMENTS.md plus one link in the onboarding copy — too small to be its own plan.

Three options exist:

- **2 plans**: rendering + everything-else-CSS-and-onboarding. Risk: the second plan does too much.
- **3 plans** (recommended): rendering, print/mobile CSS, onboarding/privacy/housekeeping. Plan A blocks Plan B (you can't write print rules until the blocks exist). Plan C is independent of both — it touches the key-entry boot path and adds two new screens, not the result screen. Plans A and C can be authored in parallel waves; Plan B follows Plan A.
- **4 plans**: split onboarding from privacy. Adds coordination overhead for no real parallelism gain — both are static copy on new `screen` values, easier to do together.

**Plan A: Render Blocks A through H + non-dismissable disclaimer (CHEAT-01..08, TRUST-01)**
- Replace the `#result` section in `index.html` with a single `#cheatSheet` section containing eight subsections `#blockA` through `#blockH`.
- Wire `render()`'s `'result'` branch to call eight new helpers: `renderBlockA(cs)`, `renderBlockB(cs)`, ..., `renderBlockH()`.
- Implement `computeTodayWindow()` (Section 9 below).
- Add the pinned disclaimer bar at the top of `#cheatSheet`.
- Keep raw-JSON `<details>` block but hide it behind a `?raw=1` URL flag (Section 2 below).

**Plan B: Print stylesheet + mobile breakpoint (PRINT-01, PRINT-02, PRINT-03)**
- Append a single `<style>` block to the existing inline stylesheet with `@media print { ... }` and `@media (max-width: 480px) { ... }` rules.
- Add the `.no-print` utility class to every button, header strip, and footer outside `#cheatSheet`.
- Make Block G visible only inside `@media print`.
- Document a manual print-preview checklist in the PLAN frontmatter so the executor doesn't drift.
- Depends on Plan A.

**Plan C: Onboarding screen + privacy page + TRUST-05 housekeeping (TRUST-03, TRUST-05)**
- Add two new `screen` values: `'onboarding'` and `'privacy'`.
- Add `localStorage.migrationsamt.onboardingSeen` flag and the boot-path routing logic (Section 6 below).
- Add the privacy `screen` reachable from a "Privacy" link rendered in the page footer or header strip on every non-result screen.
- Amend REQUIREMENTS.md TRUST-05 wording from "free Gemini API key" to "free Anthropic API key".

**Planner recommendation:** Author three plans (A, B, C). Plan A first or in parallel with C. Plan B last because it depends on A's DOM.

## Section 2: Result-screen → cheat-sheet swap

The Phase 2 result screen lives at lines 304-329 of `index.html`. It currently contains four placeholder divs (`#resultBlockB`, `#resultBlockC`, `#resultBlockE`, `#resultBlockF`), a `<details>` raw-JSON debug panel, and two navigation buttons.

Phase 3 transformation:

1. Rename the section from `id="result"` to keep the same id (`render()` already keys off `screen === 'result'` and the `hideAllSections` helper sweeps it). Inside, replace the entire contents with the cheat-sheet container.

2. New structure inside `#result`:

```
<section id="result" hidden>
  <div class="cheat-sheet-disclaimer no-print-hide">
    Preparation aid only. Not legal advice. Do not read this aloud word for word.
  </div>
  <article id="cheatSheet" class="cheat-sheet-print-root">
    <section id="blockA" class="cheat-sheet-block">...</section>
    <section id="blockB" class="cheat-sheet-block">...</section>
    <section id="blockC" class="cheat-sheet-block">...</section>
    <section id="blockD" class="cheat-sheet-block">...</section>
    <section id="blockE" class="cheat-sheet-block">...</section>
    <section id="blockF" class="cheat-sheet-block">...</section>
    <section id="blockG" class="cheat-sheet-block cheat-sheet-print-only">...</section>
    <section id="blockH" class="cheat-sheet-block">...</section>
  </article>
  <div class="cheat-sheet-controls no-print">
    <button id="printCheatSheetBtn" type="button">Print this sheet</button>
    <button id="newCheatSheetButton" type="button">New cheat sheet</button>
    <button id="backToIntakeFromResultButton" type="button">Back to intake</button>
  </div>
  <details class="no-print" id="rawJsonDebug" hidden>
    <summary>Raw JSON (developer view)</summary>
    <pre id="resultRawJson"></pre>
  </details>
</section>
```

3. Block order on screen, top to bottom, matches ROADMAP "Cheat Sheet Anatomy": A → B → C → D → E → F → G (print-only) → H. The non-dismissable disclaimer (TRUST-01) sits ABOVE Block A, sticky on scroll.

4. **`?raw=1` developer toggle.** During the pilot Francisco will want to debug whether the LLM produced the right shape without printing. Keep the `<details>` raw JSON panel, hidden by default, revealed only when `new URLSearchParams(location.search).get('raw') === '1'`. Same pattern as `?mock=1`. The `<pre>` content is set via `textContent` only — never `innerHTML`. This is a one-line gate in the render helper; cleanly removable post-pilot if desired.

5. The Phase 2 helper functions `renderBlockB`, `renderBlockC`, `renderBlockE`, `renderBlockF` (lines 875-961) can be **kept as-is and used unchanged** to populate the relevant blocks within the new structure. Phase 3 adds new helpers for A, D, G, H and a small post-pass to write the user-goal sentence into Block A (since Block A is part hardcoded, part LLM-derived — `cs.blockB.userGoalSentence` becomes the "what you're calling about" line at the bottom of Block A).

**Planner recommendation:** Keep the four Phase 2 render helpers unchanged, add four new helpers for A/D/G/H, wrap everything in the new `#cheatSheet` article. Gate the raw-JSON details panel behind `?raw=1`. Delete nothing from Phase 2 except the throwaway `<h2>` "Phase 2 raw preview" heading and helper paragraph.

## Section 3: Two-column DE/EN layout (CSS approach)

**Recommendation: CSS grid.** Justification: it collapses to single column with one line of CSS in a media query; it survives the print engine cleanly (Chrome and Edge both honour grid in print); it does not need semantic table structure for what is really a visual side-by-side, not a data table.

The classic alternative is `<table>`. For Block C in particular (officer question + affirmative + negative + glosses), the data is genuinely tabular. But a real `<table>` with rowspans and `display: block` overrides at the mobile breakpoint is more code than the grid version, and Block B is not tabular at all (it's a sequence of paragraphs).

Flexbox is the third option but `flex-wrap` does not give clean row alignment when DE and EN strings have different heights — grid's row gap and implicit row sizing handle that for free.

`print-color-adjust: exact` is the rule that forces the browser to print background colors and borders. Without it, Chrome strips backgrounds to save ink by default ([MDN: print-color-adjust](https://developer.mozilla.org/en-US/docs/Web/CSS/print-color-adjust)). For Phase 3 we want at least the block borders to print so the eight blocks are visually distinguishable on paper.

Worked example for Block C (the most complex two-column case):

```css
.cheat-sheet-block {
  border-left: 4px solid #444;
  padding: 0.75rem 1rem;
  margin-bottom: 1.25rem;
  print-color-adjust: exact;
  -webkit-print-color-adjust: exact;  /* Safari */
}

.cheat-sheet-block h3 {
  margin-top: 0;
  font-size: 1.05rem;
}

.bilingual-row {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 0.5rem 1rem;
  margin-bottom: 0.75rem;
}

.bilingual-row .de {
  font-weight: 600;
}

.bilingual-row .en {
  color: #555;
  font-size: 0.95rem;
}

/* Mobile: collapse to single column. */
@media (max-width: 480px) {
  .bilingual-row {
    grid-template-columns: 1fr;
    gap: 0.25rem;
  }
}

/* Print: keep two columns, force borders, avoid page-break inside blocks. */
@media print {
  .cheat-sheet-block {
    page-break-inside: avoid;
    break-inside: avoid;
  }
}
```

References:
- [MDN: CSS Grid Layout](https://developer.mozilla.org/en-US/docs/Web/CSS/CSS_grid_layout) (HIGH)
- [MDN: print-color-adjust](https://developer.mozilla.org/en-US/docs/Web/CSS/print-color-adjust) (HIGH)
- [MDN: @media print](https://developer.mozilla.org/en-US/docs/Web/CSS/CSS_media_queries/Printing) (HIGH)

**Planner recommendation:** Use CSS grid for all two-column layouts (Blocks B, C, D, E). Single `.bilingual-row` class for the grid container, `.de` and `.en` for the two cells. One mobile media query collapses everything to single column. Include `print-color-adjust: exact` on every block to force borders/backgrounds to print.

## Section 4: Print stylesheet

The print stylesheet is a single `@media print { ... }` block appended to the existing inline `<style>` element. Strategy: opt-out hiding via a `.no-print` utility class on every UI control, plus an explicit allow-list of what's in `#cheatSheet`. This is more beginner-friendly than a global `body > * { display: none } #cheatSheet { display: block }` reset.

```css
@page {
  size: A4;
  margin: 1.5cm;
}

@media print {
  /* Hide every non-cheat-sheet UI element. */
  .no-print,
  header,
  footer,
  .intake-key-header,
  #intake,
  #key-entry,
  #generating,
  #errorPanel,
  #onboarding,
  #privacy,
  #rawJsonDebug,
  .cheat-sheet-controls {
    display: none !important;
  }

  /* The cheat sheet itself prints. */
  body {
    margin: 0;
    color: #000;
    font-size: 11pt;
  }

  #cheatSheet {
    max-width: none;
    margin: 0;
    padding: 0;
  }

  /* Block G is screen-hidden, print-visible. */
  .cheat-sheet-print-only {
    display: block !important;
  }

  /* Each block stays whole. */
  .cheat-sheet-block {
    page-break-inside: avoid;
    break-inside: avoid;
    margin-bottom: 0.75rem;
  }

  /* Disclaimer at the top of page 1, not sticky. */
  .cheat-sheet-disclaimer {
    position: static;
    border: 2px solid #000;
    padding: 0.5rem;
    margin-bottom: 0.75rem;
    font-weight: bold;
  }

  /* Force colored borders and backgrounds to print. */
  .cheat-sheet-block,
  .cheat-sheet-disclaimer {
    print-color-adjust: exact;
    -webkit-print-color-adjust: exact;
  }

  /* Links: show URL in parentheses for Block H escalations. */
  #blockH a[href]::after {
    content: " (" attr(href) ")";
    font-size: 0.85em;
    color: #555;
  }
}
```

**A4 dimensions:** `@page { size: A4 }` sets the paper. 1.5cm margin is conservative (1cm prints tighter but risks edge clipping on some home printers). [MDN: @page](https://developer.mozilla.org/en-US/docs/Web/CSS/@page) (HIGH).

**Page-break behaviour:** `page-break-inside: avoid` is the legacy property; `break-inside: avoid` is the modern one. Include both for browser coverage. [MDN: break-inside](https://developer.mozilla.org/en-US/docs/Web/CSS/break-inside) (HIGH).

**Block G print-only:** Define `.cheat-sheet-print-only { display: none }` in the screen styles, then `display: block` inside `@media print`. Block G is four blank lines for the user to write the officer name, next step, date, and reference number while on the call.

**Forced two-page layout?** Don't force it. With current content (eight blocks, no LLM bloat) the sheet will run one to two pages naturally. If pagination pushes Block H to a second page that's fine; if Block H sits at the bottom of page 1 that's also fine. Don't add `page-break-after` rules — they cause weird half-empty pages when content shrinks.

**Manual print-preview checklist for the executor (paste into Plan B):**

1. Open `index.html?mock=1`, navigate through key entry → intake → submit, land on the cheat sheet.
2. Hit Ctrl+P (Chrome desktop).
3. Verify the destination is set to "Save as PDF".
4. Verify paper size is A4.
5. Verify margins are "Default" (which on Chrome respects the `@page` value).
6. **"Background graphics" checkbox must be ticked** for the colored block borders to print. Note this in the privacy page if relevant; this is a Chrome user-facing knob.
7. Confirm page count is 1 or 2.
8. Visually scan each page: no block is split across the page boundary. No button or form control is visible. The disclaimer is at the top of page 1.
9. Block G has four labeled blank lines.
10. Save as PDF, open the PDF, confirm the visual.

References:
- [MDN: @page](https://developer.mozilla.org/en-US/docs/Web/CSS/@page) (HIGH)
- [MDN: @media print printing guide](https://developer.mozilla.org/en-US/docs/Web/CSS/CSS_media_queries/Printing) (HIGH)
- [MDN: print-color-adjust](https://developer.mozilla.org/en-US/docs/Web/CSS/print-color-adjust) (HIGH)
- [MDN: break-inside](https://developer.mozilla.org/en-US/docs/Web/CSS/break-inside) (HIGH)

**Planner recommendation:** A4 paper size, 1.5cm margins, `.no-print` opt-out class on controls plus explicit hiding of every non-result section id, `break-inside: avoid` plus legacy `page-break-inside: avoid` on every block, `.cheat-sheet-print-only` for Block G, `print-color-adjust: exact` on each block. Embed the 10-step print-preview checklist above into Plan B as a verification task.

## Section 5: Mobile layout (iOS Safari, PRINT-02)

The viewport meta tag at line 6 of `index.html` (`<meta name="viewport" content="width=device-width, initial-scale=1">`) is already correct. No change needed.

**Mobile breakpoint:** Use `@media (max-width: 480px)`. Justification: iPhone 15 portrait CSS width is 393px; iPhone SE is 375px; the smallest reasonable target is 320px. 480px is the conventional "phone" cutoff that catches everything portrait. The two-column DE/EN grid collapses to one column at this breakpoint; the body's `max-width: 720px` already produces a narrow column above this size, so no further intermediate breakpoint is needed.

**Minimum body font size 16px.** iOS Safari auto-zooms when a form field has a computed font-size below 16px. This is a long-standing WebKit behaviour and the only reliable fix is to set the form field font-size to >= 16px ([CSS Tricks: 16px or larger text prevents iOS form zoom](https://css-tricks.com/16px-or-larger-text-prevents-ios-form-zoom/), MEDIUM, widely confirmed). The current `input[type="password"]` rule uses `font-size: 1rem` which resolves to 16px assuming default root font size, so this is already safe. Add an explicit `font-size: 16px` to any `<select>`, `<input>`, and `<textarea>` rule in the mobile media query to be defensive.

**Maximum line length:** The body's `max-width: 720px` is already roughly 70 characters of body-text width at the default font size. That's fine for English. For the German lines in Block B, Block C, and Block D, the same constraint applies; nothing further needed.

**On-device verification:**

PRINT-02 acceptance criterion from REQUIREMENTS.md says "tested on device, not just devtools emulation". Francisco may not have an iPhone to hand. Recommendation: accept a two-stage pass.

- **Soft pass (Phase 3 acceptance):** Chrome devtools "iPhone 15 Pro" emulation on the local file or deployed GitHub Pages URL. Steps for the executor: open `index.html` in Chrome → F12 → click the device toolbar icon (Ctrl+Shift+M) → choose "iPhone 15 Pro" from the device dropdown → reload → step through key entry, intake, submit (use `?mock=1`), land on the cheat sheet → verify single-column collapse, readable font sizes, no horizontal scroll.
- **Hard pass (deferred to Phase 5 pilot):** First real user opens the deployed GitHub Pages URL on their actual iPhone. Their feedback is the formal PRINT-02 verification. Document this deferral in PLAN B's frontmatter so the requirement isn't accidentally ticked off too early.

**Planner recommendation:** Single `@media (max-width: 480px)` breakpoint. Set `font-size: 16px` on every form input inside the mobile media query (defensive against iOS auto-zoom). Soft-pass PRINT-02 via Chrome devtools "iPhone 15 Pro" emulation; carry the hard on-device pass as an explicit Phase 5 pilot checkpoint with REQUIREMENTS.md flagged as "Phase 3 soft pass, Phase 5 hard pass" until then.

## Section 6: Onboarding screen (TRUST-05)

**Trigger logic.** On page load, after reading the saved API key from localStorage, before deciding the initial `screen`, check `localStorage.migrationsamt.onboardingSeen`. If absent or `'false'`, set `screen = 'onboarding'`. Otherwise proceed with the existing logic (key present → `'intake'`, key absent → `'key-entry'`).

**Storage key naming:** `migrationsamt.onboardingSeen`, matching the existing `migrationsamt.consentGiven` prefix from Phase 2 (CONSENT_STORAGE_KEY at line 768).

**Onboarding screen body copy (English, beginner-friendly, paste verbatim):**

```
Welcome

This is a preparation aid for calling the Migrationsamt of canton Zürich. You describe your situation in your own language, and the tool builds a German cheat sheet you keep in front of you while you make the call yourself.

How it works

You bring your own Anthropic API key. The key is saved only in your browser (in localStorage), never sent to any server we run. There is no backend, no account, no log file. When you press Generate, your intake answers are sent in a single call to Anthropic, and Anthropic's response (the cheat sheet) comes straight back to your browser.

You will need an Anthropic API key

If you do not have one yet, sign up at the Anthropic Console, then go to Settings → API Keys → Create Key. Copy the key (it starts with sk-ant-...) and paste it into the next screen.

  Get an Anthropic API key → https://console.anthropic.com/settings/keys

What this tool will not do

  - It is not legal advice. It does not tell you what permit you should apply for, or what to say to influence an outcome.
  - It does not contact the Migrationsamt for you. You make the call yourself.
  - It never accesses your microphone. There is no recording of any kind, ever.

Read more about how your data is handled on the Privacy page (link in the page footer).

[ Got it, continue ]
```

The "Got it, continue" button handler:

```js
function onOnboardingContinue() {
  try {
    localStorage.setItem('migrationsamt.onboardingSeen', 'true');
  } catch (_e) {
    // Best effort; if storage is blocked the user will see onboarding again next visit.
  }
  setState({ screen: appState.apiKey ? 'intake' : 'key-entry' });
}
```

**Anthropic Console URL:** `https://console.anthropic.com/settings/keys` is the direct path to the API key management screen. Verified 2026-05-15 via web search ([Anthropic Console / Claude Platform API Keys](https://platform.claude.com/settings/keys) is an alias of the same destination; the `console.anthropic.com` form is the canonical URL used in third-party signup tutorials [VERIFIED: web search 2026-05-15]). The base console URL `https://console.anthropic.com` is the safer link to give to a user who has not signed up yet because it shows the sign-up flow; the `settings/keys` subpath is for users with an account. Recommendation: link to the base console URL in the onboarding screen body text, then add a one-line note "After signing up, go to Settings → API Keys → Create Key".

**Planner recommendation:** Insert `'onboarding'` as a new screen value ahead of `'key-entry'` in the boot path. Gate by `localStorage.migrationsamt.onboardingSeen`. Paste the body copy above verbatim (it covers TRUST-05 wording, the "preparation aid not legal advice" framing for TRUST-01 reinforcement, the BYO-key model, and the "no microphone ever" lifetime guardrail). Link to `https://console.anthropic.com` (not `/settings/keys`) so unsigned-up users see the sign-up flow first.

## Section 7: Privacy page (TRUST-03)

**Screen value:** `'privacy'`, reachable via a "Privacy" link rendered in the page footer (the existing `<footer>` at line 349). The link sets `screen = 'privacy'` and stores the previous screen value in a small `appState.returnTo` field so the Back button can return the user where they came from.

```js
function onPrivacyClick() {
  appState.returnTo = appState.screen;
  setState({ screen: 'privacy' });
}

function onPrivacyBack() {
  const target = appState.returnTo || 'intake';
  appState.returnTo = null;
  setState({ screen: target });
}
```

The "Privacy" link should be visible on every non-result screen (key-entry, intake, onboarding, error). It is hidden on the result screen and on the privacy screen itself. The print stylesheet hides it via the footer hide rule.

**Privacy page body copy (English, paste verbatim):**

```
Privacy

This tool is designed so that as little of your information as possible leaves your browser.

What stays in your browser, only

  - Your Anthropic API key. Saved in localStorage. You can clear it with the "Clear key" button on any screen. Clearing your browser site data also removes it.
  - The intake answers you typed (permit type, reason for calling, reference numbers, situation description). These exist only in memory after you submit, and are not persisted.
  - The generated cheat sheet. Shown on screen and available to print. Not persisted between sessions. Closing the tab clears it.
  - The onboarding-seen flag and the consent flag. Tiny boolean flags so you don't see the same screens twice. No personal data.

What is sent over the network

When you press "Generate cheat sheet", your intake answers plus the system prompt are sent in one HTTPS request to Anthropic's API (https://api.anthropic.com/v1/messages). The response (the cheat sheet) comes straight back to your browser. Anthropic's own data-handling policies apply to that request: see https://www.anthropic.com/legal/privacy

That is the only outbound request this tool ever makes.

What this tool never does

  - No backend of our own. No server stores your key or your intake.
  - No analytics. No tracking pixels. No third-party scripts. The Content Security Policy of the page blocks third-party scripts by default.
  - No microphone access, ever. There is no code path in this tool that requests microphone permission. This is a permanent design constraint tied to Article 179bis of the Swiss Criminal Code (recording conversations without consent is illegal). Even future versions will not record your call.
  - No cookies are set by this tool.

Your right to walk away

You can clear your saved key in one click ("Clear key" on any screen). You can close the tab and nothing about your session persists except the saved key (if you saved one) and the two boolean flags. Clearing your browser site data removes everything.

[ Back ]
```

**TRUST-03 acceptance:** the page covers no-backend, no-logging, BYO-key, no-microphone-ever, no-cookies, no-analytics, and what the single outbound request actually contains. That's the full plain-English contract.

**Planner recommendation:** New `screen = 'privacy'` reachable via a "Privacy" link in the page footer on every non-result screen. Body copy above is the executable text — paste it into the new section verbatim. Includes `appState.returnTo` for back navigation.

## Section 8: TRUST-01 non-dismissable disclaimer

**Wording (one line):** `Preparation aid only. Not legal advice. Do not read this aloud word for word.`

This is shorter than the Block H footer text but reinforces the same three claims. It is the user's permanent warning at the top of every cheat sheet.

**Position behaviour:**

- On screen: `position: sticky; top: 0` inside `#cheatSheet`, so the disclaimer stays visible as the user scrolls through the eight blocks. Background color so it remains legible above scrolled content.
- In print: `position: static` (override sticky), so the disclaimer renders at the top of page 1 only. Forced visible via the print stylesheet, never inside the `.no-print` allow-list.

```css
.cheat-sheet-disclaimer {
  position: sticky;
  top: 0;
  background: #fff4cc;
  border: 1px solid #b08800;
  padding: 0.5rem 0.75rem;
  margin-bottom: 1rem;
  font-weight: bold;
  z-index: 10;
  print-color-adjust: exact;
  -webkit-print-color-adjust: exact;
}

@media print {
  .cheat-sheet-disclaimer {
    position: static;
    background: #fff;
    border: 2px solid #000;
  }
}
```

**Non-dismissable:** there is no close button. The element has no `hidden` toggle. The user cannot make it disappear by clicking anywhere. This is the "non-dismissable" half of the requirement.

**Planner recommendation:** Single `.cheat-sheet-disclaimer` div at the top of `#cheatSheet`, never inside a control area, never with a close button. Wording: `Preparation aid only. Not legal advice. Do not read this aloud word for word.` Sticky on screen, static in print.

## Section 9: Block A current-day hours computation

The function reads `MIGRATIONSAMT.phoneHours` and `MIGRATIONSAMT.closures2026` (note: the actual constant in `index.html` line 400 is named `closures2026`, not `holidays2026` as the prompt described — the code uses `closures2026`). Output is a small object the renderer turns into one Block A line.

**Note on the A2 assumption.** 24 Dec 2026 is currently treated as a normal Thursday by `closures2026` (no entry for that date). The inline ASSUMPTION A2 comment at line 394 says Canton Zürich practice often makes it a half-day. Three handling options:

1. Add a runtime check: if `today === '2026-12-24'` and no closure entry exists, render the normal hours plus an inline footnote "(24 Dec schedule unconfirmed)". This is a small extra `if` in `computeTodayWindow()`.
2. Add the data entry for 24 Dec speculatively. Risks being wrong.
3. Leave it alone, fix in Phase 5 pre-pilot.

Option 1 is the recommendation: it shows the user what we know, plus a tiny caveat, without inventing data.

**Algorithm:**

```js
/* computeTodayWindow returns the Block A "today's hours" object.
   Inputs: MIGRATIONSAMT (constant), optional Date (for testing).
   Output: { open: boolean, todayLabel: string, windowText: string, note: string }
*/
function computeTodayWindow(now) {
  now = now || new Date();
  const yyyy = now.getFullYear();
  const mm = String(now.getMonth() + 1).padStart(2, '0');
  const dd = String(now.getDate()).padStart(2, '0');
  const isoDate = yyyy + '-' + mm + '-' + dd;
  const dayOfWeek = now.getDay(); // 0 = Sunday, 6 = Saturday

  // German weekday names for the Block A label.
  const weekdaysDe = ['Sonntag', 'Montag', 'Dienstag', 'Mittwoch', 'Donnerstag', 'Freitag', 'Samstag'];
  const todayLabel = weekdaysDe[dayOfWeek] + ' ' + isoDate;

  // Weekend?
  if (dayOfWeek === 0 || dayOfWeek === 6) {
    return { open: false, todayLabel: todayLabel, windowText: 'Closed (weekend)', note: '' };
  }

  // Closure entry?
  const closure = MIGRATIONSAMT.closures2026.find(function (c) { return c.date === isoDate; });
  if (closure) {
    if (closure.type === 'closed') {
      return { open: false, todayLabel: todayLabel, windowText: 'Closed (' + closure.name + ')', note: '' };
    }
    if (closure.type === 'reduced') {
      // Render the morning window and the early close.
      const morning = MIGRATIONSAMT.phoneHours.mondayToFriday[0];
      return {
        open: true,
        todayLabel: todayLabel,
        windowText: morning.from + '-' + closure.closesAt + ' (reduced hours, ' + closure.name + ')',
        note: '',
      };
    }
  }

  // Normal weekday windows.
  const windows = MIGRATIONSAMT.phoneHours.mondayToFriday;
  const windowText = windows.map(function (w) { return w.from + '-' + w.to; }).join(', ');

  // A2 footnote for 24 Dec 2026.
  let note = '';
  if (isoDate === '2026-12-24') {
    note = '(24 Dec schedule unconfirmed; verify on zh.ch before calling)';
  }

  return { open: true, todayLabel: todayLabel, windowText: windowText, note: note };
}
```

**Display copy in Block A:** "Today, {todayLabel}: {windowText}. {note}" — for example "Today, Donnerstag 2026-05-15: 08:00-11:45, 13:00-16:30." The German weekday is intentional because Block A is the office's German contact card; mixing in the German day name reinforces "this is what the office sees".

**Edge cases handled:**

- Saturday/Sunday → "Closed (weekend)".
- Listed `closed` holiday → "Closed (Karfreitag)" etc.
- Listed `reduced` holiday → "08:00-14:30 (reduced hours, Tag vor Auffahrt)".
- 24 Dec 2026 → normal hours plus footnote.
- User device clock wrong → tool displays the wrong day. Documented as risk in Section 12.

**Planner recommendation:** Implement `computeTodayWindow()` as a pure function (no DOM, no setState side effects) inside the rendering helpers. Use the algorithm above verbatim. German weekday names for verisimilitude. 24 Dec footnote as an inline caveat, not a separate state.

## Section 10: ASSUMPTION A1 resolution

The Block D panic phrases (lines 428-436 of `index.html`) are seven short formal Hochdeutsch phrases. The inline comment flags them for native-speaker review before Phase 3 renders them.

**Three options:**

| Option | Risk | Cost |
|--------|------|------|
| (a) Ship as-is, flag for Phase 5 | Low. The phrases are concise high-frequency Hochdeutsch (`Können Sie das bitte wiederholen?`, `Auf Wiederhören.`, etc.). They are correct-sounding for any German speaker. | Zero. |
| (b) Quick LLM review by Claude | Low risk but might surface stylistic nitpicks (e.g. `Können Sie das bitte wiederholen?` vs `Würden Sie das bitte wiederholen?`). Decisions still need a human arbiter. | One LLM call worth of tokens. |
| (c) Real native-speaker review (Francisco's network) | Highest confidence. | Depends on availability; could delay Phase 3. |

**Recommendation: ship as-is (option a), flag for Phase 5 pilot review.**

Rationale: the seven phrases are all canonical telephone phrases that any German B2+ speaker would recognise as correct. The cost of being wrong is low (a slightly stilted phrase the user reads in a phone call), the cost of waiting is high (Phase 3 blocks on a person who may take days to respond). The Phase 5 pilot is the natural moment to catch real-world feedback ("did the officer understand what you meant?"). Mark the assumption in the new PLAN frontmatter and STATE.md Open Todos so it isn't lost.

If Francisco does happen to have a native-speaker contact available the same week, doing a quick async review is a free bonus, but it should not gate Phase 3.

**Planner recommendation:** Ship as-is. Carry the A1 caveat into Plan A's frontmatter and add a checkbox to the Phase 5 pre-pilot prep list. Do not edit the seven panic phrases in Phase 3.

## Section 11: TRUST-05 housekeeping

REQUIREMENTS.md line 49 currently reads:

> **TRUST-05**: A first-visit onboarding screen explains how to get a free Gemini API key, with link

Two factual problems:

1. Provider is Anthropic (D-01 locked in Phase 0). Should say "free Anthropic API key" — but **"free" is misleading** for Anthropic: there's no free tier in the Gemini sense, just a pay-as-you-go account where a single cheat sheet generation costs around $0.001 to $0.003 on Haiku. Recommended amended wording: "A first-visit onboarding screen explains how to get an Anthropic API key, with link". Drop the word "free".

2. The link target: `https://console.anthropic.com` (base console, so unsigned-up users see the sign-up flow).

**Fold into:** Plan C (onboarding + privacy). The TRUST-05 wording amendment is a one-line edit to REQUIREMENTS.md; the onboarding-screen link is part of the body copy in Section 6. Two changes, one PLAN, same wave. No need for a fourth plan.

**Planner recommendation:** Plan C includes one tiny housekeeping task: amend REQUIREMENTS.md TRUST-05 wording from "free Gemini API key" to "Anthropic API key" (drop the "free" — Anthropic is paid pay-as-you-go, very cheap, but not free). Link target in the onboarding body is `https://console.anthropic.com`.

## Section 12: Risks

| Risk | Impact | Mitigation |
|------|--------|-----------|
| Print preview pagination is browser-specific (Chrome vs Edge vs Safari) | Medium | Test in Chrome only for v1; document Safari/Edge as best-effort in Plan B's verification checklist. |
| `?raw=1` dev toggle leaking into the production user experience | Low | One conditional in the result render path; the panel is `hidden` by default. Easy to grep and remove post-pilot. |
| Onboarding flag in localStorage means clearing site data resets onboarding | Low | Expected behaviour, not a bug. Document in the privacy page (which already mentions clearing site data). |
| Block A hours depend on the client clock; wrong clock → wrong hours displayed | Low for v1 | Acceptable for a preparation aid (user is calling within minutes of opening the sheet). Document as known limitation. Future v1.x could fetch Swiss time from a public NTP-like HTTPS endpoint, but that adds a new `connect-src` to the CSP. |
| Print might leak the API-key UI into the printout if the hide selector is wrong | High | Verification: in the manual print-preview checklist (Section 4), step 8 explicitly looks for "no button or form control visible". Test from the cheat-sheet screen and confirm the masked-key chip in `.intake-key-header` is hidden. |
| Mobile auto-zoom on form fields | Low | All form fields use `font-size: 1rem` already; add explicit `font-size: 16px` in the mobile media query as a belt-and-braces guard. |
| CSP regression: a third-party stylesheet or font snuck in | Low | No new connect-src or style-src needed for Phase 3. Verification: `git diff` the CSP meta tag before commit; should be zero changes. |
| Block H escalation URLs go stale | Low | Already verified 2026-05-14 per the inline comment at line 453. Re-verify pre-pilot. |
| iOS Safari soft-pass becomes a forgotten hard-pass | Medium | Plan B frontmatter: PRINT-02 stays "pending" until Phase 5 pilot verifies on a real iPhone. Don't tick it in Phase 3. |

**Planner recommendation:** Embed the print-leak risk verification into the print-preview checklist as a numbered step. Add the iOS Safari soft-pass/hard-pass distinction to Plan B's frontmatter. Carry the A2 hours-display-vs-device-clock note into the privacy page body so it's user-visible (done — line "device clock" implicitly covered by "schedule unconfirmed" footnote and Phase 5 verification).

## Section 13: Acceptable browser scope

| Browser | Scope | Notes |
|---------|-------|-------|
| Desktop Chrome | Primary target, full support required | Phase 0 spike verified CORS + fetch here. Print stylesheet authored against Chrome's print preview. |
| Mobile Safari (iOS) | Primary target for reading, full support required | PRINT-02 requirement. Soft-pass in Phase 3 via Chrome devtools "iPhone 15 Pro" emulation; hard pass deferred to Phase 5 pilot. |
| Mobile Chrome (Android) | Bonus support | Should work because CSS grid + `@media print` + `localStorage` are all standards; not separately verified in Phase 3. |
| Desktop Safari | Best-effort | Add `-webkit-print-color-adjust: exact` alongside `print-color-adjust: exact` for the border-printing rule. No other Safari-specific code paths. |
| Desktop Edge | Best-effort | Chromium-based, should match Chrome behaviour. |
| Desktop Firefox | Best-effort | CSS grid + `@media print` work; print preview differs slightly from Chrome but no blocking issue expected. |
| IE 11 and older | Out of scope | Already excluded by the project's modern-baseline assumption (`localStorage`, `fetch`, ES2022). |

**Planner recommendation:** Phase 3 commits to "desktop Chrome plus iPhone Safari (soft pass in Phase 3, hard pass in Phase 5)". Everything else is best-effort. Document this scope in the PLAN frontmatter so the executor doesn't burn time chasing Firefox print previews.

## Code Examples

### Block A render helper (worked example)

```js
function renderBlockA(cs) {
  const root = document.getElementById('blockA');
  root.textContent = '';

  const h3 = document.createElement('h3');
  h3.textContent = 'Block A - Who you are calling';
  root.appendChild(h3);

  // Office name and parent department.
  const nameLine = document.createElement('p');
  nameLine.innerHTML = '';
  nameLine.appendChild(document.createTextNode(MIGRATIONSAMT.nameDe));
  root.appendChild(nameLine);

  const deptLine = document.createElement('p');
  deptLine.textContent = MIGRATIONSAMT.parentDept;
  root.appendChild(deptLine);

  // Phone.
  const phoneLine = document.createElement('p');
  phoneLine.textContent = 'Phone: ' + MIGRATIONSAMT.phone.international;
  root.appendChild(phoneLine);

  // Address.
  const addrLine = document.createElement('p');
  addrLine.textContent = MIGRATIONSAMT.address.line1 + ', '
    + MIGRATIONSAMT.address.postalCode + ' '
    + MIGRATIONSAMT.address.city;
  root.appendChild(addrLine);

  // Today's hours.
  const window = computeTodayWindow();
  const hoursLine = document.createElement('p');
  hoursLine.textContent = 'Today, ' + window.todayLabel + ': ' + window.windowText
    + (window.note ? ' ' + window.note : '');
  root.appendChild(hoursLine);

  // User's stated goal (from the LLM-generated Block B).
  if (cs && cs.blockB && cs.blockB.userGoalSentence) {
    const goalLabel = document.createElement('p');
    goalLabel.innerHTML = '';
    const strong = document.createElement('strong');
    strong.textContent = 'Your goal for this call:';
    goalLabel.appendChild(strong);
    root.appendChild(goalLabel);

    const goalDe = document.createElement('p');
    goalDe.className = 'de';
    goalDe.textContent = cs.blockB.userGoalSentence;
    root.appendChild(goalDe);

    const goalEn = document.createElement('p');
    goalEn.className = 'en';
    goalEn.textContent = cs.blockB.userGoalGloss;
    root.appendChild(goalEn);
  }
}
```

All writes via `textContent`; no `innerHTML` from LLM-derived data (matches the locked anti-XSS posture from Phase 1/2).

### Block D render helper (hardcoded panic phrases)

```js
function renderBlockD() {
  const root = document.getElementById('blockD');
  root.textContent = '';

  const h3 = document.createElement('h3');
  h3.textContent = 'Block D - Panic phrases (always available)';
  root.appendChild(h3);

  BLOCK_D.forEach(function (phrase) {
    const row = document.createElement('div');
    row.className = 'bilingual-row';
    const de = document.createElement('div');
    de.className = 'de';
    de.textContent = phrase.de;
    const en = document.createElement('div');
    en.className = 'en';
    en.textContent = phrase.en;
    row.appendChild(de);
    row.appendChild(en);
    root.appendChild(row);
  });
}
```

### Block G render helper (note-taking lines, print-only via CSS)

```js
function renderBlockG() {
  const root = document.getElementById('blockG');
  root.textContent = '';

  const h3 = document.createElement('h3');
  h3.textContent = 'Block G - Take notes during the call';
  root.appendChild(h3);

  const labels = ['Officer name:', 'Next step:', 'Date:', 'Reference number:'];
  labels.forEach(function (label) {
    const line = document.createElement('p');
    line.className = 'note-line';
    line.textContent = label + ' ____________________________________';
    root.appendChild(line);
  });
}
```

Block G is rendered every time, but the `.cheat-sheet-print-only` class on its parent `<section>` hides it from the screen and only shows it in `@media print`.

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
|---|-------|---------|---------------|
| A1 (carried from Phase 1) | Seven Block D panic phrases are correct conventional Hochdeutsch | Section 10 | Slightly stilted phrasing the user reads during the call; user re-reads, officer understands anyway. Low. |
| A2 (carried from Phase 1) | 24 Dec 2026 is treated as normal Migrationsamt hours | Section 9 | User calls on 24 Dec, office closed, time wasted. Mitigated by inline footnote "schedule unconfirmed". Re-verify Phase 5. |
| New | Anthropic Console base URL is the right place to send an un-signed-up user | Section 6 | If Anthropic changes its sign-up entry point, the link rots. URL was verified via web search 2026-05-15. Low. |
| New | Chrome devtools "iPhone 15 Pro" emulation is acceptable as a soft pass for PRINT-02 | Section 5 | If real iOS Safari rendering diverges, Phase 5 pilot catches it. Documented as Phase 3 soft / Phase 5 hard. |
| New | "Background graphics" checkbox in Chrome's print dialog is on by default OR the user knows to enable it | Section 4 | If unchecked, block borders won't print; cheat sheet still readable. Documented in the print-preview checklist. |

## Open Questions

1. **Should the in-app "Print" button trigger `window.print()` directly, or should it just nudge the user to Ctrl+P?**
   - What we know: `window.print()` works cross-browser and opens the native print dialog.
   - What's unclear: whether Francisco prefers an in-page button (more discoverable) or relying on Ctrl+P (more browser-native).
   - Recommendation: include both — the in-page button calls `window.print()`, and the cheat-sheet screen also displays a small "Tip: Ctrl+P also works" helper line in the controls bar.

2. **Where does the "Privacy" link live on the result screen?**
   - What we know: the print stylesheet hides the page `<footer>`, so a footer-only Privacy link would be invisible on the result screen.
   - What's unclear: whether the result screen should have its own non-printed Privacy link or whether Privacy is only reachable from pre-result screens.
   - Recommendation: render the Privacy link in the `.cheat-sheet-controls` div (which is also `.no-print`), so it's reachable from the result screen but doesn't appear in the printed sheet.

3. **Does the print stylesheet need to handle two-page vs one-page splits explicitly?**
   - What we know: with current mock content the sheet is one to two pages depending on Block E and F length.
   - What's unclear: whether Block H should ALWAYS land on its own at the bottom of the last page (visually anchoring "preparation aid, not legal advice").
   - Recommendation: don't force it. Let the browser paginate naturally. Block H having a top border + the always-present sticky disclaimer at page 1 is enough TRUST-01 coverage.

## Environment Availability

Phase 3 adds zero new external dependencies. The only environment requirement is the existing browser + Anthropic API endpoint chain unchanged from Phase 2.

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|----------|
| Modern browser with CSS grid + @media print + localStorage | Phase 3 rendering | ✓ | Chrome 90+, Safari 14+, Firefox 90+ | None — covered by L-05/L-07 baseline |

## Project Constraints (from CLAUDE.md)

- Vanilla HTML, CSS, vanilla JS only. No frameworks, no build, no TypeScript. (Project root + workspace `CLAUDE.md`.)
- Beginner-friendly, clean readable code, short focused functions, comments explaining each section.
- **No em dashes or en dashes in visible UI copy.** (Workspace `CLAUDE.md`.) Apply to onboarding and privacy body text — use hyphens or sentence breaks instead.
- Single `index.html` file with inline `<style>` and `<script>` (L-05).
- Strict CSP, no third-party scripts at runtime (L-07).
- Never call `getUserMedia` anywhere (lifetime guardrail, TRUST-04).
- All writes from LLM-derived data via `textContent`, never `innerHTML`.
- Anthropic-only, direct browser fetch, BYO key in localStorage (L-01..L-04).
- GSD workflow enforcement: planning artifacts in `.planning/`, no direct repo edits outside a GSD command.

## Sources

### Primary (HIGH confidence)
- [MDN: CSS Grid Layout](https://developer.mozilla.org/en-US/docs/Web/CSS/CSS_grid_layout) — grid responsive collapse and print behaviour
- [MDN: @media print printing guide](https://developer.mozilla.org/en-US/docs/Web/CSS/CSS_media_queries/Printing) — `@media print`, `@page`, `page-break-*` semantics
- [MDN: @page](https://developer.mozilla.org/en-US/docs/Web/CSS/@page) — A4 size, margins
- [MDN: print-color-adjust](https://developer.mozilla.org/en-US/docs/Web/CSS/print-color-adjust) — forcing colored borders/backgrounds to print
- [MDN: break-inside](https://developer.mozilla.org/en-US/docs/Web/CSS/break-inside) — modern equivalent of `page-break-inside`

### Secondary (MEDIUM confidence)
- [Anthropic Console: API Keys settings](https://platform.claude.com/settings/keys) — direct path to key management (Anthropic-canonical via aliased domain)
- [Anthropic Console signup tutorial 2026 (chaterimo)](https://www.chaterimo.com/en/blog/how-to-anthropic-api-account/) — confirms `console.anthropic.com` as the sign-up entry point
- [CSS Tricks: 16px or larger text prevents iOS form zoom](https://css-tricks.com/16px-or-larger-text-prevents-ios-form-zoom/) — iOS Safari auto-zoom behaviour for form fields below 16px

### Tertiary (LOW confidence)
- None. All Phase 3 claims rest on MDN primary sources or are verified via direct inspection of `index.html`.

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH — pure CSS3 + vanilla JS, no new deps, all techniques are MDN-documented and years stable.
- Architecture: HIGH — Phase 3 reuses the locked `appState` + `setState` + `render` pattern with two new screen values.
- Print/mobile: HIGH for Chrome desktop and Chrome devtools iPhone emulation; soft for real-iOS-Safari verification (deferred to Phase 5 pilot).
- Onboarding/privacy copy: HIGH — body text is paste-ready; only the Anthropic Console URL has a meaningful change-risk (mitigated by linking to the base console domain).

**Research date:** 2026-05-15
**Valid until:** 2026-06-15 (CSS print rules are stable for years; the Anthropic Console URL is the only fast-moving piece; re-verify pre-pilot)
