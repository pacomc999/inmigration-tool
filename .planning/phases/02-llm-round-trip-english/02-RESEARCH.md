# Phase 2: LLM Round-Trip in English - Research

**Researched:** 2026-05-14
**Domain:** Anthropic Messages API browser integration, structured JSON output, system-prompt design, intake form UX, error handling
**Confidence:** HIGH (Anthropic structured outputs, prompt caching, pricing, tool-use, CORS header); MEDIUM (system-prompt exact wording, intake copy — tunable post-pilot)

<user_constraints>
## User Constraints (from CONTEXT.md and STATE.md)

### Locked Decisions (binding from Phase 0 and Phase 1)

- **L-01:** Anthropic Messages API only. No provider toggle. Use a current model id; `claude-3-5-haiku-latest` is retired. Phase 0 spike used `claude-haiku-4-5`. [VERIFIED: 00-CONTEXT.md D-01; 00-01-SUMMARY.md]
- **L-02:** All requests use the `anthropic-dangerous-direct-browser-access: true` header plus `anthropic-version: 2023-06-01` and `x-api-key`. [VERIFIED]
- **L-03:** Direct browser `fetch` to Anthropic. No backend, no proxy. [VERIFIED]
- **L-04:** API key entered at runtime, stored only in `localStorage`. Already implemented in Phase 1 (`STORAGE_KEY = 'migrationsamt.anthropicKey'`). [VERIFIED]
- **L-05:** No third-party CDN scripts. Single-file `index.html` at repo root with inline `<style>` and `<script>`. [VERIFIED]
- **L-06:** No `getUserMedia` ever. `verify-no-mic.ps1` must continue to exit 0 after Phase 2. [VERIFIED]
- **L-07:** TRUST-05 onboarding copy is Phase 3 work, NOT Phase 2. [VERIFIED]
- CSP `connect-src` is already `https://api.anthropic.com` (Phase 1) — no CSP edits needed for Phase 2. [VERIFIED: index.html lines 13-23]

### Claude's Discretion (per 02-CONTEXT.md)

1. Exact system prompt text (LLM-01).
2. Exact JSON schema field names (LLM-02 — must match between Phase 2 send and Phase 3 render).
3. Anthropic Messages API parameters: `max_tokens`, `temperature`, prompt caching.
4. Intake form layout and copy.
5. Phase-2-only result screen shape (replaced in Phase 3).
6. Error UI shape (LLM-04).
7. State-machine extensions to `appState.screen`.
8. Code location of system prompt + schema inside `index.html`.

### Deferred Ideas (OUT OF SCOPE for Phase 2)

- Block A/D/G/H rendering (Phase 3).
- Two-column cheat-sheet print stylesheet (Phase 3).
- Multilingual UI / glosses — ES, PT (Phase 4).
- Non-dismissable disclaimer (Phase 3 / TRUST-01).
- Onboarding screen / privacy page (Phase 3 / TRUST-03 / TRUST-05).
- Live AI interpreter on the call (v2; PROJECT.md Out of Scope).
- Pronunciation audio (v1.x).
- iOS Safari rendering (deferred to v2 per Phase 0 D-05).

</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| INTAKE-02 | Permit type from fixed list (L/B/C/Ci/G/N/F/S/"I don't know"), never free text | Section 5 — form layout |
| INTAKE-03 | Reason for calling from curated topic list | Section 5 — reason dropdown |
| INTAKE-04 | Optional reference fields: case ref number, AHV number, appointment date | Section 5 — optional fields block |
| INTAKE-05 | Free-text situation description in English | Section 5 — textarea + helper copy |
| LLM-01 | System prompt forbids contact details, permit-eligibility advice, strategic legal advice | Section 1 — full prompt draft |
| LLM-02 | LLM returns structured JSON matching Block B/C/E/F schema | Sections 2, 3 — output_config + schema |
| LLM-03 | Loading state with reassurance messages during 10–20s wait | Section 5 — cycling loading messages |
| LLM-04 | 401, 429, 500, JSON-parse errors with friendly EN messages and Try-again / Back paths | Section 7 — error UI + copy |
| TRUST-02 | Consent checkbox before first generation; cannot submit unchecked | Section 5 — checkbox copy + gate |

</phase_requirements>

## Summary

Phase 2 turns the static Phase 1 skeleton into a working LLM round-trip. The user fills a structured intake form (4 fields + a free-text area + a one-time consent), the app builds a single Anthropic Messages request, parses the JSON response against a locked schema, and shows either a raw structured-output view or a friendly error.

Two technical findings drive everything else:

1. **Anthropic now ships a native structured-output feature** called `output_config.format` with `type: "json_schema"`. It uses grammar-constrained sampling, so the model literally cannot return invalid JSON for the schema. It is generally available on `claude-haiku-4-5` and requires no beta headers as of the current docs. This is the most reliable option and is strictly better than the older tool-use-as-structured-output trick for a beginner one-shot v1. We document the tool-use approach as a fallback in case `output_config` ever misbehaves, but the recommendation is `output_config`. [CITED: platform.claude.com/docs/en/docs/build-with-claude/structured-outputs]

2. **Prompt caching pays for itself after one cache hit on the 5-min TTL** (1.25x write, 0.1x read). The Migrationsamt system prompt + JSON schema together are ~1.5–2k tokens of stable prefix that every call reuses. With `claude-haiku-4-5` at $1/MTok input, the per-call savings are small in absolute terms (single cents), but the latency benefit (cache-hit reads are markedly faster) is the real win on a 10–20s wait. Below the 4,096-token cache minimum for Haiku 4.5, however, caching is silently skipped. Our system prompt + schema together are below that threshold, so v1 should NOT enable caching — it will not error, just no-op. We document this and re-evaluate post-pilot. [CITED: platform.claude.com/docs/en/build-with-claude/prompt-caching — 4096-token min for Haiku 4.5]

Beyond those, the design is small: extend `appState.screen` from `{key-entry, ready}` to add `{intake, generating, result, error}`, keep the consent boolean in `appState.consentGiven` so it survives screen swaps, hold the most recent intake in `appState.lastIntake` so a 401 doesn't lose the user's typing, build the request with `max_tokens: 2500` and `temperature: 0.3`, and render the result as labelled block sections plus a `<pre>` JSON dump for sanity-checking. A `?mock=1` URL flag returns a hardcoded fixture so Francisco can iterate on Phase 3 rendering without burning real tokens.

**Primary recommendation:** Use `output_config.format` with `type: "json_schema"`, schema verbatim from Section 3. Model `claude-haiku-4-5`, `max_tokens: 2500`, `temperature: 0.3`, no prompt caching for v1 (under minimum cacheable size). System prompt verbatim from Section 1. Intake form, result screen, error UI, state machine, and code layout per Sections 5–9. Add `?mock=1` mock-fixture flag (Section 10) for dev iteration.

## Architectural Responsibility Map

| Capability | Primary Tier | Secondary Tier | Rationale |
|------------|-------------|----------------|-----------|
| Render intake form / loading / result / error | Browser DOM | — | Vanilla single-file app, no SSR |
| Hold intake state for 401 recovery | In-memory `appState` | — | Survives screen swap, not persisted (cheat sheet is per-session) |
| Persist consent flag | `localStorage` (one boolean) | — | TRUST-02 says first-time only, so we need to remember it across reloads |
| Build LLM request body | Browser JS | — | Same origin as `index.html`, allowed by CSP `connect-src` |
| Call Anthropic | `fetch()` to `api.anthropic.com` | — | L-03 direct browser fetch |
| Parse and validate JSON response | Browser JS | — | `output_config.format` guarantees schema; we still parse defensively |
| Surface 4xx/5xx/parse errors | Browser DOM | — | No telemetry, no backend |
| Source of truth for Migrationsamt facts | Phase 1 constants | — | LLM is never asked to generate Block A/D content |

## 1. System Prompt Design (LLM-01)

### Anthropic's prompt-engineering guidance applied here

Anthropic's official prompt-engineering guide for Claude 4.x models recommends: (a) clear role definition in the `system` field, separate from user content; (b) XML-style tags to fence examples or domain context; (c) explicit forbidden-behaviour rules with concrete examples are far stronger than abstract rules; (d) when structured output is required, prefer `output_config.format` over prompt-instructions ("respond with JSON only" is a hint, the schema is the enforcer). [CITED: platform.claude.com/docs/en/build-with-claude/prompt-engineering — best-practices guide for Opus 4.7 / Haiku 4.5]

For Phase 2 specifically, the system prompt does three jobs: (1) lock the role, (2) list concrete forbidden requests with concrete refusal patterns, (3) scope the generation to Blocks B/C/E/F with Hochdeutsch in German fields and English in glosses. The schema enforcement lives in `output_config.format` (Section 2), not in prose.

### Draft system prompt (copy-pasteable)

