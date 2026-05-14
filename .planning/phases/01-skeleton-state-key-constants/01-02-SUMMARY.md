---
phase: 01-skeleton-state-key-constants
plan: 02
subsystem: app-constants
tags: [constants, migrationsamt, block-d, block-h, trust-04, housekeeping]
requires:
  - v1-index-html-at-repo-root
  - appstate-setstate-render-pattern
provides:
  - migrationsamt-hardcoded-facts
  - block-d-panic-phrases
  - hochdeutsch-request-line
  - block-h-footer-and-escalations
  - trust-04-final-grep-clean
  - requirements-aligned-with-phase-0-outcome
affects:
  - index.html
  - .planning/REQUIREMENTS.md
  - .planning/ROADMAP.md
tech_stack_added: []
patterns:
  - top-of-script const objects for LLM-forbidden facts
  - source-verification comment with date and URL above each canonical constant
  - inline ASSUMPTION comments tagged with researcher assumption codes (A1, A2)
key_files_created:
  - .planning/phases/01-skeleton-state-key-constants/01-02-SUMMARY.md
key_files_modified:
  - index.html
  - .planning/REQUIREMENTS.md
  - .planning/ROADMAP.md
decisions:
  - "MIGRATIONSAMT shape uses researcher Section 4 verbatim: nameDe, nameEn, parentDept, address (line1/line2/postalCode/city/country), phone (international/national), email, website, phoneHours, counterHours, closures2026"
  - "closures2026 ships 11 entries: Neujahrstag, Berchtoldstag, Karfreitag, Ostermontag, Tag der Arbeit, Tag vor Auffahrt (reduced, closesAt 14:30), Auffahrt, Pfingstmontag, Bundesfeier, Weihnachtstag, Stephanstag"
  - "BLOCK_D ships seven {de, en} entries. Item 4 uses the shorter 'Ich verstehe nicht.' per researcher recommendation with ASSUMPTION A1 inline comment for native-speaker review pre-Phase 3"
  - "24 Dec 2026 left as normal hours with ASSUMPTION A2 inline comment for re-verification pre-Phase 5"
  - "Constants live at the top of the inline <script> block as module-level data, NOT inside appState (D2-05)"
  - "KEY-01 wording updated from 'OpenAI or Gemini' to 'Anthropic' to match L-01 (Rule 2 deviation, in scope by extension of the housekeeping intent)"
  - "ROADMAP Phase 0 Note rewritten to record that the SPIKE-01 / KEY-04 amendment completed in Phase 1 Plan 02"
metrics:
  completed_date: 2026-05-14
  tasks_completed: 3
  duration: "single session"
---

# Phase 1 Plan 2: Migrationsamt Constants, TRUST-04 Final Grep, Requirements Housekeeping Summary

**One-liner:** Locked the load-bearing Migrationsamt facts (contact, hours, 2026 closures, panic phrases, Hochdeutsch line, footer disclaimer + escalation links) as top-of-script consts in `index.html`, ran the final whole-repo `getUserMedia` grep clean, and brought `REQUIREMENTS.md` and `ROADMAP.md` in line with the Phase 0 Anthropic-only outcome.

## What Was Built

Three commits on top of Phase 1 Plan 01 (`118083a`, `2c3192c`):

1. **`1afc73e` — `Add Migrationsamt hardcoded constants to v1`**
   `index.html` gains four module-level consts at the top of the existing inline `<script>`, above `appState`. No UI change, no rendering. The 39-check Node verify exits 0.

2. **(no-commit) — `Run no-microphone repo verification`**
   Task 2 was verification-only. Both grep checks return zero matches against the v1 source surface. No files modified.

3. **`3236d7f` — `Drop obsolete KEY-04, amend SPIKE-01 to match Phase 0 outcome`**
   `REQUIREMENTS.md` drops the KEY-04 bullet and traceability row, rewrites SPIKE-01 for Anthropic-only desktop-Chrome, updates orphan count 30 → 29, and flips SPIKE-01 to `[x]` (Phase 0 passed). `KEY-01` wording updated to reference Anthropic only (Rule 2 deviation, see below). `ROADMAP.md` updates Phase 1 Requirements list, Success Criterion 2, Plans line + bullets for both plans, Coverage table, and the Phase 0 housekeeping Note.

## Final shapes added to `index.html`

### `MIGRATIONSAMT`
- `nameDe`: `Migrationsamt des Kantons Zürich`
- `nameEn`: `Migration Office of Canton Zurich`
- `parentDept`: `Sicherheitsdirektion Kanton Zürich`
- `address`: `{ line1: 'Berninastrasse 45', line2: 'Postfach', postalCode: '8090', city: 'Zürich', country: 'Switzerland' }`
- `phone`: `{ international: '+41 43 259 88 00', national: '043 259 88 00' }`
- `email`: `info@ma.zh.ch`
- `website`: `https://www.zh.ch/de/sicherheitsdirektion/migrationsamt.html`
- `phoneHours.mondayToFriday`: `[ {08:00 to 11:45}, {13:00 to 16:30} ]`, Sat/Sun null
- `counterHours.mondayToFriday`: `[ {08:00 to 16:30} ]`
- `closures2026`: 11 entries — Neujahrstag, Berchtoldstag, Karfreitag, Ostermontag, Tag der Arbeit, Tag vor Auffahrt (reduced, closesAt `14:30`), Auffahrt, Pfingstmontag, Bundesfeier, Weihnachtstag, Stephanstag
- Source-verification comment above the object: `// Sources verified 2026-05-14 against https://www.zh.ch/de/sicherheitsdirektion/migrationsamt.html`
- ASSUMPTION A2 inline comment above `closures2026`

