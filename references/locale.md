# Locale (user language)

Every stage must **setup and reply in the user's language**.

## Setup — ask once per workspace, on the first command

The **first `/dev-workflow:*` command run in a workspace** (any command — `:learning`, `:spec`,
`:start`, whichever the user reaches for first) must ask explicitly, before doing anything else:

```
[LOCALE] What language should I use for chat, questions, and status updates in this workspace?
(Gate keywords like CONFIRM G3: and PASS/FAIL always stay English regardless of your answer.)
```

Do not skip this by silently inferring from the language of the user's message — a user typing
in English does not necessarily want English replies (e.g. pasting an English ticket title while
preferring Vietnamese chat). Ask once, then never ask again for this workspace.

**How to tell it's the first command:** check `domain-knowledge/INDEX.md`'s `Chat locale` field.

- Field missing, or `domain-knowledge/` doesn't exist yet → this is the first command. Ask
  `[LOCALE]` before anything else (before creating the workspace, before `:learning`'s own
  business-domain questions). Write the answer to `Chat locale` on `domain-knowledge/INDEX.md`
  as part of workspace bootstrap.
- Field already set to a real value (not a `[vi|en|ja|…]` placeholder) → do not ask again. Read
  it and use it for the rest of this session and every future one, silently.

## Detect (fallback only — after the one-time ask above has already happened)

Once `Chat locale` is set, that value is authoritative. Do not re-derive language from the
latest message on every turn — that reopens exactly the "guessed wrong" problem the one-time ask
exists to close. Only fall back to inference when `domain-knowledge/` cannot be resolved at all
(e.g. a command run outside any workspace context):

1. `DEV_WORKFLOW_LANG` / `LANG` / editor UI locale if known.
2. Language of the user's message in this chat.
3. Default English, and note in the reply that this is a guess pending a real workspace to store
   the answer in.

Store choice on worklog INDEX too when starting a ticket (mirrors the workspace-level setting,
kept per-ticket for worklog portability):

```
- **Chat locale:** vi | en | ja | …
```

## Reply rules

| Surface | Language |
|---------|----------|
| Chat (questions, verdicts, next steps, coaching) | **User language** |
| Slash-command summaries / status lines | User language |
| Artifact **field labels** / gate keywords (`CONFIRM G3:`, PASS/FAIL, AC-01) | **English** (checker-stable) |
| Free-text notes inside artifacts (Evidence, Note, Why) | User language OK |

## Setup copy

When explaining first-time setup (`:learning`, install hints, missing workspace):
- Speak in user language.
- Keep paths, env var names, commands in original English form (e.g. `DEV_WORKFLOW_WORKSPACES_ROOT`).

## Forbid

- Force English chat when user writes Vietnamese (or any non-English).
- Translate gate phrases (`CONFIRM G3:`) — break checker.
- Invent locale and never ask when ambiguous.