```text
You are a preparation aid for a single phone call to the Migrationsamt of canton Zürich (the cantonal migration office of Zurich, Switzerland). A non-German-speaking user is about to make this call themselves. Your only job is to produce a tailored German cheat sheet in strict JSON, so the user has key phrases, likely questions, vocabulary, and a checklist in front of them during the call.

<role_boundaries>
You are NOT a legal advisor. You do NOT give immigration-law advice, permit-eligibility advice, or strategic advice about what the user "should" do. You are NOT a representative: you never speak to the Migrationsamt on the user's behalf, and the cheat sheet never instructs the user to lie, impersonate, or read your output verbatim if it would mislead the officer. You are NOT a live translator: this is preparation only, not real-time interpretation.
</role_boundaries>

<forbidden_behaviour>
1. Never generate Migrationsamt contact details. If your output would include a phone number, email address, postal address, opening hours, or office name, omit it. Those facts are inserted by the calling application from a separately verified source. If the user asks for contact details, respond inside the schema that the calling application provides the contact details separately, and do not invent any.
2. Never give permit-eligibility advice. Do not state "you qualify for permit X" or "you should apply for Y". If the user's free-text situation asks "can I get a C permit", treat the call as a status check or appointment-booking call, and let the officer answer eligibility on the phone.
3. Never give strategic legal advice. Do not suggest withholding information from the officer, framing the situation a certain way to improve outcomes, or workarounds. The cheat sheet is for clarity, not strategy.
4. Never produce content outside the schema. Do not add an introduction, an explanation, an apology, or a markdown code fence. The response is strict JSON, nothing else.
5. Never invent reference numbers, AHV numbers, dates, or facts the user did not provide. If a field is empty in the intake, leave any sentence that would use it out of the German script.
</forbidden_behaviour>

<generation_scope>
Generate ONLY these blocks of the cheat sheet, in the JSON schema provided by the calling application:
- Block B: opening script (3–5 lines), including a one-sentence statement of the user's goal in formal Hochdeutsch and an optional reference-number sentence if the intake provides one.
- Block C: likely officer questions and suggested answers, at least 4 entries, covering the user's chosen reason-for-calling topic, with both affirmative and negative answer forms in German plus English glosses.
- Block E: vocabulary mini-glossary, 6 to 12 German domain words relevant to the user's situation, each with the correct article (der/die/das) and English translation.
- Block F: prep checklist tailored to the intake, 5 to 10 actionable items (documents to have ready, reference numbers, phone charged, sheet open).

Do NOT generate the call header, panic phrases, note-taking lines, or footer notice. Those are hardcoded by the calling application.
</generation_scope>

<language_anchors>
- All German fields use formal Hochdeutsch (Standard German), suitable for a phone call with a cantonal civil servant. Use "Sie" form throughout. Avoid Swiss German, dialect, and colloquialisms.
- All English-gloss fields use plain, clear English aimed at a non-native speaker preparing for the call.
- Tone is bureaucratic, polite, concise. Match the register the Migrationsamt itself uses in published correspondence: "Sehr geehrte Damen und Herren", "Ich möchte...", "Können Sie mir bitte mitteilen, ob...".
</language_anchors>

<edge_cases>
- If the user's free-text situation is empty: still generate Blocks B, C, E, F based on permit type and reason-for-calling alone. Make Block F slightly more generic.
- If the user's free-text situation is gibberish or in a language you cannot parse: produce a Block B with a minimal opening, a Block C with the 4 most common questions for the chosen reason-for-calling, a generic Block E, and a Block F that includes "Have a clear summary of your situation written down before calling".
- If the user's free-text situation is off-topic for the Migrationsamt (e.g. "I want to cancel my Spotify subscription"): produce a Block B that politely asks the officer to clarify whether they are the correct office, a Block C with a handful of generic clarification questions, a generic Block E, and a Block F that includes "Confirm that the Migrationsamt is the correct office for your concern before going further".
</edge_cases>

Reply in JSON only. The calling application enforces the schema via the API's structured-output feature; your response must validate against it.
```

### Notes on the prompt

