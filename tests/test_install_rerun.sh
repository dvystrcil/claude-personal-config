#!/usr/bin/env bash
# Re-running install.sh (update.sh does, on every update) must leave
# ~/.claude/CLAUDE.md byte-identical: the block is replaced, not stacked. It
# used to leave one more blank line above the block each run (2026-11-14:
# 4 blank lines before the marker after a handful of updates). Also pins the
# closing message: a git-clone diary is committed and pushed by Claude when it
# writes an entry, not "push entries to its remote periodically".
#
# Hermetic, like test_install_diary_block.sh: a COPY of install.sh with HOME,
# CLAUDE_HOME and the global git config in a temp dir, a local skills repo.
set -euo pipefail

here=$(cd "$(dirname "$0")/.." && pwd)
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

git -c init.defaultBranch=main init -q "$tmp/skills-src"
mkdir -p "$tmp/skills-src/claude/diary"
echo "# diary" > "$tmp/skills-src/claude/diary/SKILL.md"
echo "diary" > "$tmp/skills-src/portable-skills.txt"
git -C "$tmp/skills-src" add -A
git -C "$tmp/skills-src" -c user.name=t -c user.email=t@t commit -q -m init
git clone -q --bare "$tmp/skills-src" "$tmp/skills.git"
git clone -q "$tmp/skills.git" "$tmp/skills"

mkdir -p "$tmp/cpc" "$tmp/home/.claude" "$tmp/diary"
cp -r "$here/install.sh" "$here/hooks" "$tmp/cpc/"
md="$tmp/home/.claude/CLAUDE.md"
run() {
    HOME="$tmp/home" GIT_CONFIG_GLOBAL="$tmp/home/.gitconfig" \
    CLAUDE_HOME="$tmp/home/.claude" SKILLS_REPO_DIR="$tmp/skills" \
    DIARY_PATH="$tmp/diary" WORK_PATHS="" \
        bash "$tmp/cpc/install.sh" >"$tmp/out.log" 2>&1 || { cat "$tmp/out.log"; exit 1; }
}
fail=0

# 1. no CLAUDE.md before: the block is the file, with no blank lines above it
run; cp "$md" "$tmp/one"; run; run
if ! cmp -s "$tmp/one" "$md"; then echo "FAIL: CLAUDE.md changed on re-run (fresh file)"; { diff "$tmp/one" "$md" || true; } | head; fail=1; fi
if [ "$(head -1 "$md")" != "# >>> claude-personal-config (managed by install.sh — do not edit between markers) >>>" ]; then
    echo "FAIL: fresh CLAUDE.md doesn't start with the block: $(head -3 "$md" | cat -A)"; fail=1
fi

# 2. the user's own content above: kept as is, one blank line between it and the block
printf '# my rules\n  \nbe brief\n' > "$md"     # a whitespace-only line in the user's content stays as is
run; cp "$md" "$tmp/two"; run; run
if ! cmp -s "$tmp/two" "$md"; then echo "FAIL: CLAUDE.md changed on re-run (user content)"; { diff "$tmp/two" "$md" || true; } | head; fail=1; fi
if [ "$(head -4 "$md")" != "$(printf '# my rules\n  \nbe brief\n')" ] || [ "$(sed -n 4p "$md")" != "" ]; then
    echo "FAIL: user content or separator wrong:"; head -6 "$md" | cat -A; fail=1
fi

# 3. a file that already collected blank lines above the block heals
{ printf '\n\n\n\n'; sed -n '/>>> claude-personal-config/,$p' "$tmp/one"; } > "$md"
run
if ! cmp -s "$tmp/one" "$md"; then echo "FAIL: stacked blank lines not removed"; head -3 "$md" | cat -A; fail=1; fi

# 4. the closing message
if grep -q "push entries to its remote periodically" "$tmp/out.log"; then echo "FAIL: closing message still says push periodically"; fail=1; fi
if ! grep -qF "Claude commits and pushes each entry" "$tmp/out.log"; then echo "FAIL: closing message doesn't say Claude pushes"; fail=1; fi

[ "$fail" = 0 ] || exit 1
echo "ok: re-running install leaves CLAUDE.md byte-identical; the message says Claude pushes"
