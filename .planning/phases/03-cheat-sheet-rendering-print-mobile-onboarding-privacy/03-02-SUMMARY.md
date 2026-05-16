---
phase: 03-cheat-sheet-rendering-print-mobile-onboarding-privacy
plan: 02
subsystem: print-and-mobile
tags: [print, mobile, css, media-queries, a4, ios-safari]
requires: [03-01-PLAN.md]
provides:
  - "A4 print stylesheet that produces a 1-2 page cheat sheet with hidden controls and surfaced Block G"
  - "Mobile breakpoint at 480px collapsing two-column DE/EN rows to single column with 16px form fonts"
affects:
  - index.html
tech_stack_added: []
patterns:
  - "Single inline @media print block append, no new external resources"
  - "print-color-adjust: exact paired with manual 'Background graphics' instruction in the print preview checklist"
  - "Soft-pass for iOS Safari via Chrome devtools emulation; hard on-device pass formally deferred to Phase 5 pilot"
key_files_created: []
key_files_modified:
  - index.html
decisions:
  - "@page size A4 with 1.5cm margins is the v1 print contract"
  - "Block G visibility is CSS-driven (display: none default, display: block !important inside @media print)"
  - "Mobile breakpoint at max-width 480px; the same DOM serves both desktop and phone"
metrics:
  completed_date: 2026-05-16
  tasks_completed: 3
  duration: "~1 session including the human-verify checkpoint walkthrough"
---

# Phase 3 Plan 02 SUMMARY: Print stylesheet + mobile breakpoint

**One-liner:** Layered an `@media print` block (A4, hidden controls, Block G surfaced, page-break-inside avoided) and an `@media (max-width: 480px)` mobile block (single-column DE/EN collapse, 16px form fonts) over the Wave 1 cheat-sheet DOM, without touching any markup.

## Outcome

**PASS.** Francisco verified the print preview walkthrough (desktop Chrome → Ctrl+P → A4 → Background graphics → 1-2 page PDF) and the iPhone 15 Pro devtools mobile emulation. PRINT-01, PRINT-02 (soft pass), PRINT-03 all met.

## What was built

- `@page { size: A4; margin: 1.5cm }` for predictable A4 pagination.
- `@media print` block that:
  - Hides `.intake-key-header`, `#intake`, `#key-entry`, `#generating`, `#errorPanel`, `#onboarding` (added in 03-03), `#privacy` (added in 03-03), `#rawJsonDebug`, `.cheat-sheet-controls`
  - Flips `.cheat-sheet-print-only` to `display: block !important` to surface Block G
  - Applies `page-break-inside: avoid` and `break-inside: avoid` to every `.cheat-sheet-block`
  - Applies `print-color-adjust: exact` and `-webkit-print-color-adjust: exact` for preserved borders and the yellow disclaimer strip (effective only when the user ticks "Background graphics")
  - Static-positions the disclaimer at the top of page 1 (not sticky in print)
  - Adds `::after { content: ' (' attr(href) ')' }` on Block H escalation links so URLs survive on paper
- `@media (max-width: 480px)` block that:
  - Collapses `.bilingual-row` grid from `1fr 1fr` to single column `1fr`
  - Bumps body and form-input base font-size to 16px to prevent iOS Safari auto-zoom on focus

## Commits

| # | Commit | Description |
|---|--------|-------------|
| 1 | `2ff97ba` | Add print stylesheet with @page A4 and print-color-adjust |
| 2 | `614f1a5` | Add mobile breakpoint at 480px with single-column collapse |

## Human-verify outcome

Francisco's two-walkthrough verdict: **PASS** (continue signal accepted as approval).

- Walkthrough A (print preview, Ctrl+P → A4 → Background graphics → Save as PDF): 1-2 pages, no block split, no controls bleeding, disclaimer + Block G + Block H link annotations all visible in print.
- Walkthrough B (iPhone 15 Pro devtools emulation): single-column collapse confirmed on Blocks B/C/D/E, no horizontal scrolling, Print button reachable.

## Deviations from plan

None. Both `auto` tasks executed exactly as written. Temporary helper scripts (`.verify-task1.ps1`, `.verify-task2.ps1`) used during local verification were cleaned up before commit.

## Flags for downstream phases

- **PRINT-02 hard pass deferred to Phase 5.** The Phase 3 close-out marks PRINT-02 as a soft pass via Chrome iPhone 15 Pro devtools emulation. A real iPhone test is still required before the pilot in Phase 5.
- **Background graphics user education.** The print preview requires the user to tick "Background graphics" for the yellow disclaimer strip and block borders to render. This will be documented in the onboarding text (Plan 03-03) or README so the first real user doesn't get a colourless printout.
- **`@page` size = A4** assumes the user prints in a country using A4 paper (Switzerland: yes). If a US-letter user ever appears, the page may run slightly over due to size mismatch; acceptable for v1.

## Self-check: PASSED

- `index.html` extends Phase 1+2 cleanly. No DOM changes in this plan, CSS only.
- `verify-no-mic.ps1` exits 0.
- PRINT-01 (clean A4 page-break behaviour), PRINT-02 (soft pass mobile), PRINT-03 (controls hidden in print) all satisfied.
- All Wave 1 invariants intact: CSP narrow, no `getUserMedia`, no em/en dashes, no new external resources.
