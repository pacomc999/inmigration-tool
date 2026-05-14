# Architecture Research

**Domain:** Single-page vanilla JS webapp, browser-only LLM client (BYO API key), printable cheat-sheet output
**Researched:** 2026-05-14
**Confidence:** HIGH

## Executive Recommendation

Build it as a **single `index.html` file** with inline `<style>` and `<script>` blocks, matching the style of the developer's other projects (Sector Rojo, music_animator, spaceship_search). Use a single `appState` object as the single source of truth, a small `render()` function that re-paints the active screen, and a `screen` field on `appState` to drive a tiny state machine (`'intake' | 'loading' | 'result' | 'error' | 'settings'`).

The only reason to break out of one file is the prompt templates, which benefit from being editable as plain text without scrolling past 1000 lines of UI code. Even those can stay inline for v1.

## System Overview

```
┌─────────────────────────────────────────────────────────────┐
│                  index.html (single file)                    │
├─────────────────────────────────────────────────────────────┤
│  <style>  - layout, screen visibility, print rules          │
├─────────────────────────────────────────────────────────────┤
│  <body>   - all screens as sibling <section> elements       │
│             toggled via [data-screen] / hidden attribute    │
│   ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐      │
│   │ #intake  │ │ #loading │ │ #result  │ │ #settings│      │
│   └──────────┘ └──────────┘ └──────────┘ └──────────┘      │
├─────────────────────────────────────────────────────────────┤
│  <script>                                                    │
│   ┌──────────────────────────────────────────────────┐      │
│   │  appState  (single source of truth)              │      │
│   └──────────────────────────────────────────────────┘      │
│              ↑              ↓                                │
│   ┌──────────────────┐  ┌─────────────────────────┐         │
│   │  event handlers  │  │  render()  - paints DOM │         │
│   │  (form submits,  │  │  from appState          │         │
│   │   button clicks) │  └─────────────────────────┘         │
│   └──────────────────┘                                       │
│              ↓                                                │
│   ┌──────────────────────────────────────────────────┐      │
│   │  PROMPTS  - template strings (EN/ES/PT versions) │      │
│   └──────────────────────────────────────────────────┘      │
│              ↓                                                │
│   ┌──────────────────────────────────────────────────┐      │
│   │  callLLM()  - fetch() wrapper, returns JSON      │      │
│   │   - openaiCall() / geminiCall() branches         │      │
│   └──────────────────────────────────────────────────┘      │
│              ↓                                                │
│   ┌──────────────────────────────────────────────────┐      │
│   │  localStorage  - API key, last cheat sheet       │      │
│   └──────────────────────────────────────────────────┘      │
└─────────────────────────────────────────────────────────────┘
                          ↓ (network)
              ┌──────────────────────────┐
              │  OpenAI or Gemini API    │
              └──────────────────────────┘
```

## File Layout

### Recommended for v1: Single File

```
inmigration tool/
├── index.html          # everything: HTML, CSS, JS, prompts
├── README.md
└── .planning/
```

**Why single file for this project:**

- Matches the workspace convention (all three sibling projects do this)
- Beginner-friendly: one place to look, no module loading concerns, no CORS issues when opened via `file://`
- Tiny app: probably 800-1500 lines total. Manageable in one file
- No build system means no module bundling. Native ES modules work but require a server (browsers block `import` from `file://`)
- Easy to share: one file, drop it on any static host (GitHub Pages, Netlify drop, even email)

### When to split (defer to v2 if it ever becomes painful)

Split into separate files only if any of these become true:

| Trigger | Files to extract |
|---------|------------------|
| Prompts grow past ~200 lines or you want to edit them without IDE syntax highlighting fighting you | `prompts.js` (still loaded via `<script>` tag, not modules) |
| CSS passes ~300 lines | `styles.css` linked via `<link rel="stylesheet">` |
| JS passes ~1200 lines | `app.js` via `<script src="app.js">` |
| You start working on v2 (interpreter mode) | Consider modules + a tiny dev server (`python -m http.server`) |

**Splitting rule for vanilla JS:** use plain `<script>` tags in order, not `<script type="module">`. Modules require HTTP serving, which breaks the "double-click the HTML file" workflow.

## State Management Pattern

### The pattern: one `appState` object + `render()` function