- The XML-style tags (`<role_boundaries>`, `<forbidden_behaviour>`, etc.) follow Anthropic's documented best practice for fencing distinct instruction sections. [CITED: prompt-engineering guide]
- The forbidden-behaviour items use the strong pattern Anthropic recommends: "If X, do Y" with a concrete refusal pattern, not "don't do X".
- The "Reply in JSON only" tail is belt-and-suspenders. The real enforcement is `output_config.format` (Section 2), but the instruction reinforces it and helps in case `output_config` is ever disabled for debugging.
- Length: ~700 input tokens, well under any limit. Stable across calls — a good prompt-cache target IF we ever exceed 4096 tokens of stable prefix (we don't, see Section 4).

**Planner recommendation:** Ship the system prompt above verbatim as `SYSTEM_PROMPT` (a single template-literal `const`) at the top of the existing `<script>` block in `index.html`, immediately after `BLOCK_H_FOOTER`. Flag it as a Phase 5 pilot tuning target (the open-question item in STATE.md "Does Gemini 2.5 Flash produce high-quality German bureaucratic vocabulary?" now reads as "does claude-haiku-4-5"; the pilot answers it).

Sources: [Anthropic prompt-engineering best practices](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering), [Anthropic structured outputs](https://platform.claude.com/docs/en/docs/build-with-claude/structured-outputs).

## 2. Anthropic Structured Output Reliability

### Option A (recommended): native `output_config.format`

Anthropic's official native JSON-schema feature uses grammar-constrained sampling, which means the decoder is physically restricted to tokens that keep the output valid against the schema. The doc states "Always valid JSON, type safe, no retries needed, grammar-constrained" — this is the strongest guarantee on the market right now. It is generally available on `claude-haiku-4-5` and requires no beta headers as of the docs we fetched 2026-05-14. [CITED: platform.claude.com/docs/en/docs/build-with-claude/structured-outputs]

Request body shape with `output_config.format` and our schema:

```json
{
  "model": "claude-haiku-4-5",
  "max_tokens": 2500,
  "temperature": 0.3,
  "system": "<the system prompt from Section 1>",
  "messages": [
    {
      "role": "user",
      "content": "<the user-message built from intake fields, see Section 5>"
    }
  ],
  "output_config": {
    "format": {
      "type": "json_schema",
      "schema": { "...see Section 3..." }
    }
  }
}
```

The response is plain JSON in `response.content[0].text` — parsed with `JSON.parse(...)` and we get a typed object matching the schema. No markdown fences to strip, no leading prose to chop.

### Option B (fallback): tool-use forced-call

The legacy pattern (still supported) is to define a single client tool whose `input_schema` is the desired JSON shape, then set `tool_choice: { "type": "tool", "name": "..." }` to force the model to call exactly that tool. The schema arrives as `response.content[0].input` (a `tool_use` block) instead of `content[0].text`. This was the standard approach for browser-only structured output before `output_config` shipped. [CITED: platform.claude.com/docs/en/docs/build-with-claude/tool-use/overview]

Example body:

```json
{
  "model": "claude-haiku-4-5",
  "max_tokens": 2500,
  "temperature": 0.3,
  "system": "<system prompt>",
  "messages": [{ "role": "user", "content": "<user message>" }],
  "tools": [
    {
      "name": "emit_cheat_sheet",
      "description": "Emit the Migrationsamt cheat sheet as structured data.",
      "input_schema": { "...same schema as Section 3..." }
    }
  ],
  "tool_choice": { "type": "tool", "name": "emit_cheat_sheet" }
}
```

Then `response.content[0].input` is the typed object.

Tool-use forced-call costs an extra ~313 tokens of system-prompt overhead (per Anthropic's tool-use pricing table) on every request. `output_config.format` has no equivalent overhead surcharge documented.

### Option C (anti-pattern): prompt-only "respond with JSON"

This is the approach used in the Phase 0 spike and is what the project was originally going to fall back to. It works MOST of the time but breaks in roughly the obvious ways: occasional markdown fences (` ```json `), occasional prose preambles ("Here is the cheat sheet:"), occasional truncation that produces invalid JSON. Defensive parsing (strip fences, trim whitespace, find first `{` and last `}`) can recover most of these, but it is fragile and a beginner-unfriendly debugging surface.

### Comparison

| Approach | Reliability | Token overhead | Beginner friendly | Notes |
|----------|------------|----------------|-------------------|-------|
| A: `output_config.format` | Guaranteed (grammar-constrained) | 0 documented | Yes | Recommended. No fences to strip. |
| B: tool-use forced-call | Very high (schema validated) | +313 tokens system prompt | Medium | Use if `output_config` ever misbehaves. |
| C: prompt-only JSON | ~95%, fragile failures | 0 | No | Last resort with a tolerant parser. |

**Planner recommendation:** Ship Option A. Wire the response handler to read `response.content[0].text` and `JSON.parse()` it. As defence in depth (in case `output_config` ever silently fails or the model id is changed in future), implement a tolerant parser that strips markdown fences and trims whitespace before `JSON.parse` — adds three lines, costs nothing. If `JSON.parse` throws, treat as the parse-error class in Section 7.

Sources: [Anthropic structured outputs](https://platform.claude.com/docs/en/docs/build-with-claude/structured-outputs), [Anthropic tool use](https://platform.claude.com/docs/en/docs/build-with-claude/tool-use/overview).

## 3. Locked JSON Schema

The schema below is the source of truth for both the Phase 2 send (as `output_config.format.schema`) and the Phase 3 render. The planner should copy this verbatim into `CHEAT_SHEET_SCHEMA` in `index.html`.

```javascript
const CHEAT_SHEET_SCHEMA = {
  type: 'object',
  properties: {
    blockB: {
      type: 'object',
      description: 'Opening script: user-goal sentence plus 3-5 opening lines.',
      properties: {
        userGoalSentence: {
          type: 'string',
          description: 'One sentence in formal Hochdeutsch stating what the user wants from the call, with the case reference number inserted if provided in the intake.',
        },
        userGoalGloss: {
          type: 'string',
          description: 'Plain-English gloss of userGoalSentence.',
        },
        openingScript: {
          type: 'array',
          minItems: 3,
          maxItems: 5,
          description: 'The opening lines the user reads at call start. Must include the Hochdeutsch-request sentence by default. Each item is one DE/EN pair.',
          items: {
            type: 'object',
            properties: {
              germanLine: { type: 'string' },
              englishGloss: { type: 'string' },
            },
            required: ['germanLine', 'englishGloss'],
            additionalProperties: false,
          },
        },
      },
      required: ['userGoalSentence', 'userGoalGloss', 'openingScript'],
      additionalProperties: false,
    },
    blockC: {
      type: 'array',
      minItems: 4,
      maxItems: 6,
      description: 'Likely officer questions with suggested affirmative and negative answers, in formal Hochdeutsch with English glosses.',
      items: {
        type: 'object',
        properties: {
          germanQuestion: { type: 'string' },
          englishGloss: { type: 'string' },
          affirmativeGerman: { type: 'string' },
          affirmativeEnglish: { type: 'string' },
          negativeGerman: { type: 'string' },
          negativeEnglish: { type: 'string' },
        },
        required: [
          'germanQuestion', 'englishGloss',
          'affirmativeGerman', 'affirmativeEnglish',
          'negativeGerman', 'negativeEnglish',
        ],
        additionalProperties: false,
      },
    },
    blockE: {
      type: 'array',
      minItems: 6,
      maxItems: 12,
      description: 'Vocabulary mini-glossary, 6-12 entries, each with article and English translation.',
      items: {
        type: 'object',
        properties: {
          article: {
            type: 'string',
            enum: ['der', 'die', 'das'],
          },
          germanWord: { type: 'string' },
          englishTranslation: { type: 'string' },
        },
        required: ['article', 'germanWord', 'englishTranslation'],
        additionalProperties: false,
      },
    },
    blockF: {
      type: 'array',
      minItems: 5,
      maxItems: 10,
      description: 'Prep checklist tailored to the intake. Each item is one actionable English line.',
      items: { type: 'string' },
    },
  },
  required: ['blockB', 'blockC', 'blockE', 'blockF'],
  additionalProperties: false,
};
```

### ROADMAP Cheat Sheet Anatomy coverage check

| ROADMAP requirement | Schema field | Covered? |
|---------------------|-------------|---------|
| Block B: opening script with Hochdeutsch-request line, custom user-goal + reference number sentence | `blockB.openingScript`, `blockB.userGoalSentence` | Yes — Hochdeutsch-request line is enforced by the system prompt as "must include" |
| Block C: ≥4 questions with affirmative + negative answer forms, two columns DE/native | `blockC[]` with min 4 entries, all six DE/EN fields per entry | Yes |
| Block E: 6–12 German words with article and translation | `blockE[]` min 6 max 12, article enum | Yes |
| Block F: prep checklist tailored to intake | `blockF[]` min 5 max 10 | Yes |

Gaps flagged:
- The Hochdeutsch-request line is required by the SYSTEM PROMPT to appear in `blockB.openingScript`, but the schema does not encode that requirement (impossible to express in JSON schema without an enum on string content, which would be brittle). Document it in the system prompt only. Phase 5 pilot debrief verifies it's actually present in real generations.
- Block A's user-goal sentence (inside Block A on the cheat sheet, per ROADMAP) is duplicated in `blockB.userGoalSentence`. That's fine: Block A is rendered from the constant + this string in Phase 3; Block B's opening script also references the same intent.

**Planner recommendation:** Copy the schema above verbatim into `CHEAT_SHEET_SCHEMA` immediately after the `SYSTEM_PROMPT` constant. Pass it as `output_config.format.schema` in every request. Phase 3 rendering reads the SAME object shape — any field renaming requires updating both phases simultaneously.

## 4. API Parameters and Cost

### max_tokens

Total expected output size: Block B (~150 tokens), Block C with 6 entries each ~80 tokens (~480 tokens), Block E with 12 entries each ~15 tokens (~180 tokens), Block F with 10 entries each ~20 tokens (~200 tokens), plus JSON syntactic overhead (~150 tokens). Total ~1,160 tokens for a maximum-size response. Doubling for safety on long German words and longer-than-average answers gives ~2,300 tokens.

**Recommended: `max_tokens: 2500`.**

Justification: gives ~100% headroom over the upper-bound estimate. At Haiku 4.5's $5/MTok output rate, the cap is worth $0.0125 if entirely consumed — trivial. The bigger risk is setting it too low and getting truncated JSON (which `output_config.format` would still accept up to the truncation point, producing a partial object that fails `required` validation, surfaced as a 4xx). 2500 is the safe choice.

### temperature

The output should be deterministic and bureaucratic, with no creative flourish. The same intake should produce a similar cheat sheet on re-runs (helpful for debugging).

**Recommended: `temperature: 0.3`.**

Justification: 0.0 is technically deterministic but Claude sometimes underperforms at 0.0 because the constrained sampler can dead-end on a single-token path that produces stilted German. 0.3 is the practical lower bound that maintains variability for natural German phrasing while staying near-deterministic. Anthropic's own prompt-engineering guide does not specify a single number; 0.3 is in line with their "structured output, low variability" examples.

### Prompt caching: skip for v1

Per the prompt-caching docs, the minimum cacheable prompt length on `claude-haiku-4-5` is **4,096 tokens**. [CITED: platform.claude.com/docs/en/build-with-claude/prompt-caching]

Our stable prefix (system prompt ~700 tokens + JSON schema ~500 tokens + the constant headers ~100 tokens) totals ~1,300 tokens. Far below 4,096. Caching is silently skipped on under-minimum prompts (no error). Adding `cache_control` would no-op.

**Recommended for v1: do NOT add `cache_control`.** Re-evaluate in Phase 5 if the pilot grows the system prompt past 4096 tokens (unlikely — the pilot debrief is more likely to make the prompt sharper, not longer).

Documentation comment in code:

```javascript
// Prompt caching intentionally not enabled in v1: claude-haiku-4-5 requires
// 4096+ tokens of stable prefix; our system prompt + schema together are
// ~1300 tokens. Caching would silently no-op. Re-evaluate post-pilot.
```

### Cost per generation

Pricing for `claude-haiku-4-5` (verified 2026-05-14 against platform.claude.com/docs/en/about-claude/pricing):
- Base input: **$1 / MTok**
- Output: **$5 / MTok**

Estimated per-call cost:
- Input: ~1,300 tokens (system + schema + headers) + ~200 tokens (intake user message) = ~1,500 input tokens → 1500 × $1 / 1M = **$0.0015**
- Output: ~1,200 tokens average (smaller end of the response range) → 1200 × $5 / 1M = **$0.0060**
- **Total per call: ~$0.0075 (three quarters of a cent).**

Worst case at full `max_tokens: 2500` output: ~1500 input + 2500 output = $0.0015 + $0.0125 = **~$0.014 (less than 1.5 cents)**.

Development budget for Phase 2 iteration: 100 dev calls × $0.014 worst case = **$1.40 total**. Negligible.

**Planner recommendation:** Set `max_tokens: 2500`, `temperature: 0.3`, NO prompt caching. Document the cost-per-call (~$0.01) in `README.md` so Francisco has a reference. Use `?mock=1` (Section 10) for UI iteration to avoid even the $1.40.

Sources: [Anthropic pricing](https://platform.claude.com/docs/en/about-claude/pricing), [prompt caching](https://platform.claude.com/docs/en/build-with-claude/prompt-caching).

## 5. Intake Form UI Shape and Copy (English Only)

### Layout (wireframe)

Single column, vertical stack inside the existing `<main>` of `index.html`. Phase 1's `#ready` section becomes the launchpad into the intake (a "Start cheat sheet" button), and a new `#intake` section holds the form. Reading order, top to bottom:

```
[H2: Tell us about your call]
[Helper paragraph]

[Label: What permit do you hold?] [select dropdown — INTAKE-02]
[Label: What is the call about?] [select dropdown — INTAKE-03]

[Section heading: Reference details (optional)] [helper: "Skip any you don't have."]
[Label: Case reference number] [text input — INTAKE-04]
[Label: AHV number] [text input — INTAKE-04]
[Label: Appointment date, if any] [date input — INTAKE-04]

[Label: Briefly describe your situation in English] [textarea — INTAKE-05]
[Helper under textarea]

[Consent block — TRUST-02, only shown if not previously consented]
[Checkbox] [consent copy]

[Primary button: Generate cheat sheet]
[Secondary link: Back to key]
```

### Field-by-field

**INTAKE-02 — Permit type (select, required)**

Label: `What permit do you hold?`
Options (value = display, in this order):
- `(not selected)` → placeholder
- `L` → `L permit (short-term residence)`
- `B` → `B permit (residence)`
- `C` → `C permit (settlement)`
- `Ci` → `Ci permit (residence with gainful employment for spouses of diplomats)`
- `G` → `G permit (cross-border commuter)`
- `N` → `N permit (asylum seeker)`
- `F` → `F permit (temporary admission)`
- `S` → `S permit (protection status)`
- `unknown` → `I don't know`

Default: not selected. Required: yes. Validation: must pick a non-empty option.

**INTAKE-03 — Reason for calling (select, required)**

Label: `What is the call about?`
Options (value = display):
- `(not selected)` → placeholder
- `renewal` → `Permit renewal`
- `change_status` → `Change of status`
- `family_reunification` → `Family reunification`
- `work_permit_change` → `Work-permit change`
- `address_change` → `Address change`
- `missing_document` → `Missing document`
- `lost_permit` → `Lost permit`
- `status_check` → `Status check on a pending application`
- `appointment_booking` → `Booking an appointment`
- `other` → `Other`

Default: not selected. Required: yes.

**INTAKE-04 — Reference details (three optional fields)**

Section heading: `Reference details (optional)`
Helper: `Skip any you do not have. The cheat sheet still works without them.`

- Label: `Case reference number` — placeholder `e.g. ZH-12345` — text input, no validation
- Label: `AHV number` — placeholder `756.xxxx.xxxx.xx` — text input, no validation (do NOT validate the format; AHV format checks belong nowhere near the LLM)
- Label: `Appointment date, if any` — `<input type="date">` — no validation

**INTAKE-05 — Free-text situation (textarea, required)**

Label: `Briefly describe your situation in English`
Helper: `A few sentences is enough. The tool uses this to tailor the questions and checklist. Do not paste anything you would not want sent to Anthropic.`
Textarea attributes: 4 rows visible, no max length (Anthropic context window is large).
Required: yes — refuse to submit if empty (the system prompt has an edge-case branch for empty, but the UX should still nudge the user to fill it).

### Consent block (TRUST-02)

Visible only if `localStorage.getItem('migrationsamt.consentGiven')` is not `'true'`. Once checked and the user submits, persist `'true'`. Subsequent generations skip the checkbox.

Heading: `Before we send this to Anthropic`
Copy (verbatim):
> When you click "Generate cheat sheet", the following information is sent in one single API call to Anthropic's Claude service using your saved API key:
> - your permit type and the reason for your call
> - any reference numbers, AHV number, and appointment date you typed in
> - the free-text description of your situation you just wrote
>
> Nothing else leaves your browser. There is no backend, no logs, no analytics. Anthropic's own data-handling policies apply to the request itself.

Checkbox label: `I understand what is being sent and I want to continue.`

Submit button is disabled until the checkbox is checked.

### Generate button

Label: `Generate cheat sheet`
Disabled state: when required fields are empty, or when the (first-time) consent checkbox is unchecked.

### Loading state copy (cycled during the 10–20s wait)

Show one message at a time, cycling every ~4 seconds. Below a simple animated indicator (a `<progress>` element or three dots). No spinner library, no CSS animation library. Plain CSS keyframes are allowed by the existing `style-src 'unsafe-inline'`.

Cycle, in order, then loop:
1. `Building your cheat sheet now. This usually takes 10 to 20 seconds.`
2. `Translating your situation into formal German.`
3. `Picking the questions the officer is most likely to ask.`
4. `Compiling vocabulary and your prep checklist.`
5. `Almost there. Final pass on the German.`

If we go past message 5 (>20s), stop cycling on message 5 and keep it on screen.

### Result-screen heading

H2: `Your cheat sheet (Phase 2 raw preview)`
Helper paragraph: `This is the raw structured output. In a later step we will format it as a printable cheat sheet. For now, look through it to check the German makes sense and the schema is right.`

### Error panel heading per class (copy in Section 7)

### Page title and H1 (unchanged from Phase 1)

`Migrationsamt Zürich Call Helper` stays as `<title>` and `<h1>`.

**Planner recommendation:** Use the field shape and copy above verbatim. All copy strings live as inline HTML text (no i18n abstraction — Phase 4 introduces that). Required-field validation is plain JS (`if (!value.trim()) return`); no HTML5 form validation (we never `<form action>` per CSP `form-action 'none'`). Loading-state cycling uses `setInterval` cleared on success/error/unmount.

## 6. Result Screen for Phase 2

### Recommendation: labelled DOM block list + raw JSON `<pre>` below

A `<pre>` alone is hard for Francisco to scan ("is Block C really got six entries?"). A labelled DOM rendering of each block lets him eyeball the German immediately. Both together gives the full picture, and the labelled rendering is throwaway code (Phase 3 replaces it with the real cheat-sheet view), so cheap to write.

Layout, top to bottom:

```
[H2: Your cheat sheet (Phase 2 raw preview)]
[Helper paragraph]

[H3: Block B - Opening script]
  [Goal sentence (DE)]: <userGoalSentence>
  [Goal sentence (EN)]: <userGoalGloss>
  [Opening lines:]
    1. DE: <line> / EN: <gloss>
    2. ...

[H3: Block C - Likely officer questions]
  1. Q: <germanQuestion> / <englishGloss>
     Yes: <affirmativeGerman> / <affirmativeEnglish>
     No:  <negativeGerman> / <negativeEnglish>
  2. ...

[H3: Block E - Vocabulary]
  [List of: <article> <germanWord> — <englishTranslation>]

[H3: Block F - Prep checklist]
  [Bullet list of strings]

[Collapsible: Raw JSON for debugging]
  [<pre> with JSON.stringify(response, null, 2)]

[Button: New cheat sheet]
[Button: Back to intake]
```

### Buttons

- **New cheat sheet:** clears `appState.cheatSheet` and `appState.lastIntake`, swaps to `'intake'` with empty form.
- **Back to intake:** keeps `appState.lastIntake`, swaps to `'intake'`, the form is re-populated from `lastIntake` so Francisco can tweak one field and re-run.

### Rendering safety

Every DOM write is `textContent` only. The raw JSON `<pre>` is also `textContent` (with `JSON.stringify(..., null, 2)` as the input). No `innerHTML` anywhere, in line with Phase 1's discipline. This matters because the LLM output is, by the project's own threat model, untrusted text — even though `output_config.format` constrains the structure, individual string contents are arbitrary.

**Planner recommendation:** Render block-by-block with labelled headers, then a `<details><summary>Raw JSON</summary><pre>...</pre></details>` at the bottom. All writes via `textContent`. This section is explicitly throwaway — Phase 3 deletes most of it and replaces with the two-column cheat sheet. Keep code comments noting "Phase 3 replaces this".

## 7. Error UI Shape (LLM-04)

### Recommendation: one shared error panel, switched copy by class

One `<section id="errorPanel">` pre-rendered hidden in HTML. `render()` for `appState.screen === 'error'` reads `appState.errorClass` (one of `'auth' | 'rate-limit' | 'server' | 'parse' | 'network'`) and writes the heading, body, and visible action buttons accordingly via `textContent`.

### Error classes

The mapping from response state to class:
- HTTP 401 → `'auth'` (bad or missing key)
- HTTP 429 → `'rate-limit'` (Anthropic rate-limited the user's account)
- HTTP 5xx → `'server'`
- `fetch()` throws (network drop, CORS unexpected failure) → `'network'`
- HTTP 200 but `JSON.parse` throws or the schema's `required` fields are missing → `'parse'`
- HTTP 4xx other than 401/429 (e.g. 400 for invalid request, 403) → `'server'` (treat as server-side issue from the user's POV; the body is shown verbatim in the diagnostic detail)

### Copy per class (verbatim)

**Auth (401)**

- Heading: `Your API key did not work`
- Body: `Anthropic rejected your saved API key. It might be wrong, expired, or revoked. You can paste a new key and try again, or go back to the intake.`
- Buttons: `Update key` (→ `key-entry` screen, keeps `appState.lastIntake` in memory), `Try again` (→ resends the same intake, same key), `Back to intake` (→ `intake`, form re-populated)

**Rate limit (429)**

- Heading: `Anthropic is rate-limiting your account right now`
- Body: `Your Anthropic account has hit a temporary rate limit. Wait a minute or two and try again, or change your intake and come back.`
- Buttons: `Try again`, `Back to intake`

**Server (5xx, plus 4xx other than 401/429)**

- Heading: `Anthropic is having a problem`
- Body: `Anthropic returned an error from their side. This usually clears up by itself within a few minutes. Try again, or come back later.`
- Buttons: `Try again`, `Back to intake`

**Parse error (200 but bad JSON or schema mismatch)**

- Heading: `Something went wrong reading the response`
- Body: `Anthropic answered, but the response did not match the expected shape. This is rare. Trying again usually fixes it. If it keeps happening, this is a bug worth reporting.`
- Buttons: `Try again`, `Back to intake`

**Network error (fetch threw)**

- Heading: `Could not reach Anthropic`
- Body: `Your browser could not connect to Anthropic. Check your internet connection and try again.`
- Buttons: `Try again`, `Back to intake`

### Diagnostic detail (collapsible)

Below the body, a `<details><summary>Show technical details</summary>` containing:
- HTTP status code (if applicable)
- Response body text (if any, truncated to 2000 chars)
- The error message from `JSON.parse` or `fetch` (if any)

This is intended for Francisco during development. It's collapsed by default so real users do not see scary stack-trace-like text up front. All writes via `textContent`.

### Intake preservation

On any error, `appState.lastIntake` MUST already contain the intake the user just submitted. The `Try again` button re-sends the exact same payload. The `Back to intake` button repopulates the form fields from `lastIntake`. The `Update key` button (auth class only) routes through `'key-entry'` but on save returns to `'intake'` with `lastIntake` still in memory. This is the load-bearing fix for the "user types a paragraph, gets a 401, loses everything" failure mode.

**Planner recommendation:** Single `#errorPanel` section pre-rendered hidden. `appState.errorClass` switch in `render()`. Copy verbatim from above. `appState.lastIntake` survives every error path. `Update key` is the only button that appears only on the `'auth'` class.

## 8. State Machine

### Final `appState` shape

```javascript
const appState = {
  // Screen the user currently sees.
  screen: 'key-entry',  // 'key-entry' | 'intake' | 'generating' | 'result' | 'error'

  // Anthropic API key (carried from Phase 1).
  apiKey: null,

  // Most recently submitted intake. Survives generating -> result -> intake
  // and survives generating -> error -> intake. Lets the user fix one field
  // without re-typing the whole form.
  lastIntake: null,  // { permit, reason, caseRef, ahv, appointmentDate, situation }

  // Cheat sheet JSON returned by Anthropic, parsed and schema-validated.
  cheatSheet: null,  // matches CHEAT_SHEET_SCHEMA, or null if not generated yet

  // Error metadata for the 'error' screen.
  errorClass: null,  // 'auth' | 'rate-limit' | 'server' | 'parse' | 'network'
  errorDetail: null, // { httpStatus?, bodyText?, message? } — for the collapsible technical details

  // First-time consent flag, mirrored from localStorage on load.
  consentGiven: false,
};
```

### Transitions

| From | Event | To | Side effects |
|------|-------|----|--------------|
| `key-entry` | Save key succeeds | `intake` | Save to localStorage; `setState({ apiKey, screen: 'intake' })` |
| `ready` (Phase 1 holdover) | DOMContentLoaded with stored key | `intake` | Skip `'ready'` for Phase 2; Phase 1's `'ready'` screen is no longer reachable as a normal flow. See note below. |
| `intake` | Click Generate (form valid, consent checked) | `generating` | Snapshot intake into `appState.lastIntake`, persist consent to localStorage, fire LLM call |
| `intake` | Click "Back to key" (small secondary link) | `key-entry` | No state mutation beyond `screen` |
| `generating` | Fetch returns 2xx + JSON parse succeeds + schema-valid | `result` | `setState({ cheatSheet, screen: 'result' })` |
| `generating` | Fetch returns 401 | `error` (auth) | `setState({ errorClass: 'auth', errorDetail, screen: 'error' })` |
| `generating` | Fetch returns 429 | `error` (rate-limit) | similar |
| `generating` | Fetch returns 4xx/5xx other | `error` (server) | similar |
| `generating` | Fetch throws | `error` (network) | similar |
| `generating` | 200 but JSON.parse/schema fails | `error` (parse) | similar |
| `result` | Click "New cheat sheet" | `intake` | `setState({ cheatSheet: null, lastIntake: null, screen: 'intake' })` |
| `result` | Click "Back to intake" | `intake` | `setState({ screen: 'intake' })` — `lastIntake` preserved |
| `error` | Click "Try again" | `generating` | Re-fire the LLM call with `lastIntake` |
| `error` | Click "Back to intake" | `intake` | `setState({ screen: 'intake' })` — `lastIntake` and form preserved |
| `error` (auth only) | Click "Update key" | `key-entry` | `lastIntake` preserved in memory |
| `key-entry` | Save new key succeeds (post-401 flow) | `intake` | `lastIntake` survives, form repopulates |

### Note on Phase 1's `'ready'` screen

Phase 1 ships `'ready'` as the post-key-save landing screen (showing the masked key with Replace/Clear buttons). For Phase 2, the cleanest move is to **fold the Replace/Clear buttons into the intake screen header** (a small section at the top of `'intake'` reading `Key: sk-ant-...abcd  [Replace key] [Clear key]`) and skip the `'ready'` state entirely in the normal flow.

This keeps the user moving forward: paste key → land directly on intake form. It also means `'ready'` is dropped as a reachable state in the union type. The Replace/Clear functionality stays, just inline in the intake header.

Alternative: keep `'ready'` and add a "Start cheat sheet" button on it. Less seamless. **Recommended: fold into intake.**

### `consentGiven` persistence

Mirror the localStorage value into `appState.consentGiven` on `DOMContentLoaded`. When the user checks the consent checkbox and submits, set `localStorage.setItem('migrationsamt.consentGiven', 'true')` and `appState.consentGiven = true`. The consent block is only rendered if `!appState.consentGiven`. Clearing the API key does NOT clear consent — they are independent. Add a small "Clear all stored data" link on the intake screen for completeness; that one removes both `migrationsamt.anthropicKey` and `migrationsamt.consentGiven`.

**Planner recommendation:** Adopt the final `appState` shape and transitions above. Fold Replace/Clear into the intake header, drop `'ready'` from the screen union. Persist consent under `migrationsamt.consentGiven`. `lastIntake` lives in memory only (cheat sheet is per-session per STATE.md Locked Decisions; intake answers are stated as persisted in STATE.md but for v1 the simplest reading is "across-screen within a session", which is what this design provides).

## 9. System Prompt + Schema Location in Code

### Recommendation: top of inline `<script>`, after `BLOCK_H_FOOTER`

The Phase 1 structure already has a clear "constants" zone at the top of the `<script>` block:

```
Line ~150: SYSTEM_PROMPT (NEW, Phase 2)            <-- add here
Line ~155: CHEAT_SHEET_SCHEMA (NEW, Phase 2)       <-- add here
Line ~160: ANTHROPIC_API (NEW, Phase 2 config)     <-- add here
Line ~273: MIGRATIONSAMT (Phase 1)
Line ~225: BLOCK_D (Phase 1)
Line ~242: HOCHDEUTSCH_REQUEST (Phase 1)
Line ~253: BLOCK_H_FOOTER (Phase 1)
Line ~276: appState (Phase 1)
Line ~284: STORAGE_KEY + helpers (Phase 1)
Line ~317: maskKey (Phase 1)
Line ~322: setState + render (Phase 1)
Line ~394: DOMContentLoaded handler (Phase 1)
```

Phase 2 adds three new constants. Recommended order, all immediately after `BLOCK_H_FOOTER` and before `appState`:

```javascript
/* ----------------------------------------------------------------------
   ANTHROPIC API CONFIG
   The endpoint, current model id, and request defaults. Tied to Phase 0
   CORS spike outcome and Phase 1 CSP connect-src lock.
   ---------------------------------------------------------------------- */
const ANTHROPIC_API = {
  endpoint: 'https://api.anthropic.com/v1/messages',
  model: 'claude-haiku-4-5',
  apiVersion: '2023-06-01',
  maxTokens: 2500,
  temperature: 0.3,
  // Prompt caching intentionally not enabled in v1: Haiku 4.5 requires
  // 4096+ tokens of stable prefix; our system prompt + schema together
  // are ~1300 tokens. Caching would silently no-op.
};

/* ----------------------------------------------------------------------
   SYSTEM PROMPT (LLM-01)
   Locks the model's role, lists forbidden behaviours with concrete refusal
   patterns, scopes generation to Blocks B/C/E/F only, and anchors the
   language to formal Hochdeutsch. Phase 5 pilot debrief is the expected
   tuning trigger.
   ---------------------------------------------------------------------- */
const SYSTEM_PROMPT = `You are a preparation aid... [Section 1 verbatim]`;

/* ----------------------------------------------------------------------
   CHEAT SHEET SCHEMA (LLM-02)
   The strict JSON shape the LLM must return. Enforced server-side via
   output_config.format on every request. Phase 3 rendering reads the
   same shape — any field rename here requires a matching Phase 3 edit.
   ---------------------------------------------------------------------- */
const CHEAT_SHEET_SCHEMA = { /* Section 3 verbatim */ };
```

Naming conventions:
- `SCREAMING_SNAKE_CASE` for module-level immutable data, matching the Phase 1 pattern (`MIGRATIONSAMT`, `BLOCK_D`, etc.).
- `camelCase` for functions and `appState` properties, matching `maskKey`, `setState`, etc.
- Section comments use a 70-dash banner matching Phase 1's style.

A separate function block lower in the script (alongside `setState`/`render`) holds:
- `buildRequestBody(intake)` — composes the messages array from `appState.lastIntake`
- `callAnthropic(intake, apiKey)` — runs the `fetch`, returns `{ ok, data, errorClass, errorDetail }`
- `parseAndValidateResponse(rawData)` — extracts `content[0].text`, `JSON.parse`s, validates against the schema's `required` fields, returns `{ ok, cheatSheet, errorDetail }`

**Planner recommendation:** Add the three new constants block-by-block in the order above, with banner comments matching Phase 1's style. Keep all I/O functions (`buildRequestBody`, `callAnthropic`, `parseAndValidateResponse`) grouped together below the constants and above the event handlers. Phase 2 should not exceed ~1500 lines of `index.html` total; if it does, the extraction-to-`prompts.js`/`schema.js` decision (still `script-src 'self'`-allowed) is a Phase 3+ refactor.

## 10. Risks

### Risk 1: Token-budget overrun (response truncation)

**What goes wrong:** `max_tokens` set too low, JSON is cut off mid-string, `JSON.parse` throws.
**Mitigation:** `max_tokens: 2500` per Section 4 — ~100% headroom over the upper-bound output estimate. If a truncation happens anyway (e.g. Block C with very long German answers), the parse-error class catches it, and Try again with a slightly different intake usually fixes it. Add a comment near `max_tokens` explaining the headroom.

### Risk 2: Markdown-fenced JSON despite instructions

**What goes wrong:** Even with `output_config.format`, in rare cases Claude wraps the response in ` ```json `. (Less likely with `output_config.format` than with prompt-only; documented behaviour with prompt-only.)
**Mitigation:** Tolerant parser. Before `JSON.parse`, run:

```javascript
function stripFences(text) {
  let t = text.trim();
  if (t.startsWith('```json')) t = t.slice(7);
  else if (t.startsWith('```')) t = t.slice(3);
  if (t.endsWith('```')) t = t.slice(0, -3);
  return t.trim();
}
```

Three lines, costs nothing, eliminates the most common failure mode.

### Risk 3: 401 wiping the user's intake

**What goes wrong:** User types a paragraph, gets 401, clicks "Update key", form is empty.
**Mitigation:** `appState.lastIntake` is set BEFORE the fetch, survives the error path, and the intake form re-populates from it on return. The state-machine spec in Section 8 makes this explicit.

### Risk 4: Off-topic free-text situations

**What goes wrong:** User types "I want to cancel my Spotify subscription". The model either refuses, generates boilerplate, or hallucinates.
**Mitigation:** The system prompt's `<edge_cases>` section instructs the model to produce a clarifying Block B + a checklist that suggests verifying the office. This is a Phase 5 monitoring item: log nothing automatically, but Francisco should run a manual off-topic test before pilot and document the actual model behaviour. Track as a Phase 5 follow-up.

### Risk 5: Cost during dev iteration

**What goes wrong:** Francisco re-runs the LLM call dozens of times while iterating on the UI. Each call is ~$0.01 — not financially scary, but the 10–20s latency is annoying.
**Mitigation:** **`?mock=1` URL flag.** When the page loads with `?mock=1` in the query string, `callAnthropic` returns a hardcoded fixture immediately (a JSON object that validates against the schema — write it once, hardcode it in `index.html` as `const MOCK_CHEAT_SHEET = {...}`). UI iteration runs instantly with zero API calls.

Implementation sketch:

```javascript
const USE_MOCK = new URLSearchParams(window.location.search).get('mock') === '1';

async function callAnthropic(intake, apiKey) {
  if (USE_MOCK) {
    await new Promise(r => setTimeout(r, 800));  // simulate latency
    return { ok: true, data: MOCK_CHEAT_SHEET };
  }
  // ... real fetch
}
```

Document the flag in `README.md`: `https://pacomc999.github.io/inmigration-tool/?mock=1`. Recommend Francisco use it for any UI-only change.

### Risk 6: Anthropic model retirement (lessons from Phase 0)

**What goes wrong:** `claude-haiku-4-5` gets deprecated mid-project (like `claude-3-5-haiku-latest` was during Phase 0).
**Mitigation:** Model id is one constant (`ANTHROPIC_API.model`), one line to change. Document in `README.md`: "If you get a 404 from Anthropic, the model may have been retired. Check platform.claude.com/docs/en/about-claude/model-deprecations and update `ANTHROPIC_API.model`."

### Risk 7: Free-text textarea accepts dangerous content

**What goes wrong:** User pastes 200KB of irrelevant text into the situation field, ballooning token cost.
**Mitigation:** v1 ships with no client-side length cap. Per Section 4, even a 4KB situation field is ~1000 input tokens = $0.001. The cost ceiling is low enough that policing it is over-engineering. Phase 5 monitoring item if real users do this.

### Risk 8: `output_config.format` feature changes underfoot

**What goes wrong:** Anthropic renames `output_config.format` to something else, or moves it back behind a beta header.
**Mitigation:** Documented as a known fragility. Tolerant parser (Risk 2) plus the fallback to tool-use forced-call (Section 2 Option B) means a quick pivot is possible. Add a code comment near the request body: "If output_config.format ever stops working, switch to tool-use forced-call — see RESEARCH.md Section 2."

**Planner recommendation:** Build all eight mitigations into Phase 2 from day one. They are cheap (most are one-to-three-line additions or comments) and they head off the most likely Phase 5 surprises. The `?mock=1` flag in particular pays for itself the first time Francisco iterates on the Block C rendering.

## 11. Out of Scope Reminders (NOT to build in Phase 2)

Repeated from 02-CONTEXT.md and Phase 1 boundaries, with citations:

- **No cheat-sheet rendering** (two-column DE/EN print layout, Block A render with phone/address/hours, panic phrases Block D render, note-taking Block G, Block H footer with escalation links). All Phase 3 (ROADMAP Phase 3 success criterion 1). The Phase 2 result screen is explicitly "raw structured output" (ROADMAP Phase 2 success criterion 4).
- **No multilingual UI** and no Spanish/Portuguese gloss columns. Phase 4 (LANG-01, LANG-02). Phase 2 intake form labels, error copy, and helper text are English-only.
- **No `<input type="radio">` UI language switcher** (INTAKE-01). It is meaningless without ES/PT content; ROADMAP "Notes on Phase Boundaries" explicitly states INTAKE-01 lives in Phase 4.
- **No print stylesheet** (`@media print`), no A4 layout, no `page-break-inside`. Phase 3 (PRINT-01, PRINT-02, PRINT-03).
- **No non-dismissable disclaimer at the top of every screen** beyond Phase 1's footer disclaimer (TRUST-01 is Phase 3). The footer line from Phase 1 stays, untouched.
- **No onboarding screen** explaining the BYOK model with a key-acquisition link (TRUST-05, Phase 3 — and the existing wording references Gemini; L-07 flags it for Phase 3 update to Anthropic).
- **No privacy page** (TRUST-03, Phase 3).
- **No pronunciation audio** for German phrases (v1.x deferred).
- **No QR handoff** desktop→phone (v1.x deferred).
- **No saved-sheets list** or any persistence of generated cheat sheets across sessions (STATE.md Locked Decisions; PROJECT.md Out of Scope).
- **No analytics, no telemetry, no error reporting endpoint** (PROJECT.md privacy posture, Phase 1 CSP `connect-src` lock).
- **No live AI interpreter** during the call (PROJECT.md Out of Scope, deferred to v2).
- **No microphone access of any kind** (TRUST-04 lifetime guardrail). `verify-no-mic.ps1` must continue to exit 0.
- **No third-party CDN scripts** (L-05). No marked.js, no DOMPurify, no anything — the result screen renders via `textContent` only, no markdown to parse.
- **No streaming** of the LLM response. Single fetch + single response. Streaming is a v2 consideration if pilot users complain about wait time (STATE.md Open Questions, ROADMAP v2 deferred).
- **No retry logic** beyond the user-clicked "Try again" button. No exponential backoff, no automatic 429 wait. Beginner-friendly: the user clicks the button if they want another attempt.
- **No `<form action>` submission** of the intake. The CSP `form-action 'none'` blocks it. Use a `<button type="button">` with a JS click handler.

**Planner recommendation:** Add an explicit "Out of scope for Phase 2" section to PLAN.md frontmatter referencing this section, so any drift during plan-checking is immediately visible. Build only what's in Section 1–10 above; if any task touches an item on this Section 11 list, it does not belong in Phase 2.

## Runtime State Inventory

Phase 2 is greenfield code addition, not rename/refactor — this section is omitted with one note: Phase 2 introduces a new localStorage key `migrationsamt.consentGiven` (boolean string `'true'`). It coexists with the existing `migrationsamt.anthropicKey` (Phase 1). Both are cleared independently. No existing identifiers are renamed.

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|----------|
| Modern browser (Chrome 90+) | Running the app | yes | Chrome current | — |
| Anthropic API key (sk-ant-...) | LLM-01 → LLM-04 | yes (Francisco has personal) | — | `?mock=1` flag for UI iteration |
| Anthropic Messages API endpoint | LLM-01 → LLM-04 | yes (Phase 0 confirmed) | API version `2023-06-01` | none — failure routes to error screen |
| `output_config.format` feature | LLM-02 reliability | yes (verified 2026-05-14, GA on Haiku 4.5) | n/a — no beta header | Tool-use forced-call (Section 2 Option B) |
| `claude-haiku-4-5` model | LLM call | yes (Phase 0 used it) | current | If retired: swap model id in `ANTHROPIC_API.model` |
| Prompt caching | Cost optimisation | n/a in v1 | requires 4096+ token prefix; we have ~1300 | Skip caching, document |
| PowerShell | `verify-no-mic.ps1` | yes (Phase 1) | Win 11 default | — |
| Git, GitHub Pages | Deploy | yes (Phase 0 set up) | — | — |

No new external runtimes, package managers, or services. Pure HTML/CSS/JS plus one HTTPS endpoint (already in CSP `connect-src`).

## Validation Architecture

### Test Framework

| Property | Value |
|----------|-------|
| Framework | None (vanilla single-file app, no test runner per CLAUDE.md "no build system") |
| Config file | n/a |
| Quick run command | Manual: open `index.html` in Chrome, walk through happy path |
| Full suite command | Manual smoke test from `README.md` + automated Node verify scripts per task (Phase 1 precedent) |

Per Phase 1's pattern (01-01-SUMMARY.md and 01-02-SUMMARY.md), each task ships a Node `-e` one-liner that does textual / structural checks against the modified files (e.g. "CSP contains connect-src https://api.anthropic.com", "SYSTEM_PROMPT defined as a const", "schema has required: ['blockB', 'blockC', 'blockE', 'blockF']"). The planner specifies the exact check list per task.

### Phase Requirements → Test Map

| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|--------------|
| INTAKE-02 | Permit dropdown has 9 options matching INTAKE-02 list, no free text | structural | `node -e` grep for the nine `<option value="...">` literals | ❌ Wave 0 (no test infra) |
| INTAKE-03 | Reason dropdown has 10 options | structural | `node -e` grep for option values | ❌ Wave 0 |
| INTAKE-04 | Three optional ref fields present | structural | `node -e` grep for input ids `caseRef`, `ahv`, `appointmentDate` | ❌ Wave 0 |
| INTAKE-05 | Textarea with id `situationText` exists | structural | `node -e` grep | ❌ Wave 0 |
| LLM-01 | SYSTEM_PROMPT defined, contains forbidden-behaviour anchors | structural | `node -e` grep for `<forbidden_behaviour>`, `permit-eligibility`, `contact details` | ❌ Wave 0 |
| LLM-02 | CHEAT_SHEET_SCHEMA defined, required array correct | structural | `node -e` parse the JS, assert keys | ❌ Wave 0 |
| LLM-03 | Loading messages array has 5 entries, generating screen exists | structural | `node -e` grep | ❌ Wave 0 |
| LLM-04 | Error panel renders five classes with copy from Section 7 | structural | `node -e` grep for class names + heading strings | ❌ Wave 0 |
| TRUST-02 | Consent checkbox exists, persists to `migrationsamt.consentGiven` | structural | `node -e` grep | ❌ Wave 0 |
| Happy path | Mock fixture flow `?mock=1` returns Section-3-shaped JSON, all four blocks render | manual | Francisco opens `index.html?mock=1` in Chrome | ❌ Wave 0 |
| Real LLM call | Live Anthropic call with valid key produces a valid cheat sheet | manual | Francisco runs once before merge with personal key | ❌ Wave 0 |
| Error path: 401 | Wrong key produces auth error screen with "Update key" button | manual | Francisco saves `sk-ant-bogus` and clicks Generate | ❌ Wave 0 |
| Error path: parse | Mock fixture with malformed JSON triggers parse error screen | manual / structural | `?mock=broken` returns invalid JSON | ❌ Wave 0 |
| TRUST-04 carry-forward | `verify-no-mic.ps1` still exits 0 | automated | `powershell -File ./verify-no-mic.ps1` | ✅ Phase 1 |

### Sampling Rate

- **Per task commit:** the task's own Node `-e` structural check (planner specifies).
- **Per wave merge:** Francisco runs `verify-no-mic.ps1` plus the happy-path smoke test with `?mock=1`.
- **Phase gate:** one real LLM call with Francisco's personal key, plus one 401 error-class test with a bogus key.

### Wave 0 Gaps

- [ ] **Mock fixture object** `MOCK_CHEAT_SHEET` — needed for `?mock=1` flag. One hardcoded JS object matching Section 3 schema. Author once, never changes.
- [ ] **Mock-broken fixture** `MOCK_CHEAT_SHEET_BROKEN` (optional, for parse-error path test). Same shape with a deliberate missing required field.
- [ ] **Smoke-test recipe in `README.md`** — the manual checklist Francisco runs before merging each plan.

No test framework install required; the Phase 1 precedent (inline `node -e` checks per task) carries forward unchanged.

## Security Domain

### Applicable ASVS Categories

| ASVS Category | Applies | Standard Control |
|---------------|---------|-----------------|
| V2 Authentication | yes (key handling, carried from Phase 1) | localStorage `type=password` input + masked display (Phase 1) |
| V3 Session Management | no | No sessions; per-page-load in-memory state |
| V4 Access Control | no | Single-user browser-local app |
| V5 Input Validation | yes (intake form, free-text textarea) | Required-field validation in JS; textContent-only rendering of user-typed values (no innerHTML) |
| V6 Cryptography | no | No tokens to sign, no encryption to hand-roll; key stored plaintext in localStorage per Phase 1 decision (intentional, BYOK posture) |

### Known Threat Patterns for this stack

| Pattern | STRIDE | Standard Mitigation |
|---------|--------|---------------------|
| XSS via LLM response (untrusted text from Anthropic) | Tampering | `textContent` only, no `innerHTML` anywhere in result rendering. CSP `script-src 'self' 'unsafe-inline'` does NOT relax this — `unsafe-inline` only affects `<script>` tags written by the developer, not DOM writes |
| XSS via user-typed intake echoed into UI | Tampering | Same: `textContent` only for any intake-derived display |
| Phishing / look-alike origin asks for the key | Spoofing | CSP `default-src 'self'` blocks third-party JS from loading; documented in README known-traps |
| API key exfiltration via 3rd-party request | Information disclosure | CSP `connect-src https://api.anthropic.com` is the only allowed outbound destination (Phase 1 lock) |
| Key logged to console / browser network panel | Information disclosure | `console.*` never receives `apiKey`; password input cleared after Save (Phase 1 already enforces) |
| Replay or abuse of stored key from another tab | Information disclosure | localStorage scoped to origin; no shared-token model |
| CSRF | Tampering | No `<form action>`, `form-action 'none'` in CSP; only `fetch()` calls authenticated by user-supplied key |
| Microphone / audio capture | Information disclosure | TRUST-04 lifetime guardrail, grep enforced (Phase 1) |
| Prompt injection from user's free-text situation | Tampering | The user is the only source of the user message in Phase 2 (single-turn). Prompt injection by the user-against-themselves is not a meaningful threat for a preparation aid. System prompt's role boundaries protect against the user attempting to extract legal advice via injection. |

**Planner recommendation:** The Phase 1 security posture (CSP lock, textContent-only, no innerHTML, no console logging of key, password input cleared after save) extends to Phase 2 unchanged. The only new threat surface is the intake/result rendering pipeline; the rule is the same — every DOM write is `textContent`, never `innerHTML`, every time. Build a structural test into every task that greps for `innerHTML` in the touched code and fails on any non-comment hit.

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
|---|-------|---------|---------------|
| A1 | `claude-haiku-4-5` will still be the recommended Anthropic Haiku model when Phase 2 ships | 4 | Low — one-line model-id change if it's retired; Phase 0 lesson learned |
| A2 | The system prompt in Section 1 produces high-quality bureaucratic Hochdeutsch on first call | 1 | Medium — known iteration target. Phase 5 pilot debrief is the validation point. STATE.md "Open Questions" includes this. |
| A3 | `output_config.format` continues to work without beta headers on Haiku 4.5 | 2 | Low — fallback to tool-use forced-call is documented and one-day swap |
| A4 | The 4096-token cache minimum on Haiku 4.5 is current as of 2026-05-14 | 4 | Low — verified against current docs; if it drops, we just enable caching |
| A5 | Anthropic per-call pricing ($1 input / $5 output per MTok for Haiku 4.5) is current | 4 | Low — verified 2026-05-14; tracked annually |
| A6 | The intake form copy in Section 5 is clear to a non-native English speaker | 5 | Medium — first real user feedback (Phase 5 pilot) is the test |
| A7 | The five error classes in Section 7 cover all realistic Anthropic failure modes | 7 | Medium — if a 408 (timeout) or 503 (overloaded) appears, the "server" class is the catch-all and copy still reads sensibly |
| A8 | The `?mock=1` URL flag does not interfere with the Phase 1 CSP | 10 | Low — query string parsing is plain JS, no eval, no script injection |
| A9 | The user's situation textarea will never be so long it hits Anthropic's input context limit | 10 (Risk 7) | Very low — Haiku 4.5 context is large; a 200KB paste is ~50k tokens, still under context |

A1–A5 are calibration assumptions (verified now, may drift). A6–A9 are design assumptions (validated by pilot).

## Open Questions

1. **Should the Phase 2 result screen include the (Phase 1-hardcoded) Block A / D / G / H values alongside the LLM-generated blocks, even though they don't render as a full cheat sheet?**
   - What we know: Phase 2's result screen is "raw structured output" per ROADMAP. Phase 3 renders Blocks A–H. The Phase 1 constants are accessible in `index.html`.
   - What's unclear: Whether the sanity check is more useful with full A–H visible (so Francisco can eyeball the gestalt) or just B/C/E/F (the schema-validation purpose).
   - Recommendation: Phase 2 shows only B/C/E/F (what the LLM returned). Adding A/D/G/H rendering even as a preview is Phase 3 scope creep. Francisco can mentally compose the full sheet from the constants he already knows are correct.

2. **Should the Generate button be disabled while in `'generating'` state, or should the screen swap immediately to `'generating'` so the question is moot?**
   - What we know: Swapping screens immediately means the button no longer exists, so the user cannot double-click.
   - Recommendation: Swap screens immediately. Simpler, and the cycling loading messages give better feedback than a disabled button on the intake screen.

3. **What does the textarea minimum length look like? Is one sentence enough, or should the UI prompt for two?**
   - What we know: The system prompt's edge-case branch handles short / empty situations gracefully.
   - Recommendation: No min-length enforcement in Phase 2. The UI helper says "A few sentences is enough" as a soft hint. Phase 5 pilot tells us whether real users undershoot.

4. **Should `?mock=1` be discoverable in the UI (e.g. a small dev-mode link in the footer), or hidden as a URL flag only?**
   - Recommendation: URL flag only. Document in `README.md`. Surfacing it in the UI risks real users finding it and getting confused. Francisco is the only person who needs it.

Francisco-facing questions to surface before planning starts:
- The locked JSON schema in Section 3 — is the field naming acceptable, or does he want different field names (e.g. `germanLine` vs `de`, `englishGloss` vs `en`)? Schema lives both in Phase 2 send and Phase 3 render; a rename later is a two-file edit.
- The error copy in Section 7 — is the tone right for the project's audience (non-native English speakers under stress)? Particularly "Anthropic is having a problem" — should it name Anthropic at all, or just say "the AI service"?

## Project Constraints (from CLAUDE.md)

From `C:\Users\pacoe\coding_projects\inmigration tool\CLAUDE.md` and `C:\Users\pacoe\coding_projects\CLAUDE.md`:

- Vanilla HTML, CSS, vanilla JS only. No frameworks, no build system, no TypeScript.
- Single-file pattern: inline `<style>` and `<script>` in one HTML file.
- Never use dashes (em dash, en dash) in visible text or copy suggestions.
- Add comments to explain what each section does.
- Keep functions short and focused on one thing.
- Make small changes one step at a time.
- Git commit messages in present tense, short, descriptive.
- GSD workflow enforced — all edits via `/gsd-execute-phase` (or equivalent), not direct.
- Privacy: nothing leaves the user's browser except the single LLM call. No analytics. No backend.
- Beginner frontend developer; explain what changed and why.

Phase 2-specific reading of these:
- The intake form is one section, the result screen is one section, the error panel is one section — all pre-rendered in HTML with `hidden` flipped by `render()`. Same shape as Phase 1.
- Helper functions (`buildRequestBody`, `callAnthropic`, `parseAndValidateResponse`) are short and single-purpose. Avoid mega-functions.
- All copy in Sections 5 and 7 is dash-free; the planner should review for any em/en dashes inadvertently introduced.
- Add a top-of-section banner comment for each new block in `<script>` (Phase 1 precedent).

The planner MUST honor these. Any task that contradicts one of these directives is invalid.

## Sources

### Primary (HIGH confidence)

- [Anthropic structured outputs (output_config.format)](https://platform.claude.com/docs/en/docs/build-with-claude/structured-outputs) — JSON schema constrained sampling, GA on Haiku 4.5, no beta header (verified 2026-05-14)
- [Anthropic tool use overview](https://platform.claude.com/docs/en/docs/build-with-claude/tool-use/overview) — `tool_choice` forced-call shape, tool-use token overhead table
- [Anthropic prompt caching](https://platform.claude.com/docs/en/build-with-claude/prompt-caching) — cache_control syntax, 5-min/1-hour TTLs, 0.1x cache-read multiplier, 4096-token minimum on Haiku 4.5
- [Anthropic pricing](https://platform.claude.com/docs/en/about-claude/pricing) — Haiku 4.5: $1/MTok input, $5/MTok output, $1.25 cache write 5m, $0.10 cache read
- [Anthropic prompt engineering best practices](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering) — system prompt design, XML tag fencing, forbidden-behaviour patterns
- [Phase 0 spike outcome](.planning/phases/00-cors-and-provider-spike/00-01-SUMMARY.md) — confirms CORS + headers + model id
- [Phase 1 skeleton](index.html) — `appState`, CSP, localStorage helpers, MIGRATIONSAMT/BLOCK_D/HOCHDEUTSCH_REQUEST/BLOCK_H_FOOTER constants
- [ROADMAP.md Cheat Sheet Anatomy](.planning/ROADMAP.md) — Block B/C/E/F definitions

### Secondary (MEDIUM confidence)

- [Anthropic Haiku model page](https://www.anthropic.com/claude/haiku) — cross-check for Haiku 4.5 capability claims
- Anthropic prompt-engineering long-form guide (60KB, partially fetched) — confirms XML tags and instruction structure
- [pricepertoken.com Claude Haiku 4.5](https://pricepertoken.com/pricing-page/model/anthropic-claude-haiku-4.5) — cross-check pricing

### Tertiary (LOW confidence)

- Exact German wording of the SYSTEM_PROMPT examples ("Sehr geehrte Damen und Herren", "Ich möchte..."). Conventional bureaucratic German; native-speaker review is a Phase 5 pilot-prep item.

## Metadata

**Confidence breakdown:**

- Anthropic structured-output API: HIGH — official docs, current, GA on chosen model
- Pricing and token estimates: HIGH — direct from pricing docs (verified 2026-05-14)
- Prompt caching applicability: HIGH — clear minimum-token threshold, our prefix is well below
- System prompt design: MEDIUM — follows Anthropic's documented best practices, but the EXACT wording is a known iteration target for Phase 5
- JSON schema: HIGH — covers ROADMAP Cheat Sheet Anatomy Blocks B/C/E/F, validated against Phase 3 rendering needs
- Intake / result / error UI: MEDIUM — design is sound for a beginner-friendly single-file app, but real users may surface usability issues at Phase 5 pilot
- State machine: HIGH — small union, transitions are explicit
- Cost per call: HIGH — math is direct from pricing
- Mock fixture flag: HIGH — pattern is standard, costs three lines
- Security posture: HIGH — extends Phase 1 unchanged

**Research date:** 2026-05-14
**Valid until:** 2026-06-14 for the pricing and model-id items (re-verify before Phase 5 pilot). All other items stable until project completion.
