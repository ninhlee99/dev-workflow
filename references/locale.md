# Locale (user language)

Every stage must **setup and reply in the user's language**.

## Detect

1. Prefer language of the **latest user message** in this chat (Vietnamese → VI, English → EN, Japanese → JA, …).
2. Else `DEV_WORKFLOW_LANG` / `LANG` / Cursor UI locale if known.
3. Default: English only when language truly unclear — then ask once: preferred language?

Store choice on worklog INDEX when starting a ticket:

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
