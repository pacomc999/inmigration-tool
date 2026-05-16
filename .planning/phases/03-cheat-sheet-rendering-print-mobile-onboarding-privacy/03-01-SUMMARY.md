---
phase: 03-cheat-sheet-rendering-print-mobile-onboarding-privacy
plan: 01
subsystem: render
tags: [render, cheat-sheet, blocks-a-h, trust-01, computeTodayWindow, raw-flag, phase-3]
requires: [02-02-PLAN.md]
provides:
  - "Eight-block printable cheat-sheet DOM under #cheatSheet"
  - "computeTodayWindow() pure helper for Block A's hours line"
  - "renderBlockA / renderBlockD / renderBlockG / renderBlockH render helpers"
  - "?raw=1 developer-only raw JSON view gate"
  - "In-page Print button calling window.print() plus Ctrl+P hint"
  - "TRUST-01 non-dismissable disclaimer strip"
affects:
  - index.html
tech_stack_added: []
patterns:
  - "CSS grid for two-column DE/EN .bilingual-row layout"
  - "Screen-default .cheat-sheet-print-only { display: none } (Plan 03-02 flips in print)"
  - "URLSearchParams gate for ?raw=1 developer view (one conditional, cleanly removable)"
  - "All LLM-derived and developer-controlled text via textContent + setAttribute"
key_files_created: []
key_files_modified:
  - index.html
decisions:
  - "Phase 2 helpers renderBlockB/C/E/F reused unchanged; their target ids (#resultBlockB..F) now nest inside the corresponding <section id=\"blockB|C|E|F\">"
  - "Disclaimer wording (TRUST-01) shipped: 'Preparation aid only. Not legal advice. Do not read this aloud word for word.'"
  - "Block G content built every render even though hidden on screen, so print preview always reflects current state"
  - "renderBlockA() reads cs.blockB.userGoalSentence + userGoalGloss for the bottom goal section; gracefully skips when absent"
  - "renderBlockH() reads BLOCK_H_FOOTER.disclaimer and BLOCK_H_FOOTER.escalations[] (name + url) - the actual shape shipped by Phase 1"
metrics:
  completed_date: 2026-05-16
  tasks_completed: 4
  duration: "~1 session"
---

# Phase 3 Plan 01: Cheat Sheet Rendering Summary

**One-liner:** Replaced the Phase 2 throwaway raw-JSON result panel with a printable eight-block cheat sheet (Blocks A through H) under `<article id="cheatSheet">`, added a sticky TRUST-01 disclaimer strip, a pure `computeTodayWindow()` helper feeding Block A's hours line, an in-page Print button plus Ctrl+P hint, and a `?raw=1` developer-only raw JSON view; zero new dependencies, zero CSP changes, zero `.innerHTML =` introduced.

## Outcome

**PASS.** All four task automated verifies exit 0 against the planned regex checks. `verify-no-mic.ps1` exits 0. The cumulative grep for `\.innerHTML\s*=` returns zero hits and the grep for `holidays2026` returns zero hits. The DOM scaffold is ready for Plan 03-02 (print + mobile rules) to layer on top.

## What was built

### Final DOM shape of `#result` and `#cheatSheet`

```
<section id="result" hidden>
  <div class="cheat-sheet-disclaimer">Preparation aid only. Not legal advice. Do not read this aloud word for word.</div>
  <article id="cheatSheet" class="cheat-sheet-print-root">
    <section id="blockA" class="cheat-sheet-block"></section>
    <section id="blockB" class="cheat-sheet-block"><div id="resultBlockB"></div></section>
    <section id="blockC" class="cheat-sheet-block"><div id="resultBlockC"></div></section>
    <section id="blockD" class="cheat-sheet-block"></section>
    <section id="blockE" class="cheat-sheet-block"><div id="resultBlockE"></div></section>
    <section id="blockF" class="cheat-sheet-block"><div id="resultBlockF"></div></section>
    <section id="blockG" class="cheat-sheet-block cheat-sheet-print-only"></section>
    <section id="blockH" class="cheat-sheet-block"></section>
  </article>
  <div class="cheat-sheet-controls">
    <button id="printCheatSheetBtn">Print this sheet</button>
    <span class="print-hint">Tip: Ctrl+P also works on most browsers.</span>
    <button id="newCheatSheetButton">New cheat sheet</button>
    <button id="backToIntakeFromResultButton">Back to intake</button>
  </div>
  <details id="rawJsonDebug" class="cheat-sheet-raw" hidden>
    <summary>Raw JSON (developer view, ?raw=1)</summary>
    <pre id="resultRawJson"></pre>
  </details>
</section>
```

The four Phase 2 placeholder divs (`#resultBlockB`, `#resultBlockC`, `#resultBlockE`, `#resultBlockF`) are preserved and now nest inside their corresponding block sections so the Phase 2 helpers continue to write into them unchanged. The two Phase 2 navigation button ids (`#newCheatSheetButton`, `#backToIntakeFromResultButton`) are preserved so the existing Plan 02 click handlers resolve.

