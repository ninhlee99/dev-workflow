---
name: confirm
description: >-
  Summarize decisions, hand user a pre-filled CONFIRM G3 line to send back (only
  the name left to edit); write INDEX + 03b-human-confirm.md. Never invent the
  phrase or fill in the name. P0 also CONFIRM G3-PM.
argument-hint: "<Ticket ID> Run after clarify — AI hands you a ready-to-send CONFIRM G3 line"
arguments: [ticket_id]
disable-model-invocation: false
---

# /dev-workflow:confirm

Apply `references/skill-quality.md`; this stage records decisions but never manufactures or reinterprets them.

If first `/dev-workflow:*` command in this workspace, ask `[LOCALE]` per `references/locale.md`
before anything else.

**Risk=P2 fast path**: G3 is soft for P2 (see `references/risk.md`) — a real human `CONFIRM G3:`
is still the safest evidence, but a genuinely tiny, non-behavioral P2 ticket may skip this stage
and go straight to `:plan`/`:build` with `check-gates.sh` only warning, not failing, at G3. Say so
explicitly once — `"Risk=P2 — CONFIRM G3 is optional here; skip it and continue, or send the
confirm line if you'd rather have it on record."` — and let the user pick. `--strict` or any risk
other than P2 always requires the full flow below.

1. Present clarify decisions + OPEN Qs + spec deltas as a short summary — what's being locked in,
   not a raw dump of `03-clarify-report.md`.
2. Hand the user a ready-to-send line instead of asking them to compose one from memory:
   `CONFIRM G3: <Ticket_ID> <your name> <YYYY-MM-DD>` — ticket and today's date already filled in,
   only the name left as a placeholder for them to edit (the AI cannot fill in the human's name
   itself — that would defeat the anti-forge point of this whole gate). P0: also hand over
   `CONFIRM G3-PM: <Ticket_ID> <your name> <YYYY-MM-DD>` for the PM to send.
3. The user edits the name and sends it back as their own message — that message, not anything the
   AI writes unprompted, is the proof of human sign-off.
4. Write the phrase(s) exactly as the user sent them to **both** `INDEX.md` and
   `03b-human-confirm.md` (Source: user-message). Never fill in or guess the name, and never
   silently reinterpret free text as if it were the phrase.
   - Reply matches `CONFIRM G3: <Ticket> <Name> <Date>` exactly → write it as-is.
   - Reply is clearly an agreement but not in that shape (e.g. "ok đồng ý, tên tôi là Hoa") →
     compose the correct line from what they just gave you (their name, today's date if they
     didn't state one) and hand it back once more for them to send — don't make them retype from
     scratch, and don't make them guess the shape a second time either. Still wait for that exact
     line back before writing anything; a paraphrase of their intent is not the anti-forge artifact.
   - Reply doesn't clearly indicate agreement at all → ask a direct yes/no, do not assume.
5. Forbidden names: AI, ChatGPT, Claude, Copilot, Cursor, Assistant, Bot.
6. Only then G3 PASS → `:plan`.
7. Every confirmed NO/UNCLEAR claim must show the exact selected decision, owner role, and source
   message—not a blanket phrase. Unknown authority for a Requirement change keeps G3 FAIL.
