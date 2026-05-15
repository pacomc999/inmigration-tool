---
phase: 02-llm-round-trip-english
plan: 02
subsystem: llm
tags: [llm, anthropic, structured-output, json-schema, intake, error-handling]
requires: [02-01-PLAN.md]
provides:
  - "Working end-to-end LLM round-trip from intake to result/error screen"
  - "Locked CHEAT_SHEET_SCHEMA used by Phase 3 rendering"
  - "MOCK_CHEAT_SHEET fixture for Phase 3 dev iteration without API calls"
affects:
  - index.html
  - README.md
tech_stack_added: []
patterns:
  - "Anthropic structured-output via output_config.format (type: json_schema)"
  - "Mock-flag URL switch (?mock=1, ?mock=broken) for zero-cost dev iteration"
  - "HTTP-status-to-errorClass mapping with five user-facing classes"
key_files_created: []
key_files_modified:
  - index.html
  - README.md
decisions:
  - "Anthropic grammar-constrained JSON-schema mode (`output_config.format`) is the production path; tool-use forced-call remains documented as a fallback only"
  - "minItems/maxItems are NOT supported by Anthropic's structured-output schema; entry counts are enforced only by SYSTEM_PROMPT and field description prose"
  - "bad-request error class (non-401/429 4xx) surfaced separately from server-side 5xx to avoid misblaming Anthropic for app-side request bugs"
metrics:
  completed_date: 2026-05-15
  tasks_completed: 6
  duration: "~1 session including a schema-fix iteration at the human-verify checkpoint"
---

# Phase 2 Plan 02 SUMMARY: LLM round-trip in English

**One-liner:** Wired the intake form to a real Anthropic Messages call with grammar-constrained JSON-schema output, plus a loading state, a result screen rendering Blocks B/C/E/F, a five-class error panel, and mock fixtures for zero-cost dev iteration. End-to-end smoke verified by Francisco against `claude-haiku-4-5` with a real key.

## Outcome

**PASS.** Real Anthropic call returned valid German for Blocks B/C/E/F. The cheat-sheet schema and SYSTEM_PROMPT are now load-bearing for Phase 3 rendering.

## What was built

