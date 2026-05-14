# Phase 1: Skeleton, State, Key Handling, Static Constants - Research

**Researched:** 2026-05-14
**Domain:** Vanilla single-file HTML app skeleton, browser-side state, localStorage key handling, strict CSP, hardcoded Migrationsamt facts
**Confidence:** HIGH (CSP behaviour, Migrationsamt contact, Anthropic CORS header); MEDIUM (2026 cantonal holiday list - cross-validated but two sources differ slightly on Berchtoldstag, see Section 4)

<user_constraints>
## User Constraints (from CONTEXT.md and STATE.md)

### Locked Decisions (binding from Phase 0 and STATE.md)

- **L-01:** v1 uses Anthropic Messages API only. No Gemini, no OpenAI, no provider toggle. [VERIFIED: 01-CONTEXT.md L-01, sourced from Phase 0 D-01]
- **L-02:** All Anthropic requests use the `anthropic-dangerous-direct-browser-access: true` header. [VERIFIED]
- **L-03:** Direct browser `fetch` to Anthropic. No backend, no proxy. [VERIFIED]
- **L-04:** API keys entered at runtime in a `type="password"` field. Never hardcoded. [VERIFIED]
- **L-05:** No third-party CDN scripts. No npm. Vanilla HTML/CSS/JS only, single-file inline. [VERIFIED]
- **L-06:** No microphone access ever. No `getUserMedia({ audio: true })` anywhere. Tied to Art. 179bis StGB. [VERIFIED]
- Single `appState + setState() + render()` pattern (same shape as Sector Rojo `gameState`). [STATE.md Locked Decisions]
- Strict CSP `default-src 'self'`, zero third-party scripts at runtime, self-host all assets. [STATE.md]
- BYO key in localStorage (plain), one-click Clear-key button, masked after save. [STATE.md]
- Hosting: GitHub Pages (per Phase 0 D-07). Netlify Drop is the fallback alternative.
- All Migrationsamt facts (phone, address, hours, 2026 holidays) are hardcoded constants; the LLM never generates contact info. [STATE.md]

### Claude's Discretion (per 01-CONTEXT.md)

1. File layout (single `index.html` vs `app/index.html` vs constants extracted to sibling `constants.js`).
2. Exact CSP meta-tag content (baseline + `connect-src` for Anthropic).
3. UI shape and copy for the key-entry screen and Clear-key button.
4. How `appState` / `setState` / `render` is structured.
5. Whether Phase 1 lives in `app/`, repo root alongside `spike/`, or replaces a different path.
6. Whether to amend REQUIREMENTS.md as part of this phase (drop KEY-04, amend SPIKE-01) or leave it to a follow-up housekeeping commit.

### Deferred Ideas (OUT OF SCOPE for Phase 1)

- Cheat sheet rendering, two-column DE/native layout, print stylesheet (Phase 3).
- LLM round-trip, intake form, JSON-schema parsing (Phase 2).
- Multilingual UI - ES, PT (Phase 4).
- iOS Safari and mobile testing (deferred to v2 per Phase 0 D-05/D-06).
- KEY-04 provider toggle (obsoleted by L-01 - to be dropped from REQUIREMENTS.md).
- Gemini / OpenAI integration of any kind.

</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| KEY-01 | User can paste their own API key and persist it in browser localStorage | Section 2 - localStorage pattern; Section 7 - UI copy |
| KEY-02 | User can clear their stored API key in one click | Section 2 - `removeItem` flow; Section 7 - Clear key copy |
| KEY-03 | API key input uses `type="password"` and is masked after save | Section 2 - masking pattern with last-4 display |
| KEY-04 | (OBSOLETE per L-01) Provider toggle Gemini/OpenAI | Drop from REQUIREMENTS.md as a planner deliverable |
| TRUST-04 | App never accesses microphone, ever (lifetime guardrail) | Section 1 - CSP excludes mic; Section 5 - grep enforcement |

</phase_requirements>

## Summary

Phase 1 is structural plumbing, not product features. The work is: stand up a single `index.html` at the repo root, lay down a strict CSP meta tag that allows exactly one outbound destination (`https://api.anthropic.com`), wire a tiny `appState + setState + render` loop modeled on Sector Rojo's `gameState`, build the BYO-key paste/save/mask/clear flow against `localStorage`, hardcode the Migrationsamt contact facts (phone, address, phone-service hours, 2026 holiday closures) plus the Block D panic phrases and Block H escalation links, and prove the lifetime mic guardrail via a grep that returns zero matches.

The riskiest tasks for a beginner are CSP fights with inline `<script>` and `<style>` (the chosen single-file pattern forces `'unsafe-inline'` on `script-src` and `style-src` unless we add hashes, which is over-engineering for v1), and getting the Migrationsamt phone/hours/holidays correct on the first try because the LLM is permanently forbidden from generating these. The Migrationsamt has an officially documented 2026 closure (Wed 13 May reduced hours, Thu 14 May Auffahrt closed) that confirms the data source is current.

