# Stack Research

**Domain:** Single-page browser tool (BYOK LLM client) for cantonal-immigration call preparation
**Researched:** 2026-05-14
**Confidence:** HIGH for the constrained stack, MEDIUM for pricing (LLM prices shift quarterly)

---

## TL;DR for a Beginner

Build one `index.html` file. Inline `<style>` and `<script>`. No npm, no build, no framework.
For the LLM, support **Gemini first** (free tier, no card required) and **OpenAI second**
(better quality, costs cents but the user pays). Both providers allow direct browser calls
in 2026, so a "pure frontend" app actually works.
Host on **Netlify drop** (drag-and-drop, no Git needed) or **GitHub Pages** if you want a Git workflow.
Add **marked.js** from a CDN only if the LLM returns markdown you want to render as HTML.
Everything else (printing, layout, language selection) is plain HTML and CSS.

---

## Recommended Stack

### Core Technologies

| Technology | Version | Purpose | Why Recommended |
|------------|---------|---------|-----------------|
| HTML5 | living standard | Document structure, semantic tags (`<form>`, `<details>`, `<dialog>`) | Native, zero deps, matches your other projects |
| CSS3 + `@media print` | living standard | Layout, print stylesheet, mobile responsive | Native printing without a PDF library |
| Vanilla JavaScript (ES2022+) | ES2022 baseline | App logic, fetch calls, localStorage | All modern browsers (2022+) support `fetch`, `async/await`, optional chaining, `?.`, top-level `await` in modules. No transpilation needed. |
| `fetch()` API | native | LLM HTTP calls | Built into every browser. No SDK needed. |
| `localStorage` | native | Persist API key + last cheat sheet between visits | Synchronous, simple key/value. Perfect for a BYOK app. |

### LLM Providers (Recommended Order)

| Provider | Model (2026) | Free Tier? | Cost (paid) | Why |
|---|---|---|---|---|
| **Google Gemini** (primary) | `gemini-2.5-flash` | Yes — 1,500 requests/day, 15 RPM, no credit card | Free for most users | Free tier covers the whole project for a single early user. No card barrier. Generous free quota even after Google's Dec 2025 cut. |
| **OpenAI** (secondary) | `gpt-5-mini` or `gpt-4o-mini` | No (pay-as-you-go) | gpt-4o-mini: $0.15 / $0.60 per 1M tokens; gpt-5-mini: $0.25 / $2.00 per 1M tokens | Higher quality on multilingual tasks. A single cheat sheet generation is roughly 1–3k input + 1k output tokens — about **$0.001–$0.003 per call** on gpt-4o-mini. Practically free for the user. |

**Recommendation:** Ship with Gemini as the default. Add an OpenAI option in the same dropdown — both use almost identical request shapes, so it is one extra `if` branch.

### Direct Browser API Calls (this is the load-bearing finding)

Both providers DO support direct browser `fetch` calls in 2026:

- **OpenAI** enabled CORS on `https://api.openai.com/v1/chat/completions` in early 2024.
  The official OpenAI JS SDK requires a `dangerouslyAllowBrowser: true` flag — the flag
  exists precisely because direct calls work technically. The "dangerous" warning is about
  exposing **your** key in a public site, which does not apply when the **user pastes their own key**.
- **Gemini** explicitly supports `x-goog-api-key` header from browser JavaScript per Google's
  own docs: "If you're using the REST API, or JavaScript on the browser, you will need to
  provide the API key explicitly." Same key-exposure caveat, same BYOK answer.

You do not need a backend. You do not need a relay. You do not need an SDK — just `fetch`.

**Many older blog posts and forum threads claim CORS is blocked.** They are stale (pre-2024)
or about other endpoints (Dashboard, login). Verify with a one-line `fetch` call from a local
HTML file before trusting any third-party article.

### Supporting Libraries (CDN, no npm)

| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| **marked.js** (UMD) | latest from jsDelivr | Convert LLM markdown output to HTML | If you prompt the LLM to return markdown (headers, bullet lists, bold). ~30 KB minified. Single `<script>` tag. |
| **DOMPurify** | latest from jsDelivr | Sanitize HTML before injecting into the page | Pair with marked.js. The LLM response is untrusted-ish input; never `innerHTML` it raw. ~20 KB. |

That is the entire third-party surface. Two CDN scripts.

```html
<script src="https://cdn.jsdelivr.net/npm/marked/marked.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/dompurify/dist/purify.min.js"></script>
```

### Hosting

| Option | Best For | Why |
|---|---|---|
| **Netlify Drop** (recommended) | Fastest path to a live URL | Drag the folder onto netlify.com/drop. Done. HTTPS included. Mobile-friendly. No Git needed. |
| **GitHub Pages** | If you want versioning | Free, HTTPS, custom domain support. Adds Git friction but matches your `pacomc999` workflow. |
| **Cloudflare Pages** | If you outgrow Netlify free tier | Generous limits, fastest CDN. Slight setup overhead. |

All three are fine. Netlify Drop is the most beginner-friendly: zero configuration, no CLI.
Vercel works too but is more oriented around Next.js — overkill here.

### Storing the User's API Key

**Use `localStorage`.** Not `sessionStorage`, not `IndexedDB`, not cookies.

Reasoning:
- `localStorage`: persists across visits, sync API, one line of code (`localStorage.setItem('key', value)`). The user pastes the key once, comes back next week, it is still there.
- `sessionStorage`: dies when the tab closes. Bad UX — user re-pastes the key every time.
- `IndexedDB`: async, complex API, total overkill for one string.
- Cookies: would be sent on every request to your origin. The browser stores it; you do not need to send it anywhere except the LLM provider.

**Security caveats to tell the user honestly:**
1. The key is stored in plaintext in their browser. Any other JavaScript running on the page
   (including any CDN script you add) could read it. Keep CDN dependencies minimal and pinned
   to a specific version when you scale up. For v1, two well-known libraries is fine.
2. If their machine is compromised, the key is exposed. Worth a one-line note in the UI:
   *"Your key is stored only in this browser. Revoke it in the OpenAI/Gemini dashboard if you stop using this site."*
3. **Do not** try to encrypt the key in localStorage with another key derived from a password —
   it adds friction without real security, since the decryption logic runs in the same browser.
4. Add a "Clear key" button. Maps to one line: `localStorage.removeItem('apiKey')`.

### Print-Friendly UI

Two CSS techniques cover this completely:

```css
/* Default: mobile-readable screen */
body { font-family: system-ui, sans-serif; max-width: 760px; margin: 0 auto; padding: 1rem; }

/* Print: clean A4 sheet */
@media print {
  @page { size: A4; margin: 1.5cm; }
  body { font-size: 11pt; color: #000; max-width: none; }
  .no-print { display: none; }            /* Hide buttons, inputs, language picker */
  h2, h3 { page-break-after: avoid; }     /* Don't strand a heading at page bottom */
  .section { page-break-inside: avoid; }  /* Keep "Vocabulary" or "Likely Questions" together */
}
```

Tag the form/buttons with `class="no-print"`, tag each cheat-sheet section with `class="section"`.
That is enough. Test by hitting Ctrl+P in Chrome — the preview shows exactly what prints.

Mobile readability: a single column, font-size at least 16px on screen, generous line-height (1.5),
no fixed widths. The same layout works on phone screens and prints cleanly to A4.

---

## Rationale Per Choice (Beginner-Friendly)

**Why no framework?**
React/Vue/Svelte exist to manage complex state across many components. This app has one screen,
one form, one output. A framework would force a build step, a node_modules folder, and concepts
(JSX, reactivity, hooks) you do not need. Vanilla JS with a few `addEventListener` calls and
`document.getElementById` is shorter and easier to debug.

**Why no TypeScript?**
TypeScript needs a compiler. That breaks the "one HTML file" promise. JSDoc comments give you
80% of the autocomplete benefit in VS Code if you want type hints — no compiler needed.

