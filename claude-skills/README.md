# Claude skills

Cluster-agnostic skills, selected for portability to any workstation (personal or work).

## Selection criteria

A skill is included here if it satisfies all of:

1. **Methodology, not project content.** Describes *how to think/work*, not *what to do for project X*.
2. **Either fully generic, OR builds on tooling the operator uses across both home and work environments.** The shared toolchain across both is currently: **Kubernetes**, **ArgoCD** (with the app-of-apps pattern + `argocd-projects/` directory layout), and **Infisical** (or `InfisicalSecret` CRD) for secret management. Skills can reference these by name. Skills must NOT encode environment-specific details (cluster names, hostnames, IP ranges, specific app names, version numbers); those go in the operator's `~/.claude/skills/` set at each environment separately.
3. **No private references.** No URLs to private repos, no internal documentation paths, no proprietary tooling names beyond the shared toolchain above.

## Skills included

| Skill | What it does | Notes |
|---|---|---|
| `code-reviewer/` | Code-review checklist + process | Contains one illustrative ArgoCD example; ArgoCD is shared between environments |
| `devops-engineer/` | K8s + ArgoCD + Infisical + CI/CD operations | Scrubbed of cluster-specific details (no hostnames, IPs, node names, app names); patterns + workflows only |
| `diary/` | Reflective diary practice — trigger conditions, voice rules, file format | Carries the methodology that used to live in the top-level `diary/README.md`; environment-specific `DIARY_PATH` is in CLAUDE.md + the JSON settings fragment |
| `doc-master/` | Documentation/writing assistance | Cluster-agnostic |
| `find-skills/` | Discover what skills are available | Helper for orienting in a new skill set |
| `first-ask/` | Clarify scope before starting | Methodology, no project refs |
| `frontend-design/` | Frontend code review + design | Cluster-agnostic |

## Skills NOT included (and why)

| Skill | Why excluded |
|---|---|
| `homelab-memory` | Tied to a specific PostgresCluster in the homelab cluster — no analog at work yet |
| `n8n-import-workflow` | Tied to homelab n8n deployment |
| `owui-import-pipeline` | Tied to homelab OWUI pipelines pod |
| `owui-memory-loader` | Tied to homelab OWUI deployment |

Each "NOT included" skill can become portable when the work environment gains the analogous tooling AND the operator decides to build skills around it. Today's shared toolchain is limited to Kubernetes + ArgoCD + Infisical; that scope can grow over time, deliberately.

## How to add a new skill

1. Verify the skill satisfies the selection criteria above.
2. Copy the skill directory into `claude-skills/`.
3. Update this README's tables.
4. Open a PR — the diff makes the addition reviewable.

When the parent skill in your primary workstation updates, periodically re-sync into this repo. There's no automatic sync — that's intentional, so a homelab-specific change doesn't accidentally land here.

## Skills NOT included that someone might miss

Anything tied to specific platforms (jira, linear, github-actions-specific-to-org, etc.) is out of scope. Add as needed in your work-environment-specific config layer, not here.
