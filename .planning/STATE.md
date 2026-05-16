---
gsd_state_version: 1.0
milestone: v1.0
milestone_name: milestone
status: unknown
last_updated: "2026-05-14T14:14:20.250Z"
progress:
  total_phases: 6
  completed_phases: 4
  total_plans: 8
  completed_plans: 8
  percent: 100
---

# STATE

Single source of truth for project memory. Updated at every transition.

## Project Reference

- **Name**: Migrationsamt Zürich Call Helper
- **Core value**: Eliminate the language-barrier moment when a non-German speaker has to call the Migrationsamt about their permit, so the call actually achieves what the user came to do
- **Current focus**: Phase 0, CORS and Provider Spike (de-risk before architecture lock-in)
- **Lifetime guardrail**: The app NEVER accesses the microphone. No `getUserMedia({ audio: true })` in any phase or any future version (Art. 179bis StGB).

## Current Position

- **Milestone**: v1
- **Phase**: 4 - Multilingual Intake and Glosses (ES + PT) (ready to plan)
- **Plan**: None yet
- **Status**: Phase 3 complete; ready for `/gsd-plan-phase 4`
- **Progress**: [■■■■□□] 4 of 6 phases complete

## Performance Metrics

- **Phases complete**: 4 of 6
- **Requirements satisfied**: Phase 3 ships CHEAT-01..08, PRINT-01 (full pass), PRINT-02 (soft pass, hard pass deferred to Phase 5 on real iPhone), PRINT-03, TRUST-01, TRUST-03, TRUST-05. REQUIREMENTS.md checkboxes are deliberately left for a manual review pass before formally ticking. Functionally validated by `?mock=1` walkthrough + print preview + iPhone 15 Pro emulation. KEY-04 dropped.
- **First-real-user pilot**: not yet attempted
- **CORS spike**: PASS (Anthropic direct browser fetch, desktop Chrome, 2026-05-14)

## Accumulated Context

### Locked Decisions (carry across all phases)

- Single `index.html` file with inline `<style>` and `<script>`, vanilla HTML/CSS/JS only, no framework, no TypeScript, no build step
- Direct browser `fetch` to LLM provider, no backend, no SDK (subject to Phase 0 spike outcome)
- Gemini 2.5 Flash default, OpenAI (gpt-4o-mini or gpt-5-mini) as toggle
- BYO key in localStorage (plain), with one-click "Clear key" button, `type="password"` field, masked after save
- Structured JSON output from LLM, rendered via `createElement` + `textContent` (zero `innerHTML` from LLM output)
- Single `appState` + `setState()` + `render()` pattern (same shape as Sector Rojo's `gameState`)
- Strict CSP `default-src 'self'`, zero third-party scripts at runtime, self-host all assets
- Hosting: Netlify Drop for v1, GitHub Pages as Git-friendly alternative
- All Migrationsamt facts (phone, address, hours, 2026 holidays) are hardcoded constants; the LLM never generates contact info
- Permit category is a structured select (L/B/C/Ci/G/N/F/S/"I don't know"), never free text
- Microphone access permanently out of scope (Art. 179bis StGB)
- v1 ships English first end-to-end, then duplicates for ES and PT in Phase 4
- Cheat sheet not persisted across sessions; only the API key and structured intake answers are persisted

### Open Todos

- Phase 4: add ES and PT for all UI strings, error copy, onboarding/privacy text, and the SYSTEM_PROMPT language anchor so glosses render in the user's chosen language. LANG-01, LANG-02, INTAKE-01.
- L-08 (locked): Anthropic structured-output JSON schema does NOT support `minItems > 1` or `maxItems`. Future schema additions must put count enforcement in SYSTEM_PROMPT and `description` prose.
- L-09 (locked): Six canonical error classes: `auth`, `rate-limit`, `server`, `bad-request`, `parse`, `network`. Phase 4 localises these.
- L-10 (new locked): The cheat-sheet DOM contract (block IDs `#blockA` through `#blockH`, `.bilingual-row` two-column grid, `.cheat-sheet-block`, `.cheat-sheet-print-only`, `.cheat-sheet-controls`, `.cheat-sheet-disclaimer`) is the canonical structure. Phase 4 layers translated strings over this DOM without changing IDs or classes.
- L-11 (new locked): Block A current-day hours read from `MIGRATIONSAMT.phoneHours` + `MIGRATIONSAMT.closures2026` via `computeTodayWindow()` (client-clock based). On 2026-12-24 displays inline note "(24 Dec schedule unconfirmed)" per ASSUMPTION A2.
- ASSUMPTION A1 (Phase 5): native-speaker review of Block D panic phrases before pilot. Inline comment in index.html marks the spot.
- ASSUMPTION A2 (Phase 5): re-verify 24 Dec 2026 Migrationsamt schedule against zh.ch before the pilot call.
- PRINT-02 hard pass: deferred to Phase 5 (real iPhone instead of devtools emulation).
- Phase 5: SYSTEM_PROMPT tuning based on real pilot debrief.
- Phase 3 REQUIREMENTS.md checkboxes for CHEAT-01..08, PRINT-01..03, TRUST-01, TRUST-03, TRUST-05 are deliberately left unticked pending a manual review pass; functional verification via `?mock=1` walkthrough is in `03-01/02/03-SUMMARY.md`.

### Active Blockers

None.

### Open Questions (deferred to specific phases)

| Question | Phase |
|---|---|
| Does Gemini 2.5 Flash produce high-quality German bureaucratic vocabulary, or is Pro required? | 2 |
| Streaming vs single-response for a 10-30s generation? | 2 |
| Per-session vs persistent key (paranoid mode toggle)? | 3 |
| Demo cheat sheet: real generated example or static fixture? | 3 |
| What does the Migrationsamt officer actually ask first on a routine permit call? | 5 |

## Session Continuity

- **Last session**: 2026-05-16, Phase 3 executed (cheat-sheet rendering for Blocks A-H, TRUST-01 sticky disclaimer, `computeTodayWindow()`, `?raw=1` developer toggle, in-page Print button, A4 print stylesheet with `print-color-adjust: exact`, 480px mobile breakpoint, onboarding screen, privacy page, TRUST-05 wording amendment in REQUIREMENTS.md). Print preview + iPhone-15-Pro emulation human-verified.
- **Next action**: Run `/gsd-plan-phase 4` to plan Multilingual Intake and Glosses (ES + PT).
- **Files of record**: `.planning/PROJECT.md`, `.planning/REQUIREMENTS.md`, `.planning/ROADMAP.md`, `.planning/research/SUMMARY.md`, `.planning/phases/00-cors-and-provider-spike/00-CONTEXT.md`

---
*Initialized 2026-05-14 by /gsd-new-project roadmap pass*
