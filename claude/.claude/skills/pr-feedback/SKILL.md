---
name: pr-feedback
description: >
  Address GitHub PR review comments by fetching unresolved feedback, planning fixes,
  implementing changes, and replying to reviewers. Use this skill when the user wants to
  address PR review comments, fix PR feedback, handle review requests, or respond to
  code review on a pull request. Also trigger when the user mentions "PR comments",
  "review feedback", "address review", or references a PR number with review context.
  Even if the user just says something like "address the comments on my PR" or "fix what
  the reviewers said", this skill should activate.
---

# PR Feedback

Address unresolved review comments from a GitHub PR: fetch them, plan fixes, implement
changes as a coordinated agent team, then commit and reply to reviewers — with user
approval before any external-facing action.

## Prerequisites

- `gh` CLI installed and authenticated
- Working directory is inside the repo (or user provides the repo identifier)

## Step 0: Resolve the Repository

Before any `gh` commands, determine the owner and repo name. This is critical because
`gh api` placeholder resolution (`{owner}`, `{repo}`) only works if the working directory
is inside a git repo with a configured remote — and that's not always the case.

```bash
gh repo view --json owner,name -q '"\(.owner.login)/\(.name)"'
```

If this fails (e.g., not in a git directory), ask the user for the repository in
`owner/repo` format.

Store the result as `REPO` (e.g., `acme/widgets`). Use it in **every** subsequent `gh`
command, either as the `-R` flag or interpolated into API paths. Never rely on implicit
repo detection — always be explicit.

## Step 1: Fetch Review Comments

The user provides a PR number or URL as an argument (e.g., `/pr-feedback 123` or
`/pr-feedback https://github.com/org/repo/pull/123`).

If a URL is given, also extract the `owner/repo` from it (overriding any local detection)
and the PR number from the path.

Fetch review comments using explicit repo paths:

```bash
# Individual review comments (line-level)
gh api "repos/${REPO}/pulls/${PR}/comments" \
  --paginate \
  --jq '[.[] | {
    id: .id,
    in_reply_to_id: .in_reply_to_id,
    path: .path,
    line: .line,
    original_line: .original_line,
    diff_hunk: .diff_hunk,
    body: .body,
    user: .user.login,
    created_at: .created_at
  }]'
```

```bash
# Top-level review bodies (overall review summaries)
gh api "repos/${REPO}/pulls/${PR}/reviews" \
  --paginate \
  --jq '[.[] | select(.state != "DISMISSED" and .body != "") | {
    id: .id,
    body: .body,
    user: .user.login,
    state: .state
  }]'
```

Process the fetched data:

1. **Separate top-level comments from replies** — comments where `in_reply_to_id` is null
   are top-level; others are reply threads. Only top-level comments represent review
   feedback to address.
2. **Group by file** — organize comments by file path for a clear summary.
3. **Include diff context** — the `diff_hunk` field shows what code the reviewer was
   looking at, which is essential for understanding the feedback.

Present a summary to the user:
- Total number of review comments found
- Grouped by file: reviewer name, comment body, line reference, and a snippet of the
  diff hunk for context
- Any top-level review summaries

If there are no comments, tell the user and stop.

## Step 2: Plan Fixes

Read each commented file at the referenced lines. Group related comments (multiple
comments about the same logical concern, even across files). For each comment or group,
produce a plan entry:

```
## Plan

### Comment 1 (@alice — src/utils.py:42)
> "This should handle the None case"
**Action:** Add a None guard before the dictionary lookup on line 42.

### Comments 2–3 (@bob — src/handler.ts:10–15)
> "Extract this into a helper" / "Too much nesting here"
**Action:** Extract the nested validation logic into a `validateInput()` helper.

### Comment 4 (@alice — src/handler.ts:30)
> "Why not use the existing util?"
**Action:** Reply only — this is a question. Explain that we chose inline logic for
performance reasons (no code change needed).
```

Categorize each comment:
- **Fix needed** — reviewer is requesting a code change
- **Reply only** — reviewer is asking a question or making an observation; draft a reply
  but no code change
- **Conflicting** — two reviewers give contradictory feedback; flag for user decision
- **Stale reference** — comment references a line that no longer exists; flag for user

Present the plan and **wait for user approval** before proceeding.

## Step 3: Implement Fixes (Agent Team)

Once approved, use an agent team to implement fixes in parallel where possible. This is
the core advantage of the team approach: independent fixes across different files can be
done simultaneously.

Create a team and spawn agents for the work:

1. **Create the team** using TeamCreate (e.g., team name `pr-fixes`).
2. **Create tasks** — one task per independent fix or group of related fixes. Each task
   should include the comment(s) it addresses, the file(s) to modify, and the planned
   change from Step 2.
3. **Spawn implementer agents** — use the Agent tool with `team_name` to spawn teammates.
   Each agent gets assigned a task and works on it independently. Use
   `subagent_type: "general-purpose"` so they have full file editing access.
4. **Coordinate** — if some fixes depend on each other (e.g., one introduces a helper that
   another uses), set up `blockedBy` dependencies between tasks so they execute in the
   right order.

Each implementer agent should:
- Read the relevant file(s)
- Make the planned changes
- If the project has lint/test commands (check CLAUDE.md), run them on the changed files
- Mark its task as completed when done

Wait for all agents to finish, then clean up the team.

For small PRs (3 or fewer independent fixes), you can skip the team approach and just
implement the fixes sequentially — the overhead of team coordination isn't worth it for
a handful of simple changes.

## Step 4: Verify and Present

After all fixes are implemented:

1. **Run project verification** — check CLAUDE.md or AGENTS.md for test/lint commands.
   Run them to confirm nothing is broken.
2. **Show the user what changed:**
   - Summary of modified files and the nature of each change
   - Tell them they can review the full diff with `git diff`
3. **Draft a commit message** referencing the PR number and summarizing the feedback
   addressed.
4. **Draft reply text for each comment** — short, professional replies explaining what was
   done. Examples:
   - "Good catch — added a None guard here."
   - "Extracted into `validateInput()` as suggested. Also reduced the nesting."
   - "This was intentional — we use inline logic here for performance. Happy to discuss further."

Ask the user: "Ready to commit, push, and reply to comments? You can also ask me to
adjust any replies or the commit message first."

## Step 5: Commit, Push, and Reply

Only proceed once the user explicitly approves.

1. **Commit** — stage only the specific files that were changed (never `git add -A`):
   ```bash
   git add <file1> <file2> ...
   git commit -m "<message>"
   ```

2. **Push** the branch:
   ```bash
   git push
   ```

3. **Reply to each comment** on GitHub using the explicit repo:
   ```bash
   gh api "repos/${REPO}/pulls/comments/${COMMENT_ID}/replies" \
     -f body="<reply text>"
   ```

4. **Report** what was done: files committed, branch pushed, and how many comments were
   replied to.

## Edge Cases

- **Comment on deleted lines**: If `line` is null but `original_line` exists, the line was
  removed in a subsequent commit. Note this in the plan and ask the user how to proceed.
- **Conflicting feedback**: Flag in the plan, present both sides, let the user decide.
- **Non-actionable comments**: Questions, acknowledgments, "nit" observations that don't
  need code changes — categorize as "reply only" in the plan.
- **Large PRs (>15 comments)**: Group by theme/file and ask the user whether to tackle
  everything at once or work through one group at a time.
- **Pagination**: Always use `--paginate` with `gh api` to handle PRs with many comments.