**Why Gemini first?**
The user can be a non-technical friend or family member. Asking them to "add a credit card to
OpenAI" is a real adoption barrier. Gemini's free tier ("1,500 requests/day, no card") removes
that entirely. OpenAI is the backup for power users who already have a key.

**Why both providers?**
Each has outage days. Each has different quality. Costs the developer nothing to support both
because the request shapes are similar enough that one `if/else` covers it.

**Why localStorage and not "more secure" options?**
The threat model is: *the user is the only person using this app on their device*. There is
no multi-user attack surface, no server to compromise. localStorage is the right tool. The
"localStorage is insecure" articles are about session tokens for SaaS apps, which is a totally
different scenario.

**Why marked.js + DOMPurify and not raw HTML?**
LLMs produce nicely structured markdown when you ask them to. Rendering markdown in vanilla
JS by hand is fiddly (lists, emphasis, code spans). marked.js turns a string into HTML in one
call. DOMPurify protects against an edge case where the LLM emits a `<script>` tag in its
output (unlikely but cheap insurance).

---

## What to Skip (Anti-Recommendations)

| Avoid | Why | Use Instead |
|-------|-----|-------------|
| React / Vue / Svelte | Forces a build system, contradicts the single-file pattern | Vanilla JS with `addEventListener` |
| TypeScript | Needs a compiler, breaks the "open the HTML file" workflow | JSDoc comments for IDE hints |
| OpenAI / Google official SDKs (`openai`, `@google/genai`) | They are npm packages and assume Node/bundler. The browser builds add weight and force the SDK's opinions on you. | Plain `fetch()` — both providers have a documented REST shape that fits in 20 lines of JS |
| Backend proxy (Express, Vercel functions, Cloudflare Workers) | Breaks the zero-hosting-cost and privacy promises. The whole reason BYOK exists is to avoid this. | Direct browser `fetch` to provider — works thanks to CORS being enabled |
| `dangerouslyAllowBrowser` via the OpenAI SDK | Pulls in the SDK, which you do not need | `fetch('https://api.openai.com/v1/chat/completions', {...})` |
| OAuth / Google sign-in for API keys | Adds a backend requirement, defeats BYOK | Plain text field where user pastes the key |
| Web Crypto API to "encrypt" the localStorage key | Theatrical security — the decryption code runs in the same JS context | Just store it in plaintext, add a Clear button |
| IndexedDB for the API key | Async, verbose API, total overkill for one string | `localStorage` |
| PDF generation libraries (jsPDF, html2pdf) | Hundreds of KB, complicates layout. Browsers already generate PDFs from print. | `window.print()` + `@media print` CSS — user picks "Save as PDF" |
| i18n libraries (i18next, Polyglot) | Designed for dozens of strings across components. You have ~30 UI strings in 3 languages. | A plain object: `const ui = { en: {...}, es: {...}, pt: {...} }` |
| Service workers / offline / PWA | Adds complexity. The whole app requires an LLM API call to be useful — there is nothing meaningful to do offline. | Skip entirely for v1 |
| Analytics (GA, Plausible, etc.) | Contradicts the "no analytics, no logs" privacy promise in PROJECT.md | Nothing. Ask the first user directly. |
| Auto rate-limit logic / token counting libs | Premature for v1. Free tiers are generous; one user makes one call per situation. | If a 429 comes back, show a friendly message: "Provider rate limit hit, wait a minute." |

---

## Installation

There is no install step. Project layout:

```
inmigration-tool/
  index.html          # Everything: <style>, <script>, markup
  README.md           # How to use
  (optional) assets/  # Favicon, icon
```

For local dev, just double-click `index.html`. If `fetch` to LLM fails with a `file://` origin
issue on a specific browser, run:

```bash
python -m http.server 8000
# then open http://localhost:8000
```

To deploy: drag the folder onto https://app.netlify.com/drop.

---

## Alternatives Considered

