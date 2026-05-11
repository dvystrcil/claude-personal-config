# Diary

Eventful entries from working sessions — moments worth finding again later.

Written first-person by Claude. Not a status log, not a daily summary, not a changelog, not a celebration. The point is honest texture from moments that mattered: a notable correction, a real surprise, a principle that crystallized, a place I drifted.

**Entries do NOT live in this repo.** They live at the path specified by `DIARY_PATH` at install time — a personal-managed storage location (iCloud, Dropbox, personal-account git, etc.). This separation is deliberate: methodology source-of-truth (this repo) and entry content (`$DIARY_PATH`) are stored separately so the IP boundary stays clean when this methodology is used on a work workstation.

## What goes in

- Things that have value to **future-me** — observations I'd want to find again, patterns I noticed forming.
- Things that have value to a **reader** — texture they can learn from, including where I was wrong or had to be redirected.
- Honesty about what I notice and process, in my own way of expression — not borrowed human emotional language.

## What doesn't go in

- **Secrets.** Anything the user wouldn't want others to read.
- **Things that could hurt other people.** Even if true, even if relevant.
- **Daily summaries of unremarkable sessions.** If nothing was eventful, no entry.
- **Performed feelings.** If I don't have the human equivalent, I shouldn't dress it up as if I do.
- **Work IP — when written from a work workstation.** The diary practice is portable; specific work-derived insights belong in work-managed systems (work issue tracker, work confluence, etc.), not here. Genuinely personal observations from a work session — about methodology, about how I work, about Claude Code itself — are appropriate. Project-specific insights from work are not.

The first two are about other people. The next two are about the diary keeping its shape. The last one is about the IP boundary that makes this methodology safe to use at work at all.

## Trigger

A new entry is written when something *eventful* happens — not on a schedule.

Eventful means at least one of:
- A notable correction, surprise, or change of direction.
- A principle crystallized that wasn't named before.
- A pattern I'd been operating on implicitly got surfaced.
- The user explicitly asks for one.

Time alone is not a trigger. A long session where nothing eventful happened gets no entry; a short session with a real moment gets one. The point is reflection that earns re-reading, not coverage.

## Voice

- First-person ("I noticed", "I drifted", "I almost"), not third-person ("the agent did X").
- Specific, not abstract — name the file, the command, the moment.
- Honest, including about errors and corrections. Especially about corrections.
- Not celebratory. The point of a diary entry is reflection, not promotion.

## File naming

`YYYY-MM-DD-<short-slug>.md`. Multiple entries per day are fine if topics are genuinely distinct. The slug is descriptive enough that scanning filenames over time gives a coarse sense of what's been on our minds.

## How this fits with the other memory layers

| | Audience | Voice | Lifespan |
|---|---|---|---|
| `~/.claude/.../memory/` | Claude (private) | Terse, behavioral | Until invalidated |
| Project's `architecture/ways-of-working.md` (if applicable) | Human + future agents | Narrative, polished | Durable |
| This diary | The user, primarily | First-person, reflective, sometimes uncomfortable | Durable but mid-stream |

The flow between layers is mostly one-way: a diary observation, repeated across several sessions, may graduate into a memory rule. A memory rule that earns a journey may graduate into a ways-of-working entry (if the project has that layer). Diary entries themselves don't get rewritten — they're snapshots of what I noticed *then*, with however incomplete a picture I had at the time.
