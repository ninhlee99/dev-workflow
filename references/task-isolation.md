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

Refuse stage if `ticket` empty (except `:learning` / `:status` without ticket / `:check` as documented).

## Anti-patterns

- One mega worklog for many tickets
- Copying PASS from ticket A into B’s INDEX
- Building ticket B while editing A’s `05-impl-log.md`
- Cleaning `domain-knowledge/` when user asked to clean one ticket