### TRUST-01 disclaimer wording shipped

> Preparation aid only. Not legal advice. Do not read this aloud word for word.

Non-dismissable. No close button. Sticky at the top of the result screen via `position: sticky; top: 0;`. Plan 03-02 will reuse the same node inside `@media print`.

### computeTodayWindow() shape and edge cases

Pure helper. Reads `MIGRATIONSAMT.phoneHours.mondayToFriday` and `MIGRATIONSAMT.closures2026`. Uses `new Date()` via the parameter default. No DOM access, no setState, no fetch.

Return shape: `{ open, todayLabel, windowText, note }`.

Four edge cases handled:

| Branch | Trigger | windowText |
|---|---|---|
| Weekend | `dayOfWeek === 0 || 6` | `'Closed (weekend)'` |
| Closed closure | `closures2026[i].type === 'closed'` | `'Closed (' + closure.name + ')'` |
| Reduced closure | `closures2026[i].type === 'reduced'` | `morning.from + '-' + closure.closesAt + ' (reduced hours, ' + closure.name + ')'` |
| Normal weekday | no closure match | `'08:00-11:45, 13:00-16:30'` |

24 Dec 2026 ASSUMPTION A2 footnote: when `isoDate === '2026-12-24'`, `note = '(24 Dec schedule unconfirmed; verify on zh.ch before calling)'` (only fires when no closure match, i.e. it sits on top of the normal-weekday branch).

Reference dates documented inline below the function (`2026-05-14 Auffahrt`, `2026-05-13 Tag vor Auffahrt`, `2026-05-16 Saturday`, `2026-05-18 Monday`, `2026-12-24 Thursday`).

### Four new render helpers

| Helper | Target | Source |
|---|---|---|
| `renderBlockA(cs)` | `#blockA` | MIGRATIONSAMT name / parentDept / phone / address + computeTodayWindow() + `cs.blockB.userGoalSentence`/`userGoalGloss` when present |
| `renderBlockD()` | `#blockD` | `BLOCK_D` array (seven entries) rendered as `.bilingual-row > .de + .en` |
| `renderBlockG()` | `#blockG` | Four hardcoded labels (Officer name / Next step / Date / Reference number) as `.note-line` paragraphs |
| `renderBlockH()` | `#blockH` | `BLOCK_H_FOOTER.disclaimer` + lead-in line + `<ul>` of three escalation `<a>` links (Welcome Desk / MIRSAH / Solinetz) with `target="_blank"` and `rel="noopener noreferrer"` set via `setAttribute` |

All LLM-derived AND developer-controlled text routes through `textContent`. Anchor `href` values are set via `setAttribute`. Zero `.innerHTML =` introduced.

### Locked call order in render()'s 'result' branch

```
renderBlockA(cs);
renderBlockB(cs.blockB);
renderBlockC(cs.blockC);
renderBlockD();
renderBlockE(cs.blockE);
renderBlockF(cs.blockF);
renderBlockG();
renderBlockH();
```

Followed by the single `?raw=1` gate (the only code path that unhides `#rawJsonDebug`).

### `?raw=1` gate

```
const rawFlag = new URLSearchParams(window.location.search).get('raw');
if (rawFlag === '1') {
  rawDetails.hidden = false;
  rawPre.textContent = JSON.stringify(cs, null, 2);
} else {
  rawDetails.hidden = true;
  rawPre.textContent = '';
}
```

Default URL (no `?raw=1`) keeps `#rawJsonDebug` hidden. The raw `<pre>` content is set via `textContent`, never `innerHTML`. The gate is one conditional in one branch and is cleanly removable post-pilot.

### Print button + Ctrl+P hint

`#printCheatSheetBtn` click handler: a single `window.print()` call. The `.print-hint` span next to it reads "Tip: Ctrl+P also works on most browsers." Plan 03-02 will hide both inside `@media print`.

### CSS rules added (screen only)

- `.cheat-sheet-disclaimer` (sticky yellow strip)
- `.cheat-sheet-block` (left-border framed section)
- `.cheat-sheet-block h3` (heading sizing)
- `.bilingual-row` (CSS grid `1fr 1fr` two-column)
- `.bilingual-row .de` / `.bilingual-row .en` (typography)
- `.cheat-sheet-print-only { display: none; }` (Plan 03-02 flips in print)
- `.cheat-sheet-controls` (flex row)
- `.print-hint` (typography)
- `.note-line` (monospace)

Print and mobile rules are explicitly out of scope for this plan and owned by Plan 03-02.

## Reused without change

`renderBlockB`, `renderBlockC`, `renderBlockE`, `renderBlockF` from Phase 2 Plan 02 are reused unchanged. Their target div ids (`#resultBlockB`..`#resultBlockF`) are preserved and now live nested inside the corresponding `<section id="blockB|C|E|F">`.

## Commits

