# Phase 0: CORS and Provider Spike, Context

**Gathered:** 2026-05-14
**Status:** Ready for planning

<domain>
## Phase Boundary

Prove that a static HTML page deployed to GitHub Pages can call the Anthropic API directly from desktop Chrome using a real key and receive sensible German text in response. Phase 0 ships no v1 code. Its only outputs are a yes/no answer to the CORS question and a decision recorded in PROJECT.md.

Out of scope for this phase: any v1 UI, intake form, cheat sheet rendering, mobile or iOS Safari testing, Gemini, OpenAI, building the proxy fallback. If the spike fails, the choice between proxy and provider pivot is made at that moment, not pre-committed.

</domain>

<decisions>
## Implementation Decisions

### Provider strategy (changed from roadmap)

- **D-01:** v1 ships with Anthropic as the single LLM provider. Gemini and OpenAI are dropped from v1 entirely. No provider toggle in the UI. The user already has an Anthropic API key and will use that for development and pilot.
- **D-02:** Phase 0 spike tests Anthropic CORS only. It does not test Gemini or OpenAI.
- **D-03:** Anthropic browser calls require the opt-in header `anthropic-dangerous-direct-browser-access: true`. The spike must include this header. If Anthropic has since changed the policy or revoked it, the spike will surface that.
- **D-04:** Implication for downstream phases: requirement KEY-04 (provider switching between Gemini and OpenAI) is obsolete and will be dropped or rewritten in Phase 1. Roadmap and REQUIREMENTS.md should be updated to reflect Anthropic-only before Phase 1 planning.

### Platform scope (changed from roadmap)

- **D-05:** v1 is desktop-only. No iOS Safari testing in Phase 0 or any v1 phase. The original SPIKE-01 wording about iOS Safari is superseded.
- **D-06:** Mobile is deferred to a future milestone (not v1). The Phase 3 success criterion about iPhone Safari rendering is now also deferred and should be updated before Phase 3 planning.

### Hosting

- **D-07:** GitHub Pages is the host for both the spike and v1. Pushed via the developer's existing GitHub account (pacomc999). Same origin for spike and v1 so the CORS result is binding.
- **D-08:** Spike artifact lives in a small folder inside the project repo (e.g., `spike/`) and is committed. Not a separate repo. After Phase 0 concludes, the spike folder either stays as a record or is removed in Phase 1. Cleanup decided in Phase 1, not now.

### Pass and fail bar for the spike

- **D-09:** The spike passes when a deployed GitHub Pages URL successfully calls Anthropic with a short German prompt (e.g., translate or compose a 1 to 2 sentence Migrationsamt request) and the response is non-empty and looks like sensible German. Tested on desktop Chrome only.
- **D-10:** A minimal "say hello" prompt is not enough. The spike must use a small Migrationsamt-shaped prompt so it also gives early signal on German bureaucratic vocabulary quality.
- **D-11:** A full JSON-schema response (Blocks B, C, E, F) is NOT required in Phase 0. That belongs in Phase 2.
- **D-12:** If the call returns 200 with a valid completion, the spike passes. If the browser blocks the request with a CORS error, or Anthropic rejects the request with 4xx tied to browser origin, the spike fails.

### Plan B trigger

- **D-13:** If the spike fails, Plan B is decided at that point, not pre-committed. The options on the table are: (a) Cloudflare Workers proxy (small serverless forwarder, free tier, BYOK preserved by passing the key through), or (b) pivot v1 to Gemini and revisit Anthropic later.
- **D-14:** A "decision moment" note must be recorded in PROJECT.md Key Decisions after Phase 0 completes, regardless of pass or fail, capturing what was tested, what worked, and what the architecture commit is going into Phase 1.

### Privacy and security during the spike

- **D-15:** The spike HTML never logs the API key to console, never sends it anywhere except api.anthropic.com, and is removed or sanitized before any code is pushed publicly if the key is ever inlined. Preferred: key entered into a text field on the spike page (not hardcoded in source).
- **D-16:** The spike must not import any third-party CDN script. Plain vanilla `fetch`. This matches the locked CSP `default-src 'self'` posture for v1.

### Claude's Discretion

- Exact prompt text for the spike. Researcher and planner choose a short Migrationsamt-shaped prompt (e.g., "Translate to German: I want to renew my B permit. My case number is ZH-12345.") consistent with the project domain.
- Whether the spike page has any UI beyond a single button and a result area. Minimal is fine, ugly is fine, throwaway is the whole point.
- Exact filename and folder layout of the spike. `spike/index.html` is a reasonable default unless a better convention surfaces during planning.

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Project locked decisions

- `.planning/PROJECT.md` — overall product scope, privacy posture, lifetime guardrails, Hochdeutsch and Migrationsamt domain context
- `.planning/REQUIREMENTS.md` §"Verification, Phase 0" — SPIKE-01 requirement text. Note: provider list (Gemini + OpenAI) is now superseded by D-01.
- `.planning/ROADMAP.md` §"Phase 0: CORS and Provider Spike" — original goal and success criteria. Note: iOS Safari clause superseded by D-05, provider list superseded by D-01.
- `.planning/STATE.md` §"Locked Decisions" — pre-existing locked items. The Gemini-default and OpenAI-toggle items are superseded by D-01 and should be amended at Phase 1.

### External

- Anthropic API documentation for the `anthropic-dangerous-direct-browser-access: true` header and direct browser usage policy. Researcher should fetch the latest official docs to confirm the header name, current policy, and any rate or origin restrictions before planning the spike.
- GitHub Pages deployment basics (developer is on Windows, account pacomc999). Standard docs are fine; no project-local guide exists yet.

### Codebase patterns to align with

- `C:\Users\pacoe\coding_projects\CLAUDE.md` §"Architecture" — single-file vanilla HTML pattern shared with music_animator, Sector_rojo, spaceship_search. The spike should fit the same pattern: one HTML file, inline `<style>` and `<script>`, no build step.

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets

- No prior code in this repo. The project root is empty of source files; only `.planning/` exists.
- Sibling projects (`music_animator/spectrum.html`, `Sector_rojo/index.html`, `spaceship_search/V1 Torus/index.html`) demonstrate the single-file vanilla HTML pattern the spike should mirror.

### Established Patterns

- Single HTML file with inline `<style>` and `<script>`, vanilla JS only, no framework, no build step. The spike must follow this.
- `appState + setState + render` pattern used in Sector Rojo (`gameState`). The spike is too small to need this, but Phase 1 will adopt it.

### Integration Points

- None yet. Phase 0 produces only an answer, not integrated code.

</code_context>

<specifics>
## Specific Ideas

- Developer's GitHub username is `pacomc999`.
- Developer's Anthropic key is the personal key already in hand (not a project-issued or shared key). Spike pricing is effectively zero for the small number of test calls Phase 0 needs.

</specifics>

<deferred>
## Deferred Ideas

- iOS Safari and mobile rendering. Originally part of SPIKE-01 and Phase 3 acceptance. Now a v2 concern.
- Gemini as a free-tier fallback so end users without an Anthropic key could still use the tool. Considered and explicitly dropped from v1. Worth reconsidering when v1 is in pilot if cost-of-key becomes a barrier for real users.
- Cloudflare Workers proxy. Not built in Phase 0. Only built if the spike fails AND the chosen Plan B is the proxy route.
- Stretch goal: testing a stripped-down JSON-schema response in the spike. Moved to Phase 2 where the real LLM round-trip happens.

</deferred>

---

*Phase: 0-cors-and-provider-spike*
*Context gathered: 2026-05-14*
