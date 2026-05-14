# Phase 0: CORS and Provider Spike, Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-05-14
**Phase:** 0-cors-and-provider-spike
**Areas discussed:** Provider choice, Mobile scope, Hosting, Pass and fail bar, Plan B

---

## Area selection

User was offered four gray areas (Hosting choice, iOS Safari access, API keys on hand, Pass and fail bar) and replied freeform: pick hosting, use Anthropic instead of Gemini and OpenAI, skip mobile. This expanded the conversation to Provider and Mobile in addition to Hosting and the Pass/Plan-B bar.

---

## Provider strategy

| Option | Description | Selected |
|--------|-------------|----------|
| Anthropic only, drop Gemini and OpenAI from v1 | Single provider, no UI toggle. Plan B triggered for Anthropic only. | ✓ |
| Anthropic only for the spike, decide on providers later | Spike just proves Anthropic works. Provider scope deferred. | |
| Anthropic primary, keep Gemini as a free fallback | Anthropic for quality, Gemini as a free backup; spike tests both. | |
| Just use Anthropic key for dev, ship with Gemini default | Develop against Anthropic, ship with Gemini for end users. | |

**User's choice:** Anthropic only, drop Gemini and OpenAI from v1.
**Notes:** Implication flagged that this contradicts the original research recommendation (Anthropic CORS was historically the reason for picking Gemini and OpenAI). The opt-in header `anthropic-dangerous-direct-browser-access: true` is the load-bearing detail the researcher must confirm. Requirement KEY-04 (provider switching) becomes obsolete and must be revised before Phase 1 planning.

---

## Mobile and iOS Safari

| Option | Description | Selected |
|--------|-------------|----------|
| Skip mobile entirely for v1, desktop-only ship | v1 is desktop-only. Print or display on laptop. Mobile is v2. | ✓ |
| Skip mobile testing now, but keep the UI mobile-friendly | Defer iOS Safari, but Phase 3 still aims for responsive layout. | |
| Test mobile later, not in Phase 0 | Defer mobile verification to a later checkpoint, not Phase 0. | |

**User's choice:** Skip mobile entirely for v1, desktop-only ship.
**Notes:** This supersedes the iOS Safari clause of SPIKE-01 and the Phase 3 mobile rendering acceptance criterion. Both should be reworded before their planning phases.

---

## Hosting

| Option | Description | Selected |
|--------|-------------|----------|
| GitHub Pages | Free, HTTPS, matches developer's existing GitHub workflow (pacomc999). | ✓ |
| Netlify Drop | Drag and drop, instant URL, no Git needed. | |
| Cloudflare Pages | Free, fastest CDN, slight setup overhead. | |
| Local file only for the spike, decide host later | file:// origin, would NOT prove the v1 architecture. | |

**User's choice:** GitHub Pages.
**Notes:** Same host for spike and v1 so the CORS outcome is binding. Developer is on Windows and has an existing GitHub presence.

---

## Pass and fail bar

| Option | Description | Selected |
|--------|-------------|----------|
| Minimal: non-empty response from Anthropic on desktop Chrome | Any test prompt, any non-empty completion. Simplest. | |
| Realistic: short German prompt returns sensible German text | Migrationsamt-shaped mini prompt. Early signal on German quality. | ✓ |
| Stretch: stripped-down v1 prompt returns valid JSON | Mini schema test. Highest confidence but belongs in Phase 2. | |

**User's choice:** Realistic: short German prompt returns sensible German text.
**Notes:** Stretch JSON test is explicitly deferred to Phase 2 where the full LLM round trip lives.

---

## Plan B trigger

| Option | Description | Selected |
|--------|-------------|----------|
| Cloudflare Workers proxy (~30 lines, free tier, no logging) | Small serverless forwarder, BYOK preserved. | |
| Switch v1 to Gemini, revisit Anthropic later | Pivot v1 to a free-tier provider, defer Anthropic. | |
| Decide at the time | Capture both options but do not pre-commit. | ✓ |

**User's choice:** Decide at the time.
**Notes:** Phase 0 must produce a written architecture decision in PROJECT.md Key Decisions regardless of pass or fail, so Phase 1 starts from a settled position.

---

## Claude's Discretion

- Exact prompt text used in the spike (researcher and planner pick a Migrationsamt-shaped short prompt).
- Whether the spike page has any UI beyond a single button and a result area.
- Exact filename and folder layout for the spike (default `spike/index.html`).

## Deferred Ideas

- iOS Safari testing and mobile rendering (deferred to v2).
- Gemini as a free-tier fallback for end users without an Anthropic key.
- Cloudflare Workers proxy (only built if spike fails AND proxy is the chosen Plan B).
- Stretch goal of testing JSON-schema responses in the spike (moved to Phase 2).
