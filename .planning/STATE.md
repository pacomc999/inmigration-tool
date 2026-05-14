# STATE

Single source of truth for project memory. Updated at every transition.

## Project Reference

- **Name**: Migrationsamt Zürich Call Helper
- **Core value**: Eliminate the language-barrier moment when a non-German speaker has to call the Migrationsamt about their permit, so the call actually achieves what the user came to do
- **Current focus**: Phase 0, CORS and Provider Spike (de-risk before architecture lock-in)
- **Lifetime guardrail**: The app NEVER accesses the microphone. No `getUserMedia({ audio: true })` in any phase or any future version (Art. 179bis StGB).

## Current Position

- **Milestone**: v1
- **Phase**: 0 - CORS and Provider Spike
- **Plan**: None yet
- **Status**: Not started
- **Progress**: [□□□□□□] 0 of 6 phases complete

## Performance Metrics

- **Phases complete**: 0 of 6
- **Requirements satisfied**: 0 of 30 v1 requirements
- **First-real-user pilot**: not yet attempted
- **CORS spike**: not yet run

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

- Phase 0 spike: deploy a throwaway HTML to real production host, fetch Gemini + OpenAI from desktop Chrome and iOS Safari
- If spike fails, scaffold the Cloudflare Workers proxy fallback (~30 lines, no logging)

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

- **Last session**: 2026-05-14, roadmap created
- **Next action**: Run `/gsd-plan-phase 0` to plan the CORS spike
- **Files of record**: `.planning/PROJECT.md`, `.planning/REQUIREMENTS.md`, `.planning/ROADMAP.md`, `.planning/research/SUMMARY.md`

---
*Initialized 2026-05-14 by /gsd-new-project roadmap pass*
