<!-- GSD:project-start source:PROJECT.md -->
## Project

**Migrationsamt Zürich Call Helper**

A single-page web tool that helps people in canton Zürich who do not speak German make better phone calls to the Migrationsamt (the cantonal migration office). The user describes their situation in English, Spanish, or Portuguese, and the tool generates a tailored German cheat sheet (key phrases, vocabulary, likely officer questions, and a prep checklist) that the user keeps in front of them while making the call themselves.

**Core Value:** Eliminate the language barrier moment when a non-German speaker has to call the Migrationsamt about their permit, so the call actually achieves what the user came to do.

### Constraints

- **Timeline**: The first real user should be using v1 for an actual call within this month
- **Tech stack**: Vanilla HTML, CSS, and vanilla JavaScript only. No frameworks, no build system, no TypeScript. Consistent with developer's other projects in this workspace
- **Budget**: Zero. No paid hosting, no paid APIs paid by the developer. User brings their own LLM API key
- **Privacy**: Immigration data is sensitive. Nothing leaves the user's browser except the single LLM API call to generate the cheat sheet. No analytics, no backend, no logs
- **Scope**: Canton Zürich only, three input languages only, one output language (German)
- **Legal**: The tool must not give legal advice, not impersonate the user, not contact authorities directly. It is a preparation aid, not a representative
<!-- GSD:project-end -->

<!-- GSD:stack-start source:research/STACK.md -->
## Technology Stack

## TL;DR for a Beginner
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
### Direct Browser API Calls (this is the load-bearing finding)
- **OpenAI** enabled CORS on `https://api.openai.com/v1/chat/completions` in early 2024.
- **Gemini** explicitly supports `x-goog-api-key` header from browser JavaScript per Google's
### Supporting Libraries (CDN, no npm)
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| **marked.js** (UMD) | latest from jsDelivr | Convert LLM markdown output to HTML | If you prompt the LLM to return markdown (headers, bullet lists, bold). ~30 KB minified. Single `<script>` tag. |
| **DOMPurify** | latest from jsDelivr | Sanitize HTML before injecting into the page | Pair with marked.js. The LLM response is untrusted-ish input; never `innerHTML` it raw. ~20 KB. |
### Hosting
| Option | Best For | Why |
|---|---|---|
| **Netlify Drop** (recommended) | Fastest path to a live URL | Drag the folder onto netlify.com/drop. Done. HTTPS included. Mobile-friendly. No Git needed. |
| **GitHub Pages** | If you want versioning | Free, HTTPS, custom domain support. Adds Git friction but matches your `pacomc999` workflow. |
| **Cloudflare Pages** | If you outgrow Netlify free tier | Generous limits, fastest CDN. Slight setup overhead. |
### Storing the User's API Key
- `localStorage`: persists across visits, sync API, one line of code (`localStorage.setItem('key', value)`). The user pastes the key once, comes back next week, it is still there.
- `sessionStorage`: dies when the tab closes. Bad UX — user re-pastes the key every time.
- `IndexedDB`: async, complex API, total overkill for one string.
- Cookies: would be sent on every request to your origin. The browser stores it; you do not need to send it anywhere except the LLM provider.
### Print-Friendly UI
## Rationale Per Choice (Beginner-Friendly)
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
## Installation
# then open http://localhost:8000
## Alternatives Considered
| Recommended | Alternative | When to Use Alternative |
|-------------|-------------|-------------------------|
| Gemini 2.5 Flash | Gemini 2.5 Pro | If output quality on German legal/bureaucratic terms is poor with Flash. Pro has stricter free limits. |
| OpenAI as secondary | Anthropic Claude as secondary | Anthropic CORS support is patchier (byok-relay's existence suggests issues). Reconsider in 6 months. |
| `fetch()` direct | OpenAI/Google JS SDK | If you ever add features like streaming with auto-reconnect or function calling, the SDK saves time. Not for v1. |
| Netlify Drop | GitHub Pages | When you have a Git workflow you want preserved. |
| localStorage | sessionStorage | If you have a strong reason to force the user to re-paste the key every session. Almost never. |
| marked.js | Roll your own minimal markdown parser | If your prompt restricts the LLM to only `**bold**`, `# header`, `- list` you could parse it in 30 lines. Saves ~30 KB. Worth it only if you really want zero CDN deps. |
## Version Compatibility
| Component | Constraint | Note |
|-----------|-----------|------|
| Browsers | Chrome 90+, Firefox 90+, Safari 14+, Edge 90+ | Covers >98% of users. All have CORS, `fetch`, `localStorage`, `@media print`. |
| marked.js | v9+ | Uses ES2018+ syntax, fine for target browsers |
| Gemini API | `v1beta` | Stable as of 2026-05; model name `gemini-2.5-flash` |
| OpenAI API | `v1/chat/completions` | The classic Chat Completions endpoint. (The newer Responses API exists but Chat Completions is simpler for one-shot text generation.) |
## Open Questions (Surface These in Phase 1)
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
<!-- GSD:stack-end -->

<!-- GSD:conventions-start source:CONVENTIONS.md -->
## Conventions

Conventions not yet established. Will populate as patterns emerge during development.
<!-- GSD:conventions-end -->

<!-- GSD:architecture-start source:ARCHITECTURE.md -->
## Architecture

Architecture not yet mapped. Follow existing patterns found in the codebase.
<!-- GSD:architecture-end -->

<!-- GSD:skills-start source:skills/ -->
## Project Skills

No project skills found. Add skills to any of: `.claude/skills/`, `.agents/skills/`, `.cursor/skills/`, `.github/skills/`, or `.codex/skills/` with a `SKILL.md` index file.
<!-- GSD:skills-end -->

<!-- GSD:workflow-start source:GSD defaults -->
## GSD Workflow Enforcement

Before using Edit, Write, or other file-changing tools, start work through a GSD command so planning artifacts and execution context stay in sync.

Use these entry points:
- `/gsd-quick` for small fixes, doc updates, and ad-hoc tasks
- `/gsd-debug` for investigation and bug fixing
- `/gsd-execute-phase` for planned phase work

Do not make direct repo edits outside a GSD workflow unless the user explicitly asks to bypass it.
<!-- GSD:workflow-end -->



<!-- GSD:profile-start -->
## Developer Profile

> Profile not yet configured. Run `/gsd-profile-user` to generate your developer profile.
> This section is managed by `generate-claude-profile` -- do not edit manually.
<!-- GSD:profile-end -->
