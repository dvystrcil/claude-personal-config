#!/bin/bash
# install.sh — idempotent setup for the portable Claude Code methodology.
#
# Sets up:
#   - Symlinks selected skills to ~/.claude/skills/
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
#   DIARY_PATH      Required for install. Where diary entries are written.
#   WORK_PATHS      Comma-separated path prefixes treated as work-managed.
#                   Defaults: /work,/Work,/opt/enterprise,/opt/company,~/Work,~/work
#                   At a WORK install, set this to "" (empty) to disable the
#                   refuse-if-under-work check (since you WANT the diary in work
#                   storage there).
#   PERSONAL_PATHS  Comma-separated path prefixes treated as personal-managed.
#                   Empty by default. At a WORK install, set this to your known
#                   personal roots (iCloud, Dropbox, etc.) so the install refuses
#                   if DIARY_PATH accidentally lands there.
#   CLAUDE_HOME     Optional. Defaults to ~/.claude.
#
# IP-boundary intent:
#   - HOME install: keep diary OUT of work-managed storage. WORK_PATHS check fires.
#   - WORK install: keep diary OUT of personal-managed storage. PERSONAL_PATHS
#     check fires. (Work entries belong in work systems for IP compliance.)
#   - Methodology repo source lives in a personally-managed location at home;
#     at work it's cloned to wherever (it's open-source public methodology).

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_HOME="${CLAUDE_HOME:-$HOME/.claude}"
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
        # trim whitespace + expand ~
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
    info "Uninstalling — removing symlinks, settings fragment, CLAUDE.md diary block, and update.sh."
    local update_script="$REPO_DIR/update.sh"
    if [ -f "$update_script" ]; then
        rm "$update_script"
        info "  removed update.sh: $update_script"
    fi
    local skills_dir="$CLAUDE_HOME/skills"
    if [ -d "$skills_dir" ]; then
        for sk in "$REPO_DIR"/claude-skills/*/; do
            name=$(basename "$sk")
            target="$skills_dir/$name"
            if [ -L "$target" ]; then
                rm "$target"
                info "  removed symlink: $target"
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
        # If CLAUDE.md is now blank or only whitespace, remove the file entirely
        if [ ! -s "$claude_md" ] || ! grep -q '[^[:space:]]' "$claude_md"; then
            rm "$claude_md"
            info "  removed empty CLAUDE.md: $claude_md"
        fi
    fi
    info "Uninstall complete. Diary entries at \$DIARY_PATH left untouched."
    exit 0
}

if [ "${1:-}" = "--uninstall" ]; then
    uninstall
fi

# Pre-flight 1: refuse to install from inside a work-managed path. The
# methodology repo's source should sit in a personally-managed location even on
# a work box (it's public; clone it under your home dir, not under ~/Work/).
matched=$(is_under_any_path "$REPO_DIR" "$WORK_PATHS" || true)
if [ -n "$matched" ]; then
    err "Install dir '$REPO_DIR' is under work-managed path '$matched'.
Move this repo to a non-work-managed directory (e.g. ~/.config/claude-personal/)
before installing. The methodology repo itself is open-source public; cloning
it under ~/Work/ confuses ownership at audit time. To intentionally disable
this check, set WORK_PATHS=\"\" when invoking install.sh."
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

# Resolve DIARY_PATH absolutely
DIARY_PATH="${DIARY_PATH/#\~/$HOME}"

# Pre-flight 2a: at HOME installs (WORK_PATHS active), refuse if DIARY_PATH is
# under a work-managed path. Keep personal-environment diary out of work
# storage.
matched=$(is_under_any_path "$DIARY_PATH" "$WORK_PATHS" || true)
if [ -n "$matched" ]; then
    err "DIARY_PATH '$DIARY_PATH' is under work-managed path '$matched'.
If this is a HOME environment: pick a personal-managed path instead.
If this IS a work environment: set WORK_PATHS=\"\" to disable this check
and set PERSONAL_PATHS to your known-personal roots so the inverse check
fires instead.

Examples:
  Home:  DIARY_PATH=~/iCloud-Drive/diary ./install.sh
  Work:  PERSONAL_PATHS=~/iCloud-Drive,~/Dropbox WORK_PATHS=\"\" \\
         DIARY_PATH=~/Work/claude-diary-work ./install.sh"
fi

# Pre-flight 2b: at WORK installs (PERSONAL_PATHS active), refuse if DIARY_PATH
# is under a personal-managed path. Keep work-environment diary out of personal
# storage.
matched=$(is_under_any_path "$DIARY_PATH" "$PERSONAL_PATHS" || true)
if [ -n "$matched" ]; then
    err "DIARY_PATH '$DIARY_PATH' is under personal-managed path '$matched'.
At a work install, the diary should live in WORK-managed storage so entries
stay in the IP boundary of the work environment that produced them. Pick a
work-managed path (e.g. a clone of your work GitHub's diary repo)."
fi

# Create DIARY_PATH if it doesn't exist
mkdir -p "$DIARY_PATH"
info "Diary path: $DIARY_PATH"

# Symlink skills
mkdir -p "$CLAUDE_HOME/skills"
for sk in "$REPO_DIR"/claude-skills/*/; do
    name=$(basename "$sk")
    target="$CLAUDE_HOME/skills/$name"
    if [ -L "$target" ]; then
        actual=$(readlink "$target")
        if [ "$actual" = "$sk" ] || [ "$actual" = "${sk%/}" ]; then
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
    ln -s "$sk" "$target"
    info "  ✓ symlinked $name"