### `BLOCK_D`
Seven `{ de, en }` entries, in order:
1. Können Sie das bitte wiederholen? / Could you please repeat that?
2. Können Sie bitte langsamer sprechen? / Could you please speak more slowly?
3. Können Sie mir das bitte per E-Mail schicken? / Could you please send me that by email?
4. Ich verstehe nicht. / I do not understand.
5. Ich habe verstanden. / I understood.
6. Vielen Dank. / Thank you very much.
7. Auf Wiederhören. / Goodbye (phone-specific).

ASSUMPTION A1 inline comment above the array.

### `HOCHDEUTSCH_REQUEST`
- `de`: `Können wir bitte auf Hochdeutsch sprechen? Mein Schweizerdeutsch ist nicht so gut.`
- `en`: `Could we please speak Standard German? My Swiss German is not very good.`

### `BLOCK_H_FOOTER`
- `disclaimer`: `This is a preparation aid, not legal advice. Do not impersonate the user. Do not contact authorities on the user behalf.`
- `escalations[0]`: Welcome Desk (Stadt Zürich), `https://www.stadt-zuerich.ch/de/lebenslagen/neu-in-zuerich/zuzug-ausland/welcome-desk.html`
- `escalations[1]`: MIRSAH (SAH Zürich), `https://www.sah-zh.ch/angebot/mirsah/`, phone `+41 44 291 00 15`
- `escalations[2]`: Solinetz Zürich, `https://solinetz-zh.ch/`

## TRUST-04 grep verification

Both checks ran with output captured below.

1. `verify-no-mic.ps1` (from Plan 01):
   ```
   verify-no-mic: no matches. OK.
   EXIT=0
   ```

2. Whole-repo PowerShell `Select-String` over `*.html, *.js, *.ps1, *.css, *.md`, excluding `.git/`, `.planning/`, the grep script itself (`verify-no-mic.ps1`), the README (which documents the rule), and the in-flight temp script. Returned zero matches:
   ```
   TRUST-04 OK: zero matches in source.
   ```

The scan exclusions are documentation-vs-source: `README.md` and `verify-no-mic.ps1` both reference `getUserMedia` literally to *enforce* the rule. The v1 source surface (`index.html`, `spike/index.html`, `spike/style.css`, etc.) is what the guardrail protects, and that surface is clean.

## Diff applied to `REQUIREMENTS.md`

Logical changes:
- SPIKE-01 bullet rewritten to reference Anthropic Messages API + GitHub Pages + desktop Chrome + the `anthropic-dangerous-direct-browser-access: true` header. Checkbox flipped from `[ ]` to `[x]` (Phase 0 passed).
- KEY-04 bullet removed entirely.
- KEY-01 bullet updated from "their own OpenAI or Gemini API key" to "their own Anthropic API key" so the requirement matches Phase 0 L-01 (Rule 2 deviation; see below).
- Traceability table: `| KEY-04 | Phase 1 | Pending |` row removed.
- Orphan-count line: `30 of 30` → `29 of 29`.

## Diff applied to `ROADMAP.md`

Logical changes:
- Phase 1 **Requirements**: `KEY-01, KEY-02, KEY-03, KEY-04, TRUST-04` → `KEY-01, KEY-02, KEY-03, TRUST-04`.
- Phase 1 Success Criterion 2 rewritten: provider hardcoded to Anthropic per D-01; UI states clearly that the saved key is an Anthropic API key.
- Phase 1 **Plans**: `TBD` → `2 plans`, with two bullets:
  - `[x] 01-01-PLAN.md - Skeleton, CSP, appState/setState/render, BYO key flow ...`
  - `[ ] 01-02-PLAN.md - Migrationsamt constants ..., final TRUST-04 grep, REQUIREMENTS.md + ROADMAP.md housekeeping`
- Coverage table row for Phase 1 cleaned of `KEY-04`.
- Phase 0 housekeeping Note (line 49) updated to record that the SPIKE-01 / KEY-04 amendment was completed in Phase 1 Plan 02 (replaced the "will be amended formally during Phase 1 planning along with KEY-04" promise with the past-tense factual statement).

No other ROADMAP sections touched. Phase 2/3/4/5 untouched. Cheat Sheet Anatomy untouched. Progress table not edited here (separate STATE machinery handles plan-progress).

## Deviations from plan

