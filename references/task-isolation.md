# Task isolation (per ticket)

Each ticket is an **independent** delivery unit. Do not bleed state across tickets.

## Boundaries

| Shared (project) | Isolated (per ticket) |
|------------------|------------------------|
| `PROJECT.md` | `worklogs/<Ticket_ID>/` entire tree |
| `domain-knowledge/` | All `01`–`07`, `02b`, `03b`, `06b`, `06c` |
| `repos/<slug>/` maps | INDEX Risk / CONFIRM / waivers for that ticket |
| Plugin templates | Plan / build / review evidence for that ticket only |

## Build rules

1. Resolve **only** `worklogs/<Ticket_ID>/` for the current ticket arg. Never write another ticket’s worklog.
2. Read shared domain knowledge; **do not** edit another ticket’s AC/plan to “reuse”.
3. Coverage map / impl log / tests cited in `05-impl-log.md` must map to **this** ticket’s AC IDs.
4. Git branch / PR may share repo — still log evidence under **this** worklog only.
5. If ticket B needs artifacts from A → copy facts into B’s worklog (or coaching), never silently depend on A’s open worklog path.
6. `:clean <Ticket>` removes **that** worklog (or archives it). Leaves other tickets + domain knowledge untouched.

## Start of every stage

Print:

```
project=<slug> home=<path> ticket=<Ticket_ID> worklog=<path> locale=<code>
```

## No Ticket ID given

A missing Ticket ID does **not** refuse the stage. Proceed with the requested work (analysis,
Q&A, code read, conversation) exactly as if a ticket had been given.

- **No confirm/persist needed** (pure question, read-only lookup, a claim resolved as MATCH with
  nothing to record) → do the work, answer the user, **write nothing under `worklogs/`**. Do not
  invent or ask for an ID just to satisfy this section — an ID that names nothing is noise.
- **Confirm/persist needed** (a decision, a non-MATCH claim, anything `:clarify`/`:confirm` would
  otherwise log, or the user explicitly wants a worklog kept) → derive a short slug from the task
  itself instead of asking the user to supply one:
  - 2–5 words, kebab-case, drawn from the actual subject (e.g. a ticket titled/described as
    "sửa text nút xác nhận đơn hàng" → `confirm-btn-text`; a bug about search default query type →
    `search-default-query`).
  - Prefix `adhoc-` so it's visibly not a real tracker ID: `adhoc-confirm-btn-text`.
  - Use that slug as `<Ticket_ID>` everywhere in this file's rules — same isolation boundaries,
    same `worklogs/<slug>/` tree, same one-ticket-per-folder discipline.
  - State it once when first derived: `No Ticket ID given — using adhoc-<slug> for this worklog.`
    so the user can rename it if they'd rather track it under a real ID later.
  - If the user later supplies a real Ticket ID for the same task, move/rename the folder to the
    real ID rather than keeping both.

This section governs conversational stages (`:spec`, `:clarify`, `:plan`, `:build`, etc.) reading
and writing worklog content. It does not change `check-gates.sh` / `clean-worklog.sh` /
`:check` / `:clean` / `:audit` — those do machine string-matching against an exact ticket
(`CONFIRM G3: <ticket> …`, PILOT file lookups) and still require the real or derived slug to be
passed explicitly; they are not what "refuse if ticket empty" used to guard here.

## Anti-patterns

- One mega worklog for many tickets
- Copying PASS from ticket A into B’s INDEX
- Building ticket B while editing A’s `05-impl-log.md`
- Cleaning `domain-knowledge/` when user asked to clean one ticket
