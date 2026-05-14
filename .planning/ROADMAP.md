# Roadmap, v1

Milestone: v1 of the Migrationsamt Zürich Call Helper. Ship a printable cheat sheet that lets a non-German speaker make a real Migrationsamt call within one month.

- Granularity: coarse (per config.json)
- Project mode: standard (Horizontal Layers; the research's build order is load-bearing)
- Parallelization: enabled (independent plans within a phase can run as separate waves)
- Lifetime guardrail: the app NEVER accesses the microphone. No code path may call `getUserMedia({ audio: true })`, ever. This is tied to Art. 179bis StGB and applies to every phase and to all future versions.

## Cheat Sheet Anatomy (locked, referenced by phases)

The product is one printable A4/phone sheet with eight blocks, A through H, top to bottom. Phases reference these block IDs:

- **Block A** Call Header: hardcoded office name, phone, address, current-day hours window, plus user's stated goal
- **Block B** Opening Script: German lines with native gloss, always includes the Hochdeutsch-request sentence
- **Block C** Likely Officer Questions and Suggested Answers: two columns DE/native, affirmative and negative answer forms
- **Block D** Panic Phrases: hardcoded DE phrases with native gloss (repeat, slower, send by email, I don't understand, I understood, thank you, Auf Wiederhören)
- **Block E** Vocabulary Mini-Glossary: 6 to 12 German domain words with article and translation
- **Block F** Prep Checklist: documents, reference numbers, phone charged, sheet open, tailored to intake
- **Block G** Note-Taking Lines: printable only (officer name, next step, date, reference number)
- **Block H** Footer Safety Notice: "preparation aid, not legal advice" plus escalation links (Welcome Desk, MIRSAH, Solinetz)

Hardcoded blocks: A (contact + hours), D, G, H. LLM-generated blocks: B (custom sentence + reference number), C, E, F, plus the user-goal sentence inside A.

## Phases

- [ ] **Phase 0: CORS and Provider Spike** - de-risk the load-bearing assumption that the browser can directly call Gemini and OpenAI from the deployed origin
- [ ] **Phase 1: Skeleton, State, Key Handling, Static Constants** - HTML scaffold, appState + setState + render, BYO key flow, hardcoded Migrationsamt constants, strict CSP, Blocks A/D/G/H static content in place
- [ ] **Phase 2: LLM Round-Trip in English** - structured intake form, prompt building, JSON-schema response, error handling, loading state, consent before first generation
- [ ] **Phase 3: Cheat Sheet Rendering, Print, Mobile, Onboarding, Privacy** - render Blocks A through H, two-column DE/native, print stylesheet, phone layout, onboarding, privacy page, non-dismissable disclaimer
- [ ] **Phase 4: Multilingual Intake and Glosses (ES + PT)** - UI language switcher live, ES and PT prompt templates, ES and PT gloss columns
- [ ] **Phase 5: First Real-User Pilot and Prompt Tuning** - first close contact uses the tool for a real call, debrief feeds back into phrasebook and prompts

## Phase Details

### Phase 0: CORS and Provider Spike
**Goal**: Prove that a static HTML page on the chosen production host can `fetch` directly to both Gemini and OpenAI with a real key, on Chrome and iOS Safari. If it cannot, commit to Plan B (Cloudflare Workers proxy) before any other code is written.
**Depends on**: Nothing (first phase)
**Requirements**: SPIKE-01
**Success Criteria** (what must be TRUE):
  1. A throwaway static HTML page deployed to the real production host (Netlify Drop or GitHub Pages) successfully fetches a non-empty completion from Gemini using a real key, on desktop Chrome
  2. The same page successfully fetches a non-empty completion from OpenAI using a real key, on desktop Chrome
  3. Both fetches are repeated successfully on iOS Safari from the same deployed URL
  4. If any of the above fails, Plan B (Cloudflare Workers proxy) is committed with a working spike before Phase 1 starts
  5. Outcome documented in PROJECT.md Key Decisions and in a Phase 0 note (CORS-green or Plan-B chosen)
**Plans**: 1 plan
- [ ] 00-01-PLAN.md - Anthropic CORS spike on GitHub Pages (build spike/index.html, deploy via Pages, verify desktop Chrome fetch, record outcome in PROJECT.md Key Decisions)

Note: the Phase 0 Goal and Success Criteria above predate the discussion captured in `.planning/phases/00-cors-and-provider-spike/00-CONTEXT.md`. The CONTEXT decisions (D-01, D-02, D-05) narrow Phase 0 to Anthropic-only on desktop Chrome and supersede the Gemini/OpenAI/iOS Safari language above. The pre-existing wording is left intact here for traceability and will be amended formally during Phase 1 planning along with KEY-04.

### Phase 1: Skeleton, State, Key Handling, Static Constants
**Goal**: Lay the structural backbone the rest of the app hangs from, with the API key flow working end-to-end, the lifetime microphone guardrail in place, and every fact the LLM is forbidden to invent already hardcoded.
**Depends on**: Phase 0
**Requirements**: KEY-01, KEY-02, KEY-03, KEY-04, TRUST-04
**Success Criteria** (what must be TRUE):
  1. User can paste an OpenAI or Gemini API key into a `type="password"` field, save it, reload the page, and see the key still present (stored only in browser localStorage)
  2. User can switch the active provider between Gemini and OpenAI, with Gemini as the default on first visit
  3. User can click "Clear key" and verify in DevTools that the key is gone from localStorage
  4. After save, the key input shows a masked representation (e.g. last 4 characters only), never the full key
  5. A strict CSP meta tag is in place, no third-party scripts load at runtime, and a `git grep` for `getUserMedia` returns zero matches (lifetime mic guardrail)
**Plans**: TBD
**UI hint**: yes

### Phase 2: LLM Round-Trip in English
**Goal**: Make the highest-risk technical step real. User fills the structured intake in English, the app sends a single LLM call with the locked prompt, parses the JSON response against the Block B/C/E/F schema, and either lands on a viewable raw result or shows a friendly error.
**Depends on**: Phase 1
**Requirements**: INTAKE-02, INTAKE-03, INTAKE-04, INTAKE-05, LLM-01, LLM-02, LLM-03, LLM-04, TRUST-02
**Success Criteria** (what must be TRUE):
  1. User can fill out a structured intake form: permit type from a fixed list (L/B/C/Ci/G/N/F/S/"I don't know", never free text), reason for calling from a curated topic list, optional reference fields, and a free-text situation description in English
  2. On first generation, user sees a consent checkbox explaining what data is sent to which LLM provider and what stays local; cannot submit without checking it
  3. After submission, user sees a clear loading state with reassurance messaging during the 10 to 20 second wait
  4. On success, the parsed JSON returned by the LLM matches the locked schema for Blocks B, C, E, and F, and is viewable (even as raw structured output) on a result screen
  5. On 401, 429, 500, or JSON parse failure, the user sees a friendly English error message with a "Try again" and "Back to intake" path; the system prompt forbids generating contact details, permit-eligibility advice, and strategic legal advice
**Plans**: TBD
**UI hint**: yes

### Phase 3: Cheat Sheet Rendering, Print, Mobile, Onboarding, Privacy
**Goal**: Turn the parsed JSON into the actual deliverable: a polished two-column cheat sheet that prints cleanly on A4, reads cleanly on a phone, sits behind a first-visit onboarding flow and consent, and never lets the user lose sight of the "not legal advice" disclaimer.
**Depends on**: Phase 2
**Requirements**: CHEAT-01, CHEAT-02, CHEAT-03, CHEAT-04, CHEAT-05, CHEAT-06, CHEAT-07, CHEAT-08, PRINT-01, PRINT-02, PRINT-03, TRUST-01, TRUST-03, TRUST-05
**Success Criteria** (what must be TRUE):
  1. After a successful generation, user sees a rendered cheat sheet with all eight blocks A through H present: hardcoded call header (A), opening script with Hochdeutsch-request line (B), at least 4 likely officer questions with affirmative and negative answers (C), pinned panic phrases (D), 6 to 12 vocabulary entries with articles (E), tailored prep checklist (F), note-taking lines visible only on print (G), and footer with escalation links (H)
  2. A non-dismissable "preparation aid, not legal advice" disclaimer is visible at the top of every rendered cheat sheet
  3. Hitting Ctrl+P or the in-app Print button produces a clean A4 layout, one to two pages, with form controls and buttons hidden, and no section is split across a page break
  4. The cheat sheet renders as a readable single-column layout on a real iPhone Safari window (tested on device, not just devtools emulation)
  5. A first-time visitor without a key lands on an onboarding screen explaining the BYO-key model, with a link to obtain a free Gemini key, and can read a dedicated privacy page explaining the no-backend, no-logging, BYO-key posture in plain English
**Plans**: TBD
**UI hint**: yes

### Phase 4: Multilingual Intake and Glosses (ES + PT)
**Goal**: Triple the audience now that the English pipeline is proven. Add Spanish and Portuguese as fully supported UI and gloss languages, with per-language user-prompt templates so the LLM produces native-language glosses in Blocks B, C, E, and F.
**Depends on**: Phase 3
**Requirements**: INTAKE-01, LANG-01, LANG-02
**Success Criteria** (what must be TRUE):
  1. User can pick UI language from English, Spanish, or Portuguese on the intake screen, and every intake label, button, helper text, error message, and onboarding string flips to the chosen language
  2. With Spanish or Portuguese selected, a generated cheat sheet renders the native-language gloss column (in Blocks B, C, E, F) in the user's chosen language, not in English
  3. The hardcoded blocks D (panic phrases) and H (footer notice) also display their native-language text in the chosen language
  4. Provider error messages (401, 429, 500, parse) render in the user's chosen language
**Plans**: TBD
**UI hint**: yes

### Phase 5: First Real-User Pilot and Prompt Tuning
**Goal**: Validate the entire artefact with the real audience of one: someone close to the developer who is actively dealing with Zürich immigration. Their actual call is the v1 acceptance test. Their debrief loops back into the phrasebook and prompt.
**Depends on**: Phase 4
**Requirements**: PILOT-01
**Success Criteria** (what must be TRUE):
  1. The first real user completes an actual Migrationsamt Zürich phone call using the v1 cheat sheet (printed or on-screen) as their primary aid
  2. A structured debrief is captured: what did the officer actually ask first, which Block C questions matched reality, which German phrases failed, what was missing
  3. At least one concrete improvement (system prompt change, phrasebook addition, or topic-template adjustment) is committed back into the app based on the debrief
  4. The first user confirms they would use the tool again for a future call, or names the specific blockers that would have to change for them to do so

## Progress

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 0. CORS and Provider Spike | 0/1 | Planned | - |
| 1. Skeleton, State, Key Handling, Static Constants | 0/0 | Not started | - |
| 2. LLM Round-Trip in English | 0/0 | Not started | - |
| 3. Cheat Sheet Rendering, Print, Mobile, Onboarding, Privacy | 0/0 | Not started | - |
| 4. Multilingual Intake and Glosses (ES + PT) | 0/0 | Not started | - |
| 5. First Real-User Pilot and Prompt Tuning | 0/0 | Not started | - |

## Coverage

All 30 v1 requirements mapped, no orphans.

| Phase | Requirements |
|-------|--------------|
| 0 | SPIKE-01 |
| 1 | KEY-01, KEY-02, KEY-03, KEY-04, TRUST-04 |
| 2 | INTAKE-02, INTAKE-03, INTAKE-04, INTAKE-05, LLM-01, LLM-02, LLM-03, LLM-04, TRUST-02 |
| 3 | CHEAT-01, CHEAT-02, CHEAT-03, CHEAT-04, CHEAT-05, CHEAT-06, CHEAT-07, CHEAT-08, PRINT-01, PRINT-02, PRINT-03, TRUST-01, TRUST-03, TRUST-05 |
| 4 | INTAKE-01, LANG-01, LANG-02 |
| 5 | PILOT-01 |

## Notes on Phase Boundaries

- **INTAKE-01 lives in Phase 4, not Phase 2.** The UI language selector is meaningless until ES and PT are real. Phase 2 ships English-only intake and English-only error messages; Phase 4 turns INTAKE-01 on.
- **Block A, D, G, H content is hardcoded in Phase 1** (constants file: phone, address, hours, panic phrases, footer text, escalation links). The CHEAT-01/04/07/08 *rendering* requirements live in Phase 3 because that's when the result screen exists.
- **TRUST-04 (no microphone, ever) is a lifetime guardrail.** Phase 1 enforces it (CSP + grep check) but it applies to every future phase and every v1.x / v2 feature.
- **Parallelization within phases**: independent plans (e.g. in Phase 3, "print stylesheet" vs "onboarding flow" vs "privacy page") can be authored as separate waves and run concurrently per config.json.
