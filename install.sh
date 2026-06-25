#!/bin/bash
# install.sh — idempotent setup for the portable Claude Code methodology.
#
# Sets up:
#   - Clones (or pulls) dvystrcil/skills and symlinks the cluster-agnostic
#     subset listed in dvystrcil/skills/portable-skills.txt into
#     ~/.claude/skills/.
#   - Configures Claude Code settings fragment with the diary path
#   - Refuses to run if install dir lies under a work-managed root (home install case)
#   - Refuses to run if DIARY_PATH lies under the "wrong" root for the environment:
#       * At a HOME install: DIARY_PATH must NOT be under work-managed paths (WORK_PATHS).
#       * At a WORK install: DIARY_PATH must NOT be under personal-managed paths (PERSONAL_PATHS).
#
# Per-environment usage:
#
#   # HOME install — diary entries land in personal storage (iCloud, personal git, etc.)
#   DIARY_PATH=~/iCloud-Drive/diary ./install.sh
#
#   # WORK install — diary entries land in WORK-managed storage (work GitHub clone, etc.)
#   # Set PERSONAL_PATHS to your known-personal roots so the install refuses if
#   # DIARY_PATH accidentally points there. Also set WORK_PATHS="" to disable the
#   # home-install check (since the work-diary path IS work-managed and would
#   # otherwise be refused).
#   PERSONAL_PATHS=~/iCloud-Drive,~/Dropbox,~/Personal \
#   WORK_PATHS="" \
#   DIARY_PATH=~/Work/claude-diary-work ./install.sh
#
#   # Uninstall (either environment)
#   ./install.sh --uninstall
#
# Environment:
#   DIARY_PATH        Required for install. Where diary entries are written.
#   WORK_PATHS        Comma-separated path prefixes treated as work-managed.
#                     Defaults: /work,/Work,/opt/enterprise,/opt/company,~/Work,~/work
#                     At a WORK install, set this to "" (empty) to disable the
#                     refuse-if-under-work check.
#   PERSONAL_PATHS    Comma-separated path prefixes treated as personal-managed.
#                     Empty by default. At a WORK install, set this to your known
#                     personal roots (iCloud, Dropbox, etc.) so the install refuses
#                     if DIARY_PATH accidentally lands there.
#   CLAUDE_HOME       Optional. Defaults to ~/.claude.
#   SKILLS_REPO_DIR   Optional. Where to clone dvystrcil/skills. Defaults to
#                     a sibling of this repo: $(dirname $REPO_DIR)/skills.
#
# IP-boundary intent:
#   - HOME install: keep diary OUT of work-managed storage. WORK_PATHS check fires.
#   - WORK install: keep diary OUT of personal-managed storage. PERSONAL_PATHS
#     check fires. (Work entries belong in work systems for IP compliance.)
#   - Methodology repo source lives in a personally-managed location at home;
#     at work it's cloned to wherever (it's open-source public methodology).
#   - Skills source repo (dvystrcil/skills) is public on GitHub; cloned via HTTPS
#     without auth.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_HOME="${CLAUDE_HOME:-$HOME/.claude}"
SKILLS_REPO_URL="https://github.com/dvystrcil/skills.git"
SKILLS_REPO_DIR="${SKILLS_REPO_DIR:-$(dirname "$REPO_DIR")/skills}"
WORK_PATHS_DEFAULT="/work,/Work,/opt/enterprise,/opt/company,${HOME}/Work,${HOME}/work"
WORK_PATHS="${WORK_PATHS-$WORK_PATHS_DEFAULT}"  # use - not := so an explicit "" disables
PERSONAL_PATHS="${PERSONAL_PATHS-}"             # empty by default

err() { echo "ERROR: $*" >&2; exit 1; }
warn() { echo "WARN: $*" >&2; }
info() { echo "INFO: $*"; }

# Generic "is $target under any of the path prefixes in $list?". $list is
# comma-separated; "" or empty list means no match.
is_under_any_path() {
    local target="$1"
    local list="$2"
    local abs
    abs=$(cd "$(dirname "$target")" 2>/dev/null && pwd)/$(basename "$target")
    [ -z "$list" ] && return 1
    IFS=',' read -ra paths <<< "$list"
    for p in "${paths[@]}"; do
        p="${p# }"; p="${p% }"
        p="${p/#\~/$HOME}"
        [ -z "$p" ] && continue
        if [[ "$abs" == "$p"* ]]; then
            echo "$p"
            return 0
        fi
    done
    return 1
}

