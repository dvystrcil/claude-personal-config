# Acceptance-criteria-driven work

A working pattern for non-trivial implementation tasks: define acceptance criteria upfront, work through them explicitly, present final status as a structured table. Keeps work traceable and testing honest.

## Trigger

Use this pattern any time a task involves shipping or deploying something. Even small tasks benefit from 2-3 ACs stated upfront. Skip it for purely exploratory work or one-off scripts that aren't going into production.

## The shape

### 1. Open or reuse an issue

Every non-trivial task gets a GitHub issue. The issue is the *source of truth* for ACs and the final receipt. Create it before starting work if one doesn't exist.

### 2. Write ACs upfront

ACs go in the issue body, not in chat or in a PR description. Use the [issue template](./issue-template.md) — sections for background, architecture/proposal, and ACs.

ACs should be:
- **Concrete** — "the script exits non-zero on missing args" not "the script handles errors"
- **Testable** — someone other than you can verify each one
- **Numbered** — AC1, AC2, ... so you can reference them in commits and PRs
- **Scoped to the issue** — don't sneak ACs from a different work stream in

3-12 ACs is the usual range. Fewer than 3 and the structure adds noise; more than 12 and the issue is too big and should be split.

### 3. Work through them, marking progress in commits

In commit messages, reference the ACs you're advancing: `feat(thing): ship widget — closes AC1, AC2 of issue#42`.

### 4. Close with a status table

When the work is done, comment on the issue with the AC status as a table:

```markdown
## Final status

| AC | Description | Status | Evidence |
|---|---|---|---|
| AC1 | Widget exists at `bin/widget.sh` | ✅ | commit abc123 |
| AC2 | `--help` flag works | ✅ | `bin/tests/test_widget.sh` |
| AC3 | Runs on platform X | ❌ | blocked; tracked as follow-on issue#43 |
| AC4 | Documentation updated | ⏳ | will be done in next PR |
```

✅ Done, ❌ Not done (with explanation), ⏳ In progress / deferred. **Don't lie** — incomplete is incomplete. The table is the trust mechanism.

## Why this works

- **ACs in the issue keep the work traceable.** Anyone reading the issue 6 months from now sees what was intended vs what shipped.
- **Pre-defined ACs prevent scope creep.** If new requirements emerge mid-work, they become new issues or explicit AC additions in a follow-up comment — not silent expansions.
- **The closing table is the trust mechanism.** A red ❌ visible in the issue forces honesty in a way that "merged the PR, see ya" doesn't.
- **It scales down.** Small tasks with 3 ACs benefit. Large tasks with 12 ACs benefit more.

## What this is NOT

- **Not a rigid process for every commit.** Bug fixes and trivial changes don't need ACs.
- **Not a substitute for actually thinking about the problem.** Bad ACs lead to bad work. The pattern doesn't substitute for design.
- **Not a replacement for code review.** ACs verify "did we ship what we intended"; code review verifies "is what we shipped good."

## Templates

- [issue-template.md](./issue-template.md) — drop into a new issue
- [closing-comment-template.md](./closing-comment-template.md) — the final-status table format
