---
phase: 01-skeleton-state-key-constants
plan: 01
subsystem: app-skeleton
tags: [skeleton, csp, byok, localstorage, trust-04]
requires: [anthropic-direct-browser-fetch-confirmed]
provides:
  - v1-index-html-at-repo-root
  - appstate-setstate-render-pattern
  - byo-anthropic-key-flow
  - localstorage-key-namespace-migrationsamt
  - csp-locked-to-anthropic-origin
  - mic-guardrail-script
affects:
  - index.html
  - README.md
  - verify-no-mic.ps1
tech_stack_added: []
patterns:
  - single-file inline HTML/CSS/JS app at repo root
  - appState plain object plus setState plus render() with hidden-attribute screen swap
  - localStorage BYO key with try/catch and namespaced key
  - strict meta CSP with connect-src locked to one origin
  - PowerShell Select-String grep guard for forbidden APIs
key_files_created:
  - index.html
  - README.md
  - verify-no-mic.ps1
key_files_modified: []
decisions:
  - "Shipped CSP verbatim from PLAN <csp_meta_verbatim>; connect-src is exactly https://api.anthropic.com"
  - "Mask format: first 7 chars + '...' + last 4 chars (e.g. sk-ant-...abcd) via textContent"
  - "appState shape locked: { screen: 'key-entry' | 'ready', apiKey: string | null }"
  - "localStorage key: migrationsamt.anthropicKey (namespaced)"
  - "Clear button uses window.confirm(); Replace button skips confirmation"
metrics:
  completed_date: 2026-05-14
  tasks_completed: 1
  duration: "single session"
---

# Phase 1 Plan 1: Skeleton, State, and Key Handling Summary

**One-liner:** Stood up the v1 single-file app at `index.html` with a strict CSP locked to Anthropic, an `appState + setState + render` loop, the BYO Anthropic key paste/save/mask/clear/replace flow against `localStorage`, and a PowerShell mic guardrail script.

## What Was Built

Three files at the repo root, committed in a single atomic commit (`118083a`):

1. **`index.html`** — vanilla HTML with inline `<style>` and inline `<script>`. No build step, no CDN, no framework. Contains the CSP meta tag, both screens pre-rendered, and the full key flow.
2. **`README.md`** — live URL, spike URL, mic guardrail command, and the six known traps from researcher Section 8.
3. **`verify-no-mic.ps1`** — PowerShell `Select-String` against `index.html` and `spike/index.html` for the literal `getUserMedia`. Exits 1 on any match.

## Exact CSP shipped in the meta tag

```
default-src 'self';
connect-src https://api.anthropic.com;
script-src 'self' 'unsafe-inline';
style-src 'self' 'unsafe-inline';
img-src 'self' data:;
font-src 'self';
form-action 'none';
base-uri 'self';
object-src 'none';
```

`connect-src` is exactly one origin so Phase 2 can call Anthropic with zero CSP edits. `frame-ancestors`, `report-uri`, and `sandbox` are deliberately omitted (meta CSP cannot enforce them) and that fact is documented in an HTML comment above the tag.

## Final appState shape

```javascript
const appState = {
  screen: 'key-entry',  // 'key-entry' | 'ready'
  apiKey: null,         // raw key, in memory only, never put into innerHTML
};
```

`setState(partial)` calls `Object.assign(appState, partial)` then `render()`.

`render()` branches on `appState.screen`:

- **`'key-entry'`**: section `#keyEntry` visible, section `#ready` hidden, any inline error on `#keyEntryError` is cleared.
- **`'ready'`**: section `#keyEntry` hidden, section `#ready` visible, `#maskedKey.textContent = maskKey(appState.apiKey)`.

Both sections are pre-rendered in HTML with the `hidden` attribute flipped by `render()`. No `innerHTML` writes anywhere in the script.

## Masked-display format