**Primary recommendation:** Single `index.html` at repo root. Inline `<style>` and `<script>` per the workspace pattern. CSP allows `'self' 'unsafe-inline'` for scripts/styles (pragmatic, beginner-friendly, documented limitation) and `connect-src` locked to `https://api.anthropic.com`. Hardcode constants in a top-of-`<script>` `const MIGRATIONSAMT = {...}` object, not a separate file. Hold `appState` as a plain object; `setState(partial)` does `Object.assign` then calls `render()`; `render()` switches on `appState.screen` and writes via `textContent`/`value` only. Add a one-line PowerShell grep guard for `getUserMedia` and run it manually before each commit; skip precommit hooks for v1.

## Architectural Responsibility Map

| Capability | Primary Tier | Secondary Tier | Rationale |
|------------|-------------|----------------|-----------|
| Render key-entry UI | Browser DOM | - | Vanilla JS app, no SSR, no backend |
| Persist API key | Browser localStorage | - | BYOK, zero-backend posture |
| Hold session state | In-memory `appState` object | - | Per-page-load state, mirrors Sector Rojo pattern |
| Hardcoded Migrationsamt facts | Static JS constant | - | LLM is forbidden from generating these |
| CSP enforcement | HTML `<meta>` tag | - | No HTTP-header control on GitHub Pages |
| Mic guardrail | Source code (zero matches) | manual grep | No runtime check possible, only absence in source |

## 1. Strict Content Security Policy for a Vanilla Single-File App

### What goes in the meta tag

CSP via `<meta http-equiv="Content-Security-Policy" content="...">` works in all target browsers, but with three documented limitations: it cannot enforce `frame-ancestors`, `report-uri`/`report-to`, or `sandbox`. Those must come from an HTTP response header, which GitHub Pages does not let us set. We accept this and rely on `X-Frame-Options` not being in our control - the practical impact is that someone could iframe our site, but since we store nothing of value cross-origin and our only outbound destination is the user's own Anthropic key against `api.anthropic.com`, the clickjacking surface is minimal. [CITED: MDN Web Docs - Content-Security-Policy; OWASP CSP Cheat Sheet]

The single-file pattern (inline `<style>` and inline `<script>`) forces a choice on `script-src` and `style-src`: either `'unsafe-inline'` (easy, beginner-friendly, defeats one specific XSS class), or per-block hashes/nonces (correct, but requires recomputing the hash every time the script changes, which painful without a build step). For v1, `'unsafe-inline'` is the right tradeoff because (a) there is no LLM output being injected into the DOM in Phase 1, (b) all DOM writes go via `textContent` per L-05, and (c) the only outbound network destination is locked by `connect-src`. The XSS surface is essentially the developer typing a `<script>` into their own source file. [CITED: web.dev CSP article; OWASP CSP Cheat Sheet]

### Copy-pasteable CSP for v1

```html
<meta http-equiv="Content-Security-Policy" content="
  default-src 'self';
  connect-src https://api.anthropic.com;
  script-src 'self' 'unsafe-inline';
  style-src 'self' 'unsafe-inline';
  img-src 'self' data:;
  font-src 'self';
  form-action 'none';
  base-uri 'self';
  object-src 'none';
">
```

Line by line, beginner-friendly:

- `default-src 'self'` - everything not explicitly listed must come from this origin (GitHub Pages URL). Blocks every third-party load by default.
- `connect-src https://api.anthropic.com` - the ONLY destination `fetch()` is allowed to hit. No analytics endpoint, no error reporting service, nothing.
- `script-src 'self' 'unsafe-inline'` - allows the inline `<script>` block. Required for the single-file pattern. Documented compromise.
- `style-src 'self' 'unsafe-inline'` - allows the inline `<style>` block. Same reasoning.
- `img-src 'self' data:` - allows local images and inline `data:` URIs (useful if you ever want a small inline SVG icon, no external image hosts).
- `font-src 'self'` - no Google Fonts. System fonts only.
- `form-action 'none'` - no `<form>` can submit anywhere. We use buttons + JS, not form posts.
- `base-uri 'self'` - blocks `<base>` tag injection attacks.
- `object-src 'none'` - no plugins, no Flash, no embeds.

### What `<meta>` CSP cannot do

- `frame-ancestors` - must be an HTTP header. GitHub Pages does not let us set headers. We accept the residual clickjacking risk.
- `report-uri` / `report-to` - same reason, no reporting endpoint anyway given the privacy posture.
- `sandbox` - not needed for this app.

Mention these explicitly in a comment above the meta tag so future-Francisco does not waste time trying to add them and wondering why they are ignored.

**Planner recommendation:** Use the CSP block above verbatim, placed immediately after `<meta charset>` in `<head>`. Add a one-line HTML comment above it noting the three meta-CSP-unsupported directives.

