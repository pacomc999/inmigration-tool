# Phase 3 Context: Cheat Sheet Rendering, Print, Mobile, Onboarding, Privacy

> **Note:** Francisco opted to skip the formal `/gsd-discuss-phase` step (consistent with Phases 1 and 2). This stub freezes the inherited locked decisions and lists open design questions the planner must resolve in PLAN.md.

## Source of truth for goals

See `.planning/ROADMAP.md` → Phase 3 (Goal, Depends on, Requirements, Success Criteria 1–5) and the "Cheat Sheet Anatomy" section listing all eight blocks A–H.

## Inherited locked decisions (carry forward, binding)

- **L-01..L-07** from Phases 0/1/2 (Anthropic-only, direct browser fetch, single-file vanilla `index.html`, BYO key in localStorage, no `getUserMedia` ever, no CDN, strict CSP).
- **L-08:** Anthropic structured-output schema doesn't support `minItems > 1` or `maxItems`. Count constraints live in SYSTEM_PROMPT and field descriptions.
- **L-09:** Six canonical error classes — `auth`, `rate-limit`, `server`, `bad-request`, `parse`, `network`. Phase 4 will localize these; Phase 3 doesn't touch them.

## What Phase 3 MUST deliver

### Block rendering (visual layer over the schema Phase 2 locked)

- **Block A** — Hardcoded call header. Office name, phone, address, current-day hours window (computed from `MIGRATIONSAMT.standardHours` and Swiss public holidays from the same constants object, with the ASSUMPTION A2 caveat for 24 Dec 2026 still in place), plus the user's stated goal (`appState.cheatSheet.blockB.userGoalSentence`).
- **Block B** — Opening script. Two columns DE/EN. Must always show the Hochdeutsch-request sentence by default. Order: user-goal sentence → opening-script lines in order.
- **Block C** — Likely officer questions and suggested answers. Two columns DE/EN, with affirmative/negative answer pairs visible under each question. At least 4 entries (the SYSTEM_PROMPT enforces 4–6).
- **Block D** — Hardcoded panic phrases. ASSUMPTION A1 still pending — a native-speaker pass before this ships to the pilot would be cheap insurance.
- **Block E** — Vocabulary glossary, 6–12 entries, each with article (`der`/`die`/`das`), German word, English translation.
- **Block F** — Prep checklist, tailored. 5–10 actionable lines.
- **Block G** — Note-taking lines. **Visible only when printing.** Officer name, next step, date, reference number.
- **Block H** — Footer with the non-dismissable "preparation aid, not legal advice" notice plus escalation links: Welcome Desk Stadt Zürich, MIRSAH (SAH Zürich), Solinetz.

### Non-block requirements

- **TRUST-01:** A non-dismissable disclaimer is visible at the top of every rendered cheat sheet (NOT only in Block H). Pinned position at the top of the result screen and at the top of the print layout.
- **TRUST-03:** A dedicated privacy page explains the BYO-key, no-backend, no-logging model in plain English.
- **TRUST-05:** A first-visit onboarding screen explains the BYO-key model and links to obtain a free Anthropic API key. **Note:** the current REQUIREMENTS.md wording still says "free Gemini key" — must be amended during Phase 3 housekeeping to say "Anthropic key" (Anthropic Console settings page link). The link text and target are the planner's call but must point to where a real user can sign up and create a key.

### Print + mobile

- **PRINT-01:** `@media print` styles. Clean A4 layout. 1–2 pages. No section split across a page break. Controls and buttons hidden from print.
- **PRINT-02:** Single-column readable layout on iPhone Safari window size. **Note:** Phase 0 explicitly scoped iOS Safari out of the spike, but Phase 3 introduces it as a target. Initial verification can be a Chrome devtools mobile emulation; on-device verification with a real iPhone is preferred (per PRINT-02 wording: "tested on device, not just devtools emulation"). Recommend the planner make on-device verification a checkpoint task.
- **PRINT-03:** All non-cheat-sheet UI hidden when printing.

## Out of scope for Phase 3 (deferred)