This is the same pattern as Sector Rojo's `gameState`, generalized for a form-driven app instead of a game loop.

```javascript
// Single source of truth
const appState = {
  screen: 'intake',           // 'intake' | 'loading' | 'result' | 'error' | 'settings'
  language: 'en',             // 'en' | 'es' | 'pt'
  apiProvider: 'gemini',      // 'gemini' | 'openai'
  apiKey: '',                 // loaded from localStorage on boot
  intake: {                   // form data
    permitType: '',
    reason: '',
    referenceNumber: '',
    documentsOnHand: [],
    notes: ''
  },
  cheatSheet: null,           // the parsed JSON returned by the LLM
  error: null                 // { message, details } when screen === 'error'
};
```

### How state changes drive the UI

```javascript
// Mutate state, then re-render. Never touch the DOM directly outside render().
function setState(patch) {
  Object.assign(appState, patch);
  render();
}

function render() {
  // Show only the active screen
  document.querySelectorAll('[data-screen]').forEach(el => {
    el.hidden = el.dataset.screen !== appState.screen;
  });

  // Per-screen painting
  if (appState.screen === 'result') {
    renderCheatSheet(appState.cheatSheet);
  }
  if (appState.screen === 'error') {
    document.querySelector('#error-message').textContent = appState.error.message;
  }
  // ...
}
```

### Why this works for a beginner

- **One place to look** when wondering "what is the app doing right now?" — log `appState`
- **No reactive framework magic.** You explicitly call `render()` after every change
- **Easy to debug:** drop a `console.log(appState)` at the top of `render()`
- **Easy to persist:** `localStorage.setItem('state', JSON.stringify(appState))` if you want to survive reloads

### Persistence: only what's worth persisting

```javascript
// On boot
const savedKey = localStorage.getItem('apiKey');
const savedProvider = localStorage.getItem('apiProvider');
const savedLanguage = localStorage.getItem('language');
if (savedKey) appState.apiKey = savedKey;
// ...

// When user enters key in settings
function saveApiKey(key, provider) {
  localStorage.setItem('apiKey', key);
  localStorage.setItem('apiProvider', provider);
  setState({ apiKey: key, apiProvider: provider });
}
```

**Do not persist:** intake form (sensitive immigration data), cheat sheet (sensitive), errors. Privacy posture in PROJECT.md is strong, respect it.

**Anti-pattern:** do not use sessionStorage to "remember" form drafts. Users will close the tab and assume the data is gone. It will be (mostly), but you reduce surface area by not writing it at all.

## Component Boundaries

Even in one file, mentally separate these concerns. Group them in the script block with clear comment banners.

| Module (just a section of the script) | Responsibility |
|---------------------------------------|----------------|
| `// === STATE ===` | `appState`, `setState()`, localStorage load/save |
| `// === SCREENS / RENDER ===` | `render()`, `renderCheatSheet()`, screen visibility |
| `// === INTAKE FORM ===` | Reading form values into `appState.intake`, validation |
| `// === PROMPTS ===` | `PROMPTS` object with system + user templates per language |
| `// === LLM CLIENT ===` | `callLLM()`, `callOpenAI()`, `callGemini()`, JSON parsing |
| `// === EVENT WIRING ===` | `addEventListener` calls, kicked off at `DOMContentLoaded` |

The single explicit rule: **only the render section touches the DOM for output. Only the event wiring section listens for input.** State is the bridge.

## LLM Call Lifecycle

### The lifecycle

```
[User clicks "Generate"]
      ↓
validate intake
      ↓
setState({ screen: 'loading' })           ← UI shows spinner immediately
      ↓
build prompt from PROMPTS + appState.intake + appState.language
      ↓
await callLLM(prompt, appState.apiKey, appState.apiProvider)
      ↓                       ↓
   success                  failure (network, 4xx, JSON parse)
      ↓                       ↓
parse JSON           setState({ screen: 'error', error: {...} })
      ↓
setState({ screen: 'result', cheatSheet: parsed })
```

### Clean async vanilla JS

