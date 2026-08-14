---
name: clean
description: >-
  After ticket done: archive or purge that ticket worklog only to free memory.
  Never deletes domain-knowledge or other tickets. Use /dev-workflow:clean.
argument-hint: "<Ticket ID> [--force] [--purge] — archive worklog after ship; --force if G9 incomplete; --purge hard-delete"
arguments: [ticket_id, flags]
disable-model-invocation: true
---

# /dev-workflow:clean

Apply `references/skill-quality.md`; resolve and print the exact canonical target before mutation.

If first `/dev-workflow:*` command in this workspace, ask `[LOCALE]` per `references/locale.md`
before anything else.

Free memory after a finished ticket by removing **that ticket’s worklog only**.

## Rules

1. Read `references/task-isolation.md` + `references/locale.md` (reply in user language).
2. Resolve `project=` / `worklog=` via `references/project-root.md`.
3. Run real cleaner (do not invent delete):

```bash
"$DEV_WORKFLOW_PLUGIN/bin/clean-worklog.sh" <Ticket_ID> [--project slug] [--force] [--purge]
```

4. Default = **archive** → `worklogs/.archive/<Ticket>-<UTC>/` (active worklog gone; recoverable).
   Timestamp is real UTC (`date -u`), so re-archiving the same ticket twice never collides.
5. `--purge` = hard delete archive skip — ask user confirm in chat first.
6. `--force` = allow when `--min G9` checker not PASS (user accepts risk). Note: this checks G9
   specifically, not `:audit` — a P0/P1 ticket that shipped without `:audit` sign-off can still
   be cleaned without `--force`; `:audit` is a ship-finality gate, not a clean precondition.
7. **Never** clean `domain-knowledge/`, `PROJECT.md`, `repos/`, or other tickets.
8. After PASS: tell user next is new ticket via `:start` / `:status`; optional `rm -rf worklogs/.archive` for disk.

## Refuse

- Missing Ticket_ID
- Path outside `worklogs/<Ticket_ID>/`
- User asked to “clean everything” without listing tickets — clarify first

## Output

Print script RESULT + what was kept. Chat in user language.
For purge, confirmation must repeat ticket and canonical path. After either operation verify the
active path is gone and print destination/recoverability plus a receipt; never imply purge recovery.
