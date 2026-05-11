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

The install needs TWO repos: this one (methodology, public) and a **diary store** (where entries land). The diary store is environment-specific — personal-managed at home, work-managed at work — and you pick the location.

### Home environment

Entries land in personal-managed storage. Pick one:

| Diary store option | Example path | Notes |
|---|---|---|
| iCloud / Dropbox / Proton Drive | `~/iCloud-Drive/diary` | Simplest; no git needed; sync handled by the cloud provider |
| Personal-account git repo | `~/diary` cloned from your personal GitHub | Versioned; push when you want |
| Plain local directory backed up to a personal-only cloud | `~/.diary` | Simplest of all if cloud sync covers it |

Then:

```bash
# 1. Clone this methodology repo into a personal-only path
git clone https://github.com/dvystrcil/claude-personal-config ~/.config/claude-personal
cd ~/.config/claude-personal

# 2. Run the install with DIARY_PATH set to your diary store
DIARY_PATH=~/iCloud-Drive/diary ./install.sh
```

The install refuses if `DIARY_PATH` resolves under a work-managed root (`WORK_PATHS`, defaults to common enterprise patterns like `~/Work`, `/opt/enterprise`, etc.).

### Work environment

Entries land in **work-managed** storage. Two-repo setup:

```bash
# 1. Clone the methodology repo (this one). Keep it in a non-work-managed
#    path even though the repo itself is public; the install refuses to run
#    from inside a work-managed dir unless you set WORK_PATHS="".
git clone https://github.com/dvystrcil/claude-personal-config ~/.config/claude-personal

# 2. Clone (or create then clone) the work-side diary repo locally. This is
#    where entries will land + where you'll git-push when you want them
#    persisted to your work GitHub.
git clone https://github.<your-work-host>/<you>/claude-workstation-config.git ~/Work/claude-diary-work

# 3. Install with the work-environment env vars:
#    - PERSONAL_PATHS: deny-list for paths that ARE personal (e.g. iCloud)
#      so the install refuses if DIARY_PATH accidentally lands there.
#    - WORK_PATHS="": disables the home-install's work-path refusal, since
#      at work the diary IS expected to live in a work-managed path.
cd ~/.config/claude-personal
PERSONAL_PATHS=~/iCloud-Drive,~/Dropbox,~/Personal \
WORK_PATHS="" \
DIARY_PATH=~/Work/claude-diary-work \
  ./install.sh
```

The two-repo split means:
- The methodology repo (this one) is read-only at work — `git pull` to update; never push.
- The diary repo (your work-side one) holds the entries that Claude writes during work sessions. Push to your work GitHub whenever you want to persist them; they never go to the methodology repo.

### Verify

```bash
# Skills should appear in Claude Code's skill list
ls ~/.claude/skills/

# Settings fragment should point at your DIARY_PATH
cat ~/.claude/settings.local.claude-personal-fragment.json

# Write a test diary entry from a Claude Code session and verify it lands
# in $DIARY_PATH, not in any unexpected location.
```

### Uninstall

```bash
cd ~/.config/claude-personal && ./install.sh --uninstall
```

Removes the symlinks + settings fragment. **Leaves your diary entries untouched** at `$DIARY_PATH`.

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
