#!/usr/bin/env bash
# The CLAUDE.md block install.sh writes is the WHEN that makes the diary fire.
# It used to say "PROACTIVELY OFFER" an entry, and the operator's standing
# correction (2026-07-07) is the opposite: write the entry without asking,
# then tell the user it was written. This pins that wording.
#
# Hermetic: runs a COPY of install.sh with HOME, CLAUDE_HOME and the global
# git config in a temp dir, against a local skills repo, so it never touches
# the real ~/.claude, update.sh, or the network.
set -euo pipefail

here=$(cd "$(dirname "$0")/.." && pwd)
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

# A local "dvystrcil/skills": a bare origin and a clone, so `git pull
# --ff-only` works offline.
git -c init.defaultBranch=main init -q "$tmp/skills-src"
mkdir -p "$tmp/skills-src/claude/diary"
echo "# diary" > "$tmp/skills-src/claude/diary/SKILL.md"
echo "diary" > "$tmp/skills-src/portable-skills.txt"
git -C "$tmp/skills-src" add -A
git -C "$tmp/skills-src" -c user.name=t -c user.email=t@t commit -q -m init
git clone -q --bare "$tmp/skills-src" "$tmp/skills.git"
git clone -q "$tmp/skills.git" "$tmp/skills"

mkdir -p "$tmp/cpc" "$tmp/home" "$tmp/diary"
cp -r "$here/install.sh" "$here/hooks" "$tmp/cpc/"

HOME="$tmp/home" GIT_CONFIG_GLOBAL="$tmp/home/.gitconfig" \
CLAUDE_HOME="$tmp/home/.claude" SKILLS_REPO_DIR="$tmp/skills" \
DIARY_PATH="$tmp/diary" WORK_PATHS="" \
    bash "$tmp/cpc/install.sh" >"$tmp/out.log" 2>&1 || { cat "$tmp/out.log"; exit 1; }

block=$(sed -n '/>>> claude-personal-config/,/<<< claude-personal-config/p' "$tmp/home/.claude/CLAUDE.md")
fail=0
check() { if ! grep -qF -- "$1" <<<"$block"; then echo "FAIL: block lacks: $1"; fail=1; fi; }
check "WRITE the diary entry yourself"
check "do not ask first"
check "tell the user"
check "entries:  $tmp/diary"
# 2026-11-14: the operator, after an entry was left untracked with the git
# command handed back: "why are you not pushing your own diary entries? it was
# the whole point of making it its own repo". A git-clone diary gets its entry
# committed AND pushed by the agent; the command is only for when that fails.
check "commit the entry and push it yourself"
check "only if the commit or push fails"
if grep -qF "the command to do it)" <<<"$block"; then echo "FAIL: block still hands the push back to the user"; fail=1; fi
if grep -qi "offer" <<<"$block"; then echo "FAIL: block still says to offer"; fail=1; fi
[ "$fail" = 0 ] || { echo "--- block ---"; echo "$block"; exit 1; }
echo "ok: CLAUDE.md block says to write the entry, push it, and tell the user"
