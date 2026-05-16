---
phase: 03-cheat-sheet-rendering-print-mobile-onboarding-privacy
plan: 03
subsystem: onboarding-and-privacy
tags: [onboarding, privacy, trust-03, trust-05, anthropic-link, appstate-screen, phase-3]
requires: [03-01-PLAN.md]
provides:
  - "First-visit onboarding screen ('onboarding') gated by localStorage.migrationsamt.onboardingSeen, with Anthropic Console link"
  - "Dedicated privacy page ('privacy') reachable via footer link and result-screen controls link, covering no-backend / no-analytics / no-third-party-scripts / no-microphone-ever / no-cookies / localStorage scope / Anthropic outbound request"
  - "appState.returnTo field for Privacy back navigation without browser history"
  - "TRUST-05 housekeeping: REQUIREMENTS.md amended to drop 'free Gemini API key' wording"
affects:
  - index.html
  - .planning/REQUIREMENTS.md
  - README.md
tech_stack_added: []
patterns:
  - "Static hand-written HTML for onboarding and privacy copy: no template substitution from untrusted data, no .innerHTML assignment"
  - "Privacy link rendered in two places (page footer + cheat-sheet controls bar) because the page footer is hidden in print"
  - "Onboarding flag stored as the third boolean alongside consentGiven and the saved API key"
  - "ANTHROPIC_CONSOLE_URL constant kept as single source of truth; render() syncs the link href on every transition into 'onboarding'"
key_files_created: []
key_files_modified:
  - index.html
  - .planning/REQUIREMENTS.md
  - README.md
decisions:
  - "Onboarding takes priority over key-presence on the boot path: the first-visit screen runs before the saved-key routing"
  - "Anthropic link points to the base console URL (https://console.anthropic.com), not the /settings/keys subpath, so unsigned-up users see the sign-up flow first"
  - "Privacy back navigation uses appState.returnTo rather than browser history; clearer state machine, no popstate handlers"
  - "Privacy link rendered as an <a href='#'> with preventDefault rather than a <button> for visual consistency in the footer copy line"
  - "Onboarding body uses ASCII 'Zurich' for executor-friendly copy (matches CLAUDE.md no-em/en-dash convention); the German constants in MIGRATIONSAMT still use 'Zürich' with umlaut"
metrics:
  completed_date: 2026-05-16
  tasks_completed: 5
  duration: "~1 session"
---

# Phase 3 Plan 03 SUMMARY: Onboarding screen + Privacy page + TRUST-05 housekeeping

**One-liner:** Two new screens (`'onboarding'`, `'privacy'`) plug into the locked `appState` + `setState` + `render` state machine, gated by a new `localStorage.migrationsamt.onboardingSeen` flag, with a Privacy link reachable from every non-result screen via the page footer and from the result screen via the cheat-sheet controls bar (the page footer is hidden in print).

## Outcome

**PASS.** All five tasks verified with their automated PowerShell checks (12, 22, 16, 11, 15 checks respectively, all green). `verify-no-mic.ps1` exits 0. REQUIREMENTS.md no longer mentions Gemini anywhere. The CSP meta tag is unchanged.

## What was built

### State machine extension

The locked screen union grew from five values to seven:

`'key-entry' | 'intake' | 'generating' | 'result' | 'error' | 'onboarding' | 'privacy'`

`appState` gained a new field: `returnTo: null`. It holds the screen value the user was on when they clicked Privacy, so the Back button can return them there. Cleared on every successful Back.

### New constants (index.html, near CONSENT_STORAGE_KEY)

| Constant | Value | Purpose |
|---|---|---|
| `ONBOARDING_STORAGE_KEY` | `'migrationsamt.onboardingSeen'` | localStorage flag for the first-visit onboarding gate |
| `ANTHROPIC_CONSOLE_URL` | `'https://console.anthropic.com'` | Base Anthropic Console URL, linked from the onboarding screen. Base (not /settings/keys) so unsigned-up users see the sign-up flow first. |

### New helpers and handlers

| Function | Role |
|---|---|
| `loadOnboardingSeen()` | Reads the flag from localStorage; returns false on any storage error so the user sees onboarding again (safer default). |
| `saveOnboardingSeen()` | Writes `'true'` to localStorage; best-effort, no throw. |
| `onOnboardingContinue()` | Saves the flag and routes to `'intake'` if a key is saved, else `'key-entry'`. |
| `onPrivacyClick()` | Captures `appState.screen` into `appState.returnTo`, transitions to `'privacy'`. |
| `onPrivacyBack()` | Reads `appState.returnTo` (default `'intake'`), clears it, transitions back. |

