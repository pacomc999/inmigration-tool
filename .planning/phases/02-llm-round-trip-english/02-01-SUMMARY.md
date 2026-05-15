---
phase: 02-llm-round-trip-english
plan: 01
subsystem: intake-state-machine
tags: [intake, state-machine, consent, trust-02, phase-2]
requires:
  - v1-index-html-at-repo-root
  - appstate-setstate-render-pattern
  - byo-anthropic-key-flow
  - localstorage-key-namespace-migrationsamt
provides:
  - intake-screen-dom
  - intake-form-validation
  - consent-localstorage-persistence
  - five-value-screen-union
  - last-intake-snapshot
  - generate-click-stub-splice-point
affects:
  - index.html
tech_stack_added: []
patterns:
  - five-value screen union with stub branches for Plan 02
  - validate-on-input gate for the Generate button
  - one-time localStorage flag for consent that survives reloads
  - inline key header strip so the user manages the key without leaving the form
  - stub click handler with a console.warn splice marker for the next plan
key_files_created:
  - .planning/phases/02-llm-round-trip-english/02-01-SUMMARY.md
key_files_modified:
  - index.html
decisions:
  - "appState screen union widened to 'key-entry' | 'intake' | 'generating' | 'result' | 'error'; 'ready' dropped from reachable states (defensive coerce-to-intake guard kept)"
  - "appState gained lastIntake, cheatSheet, errorClass, errorDetail, consentGiven fields. Initial values: nulls and false"
  - "Consent persists across reloads via localStorage key 'migrationsamt.consentGiven' (string 'true'); Clear key removes it"
  - "Permit dropdown ships exactly 9 real options + placeholder (L, B, C, Ci, G, N, F, S, unknown)"
  - "Reason dropdown ships exactly 10 real options + placeholder (renewal, change_status, family_reunification, work_permit_change, address_change, missing_document, lost_permit, status_check, appointment_booking, other)"
  - "Three optional reference inputs: caseRef (text), ahv (text with NO format validation), appointmentDate (input type=date)"
  - "Free-text situationText textarea is required, no max length"
  - "User-visible Phase 1 keyEntry copy switched from 'Anthropic' to 'the AI service' for generic tone (Rule 2 deviation, expanded from the plan's intake-screen-only scope)"
  - "Plan 01 onGenerateClick is a stub that snapshots intake into appState.lastIntake, persists consent, and console.warns the splice marker 'Plan 02 wires the LLM call here'"
  - "Phase 1 #ready section retained in DOM as an unreachable defensive fallback (plan-mandated)"
metrics:
  completed_date: 2026-05-15
  tasks_completed: 3
  duration: "single session"
---

# Phase 2 Plan 1: Intake Form, Consent Gate, and Screen Union Extension Summary

**One-liner:** Extended the Phase 1 skeleton with a five-value screen state machine, the structured intake form (permit, reason, three optional references, free-text situation), the TRUST-02 consent block with localStorage persistence, the inline key-management header strip, and a stub Generate click that snapshots the intake into `appState.lastIntake` for Plan 02 to consume.

## What Was Built

Two commits on top of the Phase 2 context (`28a5780`):

1. **`b620dc5` — `Extend appState and render for new screen union (Phase 2 Plan 01 Task 1)`**
   Inline `<script>` block in `index.html` widens `appState`, adds the consent helpers, rewrites `render()` to switch on the five-value screen union, and routes a saved-key user to `intake` instead of `ready` on both Save key and DOMContentLoaded. The 16-check Node verify exits 0.

2. **`205fd7d` — `Add intake screen with consent gate and validation (Phase 2 Plan 01 Task 2)`**
   `index.html` gains the `#intake` DOM section, the intake CSS rules, the `validateIntake` function, and the `onGenerateClick` stub. User-visible keyEntry copy switched from `Anthropic` to `the AI service`. The 41-check Node verify exits 0.

