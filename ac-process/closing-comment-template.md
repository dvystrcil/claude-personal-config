# Closing comment template — final AC status

Copy this into a closing comment when the work is done. Or into a status-checkpoint comment when a substantial chunk is done but the ticket isn't ready to close.

Two flavors below — Markdown (GitHub-native, also pastes into Jira's text editor) and Jira-native (for trackers where you prefer the platform's built-in macros).

---

## Markdown flavor

## Final status

| AC | Description | Status | Evidence |
|---|---|---|---|
| AC1 | [description] | ✅ | [commit SHA, PR#, file path] |
| AC2 | [description] | ✅ | [evidence] |
| AC3 | [description] | ❌ | [why not — blocked / deferred / scope-cut, with follow-on if applicable] |
| AC4 | [description] | ⏳ | [in-progress; expected timing or follow-on ticket] |
| AC5 | [description] | ✅ | [evidence] |

## What shipped

[1-3 paragraphs. What changed in the system as a result of this work. Useful for someone reading 6 months from now.]

## What didn't ship

[Honest list of anything in the original scope that didn't make it. For each, note: why not, and where it's tracked now (follow-on ticket, deferred to next sprint, dropped as out-of-scope).]

## Follow-ons

- [Linked tickets that this work surfaced or that were deferred from this work]

---

## Jira-native flavor

h2. Final status

||AC||Description||Status||Evidence||
|AC1|[description]|(/) |[commit SHA, PR#, file path]|
|AC2|[description]|(/) |[evidence]|
|AC3|[description]|(x) |[why not — blocked / deferred / scope-cut, with follow-on if applicable]|
|AC4|[description]|(?) |[in-progress; expected timing or follow-on ticket]|
|AC5|[description]|(/) |[evidence]|

h2. What shipped

[1-3 paragraphs.]

h2. What didn't ship

[Honest list of original-scope items that didn't make it, with where they're tracked now.]

h2. Follow-ons

* [Linked tickets — Jira auto-links {{PROJ-NNN}} references]
