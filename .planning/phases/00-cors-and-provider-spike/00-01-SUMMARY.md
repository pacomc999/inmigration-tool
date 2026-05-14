---
phase: 00-cors-and-provider-spike
plan: 01
subsystem: spike
tags: [cors, anthropic, spike, github-pages]
requires: []
provides: [anthropic-direct-browser-fetch-confirmed]
affects: [.planning/PROJECT.md, REQUIREMENTS.md (KEY-04 obsolete)]
tech_stack_added: []
patterns: [single-file vanilla HTML spike, direct browser fetch to Anthropic Messages API]
key_files_created:
  - spike/index.html
key_files_modified:
  - .planning/PROJECT.md
decisions:
  - "Phase 1 builds against direct browser fetch to Anthropic (D-01 confirmed)"
  - "claude-3-5-haiku-latest is retired; use claude-haiku-4-5 or another current model id"
  - "KEY-04 (provider toggle) is obsolete and will be dropped in Phase 1 planning"
metrics:
  completed_date: 2026-05-14
  tasks_completed: 3
  duration: "~1 session"
---

# Phase 0 Plan 1: Anthropic CORS Spike Summary

**One-liner:** Confirmed that a static GitHub Pages page can call Anthropic Messages API directly from desktop Chrome with the `anthropic-dangerous-direct-browser-access: true` header, returning sensible German for a Migrationsamt-shaped prompt.

## Outcome

**PASS.** The load-bearing assumption behind v1 (no backend, BYOK, direct browser fetch) holds for Anthropic on desktop Chrome.

## What Was Built

- `spike/index.html`: a single-file vanilla HTML page with inline `<style>` and `<script>`, one password field for the API key, one "Run spike" button, a status line, and a result area. No CDN scripts, no SDK, no build step.
- The page POSTs to `https://api.anthropic.com/v1/messages` with headers `x-api-key`, `anthropic-version: 2023-06-01`, `anthropic-dangerous-direct-browser-access: true`, and `content-type: application/json`. Response is rendered to the DOM via `textContent` only.

## Exact Prompt Used

User message content sent to Anthropic:

> Translate the following into formal Standard German suitable for a phone call to the Migrationsamt of canton Zürich. Reply with only the German translation, no explanation. Source: I would like to renew my B residence permit. My case reference number is ZH-12345.

## Exact Response Received

> Ich möchte meine B-Aufenthaltserlaubnis erneuern. Meine Geschäftsreferenznummer ist ZH-12345.

HTTP 200. No CORS preflight failure, no browser-origin rejection. Status line read "success".

## Model Used at Execution Time

`claude-haiku-4-5`.

The plan suggested `claude-3-5-haiku-latest`, but at execution time that model id returned a 404 (the model has been retired). The executor swapped the model id to `claude-haiku-4-5` in commit `1418075`, and the retest passed. Phase 1 planning should select a current model id and not assume `claude-3-5-haiku-latest` is available.

## GitHub Pages Status

GitHub Pages was NOT enabled at the start of this phase. Francisco enabled it manually via the repo Settings → Pages page during Task 2, with source set to the `master` branch and folder set to root. The spike was served at `/spike/` from that point on, and the production CORS test was run against the Pages URL (not against a local file or local server), so the result is binding for the v1 origin.

## Architecture Commit for Phase 1

- v1 builds against **direct browser fetch to Anthropic**. No backend, no Cloudflare Workers proxy.
- The `anthropic-dangerous-direct-browser-access: true` header is required and works.
- KEY-04 (Gemini/OpenAI provider toggle) is obsolete and should be removed from REQUIREMENTS.md when Phase 1 is planned.
- The SPIKE-01 wording in REQUIREMENTS.md that still mentions Gemini, OpenAI, and iOS Safari is superseded by D-01, D-02, and D-05 and should be amended in Phase 1 planning.

## Scope Note

The result is desktop-Chrome-only and Anthropic-only (per D-02, D-05). It does not say anything about Gemini, OpenAI, or iOS Safari. iOS Safari and other providers remain out of v1 scope.

## Commits

| Task | Commit | Description |
|------|--------|-------------|
| 1 | `98f2bac` | Add Anthropic CORS spike page |
| 1 (fix) | `1418075` | Update spike model to claude-haiku-4-5 (after `claude-3-5-haiku-latest` 404'd) |
| 2 | (human verification, no commit) | Francisco enabled GitHub Pages and ran the live CORS test in desktop Chrome |
| 3 | `a47d48f` | Record Phase 0 CORS spike outcome in PROJECT.md |

## Deviations from Plan

**1. [Rule 1 - Bug] Anthropic model id swap**

- **Found during:** Task 2 (human verification of the live spike call)
- **Issue:** The model id suggested by the plan, `claude-3-5-haiku-latest`, returned a 404 from Anthropic at execution time. The model has been retired.
- **Fix:** Swapped the model id in `spike/index.html` to `claude-haiku-4-5`, a current Haiku model. Retest from the GitHub Pages URL in desktop Chrome returned HTTP 200 with sensible German.
- **Files modified:** `spike/index.html`
- **Commit:** `1418075`

No other deviations. No auth gates beyond the standard BYOK pattern (Francisco pasted his Anthropic key into the password field at runtime).

## Self-Check: PASSED

- `spike/index.html` exists in the repo (commits `98f2bac`, `1418075`).
- `.planning/PROJECT.md` contains the Phase 0 outcome entry under Key Decisions (commit `a47d48f`).
- Task 3 automated verify (the `node -e` one-liner in the plan) exits 0; all six checks return true.
