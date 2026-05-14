# Phase 1 Context: Skeleton, State, Key Handling, Static Constants

> **Note:** Francisco opted to skip the formal `/gsd-discuss-phase` step for Phase 1 and let the planner exercise discretion. This file is a minimal stub so downstream agents have a place to anchor decisions.

## Source of truth for goals

See `.planning/ROADMAP.md` → Phase 1 (Goal, Depends on, Requirements, Success Criteria).

## Inherited locked decisions from Phase 0

These are binding for Phase 1 and beyond, established in Phase 0:

- **L-01 (from D-01):** v1 uses Anthropic Messages API only. No Gemini, no OpenAI, no provider toggle.
- **L-02 (from D-03):** All Anthropic requests use the `anthropic-dangerous-direct-browser-access: true` header.
- **L-03 (from CORS spike outcome):** v1 builds against direct browser `fetch` to Anthropic. No backend, no proxy.
- **L-04 (from D-15):** API keys are entered at runtime in a `type="password"` field. Never hardcoded.
- **L-05 (from D-16):** No third-party CDN scripts. No npm. Vanilla HTML/CSS/JS only, single-file inline.
- **L-06 (lifetime guardrail):** No microphone access ever. No `getUserMedia({ audio: true })` anywhere in the code. Tied to Art. 179bis StGB.

## Requirements in scope for Phase 1

Per ROADMAP.md coverage table:

- **KEY-01, KEY-02, KEY-03:** BYO key flow (paste, save, mask after save, clear button, persist in localStorage).
- **KEY-04:** Originally a Gemini/OpenAI provider toggle. **Obsoleted by Phase 0 outcome (L-01).** To be removed from REQUIREMENTS.md during this phase.
- **TRUST-04:** Lifetime microphone guardrail (CSP + grep check).

## Open questions for the planner's discretion

Since discuss-phase was skipped, the planner decides:

1. File layout for the v1 app (single `index.html` per project pattern, plus where the hardcoded Migrationsamt constants live — inline in a `<script>` block, or extracted into a sibling `constants.js`).
2. Exact CSP meta-tag content (`default-src 'self'` baseline, plus whatever `connect-src` is required to allow Anthropic API calls).
3. UI shape and copy for the key-entry screen and the "Clear key" button (this phase produces the skeleton, not the cheat-sheet rendering).
4. How `appState` / `setState` / `render` is structured (per locked decision in STATE.md "Locked Decisions"; reference sibling project pattern in `C:\Users\pacoe\coding_projects` Sector Rojo's `gameState`).
5. Where Phase 1 lives in the repo: a new `app/` directory, or directly in repo root alongside `spike/`.
6. Whether to amend REQUIREMENTS.md as part of this phase (drop KEY-04, amend SPIKE-01 wording) or leave that to a follow-up housekeeping commit.

The planner should make sensible defaults and document them in PLAN.md frontmatter.

## Out of scope for Phase 1

- Cheat sheet rendering (Phase 3).
- LLM round-trip (Phase 2).
- Multilingual UI (Phase 4).
- Print stylesheet (Phase 3).
- Intake form fields beyond a stub (Phase 2).