- Multilingual UI / glosses (Phase 4 covers ES + PT).
- Pilot real-call validation (Phase 5).
- The hardcoded blocks D/G/H content already exists in `index.html` from Phase 1; Phase 3 just renders it — no content changes (unless A1 native-speaker review surfaces issues, which would be a small content patch).

## Open design questions for the planner's discretion

Since discuss-phase was skipped, the planner decides and documents in PLAN.md frontmatter:

1. **Plan decomposition.** Phase 3 is the biggest phase so far. Reasonable cuts:
   - Plan A: render Blocks A–H over the result screen (replaces the Phase 2 raw-JSON result panel).
   - Plan B: print stylesheet + page-break behaviour + Block G visibility-only-on-print.
   - Plan C: onboarding screen + privacy page.
   - Plan D: TRUST-05 housekeeping (REQUIREMENTS.md wording, link target update).
   The planner may merge Plan D into one of the others. Plan A is the load-bearing one — everything else depends on it. Planner picks whether to author 2, 3, or 4 plans.

2. **Result screen → cheat sheet swap.** Phase 2 left a raw-JSON `<pre>`-style result screen. Phase 3 replaces it with the rendered cheat sheet. Planner decides whether to keep a "developer raw view" toggle (helpful for debugging during the pilot) or delete it outright.

3. **Two-column DE/EN layout.** CSS grid? Flexbox? Plain `<table>`? The "two-column" requirement is visual, not semantic. Recommendation: CSS grid for clean print behaviour and clean phone single-column collapse via media query. Planner verifies.

4. **Non-dismissable disclaimer placement.** Pinned at the top of the cheat sheet, visible on screen and on print, never collapsible. Exact wording the planner provides (probably the same as Block H but tightened to one line).

5. **Onboarding screen entry point.** Currently the app boots into the key-entry screen if no key is saved. Recommendation: insert an onboarding screen ahead of key-entry on first visit (detected via a `localStorage.migrationsamt.onboardingSeen` flag, similar to the consent flag from Phase 2). Planner confirms.

6. **Privacy page shape.** Modal? Separate `screen` value (`'privacy'`)? Hyperlink that triggers a state transition? Recommendation: new `screen` value reachable from a "Privacy" link in the header strip on all non-result screens. Planner confirms.

7. **Print page-break strategy.** `page-break-inside: avoid` on each block element. Blocks G + H pinned to the second page if content overflows. Planner specifies exact CSS rules so the executor doesn't drift.

8. **Mobile readability targets.** Minimum body font size on phone (recommend 16px to avoid Safari's auto-zoom on form fields). Maximum line length. Planner documents a brief visual contract.

9. **ASSUMPTION A1 resolution.** The Block D German panic phrases were flagged in Phase 1 for native-speaker review before rendering. Options: (a) ship Phase 3 with the current hardcoded text and flag for Phase 5 pilot review, (b) get a quick review now from a German speaker, (c) ask the LLM to validate as a side task. Planner makes the call and documents it.

10. **Where rendering code lives.** Inline in `index.html` `<script>` block (per L-05). Planner names the new section comments and confirms no extraction.

## Risks to flag

- **`?mock=1` becomes Phase 3's lifeline.** Iterating on the cheat-sheet layout requires running through the result screen repeatedly. Burning $0.01 per change is wasteful. The planner must rely on `MOCK_CHEAT_SHEET` for development, and only re-run a real generation at the end for sanity-check.
- **Print stylesheet has many invisible gotchas:** background colors are dropped by default, `print-color-adjust: exact` only works in some browsers, `@page` size assumes A4 in CH but the user's printer may differ. Plan should include a manual print-preview checklist for the executor.
- **iOS Safari on a real device** is the hardest verification because Francisco doesn't necessarily have one to hand. Plan should accept Chrome devtools emulation as a soft pass with a Phase 5 hard pass at pilot time.
- **CSP impact on print.** Some print-specific font imports would require widening CSP `font-src`. Recommendation: stay with system fonts (already in the body style), no external font.
- **Block A current-day hours computation.** Edge cases: weekends, holidays from `MIGRATIONSAMT.holidays2026`, 24 Dec 2026 (A2 caveat). Recommend a small `computeTodayWindow()` function with a unit-style internal check the executor can grep for.
