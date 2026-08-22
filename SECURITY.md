# Security policy

This covers vulnerabilities in the **dev-workflow plugin itself** — its installer, gate checker
(`bin/check-gates.sh`), or generated artifacts. For the P0 security gate a *ticket* goes through
when using the plugin, see [references/security.md](./references/security.md) instead — that's
unrelated to reporting a bug here.

## Supported versions

Only the latest released version (see [CHANGELOG.md](./CHANGELOG.md)) receives security fixes.

## Reporting a vulnerability

This is a solo-maintained repository, not an organization — there is no dedicated security team or
org-owned mailbox behind it. Two channels, in order of preference:

1. [GitHub private vulnerability reporting](https://github.com/ninhlee99/dev-workflow/security) —
   use the "Report a vulnerability" button on the Security tab if present. This is the preferred
   channel once enabled; it keeps the report private to maintainer + GitHub and supports draft
   advisories.
2. If that button isn't there yet, email **levanninh2101@gmail.com** with subject
   `dev-workflow security: <short summary>`. This is a personal address, not a monitored security
   inbox — expect the same response time as channel 1, not faster, but no stronger delivery
   guarantee than any other personal email.

Do not open a public issue for a security problem either way.

Include:
- The affected file(s) or command
- Steps to reproduce
- Impact (what an attacker could do — e.g. arbitrary file write during `install.sh`, code execution
  via a crafted worklog artifact read by `check-gates.sh`)

Expect an initial response within a few days. If the report is confirmed, a fix will ship as a patch
release and the advisory will be published after users have had time to update.