uninstall() {
    info "Uninstalling — removing skill symlinks, settings fragment, CLAUDE.md diary block, secret-scan hook, update.sh."
    local update_script="$REPO_DIR/update.sh"
    if [ -f "$update_script" ]; then
        rm "$update_script"
        info "  removed update.sh: $update_script"
    fi
    local skills_dir="$CLAUDE_HOME/skills"
    if [ -d "$skills_dir" ] && [ -d "$SKILLS_REPO_DIR/claude" ]; then
        for sk in "$SKILLS_REPO_DIR"/claude/*/; do
            name=$(basename "$sk")
            target="$skills_dir/$name"
            if [ -L "$target" ]; then
                actual=$(readlink "$target")
                if [ "$actual" = "$sk" ] || [ "$actual" = "${sk%/}" ]; then
                    rm "$target"
                    info "  removed symlink: $target"
                fi
            fi
        done
    fi
    local frag="$CLAUDE_HOME/settings.local.claude-personal-fragment.json"
    if [ -f "$frag" ]; then
        rm "$frag"
        info "  removed settings fragment: $frag"
    fi
    local claude_md="$CLAUDE_HOME/CLAUDE.md"
    local marker_start="# >>> claude-personal-config (managed by install.sh — do not edit between markers) >>>"
    local marker_end="# <<< claude-personal-config <<<"
    if [ -f "$claude_md" ] && grep -qF "$marker_start" "$claude_md"; then
        local tmp
        tmp=$(mktemp)
        awk -v start="$marker_start" -v end="$marker_end" '
            $0 == start { skip=1; next }
            $0 == end   { skip=0; next }
            !skip       { print }
        ' "$claude_md" > "$tmp"
        mv "$tmp" "$claude_md"
        info "  removed CLAUDE.md diary block from: $claude_md"
        if [ ! -s "$claude_md" ] || ! grep -q '[^[:space:]]' "$claude_md"; then
            rm "$claude_md"
            info "  removed empty CLAUDE.md: $claude_md"
        fi
    fi
    # Secret-scan hook: remove it; unset core.hooksPath only if it is still ours
    # (never touch a corporate/other hooksPath we deliberately didn't override).
    local hooks_dir="$CLAUDE_HOME/git-hooks"
    if [ -f "$hooks_dir/pre-commit" ]; then
        rm "$hooks_dir/pre-commit"
        rmdir "$hooks_dir" 2>/dev/null || true
        info "  removed secret-scan pre-commit hook: $hooks_dir/pre-commit"
    fi
    local hp
    hp=$(git config --global --get core.hooksPath || true)
    if [ "$hp" = "$hooks_dir" ]; then
        git config --global --unset core.hooksPath
        info "  unset core.hooksPath (was → $hooks_dir)"
    fi
    info "Uninstall complete. Diary entries at \$DIARY_PATH and the cloned skills repo left untouched."
    exit 0
}

if [ "${1:-}" = "--uninstall" ]; then
    uninstall
fi

# Pre-flight 1: refuse to install from inside a work-managed path.
matched=$(is_under_any_path "$REPO_DIR" "$WORK_PATHS" || true)
if [ -n "$matched" ]; then
    err "Install dir '$REPO_DIR' is under work-managed path '$matched'.
Move this repo to a non-work-managed directory (e.g. ~/.config/claude-personal/)
before installing. To intentionally disable this check, set WORK_PATHS=\"\"."
fi

# Require DIARY_PATH
if [ -z "${DIARY_PATH:-}" ]; then
    err "DIARY_PATH is required.
Set it to where diary entries should land. The environment determines what
'right' looks like:
  HOME install:  personal-managed storage (iCloud, Dropbox, personal git repo)
    Example: DIARY_PATH=~/iCloud-Drive/diary ./install.sh
  WORK install:  work-managed storage (work GitHub clone, work cloud, etc.)
    Example: PERSONAL_PATHS=~/iCloud-Drive,~/Dropbox WORK_PATHS=\"\" \\
             DIARY_PATH=~/Work/claude-diary-work ./install.sh"
fi

DIARY_PATH="${DIARY_PATH/#\~/$HOME}"

# Pre-flight 2a + 2b: DIARY_PATH IP-boundary checks
matched=$(is_under_any_path "$DIARY_PATH" "$WORK_PATHS" || true)
if [ -n "$matched" ]; then
    err "DIARY_PATH '$DIARY_PATH' is under work-managed path '$matched'.
At a HOME install, pick a personal-managed path. At a WORK install, set
WORK_PATHS=\"\" and set PERSONAL_PATHS to your personal roots."
fi
matched=$(is_under_any_path "$DIARY_PATH" "$PERSONAL_PATHS" || true)
if [ -n "$matched" ]; then
    err "DIARY_PATH '$DIARY_PATH' is under personal-managed path '$matched'.
At a work install, the diary belongs in work-managed storage."
fi

mkdir -p "$DIARY_PATH"
info "Diary path: $DIARY_PATH"

# Clone or update dvystrcil/skills
if [ -d "$SKILLS_REPO_DIR/.git" ]; then
    info "Pulling latest dvystrcil/skills at $SKILLS_REPO_DIR"
    git -C "$SKILLS_REPO_DIR" pull --ff-only --quiet
else
    info "Cloning dvystrcil/skills to $SKILLS_REPO_DIR"
    git clone --quiet "$SKILLS_REPO_URL" "$SKILLS_REPO_DIR"
fi

PORTABLE_FILE="$SKILLS_REPO_DIR/portable-skills.txt"
if [ ! -f "$PORTABLE_FILE" ]; then
    err "portable-skills.txt not found at $PORTABLE_FILE"
fi

# Symlink the listed cluster-agnostic skills into ~/.claude/skills/
mkdir -p "$CLAUDE_HOME/skills"
info "Linking portable skills from $SKILLS_REPO_DIR/claude/ into $CLAUDE_HOME/skills/"

while IFS= read -r raw; do
    # Strip comments and whitespace
    name="${raw%%#*}"
    name="${name// /}"
    [ -z "$name" ] && continue

    skill_dir="$SKILLS_REPO_DIR/claude/$name"
    target="$CLAUDE_HOME/skills/$name"

    if [ ! -d "$skill_dir" ]; then
        info "  · $name not in dvystrcil/skills/claude/ — install separately if needed (e.g. via Anthropic's skill registry)"
        continue
    fi

    if [ -L "$target" ]; then
        actual=$(readlink "$target")
        if [ "$actual" = "$skill_dir" ] || [ "$actual" = "${skill_dir%/}" ]; then
            info "  ✓ $name (symlink already in place)"
            continue
        fi
        warn "  ⚠ $target already points at $actual (not ours); skipping"
        continue
    fi
    if [ -e "$target" ]; then
        warn "  ⚠ $target exists (not a symlink); skipping. Move or remove it manually if you want this skill linked."
        continue
    fi
    ln -s "$skill_dir" "$target"
    info "  ✓ symlinked $name"
done < "$PORTABLE_FILE"

# Write Claude Code settings fragment
frag="$CLAUDE_HOME/settings.local.claude-personal-fragment.json"
cat > "$frag" <<EOF
{
  "_comment": "Generated by claude-personal-config/install.sh — do not edit by hand. Re-run install.sh to update.",
  "diary": {
    "path": "$DIARY_PATH",
    "methodology_ref": "$SKILLS_REPO_DIR/claude/diary/SKILL.md"
  }
}
EOF
info "  ✓ wrote settings fragment: $frag"

# Append a marked block to ~/.claude/CLAUDE.md
claude_md="$CLAUDE_HOME/CLAUDE.md"
marker_start="# >>> claude-personal-config (managed by install.sh — do not edit between markers) >>>"
marker_end="# <<< claude-personal-config <<<"

if [ -f "$claude_md" ] && grep -qF "$marker_start" "$claude_md"; then
    tmp=$(mktemp)
    awk -v start="$marker_start" -v end="$marker_end" '
        $0 == start { skip=1; next }
        $0 == end   { skip=0; next }
        !skip       { print }
    ' "$claude_md" > "$tmp"
    mv "$tmp" "$claude_md"
fi

cat >> "$claude_md" <<EOF

$marker_start
# Diary practice (claude-personal-config)
#
# BEHAVIOR — act on this each session, do not just read it:
# After a substantial or eventful session — a notable correction, a surprise, a
# principle crystallizing, a near-miss, a change of direction, or whenever the user
# asks — PROACTIVELY OFFER to write a diary entry (via the \`diary\` skill) before
# wrapping up. The skill defines HOW (trigger detail, voice, format); this block is
# the WHEN that makes it fire. Skip routine/unremarkable sessions — selectivity is
# what keeps the diary worth re-reading.
#
# Reference (where things live):
#   skill:    $CLAUDE_HOME/skills/diary/SKILL.md
#             (symlinked from dvystrcil/skills: $SKILLS_REPO_DIR/claude/diary/SKILL.md)
#   entries:  $DIARY_PATH
#   fragment: $frag
$marker_end
EOF
info "  ✓ wrote CLAUDE.md diary block: $claude_md"

# Install a global gitleaks pre-commit hook (secret-scan, every repo).
# Conflict-safe: NEVER clobbers an existing core.hooksPath — on a managed/work
# machine, corporate hooks win and we just print integration instructions.
HOOKS_DIR="$CLAUDE_HOME/git-hooks"
mkdir -p "$HOOKS_DIR"
install -m 0755 "$REPO_DIR/hooks/pre-commit" "$HOOKS_DIR/pre-commit"
info "  ✓ installed secret-scan pre-commit hook: $HOOKS_DIR/pre-commit"

current_hp=$(git config --global --get core.hooksPath || true)
if [ -z "$current_hp" ]; then
    git config --global core.hooksPath "$HOOKS_DIR"
    info "  ✓ set global core.hooksPath → $HOOKS_DIR"
elif [ "$current_hp" = "$HOOKS_DIR" ]; then
    info "  ✓ core.hooksPath already → $HOOKS_DIR (hook refreshed)"
else
    warn "  ⚠ core.hooksPath is already set to '$current_hp' (not ours) — NOT overriding it."
    warn "    To enable secret-scanning here, fold the contents of"
    warn "    $HOOKS_DIR/pre-commit into '$current_hp/pre-commit', or unset core.hooksPath."
fi

if ! command -v gitleaks >/dev/null 2>&1 && [ ! -x "$HOME/.local/bin/gitleaks" ]; then
    warn "  ⚠ gitleaks not found (PATH or ~/.local/bin) — the hook SKIPS scanning until"
    warn "    it's installed (https://github.com/gitleaks/gitleaks). Commits are never"
    warn "    blocked by its absence; you just get no secret protection until then."
fi

# Write a per-workstation update.sh
update_script="$REPO_DIR/update.sh"
{
    echo "#!/bin/bash"
    echo "# update.sh — generated by install.sh on $(date -u +'%Y-%m-%dT%H:%M:%SZ')."
    echo "# Pulls the latest methodology + skills + re-runs install.sh with the env this"
    echo "# workstation was installed with. Do NOT edit by hand — re-run install.sh"
    echo "# to regenerate. Gitignored."
    echo ""
    echo "set -e"
    echo ""
    echo "cd \"\$(dirname \"\${BASH_SOURCE[0]}\")\""
    echo ""
    echo "echo 'Pulling latest methodology...'"
    echo "git pull --ff-only"
    echo ""
    echo "echo 'Re-running install with saved env (which also pulls dvystrcil/skills)...'"
    echo "DIARY_PATH='$DIARY_PATH' \\"
    echo "WORK_PATHS='$WORK_PATHS' \\"
    echo "PERSONAL_PATHS='$PERSONAL_PATHS' \\"
    echo "CLAUDE_HOME='$CLAUDE_HOME' \\"
    echo "SKILLS_REPO_DIR='$SKILLS_REPO_DIR' \\"
    echo "  ./install.sh"
} > "$update_script"
chmod +x "$update_script"
info "  ✓ wrote per-workstation update.sh: $update_script"

cat <<EOF

Install complete.

  Skills linked under:  $CLAUDE_HOME/skills/
  Skills source repo:   $SKILLS_REPO_DIR  (dvystrcil/skills)
  Settings fragment:    $frag
  Diary entries land:   $DIARY_PATH
  Secret-scan hook:     $HOOKS_DIR/pre-commit (global gitleaks pre-commit)

To verify: ask Claude Code to list available skills — the cluster-agnostic
subset from dvystrcil/skills should appear (plus any Anthropic-installed
skills like find-skills / tdd / scheduler that this script doesn't manage).

If $DIARY_PATH is a git clone (e.g. your work-diary or personal-diary repo),
push entries to its remote periodically — entries are markdown files Claude
writes to that directory; git semantics are operator-managed.

To update later: run \`./update.sh\` from this directory. It pulls both repos
and re-runs install.sh with the env vars this install was invoked with.
update.sh is gitignored — regenerated on every install.

To uninstall: ./install.sh --uninstall
EOF
