# claude-personal-config

Portable Claude Code methodology — skills, AC-issue patterns, diary practice — for use on personal workstations *and* work-managed workstations, with a clear IP boundary so personal IP is not commingled with work product.

This repo is the **methodology layer**. It does NOT contain any diary entries, any project-specific memory, or any tooling that references specific infrastructure. Those live elsewhere (see "What's NOT in this repo" below).

## Scope

| Asset | In this repo? | Why |
|---|---|---|
| Skill content | ❌ **moved to [`dvystrcil/skills`](https://github.com/dvystrcil/skills)** | Canonical home for all Claude Code / opencode / OWUI skills. `install.sh` clones that repo and symlinks the cluster-agnostic subset (per its `portable-skills.txt`) into `~/.claude/skills/`. |
| `ac-process/` | ✅ | Templates for the AC-driven issue/PR pattern. Methodology, no project content. |
| Diary practice | ❌ **it's a skill** ([`dvystrcil/skills/claude/diary`](https://github.com/dvystrcil/skills/tree/main/claude/diary)) | The trigger/voice/format rules live in the diary `SKILL.md`, symlinked into `~/.claude/skills/diary/` by `install.sh`. **No actual entries** live there either. |
| `install.sh` | ✅ | Idempotent setup — clones `dvystrcil/skills`, symlinks the portable subset, configures Claude Code, refuses unsafe paths. |
| **Diary entries** | ❌ **deliberately excluded** | Entries written from any workstation live in personal-managed storage (iCloud / personal git account / personal cloud) — NEVER in this repo or any work-managed path. |
| Homelab memory entries | ❌ excluded | Reference homelab infrastructure; no value at work environment + non-zero leakage risk. |
| Homelab-specific skills | ❌ excluded from `portable-skills.txt` | `homelab-memory`, `owui-import-pipeline`, `n8n-import-workflow`, etc. exist in `dvystrcil/skills/claude/` but the portable manifest excludes them. |

## IP boundary

Three asymmetric risks this repo navigates:

| Asset | IP risk when used on a work workstation |
|---|---|
| Skills (methodology + scripts) | **None.** Skills describe *how to think/work*, not project content. Bringing a skill to work makes work better without claiming work IP. |
| AC-issue pattern | **None.** Same shape — a methodology, not project content. |
| Diary practice | **Real risk.** Diary entries written from a work workstation may discuss work topics. The *methodology* (the `diary` skill in [`dvystrcil/skills`](https://github.com/dvystrcil/skills)) is portable IP; specific entries are not — and they MUST live in personal-managed storage from the moment they're written, never in any work-managed git repo. |

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
git clone https://github.<your-host>/<you>/claude-workstation-config.git ~/Work/claude-diary-work

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

### What the install does

1. Clones (or `git pull`s) [`dvystrcil/skills`](https://github.com/dvystrcil/skills) to a sibling directory (`$(dirname $REPO_DIR)/skills` by default; override with `SKILLS_REPO_DIR`).
2. Reads `portable-skills.txt` from that repo and symlinks each listed skill from `dvystrcil/skills/claude/<name>/` to `~/.claude/skills/<name>/`. Skills in the manifest but not in the repo (e.g. Anthropic-installed ones like `find-skills`, `scheduler`, `tdd`) are logged as informational; install them via Anthropic's skill registry if you want them.
3. Writes a JSON settings fragment at `~/.claude/settings.local.claude-personal-fragment.json` recording the resolved `DIARY_PATH`.
4. Appends a marker-delimited block to `~/.claude/CLAUDE.md` (creates the file if absent). The block is self-contained — gives Claude Code **where** the diary lands (`DIARY_PATH`), **when** to write entries (trigger conditions from the methodology), and **how** to format them (filename + voice + what-doesn't-go-in). Idempotent — re-running the install replaces it in place; uninstall removes it.

### Verify

```bash
# Skills should appear in Claude Code's skill list
ls ~/.claude/skills/

# Settings fragment should point at your DIARY_PATH
cat ~/.claude/settings.local.claude-personal-fragment.json

# CLAUDE.md should contain the diary block
grep -A 5 'claude-personal-config' ~/.claude/CLAUDE.md

# Write a test diary entry from a Claude Code session and verify it lands
# in $DIARY_PATH, not in any unexpected location.
```

### Uninstall

```bash
cd ~/.config/claude-personal && ./install.sh --uninstall
```

Removes the symlinks + settings fragment. **Leaves your diary entries untouched** at `$DIARY_PATH`.

## Update

After the first install, a per-workstation `update.sh` is generated in the methodology repo's root with this workstation's `DIARY_PATH` (and other env-var overrides) baked in. To pull the latest methodology and re-run the install:

```bash
cd ~/.config/claude-personal && ./update.sh
```

That's `git pull --ff-only` followed by `./install.sh` with the saved env. Idempotent — re-running replaces the CLAUDE.md block in place and re-resolves symlinks. No retyping of paths required.

`update.sh` is gitignored (per-workstation values, never committed) and is regenerated on every install — so if you change `DIARY_PATH` by running install.sh with a new value, update.sh gets the new value too.

If you ever want the bare `git pull` without re-running install: symlinks resolve dynamically, so pulling new skill content propagates automatically without an install pass.

## Skills

Skills live in [`dvystrcil/skills`](https://github.com/dvystrcil/skills) (the canonical home). `install.sh` clones that repo and symlinks the **portable subset** into `~/.claude/skills/`. The subset is defined by [`portable-skills.txt`](https://github.com/dvystrcil/skills/blob/main/portable-skills.txt) — the single source of truth, **not duplicated here** (a hardcoded list here would just drift). See that file for the current cluster-agnostic set.

Homelab-specific skills exist under `dvystrcil/skills/claude/` but are excluded from the portable manifest. Where a homelab skill carries portable methodology, a generic version is in the portable set instead — e.g. `change-validation` (the discipline behind the homelab `upgrade-validate` script) and `secrets-hygiene` (the backend-agnostic version of `homelab-secrets`). Portable skills keep any homelab-flavored examples in a clearly-fenced "Homelab specifics" section.

## What's in `ac-process/`

The AC-driven issue pattern: define acceptance criteria upfront, work through them explicitly, present final status as a ✅/❌/⏳ table. See [ac-process/README.md](./ac-process/README.md) for the templates.

## Diary practice

The diary methodology is now a **first-class skill** at `dvystrcil/skills/claude/diary/SKILL.md`. The install symlinks it into `~/.claude/skills/diary/` alongside the other skills, so Claude Code loads the trigger conditions, voice rules, and file format at session start without needing a manual prompt.

The CLAUDE.md block written by the install records this workstation's `DIARY_PATH` and points at the skill. Diary entries land at `$DIARY_PATH` (the operator's choice — personal storage at home, work-managed storage at work) and never in this repo.

## License

- Code (install.sh, any scripts): MIT
- Methodology docs (READMEs in `ac-process/`): CC-BY-4.0
- Skills live in [`dvystrcil/skills`](https://github.com/dvystrcil/skills) and carry their own licenses (verify per-skill)

**Diary entries themselves are © personal, all rights reserved** — but they aren't in this repo, so this license matrix doesn't cover them; their license is whatever the personal storage location is governed by.
