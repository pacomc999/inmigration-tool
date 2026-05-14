---
gsd_state_version: 1.0
milestone: v1.0
milestone_name: milestone
status: unknown
last_updated: "2026-05-14T14:14:20.250Z"
progress:
  total_phases: 6
  completed_phases: 1
  total_plans: 1
  completed_plans: 1
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
- **Phase**: 1 - Skeleton, State, Key Handling, Static Constants (ready to plan)
- **Plan**: None yet
- **Status**: Phase 0 complete; ready for `/gsd-plan-phase 1`
- **Progress**: [■□□□□□] 1 of 6 phases complete

## Performance Metrics

- **Phases complete**: 1 of 6
- **Requirements satisfied**: 1 of 30 v1 requirements (SPIKE-01)
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

- Phase 1 planning: amend SPIKE-01 wording (still references Gemini, OpenAI, iOS Safari; superseded by D-01, D-02, D-05), and drop KEY-04 (provider toggle) from REQUIREMENTS.md per Phase 0 outcome
- Phase 1: pick a current Anthropic model id (do not reuse `claude-3-5-haiku-latest`, retired). Spike used `claude-haiku-4-5`.

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

- **Last session**: 2026-05-14, Phase 0 executed and PASSED (Anthropic CORS spike on desktop Chrome via GitHub Pages)
- **Next action**: Run `/gsd-plan-phase 1` to plan Skeleton, State, Key Handling, Static Constants (committing to direct Anthropic fetch per Phase 0 outcome)
- **Files of record**: `.planning/PROJECT.md`, `.planning/REQUIREMENTS.md`, `.planning/ROADMAP.md`, `.planning/research/SUMMARY.md`, `.planning/phases/00-cors-and-provider-spike/00-CONTEXT.md`

---
*Initialized 2026-05-14 by /gsd-new-project roadmap pass*
