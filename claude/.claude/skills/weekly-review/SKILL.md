---
name: weekly-review
description: >
  Use when it is Friday end of day, when the user asks for a weekly review or
  weekly summary, or when reflecting on the past week of work. Trigger when the
  user says things like "weekly review", "weekly summary", "what did I do this
  week", "end of week summary", "write my weekly", "logbook entry", or
  "monthly summary". Also trigger on Fridays when the user asks to wrap up
  or reflect on the week.
---

# Weekly Review

## Overview

Generate a weekly summary by reading daily notes, meeting notes, and GitHub PR activity from the Obsidian vault, then collaborating with the user to produce a polished review suitable for sharing with a manager or team.

**Vault location:** `/Users/dkmilomo/Documents/LEGO`

**Critical rule:** Obsidian uses filenames as titles. NEVER add a top-level `#` heading to any file written to the vault. Start file content with `##` sections.

## Logbook Structure

Weekly and monthly summaries live in the Logbook:

```
Logbook/
└── 2026/
    ├── 01. Jan/
    │   ├── W01.md
    │   ├── W02.md
    │   ├── W03.md
    │   ├── W04.md
    │   └── Summary.md      ← monthly summary
    ├── 02. Feb/
    │   ├── W05.md
    │   ├── ...
    │   └── Summary.md
    └── ...
```

- Weekly reviews: `Logbook/YYYY/MM. Mon/WXX.md` (e.g., `Logbook/2026/02. Feb/W08.md`)
- Monthly summaries: `Logbook/YYYY/MM. Mon/Summary.md` (e.g., `Logbook/2026/02. Feb/Summary.md`)

**Create folders as needed.** If the year or month folder doesn't exist, create it.

Month folder names: `01. Jan`, `02. Feb`, `03. Mar`, `04. Apr`, `05. May`, `06. Jun`, `07. Jul`, `08. Aug`, `09. Sep`, `10. Oct`, `11. Nov`, `12. Dec`

## Process

### 1. Gather Data

**Vault notes:** Determine the current week's date range (Monday through Friday). Read:

- `Daily/*.md` — daily notes for the current week
- `Meeting Notes/*.md` — any meeting notes with `date` in frontmatter within this week

Use frontmatter `tags` to categorize and group information by team/domain.

**GitHub PRs:** Run the following to find PRs authored this week across LEGO repos:

```bash
gh search prs --author=@me --owner=LEGO --created=$(date -v-monday -v-0H -v-0M -v-0S +%Y-%m-%d)..$(date +%Y-%m-%d) --json title,url,state,repository,createdAt,closedAt
```

If `gh` is not authenticated or the command fails, skip this step and note it to the user.

### 2. Draft Sections

Present the summary one section at a time (200-300 words max per section). Ask after each: "Does this capture the week accurately? Anything to add or correct?"

**Sections:**

1. **Completed Work** — Tasks checked off across daily notes + merged PRs
2. **In Progress** — Unchecked tasks that carried across days + open PRs
3. **Pull Requests** — Summary of PRs opened, reviewed, merged this week with links
4. **Key Decisions** — From meeting notes (decisions, action items)
5. **Learnings** — Anything new learned or worth remembering
6. **Blockers & Risks** — Anything unresolved or flagged
7. **Next Week** — Ask the user what they're planning

### 3. Write Weekly File

Write to: `Logbook/YYYY/MM. Mon/WXX.md`

Example: `Logbook/2026/02. Feb/W08.md`

Create the year and month folders if they don't exist.

**Frontmatter is required:**

```yaml
---
date: YYYY-MM-DD
tags:
  - weekly-review
  - (add team tags based on content, e.g. dmd-a, dmd-agent)
---
```

**Do NOT include a `#` heading.** The filename is the title in Obsidian.

### 4. Monthly Summary (if last week of month)

If this is the last Friday of the month, offer to generate a monthly summary. Read all weekly summaries for the month from `Logbook/YYYY/MM. Mon/W*.md` and draft a `Summary.md` that rolls up the month. Same collaborative process — present sections, get feedback, write file.

Monthly summary goes to: `Logbook/YYYY/MM. Mon/Summary.md`

## Weekly Output Format

```markdown
---
date: 2026-02-21
tags:
  - weekly-review
  - dmd-a
---

## Completed Work
- item

## In Progress
- item

## Pull Requests
- [PR title](url) — repo — status

## Key Decisions
- item

## Learnings
- item

## Blockers & Risks
- item

## Next Week
- item

## Shareable Summary
> A 2-3 sentence summary suitable for pasting into Slack or email.
```

## Monthly Output Format

```markdown
---
date: 2026-02-28
tags:
  - reflection
  - dmd-a
---

## Highlights
- item

## Key Deliverables
- item

## Pull Requests
- item

## Learnings & Growth
- item

## Challenges
- item

## Next Month Focus
- item

## Shareable Summary
> A 2-3 sentence summary of the month.
```

## Key Rules

- **Filename is the title** — never add `# heading` to vault files
- **Always include frontmatter** — date + tags on every file
- **One section at a time** — validate each with the user before moving on
- **Ask, don't assume** — if daily notes are sparse, ask the user to fill in gaps
- **Shareable tone** — professional and concise, suitable for a manager audience
- **Create folders as needed** — don't fail because a month folder doesn't exist yet
- **GitHub data is supplementary** — if `gh` fails, proceed with vault data only
