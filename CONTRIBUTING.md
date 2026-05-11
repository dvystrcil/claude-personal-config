# Contributing to claude-personal-config

This repo is intentionally narrow: portable Claude Code methodology (skills, AC-issue patterns, diary practice) that's safe to use across personal and work workstations with a clean IP boundary.

If you found something useful here and want to contribute back, thank you. Please read the selection criteria below before opening a PR — submissions that don't fit will be closed without merge to keep the repo focused.

## What's IN scope

- **Cluster-agnostic skills.** Code-review patterns, documentation helpers, AC-driven issue templates, frontend-design checklists, etc. These describe *how to think/work*, not *what to do for project X*.
- **Skills that build on the shared toolchain.** The maintainer's home and work environments both use **Kubernetes**, **ArgoCD** (app-of-apps pattern + `argocd-projects/` layout), and **Infisical**. Skills referencing these by name are fine; skills referencing specific cluster names, hostnames, IPs, or app versions are not.
- **AC-process documentation.** Templates for issue bodies, closing comments, and the broader "define ACs upfront, work through them explicitly, present a ✅/❌/⏳ table at the end" pattern. The templates support both GitHub Issues and Jira syntax (per `ac-process/README.md`).
- **Diary methodology.** The README at `diary/README.md` documents *how* the diary practice works. The methodology is open; specific entries are not (see below).
- **Install script improvements.** Reliability, error-handling, safer path detection, support for additional personal-storage backends (anything that keeps the IP boundary intact).
- **Bug reports.** Open an issue with reproduction steps.

## What's OUT of scope

- **Diary entries.** Entries live at the operator's `$DIARY_PATH` (personal-managed storage), never in this repo. Submissions that include diary entries — even as examples — will be closed.
- **Environment-specific skills.** Skills tied to a specific Kubernetes cluster, a specific app name, a specific hostname, or a specific version. The `claude-skills/README.md` "NOT included" table documents excluded skills as concrete examples (`homelab-memory`, `owui-import-pipeline`, etc.).
- **Per-organization issue tracker templates.** The AC-process docs support GitHub + Jira flavors; per-org template customizations (specific Jira project IDs, specific GitHub Actions integrations, etc.) belong in a fork.
- **Tooling that requires private resources.** Skills referencing private repos, internal documentation, or proprietary services that not everyone can access.
- **Major scope expansions.** This repo intentionally stays narrow. Adding "claude-personal-data-storage" or "claude-personal-agent-runtimes" is out of scope; open a sibling repo if that's the work.

## Submitting a PR

1. **Read the selection criteria above.** Confirm your change satisfies all of them.
2. **Open the PR against `main`** with the PR template's checklist filled in.
3. **Wait for review.** The repo's CODEOWNERS rule requires @dvystrcil's approval; expect 1-7 days depending on availability.
4. **Squash-merge is the default** for PRs that are coherent single-topic changes. Multi-commit stories are merged as-is.

## Licensing

By contributing, you agree your contribution is licensed under the same terms as the rest of the repo:

- **Code** (anything in `install.sh` or future scripts): MIT (see `LICENSE-CODE.md`)
- **Documentation** (READMEs, methodology docs, templates): CC-BY-4.0 (see `LICENSE-DOCS.md`)

If your contribution would change the licensing, that's a separate conversation — open an issue first.

## Code of conduct

Be respectful in issues and PR discussions. The maintainer is one person who runs this repo in their personal time; tone matters. If you've ever heard the phrase "engage with the work, not the person," that's the standard here. Substantive disagreement is welcome; personal attacks are not.

## Questions

Open an issue with the `question` label, or DM the maintainer if you know them through another channel. Don't expect immediate responses — this is volunteer work.
