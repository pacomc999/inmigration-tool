---
gsd_state_version: 1.0
milestone: v1.0
milestone_name: milestone
status: unknown
last_updated: "2026-05-14T14:14:20.250Z"
progress:
  total_phases: 6
  completed_phases: 3
  total_plans: 5
  completed_plans: 5
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
- **Phase**: 3 - Cheat Sheet Rendering, Print, Mobile, Onboarding, Privacy (ready to plan)
- **Plan**: None yet
- **Status**: Phase 2 complete; ready for `/gsd-plan-phase 3`
- **Progress**: [■■■□□□] 3 of 6 phases complete

## Performance Metrics

- **Phases complete**: 3 of 6
- **Requirements satisfied**: 14 of 29 v1 requirements (SPIKE-01, KEY-01, KEY-02, KEY-03, INTAKE-02, INTAKE-03, INTAKE-04, INTAKE-05, LLM-01, LLM-02, LLM-03, LLM-04, TRUST-02, TRUST-04). KEY-04 dropped (provider toggle obsoleted by Phase 0 outcome).
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

- Phase 3: build the cheat-sheet renderer against the LOCKED `CHEAT_SHEET_SCHEMA` in `index.html`. Use `?mock=1` (MOCK_CHEAT_SHEET fixture) to iterate on print layout and mobile view without burning API tokens.
- Phase 3: amend TRUST-05 onboarding copy (still references "free Gemini API key" in REQUIREMENTS.md; update to Anthropic).
- L-08 (new locked): Anthropic structured-output JSON schema does NOT support `minItems > 1` or `maxItems`. Future schema additions must put count enforcement in SYSTEM_PROMPT and `description` prose.
- L-09 (new locked): Five user-facing error classes are canonical: `auth`, `rate-limit`, `server`, `bad-request`, `parse`, `network`.
- ASSUMPTION A1 (Phase 3): native-speaker review of Block D panic phrases before CHEAT-04 renders them (inline comment in index.html marks the spot)
- ASSUMPTION A2 (Phase 5): re-verify 24 Dec 2026 Migrationsamt schedule against zh.ch before the pilot call (inline comment in index.html marks the spot)
- Phase 5: SYSTEM_PROMPT tuning based on real pilot debrief. Current prompt verified only against one-shot Francisco test; the pilot will reveal what officers actually ask first.

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

- **Last session**: 2026-05-15, Phase 2 executed and human-verified (intake form, locked SYSTEM_PROMPT and CHEAT_SHEET_SCHEMA, real Anthropic call returning sensible German, five-class error UI, mock fixtures, README updated). Schema-fix iteration at the human-verify gate caught the unsupported `minItems` constraint before Phase 3 plans against it.
- **Next action**: Run `/gsd-plan-phase 3` to plan Cheat Sheet Rendering, Print, Mobile, Onboarding, Privacy.
- **Files of record**: `.planning/PROJECT.md`, `.planning/REQUIREMENTS.md`, `.planning/ROADMAP.md`, `.planning/research/SUMMARY.md`, `.planning/phases/00-cors-and-provider-spike/00-CONTEXT.md`

---
*Initialized 2026-05-14 by /gsd-new-project roadmap pass*