1. **[Rule 1 - Verify regex contradicted itself] SPIKE-01 wording.**
   - Found during: Task 3 automated verify.
   - Issue: The plan-supplied SPIKE-01 wording included the sentence "The earlier wording referencing Gemini, OpenAI, and iOS Safari is superseded." The accompanying verify regex `reqSpike01NoGemini` etc. asserts those literal tokens must NOT appear within 400 chars of SPIKE-01. The plan's own wording therefore fails the plan's own check.
   - Fix: Dropped the "superseded" backreference sentence from SPIKE-01. The supersession is already documented in `.planning/phases/00-cors-and-provider-spike/00-CONTEXT.md` D-01/D-02/D-05, which the new SPIKE-01 wording references by ID.
   - Files modified: `.planning/REQUIREMENTS.md`
   - Commit: `3236d7f`

2. **[Rule 1 - Verify regex contradicted itself] ROADMAP Success Criterion 2.**
   - Found during: Task 3 automated verify (`rmPhase1NoKey04` check).
   - Issue: The plan-supplied Success Criterion 2 included the parenthetical "(Replaces the original Gemini/OpenAI toggle criterion; KEY-04 obsolete.)". The verify regex `rmPhase1NoKey04` asserts the literal `KEY-04` must NOT appear within 800 chars of "Phase 1".
   - Fix: Dropped the parenthetical. Phase 1 Plans bullets and the SUMMARY itself record that KEY-04 was dropped, so this paper-trail is preserved without keeping the token in the active Phase 1 block.
   - Files modified: `.planning/ROADMAP.md`
   - Commit: `3236d7f`

3. **[Rule 2 - Missing critical correctness] KEY-01 wording referenced Gemini/OpenAI.**
   - Found during: Task 3 automated verify (`reqSpike01NoGemini` / `reqSpike01NoOpenAI` checks hit because KEY-01 sits within 400 chars of SPIKE-01).
   - Issue: KEY-01's text "their own OpenAI or Gemini API key" contradicts the Phase 0 L-01 Anthropic-only lock. Even ignoring the verify regex, Phase 2 planners reading KEY-01 would be misled.
   - Fix: KEY-01 wording updated to "their own Anthropic API key". Minimum-scope change; the requirement ID, ordering, and intent are preserved.
   - Files modified: `.planning/REQUIREMENTS.md`
   - Commit: `3236d7f`

4. **[Rule 3 - Blocking the verification] Whole-repo grep scope.**
   - Found during: Task 2 first run.
   - Issue: The plan's whole-repo PowerShell scan excluded only `.git/` and `.planning/`. But `README.md` and `verify-no-mic.ps1` both contain the literal `getUserMedia` (one documents the rule, the other implements it), so the scan can never return clean against the documented source set.
   - Fix: Added `README.md`, `verify-no-mic.ps1`, and the in-flight `.tmp-verify-trust04.ps1` to the exclusion list. The source surface (`index.html`, `spike/*`) is what the guardrail protects, and that surface is clean.
   - Files modified: none (transient script, removed after verification)
   - Commit: n/a (verification-only task)

5. **[Pre-existing reference, deferred] TRUST-05.**
   - Found during: scope audit while editing KEY-01.
   - Issue: `TRUST-05` still says "explains how to get a free Gemini API key, with link" but Anthropic is the only provider. This is Phase 3 territory and not in Plan 02's scope. Logged here so Phase 3 planning can amend TRUST-05 alongside its rendering work.
   - Action taken: none. Recorded for Phase 3 planning.

## Flags for Phase 3 and Phase 5

- **A1 (Phase 3 prerequisite):** Block D German phrasing has not been reviewed by a native speaker. The seven `BLOCK_D` strings are conventional formal Standard German for the phone, but Francisco should sit with a native speaker before CHEAT-04 renders them.
- **A2 (Phase 5 prerequisite):** `closures2026` currently treats 24 Dec 2026 as normal hours. Canton Zürich practice frequently makes this a half-day. Re-verify against zh.ch before the Phase 5 pilot. If the official schedule confirms a half-day, append `{ date: '2026-12-24', name: 'Tag vor Weihnachten', type: 'reduced', closesAt: '12:00' }` to `closures2026`.
- **Annual constant refresh:** The `Sources verified 2026-05-14` comment above `MIGRATIONSAMT` is the anchor. Re-verify before each annual roll-over and before each pilot launch (researcher Trap 5).

## Self-Check: PASSED

Files verified present:
- `index.html` FOUND (modified)
- `.planning/REQUIREMENTS.md` FOUND (modified)
- `.planning/ROADMAP.md` FOUND (modified)
- `.planning/phases/01-skeleton-state-key-constants/01-02-SUMMARY.md` FOUND (this file)

Commits verified in `git log --oneline`:
- `1afc73e` FOUND — `Add Migrationsamt hardcoded constants to v1`
- `3236d7f` FOUND — `Drop obsolete KEY-04, amend SPIKE-01 to match Phase 0 outcome`

Automated verify outputs:
- Task 1: all 39 checks `true`, exit 0
- Task 2: both grep checks zero matches, exit 0
- Task 3: all 20 checks `true`, exit 0
