---
description: Run the commit gate against staged changes and report what would block
allowed-tools: Bash(make gate), Bash(git status), Bash(git diff:*)
---

Run `make gate` and report the result.

If it passes, say so in one line.

If it blocks, list each finding as `file:line — what is wrong` and propose the
specific fix for each. Do not apply the fixes unless asked. Never suggest
`--no-verify`, and never suggest adding a `gate:allow` marker as a way around a
real finding.