```javascript
async function handleGenerateClick() {
  // 1. Read form into state
  const intake = readIntakeForm();
  setState({ intake });

  // 2. Validate (basic, not strict)
  if (!appState.apiKey) {
    setState({ screen: 'error', error: { message: 'Add an API key in settings first.' } });
    return;
  }
  if (!intake.reason.trim()) {
    setState({ screen: 'error', error: { message: 'Tell us why you are calling.' } });
    return;
  }

  // 3. Loading screen
  setState({ screen: 'loading' });

  // 4. Call LLM
  try {
    const sheet = await callLLM({
      provider: appState.apiProvider,
      apiKey: appState.apiKey,
      language: appState.language,
      intake
    });
    setState({ screen: 'result', cheatSheet: sheet });
  } catch (err) {
    setState({
      screen: 'error',
      error: { message: friendlyError(err), details: err.message }
    });
  }
}
```

### Inside `callLLM`

```javascript
async function callLLM({ provider, apiKey, language, intake }) {
  const prompt = buildPrompt(language, intake);

  const response = provider === 'openai'
    ? await callOpenAI(apiKey, prompt)
    : await callGemini(apiKey, prompt);

  // Strip code fences if the model returned ```json ... ```
  const cleaned = response.trim().replace(/^```json\s*/, '').replace(/```$/, '');
  return JSON.parse(cleaned);
}
```

### Loading state: do it right

- Show a spinner or "Generating your cheat sheet, this takes 10-20 seconds" message immediately
- Disable the generate button while loading (or just hide the intake screen entirely, since `screen === 'loading'` swaps it out)
- Optional: show a rotating reassurance message every 5s ("Looking up vocabulary...", "Drafting officer questions...") — purely cosmetic but cuts perceived wait

### Error states: be human about them

```javascript
function friendlyError(err) {
  const msg = err.message.toLowerCase();
  if (msg.includes('401') || msg.includes('invalid api key')) {
    return 'Your API key was rejected. Check it in Settings.';
  }
  if (msg.includes('429')) {
    return 'Rate limit reached. Wait a minute and try again.';
  }
  if (msg.includes('failed to fetch')) {
    return 'Could not reach the API. Check your internet connection.';
  }
  if (err.name === 'SyntaxError') {
    return 'The AI returned an unexpected response. Try again.';
  }
  return 'Something went wrong. Try again, or try a different language.';
}
```

Always offer **"Try again"** and **"Back to intake"** buttons on the error screen. Never strand the user.

## Prompt Engineering Structure

### Recommendation: inline `PROMPTS` object

For v1, keep prompts inline in the script. They are tightly coupled to the JSON shape your renderer expects, so co-locating them keeps the contract visible.

```javascript
const PROMPTS = {
  system: `You are a precise translation and call-prep assistant. ...
Return JSON ONLY matching this schema:
{
  "officerGreeting": { "german": "...", "translation": "..." },
  "keySentences": [{ "german": "...", "translation": "...", "pronunciation": "..." }],
  "vocabulary": [{ "german": "...", "translation": "..." }],
  "likelyQuestions": [{ "german": "...", "translation": "...", "suggestedAnswer": { "german": "...", "translation": "..." } }],
  "prepChecklist": ["..."]
}`,

  userTemplate: {
    en: (intake) => `The user speaks English. They are calling the Migrationsamt Zürich.
Permit: ${intake.permitType}
Reason for call: ${intake.reason}
Reference number: ${intake.referenceNumber || 'none'}
Documents on hand: ${intake.documentsOnHand.join(', ') || 'none specified'}
Notes: ${intake.notes || 'none'}

Generate the cheat sheet now.`,

    es: (intake) => `El usuario habla español. Llama al Migrationsamt Zürich.
Permiso: ${intake.permitType}
...`,

    pt: (intake) => `...`
  }
};

function buildPrompt(language, intake) {
  return {
    system: PROMPTS.system,
    user: PROMPTS.userTemplate[language](intake)
  };
}
```

### When to extract prompts

Move `PROMPTS` to its own `prompts.js` (loaded with a plain `<script>` tag before `index.html`'s main script) when **either** of:

1. Prompts exceed ~150 lines total and scrolling past them gets annoying
2. You want a non-developer (your first user, a friend) to edit phrasing without touching JS

For v1 it almost certainly stays inline.

### Anti-pattern: separate JSON files for prompts

Tempting (it's "data, not code") but it costs you:
- You can't use template literal interpolation, so you need a templating step
- It requires `fetch()` to load, which means CORS issues on `file://`
- The JSON-vs-string distinction adds zero value here

## Cheat Sheet Output Rendering

### Recommendation: structured JSON from LLM, hand-rendered to HTML

Ask the LLM for a strict JSON shape (see `PROMPTS.system` above). Render it to HTML with explicit template functions. This gives you full control of the print layout, which markdown would not.

### Why not markdown?

Markdown is fine for prototyping but:
- You'd need a markdown-to-HTML library (breaks "no dependencies")
- You'd lose semantic structure (officer questions vs vocabulary collapse into "lists")
- Print styling becomes harder without distinct CSS classes per section

### Why not just stuff the LLM's raw HTML into the page?

`innerHTML` from an LLM response is an XSS hazard, even if it's "your" API key. Treat all LLM output as untrusted text and use `textContent` for everything except the wrapping structure you control.

### Render pattern

```javascript
function renderCheatSheet(sheet) {
  const container = document.querySelector('#result-content');
  container.innerHTML = '';  // clear

  container.appendChild(section('Officer Greeting', () => {
    const p = document.createElement('p');
    p.innerHTML = `<strong></strong> <em></em>`;
    p.querySelector('strong').textContent = sheet.officerGreeting.german;
    p.querySelector('em').textContent = sheet.officerGreeting.translation;
    return p;
  }));

  container.appendChild(section('Key Sentences', () => {
    const ul = document.createElement('ul');
    sheet.keySentences.forEach(s => {
      const li = document.createElement('li');
      // textContent everywhere — never innerHTML from LLM output
      li.innerHTML = `<strong></strong><br><em></em><br><small></small>`;
      li.querySelector('strong').textContent = s.german;
      li.querySelector('em').textContent = s.translation;
      li.querySelector('small').textContent = s.pronunciation || '';
      ul.appendChild(li);
    });
    return ul;
  }));

  // ... vocabulary, likelyQuestions, prepChecklist
}

function section(title, contentFn) {
  const sec = document.createElement('section');
  sec.className = 'sheet-section';
  const h = document.createElement('h2');
  h.textContent = title;
  sec.appendChild(h);
  sec.appendChild(contentFn());
  return sec;
}
```

### Safety net: schema validation

The LLM will occasionally drop a field or rename a key. Validate before rendering and fall back to "(missing)" rather than crashing:

```javascript
function safe(obj, key, fallback = '') {
  return (obj && obj[key] != null) ? obj[key] : fallback;
}
```

## Print Strategy

### What it takes to print well on A4 and US Letter

The user will print this and hold it during the call. Print rendering is a real requirement, not a nice-to-have.

### Three things to set up

**1. A dedicated `@media print` block in your `<style>`:**

```css
@media print {
  /* Hide everything that isn't the cheat sheet */
  header, nav, .intake-form, .actions, button, .settings,
  [data-screen]:not([data-screen="result"]) {
    display: none !important;
  }

  /* Page itself */
  body {
    background: white;
    color: black;
    font-family: Georgia, serif;     /* serif prints sharper than sans on most printers */
    font-size: 11pt;                  /* 10-12pt is the readable print range */
    line-height: 1.4;
  }

  /* Page margins — works for both A4 and US Letter */
  @page {
    margin: 1.5cm;                    /* generous, looks good on both sizes */
  }

  /* Section breaks */
  .sheet-section {
    page-break-inside: avoid;         /* don't split a section across pages */
    margin-bottom: 1em;
  }

  h1, h2 {
    page-break-after: avoid;          /* heading shouldn't be the last line on a page */
  }

  /* Make sure backgrounds print if you use them for emphasis */
  * {
    -webkit-print-color-adjust: exact;
    print-color-adjust: exact;
  }

  /* Show URLs after links if you have any (probably not needed here) */
  a[href]::after {
    content: " (" attr(href) ")";
    font-size: 9pt;
  }
}
```

**2. A4 + US Letter compatibility:**

- A4 is 210 x 297 mm, US Letter is 216 x 279 mm
- Use `cm` or `mm` for page margins, not `px` (px is screen, unpredictable on paper)
- Keep content width comfortable at ~16cm — fits both formats with margin
- Avoid fixed widths in CSS for printable sections. Let them flow

**3. A visible "Print" button on the result screen:**

```html
<button onclick="window.print()">Print cheat sheet</button>
```

Test by opening the print preview (Ctrl+P) in Chrome and Firefox. Look at it as both A4 and Letter (the dropdown in print preview). Iterate on CSS until both look clean.

### Mobile screen view also matters

PROJECT.md says "readable on a phone (since the user will keep it open during the call)." That's a second target. Use a single-column responsive layout (`max-width: 720px; margin: 0 auto`), and the same CSS works for phone screen and printed page with the print media query layered on top.

## Suggested Build Order

This order builds the riskiest/most-defining pieces first and lets you validate the LLM contract before you've spent time on polish.

| # | Component | Why this order | Definition of done |
|---|-----------|----------------|---------------------|
| 1 | **HTML skeleton + screens** | Lets you see the shape of the app immediately; everything downstream attaches to these screens | Four `<section data-screen="...">` blocks exist with placeholder content. Manual screen switching via dev console works (`setState({screen:'result'})`) |
| 2 | **`appState` + `setState` + `render`** | The backbone everything else hangs from | You can toggle screens by mutating state. localStorage load/save works for API key |
| 3 | **Settings screen (API key entry)** | You need a key before you can call the LLM. Build the unblocker first | User can paste a key, pick provider, click save, see it persist across reload |
| 4 | **PROMPTS object + buildPrompt()** | Defines the JSON contract the renderer depends on. Lock this before building the renderer | Calling `buildPrompt('en', sampleIntake)` returns a sane system + user prompt pair |
| 5 | **LLM client (`callOpenAI`, `callGemini`)** | High risk: you don't know what each API actually returns until you call it. De-risk early | Hardcoded test prompt returns parsed JSON in console |
| 6 | **Cheat sheet renderer** | Now you have real LLM output to render. No mocking needed | Result screen displays a real generated sheet readably on desktop |
| 7 | **Intake form (EN first)** | Wires user input into state. Start with English only to ship faster | User can fill the form, click generate, see a real result |
| 8 | **Loading + error screens** | Polish the lifecycle. Now you've felt the 15-second wait and the 401 errors yourself | Loading shows immediately, errors are friendly, "try again" works |
| 9 | **ES and PT prompt variants** | Once EN works end-to-end, copy the template for the other two languages | Language switcher in intake works for all three |
| 10 | **Print stylesheet** | Once content structure is final, lay out the print version | Ctrl+P preview looks clean on both A4 and US Letter |
| 11 | **Mobile screen polish** | Final pass for phone readability | First real user can read the cheat sheet on their phone during a test call |
| 12 | **First real-user test** | Ship to the person in PROJECT.md who's actually calling the Migrationsamt | They complete a real call using v1 |

### Build-order dependencies

```
[1 HTML skeleton]
      ↓
[2 State + render]
      ↓
[3 Settings] ─┐
              ↓
       [4 PROMPTS] ──→ [5 LLM client] ──→ [6 Renderer]
                                              ↓
                                       [7 Intake form (EN)]
                                              ↓
                                       [8 Loading/error]
                                              ↓
                                       [9 ES + PT prompts]
                                              ↓
                                       [10 Print CSS]
                                              ↓
                                       [11 Mobile polish]
                                              ↓
                                       [12 First real user]
```

### Suggested phase mapping for the roadmap

These build steps cluster naturally into phases:

- **Phase 1 — Skeleton & state plumbing:** steps 1, 2, 3
- **Phase 2 — LLM round-trip (EN only, plain text):** steps 4, 5
- **Phase 3 — Structured cheat sheet rendering:** steps 6, 7, 8
- **Phase 4 — Multilingual intake:** step 9
- **Phase 5 — Print & mobile polish:** steps 10, 11
- **Phase 6 — Ship to first real user:** step 12

Phase 2 is the highest-risk phase (LLM API contracts, JSON parsing reliability). It deserves the deepest research before starting. Everything after Phase 2 is pretty standard DOM work.

## Anti-Patterns to Avoid

### Anti-Pattern 1: Reaching for a framework "just to be safe"

**What people do:** install React/Vue/Svelte "because state management gets hard"
**Why it's wrong:** breaks the constraint, adds a build step, slows the timeline, and the app is far too small to benefit. The `appState + render()` pattern handles this fine
**Do this instead:** trust the single state object. It scales to apps 10x this size

### Anti-Pattern 2: Sending the LLM call from a backend you build

**What people do:** spin up a tiny Node server to "hide the API key"
**Why it's wrong:** you don't have a key to hide — the user brings their own. A backend would cost money to host, break privacy posture, and miss the point
**Do this instead:** `fetch()` straight from the browser to OpenAI/Gemini

### Anti-Pattern 3: Rendering LLM output as `innerHTML`

**What people do:** `container.innerHTML = response` for convenience
**Why it's wrong:** any prompt injection or odd model output can inject script tags. Immigration users may already be cautious about data; an XSS-from-LLM story would be a credibility hit
**Do this instead:** parse JSON, render to DOM via `textContent` for all leaf text

### Anti-Pattern 4: Storing the API key in a URL or a cookie

**What people do:** `?apiKey=...` in the URL, or `document.cookie`
**Why it's wrong:** URLs leak to browser history and screenshots; cookies get sent with every request and can be exfiltrated by extensions
**Do this instead:** `localStorage` only, with a clear "Clear stored key" button in settings

### Anti-Pattern 5: Skipping schema validation on LLM JSON

**What people do:** `JSON.parse(response)` and immediately access deep fields
**Why it's wrong:** models occasionally drop fields, rename keys, or wrap output in prose. App crashes on first encounter
**Do this instead:** validate shape, fall back to "(missing)" placeholders, and offer "Try again"

### Anti-Pattern 6: Building all three languages before any one works end-to-end

**What people do:** localize the UI and translate prompts before validating the LLM pipeline
**Why it's wrong:** triples the surface area before you know the core flow works
**Do this instead:** ship the full pipeline in English first (step 7 in build order), then duplicate prompts for ES and PT

### Anti-Pattern 7: Designing for screen, printing later

**What people do:** treat print as a v2 nice-to-have
**Why it's wrong:** PROJECT.md says the user will keep the sheet open during the call, and printing is one of the natural ways. Retrofitting print styles after a content-heavy page is harder than designing semantic sections from day one
**Do this instead:** keep sections semantic and class-named from the start; print CSS is then a focused 50-line add at step 10

## Scaling Considerations

This is a single-user tool with zero backend, so traditional scaling does not apply. The relevant "scaling" axes are:

| Axis | Concern | Approach |
|------|---------|----------|
| Prompt size | LLM context limits, cost on user's key | Keep intake form bounded; truncate long notes to ~2000 chars |
| Output size | Sheet too long to print on one page | Constrain JSON schema: max N vocabulary items, max N questions |
| Languages | Going beyond EN/ES/PT | Add to `PROMPTS.userTemplate` map; UI language toggle is just a state field |
| Cantons (v2) | Other cantons want this | Add a canton field to `appState`, branch system prompt per canton |
| Interpreter mode (v2) | Realtime API, possibly a backend | This is when you'd revisit the single-file decision |

## Integration Points

### External Services

| Service | Integration Pattern | Notes |
|---------|---------------------|-------|
| OpenAI Chat Completions | `fetch('https://api.openai.com/v1/chat/completions', { headers: { Authorization: 'Bearer ' + key } })` | Use `response_format: { type: 'json_object' }` to force JSON. Costs the user money per call |
| Gemini generateContent | `fetch('https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=' + apiKey)` | Free tier is generous as of 2026. Use `responseMimeType: 'application/json'` |

Both APIs accept browser-origin requests (CORS-friendly). No proxy needed.

### Internal Boundaries

| Boundary | Communication | Notes |
|----------|---------------|-------|
| State ↔ DOM | Always through `render()` | Never mutate DOM outside render functions |
| Event handlers → State | Always through `setState()` | Never mutate `appState` directly |
| LLM → Renderer | Through validated JSON object on `appState.cheatSheet` | Validate shape before assigning |
| User input → LLM | Through `buildPrompt()` | Never concatenate raw user input into the system prompt without going through the template |

---
*Architecture research for: vanilla JS single-page LLM client (immigration call helper)*
*Researched: 2026-05-14*
