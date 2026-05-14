# Phase 2 Context: LLM Round-Trip in English

> **Note:** Francisco opted to skip the formal `/gsd-discuss-phase` step for Phase 2 (continuing the pattern from Phase 1). This stub freezes the inherited locked decisions and lists the design choices the planner must make explicitly.

## Source of truth for goals

See `.planning/ROADMAP.md` → Phase 2 (Goal, Depends on, Requirements, Success Criteria 1–5).

## Inherited locked decisions

Carry forward from Phase 0 and Phase 1, binding for Phase 2:

- **L-01:** Anthropic Messages API only. No provider toggle. Use a current Anthropic model id (Phase 0 spike used `claude-haiku-4-5`; `claude-3-5-haiku-latest` is retired).
- **L-02:** All requests use the `anthropic-dangerous-direct-browser-access: true` header plus `anthropic-version: 2023-06-01` and `x-api-key`.
- **L-03:** Direct browser `fetch` to Anthropic. No backend.
- **L-04:** API key entered at runtime, stored only in `localStorage`. Already implemented in Phase 1.
- **L-05:** No third-party CDN scripts. Single-file `index.html` at repo root with inline `<style>` and `<script>`.
- **L-06:** No `getUserMedia` ever. The `verify-no-mic.ps1` script must continue to exit 0 after Phase 2.
- **L-07 (from Phase 1 housekeeping):** TRUST-05 currently mentions "free Gemini API key" — to be amended during Phase 3 onboarding work, NOT in Phase 2.

## Requirements in scope for Phase 2

Per ROADMAP.md coverage table:

- **INTAKE-02:** Permit type from fixed list (L, B, C, Ci, G, N, F, S, "I don't know") — never free text.
- **INTAKE-03:** Reason for calling from curated topic list (renewal, change of status, family reunification, work-permit change, address change, missing document, lost permit, status check, appointment booking, other).
- **INTAKE-04:** Optional structured reference data — case reference number, AHV number, appointment date.
- **INTAKE-05:** Free-text situation description in chosen language. Phase 2 ships English only; ES and PT come in Phase 4 (INTAKE-01 lives in Phase 4 per ROADMAP "Notes on Phase Boundaries").
- **LLM-01:** System prompt forbids contact details, permit-eligibility advice, and strategic legal advice.
- **LLM-02:** LLM returns structured JSON matching the locked Block B/C/E/F schema.
- **LLM-03:** Loading state visible during 10–20s wait, with reassurance messaging.
- **LLM-04:** 401, 429, 500, and JSON-parse errors show user-friendly English messages with "Try again" and "Back to intake" paths.
- **TRUST-02:** Consent checkbox before first generation; cannot submit without checking it.

## Out of scope for Phase 2 (deferred)

- Cheat sheet rendering (Phase 3). The Phase 2 result screen can be a "raw structured output" view (per ROADMAP success criterion 4) — formatted enough that Francisco can sanity-check the JSON, but NOT the printable Block-A-through-H cheat sheet.
- Multilingual UI / glosses (Phase 4).
- Print stylesheet (Phase 3).
- Non-dismissable disclaimer (Phase 3 / TRUST-01).
- Onboarding screen / privacy page (Phase 3 / TRUST-03 / TRUST-05).
- Phrase pronunciation, audio, etc. (deferred to v1.x or v2).

## Open design questions for the planner's discretion

Since discuss-phase was skipped, the planner decides and documents in PLAN.md frontmatter:

1. **System prompt text (LLM-01).** This is the load-bearing design artefact of Phase 2. The planner must compose a draft system prompt that:
   - Establishes role (preparation aid for a Migrationsamt phone call, not a legal advisor)
   - Forbids: inventing contact details, giving permit-eligibility advice, giving strategic legal advice
   - Requires: response is strict JSON matching the locked schema (no prose preamble, no markdown fences around the JSON)
   - Instructs: produce Blocks B (opening script), C (officer questions + answers), E (vocabulary glossary), F (prep checklist) only — A, D, G, H come from hardcoded constants and are NOT generated
   - Anchors language: Hochdeutsch (Standard German) in the German fields; English in the gloss columns for Phase 2
   - Tone: formal, bureaucratic vocabulary, suitable for canton Zürich Migrationsamt context
   The exact wording is the planner's call; flag it as a known iteration target (Phase 5 pilot debrief will inform revisions).

2. **Locked JSON schema for the response (LLM-02).** Define the exact shape, e.g.:
   ```
   {
     "blockB": { "germanLines": [...], "englishGloss": [...] },
     "blockC": [{ "germanQuestion": "...", "englishGloss": "...", "affirmativeDe": "...", "affirmativeEn": "...", "negativeDe": "...", "negativeEn": "..." }, ...],
     "blockE": [{ "article": "der|die|das", "germanWord": "...", "englishTranslation": "..." }, ...],
     "blockF": ["...", "...", ...]
   }
   ```
   Exact field names are the planner's call; document them in PLAN.md so Phase 3 rendering matches.

3. **Anthropic Messages API parameters.** `max_tokens` (estimate 1.5k–2k for Blocks B+C+E+F), `temperature` (probably low, e.g. 0.3, since output should be deterministic and bureaucratic), whether to use Anthropic's prompt-caching feature for the system prompt (likely yes given it never changes across calls).

4. **Intake form UI shape.** Permit dropdown, reason dropdown, three optional reference inputs, free-text textarea. Where consent checkbox lives relative to Generate button. Loading-state copy (reassurance messages during 10–20s wait).

5. **Result screen shape (Phase 2 only).** Per ROADMAP "even as raw structured output". Likely a `<pre>` with the parsed JSON pretty-printed, plus the schema field labels visible. Phase 3 replaces this with the Block A–H cheat sheet view.

6. **Error UI shape (LLM-04).** Single shared error panel with conditional copy by status code? Or separate handling per error class? Beginner-friendly recommendation: one panel, one switch statement on status.

7. **State machine.** `appState.screen` already exists from Phase 1 (`'key-entry' | 'ready'`). Phase 2 likely adds `'intake' | 'generating' | 'result' | 'error'`. Document the transitions.

8. **Where the system prompt and schema live in code.** Inline JS constants in `index.html` (per L-05) — but in a clearly labelled section the planner can name and document.

## Risks to flag

- Anthropic JSON-mode reliability: Claude can occasionally emit prose around the JSON. The planner should research whether to use Anthropic's tool-use / structured-output feature, or `response_format`-equivalent, or rely on prompting and a tolerant parser. RESEARCH.md should address this concretely.
- Token cost: Phase 2 spends real money per call. Note expected cost-per-generation for `claude-haiku-4-5` so Francisco has a back-of-envelope figure before the Phase 5 pilot.
- LLM safety drift: The system prompt's forbids must be specific. Generic "don't give legal advice" is weak; concrete examples of refused requests are stronger. Researcher should propose a tested approach.
- No telemetry / no logging: if a generation fails, Francisco has no server-side logs. The result screen and error panel are the only diagnostics. UX should be clear about what to copy-paste back for debugging.
