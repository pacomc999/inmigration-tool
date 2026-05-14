# Requirements, v1

Scoped requirements for the v1.0 milestone of the Migrationsamt Zürich Call Helper.

## v1 Requirements

### Verification, Phase 0

- [ ] **SPIKE-01**: Confirmed via deployed-origin spike that both Gemini and OpenAI accept direct browser `fetch` calls from the chosen host on Chrome and iOS Safari, or Plan B proxy committed

### API Key & Settings (KEY)

- [ ] **KEY-01**: User can paste their own OpenAI or Gemini API key into the app and have it persisted in browser localStorage only
- [ ] **KEY-02**: User can clear their stored API key in one click
- [ ] **KEY-03**: API key input uses `type="password"` and the key is masked after save
- [ ] **KEY-04**: User can switch between Gemini and OpenAI as their provider; Gemini is the default

### Situation Intake (INTAKE)

- [ ] **INTAKE-01**: User selects their UI language from English, Spanish, or Portuguese
- [ ] **INTAKE-02**: User selects their permit type from a structured list (L, B, C, Ci, G, N, F, S, or "I don't know"), never free text
- [ ] **INTAKE-03**: User selects their reason for calling from a curated topic list (renewal, change of status, family reunification, work-permit change, address change, missing document, lost permit, status check, appointment booking, other)
- [ ] **INTAKE-04**: User can enter optional structured reference data: case reference number, AHV number, appointment date if any
- [ ] **INTAKE-05**: User can describe their situation in free text in their chosen language

### Cheat Sheet Generation (LLM)

- [ ] **LLM-01**: On submission, the app calls the chosen LLM provider with a system prompt that forbids generating contact details, forbids permit-eligibility advice, and forbids strategic legal advice
- [ ] **LLM-02**: The LLM returns structured JSON matching the locked cheat sheet schema (Blocks B, C, E, F content)
- [ ] **LLM-03**: The app shows a clear loading state with reassurance messages for the 10-20s generation window
- [ ] **LLM-04**: The app handles 401, 429, 500, and JSON parse errors with user-friendly messages in the user's chosen language

### Cheat Sheet Rendering (CHEAT)

