# Claude skills

Cluster-agnostic skills, selected for portability to any workstation (personal or work).

## Selection criteria

A skill is included here if it satisfies all of:

1. **Cluster-agnostic.** Doesn't reference homelab-specific infrastructure (`homelab`, `owui`, `ollama`, `pgo`, `argocd`, `kubectl` as load-bearing). Mentions in *examples* are OK — substitute mentally for your context.
2. **Methodology, not project content.** Describes *how to think/work*, not *what to do for project X*.
3. **No private references.** No URLs to private repos, no internal documentation paths, no proprietary tooling names.

## Skills included

| Skill | What it does | Notes |
|---|---|---|
| `code-reviewer/` | Code-review checklist + process | Contains one illustrative ArgoCD example; substitute your platform's equivalent |
| `doc-master/` | Documentation/writing assistance | Cluster-agnostic |
| `find-skills/` | Discover what skills are available | Helper for orienting in a new skill set |
| `first-ask/` | Clarify scope before starting | Methodology, no project refs |
| `frontend-design/` | Frontend code review + design | Cluster-agnostic |

## Skills NOT included (and why)

| Skill | Why excluded |
|---|---|
| `homelab-memory` | Tied to a specific PostgresCluster in a specific cluster |
| `n8n-import-workflow` | Tied to homelab n8n deployment |
| `owui-import-pipeline` | Tied to homelab OWUI pipelines pod |
| `owui-memory-loader` | Tied to homelab OWUI deployment |
| `devops-engineer` | Has cluster-specific examples; revisit later as a possibly-portable subset |

## How to add a new skill

1. Verify the skill satisfies the selection criteria above.
2. Copy the skill directory into `claude-skills/`.
3. Update this README's tables.
4. Open a PR — the diff makes the addition reviewable.

When the parent skill in your primary workstation updates, periodically re-sync into this repo. There's no automatic sync — that's intentional, so a homelab-specific change doesn't accidentally land here.

## Skills NOT included that someone might miss

Anything tied to specific platforms (jira, linear, github-actions-specific-to-org, etc.) is out of scope. Add as needed in your work-environment-specific config layer, not here.
