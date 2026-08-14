# Domain knowledge INDEX

- **Project:** [Name]
- **Slug:** `[project-slug]`
- **Project home:** `workspaces/<project-slug>/`
- **Chat locale:** [vi|en|ja|…]   (asked once on first command in this workspace — see `references/locale.md`)
- **Updated:** [YYYY-MM-DD]
- **Needs learning:** ☐ no  ☐ yes
- **Needs coaching:** ☐ no  ☐ yes — topics: …
- **Coach:** [user name]

## Present

| Area | File | Status |
|---|---|---|
| Business overview | `business.md` | ☐ |
| Architecture | `architecture.md` | ☐ |
| Glossary | `glossary.md` | ☐ |
| Domains | `domains/*.md` | ☐ |

## Learning repos (`../repos/`)

| Repo slug | Path | Open Qs? |
|---|---|---|
| | `repos/<repo>/` | ☐ |

(Fill from `PROJECT.md` — do not hardcode repo names.)

## Bounded contexts / domains

- [ ] … (from brief)

## Read before every ticket

1. `../PROJECT.md`
2. `business.md`
3. `architecture.md`
4. `domains/<related>.md`
5. `changelog.md`
6. `../repos/<repo>/` when learning deeply

## Last learning session

- Date: …
- Repos: …
- Open questions: …

## Last coaching session

- Date: …
- Topics: …
- Open questions: …

## G0 DoD (PASS when)

Tick for **current ticket scope**:

- [ ] `../PROJECT.md` exists + repo map
- [ ] `business.md`, `architecture.md`, `glossary.md` have real content
- [ ] ≥1 `domains/*.md` related to ticket (real content)
- [ ] `Needs learning` = **no** for scope
- [ ] Open Qs in `../repos/*/open-questions.md` (touched repos) = **0 OPEN** (or N/A if domain-knowledge already covers)
- [ ] Last learning **or** Last coaching within **90 days** if touching that domain

**FAIL routing:** empty / Needs learning → `:learning`; wrong knowledge / changed spec → `:coaching`.