done

# Write Claude Code settings fragment
frag="$CLAUDE_HOME/settings.local.claude-personal-fragment.json"
cat > "$frag" <<EOF
{
  "_comment": "Generated by claude-personal-config/install.sh — do not edit by hand. Re-run install.sh to update.",
  "diary": {
    "path": "$DIARY_PATH",
    "methodology_ref": "$REPO_DIR/diary/README.md"
  }
}
EOF
info "  ✓ wrote settings fragment: $frag"

# Append a marked block to ~/.claude/CLAUDE.md so Claude Code's session-start
# context includes the diary-path pointer. The settings fragment is just JSON
# documentation; Claude Code doesn't auto-load it. CLAUDE.md IS auto-loaded
# at session start. Markers make the block idempotent (re-runs replace it
# in place) and removable on --uninstall.
claude_md="$CLAUDE_HOME/CLAUDE.md"
marker_start="# >>> claude-personal-config (managed by install.sh — do not edit between markers) >>>"
marker_end="# <<< claude-personal-config <<<"

# Remove any existing managed block (idempotent re-runs)
if [ -f "$claude_md" ] && grep -qF "$marker_start" "$claude_md"; then
    # sed -i differs across BSD (macOS) vs GNU; use a portable temp-file pattern
    tmp=$(mktemp)
    awk -v start="$marker_start" -v end="$marker_end" '
        $0 == start { skip=1; next }
        $0 == end   { skip=0; next }
        !skip       { print }
    ' "$claude_md" > "$tmp"
    mv "$tmp" "$claude_md"
fi

# Append the managed block (creates the file if it doesn't exist).
# Block records the environment-specific DIARY_PATH and points at the
# `diary` skill that carries the methodology (trigger conditions, voice,
# file format, what doesn't go in). The skill itself is symlinked into
# ~/.claude/skills/diary/ above, so Claude Code loads it natively at
# session start — the block here is the place that records WHERE this
# install writes entries (which varies per environment).
cat >> "$claude_md" <<EOF

$marker_start
# Diary practice — when to write + how to format lives in the \`diary\` skill:
#   $CLAUDE_HOME/skills/diary/SKILL.md
# (symlinked from this repo: $REPO_DIR/claude-skills/diary/SKILL.md)
#
# Entries land in:
#   $DIARY_PATH
#
# Settings fragment ref: $frag
$marker_end
EOF
info "  ✓ wrote CLAUDE.md diary block: $claude_md"

# Write a per-workstation update.sh that re-runs install.sh with this
# workstation's resolved env vars baked in. Saves the operator from
# having to remember DIARY_PATH / WORK_PATHS / PERSONAL_PATHS each
# time they want to update. Gitignored.
update_script="$REPO_DIR/update.sh"
{
    echo "#!/bin/bash"
    echo "# update.sh — generated by install.sh on $(date -u +'%Y-%m-%dT%H:%M:%SZ')."
    echo "# Pulls the latest methodology + re-runs install.sh with the env this"
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
    echo "echo 'Re-running install with saved env...'"
    # The pre-baked invocation. Use single-quoted values to handle paths with
    # special characters safely. WORK_PATHS / PERSONAL_PATHS preserved even
    # when empty so the work-install case (WORK_PATHS="") survives re-runs.
    echo "DIARY_PATH='$DIARY_PATH' \\"
    echo "WORK_PATHS='$WORK_PATHS' \\"
    echo "PERSONAL_PATHS='$PERSONAL_PATHS' \\"
    echo "CLAUDE_HOME='$CLAUDE_HOME' \\"
    echo "  ./install.sh"
} > "$update_script"
chmod +x "$update_script"
info "  ✓ wrote per-workstation update.sh: $update_script"

cat <<EOF

Install complete.

  Skills linked under:  $CLAUDE_HOME/skills/
  Settings fragment:    $frag
  Diary entries land:   $DIARY_PATH

To verify: ask Claude Code to list available skills — the set from this repo
should appear.

If $DIARY_PATH is a git clone (e.g. your work-diary or personal-diary repo),
push entries to its remote periodically — entries are markdown files Claude
writes to that directory; git semantics are operator-managed.

To update later: run \`./update.sh\` from this directory. It pulls the latest
methodology + re-runs install.sh with the env vars this install was invoked
with (DIARY_PATH, WORK_PATHS, PERSONAL_PATHS, CLAUDE_HOME). update.sh is
gitignored — regenerated on every install.

To uninstall: ./install.sh --uninstall
EOF
