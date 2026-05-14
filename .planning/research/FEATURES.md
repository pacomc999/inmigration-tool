# Feature Research: Migrationsamt Zürich Call Helper

**Domain:** Bureaucratic phone-call preparation aid for non-German speakers in canton Zürich
**Researched:** 2026-05-14
**Confidence:** HIGH for Zürich factual data (official zh.ch sources), MEDIUM for assumed user behaviour patterns (no first-party user interviews yet)
**Research mode:** Ecosystem / Features

---

## 1. Cheat Sheet Anatomy

This is the single most important artefact the product generates. The cheat sheet is the entire deliverable. It must be skimmable while the phone rings, usable during the call, and printable on one to two A4 pages.

Recommended structure, ordered top-to-bottom as the user will read it during the call:

### Block A: Call Header (always visible at top)

| Element | Content | Why |
|---------|---------|-----|
| Office name and phone | "Migrationsamt Kanton Zürich, 043 259 88 00" | User dials from the sheet itself |
| Best call window | "Mo to Fr, 08:00 to 12:00 and 13:00 to 16:30" | Avoid wasted calls outside hours |
| Today's goal in user's language | One sentence, e.g. "Ask why my B permit renewal is delayed" | Anchors the user when stressed |
| User's reference data | Name, date of birth, ZEMIS / Personennummer if known, current address | Officer will ask within first 30 seconds |

### Block B: Opening Script (German, with phonetic-friendly notes)

A literal script the user reads:

1. Greeting: "Grüezi, mein Name ist [Name]." (Swiss-friendly opener, accepted everywhere)
2. Language ask: "Entschuldigung, mein Deutsch ist nicht so gut. Können Sie bitte langsam und auf Hochdeutsch sprechen?" (Critical: officers may default to Swiss German; Hochdeutsch is the standard fallback)
3. Reason for call in one sentence: generated from intake, e.g. "Ich rufe an wegen der Verlängerung meiner Aufenthaltsbewilligung B."
4. Reference number line: "Meine Referenznummer ist [N]."

Each German line shows the user-language translation directly underneath in smaller text. No IPA phonetics in v1 (overkill, clutter). Optional audio playback is a v1.x differentiator (see below).

### Block C: Likely Officer Questions and Suggested Answers

Two-column German / user-language. Generated based on intake topic. Examples for a B-permit-renewal call:

| Likely question (DE) | Meaning | Suggested answer template |
|---------------------|---------|---------------------------|
| "Wie ist Ihr Name und Ihr Geburtsdatum?" | Your name and date of birth? | "[Name], geboren am [Datum]." |
| "Haben Sie die Verfallsanzeige bereits erhalten?" | Did you already get the expiry notice? | "Ja, ich habe sie erhalten / Nein, ich habe sie nicht erhalten." |
| "Arbeiten Sie zurzeit?" | Are you currently working? | "Ja, bei [Arbeitgeber] seit [Datum]." |
| "Haben Sie schon einen Termin gebucht?" | Have you booked an appointment? | "Nein, noch nicht / Ja, am [Datum]." |

For each question, two suggested answers: an affirmative and a negative form, so the user picks live.

### Block D: Key Phrases to Have Ready (panic buttons)

Short, high-value sentences for moments when comprehension breaks:

- "Können Sie das bitte wiederholen?" (Can you repeat that please?)
- "Können Sie das bitte langsamer sagen?" (Can you say that more slowly?)
- "Können Sie mir das per E-Mail oder per Kontaktformular schicken?" (Can you send that to me by email or contact form?)
- "Ich verstehe das Wort [X] nicht. Was bedeutet das?" (I don't understand the word X. What does it mean?)
- "Ich habe das verstanden, vielen Dank." (I understood that, thank you.)
- "Auf Wiederhören." (Goodbye, phone-specific)

### Block E: Vocabulary Mini-Glossary

Six to twelve domain words relevant to the user's specific call, with article and translation. Examples:

| German | Article | EN / ES / PT |
|--------|---------|--------------|
| Aufenthaltsbewilligung | die | Residence permit / Permiso de residencia / Autorização de residência |
| Verlängerung | die | Renewal / Renovación / Renovação |
| Termin | der | Appointment / Cita / Marcação |
| Verfallsanzeige | die | Expiry notice / Aviso de vencimiento / Aviso de vencimento |
| Biometrie / biometrische Daten | die | Biometrics / Datos biométricos / Dados biométricos |
| Ausländerausweis | der | Foreign national ID card / Tarjeta de extranjero / Cartão de estrangeiro |
| Sachbearbeiter / Sachbearbeiterin | der / die | Case officer / Funcionario / Funcionário |
| Gebühr | die | Fee / Tasa / Taxa |

Articles matter because they show up in officer speech ("die Verfallsanzeige") and help recognition.

### Block F: Prep Checklist (read before dialing)

- [ ] Passport or ID card in hand
- [ ] Current Ausweis (foreign national ID) in hand
- [ ] Verfallsanzeige if received
- [ ] Employment contract / Lohnabrechnung if topic is work
- [ ] Phone fully charged, quiet room
- [ ] Pen and paper for the officer's reply (dates, reference numbers)
- [ ] This cheat sheet open in front of you

### Block G: Note-Taking Lines (printable only)

Three to five blank lines labelled in user's language: "Officer's name", "Next step", "Date / deadline", "Reference number given", "Other".

### Block H: Footer Safety Notice

Plain sentence in user's language, e.g. "This sheet was generated by an AI tool. It is preparation help, not legal advice. The Migrationsamt is the only authoritative source for your case." Keep it small but always present.

---

## 2. Intake Flow

Goal: minimum questions to generate a targeted cheat sheet. Anything optional is optional. A user mid-stress should be able to skip to a usable sheet within 60 seconds.

Recommended five-step intake:

**Step 1: Language**
- Choose: English / Español / Português
- One control, big buttons

**Step 2: Permit context (helps but not required)**
- Current permit type: L / B / C / Ci / G / N / F / Other / "I don't know"
- Why this matters: a B-permit-renewal call has totally different vocabulary than a Ci-family-member call. Officers ask different questions per category.

**Step 3: Reason for the call (the most important field)**
- Pick a primary topic from a curated list (radio buttons), with a free-text field below for nuance:
  - Renewing a permit (Aufenthaltsbewilligung verlängern)
  - Checking status of a pending application
  - Booking, changing, or asking about a biometrics appointment
  - Changing employer or work situation
  - Family reunification (Familiennachzug) question
  - Address change or moving within / out of canton
  - Travel question (e.g. permit allows leaving Switzerland?)
  - Lost or stolen Ausweis
  - Asking what documents to bring
  - Other (free text only)
- Curated list = the cheat sheet generator knows which question bank and vocabulary set to load.

**Step 4: Reference data (optional but high-value)**
- Free-text fields, all optional:
  - Name as on permit
  - Date of birth
  - ZEMIS / Personennummer / case reference (any of these)
  - Current employer (if work-related)
  - Date of an existing appointment or deadline (if any)
- Display a "stored only in your browser, never sent except in the LLM prompt" note next to this section.

**Step 5: Free-text "describe the situation"**
- One big textarea in the user's language: "In your own words, what is happening and what do you want from this call?"
- This is the secret sauce. The LLM uses this to tailor the suggested questions and answers. Without it, the sheet is generic.
- Placeholder example, localised: "My B permit expires in 3 weeks, I haven't received the Verfallsanzeige, I started a new job last month and I want to ask if I need to do anything special."

**Generate button** at the bottom. After generation, the user lands on the cheat sheet view (Block A through H above) and can:
- Print
- Adjust intake and regenerate
- Switch to a phone-friendly compact view

---

## 3. Table Stakes

Without these, the tool fails to deliver its core promise.

| Feature | Why Expected | Complexity | Notes |
|---------|--------------|------------|-------|
| Three-language intake (EN / ES / PT) | The whole product premise | S | Static i18n strings, no runtime translation needed |
| Permit-type selector with L / B / C / Ci / G / N / F / Other | Different categories produce different officer questions; without this, the sheet is generic | S | Static dropdown |
| Reason-for-call picker with the curated topic list above | Without topic, cheat sheet content is unfocused | S | Static radio group |
| Free-text "describe your situation" field | The only way the LLM can tailor content beyond template | S | Plain textarea |
| LLM API key field (OpenAI or Gemini), stored in localStorage | No backend, zero hosting cost mandate | S | Provider toggle plus key input; warning that key is stored locally only |
| Generate-cheat-sheet button calling the user's LLM with a structured prompt | Core function | M | Prompt engineering and JSON schema parsing are the real work |
| Cheat sheet output in Standard German with the user's language as glosses | The point of the product | M | Output shape comes from prompt schema |
| Migrationsamt phone number and current hours visible on the sheet | First thing the user needs | S | Hardcoded constants |
| Print-friendly stylesheet (A4, one to two pages) | User keeps it physically next to phone | S | CSS print media query |
| Phone-readable compact view | User may keep sheet open on phone while on call (speakerphone) | S | Responsive CSS |
| Disclaimer footer ("preparation aid, not legal advice") | Legal safety | S | Static text in user's language |
| Opening script with the Hochdeutsch language-request line | Officers may default to Swiss German; without this line many users will not understand the start of the call | S | Always-included block |
| Officer-likely-questions block (DE plus translation plus suggested answer) | The high-value content | M | Generated by LLM from intake |
| Mini-glossary (six to twelve domain terms) | Comprehension during the call | M | Generated by LLM from intake topic |
| Prep checklist of documents | Most callers forget at least one document; check prevents wasted call | S | Generated by LLM with a base list per topic |
| Note-taking lines on the printed sheet | User must record the officer's reply somewhere | S | Static lines |

---

## 4. Differentiators

These elevate the tool above a generic Google-Translate or ChatGPT-copy-paste workflow.

| Feature | Value Proposition | Complexity | Notes |
|---------|-------------------|------------|-------|
| Topic-aware question bank | Cheat sheet for "renew B permit" differs sharply from "lost Ausweis" or "Familiennachzug query"; the LLM prompt loads a topic-specific template | M | Topic to prompt-template map maintained in JS object |
| Hochdeutsch-request line included by default | Specifically addresses the Swiss German vs Hochdeutsch reality on the phone; expat blogs mention this constantly but no tool encodes it | S | Always-on opening block |
| Two-column DE / user-language layout throughout | Easier to follow in real time than monolingual cheat sheets; user can glance to either column | S | CSS grid |
| Suggested answers come in affirmative and negative forms | The user does not know in advance which the officer will accept; both forms removes a freeze point | S | Prompt-driven |
| "Panic phrases" block (repeat, slower, send by email) | These are the lifesavers when the call goes off-script | S | Static block always included |
| Pre-call checklist that pulls in the user's stated documents | Personalised checklist ("you mentioned a new job: have payslip ready") beats a generic list | S | Generated by LLM |
| Saves the last generated sheet to localStorage | If the user has to recall, they can reopen without regeneration cost | S | localStorage key |
| Regenerate with one tweak (changes intake, keeps key data) | The first sheet is rarely perfect; cheap iteration matters | S | Intake stays in state |
| Provider toggle (Gemini free tier or OpenAI) with model selector | Lets users pick the free Gemini path; lowers friction | S | Provider abstraction in a single fetch function |
| Audio playback of key German phrases via SpeechSynthesis API | Hearing "Verfallsanzeige" once before the call cuts comprehension friction; browser-native, zero cost | M | Web Speech API, German voice selection is fiddly |
| "Copy as text" button so the user can paste the sheet into another device | Some users will read on phone but generate on laptop | S | Clipboard API |
| QR-code-to-phone handoff of the generated sheet | Generate on laptop, scan with phone, read during call | M | QR encodes a localStorage hash or a long URL fragment |
| Post-call reflection prompt ("did the officer ask anything new? add it") | Builds a community-improving template over time | M | localStorage, optional manual export |
| Print preview shows page count before printing | One vs two pages matters when the user is at a print shop | S | CSS or simple count |
| Holiday and reduced-hours notice banner | E.g. "Note: 13 May 2026 the office closes at 14:30; 14 May closed all day" | S | Hardcoded date table, render conditionally based on system date |

---

## 5. Anti-Features

Deliberately not built. Each one is a temptation that harms the product, the user, or both.

| Anti-Feature | Why Tempting | Why Not | Alternative |
|--------------|--------------|---------|-------------|
| AI dials and speaks to the officer on the user's behalf | Sounds like the ideal product | Swiss recording law (Art. 179bis StGB) makes recorded calls without all-party consent illegal; Migrationsamt will not engage with AI representatives; massive engineering | Generate the cheat sheet, user makes the call themselves |
| Live AI interpreter during the call | Powerful UX | Needs Realtime API, backend, microphone capture, push-to-translate UX; same recording-law issue if call audio is captured; pushes past one-month timeline | Defer to a possible v2; v1 is preparation only |
| Legal advice or interpretation of permit rules | LLMs will happily produce this | Giving paid immigration advice in Switzerland is regulated; wrong advice harms users with real legal consequences; product liability risk | Footer disclaimer, refer to MIRSAH and Welcome Desk Zürich for free certified advice |
| Promises about outcome ("you will get your permit renewed") | Reassuring | Outcome is the officer's call, not the tool's; false reassurance erodes trust on first failure | Frame as "preparation", never "outcome" |
| Storing user data on a server | Convenience (resume on another device) | Immigration data is sensitive; backend means hosting cost, GDPR / DSG obligations, breach risk | localStorage only; QR-handoff for cross-device use |
| Sending user data anywhere except the single LLM API call | Analytics, telemetry, "improve the model" | Same privacy reasons; users in vulnerable status will not trust the tool | No analytics, no third-party scripts, period |
| Impersonating the user (saying "I am calling on behalf of") | Felt-sense of helpfulness | The cheat sheet is for the user to read; tool must never produce content framed as if the tool itself is the caller | Always second-person: "you say", never "I say on your behalf" |
| Recording the user's call for later transcription | Useful in theory | Art. 179bis StGB; consent from the officer is functionally impossible | If the user wants notes, they handwrite on Block G |
| Coverage of other cantons | Bigger market | Procedures, phone numbers, vocabulary differ; one wrong number kills trust | Explicit "Canton Zürich only" banner; defer expansion |
| Coverage of federal SEM matters (asylum, citizenship) | Adjacent topic | Different office, different procedures, different vocabulary; mixing them confuses users | Out-of-scope notice with link to SEM contact page |
| Generic translation feature ("translate anything") | Easy to add | Dilutes the product; Google Translate exists | Stay focused on the call-prep job |
| Real-time chat with the user (chatbot UX) | Trendy | The user's task is "prepare for a phone call in 30 minutes", not "chat"; chat hides the deliverable | Form intake plus generated sheet; no chat |
| Account system / login | Standard SaaS pattern | Zero-backend mandate; nothing to gain | localStorage |
| Asking for documents to be uploaded | Could allow OCR of the Verfallsanzeige | Hugely raises privacy stakes; OCR adds complexity and failure modes | User types reference numbers manually; takes 10 seconds |
| Push notifications / reminders | Sticky | Out of scope, no backend, browser permission friction | Optional plain text "remember to call before 16:30" within the sheet |
| Promising the cheat sheet is "officially approved" | Authority bump | False; no endorsement exists | Footer makes the tool's status explicit |

---

## 6. Zürich-Specific Reference Data

Factual data the cheat-sheet generator must know. Hardcode these as constants in the app. All sourced from official zh.ch and SEM pages.

### Office contact

| Field | Value |
|-------|-------|
| Office name | Migrationsamt des Kantons Zürich |
| Address | Berninastrasse 45, 8090 Zürich |
| Phone | +41 43 259 88 00 |
| Counter hours | Mo to Fr, 08:00 to 16:30 |
| Telephone hours | Mo to Fr, 08:00 to 12:00 and 13:00 to 16:30 |
| Website | https://www.zh.ch/de/sicherheitsdirektion/migrationsamt.html |
| Contact form (alternative to phone) | https://www.zh.ch/de/migration-integration/kontaktformularmigrationsamt.html |

Confidence: HIGH (zh.ch official, search.ch corroboration).

### Known short-hours and closure dates (rolling, must be reviewed manually)

| Date | Effect | Source |
|------|--------|--------|
| Wed 13 May 2026 | Counters and phone close at 14:30 | zh.ch announcement |
| Thu 14 May 2026 (Auffahrt / Ascension) | Office fully closed | zh.ch announcement, public holiday |

The tool should ship with a small calendar object of known short days and Swiss public holidays. v1 can hardcode 2026; later versions should pull from a maintained list.

### Permit categories the cheat sheet generator must distinguish

Confidence: HIGH (SEM and ch.ch).

| Code | Name | Typical holders | Common call topics |
|------|------|-----------------|-------------------|
| L | Kurzaufenthaltsbewilligung | Short-term workers, students under one year, sometimes extendable up to 24 months | Extension, conversion to B, change of employer |
| B | Aufenthaltsbewilligung | Longer-term residents (EU/EFTA: usually 5 years; non-EU: 1 year renewable) | Renewal (most common), change of job, family reunification, address change |
| C | Niederlassungsbewilligung | Permanent residents (typically after 10 years; 5 for EU/EFTA and some bilateral countries like US/CA) | Re-issuance, biometrics update, after long absence |
| Ci | Aufenthaltsbewilligung Ci | Spouses and children of diplomats / international organisation staff | Work permission questions, renewal tied to principal holder |
| G | Grenzgängerbewilligung | Cross-border workers commuting from neighbour countries | Renewal, change of employer |
| F | Vorläufig aufgenommene Personen | Temporarily admitted | Renewal, travel restrictions |
| N | Asylsuchende | Asylum seekers (SEM-managed, not cantonal for most matters) | Mostly out of scope; refer to SEM |
| S | Schutzbedürftige | Persons under temporary protection (e.g. Ukraine context) | Renewal, change of address, work permission |

### Common call topics observed in Zürich (corroborated by ETH, UZH, zh.ch and Stadt Zürich pages)

1. **Permit renewal (Aufenthaltsbewilligung verlängern)** — the single most common reason. Verfallsanzeige arrives from SEM 2 to 3 months before expiry. Must apply at least 14 days before expiry.
2. **Biometrics appointment** (booking, rescheduling). Use the dedicated "Biometrietermin verschieben" page where possible.
3. **Address change / move within canton**.
4. **Change of employer or change in work situation** (especially for non-EU B permits).
5. **Family reunification (Familiennachzug)** — eligibility and document questions.
6. **Status of a pending decision** (where is my case at?).
7. **Lost or damaged Ausweis**.
8. **Travel / re-entry questions**, especially for long absences.
9. **Required documents** ("what should I bring to my appointment?").

Confidence: HIGH for top three, MEDIUM for the rest (inferred from ETH and UZH FAQs plus Stadt Zürich Ausländerausweis pages).

### Documents most often referenced on a Migrationsamt call

| German term | Meaning | Typical relevance |
|-------------|---------|-------------------|
| Reisepass / Pass | Passport | Always |
| Identitätskarte | National ID card (EU/EFTA citizens may use instead of passport) | Always for EU/EFTA |
| Ausländerausweis | The biometric foreign-national ID card | Always for residents |
| Verfallsanzeige | Expiry notice mailed by SEM before permit expiry | Renewal calls |
| Arbeitsvertrag | Employment contract | Work-related calls |
| Lohnabrechnung / Lohnausweis | Payslip / salary statement | Income proof |
| Mietvertrag | Rental contract | Address-related calls |
| Familienbüchlein / Heiratsurkunde / Geburtsurkunde | Family record / marriage certificate / birth certificate | Family reunification |
| Krankenversicherungsnachweis | Health insurance proof | Often requested |

### Language reality (drives the Hochdeutsch script)

Confidence: HIGH (Wikipedia: Swiss Standard German, Schweizerdeutsch; multiple expat sources).

- Officers at the Migrationsamt are formally trained to operate in Standard German (Schweizer Hochdeutsch) but commonly default to Swiss German (Schweizerdeutsch) on the phone.
- Polite, accepted request: "Können Sie bitte langsam und auf Hochdeutsch sprechen?" Officers switch on request; this is normal and not rude.
- English is sometimes offered by officers, but never assume it. The tool's premise is that the user prepares for a German call.

### Free advice referrals the disclaimer can point at

Confidence: HIGH (zh.ch and sah-zh.ch).

- **Welcome Desk Stadt Zürich** (free information in multiple languages including English and Spanish).
- **MIRSAH (SAH Zürich)** — paid but affordable counselling for migration and integration law.
- **Solinetz Zürich** — free legal information sheets (general, not case-specific advice).

---

## Feature Dependencies

```
LLM API key input
    └── enables ── Generate cheat sheet
                       ├── requires ── Intake (language, permit, topic, free text)
                       ├── requires ── Prompt template per topic
                       ├── produces ── Officer-questions block
                       ├── produces ── Vocabulary block
                       ├── produces ── Prep checklist
                       └── feeds    ── Print view and Phone view and QR handoff

Static blocks (independent of LLM):
    Opening script with Hochdeutsch line  ─┐
    Panic phrases                          ├── always rendered
    Office contact and hours               ┘
    Holiday banner (date-driven)
```

Notes:
- Static blocks render even if the LLM call fails. This is a key resilience property: a partial cheat sheet is still useful.
- Audio playback depends on the German output existing, but not on the LLM specifically. It can play any included German phrase.
- QR handoff depends on the generated sheet being serialisable into a URL fragment or localStorage hash.

---

## MVP Definition

### Launch With (v1)

- [ ] Three-language intake (EN, ES, PT)
- [ ] Permit-type selector
- [ ] Curated topic picker plus free-text situation field
- [ ] Optional reference-data fields
- [ ] LLM key input (Gemini and OpenAI), localStorage only
- [ ] Generate-cheat-sheet button with one structured prompt per topic
- [ ] Cheat-sheet output containing Blocks A through H above
- [ ] Hardcoded Migrationsamt contact and hours (Block A)
- [ ] Always-on Hochdeutsch language-request opening line
- [ ] Always-on panic-phrases block
- [ ] Always-on disclaimer footer
- [ ] Print stylesheet (A4)
- [ ] Phone-readable layout
- [ ] Holiday and short-hours banner (hardcoded 2026 dates)

### Add After Validation (v1.x)

- [ ] Audio playback of key German phrases (SpeechSynthesis)
- [ ] QR-code-to-phone handoff
- [ ] Save and reload past sheets (localStorage list)
- [ ] Post-call reflection prompt and template improvement loop
- [ ] More topic templates as the first user surfaces gaps

### Future Consideration (v2+)

- [ ] Live AI interpreter (subject to legal review of Art. 179bis StGB and Migrationsamt practice)
- [ ] Additional cantons (each requires its own factual data set)
- [ ] Additional input languages
- [ ] Federal SEM topics

---

## Feature Prioritisation Matrix

| Feature | User Value | Implementation Cost | Priority |
|---------|------------|---------------------|----------|
| LLM key input plus generation | HIGH | LOW | P1 |
| Topic picker plus tailored prompt | HIGH | LOW | P1 |
| Officer-question block | HIGH | MEDIUM | P1 |
| Hochdeutsch-request line | HIGH | LOW | P1 |
| Panic phrases | HIGH | LOW | P1 |
| Office contact and hours | HIGH | LOW | P1 |
| Disclaimer footer | MEDIUM (legal) | LOW | P1 |
| Print stylesheet | HIGH | LOW | P1 |
| Phone view | HIGH | LOW | P1 |
| Prep checklist | HIGH | LOW | P1 |
| Vocabulary glossary | MEDIUM | LOW | P1 |
| Holiday banner | MEDIUM | LOW | P1 |
| Audio playback | MEDIUM | MEDIUM | P2 |
| QR handoff | MEDIUM | MEDIUM | P2 |
| Saved sheets list | LOW | LOW | P2 |
| Reflection loop | LOW | MEDIUM | P3 |
| Live interpreter | HIGH | HIGH | P3 |

---

## Sources

- [Migrationsamt | Kanton Zürich (official)](https://www.zh.ch/de/sicherheitsdirektion/migrationsamt.html)
- [Kontaktformular Migrationsamt | Kanton Zürich](https://www.zh.ch/de/migration-integration/kontaktformularmigrationsamt.html)
- [Organisation des Migrationsamtes](https://www.zh.ch/de/sicherheitsdirektion/migrationsamt/organisation.html)
- [Migrationsamt des Kantons Zürich - search.ch](https://tel.search.ch/zuerich/berninastrasse-45/migrationsamt-des-kantons-zuerich-3.en.html)
- [Migrationsamt des Kantons Zürich - local.ch](https://www.local.ch/de/d/zuerich/8090/kantonale-verwaltung/migrationsamt-des-kantons-zuerich-dMv1VVK1n9KkjROoeRKq9w)
- [Ausländerausweis (Bewilligungen) | Stadt Zürich](https://www.stadt-zuerich.ch/de/lebenslagen/einwohner-services/ausweise/auslaenderausweis.html)
- [Ausländerausweis beantragen | Kanton Zürich](https://www.zh.ch/de/migration-integration/aufenthalt/aufenthalt-fuer-euefta-staatsangehoerige/auslaenderausweis-beantragen.html)
- [Biometrietermin verschieben | Kanton Zürich](https://www.zh.ch/de/migration-integration/aufenthalt/biometrische-auslaenderausweise/biometrie.html)
- [Renewing a residence permit | ETH Zurich](https://ethz.ch/en/studies/international/after-arrival/residence-permit/renewing.html)
- [Nach der Einreise | UZH](https://www.uzh.ch/de/studies/application/entry/registration.html)
- [Residence permits for non-EU/EFTA nationals | SEM](https://www.sem.admin.ch/sem/en/home/themen/aufenthalt/nicht_eu_efta.html)
- [Swiss residence permits: application and renewal | ch.ch](https://www.ch.ch/en/documents-and-register-extracts/permits-for-living-in-switzerland/)
- [Residence permits in Switzerland: L, B and C | Comparis](https://en.comparis.ch/neu-in-der-schweiz/auswandern/aufenthaltsbewilligung)
- [Swiss Residence Permit B, C, L, G, N, S | Lexial](https://lexial.eu/swiss-immigration-lawyers/swiss-resident-permits/)
- [Swiss Standard German - Wikipedia](https://en.wikipedia.org/wiki/Swiss_Standard_German)
- [Swiss German - Wikipedia](https://en.wikipedia.org/wiki/Swiss_German)
- [MIRSAH - SAH Zürich](https://www.sah-zh.ch/angebot/mirsah/)
- [Information and advice centres | Kanton Zürich](https://www.zh.ch/de/migration-integration/willkommen/english/information-and-advice-centres.html)
- [Recht_Migration (Solinetz Zürich PDF)](https://solinetz-zh.ch/wp-content/uploads/Recht_Migration.pdf)

---
*Feature research for: Migrationsamt Zürich Call Helper*
*Researched: 2026-05-14*
