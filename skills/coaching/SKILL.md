---
name: coaching
description: >-
  User coaches AI on new/changed business or corrects wrong understanding.
  Updates domain-knowledge + changelog. Bootstrap empty system → :learning.
argument-hint: "<topic or ticket?> User teaches new/changed business or corrects AI misunderstanding"
arguments: [topic]
disable-model-invocation: true
---

# /dev-workflow:coaching

Use when user corrects or changes business rules.
Read `references/project-root.md` and `references/coaching.md`.
Resolve workspace, diff current knowledge vs new guidance, and ask `[COACHING]` for unclear points.
Write `domain-knowledge/` and `changelog.md` only after explicit confirm.
If knowledge is empty, route to `:learning`.
Refuse invented rules and unconfirmed writes.
