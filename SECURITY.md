# Security policy

This covers vulnerabilities in the **dev-workflow plugin itself** — its installer, gate checker
(`bin/check-gates.sh`), or generated artifacts. For the P0 security gate a *ticket* goes through
when using the plugin, see [references/security.md](./references/security.md) instead — that's
unrelated to reporting a bug here.

## Supported versions

Only the latest released version (see [CHANGELOG.md](./CHANGELOG.md)) receives security fixes.

## Reporting a vulnerability

Do not open a public issue for a security problem. Email **levanninh2101@gmail.com** with the
subject `dev-workflow security: <short summary>`.

(GitHub's private vulnerability reporting will replace this once enabled for the repository —
check the [Security tab](https://github.com/ninhlee99/dev-workflow/security) for a "Report a
vulnerability" button; if present, use that instead of email.)

Include:
- The affected file(s) or command
- Steps to reproduce
- Impact (what an attacker could do — e.g. arbitrary file write during `install.sh`, code execution
  via a crafted worklog artifact read by `check-gates.sh`)

Expect an initial response within a few days. If the report is confirmed, a fix will ship as a patch
release and the advisory will be published after users have had time to update.