- `ANTHROPIC_API` config block (endpoint, headers, model id `claude-haiku-4-5`, `max_tokens: 2500`, `temperature: 0.3`).
- `SYSTEM_PROMPT` (verbatim from 02-RESEARCH.md Section 1, five XML-style fences for role, forbidden behaviour, generation scope, language anchors, edge cases).
- `CHEAT_SHEET_SCHEMA` (descriptive field names per Francisco's locked decision: `germanLine`, `englishGloss`, `germanQuestion`, `affirmativeGerman`, etc.).
- `MOCK_CHEAT_SHEET` and `MOCK_CHEAT_SHEET_BROKEN` fixtures.
- `?mock=1` / `?mock=broken` URL flag wiring in the request path.
- LLM helpers: `stripFences`, `buildRequestBody`, `callAnthropic`, `parseAndValidateResponse`, `cycleLoadingMessages`.
- Generating / result / error screens, with the result screen rendering Blocks B (opening script), C (officer questions), E (vocabulary), F (prep checklist) via `document.createElement` + `textContent` (no `innerHTML` for LLM output).
- Error panel with five classes: `auth` (401), `rate-limit` (429), `server` (5xx), `bad-request` (non-401/429 4xx), `parse` (JSON shape failure), `network` (fetch threw).
- README updated with the mock flags, per-call cost estimate (about USD 0.01), and model-deprecation hint.

## End-to-end verified

Francisco ran one real generation in desktop Chrome against `claude-haiku-4-5` with his personal `sk-ant-...` key. The result screen rendered Blocks B through F with sensible bureaucratic German appropriate to a Migrationsamt phone call. Approved as a basis for Phase 3 cheat-sheet rendering. (Block A/D/G/H are hardcoded constants from Phase 1 and are not generated, so they were not part of this verification.)

## Commits

| # | Commit | Description |
|---|--------|-------------|
| 1 | `b5d8255` | Add Anthropic API config, system prompt, schema and mock fixtures (Task 1) |
| 2 | `3397a40` | Add LLM helpers, mock-flag branch and loading-message cycle (Task 2) |
| 3 | `9543ff9` | Add generating, result and error screens with render branches (Task 3) |
| 4 | `402cc59` | Replace Generate stub with runGeneration end-to-end flow (Task 4) |
| 5 | `2ad8c55` | Document mock flags, per-call cost and model deprecation in README (Task 5) |
| 6 | `329342b` | Drop unsupported minItems/maxItems and add bad-request error class (Task 6 fix) |

## Deviations from plan

**1. [Rule 1 - Bug] Reworded Task 1 ANTHROPIC_API banner comment to drop the literal retired model id**

- **Found during:** Task 1 automated verify
- **Issue:** The plan asked the comment to mention "Phase 0 lesson learned" with the retired model id, but the file-wide regex `noRetiredModel:!/claude-3-5-haiku/.test(s)` forbids that substring anywhere in the file (including comments).
- **Fix:** Reworded the deprecation comment to say "Phase 0 hit this with an older Haiku id" instead of naming the retired id verbatim.
- **Files modified:** `index.html` (banner comment only).
- **Commit:** folded into `b5d8255`.

**2. [Rule 1 - Bug] Schema rejected by Anthropic for unsupported `minItems`**

- **Found during:** Task 6 (human-verify checkpoint Test C — real Anthropic call)
- **Issue:** Anthropic returned HTTP 400 with `invalid_request_error`: `output_config.format.schema: For 'array' type, 'minItems' values other than 0 or 1 are not supported (got: [2, 5])`. The schema had `minItems: 3/4/6/5` on the four array fields. The 02-RESEARCH.md spec wrote the counts as prose (3-5 / 4-6 / 6-12 / 5-10), the planner translated those into `minItems`/`maxItems`, and Anthropic's grammar-constrained sampling mode rejected the schema at request time.
- **Fix:** Removed all four `minItems` and `maxItems` keys. Counts now live in the field `description` strings and the SYSTEM_PROMPT (which explicitly states the ranges and is followed at `temperature: 0.3`). Added comments in `index.html` documenting the Anthropic constraint so future schema authors don't reintroduce the bug.
- **Files modified:** `index.html` (four schema branches + classifier).
- **Commit:** `329342b`.

**3. [Rule 1 - Bug] 4xx-non-401/429 misclassified as server-side 5xx**

- **Found during:** Same checkpoint failure (the 400 surfaced through the `server` class with copy blaming Anthropic for an outage).
- **Issue:** The classifier mapped 401 → `auth`, 429 → `rate-limit`, everything else → `server`. A 400 from a malformed schema (an app-side bug) showed copy that said the AI service was at fault, misdirecting the user.
- **Fix:** Added a `bad-request` class for `status >= 400 && status < 500` (excluding 401 and 429). New copy: "The request to the AI service was rejected. This usually means a bug in the app and not something you can fix..."
- **Files modified:** `index.html` (classifier + ERROR_COPY map + state-comment type list).
- **Commit:** `329342b`.

## Locked decisions carried into future phases

- **L-08 (new):** Anthropic structured-output JSON schema does NOT support `minItems > 1` or `maxItems`. Future schema additions must put count enforcement in SYSTEM_PROMPT and `description` prose, not in schema keys.
- **L-09 (new):** Five user-facing error classes are now canonical: `auth`, `rate-limit`, `server`, `bad-request`, `parse`, `network` (plus the same with localised copy in Phase 4).

## Flags for downstream phases

- **Phase 3:** Build the cheat-sheet renderer against the LOCKED `CHEAT_SHEET_SCHEMA` in `index.html`. Field names are descriptive (`germanLine`, `englishGloss`, etc.). Use `MOCK_CHEAT_SHEET` to iterate on the print layout and mobile view without burning real API tokens.
- **Phase 3:** ASSUMPTION A1 (Block D German native-speaker review) still pending.
- **Phase 4:** Add ES and PT copy for all five error-class messages and the SYSTEM_PROMPT language anchor.
- **Phase 5:** SYSTEM_PROMPT tuning based on the real pilot debrief. Current prompt is unverified beyond Francisco's one-shot test; pilot will tell us what real officers actually ask.

## Self-check: PASSED

- `index.html` extends Phase 1 cleanly (no Phase 1 functionality regressed).
- `verify-no-mic.ps1` returns zero matches.
- LLM-01 (forbidden behaviour list), LLM-02 (structured JSON), LLM-03 (loading state), LLM-04 (error classes 401/429/500/parse + bonus `bad-request` and `network`), TRUST-02 (consent gate), INTAKE-02..05 (permit, reason, optional refs, free text) are all satisfied.
- Real Anthropic call returns valid German for a B-permit renewal intake.