- [ ] **CHEAT-01**: Block A, hardcoded call header with Migrationsamt name, phone, address, current-day opening hours window, and the user's stated goal
- [ ] **CHEAT-02**: Block B, opening script in Standard German with native-language gloss under each line; always includes the Hochdeutsch-request sentence by default
- [ ] **CHEAT-03**: Block C, likely officer questions and suggested answers in two columns (German left, native right) covering at least 4 likely questions for the chosen topic, with both affirmative and negative answer forms
- [ ] **CHEAT-04**: Block D, hardcoded panic phrases in DE with native gloss (please repeat, slower, send by email, I don't understand, I understood, thank you, Auf Wiederhören)
- [ ] **CHEAT-05**: Block E, vocabulary mini-glossary of 6 to 12 German domain words with article and translation
- [ ] **CHEAT-06**: Block F, prep checklist tailored to the user's intake (documents, reference numbers, phone charged, sheet open)
- [ ] **CHEAT-07**: Block G, note-taking lines on the printed sheet only (officer name, next step, date, ref number)
- [ ] **CHEAT-08**: Block H, footer safety notice with "preparation aid, not legal advice" and escalation links (Welcome Desk, MIRSAH, Solinetz)

### Trust & Safety (TRUST)

- [ ] **TRUST-01**: A non-dismissable disclaimer is visible on every cheat sheet
- [ ] **TRUST-02**: First-time users see a consent checkbox before the first generation, explaining what data goes to the LLM provider and what stays local
- [ ] **TRUST-03**: A privacy page explains the no-backend, no-logging, BYO-key model in plain English
- [ ] **TRUST-04**: The app never accesses the microphone, ever (lifetime guardrail, no code path requests `getUserMedia({ audio: true })`)
- [ ] **TRUST-05**: A first-visit onboarding screen explains how to get a free Gemini API key, with link

### Print & Mobile (PRINT)

- [ ] **PRINT-01**: `@media print` styles produce a clean A4 layout with one or two pages, page-break-inside avoided on each block
- [ ] **PRINT-02**: The cheat sheet is usable as a single-column layout on a mobile phone screen
- [ ] **PRINT-03**: All non-cheat-sheet UI (buttons, intake form) is hidden when printing

### Multilingual (LANG)

- [ ] **LANG-01**: All UI strings exist in EN, ES, and PT (intake labels, buttons, errors, onboarding)
- [ ] **LANG-02**: The cheat sheet's native-language gloss column renders in the user's chosen language

### Pilot Validation (PILOT)

- [ ] **PILOT-01**: First real user (someone close to the developer) completes an actual Migrationsamt call using the cheat sheet, and provides a structured debrief feeding back into the prompt and phrasebook

## v2 / Deferred Requirements

- v2: Live AI interpreter mode (Path B-lite), real-time translation during the user's call via OpenAI Realtime API
- v1.x: Audio playback of German phrases for pronunciation
- v1.x: QR handoff so the user can move the cheat sheet from desktop to phone
- v1.x: Saved-sheets list (with privacy considerations)
- v1.x: Post-call reflection capture
- v2: Streaming LLM response (if real-user pilot shows wait-time abandonment)

## Out of Scope (Permanent or for Now)

- AI dialing the Migrationsamt directly, Swiss recording law and Migrationsamt practice make this not viable
- Microphone access of any kind, lifetime guardrail tied to Art. 179bis StGB
- Cantons other than Zürich, each canton's migration office differs
- Languages beyond EN, ES, PT for v1
- Permit advice, eligibility analysis, or any form of legal guidance, regulated activity in Switzerland
- Federal SEM matters (asylum, citizenship)
- Backend, accounts, server-side storage
- Native mobile app
- Markdown or third-party CDN scripts at runtime (CSP-strict, JSON-to-DOM only)
- Persisted cheat sheets across sessions, only API key and structured intake are persisted

## Traceability

Every active v1 requirement maps to exactly one phase. 30 of 30 mapped, 0 orphans.

| Requirement | Phase | Status |
|-------------|-------|--------|
| SPIKE-01 | Phase 0 | Pending |
| KEY-01 | Phase 1 | Pending |
| KEY-02 | Phase 1 | Pending |
| KEY-03 | Phase 1 | Pending |
| KEY-04 | Phase 1 | Pending |
| TRUST-04 | Phase 1 | Pending (lifetime guardrail, enforced from Phase 1 forward) |
| INTAKE-02 | Phase 2 | Pending |
| INTAKE-03 | Phase 2 | Pending |
| INTAKE-04 | Phase 2 | Pending |
| INTAKE-05 | Phase 2 | Pending |
| LLM-01 | Phase 2 | Pending |
| LLM-02 | Phase 2 | Pending |
| LLM-03 | Phase 2 | Pending |
| LLM-04 | Phase 2 | Pending (EN error copy in Phase 2; ES/PT in Phase 4 via LANG-01) |
| TRUST-02 | Phase 2 | Pending |
| CHEAT-01 | Phase 3 | Pending (constants file lives in Phase 1; rendering in Phase 3) |
| CHEAT-02 | Phase 3 | Pending |
| CHEAT-03 | Phase 3 | Pending |
| CHEAT-04 | Phase 3 | Pending (constants file lives in Phase 1; rendering in Phase 3) |
| CHEAT-05 | Phase 3 | Pending |
| CHEAT-06 | Phase 3 | Pending |
| CHEAT-07 | Phase 3 | Pending (constants file lives in Phase 1; rendering in Phase 3) |
| CHEAT-08 | Phase 3 | Pending (constants file lives in Phase 1; rendering in Phase 3) |
| TRUST-01 | Phase 3 | Pending |
| TRUST-03 | Phase 3 | Pending |
| TRUST-05 | Phase 3 | Pending |
| PRINT-01 | Phase 3 | Pending |
| PRINT-02 | Phase 3 | Pending |
| PRINT-03 | Phase 3 | Pending |
| INTAKE-01 | Phase 4 | Pending (selector meaningless without ES + PT content live) |
| LANG-01 | Phase 4 | Pending |
| LANG-02 | Phase 4 | Pending |
| PILOT-01 | Phase 5 | Pending |
