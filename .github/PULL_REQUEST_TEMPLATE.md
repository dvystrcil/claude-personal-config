<!-- Thanks for the PR. Read the selection criteria below before submitting; PRs that don't fit will be closed without merge. -->

## What this change is

<!-- One paragraph. What does this PR add/modify/remove and why? -->

## Selection criteria checklist

This repo is **methodology only**. Submissions must satisfy ALL of these:

- [ ] **Methodology, not project content.** The change describes *how to think/work*, not *what to do for a specific project, cluster, or organization*.
- [ ] **Either fully generic, OR builds on the shared toolchain.** The shared toolchain across the maintainer's environments is: **Kubernetes**, **ArgoCD** (app-of-apps pattern + `argocd-projects/` layout), and **Infisical** (or `InfisicalSecret` CRD). Skills/docs MAY reference these by name. They MUST NOT encode environment-specific details (cluster names, hostnames, IP ranges, app names, version numbers).
- [ ] **No private references.** No URLs to private repos, no internal documentation paths, no proprietary tooling names beyond the shared toolchain above.
- [ ] **No diary entries.** Diary entries belong at `$DIARY_PATH` (the operator's personal storage), not in this repo. Submissions must NOT add diary entries even as examples.
- [ ] **No secrets, tokens, or credentials.** Even commented out, even in examples.

## Type of change

- [ ] New skill
- [ ] Update to existing skill
- [ ] AC-process template / methodology doc
- [ ] Install script change
- [ ] Repo governance (CODEOWNERS, templates, branch protection docs, etc.)
- [ ] Other (explain below)

## Verification

<!-- For new skills: "the skill compiles in Claude Code; example invocation produces expected output." For install.sh changes: "ran install.sh on a clean directory; refused the unsafe paths I tested; symlinks created at the expected locations." -->

---

<!-- Maintainer (@dvystrcil): merge with squash unless the PR is a coherent multi-commit story. Add a closing comment with what shipped + what's followed. -->