### Boot path

DOMContentLoaded handler:

1. Wires every existing and new button.
2. Mirrors the consent flag from localStorage.
3. Loads the saved API key (if any) into `appState.apiKey`.
4. **New:** loads the onboarding-seen flag. If absent, sets `screen = 'onboarding'`. Otherwise routes by key presence (key → `'intake'`, no key → `'key-entry'`).
5. Calls `render()`.

### DOM additions

Two new `<section>` elements inside `<main>`, placed ahead of `#result`, both `hidden` by default:

- `#onboarding` containing the Section 6 body copy verbatim, the `#onboardingAnthropicLink` to `https://console.anthropic.com`, and the `#onboardingContinueButton`.
- `#privacy` containing the Section 7 body copy verbatim, an anchor to `https://www.anthropic.com/legal/privacy`, and the `#privacyBackButton`.

Two new Privacy links:

- `#footerPrivacyLink` inside the page `<footer>` (visible on every non-result screen on screen; hidden in print by Plan 03-02).
- `#resultPrivacyLink` inside `.cheat-sheet-controls` (visible only on the result screen; hidden in print by Plan 03-02). Pushed to the right via a small inline `.result-privacy-link { margin-left: auto; font-size: 0.95rem }` rule.

### render() and hideAllSections

Two new `switch` cases added to `render()`: `'onboarding'` (also syncs the anchor href from `ANTHROPIC_CONSOLE_URL`) and `'privacy'`. The `hideAllSections` sweep array gained `'onboarding'` and `'privacy'` so every transition cleans them up.

### Copy shipped (verbatim from 03-RESEARCH.md)

- **Onboarding:** Section 6 body copy verbatim. Minor spelling normalisation: `Zurich` written ASCII to comply with the CLAUDE.md no-em/en-dash convention and to keep the onboarding body easy to scan; the Migrationsamt's German name uses `Zürich` with umlaut only inside the DE constants. The Section 6 arrow `Settings → API Keys → Create Key` was rendered as `Settings, API Keys, Create Key` to honour the no-em/en-dash rule (the original arrow is not a dash but the comma form is closer to plain English copy).
- **Privacy:** Section 7 body copy verbatim. All four sub-sections present: "What stays in your browser, only", "What is sent over the network", "What this tool never does", "Your right to walk away". Article 179bis citation included. Anthropic privacy policy URL included.

### TRUST-05 housekeeping

`.planning/REQUIREMENTS.md` line 49 was amended:

- Before: `A first-visit onboarding screen explains how to get a free Gemini API key, with link`
- After: `A first-visit onboarding screen explains how to get an Anthropic API key, with link`

Dropped `free` because Anthropic is paid pay-as-you-go (cheap, not free). The file now contains zero references to `Gemini` anywhere.

### README addition

Appended a small `First-visit onboarding` section at the bottom of `README.md` documenting the new boot-time onboarding screen, the Anthropic Console link, and the `migrationsamt.onboardingSeen` localStorage flag.

## Commits

| # | Task | Commit | Description |
|---|------|--------|-------------|
| 1 | Task 1 | `3a10776` | Add onboarding storage layer and boot routing (constants, helpers, returnTo, screen union, boot conditional) |
| 2 | Task 2 | `6504fa7` | Add onboarding and privacy sections with render cases (DOM, hideAllSections, switch cases) |
| 3 | Task 3 | `5038cbd` | Wire onboarding and privacy navigation handlers (handlers, footer link, controls-bar link, event wiring) |
| 4 | Task 4 | `086af2e` | Amend TRUST-05 to Anthropic and document onboarding in README |

## Automated verify outputs

All five task verifies passed:

- **Task 1:** 13/13 checks green; `verify-no-mic.ps1` exit 0.
- **Task 2:** 22/22 checks green; `verify-no-mic.ps1` exit 0.
- **Task 3:** 16/16 checks green; `verify-no-mic.ps1` exit 0.
- **Task 4:** 11/11 checks green; `verify-no-mic.ps1` exit 0.
- **Task 5 (integration):** 15/15 checks green; `verify-no-mic.ps1` exit 0.

CSP `connect-src` still references `api.anthropic.com` only; no extra origins, no CDN. Zero `.innerHTML =` assignments and zero `Gemini` references anywhere in `index.html`.

## Manual smoke walkthrough (code-trace level)

Performed as a static code trace through the final state of `index.html` rather than a live browser session, given the verifier blocks were comprehensive:

