---
name: confirm
description: >-
  Wait for human CONFIRM G3 phrase; write INDEX + 03b-human-confirm.md.
  Never invent phrase or use AI names. P0 also CONFIRM G3-PM.
argument-hint: "<Ticket ID> Run after conflict — wait for user CONFIRM G3"
arguments: [ticket_id]
disable-model-invocation: true
---

# /dev-workflow:confirm

If first `/dev-workflow:*` command in this workspace, ask `[LOCALE]` per `references/locale.md`
before anything else.

1. Present conflict decisions + OPEN Qs + spec deltas.
2. Ask user to reply exactly: `CONFIRM G3: <Ticket> <Human_Name> <YYYY-MM-DD>`
3. P0: also `CONFIRM G3-PM: <Ticket> <PM_Name> <YYYY-MM-DD>`
4. Write phrases to **both** `INDEX.md` and `03b-human-confirm.md` (Source: user-message).
5. Forbidden names: AI, ChatGPT, Claude, Copilot, Cursor, Assistant, Bot.
6. Only then G3 PASS → `:plan`.
