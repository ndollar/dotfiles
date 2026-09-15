---
name: pre-commit
description: Review all changed files against CLAUDE.md conventions before committing
user-invocable: true
---

Review all changed files in the current branch against the CLAUDE.md conventions. Do NOT make any changes — only report violations.

Steps:
1. Determine which files have changed:
   - If there are uncommitted changes (staged or unstaged), run `git diff --name-only` and `git diff --cached --name-only`
   - If the working tree is clean but the branch has commits ahead of master, run `git diff --name-only master...HEAD`
   - Combine both if there are uncommitted changes AND commits ahead of master
2. Read each changed file
3. Read all applicable CLAUDE.md files (root, package-level, etc.)
4. For each changed file, check every applicable convention and flag violations
5. Only check new or modified code — do not flag pre-existing issues in unchanged lines. Use `git diff` or `git diff master...HEAD` to see only the changed lines.

Output a summary of violations grouped by file. If no violations are found, say so.
