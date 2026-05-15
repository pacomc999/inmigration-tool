# Migrationsamt Zürich Call Helper

A single-page browser tool that helps non-German speakers in canton Zürich prepare for a phone call to the Migrationsamt. The user describes their situation, and the tool generates a tailored German cheat sheet they keep in front of them while making the call themselves.

The app runs entirely in the browser. The user brings their own Anthropic API key. No backend, no logging, no accounts.

## Live URLs

- v1 app: https://pacomc999.github.io/inmigration-tool/
- Phase 0 spike (kept as historical artifact): https://pacomc999.github.io/inmigration-tool/spike/

Each real generation costs roughly USD 0.01 against `claude-haiku-4-5` (about 1500 input tokens and 1200 output tokens, per the AI provider's published pricing as of 2026-05-14).

If the AI service returns a 404 from the messages endpoint, the model id may have been retired. Update `ANTHROPIC_API.model` in `index.html` and consult the AI provider's model deprecation page.

## Platform scope

v1 targets desktop Chrome only (per Phase 0 decision D-05). iOS Safari and mobile are out of scope until v2.

## Run the mic guardrail before every commit

This project must never call `getUserMedia` (TRUST-04, tied to Art. 179bis StGB). A PowerShell script at the repo root enforces this by grepping the source. Run it before every commit:

```powershell
powershell -File .\verify-no-mic.ps1
```

Expected output: `verify-no-mic: no matches. OK.` and exit code 0. Any other output is a violation and must block the commit.

## Known traps

Six things that bite beginners working on this project. Keep this list in mind.

1. **CSP and `'unsafe-inline'`.** The single-file pattern forces `script-src 'self' 'unsafe-inline'` and `style-src 'self' 'unsafe-inline'`. Do not try to harden with nonces or hashes without a build system; the hash has to change every time the script changes, and the page silently breaks when it does not match. Look for "Refused to execute inline script because it violates the following Content Security Policy directive" in DevTools.

2. **GitHub Pages caching during development.** Pages caches at the CDN and the browser. A hard reload does not always evict the CDN cache for several minutes. During iteration, append a query string like `?v=2` to bypass it, or open `index.html` from disk via `file://` for the fastest feedback.

3. **localStorage on private browsing.** Some browser modes zero out localStorage quota and throw `QuotaExceededError` on `setItem`. The app wraps every `localStorage` call in try/catch and shows an inline error, but the failure mode is silent if the catch is missing. Keep the try/catch.

4. **`<meta>` CSP cannot do `frame-ancestors`, `report-uri`, or `sandbox`.** These directives are silently ignored when set via meta. Do not add them; they give a false sense of security. They would require HTTP headers, which GitHub Pages does not let us set.

5. **Hardcoded constants drifting out of date.** Migrationsamt phone, hours, and 2026 holidays are hardcoded constants. The LLM is permanently forbidden from generating contact info. Re-verify these facts against zh.ch before any pilot launch and annually thereafter.

6. **Accidental third-party CDN.** Vanilla HTML, CSS, and JS only. No npm, no build step, no CDN script tags. If a feature genuinely needs a small library, copy the file into the repo and serve it self-hosted under `'self'`. v1 needs no libraries.

## Mock fixtures (dev only)

Two URL flags short-circuit the real AI service call so you can iterate on the UI without burning API tokens or waiting 10 to 20 seconds per click.

- `?mock=1` returns a hardcoded cheat sheet fixture (`MOCK_CHEAT_SHEET` inside `index.html`) after a short simulated delay. The result screen renders Blocks B, C, E, and F from the fixture. Useful for iterating on layout, styling, and screen transitions.
- `?mock=broken` returns a deliberately malformed JSON string. The parser fails and the app routes to the parse-error screen. Useful for sanity-checking the error path UI.

Open the file from disk with the flag appended, for example `file:///.../index.html?mock=1`. No real API call is made under either flag, and your saved API key is not touched.