Sources: [MDN: CSP](https://developer.mozilla.org/en-US/docs/Web/HTTP/Guides/CSP), [content-security-policy.com: meta tag example](https://content-security-policy.com/examples/meta/), [content-security-policy.com: frame-ancestors](https://content-security-policy.com/frame-ancestors/), [OWASP CSP Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Content_Security_Policy_Cheat_Sheet.html).

## 2. localStorage API Key Persistence Pattern

### The complete flow

1. On `DOMContentLoaded`, read `localStorage.getItem('migrationsamt.anthropicKey')`. If a string is present, set `appState.apiKey = stored` and `appState.screen = 'ready'`. If null, `appState.screen = 'key-entry'`.
2. `render()` for `'key-entry'`: show password input + Save button + helper copy. Input is empty (never pre-fill the actual key).
3. `render()` for `'ready'`: show masked key (e.g. `sk-ant-...abcd`), a Clear button, a "Replace key" button.
4. Save button click: read the input value, `localStorage.setItem('migrationsamt.anthropicKey', value)`, `setState({ apiKey: value, screen: 'ready' })`.
5. Clear button click: `localStorage.removeItem('migrationsamt.anthropicKey')`, `setState({ apiKey: null, screen: 'key-entry' })`.
6. Replace button click: same as Clear but goes back to key-entry without confirmation.

### Masking pattern

The mask should never echo the full key into the DOM, even momentarily. The DOM element shows only:

```javascript
function maskKey(key) {
  // Anthropic keys start with sk-ant- and are long. Show first 7 chars + last 4.
  if (!key || key.length < 12) return '(hidden)';
  return key.slice(0, 7) + '...' + key.slice(-4);
}
```

Then `displayEl.textContent = maskKey(appState.apiKey);`. Never `innerHTML`.

### localStorage key name

Use a namespaced key: `migrationsamt.anthropicKey`. The namespace matters because localStorage is shared across all pages on the same origin (`pacomc999.github.io`), so any other project Francisco eventually puts under that GitHub Pages account would otherwise collide.

### Edge cases

- **Stored value is empty string**: treat as not present. Check `if (stored && stored.trim()) {...}`.
- **localStorage throws** (private-browsing mode on some browsers): wrap in try/catch. On failure, render an error: "Your browser is blocking localStorage. The app needs it to remember your key between visits. Try a normal browser window." This is a Phase 3+ polish concern; for Phase 1 a console error and a simple inline message is enough. [ASSUMED: private-browsing localStorage quirks - reproducible on iOS Safari historically, not in scope for v1 desktop-only.]
- **User saves an empty string**: trim before save, refuse to save empty.
- **User reloads with key in storage**: storage wins; pre-populate the masked display, do not re-prompt.

**Planner recommendation:** Implement save/load/clear in a tiny `keyStorage` module (just three functions inside the `<script>` block, no need for a class). Use `migrationsamt.anthropicKey` as the storage key. Mask = first 7 + `...` + last 4. Never `innerHTML`. Wrap localStorage in try/catch from day one even though private-browsing is out of scope - the cost is two lines.

Sources: [MDN: Window.localStorage](https://developer.mozilla.org/en-US/docs/Web/API/Window/localStorage), [Auth0: Secure Browser Storage facts](https://auth0.com/blog/secure-browser-storage-the-facts/).

## 3. appState / setState / render Pattern (mirroring Sector Rojo)

### What Sector Rojo actually does

Reading `C:\Users\pacoe\coding_projects\Sector_rojo\index.html`: `gameState` is a single top-level `let gameState = 'menu';` string variable that takes values like `'menu'`, `'playing'`, `'paused'`, `'dead'`, `'upgrade'`, `'test-menu'`. Handlers mutate it directly (`gameState = 'playing'`) and the main `requestAnimationFrame` loop branches on it to decide what to update and what to draw. There is no formal `setState` or `render` - the canvas redraws every frame regardless.

This pattern is great for a game (continuous redraw). It is not what we want for a form-driven app (DOM should only update when something changes). STATE.md explicitly says "Single `appState` + `setState()` + `render()` pattern (same shape as Sector Rojo's `gameState`)" - so the intent is `gameState`-the-concept (one canonical state value, branching on it), not `gameState`-the-code (mutate-and-redraw-every-frame).

### Recommended Phase 1 pattern

```javascript
// One single source of truth. All UI is a function of this object.
const appState = {
  screen: 'key-entry',  // 'key-entry' | 'ready'
  apiKey: null,         // raw key, kept in memory; never put into innerHTML
};

// Merge a partial update, then re-render. Beginner-friendly.
function setState(partial) {
  Object.assign(appState, partial);
  render();
}

// Single render function. Reads state, writes DOM via textContent / value / classList.
// Idempotent: calling it twice produces the same DOM.
function render() {
  const keyEntryEl = document.getElementById('keyEntry');
  const readyEl = document.getElementById('ready');

  if (appState.screen === 'key-entry') {
    keyEntryEl.hidden = false;
    readyEl.hidden = true;
  } else if (appState.screen === 'ready') {
    keyEntryEl.hidden = true;
    readyEl.hidden = false;
    document.getElementById('maskedKey').textContent = maskKey(appState.apiKey);
  }
}
```

Two screens, both pre-rendered in HTML with `hidden` attributes flipped by render(). This avoids any innerHTML manipulation. As Phase 2 adds the intake screen and Phase 3 adds the cheat-sheet screen, the same pattern scales: more `appState.screen` values, more pre-rendered sections, more branches in `render()`.

### State fields Phase 1 needs

| Field | Type | Notes |
|-------|------|-------|
| `screen` | `'key-entry' \| 'ready'` | The current screen. Phase 2 will add `'intake'`, Phase 3 `'loading'`, `'result'`, `'error'`. |
| `apiKey` | `string \| null` | Raw key in memory after save or load. Never echoed to DOM. |

That is it. No `apiKeyMasked` field - derive it on the fly via `maskKey(appState.apiKey)`. Derived data should not live in state.

**Planner recommendation:** Implement exactly the three things above (the `appState` object, `setState`, `render`) and nothing more. Pre-render both screens in HTML with `hidden`; flip `hidden` in `render()`. Resist any urge to introduce event buses, observers, or a render-on-every-RAF loop - that is Sector Rojo's game-loop pattern, not this app's.

Sources: `C:\Users\pacoe\coding_projects\Sector_rojo\index.html` (Glob + Grep on `gameState`); STATE.md "Locked Decisions" line on `appState + setState + render`.

## 4. Hardcoded Migrationsamt Constants

These are the load-bearing facts. The LLM is permanently forbidden from generating any of these. Get them right.

### Office identity

- **Official name (German):** Migrationsamt des Kantons Zürich [VERIFIED: zh.ch]
- **English label (informal, for UI clarity in the EN locale):** Migration Office of Canton Zurich
- **Sicherheitsdirektion** (the parent department, useful for prompt grounding in Phase 2): Sicherheitsdirektion Kanton Zürich

### Address

- **Postal address:** Berninastrasse 45, Postfach, 8090 Zürich [VERIFIED: zh.ch official page; cross-confirmed by search.ch]

### Phone

- **Number:** +41 43 259 88 00 [VERIFIED: zh.ch]
- Display variants the app should accept/show:
  - International: `+41 43 259 88 00`
  - Swiss national: `043 259 88 00`

### Phone service hours (the ones that actually matter for v1)

These are the hours when a human picks up the phone, NOT the counter hours:

- Monday to Friday: 08:00 to 11:45 and 13:00 to 16:30 [VERIFIED: zh.ch]
- Closed for lunch 11:45 to 13:00
- Closed Saturday and Sunday

### Counter / Schalter hours (not the phone, but worth having in the constant for completeness)

- Monday to Friday: 08:00 to 16:30 [VERIFIED: zh.ch]

### 2026 closure days (Migrationsamt closed = no phone service)

The Migrationsamt follows canton Zürich's official cantonal holiday calendar. For 2026, the cantonal-level paid holidays are:

| Date | Day | German | Office state |
|------|-----|--------|--------------|
| 2026-01-01 | Thu | Neujahrstag | Closed |
| 2026-01-02 | Fri | Berchtoldstag | Closed (cantonally observed per canton Zürich's published 2026 list; some employers treat as half-day, but the Migrationsamt as a cantonal office observes the full day per personalamt) |
| 2026-04-03 | Fri | Karfreitag | Closed |
| 2026-04-06 | Mon | Ostermontag | Closed |
| 2026-05-01 | Fri | Tag der Arbeit | Closed |
| 2026-05-13 | Wed | (day before Auffahrt) | Reduced hours, open until 14:30 [VERIFIED: zh.ch live page 2026-05-14] |
| 2026-05-14 | Thu | Auffahrt | Closed |
| 2026-05-25 | Mon | Pfingstmontag | Closed |
| 2026-08-01 | Sat | Bundesfeier | Closed (weekend anyway) |
| 2026-12-25 | Fri | Weihnachtstag | Closed |
| 2026-12-26 | Sat | Stephanstag | Closed (weekend anyway) |

Notes for the planner:
- The Wednesday-before-Auffahrt reduced-hours pattern is published per-year, not a general rule. Hardcoding it for 2026 is fine; for 2027+ the constant will need to be updated. Add a comment.
- 1 August and 26 December 2026 fall on a Saturday - no v1 user would call those days, but include them in the constant so the office-closed logic stays correct.
- The day-before-Christmas (24 Dec 2026, Thursday) and 31 Dec are commonly half-days in canton Zürich practice but NOT cantonal paid holidays. Phase 1 should leave these as normal-hours unless Francisco confirms otherwise. [ASSUMED: 2026 Migrationsamt Dec 24 schedule - not in current published source. Flag for confirmation.]

The constant should be shaped:

```javascript
const MIGRATIONSAMT = {
  nameDe: 'Migrationsamt des Kantons Zürich',
  nameEn: 'Migration Office of Canton Zurich',
  parentDept: 'Sicherheitsdirektion Kanton Zürich',
  address: {
    line1: 'Berninastrasse 45',
    line2: 'Postfach',
    postalCode: '8090',
    city: 'Zürich',
    country: 'Switzerland',
  },
  phone: {
    international: '+41 43 259 88 00',
    national: '043 259 88 00',
  },
  email: 'info@ma.zh.ch',
  website: 'https://www.zh.ch/de/sicherheitsdirektion/migrationsamt.html',
  phoneHours: {
    // Mon-Fri only. Two windows per day with a lunch gap.
    mondayToFriday: [
      { from: '08:00', to: '11:45' },
      { from: '13:00', to: '16:30' },
    ],
    saturday: null,
    sunday: null,
  },
  counterHours: {
    mondayToFriday: [{ from: '08:00', to: '16:30' }],
  },
  // 2026 closures. Update annually.
  closures2026: [
    { date: '2026-01-01', name: 'Neujahrstag', type: 'closed' },
    { date: '2026-01-02', name: 'Berchtoldstag', type: 'closed' },
    { date: '2026-04-03', name: 'Karfreitag', type: 'closed' },
    { date: '2026-04-06', name: 'Ostermontag', type: 'closed' },
    { date: '2026-05-01', name: 'Tag der Arbeit', type: 'closed' },
    { date: '2026-05-13', name: 'Tag vor Auffahrt', type: 'reduced', closesAt: '14:30' },
    { date: '2026-05-14', name: 'Auffahrt', type: 'closed' },
    { date: '2026-05-25', name: 'Pfingstmontag', type: 'closed' },
    { date: '2026-08-01', name: 'Bundesfeier', type: 'closed' },
    { date: '2026-12-25', name: 'Weihnachtstag', type: 'closed' },
    { date: '2026-12-26', name: 'Stephanstag', type: 'closed' },
  ],
};
```

### Block D: Panic phrases (hardcoded German with English gloss)

Per ROADMAP Cheat Sheet Anatomy, Block D pins seven phrases. These are the canonical German:

| German | English gloss |
|--------|---------------|
| Können Sie das bitte wiederholen? | Could you please repeat that? |
| Können Sie bitte langsamer sprechen? | Could you please speak more slowly? |
| Können Sie mir das bitte per E-Mail schicken? | Could you please send me that by email? |
| Ich verstehe nicht. | I don't understand. |
| Ich habe verstanden. | I understood. |
| Vielen Dank. | Thank you very much. |
| Auf Wiederhören. | Goodbye (phone-specific). |

These come from common phrasebook usage for formal Standard German over the phone. [ASSUMED: exact wording - confirm with Francisco / a native speaker before Phase 3 rendering. Phrasing is conventional but personal preference exists, e.g. some prefer "Ich verstehe das nicht" over "Ich verstehe nicht".]

Also include the always-on Hochdeutsch-request line (used in Block B, but worth keeping in the constants bundle for reuse):

> Können wir bitte auf Hochdeutsch sprechen? Mein Schweizerdeutsch ist nicht so gut.
> (Could we please speak Standard German? My Swiss German isn't very good.)

### Block H: Footer escalation links

Three escalation paths per ROADMAP. URLs verified via the same Welcome Desk / SAH-Zürich / Solinetz search:

- **Welcome Desk (Stadt Zürich)** - free information for newcomers, multilingual.
  URL: `https://www.stadt-zuerich.ch/de/lebenslagen/neu-in-zuerich/zuzug-ausland/welcome-desk.html` [VERIFIED]
- **MIRSAH (SAH Zürich)** - legal counselling for migration and integration law.
  URL: `https://www.sah-zh.ch/angebot/mirsah/` [VERIFIED]
  Phone (worth including): +41 44 291 00 15
- **Solinetz Zürich** - network supporting migrants and refugees.
  URL: `https://solinetz-zh.ch/` [VERIFIED - infer base from PDF subdomain]

Plus the non-dismissable footer text (rendered in Block H per CHEAT-08 in Phase 3, but the string itself is a Phase 1 constant):

> This is a preparation aid, not legal advice. Do not impersonate the user. Do not contact authorities on the user's behalf.

**Planner recommendation:** Hardcode the entire `MIGRATIONSAMT` object verbatim from the structure above into a top-of-`<script>` `const`. Include a `// Sources verified 2026-05-14` comment with the zh.ch URL. Phase 1 does not render any of this content (rendering is Phase 3), but the constants must be in place so Phase 3 has nothing to invent. Flag two items for Francisco confirmation before Phase 3 planning: (a) exact German wording of Block D phrases, (b) 24 Dec 2026 Migrationsamt schedule.

Sources: [Migrationsamt - zh.ch](https://www.zh.ch/de/sicherheitsdirektion/migrationsamt.html), [Kontakt - zh.ch](https://www.zh.ch/de/migration-integration/kontaktformularmigrationsamt.html), [Feiertage 2026 Kanton Zürich - personalamt PDF](https://www.zh.ch/content/dam/zhweb/bilder-dokumente/organisation/finanzdirektion/personalamt/feiertage_2026.pdf), [magicheidi 2026 Zurich holidays](https://magicheidi.ch/de/public-holidays-zurich-2026), [Welcome Desk Stadt Zürich](https://www.stadt-zuerich.ch/de/lebenslagen/neu-in-zuerich/zuzug-ausland/welcome-desk.html), [MIRSAH SAH-Zürich](https://www.sah-zh.ch/angebot/mirsah/).

## 5. `getUserMedia` Grep Enforcement

### The command Francisco runs

On Windows PowerShell (Francisco's actual environment):

```powershell
Select-String -Path "C:\Users\pacoe\coding_projects\inmigration tool\*.html","C:\Users\pacoe\coding_projects\inmigration tool\app\*.html" -Pattern "getUserMedia" -SimpleMatch
```

Expected output: nothing. Any output is a TRUST-04 violation and must block the commit.

Bash-equivalent (for the CLAUDE.md sibling-project parity, or if Francisco moves to WSL):

```bash
git grep -n "getUserMedia"
```

Expected exit code 1 (no matches found), expected output empty.

### Precommit hook? No.

For v1, manual grep is the right answer:

- Setting up a Git hook on Windows is fiddly (line endings, shebang, executable bit), and Francisco is a beginner.
- The grep takes one second to run manually.
- Phase 1 has very few commits (probably under ten), and Phase 2/3/4 are unlikely to introduce mic code by accident.
- The CSP `default-src 'self'` already blocks any inline `<audio>` element from a non-self origin; `getUserMedia` itself is not blocked by CSP (browser API), but it cannot be silently added without source code review.

Add a one-line `pretest.ps1` (or `verify.ps1`) at the repo root that runs the grep and exits 1 on any match. Francisco runs it before every commit by hand. Beginner-friendly, zero magic. If/when Francisco adds CI in v1.x, the same one-liner becomes a CI step.

**Planner recommendation:** Add a `verify-no-mic.ps1` script at repo root that runs the Select-String above and exits non-zero on any match. Francisco runs it manually before each commit. No precommit hook for v1. Document the command in `README.md` (which the planner should also create).

Sources: PowerShell `Select-String` is a built-in cmdlet; `git grep` is a built-in subcommand.

## 6. File Layout Recommendation

### The options

| Option | Pros | Cons |
|--------|------|------|
| **A: Single `index.html` at repo root** | Matches sibling-project pattern (`Sector_rojo/index.html`). Simplest possible. `https://pacomc999.github.io/inmigration-tool/` lands directly on the app. | `spike/` continues to exist as a sibling; might confuse users who land on the repo. |
| B: `app/index.html` | Keeps repo root clean. Easy to add `docs/`, `tests/`, etc. later. | Requires GitHub Pages root config change (currently serves from `master:/`). URL becomes `pacomc999.github.io/inmigration-tool/app/`, less clean. Beginner-unfriendly. |
| C: Replace `spike/index.html` in place | Zero new files. | Loses the spike artifact (the Phase 0 SUMMARY explicitly says cleanup is a Phase 1 decision). The spike is useful evidence for traceability. |

### Recommendation: Option A

Put the v1 app at `index.html` in the repo root. Keep `spike/index.html` as-is. The GitHub Pages root continues to serve from `master:/` and now naturally lands on the v1 app. The spike remains accessible at `/spike/` as a historical artifact. This matches the workspace convention (`Sector_rojo/index.html`, `music_animator/spectrum.html` - all live at their project root) and is the smallest cognitive load for Francisco.

Phase 2 (LLM round-trip), Phase 3 (cheat-sheet rendering) all stay in the same `index.html`. The single-file pattern is a locked decision. If the file grows past ~2000 lines and becomes unmaintainable, the right move at that point is to extract `constants.js` and `prompts.js` as same-origin `<script src="...">` tags (allowed by `script-src 'self'`), not to introduce a build system. That decision is Phase 4 or later, not Phase 1.

**Planner recommendation:** `index.html` at repo root. Leave `spike/` alone. Update `.gitignore` if needed. Add a `README.md` at repo root that links to both the live URL and the spike URL for traceability.

## 7. Key UI Copy (English Only)

Phase 4 will localise; Phase 1 ships English-only as scoped. Beginner-readable, short, no jargon. Avoid em dashes per CLAUDE.md.

### Key-entry screen

- **Page title (`<title>`):** Migrationsamt Zürich Call Helper
- **H1:** Migrationsamt Zürich Call Helper
- **Subtitle / lede (one sentence):** A preparation tool for English speakers who need to call the Migrationsamt of canton Zürich.
- **Section heading:** Bring your own Anthropic API key
- **Helper paragraph:**
  > This tool runs entirely in your browser. To generate your cheat sheet it needs to call Anthropic's Claude API on your behalf. You provide the key, the key stays in your browser, and nothing else is sent anywhere. No backend, no logging, no accounts.
- **Input label:** Your Anthropic API key
- **Input placeholder:** `sk-ant-...`
- **Helper text under input:** Stored only in your browser's local storage. Click "Clear key" any time to remove it.
- **Save button:** Save key
- **Empty-state error (if user clicks Save with empty input):** Please paste your Anthropic API key first.
- **localStorage-blocked error (rare, defensive):** Your browser is blocking local storage. The app needs it to remember your key between visits.

### Ready screen (key saved, masked)

- **H2:** Key saved
- **Masked display:** `sk-ant-...abcd` (rendered via the mask function)
- **Helper text:** Your key is stored in this browser only. You are ready to use the tool.
- **Replace button:** Replace key
- **Clear button:** Clear key
- **Clear confirmation (inline or `confirm()` for v1, simple):** Remove the saved key from this browser? You will need to paste it again next time.

### Disclaimer (footer, present on every screen from Phase 1 forward)

> This is a preparation aid, not legal advice. The tool does not contact authorities. You make the call.

**Planner recommendation:** Use the copy above verbatim in `index.html`. All strings live as static HTML text content in Phase 1 (no i18n abstraction yet - that arrives in Phase 4). Avoid contractions where formality matters; "do not" is OK to keep contractions per CLAUDE.md normal-English preference. No em dashes anywhere.

## 8. Risks and Beginner Traps

### Trap 1: CSP and `'unsafe-inline'`

**What goes wrong:** Beginner adds a nonce/hash for hardening, the script changes, the hash no longer matches, the page is silently broken (the inline `<script>` simply does not execute and DevTools console shows a CSP violation).
**Why it happens:** Hashes must be recomputed every time the inline script changes. Without a build system, this is manual.
**How to avoid:** Use `'unsafe-inline'` for v1. Documented compromise. Revisit only if Phase 2+ ever loads untrusted DOM content (which the no-innerHTML rule already forbids).
**Warning sign:** "Refused to execute inline script because it violates the following Content Security Policy directive..." in DevTools console.

### Trap 2: GitHub Pages aggressive caching during development

**What goes wrong:** Francisco pushes a change, reloads the page, sees the old version, thinks the deploy is broken.
**Why it happens:** GitHub Pages caches both at the CDN layer and via standard browser caching. A hard reload (Ctrl+Shift+R) does not always evict the CDN cache for several minutes.
**How to avoid:** During Phase 1 development, append a query string to the URL when testing: `https://pacomc999.github.io/inmigration-tool/?v=1`, `?v=2`, etc. Browsers treat distinct query strings as distinct resources. For local-only iteration, prefer opening `index.html` directly from disk (`file://`) so there is no caching layer at all - the CSP and localStorage both work the same way locally. Once the page is stable, drop the query string.
**Warning sign:** Edit visible in source on GitHub but not in browser after Ctrl+Shift+R.

### Trap 3: localStorage on private browsing (iOS Safari, some Firefox modes)

**What goes wrong:** `localStorage.setItem` throws a `QuotaExceededError` because private mode allots zero quota. The app crashes on the Save click.
**Why it happens:** Apple's privacy posture historically zeroed out localStorage in private browsing.
**How to avoid:** Wrap every localStorage call in try/catch from day one. Per Phase 0 D-05, iOS Safari is out of v1 scope, but the same failure mode appears on some Firefox configurations. Two lines of try/catch costs nothing.
**Warning sign:** Save click does nothing, DevTools console shows a QuotaExceededError.

### Trap 4: Forgetting that `<meta>` CSP cannot do `frame-ancestors`

**What goes wrong:** Beginner adds `frame-ancestors 'none'` to the meta tag, feels secure, but the directive is silently ignored. The site remains iframable.
**Why it happens:** CSP spec says meta-CSP does not support `frame-ancestors`, `report-uri`, or `sandbox`.
**How to avoid:** Do not include those directives. Add a comment in the HTML explaining why.
**Warning sign:** None visible - the directive is silently ignored, not a console warning.

### Trap 5: Hardcoded constants drifting out of date

**What goes wrong:** Migrationsamt changes phone hours or moves; v1 still ships the 2026 facts six months later.
**Why it happens:** The locked decision (LLM never generates contact info) means there is no auto-update path.
**How to avoid:** Add a comment at the top of the MIGRATIONSAMT constant with the verification date and source URL. Plan a re-verification check before the v1 pilot in Phase 5 and annually thereafter. Phase 1 plan should include a single task: "verify Migrationsamt facts against zh.ch on the day of pilot launch".
**Warning sign:** Pilot user reports "I called the number and it was wrong."

### Trap 6: Accidentally adding a third-party CDN later

**What goes wrong:** Phase 2 or 3 wants a small library (e.g. a date formatter), Francisco adds a `<script src="https://cdn.jsdelivr.net/...">`, the CSP blocks it, debugging eats a half day.
**Why it happens:** L-05 forbids third-party scripts, but the temptation is constant.
**How to avoid:** Treat the CSP `default-src 'self'` as binding. If a feature genuinely needs a library, copy the library file into the repo and serve it self-hosted (still allowed). Phase 1 needs no libraries.
**Warning sign:** "Refused to load the script... because it violates the following Content Security Policy directive: default-src 'self'."

**Planner recommendation:** Add a short "Known traps" section to README.md listing these six. The CSP-and-inline-script and GitHub-Pages-caching traps are the two most likely to bite during Phase 1 development specifically.

## Runtime State Inventory

This is not a rename/refactor phase; this section is omitted. Phase 1 introduces new files (`index.html`, `README.md`, `verify-no-mic.ps1`) but does not change existing identifiers. The `spike/` folder is left intact per Section 6.

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|----------|
| Modern browser (Chrome 90+) | Running the app | yes | Chrome current | - |
| Git | Committing changes | yes | per Phase 0 commits | - |
| GitHub CLI (`gh`) | (optional) Pages deploys | yes | Installed in Phase 0 | Manual git push |
| PowerShell | Running `verify-no-mic.ps1` | yes | Windows 11 default | `git grep` via Bash |
| Anthropic API key | Phase 2 onward (not Phase 1) | yes (Francisco has personal) | - | - |

No external runtimes, package managers, or services are required for Phase 1. The phase is pure HTML/CSS/JS, no build step.

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
|---|-------|---------|---------------|
| A1 | Block D German phrasing matches conventional formal Hochdeutsch | 4 | Low - phrases are widely used variants. Confirm with native speaker before Phase 3 renders them. |
| A2 | 24 Dec 2026 Migrationsamt schedule is normal hours (not half-day) | 4 | Medium - widely-observed half-day in canton Zürich practice but not cantonal-paid. Confirm with Francisco; possibly add `{ date: '2026-12-24', type: 'reduced', closesAt: '12:00' }` to closures. |
| A3 | localStorage quota issues are out of scope for v1 (desktop Chrome only) | 2 | Low - per Phase 0 D-05 platform scope. Try/catch is still added defensively. |
| A4 | The 2026-05-13 reduced-hours pattern is a one-off, not an annual rule | 4 | Low - hardcoded for 2026 only; annual review task already noted in Trap 5. |

## Open Questions

1. **Drop KEY-04 from REQUIREMENTS.md in this phase or as housekeeping?**
   - What we know: KEY-04 (provider toggle) is obsoleted by L-01 (Anthropic-only). 01-CONTEXT.md says the planner can decide.
   - What's unclear: Whether the planner should fold the REQUIREMENTS.md amendment into Phase 1 or treat it as a separate small commit.
   - Recommendation: Include the REQUIREMENTS.md amendment as a single task in Phase 1's plan (small, low risk, keeps the doc honest before Phase 2 starts pulling requirement IDs from it).

2. **Block D German wording - native-speaker review.**
   - What we know: Section 4 lists conventional phrasings.
   - What's unclear: Whether Francisco wants to lock these exact strings or have a native speaker review first.
   - Recommendation: Lock in Phase 1 as a constant, flag for review in Phase 3 planning before they render. Updating a constant is cheap.

3. **Migrationsamt 24 Dec 2026 closure?**
   - What we know: Cantonal paid holidays do not include 24 Dec. Practice varies.
   - What's unclear: Whether the Migrationsamt specifically publishes a 24 Dec 2026 schedule.
   - Recommendation: Ship Phase 1 with 24 Dec as normal-hours. Add a task to Phase 5 (pilot) to re-verify the official zh.ch schedule before the user's actual call.

## Project Constraints (from CLAUDE.md)

From `C:\Users\pacoe\coding_projects\inmigration tool\CLAUDE.md` and `C:\Users\pacoe\coding_projects\CLAUDE.md`:

- Vanilla HTML, CSS, and vanilla JS only. No frameworks, no build system, no TypeScript.
- Single-file pattern: inline `<style>` and `<script>` in one HTML file.
- Never use dashes (em dash, en dash) in visible text or copy suggestions.
- Add comments to explain what each section does.
- Keep functions short and focused on one thing.
- Make small changes one step at a time.
- Git commit messages in present tense, short, descriptive.
- GSD workflow enforced - all edits via `/gsd-execute-phase` (or equivalent), not direct.
- Privacy: nothing leaves the user's browser except the single LLM call. No analytics. No backend.

The planner MUST honor these. Any task that would violate one of these directives is invalid.

## Sources

### Primary (HIGH confidence)

- [Migrationsamt - zh.ch](https://www.zh.ch/de/sicherheitsdirektion/migrationsamt.html) - official phone, address, hours, current 2026 closure notice (verified 2026-05-14)
- [Kontaktformular Migrationsamt - zh.ch](https://www.zh.ch/de/migration-integration/kontaktformularmigrationsamt.html) - contact details cross-check
- [MDN: Content Security Policy](https://developer.mozilla.org/en-US/docs/Web/HTTP/Guides/CSP) - CSP directive reference
- [content-security-policy.com: meta tag example](https://content-security-policy.com/examples/meta/) - meta-tag syntax
- [content-security-policy.com: frame-ancestors](https://content-security-policy.com/frame-ancestors/) - meta-tag limitations
- [OWASP CSP Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Content_Security_Policy_Cheat_Sheet.html) - hardening guidance
- [Simon Willison: Claude's API now supports CORS](https://simonwillison.net/2024/Aug/23/anthropic-dangerous-direct-browser-access/) - confirms the dangerous-direct-browser-access header (corroborated by Phase 0 spike outcome)
- `C:\Users\pacoe\coding_projects\Sector_rojo\index.html` - `gameState` pattern source
- `C:\Users\pacoe\coding_projects\inmigration tool\spike\index.html` - existing Phase 0 spike code

### Secondary (MEDIUM confidence)

- [magicheidi: 2026 Zurich public holidays](https://magicheidi.ch/de/public-holidays-zurich-2026) - 2026 holiday list, cross-validated against zh.ch personalamt PDF
- [Welcome Desk - Stadt Zürich](https://www.stadt-zuerich.ch/de/lebenslagen/neu-in-zuerich/zuzug-ausland/welcome-desk.html) - escalation link
- [MIRSAH - SAH Zürich](https://www.sah-zh.ch/angebot/mirsah/) - escalation link
- [Auth0: Secure Browser Storage](https://auth0.com/blog/secure-browser-storage-the-facts/) - localStorage tradeoffs
- [Feiertage 2026 Kanton Zürich PDF (personalamt)](https://www.zh.ch/content/dam/zhweb/bilder-dokumente/organisation/finanzdirektion/personalamt/feiertage_2026.pdf) - official cantonal calendar (PDF; readable through magicheidi cross-check)

### Tertiary (LOW confidence)

- Block D German phrasing - conventional usage, no single authoritative source. Confirm with native speaker before rendering.

## Metadata

**Confidence breakdown:**

- CSP for vanilla single-file: HIGH - MDN + OWASP + content-security-policy.com agree on limitations and directive syntax.
- localStorage pattern: HIGH - standard browser API, no library needed.
- appState/setState/render pattern: HIGH - matches STATE.md locked decision, scales to Phase 2-4 cleanly.
- Migrationsamt contact facts: HIGH - direct from zh.ch.
- 2026 cantonal holidays: MEDIUM - two sources agree but the PDF couldn't be read directly by tooling, secondary sources triangulate.
- Block D phrases: LOW - widely-used conventional German, confirm before render.
- Mic guardrail grep: HIGH - trivial.

**Research date:** 2026-05-14
**Valid until:** 2026-06-14 for stable items (CSP, localStorage, pattern). Re-verify Migrationsamt facts before the Phase 5 pilot and annually thereafter.
