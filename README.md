# claude-personal-config

Portable Claude Code methodology — skills, AC-issue patterns, diary practice — for use on personal workstations *and* work-managed workstations, with a clear IP boundary so personal IP is not commingled with work product.

This repo is the **methodology layer**. It does NOT contain any diary entries, any project-specific memory, or any tooling that references specific infrastructure. Those live elsewhere (see "What's NOT in this repo" below).

## Scope

| Asset | In this repo? | Why |
|---|---|---|
| `claude-skills/` | ✅ Selected subset | Cluster-agnostic skills only (doc-master, code-reviewer, find-skills, etc.). Homelab-specific tooling skills excluded. |
| `ac-process/` | ✅ | Templates for the AC-driven issue/PR pattern. Methodology, no project content. |
| `diary/README.md` | ✅ | The diary practice itself — trigger rules, voice rules. **No actual entries.** |
| `install.sh` | ✅ | Idempotent setup script that refuses to run inside work-managed paths. |
| **Diary entries** | ❌ **deliberately excluded** | Entries written from any workstation live in personal-managed storage (iCloud / personal git account / personal cloud) — NEVER in this repo or any work-managed path. |
| Homelab memory entries | ❌ excluded | Reference homelab infrastructure; no value at work environment + non-zero leakage risk. |
| Homelab-specific skills | ❌ excluded | `homelab-memory`, `owui-import-pipeline`, `n8n-import-workflow`, etc. — tied to personal cluster. |

## IP boundary

Three asymmetric risks this repo navigates:

| Asset | IP risk when used on a work workstation |
|---|---|
| Skills (methodology + scripts) | **None.** Skills describe *how to think/work*, not project content. Bringing a skill to work makes work better without claiming work IP. |
| AC-issue pattern | **None.** Same shape — a methodology, not project content. |
| Diary practice | **Real risk.** Diary entries written from a work workstation may discuss work topics. The *methodology* (this repo's `diary/README.md`) is portable IP; specific entries are not — and they MUST live in personal-managed storage from the moment they're written, never in any work-managed git repo. |

**The install script enforces this**: it sets the diary path to a personal-only location, and refuses to run if the install directory is under a work-managed path.

## Install

```bash
git clone https://github.com/dvystrcil/claude-personal-config ~/.config/claude-personal
cd ~/.config/claude-personal
DIARY_PATH=~/iCloud-Drive/diary ./install.sh
```

`DIARY_PATH` is required. Choose a personal-managed storage location — iCloud, Dropbox, Proton Drive, or a personal-only git repo path. The install script refuses to set up if `DIARY_PATH` resolves under a work-managed root (configurable via `WORK_PATHS` env var; defaults to common enterprise patterns).

To uninstall: `./install.sh --uninstall` — removes the symlinks + settings fragment; leaves your diary entries untouched.

## Update

```bash
cd ~/.config/claude-personal && git pull
```

Symlinks resolve dynamically, so a `git pull` immediately propagates skills updates. No re-install needed.

## What's in `claude-skills/`

See [claude-skills/README.md](./claude-skills/README.md) for the per-skill audit.

Current set (cluster-agnostic):
- `code-reviewer/` — code review process + checklist
- `doc-master/` — documentation/writing assistance
- `find-skills/` — discover what skills are available
- `first-ask/` — clarify scope before starting work
- `frontend-design/` — frontend code review + design

Some skills include illustrative examples drawn from the personal homelab context (e.g. `code-reviewer/SKILL.md` mentions ArgoCD ignoreDifferences as a review item). Substitute your work environment's equivalents mentally; nothing in the methodology is homelab-specific.

## What's in `ac-process/`

The AC-driven issue pattern: define acceptance criteria upfront, work through them explicitly, present final status as a ✅/❌/⏳ table. See [ac-process/README.md](./ac-process/README.md) for the templates.

## What's in `diary/`

ONLY the methodology README. Diary entries live in `$DIARY_PATH`, NOT here.

## License

- Code (install.sh, any scripts): MIT
- Methodology docs (READMEs in `ac-process/`, `diary/`): CC-BY-4.0
- Selected skills in `claude-skills/`: whatever their upstream license specifies (most are MIT or unlicensed; verify per-skill)

**Diary entries themselves are © personal, all rights reserved** — but they aren't in this repo, so this license matrix doesn't cover them; their license is whatever the personal storage location is governed by.