| # | Commit | Description |
|---|--------|-------------|
| 1 | `754a593` | Add eight-block cheat-sheet DOM with TRUST-01 disclaimer and print controls (Task 1) |
| 2 | `e8e2746` | Add computeTodayWindow pure helper for Block A hours line (Task 2) |
| 3 | `1b21822` | Add renderBlockA, D, G, H helpers and wire eight-block result render with raw=1 gate (Task 3) |
| 4 | `00f0a94` | Wire print button to window.print (Task 4) |

## Deviations from plan

**1. [Rule 3 - Blocking issue] Compressed renderBlockA comments to keep the verifier regex `renderBlockA[\s\S]{0,800}computeTodayWindow\s*\(` matching**

- **Found during:** Task 3 automated verify (`renderBlockACallsCompute=False`).
- **Issue:** The plan-supplied verifier expected `computeTodayWindow(` within 800 characters of `function renderBlockA`. The first pass had per-paragraph comments and a separate `const` for each `<p>` line, pushing the distance to 1332 chars and tripping the check.
- **Fix:** Replaced the six separate `document.createElement('p')` blocks at the top of `renderBlockA` with a small inline `addP(text)` helper. Same DOM output, same textContent-only rule, no behaviour change. Final distance: 794 chars.
- **Files modified:** `index.html` (renderBlockA only).
- **Commit:** Folded into `1b21822`.

No other deviations. The plan executed as written.

## CSP / dependency invariants confirmed

- CSP `connect-src` is still `https://api.anthropic.com` only. No new origins.
- Zero new `<link>` or `<script>` elements with `https://` sources.
- Zero new fonts loaded.
- `verify-no-mic.ps1` exits 0.
- File-wide grep for `.innerHTML =` returns zero hits (Phase 1 + 2 + 3 cumulative).
- File-wide grep for `holidays2026` returns zero hits (the correct field name `closures2026` is used throughout).

## Heads-up for Plan 03-02 (print stylesheet + mobile)

- The screen rule `.cheat-sheet-print-only { display: none; }` is in place. Plan 03-02 must flip it to `display: block` inside `@media print` to surface Block G in printed output.
- The disclaimer is a single node `.cheat-sheet-disclaimer` at the top of `#result`. Inside `@media print`, plan 03-02 should keep it visible at the top of the printed sheet (it is already non-sticky behaviour in print by virtue of how page flow works, but verify).
- `.cheat-sheet-controls` (containing `#printCheatSheetBtn` and the two navigation buttons) plus `#rawJsonDebug` should be hidden in print.
- Every `<section class="cheat-sheet-block">` is a natural page-break-avoid target. Recommend `page-break-inside: avoid` on `.cheat-sheet-block`.
- Mobile rules: the `.bilingual-row` grid is `1fr 1fr`. Plan 03-02 should collapse it to a single column at `@media (max-width: 480px)` via `grid-template-columns: 1fr`.
- The intake header strip and TRUST-01 disclaimer both already wrap on small screens (flex-wrap is set on `.intake-key-header` and the disclaimer is a block).
- Body min font: already at the system default; Plan 03-02 should ensure form inputs stay at >= 16px on mobile to avoid Safari's auto-zoom.
- Note: Plan 03-02 cannot rely on `print-color-adjust: exact` working on all browsers; the yellow disclaimer strip may render colourless in print. Plan accordingly (Section 8 of 03-RESEARCH.md flagged this).

## Heads-up for Plan 03-03 (onboarding + privacy + TRUST-05 housekeeping)

- The screen union widens further (`'privacy'` or `'onboarding'`). The existing `hideAllSections` sweep already lists every section by id; Plan 03-03 must add the new section ids to that array.
- A first-visit detection flag (suggested `localStorage.migrationsamt.onboardingSeen`) should follow the same try/catch pattern as the existing `loadConsent` / `saveConsent` helpers.
- TRUST-05 wording: `REQUIREMENTS.md` still says "Gemini key" in places. Plan 03-03 fixes that to "Anthropic key" and updates any onboarding link to the Anthropic Console settings page.
- The TRUST-01 disclaimer wording shipped here (in `#result`) does NOT need to be repeated on the onboarding screen; the onboarding screen has its own TRUST-05 BYOK explanation copy.

## Open follow-ups (no action required in 03-01)

- ASSUMPTION A1 (Block D German phrasing): still pending Phase 5 native-speaker review. No content change shipped here.
- ASSUMPTION A2 (24 Dec 2026 schedule): inline footnote shipped. Hard pass is Phase 5 verification against zh.ch.

## Self-check: PASSED

- All four task automated verify commands exit 0 against their regex check sets.
- `verify-no-mic.ps1` exits 0.
- `git log --oneline` confirms commits `754a593`, `e8e2746`, `1b21822`, `00f0a94` exist on the current branch.
- `index.html` contains all required ids (`#blockA`..`#blockH`, `#cheatSheet`, `#rawJsonDebug`, `#printCheatSheetBtn`, preserved `#newCheatSheetButton` and `#backToIntakeFromResultButton`).
- Cumulative file-wide grep for `\.innerHTML\s*=` returns zero hits.
- Cumulative file-wide grep for `holidays2026` returns zero hits.
- No em or en dash characters in the file.
- No `getUserMedia` introduced.
