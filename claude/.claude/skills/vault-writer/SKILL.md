---
name: vault-writer
description: >
  Use when the user wants to add notes, documentation, meeting notes, or any
  content to their Obsidian vault. Trigger when the user says things like
  "add to vault", "write a note", "save this to obsidian", "meeting notes",
  "add to daily", "new tech reference", or mentions writing to specific vault
  folders like Daily, Meeting Notes, Tech Reference, DMD-A, DMD-Agent, or Logbook.
---

# Vault Writer

## Overview

Write content to the Obsidian vault at `/Users/dkmilomo/Documents/LEGO`. Determine what the user wants to capture, pick the right location, and write it following vault conventions.

**Critical rule:** Obsidian uses filenames as titles. NEVER add a top-level `#` heading to any file. Start content with `##` sections.

## Vault Structure

| Folder | Purpose |
|---|---|
| `Daily/` | One file per day (`YYYY-MM-DD.md`) |
| `Meeting Notes/` | Prefixed by team (`YYYY-MM-DD - TEAM - Topic.md`) |
| `Personal Development/` | IDP, reflections, career docs |
| `Tech Reference/` | General how-to notes, not team-specific |
| `DMD-A/Projects/` | Feature docs, plans, specs for DMD-A |
| `DMD-A/Technical/` | DMD-A team processes, domain reference |
| `DMD-Agent/Projects/` | Feature docs, plans, specs for DMD-Agent |
| `DMD-Agent/Technical/` | Terraform, Python, cloud, AI reference |
| `Logbook/YYYY/MM. Mon/` | Weekly summaries (`WXX.md`) and monthly summaries (`Summary.md`) |
| `Templates/` | Note templates |
| `Archive/` | Old files |

## Frontmatter

Every file MUST have YAML frontmatter with `date` and `tags`:

```yaml
---
date: YYYY-MM-DD
tags:
  - tag1
  - tag2
---
```

### Tag Reference

Read `/Users/dkmilomo/Documents/LEGO/Tech Reference/Vault Tags Reference.md` for the full predefined tag list. Key categories:

| Category | Examples |
|---|---|
| Team | `dmd-a`, `dmd-agent` |
| Domain | `terraform`, `python`, `cloud`, `ai`, `frontend`, `cpp` |
| Type | `meeting`, `project`, `process`, `how-to`, `reflection`, `weekly-review`, `daily` |
| Project | `ldd-modernisation`, `element-library`, `scene-graph`, `cloud-storage` |

Auto-select relevant tags from the predefined list. Add new free-form tags if nothing fits. Always include at least one type tag and one team tag (if team-specific).

## Process

### 1. Understand the Content

Read what the user provides. Ask one clarifying question if intent is genuinely unclear — otherwise proceed.

### 2. Determine Location and Confirm

Match content to the right folder using the structure table. Then confirm:

"I'll put this in `[folder]` as `[filename]` with tags `[tags]` — sound right?"

Wait for confirmation before writing.

### 3. Write the File

- **NEVER** add a `#` heading — the filename is the title
- **ALWAYS** start with YAML frontmatter (date + tags)
- Start content with `##` sections
- For meeting notes, use structure: Attendees, Decisions, Action Items, Notes
- For daily notes, **append** to existing file if one exists for today (do not duplicate frontmatter)
- Clean up rough notes into clear, scannable content but preserve meaning

### 4. Confirm

Tell the user the full path of the file created or updated.

## Red Flags

- Adding `# Title` to a file — STOP, filename is the title
- Missing frontmatter — STOP, every file needs date + tags
- Overwriting a daily note — STOP, append instead
- Writing without confirming location — STOP, ask first
- Splitting into multiple files — STOP, one file unless user asks

## Common Mistakes

| Mistake | Fix |
|---|---|
| Adding `#` heading | Filename is the title. Start with `##` |
| Missing frontmatter | Every file needs `date` and `tags` in YAML frontmatter |
| Overwriting daily note | Read existing file first, append to relevant section |
| Wrong folder | Check the vault structure table above |
| Padding with filler | Keep it concise, don't add content user didn't provide |