| Recommended | Alternative | When to Use Alternative |
|-------------|-------------|-------------------------|
| Gemini 2.5 Flash | Gemini 2.5 Pro | If output quality on German legal/bureaucratic terms is poor with Flash. Pro has stricter free limits. |
| OpenAI as secondary | Anthropic Claude as secondary | Anthropic CORS support is patchier (byok-relay's existence suggests issues). Reconsider in 6 months. |
| `fetch()` direct | OpenAI/Google JS SDK | If you ever add features like streaming with auto-reconnect or function calling, the SDK saves time. Not for v1. |
| Netlify Drop | GitHub Pages | When you have a Git workflow you want preserved. |
| localStorage | sessionStorage | If you have a strong reason to force the user to re-paste the key every session. Almost never. |
| marked.js | Roll your own minimal markdown parser | If your prompt restricts the LLM to only `**bold**`, `# header`, `- list` you could parse it in 30 lines. Saves ~30 KB. Worth it only if you really want zero CDN deps. |

---

## Version Compatibility

| Component | Constraint | Note |
|-----------|-----------|------|
| Browsers | Chrome 90+, Firefox 90+, Safari 14+, Edge 90+ | Covers >98% of users. All have CORS, `fetch`, `localStorage`, `@media print`. |
| marked.js | v9+ | Uses ES2018+ syntax, fine for target browsers |
| Gemini API | `v1beta` | Stable as of 2026-05; model name `gemini-2.5-flash` |
| OpenAI API | `v1/chat/completions` | The classic Chat Completions endpoint. (The newer Responses API exists but Chat Completions is simpler for one-shot text generation.) |

---

## Open Questions (Surface These in Phase 1)

1. **Output quality of Gemini Flash on Standard German bureaucratic vocabulary** —
   needs a real prompt test before locking it as default. Pro might be required.
2. **Should the user provide their key per-session or once?** UX choice: paranoid mode
   (sessionStorage) vs convenience (localStorage). Recommend defaulting to localStorage
   with a clearly labeled "Forget key on close" checkbox that switches to sessionStorage.
3. **Streaming vs single response?** Streaming makes the first 200ms feel faster but adds
   parsing complexity. For a cheat sheet (not a chat), a single response is fine.
4. **Token budget per call?** Sketch the worst-case prompt to confirm it fits well under
   model context limits (it will — cheat sheets are short).
5. **Error handling for 401 (bad key) vs 429 (rate limit) vs 500 (provider down)** — design
   three friendly error messages in all three input languages.

---

## Sources

- [OpenAI API Pricing 2026 (pricepertoken.com)](https://pricepertoken.com/pricing-page/provider/openai) — gpt-4o-mini and gpt-5-mini costs
- [OpenAI Developer Community: CORS thread](https://community.openai.com/t/cross-origin-resource-sharing-cors/28905) — confirms CORS enabled on `/v1/chat/completions` since early 2024 (HIGH)
- [Gemini API Free Tier 2026 (TokenMix)](https://tokenmix.ai/blog/gemini-api-free-tier-limits) — 1,500 RPD, 15 RPM, no card (MEDIUM, cross-checked with Google's docs)
- [Google AI: Using Gemini API keys](https://ai.google.dev/gemini-api/docs/api-key) — explicitly supports browser JS with `x-goog-api-key` header (HIGH)
- [Google AI: Gemini API rate limits](https://ai.google.dev/gemini-api/docs/rate-limits) — official limit table (HIGH)
- [marked.js (markedjs.org)](https://marked.js.org/) — UMD CDN distribution (HIGH)
- [MDN: CSS Printing](https://developer.mozilla.org/en-US/docs/Web/CSS/CSS_media_queries/Printing) — `@media print`, `@page`, `page-break-*` (HIGH)
- [Auth0: Secure Browser Storage](https://auth0.com/blog/secure-browser-storage-the-facts/) — localStorage vs sessionStorage tradeoffs (MEDIUM)
- [avikalpg/byok-relay](https://github.com/avikalpg/byok-relay) — confirms some providers (Anthropic) still block CORS, validating the recommendation to stick with OpenAI/Gemini (MEDIUM)

---
*Stack research for: BYOK browser-only LLM cheat-sheet tool, Swiss canton Zürich immigration*
*Researched: 2026-05-14*
