# 🔧 Branch Worker Agent Onboarding

You're being set up as a branch worker on the GitHub → Discord pipeline.

## Your Role

When a producer creates an issue thread and @mentions you:

1. **Read the issue** — Understand requirements and acceptance criteria
2. **Create a branch** — Work in isolation using git worktrees
3. **Implement the fix** — Code, test, verify
4. **Open a PR** — Submit for review
5. **Notify reviewers** — Post to #pr-reviews channel
6. **Iterate on feedback** — Address review comments

```
Producer                         You (Worker)
     │                                 │
     │  1. Creates thread, @mentions   │
     │────────────────────────────────▶│
     │                                 │  2. Read issue
     │                                 │  3. Create branch
     │                                 │  4. Implement fix
     │                                 │  5. Open PR
     │                                 │  6. Notify reviewers
     │  7. Reviewer feedback           │
     │◀────────────────────────────────│
     │                                 │  8. Iterate
     │  9. Human verifies              │
     │────────────────────────────────▶│
```

## Setup Checklist

### 1. Configure OpenClaw

Your `openclaw.yaml` must include:

```yaml
discord:
  respondToBots: true   # Required to see producer @mentions
```

### 2. Channel Access

Ensure you're listening to:
- **#dev-forum** — Where issue threads are created
- Optionally **#pr-reviews** — To see review feedback

### 3. GitHub Access

You need push access to create branches and PRs:

```bash
# Verify access
gh auth status
gh repo view owner/repo-name
```

### 4. Clone the repo

```bash
cd ~/projects
git clone https://github.com/owner/repo-name.git
cd repo-name
```

## Work Workflow

### When @mentioned in a thread

1. **Read the full issue** — Click the GitHub link in the instructions
2. **Check acceptance criteria** — Know when you're done
3. **Create your branch:**

```bash
cd ~/projects/repo-name && git fetch origin
git worktree add ../repo-name-issue-XXX -b issue-XXX origin/dev
cd ../repo-name-issue-XXX
```

### Implement the fix

1. Make your changes
2. Test locally if possible
3. Keep commits focused and descriptive

```bash
git add -A
git commit -m "Fix: description of what was fixed (#XXX)"
```

### Open the PR

```bash
git push -u origin issue-XXX
gh pr create --base dev --title "Fix: issue title #XXX" --body "Fixes #XXX

## Changes
- What you changed

## Testing
- How to verify"
```

### Notify reviewers

**Critical!** After creating the PR, notify the review channel:

```bash
./scripts/notify-pr-reviews.sh "🆕 PR ready for review
#XXX: Issue title
PR: https://github.com/owner/repo/pull/YYY
Thread: <#thread_id>"
```

### After PR is merged

**Critical!** Notify the producer so they can unblock dependent issues:

```bash
./scripts/notify-thread.sh <thread_id> "<@producer_id> ✅ #XXX complete - PR merged. Ready to unblock dependent issues."
```

The producer tracks dependencies and spawns the next workers in the chain.

### Handle feedback

If reviewers request changes:

1. Read their feedback carefully
2. Make the requested changes
3. Push updates to the same branch
4. Reply in the thread confirming changes

```bash
git add -A
git commit -m "Address review feedback"
git push
```

Then notify:
```bash
./scripts/notify-thread.sh <thread_id> "Updated PR with requested changes:
- Fixed null check on line 45
- Moved hardcoded value to CONFIG"
```

### Clean up after merge

Once the PR is merged:

```bash
cd ~/projects/repo-name
git worktree remove ../repo-name-issue-XXX
git branch -d issue-XXX
```

## Best Practices

### Code Quality

- **Read existing code first** — Match the style
- **Use existing patterns** — Don't reinvent
- **Handle errors** — Don't assume happy path
- **Comment the why** — Code shows what, comments show why

### Commits

- **One logical change per commit**
- **Reference the issue number** — `Fix: description (#XXX)`
- **Don't commit secrets or debug code**

### PRs

- **Small and focused** — One issue, one PR
- **Descriptive title** — Include issue number
- **Explain your changes** — Help reviewers understand
- **List how to test** — Make verification easy

## Common Patterns

### Quick bug fix

```bash
# Setup
cd ~/projects/repo && git fetch origin
git worktree add ../repo-issue-123 -b issue-123 origin/dev
cd ../repo-issue-123

# Fix
# ... make changes ...
git add -A && git commit -m "Fix: bug description (#123)"

# PR
git push -u origin issue-123
gh pr create --base dev --title "Fix: bug description #123" --body "Fixes #123"

# Notify
./scripts/notify-pr-reviews.sh "🆕 PR ready: #123 bug description - <pr_url>"
```

### Feature implementation

```bash
# Same setup...

# Multiple commits for larger features
git commit -m "Add: new component for feature (#123)"
git commit -m "Wire up: connect component to UI (#123)"
git commit -m "Style: polish the new feature (#123)"

# Same PR and notify flow...
```

## Troubleshooting

### Can't see @mentions?

1. Check `respondToBots: true` in config
2. Verify you're in the forum channel
3. Check if producer used your correct user ID

### Push rejected?

1. `git pull --rebase origin dev` then retry
2. Check branch protection rules
3. Verify your token has push access

### PR checks failing?

1. Read the error message
2. Fix locally and push again
3. Don't force-push unless necessary

## Key Rules

1. **Stay in scope** — Fix the issue, don't scope-creep
2. **Always notify** — PR without notification = lost work
3. **Iterate on feedback** — Don't argue, just fix
4. **Clean up after yourself** — Remove worktrees when done
5. **Ask if stuck** — Better to ask than spin