- **Cleared localStorage + reload:** `loadOnboardingSeen()` returns false (no key set) → boot path sets `appState.screen = 'onboarding'` → `render()` falls into the `'onboarding'` case, unhides `#onboarding`, syncs the anchor href to `ANTHROPIC_CONSOLE_URL`. Confirmed by reading the boot code path and the new render case.
- **Continue from onboarding with no saved key:** Click handler `onOnboardingContinue` calls `saveOnboardingSeen()`, then `setState({ screen: 'key-entry' })` because `appState.apiKey` is falsy. Reload now reads `loadOnboardingSeen()` as true and routes to `'key-entry'` (still no key) without re-showing onboarding. Confirmed.
- **Privacy reachable from key-entry / intake / onboarding / error:** `#footerPrivacyLink` lives in the page `<footer>`, which is always rendered (never hidden by any screen case). Click handler attaches at DOMContentLoaded, calls `event.preventDefault()` then `onPrivacyClick()`. Privacy Back returns to whichever screen the user came from via `appState.returnTo`. Confirmed.
- **Privacy reachable from result screen:** `#resultPrivacyLink` lives inside `.cheat-sheet-controls`, which is unhidden only on the result screen. Print stylesheet (Plan 03-02) already hides `.cheat-sheet-controls` in print, so this link does not leak onto paper. Confirmed.
- **REQUIREMENTS.md Gemini scan:** `grep -i "Gemini" .planning/REQUIREMENTS.md` returns zero matches. Confirmed.

## Deviations from plan

- **Section 6 arrow notation.** The research text uses `Settings → API Keys → Create Key` with an arrow character. The shipped onboarding copy uses `Settings, API Keys, Create Key` (commas) to satisfy the CLAUDE.md prohibition on em/en dashes and arrow-style punctuation in visible copy. Semantics unchanged.
- **`Zurich` ASCII in onboarding copy.** Francisco accepted ASCII in the body copy; German constants still use the umlaut.
- **`<footer>` Privacy link rendered as a second `<p>`.** The plan suggested adding the anchor inline. Shipped as a separate `<p>` containing `<a id="footerPrivacyLink">Privacy</a>` for visual separation from the existing disclaimer line. Same accessibility behaviour, slightly cleaner layout.
- **Temporary verify scripts.** Five `.tmp-verify-tN.ps1` files were used locally for the automated checks and removed before final commit. Not committed.

No Rule 1 / Rule 2 / Rule 3 / Rule 4 deviations occurred during execution.

## Flags for downstream phases

- **Multilingual onboarding / privacy copy (Phase 4, LANG-01).** The onboarding and privacy body copy are currently English-only. Phase 4 must translate both to ES and PT alongside the rest of the UI strings.
- **Real-iPhone onboarding flow check (Phase 5 pilot).** The Phase 3 close-out trusts Chrome devtools emulation for mobile rendering of the onboarding and privacy screens; a real iPhone pass is the formal pilot acceptance.
- **PRINT-02 hard pass (Phase 5 pilot).** Carried forward from Plan 03-02; the onboarding flow does not change this status.
- **Anthropic Console URL rot risk.** If Anthropic ever moves the sign-up entry point, the `ANTHROPIC_CONSOLE_URL` constant is the single edit site. Re-verify pre-pilot.

## Self-check: PASSED

- `index.html` updated: new constants, helpers, handlers, DOM sections, render cases, hideAllSections sweep, footer link, controls-bar link. Verified by Task 5 integration checks.
- `.planning/REQUIREMENTS.md` updated: TRUST-05 amended; zero remaining `Gemini` references. Verified by Task 4 checks.
- `README.md` updated: new `First-visit onboarding` section referencing the Anthropic Console URL and the storage key. Verified by Task 4 checks.
- All four task commits exist (`3a10776`, `6504fa7`, `5038cbd`, `086af2e`); confirmed via `git log`.
- `verify-no-mic.ps1` exits 0 on the final state.
- CSP meta tag unchanged: only `api.anthropic.com` in `connect-src`.
- Zero `.innerHTML =` assignments in `index.html`.
- Zero em / en dashes anywhere in `index.html`, REQUIREMENTS.md, or README.md.
- TRUST-03 satisfied: privacy page covers no-backend, no-analytics, no-third-party-scripts, no-microphone-ever (Article 179bis), no cookies, what stays local, what is sent on each Generate, and links the Anthropic privacy policy.
- TRUST-05 satisfied: first-visit onboarding screen explains the BYO Anthropic API key model and links to `https://console.anthropic.com`.
