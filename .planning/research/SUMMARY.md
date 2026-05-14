# Research Summary, Migrationsamt Zürich Call Helper

**Synthesised:** 2026-05-14
**Sources read:** PROJECT.md, STACK.md, FEATURES.md, ARCHITECTURE.md, PITFALLS.md
**Overall confidence:** HIGH on stack and architecture, HIGH on Zürich-factual content, MEDIUM on real-user behaviour (no pilot yet), MEDIUM on production CORS (must be spike-validated).

## Top Findings

1. **A single `index.html` is the correct shape.** All four researchers converge: one file, inline `<style>` and `<script>`, vanilla JS, no build, no framework, no TypeScript. Matches the workspace convention and the developer's skill level. Expected size ~800-1500 lines.
2. **The CORS question is load-bearing and must be resolved in a 30-minute Phase 0 spike.** STACK is optimistic (both providers support direct browser calls in 2026). PITFALLS is more cautious (recent forum reports say OpenAI still blocks browser-origin `fetch`; Gemini's REST endpoint is reliable but the OpenAI-compatibility shim is flaky). The zero-backend architecture stands or falls on this. Do not write a single prompt before the spike returns green.
3. **The cheat sheet is the entire product.** Not a chat, not a flow, a generated A4/phone document held during the call. Its anatomy is locked (Blocks A-H, see below). Print CSS is a real requirement, not polish.
4. **Trust calibration is the hardest design problem, not engineering.** The user is in a vulnerable moment with a state authority. Polished German + tidy layout signals "I'm correct," which is dangerous if the LLM hallucinated. Back-translation, hardcoded contact details, structured permit selector, pinned escape phrases, non-dismissable disclaimer all exist to counter over-trust.
5. **Hardcode every fact, generate only the language.** Phone, address, hours, permit codes, holiday closures, all constants. The LLM produces German linguistic content only. Any prompt asking the LLM to "include the office contact" is a bug.
6. **Gemini first, OpenAI second.** Gemini's free tier (1,500 RPD, no credit card) is the difference between "a non-technical friend can use this" and "they bounce at signup."
7. **Ship English end-to-end before adding ES and PT.** Triple the surface area only after the core pipeline (intake → prompt → LLM → JSON → render → print) works for one language.

## Locked Stack Decisions (promote to PROJECT.md Key Decisions)

| Decision | Rationale |
|----------|-----------|
| Single `index.html`, inline CSS and JS | Matches workspace pattern; beginner-friendly; no build step |
| Vanilla JS only, no framework, no TypeScript | Stated constraint; app too small to benefit |
| Direct browser `fetch` to LLM provider, no backend, no SDK | Preserves zero-cost hosting and privacy; REST shape ~20 lines |
| Gemini 2.5 Flash default, OpenAI (gpt-4o-mini or gpt-5-mini) as toggle | Free tier removes credit-card barrier |
| BYO key in `localStorage` (plain), with "Clear key" button | Persistence without re-paste; sessionStorage adds friction with no real security gain |
| Structured JSON output from LLM, rendered to DOM via `textContent` | Full control of print layout; avoids XSS |
| Single `appState` + `setState()` + `render()` pattern | Same shape as Sector Rojo's `gameState` |
| Strict CSP `default-src 'self'`, zero third-party scripts at runtime | Protects API key. Note: marked.js / DOMPurify (recommended by STACK) are dropped in favour of pure JSON-to-DOM rendering, see Disagreement #1 |
| Hosting: Netlify Drop for v1, GitHub Pages as Git-friendly alternative | Both free, HTTPS, beginner-friendly |
| Hardcoded factual constants for Migrationsamt | Eliminates hallucination class of pitfalls |
| Microphone access permanently out of scope | Art. 179bis StGB; applies to all current and future phases |

## Recommended Phase Structure

### Phase 0, CORS & Provider Spike (riskiest first, ~30 min to 2 hours)
**Why first:** If direct browser calls don't work from the deployed origin, the whole architecture changes.
**Deliverable:** Single static HTML deployed to the real production host, making a successful `fetch` to both Gemini and OpenAI from a real key, on Chrome and iOS Safari.
**Exit criterion:** Documented evidence of two successful round-trips. If failed, switch to Plan B (Cloudflare Workers proxy) and document deviation before Phase 1.
**Pitfalls covered:** #6.

### Phase 1, Skeleton, State, and Key Handling
**Why next:** Backbone that everything else hangs from; unblocker for Phase 2.
**Includes:** HTML screens; `appState` + `setState` + `render`; Settings screen (paste key, pick provider, password-type field, "Clear key"); strict CSP meta tag; hardcoded constants file (Migrationsamt contact + 2026 holidays).
**Pitfalls covered:** #1, #7, #13.

### Phase 2, LLM Round-Trip (English, JSON contract, error handling)
**Why next:** Highest technical risk after CORS. Locks the JSON schema the renderer depends on.
**Includes:** `PROMPTS` object with system + EN user template; structured permit selector + curated topic picker; `callLLM` / `callOpenAI` / `callGemini` `fetch` wrappers; JSON parse with code-fence stripping + schema validation; loading screen; friendly errors for 401/429/500/SyntaxError; prompt explicitly forbids contact-detail generation and strategic/legal advice.
**Pitfalls covered:** #2, #5, #11, #12.

### Phase 3, Cheat Sheet Rendering, Print, Mobile, Onboarding
**Includes:** Render functions for Blocks A-H; two-column DE/native with back-translation everywhere; `@media print` for A4 + US Letter; mobile single-column; pinned escape phrases on every sheet; non-dismissable disclaimer; first-visit onboarding ("Get a free Gemini key" with screenshots); demo cheat sheet visible without a key; privacy page (revFADP-aware); consent checkbox before first generation.
**Pitfalls covered:** #3, #4, #8, #14, #15, #16, #17.

### Phase 4, Multilingual Intake (ES + PT)
**Why later:** Duplicate only after EN pipeline is proven end-to-end.
**Includes:** Per-language `userTemplate`; UI string translations via `const ui = { en, es, pt }`; language toggle.

### Phase 5, First Real-User Pilot & Prompt Tuning
**Why last:** Irreplaceable validation loop; no public post-mortems exist for this niche.
**Includes:** Pre-call walkthrough; observe/debrief; update topic-specific question banks with real officer questions; tune phrasebook; iterate system prompt against adversarial inputs.
**Pitfalls covered:** #10, #15.

### Deferred to v1.x / v2
Audio playback, QR handoff, saved-sheets list, post-call reflection, other cantons, other languages, live AI interpreter (subject to Art. 179bis review).

## Critical Pitfalls to Address Up Front (Phase 0 / Phase 1, before any prompt)

1. **Phase 0 CORS spike**, load-bearing.
2. **Contact details as hardcoded constants**, phone, address, hours, holidays live in exactly one file; greppable; LLM never sees them as a generation target.
3. **Structured permit selector, not free text**, `<select>` with L/B/C/Ci/G/N/F/S/"I don't know"; permit code is required structured input, ground truth.
4. **Strict CSP + zero third-party scripts at runtime**, `default-src 'self'; connect-src 'self' https://generativelanguage.googleapis.com https://api.openai.com`. Self-host all assets.
5. **Key handling discipline**, `localStorage` only, never in URL, `type="password"`, masked after save, one-click "Clear key".
6. **Microphone permanently disallowed**, codebase grep must show zero `getUserMedia({ audio: true })` forever. Roadmap-level guardrail.
7. **Non-dismissable disclaimer + pinned escape phrases at the top of every cheat sheet**, Phase 3 design constraint.

## Cheat Sheet Anatomy (locked)

Blocks A through H, top to bottom, every time:
- **A. Call Header**, office name + phone + best call window + today's goal (user lang) + user reference data
- **B. Opening Script**, Grüezi greeting + Hochdeutsch-request line (critical: officers default to Swiss German) + reason for call + reference number; each German line with native-language gloss directly underneath
- **C. Likely Officer Questions & Suggested Answers**, two-column DE/native, with both affirmative and negative answer forms so the user picks live
- **D. Panic Phrases**, repeat, slower, send-by-email, "I don't understand X", "I understood, thank you", Auf Wiederhören
- **E. Vocabulary Mini-Glossary**, 6-12 domain words with article + translation
- **F. Prep Checklist**, documents, phone charged, pen, sheet open
- **G. Note-Taking Lines**, printable only; officer name, next step, date, ref number, other
- **H. Footer Safety Notice**, "preparation aid, not legal advice" + escalation links (Welcome Desk, MIRSAH, Solinetz)

**LLM-generated:** B (custom sentence + ref number), C, E, F (personalisation), part of A (today's goal)
**Hardcoded:** A (contact + hours), D, G, H
**Resilience:** static blocks render even if the LLM call fails, a partial cheat sheet is still useful.

## Open Questions for Phase-Specific Research

| Question | Phase to resolve | Why deferred |
|---|---|---|
| Does Gemini 2.5 Flash produce high-quality German bureaucratic vocabulary, or is Pro required? | Phase 2 | Needs real prompt test against real intake |
| Streaming vs single-response for a 10-30s generation? | Phase 2 | Decide once first generation runs and we feel the wait |
| Per-session vs persistent key (paranoid mode toggle)? | Phase 3 | Best made after onboarding copy exists |
| Demo cheat sheet: real generated example or static fixture? | Phase 3 | Affects onboarding flow |
| What does the Migrationsamt officer actually ask first on a routine permit call? | Phase 5 | Only answerable from a real pilot call |

## Sources of Disagreement / Trade-offs

**1. marked.js + DOMPurify vs pure JSON-to-DOM.** STACK recommends loading marked.js + DOMPurify from CDN. ARCHITECTURE recommends pure JSON output rendered with `createElement` + `textContent`. PITFALLS recommends strict CSP with zero third-party scripts (CDN script can read localStorage and exfiltrate the key). **Resolution:** Go with ARCHITECTURE + PITFALLS. No CDN scripts. Force JSON output, render explicitly. CSP and key-safety wins outweigh marked.js convenience. If markdown rendering is ever needed later, vendor locally and pin the version.

**2. How confident to be about browser-direct LLM calls.** STACK is HIGH confidence both providers work since early 2024. PITFALLS is MEDIUM, citing recent forum reports of OpenAI still blocking despite `dangerouslyAllowBrowser`. **Resolution:** Run the Phase 0 spike. If both work, STACK is vindicated. If not, fall back to PITFALLS Plan B (Cloudflare Workers proxy, ~30 lines, no logging). No architecture decisions get locked in before the spike returns evidence.

**3. Saving past cheat sheets to localStorage.** FEATURES lists it as a v1 differentiator. ARCHITECTURE and PITFALLS say no, sensitive content, regenerate on demand, data minimisation is the strongest revFADP posture. **Resolution:** Architecture/Pitfalls win. Persist only the API key and structured intake answers. Cheat sheet stays in memory; v1.x "Export to file" flow can include it as an explicit user-initiated download.

**4. Streaming vs single-response.** STACK and ARCHITECTURE lean single-response for simplicity. PITFALLS flags a 10-30s wait with no feedback as a real UX risk. **Resolution:** Single response in Phase 2 with honest "Generating your cheat sheet, this takes 10-20 seconds" + rotating reassurance every 5s. Add streaming in v1.x only if real-user pilot shows abandonment.