Task 3 (`verify-no-mic.ps1` + innerHTML grep) is verification-only; both checks return clean. No files modified.

## Final appState Shape

```javascript
const appState = {
  screen: 'key-entry',     // 'key-entry' | 'intake' | 'generating' | 'result' | 'error'
  apiKey: null,            // raw key, in memory only
  lastIntake: null,        // last intake snapshot, populated by onGenerateClick
  cheatSheet: null,        // parsed LLM JSON (Plan 02 populates)
  errorClass: null,        // 'auth' | 'rate-limit' | 'server' | 'parse' | 'network' (Plan 02)
  errorDetail: null,       // { httpStatus?, bodyText?, message? } (Plan 02)
  consentGiven: false,     // mirrored from localStorage on load
};
```

## New localStorage Key

| Key | Value | Set by | Cleared by |
|-----|-------|--------|-----------|
| `migrationsamt.consentGiven` | string `'true'` or absent | `saveConsent()` invoked from `onGenerateClick` when the user first ticks the consent checkbox and clicks Generate | `handleClearKey()` (wipes both the API key and consent in one click), best effort silent on failure |

`loadConsent()` reads it on DOMContentLoaded and mirrors to `appState.consentGiven`. Any read or write throw is silently treated as "no consent recorded" so private-browsing or quota errors only re-display the consent block.

## Intake Form Fields and Element IDs

Plan 02 will reference these by id. Reading order top to bottom inside `#intake`:

| Element id | Type | Required | Source of values | Notes |
|------------|------|----------|------------------|-------|
| `intakeMaskedKey` | `<span>` | n/a | `maskKey(appState.apiKey)` | Populated by render() |
| `intakeReplaceKey` | `<button>` | n/a | wires to `handleReplaceKey` | |
| `intakeClearKey` | `<button>` | n/a | wires to `handleClearKey` | |
| `permitType` | `<select>` | yes | 9 fixed values: L, B, C, Ci, G, N, F, S, unknown | INTAKE-02 |
| `callReason` | `<select>` | yes | 10 fixed values: renewal, change_status, family_reunification, work_permit_change, address_change, missing_document, lost_permit, status_check, appointment_booking, other | INTAKE-03 |
| `caseRef` | `<input type="text">` | no | free text | INTAKE-04 |
| `ahv` | `<input type="text">` | no | free text, NO pattern validation | INTAKE-04 |
| `appointmentDate` | `<input type="date">` | no | ISO date string | INTAKE-04 |
| `situationText` | `<textarea>` | yes | free text, no max length | INTAKE-05 |
| `intakeConsent` | `<section>` | shown only when `appState.consentGiven` is false | block heading + paragraph + ul + checkbox label | TRUST-02 |
| `consentCheckbox` | `<input type="checkbox">` | when consent block is shown | unchecked initially | TRUST-02 |
| `generateButton` | `<button>` | starts disabled, enabled by `validateIntake` | wires to `onGenerateClick` | |
| `intakeError` | `<p class="error">` | empty initially | role="status" for future inline validation hints | |

`onGenerateClick` reads the trimmed values from the form fields and stores them in `appState.lastIntake` with the shape:

```javascript
{ permit, reason, caseRef, ahv, appointmentDate, situation }
```

Empty strings are allowed for the three optional reference fields.

## Plan 02 Splice Point

The Generate click handler is intentionally a stub:

```javascript
function onGenerateClick() {
  // ... reads form fields and builds the snapshot ...
  setState({ lastIntake: snapshot });

  // Stub: Phase 2 Plan 02 replaces this body with the LLM round-trip.
  console.warn('Plan 02 wires the LLM call here. Intake snapshot:', appState.lastIntake);
}
```

Plan 02 should:

1. Replace the `console.warn` line with the Anthropic Messages API call (per 02-RESEARCH.md Sections 1-4).
2. Add a screen swap to `'generating'` before the fetch and to `'result'` or `'error'` after.
3. Wire the `renderUnimplemented` stub branches (`generating`, `result`, `error`) to real render branches with DOM that Plan 02 owns.

