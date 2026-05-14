# Migrationsamt Zürich Call Helper

## What This Is

A single-page web tool that helps people in canton Zürich who do not speak German make better phone calls to the Migrationsamt (the cantonal migration office). The user describes their situation in English, Spanish, or Portuguese, and the tool generates a tailored German cheat sheet (key phrases, vocabulary, likely officer questions, and a prep checklist) that the user keeps in front of them while making the call themselves.

## Core Value

Eliminate the language barrier moment when a non-German speaker has to call the Migrationsamt about their permit, so the call actually achieves what the user came to do.

## Requirements

### Validated

(None yet, ship to validate)

### Active

- [ ] User can describe their situation through a guided intake (permit type, what they need, reference numbers, documents on hand) in English, Spanish, or Portuguese
- [ ] Tool generates a tailored cheat sheet for the call, including: likely officer greeting and meaning, key sentences to say in Standard German, relevant vocabulary, likely officer questions with suggested answers, and a prep checklist of documents and numbers
- [ ] Cheat sheet is printable and readable on a phone (since the user will keep it open during the call)
- [ ] User can paste their own LLM API key (OpenAI or Gemini) into the app, stored only in their browser, so the tool runs with zero hosting cost
- [ ] First real user (someone close to the developer, dealing with Zürich immigration) successfully uses it for an actual call this month

### Out of Scope

- AI dialing the Migrationsamt directly on the user's behalf, because Swiss recording law (Article 179bis StGB) and Migrationsamt practice make it not viable, and the engineering is months of full-stack work
- Live AI interpreter during the call (deferred to v2 as a possible add-on, not v1)
- Cantons other than Zürich, because procedures, phone numbers, and contact patterns differ canton by canton
- Languages beyond English, Spanish, and Portuguese, to keep v1 scope tight
- Permit advice or legal guidance, because giving paid immigration advice in Switzerland is regulated
- Federal SEM matters (asylum, citizenship), because those follow different procedures from cantonal migration
- A full knowledge base or FAQ about the Swiss immigration system, only just-enough context tied to the specific call
- Backend, accounts, server-side storage of user data, to keep privacy strong and hosting costs at zero
- Native mobile app, web only

## Context

- Built by a beginner frontend developer learning web dev as they go. Comfortable with vanilla HTML, CSS, and JavaScript. Will use Python or R occasionally but not for this project. No TypeScript.
- The developer has a person close to them currently navigating Zürich immigration who will be the first real user. Strong feedback loop, real stakes.
- Zürich Migrationsamt operates in Standard German over the phone (officers may default to Swiss German but switch to Hochdeutsch on request). Phone hours are limited and the office is busy.
- Existing tools in this space are either English-only expat blogs, official German-only government pages, or expensive immigration lawyers. The gap is in the moment of the phone call itself.
- Free LLM API tiers exist (Gemini has a generous free developer tier as of 2026) which means users can run the tool at zero cost using their own key.

## Constraints

- **Timeline**: The first real user should be using v1 for an actual call within this month
- **Tech stack**: Vanilla HTML, CSS, and vanilla JavaScript only. No frameworks, no build system, no TypeScript. Consistent with developer's other projects in this workspace
- **Budget**: Zero. No paid hosting, no paid APIs paid by the developer. User brings their own LLM API key
- **Privacy**: Immigration data is sensitive. Nothing leaves the user's browser except the single LLM API call to generate the cheat sheet. No analytics, no backend, no logs
- **Scope**: Canton Zürich only, three input languages only, one output language (German)
- **Legal**: The tool must not give legal advice, not impersonate the user, not contact authorities directly. It is a preparation aid, not a representative

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Path A+ (cheat sheet, no live AI on the call) for v1 | Simplest version that delivers real value, fully buildable as a static webapp, ships fastest, sidesteps Swiss recording law | Pending |
| Vanilla HTML/CSS/JS, no framework | Matches developer's skills, no build system needed, matches the workspace's other projects | Pending |
| User brings their own LLM API key, stored in browser only | Zero hosting costs, strong privacy posture, no backend to maintain, no API costs for the developer | Pending |
| Canton Zürich only for v1 | Cantonal migration offices vary, scoping to one keeps content accurate and lets the first real user (in Zürich) benefit | Pending |
| Three input languages only (EN, ES, PT) for v1 | Covers a large underserved population in Zürich while keeping translation prompts tight | Pending |
| Out: AI dialing the office | Swiss recording law makes consent practically impossible, Migrationsamt will not engage with AI representatives, and the engineering is months of work | Pending |
| Out: live AI interpreter for v1 | Bigger engineering leap (Realtime API, backend) that would push past the one-month timeline. Reasonable stretch for v2 | Pending |

### 2026-05-14: Phase 0 CORS spike outcome (Anthropic, desktop Chrome)

**Result: pass.**

What was tested: a single-file static HTML page (`spike/index.html`), deployed to GitHub Pages from the `master` branch root and served at `/spike/`, called the Anthropic Messages API directly from the browser. The request used the `anthropic-dangerous-direct-browser-access: true` header along with `x-api-key` and `anthropic-version: 2023-06-01`, and posted a Migrationsamt-shaped translation prompt asking for a Standard German rendering of "I would like to renew my B residence permit. My case reference number is ZH-12345." Tested in desktop Chrome only.

The response came back with HTTP 200 and the verbatim German completion: "Ich möchte meine B-Aufenthaltserlaubnis erneuern. Meine Geschäftsreferenznummer ist ZH-12345." No CORS preflight failure was observed, and the dangerous-direct-browser-access header was accepted by Anthropic.

Model swap during execution: the plan suggested `claude-3-5-haiku-latest`, but that model id returned a 404 at runtime (the model has been retired). The executor swapped to `claude-haiku-4-5` (commit `1418075`) and the retest passed. Phase 1 planning should pick a current model id and avoid `claude-3-5-haiku-latest`.

Architecture commit for Phase 1:

- v1 builds against direct browser `fetch` to Anthropic, per D-01. No backend, no proxy.
- KEY-04 (provider toggle between Gemini and OpenAI) is obsolete and will be removed from REQUIREMENTS.md when Phase 1 is planned.

Scope note: this result is desktop-Chrome-only and Anthropic-only (per D-02, D-05). It does not say anything about Gemini, OpenAI, or iOS Safari, all of which remain out of v1 scope.

## Evolution

This document evolves at phase transitions and milestone boundaries.

**After each phase transition** (via `/gsd-transition`):
1. Requirements invalidated? Move to Out of Scope with reason
2. Requirements validated? Move to Validated with phase reference
3. New requirements emerged? Add to Active
4. Decisions to log? Add to Key Decisions
5. "What This Is" still accurate? Update if drifted

**After each milestone** (via `/gsd-complete-milestone`):
1. Full review of all sections
2. Core Value check, still the right priority?
3. Audit Out of Scope, reasons still valid?
4. Update Context with current state

---
*Last updated: 2026-05-14 after initialization*