`maskKey(key)` returns `(hidden)` when the key is missing or shorter than 12 chars, otherwise `key.slice(0, 7) + '...' + key.slice(-4)`. For Anthropic keys this produces the documented `sk-ant-...abcd` shape and is written to the DOM via `textContent` only.

## Key-flow behavior

- **Save:** trims input, refuses empty, writes to `localStorage.setItem('migrationsamt.anthropicKey', key)` inside try/catch, clears the input field to avoid leaving the raw key in the DOM, then `setState({ apiKey, screen: 'ready' })`.
- **Reload after Save:** `DOMContentLoaded` reads `localStorage.getItem('migrationsamt.anthropicKey')`, populates `appState.apiKey`, sets `screen: 'ready'`, and `render()` shows the masked form.
- **Clear:** `window.confirm()` with the planned prompt; on yes, `localStorage.removeItem(...)` (best effort) then `setState({ apiKey: null, screen: 'key-entry' })`.
- **Replace:** swaps to `key-entry` without confirmation and without removing the stored key; the user must click Save again to overwrite.
- **localStorage blocked:** every call is wrapped in try/catch. Save shows the inline "Your browser is blocking local storage…" error and refuses to advance.

## Privacy rules enforced in code

- The `apiKey` variable is never passed to any `console.*` call.
- The `apiKey` is never assigned to `innerHTML`/`outerHTML` anywhere.
- After save, the password input is cleared so the raw key does not linger in the DOM.
- The masked display uses `textContent` only.

## TRUST-04: lifetime mic guardrail

`verify-no-mic.ps1` greps `index.html` and `spike/index.html` for the literal `getUserMedia`. Confirmed run on the committed source:

```
PS> powershell -File ./verify-no-mic.ps1
verify-no-mic: no matches. OK.
EXIT=0
```

The string `getUserMedia` appears zero times in `index.html`. The CSP `default-src 'self'` plus the absence of `getUserMedia` from source means the app cannot silently gain microphone access without a deliberate source edit.

## Automated verify output

The 22-check Node script in `<verify><automated>` returns exit code 0 with all checks `true`:

```
hasCspMeta, cspConnectAnthropic, cspDefaultSelf, cspObjectNone,
hasPasswordInput, hasMaskKeyFn, hasSetState, hasRender, hasAppState,
hasStorageKey, hasSetItem, hasGetItem, hasRemoveItem,
hasTextContentMasked, noInnerHtmlOnKey, noConsoleLogKey,
noGetUserMedia, noCdnScript, hasReadmeLive, hasReadmeMicCmd,
verifyScriptScansHtml, verifyScriptExitsNonZero  -> all true
EXIT=0
```

## Deviations from plan

None. The UI copy is verbatim from `<ui_copy_verbatim>`. The CSP is verbatim from `<csp_meta_verbatim>`. The `appState` shape and `maskKey` implementation match the `<interfaces>` block exactly. The PowerShell script matches the action-block template. The README contains the six known traps from researcher Section 8 verbatim in intent.

## Beginner traps actually encountered

None during execution. The CSP and inline-script tradeoff was settled by the planner (`'unsafe-inline'` for v1) so there was no fight with DevTools. Manual Chrome smoke test was not run by the executor because the agent runs headless on Windows; Francisco should open the file in desktop Chrome and confirm:

1. The key-entry screen renders with no console errors and no CSP-violation errors.
2. Pasting a fake key like `sk-ant-test-1234567890abcd` and clicking **Save key** swaps to the ready screen and shows `sk-ant-...abcd`.
3. Reloading keeps the user on the ready screen with the same masked form.
4. **Replace key** swaps back to key-entry without removing localStorage.
5. **Clear key** + confirm removes the `migrationsamt.anthropicKey` entry (DevTools > Application > Local Storage) and swaps back.

## Self-Check: PASSED

Files verified present:
- `index.html` FOUND
- `README.md` FOUND
- `verify-no-mic.ps1` FOUND

Commit verified:
- `118083a` FOUND in `git log --oneline`