Search `grep "Plan 02 wires the LLM call here"` to find the splice point.

## Verification Results

| Task | Verify command | Result |
|------|----------------|--------|
| 1 | 16-check Node script (appState shape, render switch, key handler routing, defensive guards) | All true, exit 0 |
| 2 | 41-check Node script (intake DOM ids, dropdown values, copy strings, no-dash guards) | All true, exit 0 |
| 3 | `verify-no-mic.ps1` + innerHTML grep | `verify-no-mic: no matches. OK.` and `OK: no innerHTML assignment` |

End-to-end smoke (Francisco runs in desktop Chrome) is documented in the plan's `<verification>` block; not run as part of this executor pass.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 2 - Critical functionality] Generic copy in Phase 1 keyEntry section**
- **Found during:** Task 2 verify
- **Issue:** The plan's Task 2 verify check `noAnthropicInUiCopy` failed because the Phase 1 `#keyEntry` section had user-visible copy mentioning `Anthropic` ("Bring your own Anthropic API key", "Your Anthropic API key", and a helper paragraph). The plan's success criterion says "User-visible copy says `the AI service`, not `Anthropic`."
- **Fix:** Updated three strings in `#keyEntry` to use `API key` / `the AI service`. The Save key error toast (`Please paste your Anthropic API key first.`) was also generalised since it is user-visible. Code comments and CSP-domain references to `api.anthropic.com` were left untouched (the plan permits "Code comments and devtools strings may still mention Anthropic").
- **Files modified:** `index.html`
- **Commit:** `205fd7d`

**2. [Rule 3 - Blocking issue] `render()` 'ready' coercion comment wording**
- **Found during:** Task 1 verify
- **Issue:** The plan's `noReadyInSwitch` regex check tolerates `screen === 'ready'` only if a nearby `coerce` comment marks it as defensive. The first draft of the comment said "no longer a reachable" without the literal word `coerce`, so the regex flagged it.
- **Fix:** Changed `// Defensive coercion: ...` to `// Defensive coerce step: ...` so the regex finds the marker. Behaviour is identical.
- **Files modified:** `index.html`
- **Commit:** `b620dc5` (squashed into Task 1's commit before push since the change was three characters)

### Manual scope edits

- The plan said the keyEntry copy change was implicit in moving to a generic tone, but the explicit instruction was scoped to the intake screen. Treated this as Rule 2 (correctness: the success criterion "User-visible copy says `the AI service`" applies repo-wide, not only inside `#intake`).

No architectural changes. No authentication gates. No Rule 4 escalations.

## Known Stubs

| Stub | File | Line region | Reason |
|------|------|-------------|--------|
| `onGenerateClick` body after `setState({ lastIntake })` | `index.html` | inside the function bound to `#generateButton` click | Intentional. Plan 02 replaces this with the LLM round-trip. Splice marker: `Plan 02 wires the LLM call here`. |
| `renderUnimplemented` branches for `generating`, `result`, `error` | `index.html` | inside `render()` switch | Intentional. Plan 02 fills in the real branches and adds the DOM sections they need. |
| `#ready` DOM section retained but unreachable | `index.html` | inside `<main>` | Mandated by the plan ("DO NOT delete it") as a defensive fallback. The defensive coerce in `render()` routes any stray `screen === 'ready'` to `'intake'`. |

All three stubs are documented as Plan 02 work, not gaps in Plan 01.

## Self-Check: PASSED

- `index.html` exists and contains `<section id="intake"` and `id="intakeMaskedKey"`.
- Commit `b620dc5` (Task 1) found in git log.
- Commit `205fd7d` (Task 2) found in git log.
- `verify-no-mic.ps1` exits 0 with the expected OK line.
- No `.innerHTML =` assignment anywhere in `index.html`.
- No em or en dashes anywhere in `index.html`.
