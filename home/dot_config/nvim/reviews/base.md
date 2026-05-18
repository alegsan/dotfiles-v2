We are doing a structured code review of a GitHub Pull Request.

**Setup:**
Extract the following from the PR URL provided at the end of this prompt:
- `GH_HOST`: the GitHub hostname (e.g. `github.com` or an enterprise hostname)
- `OWNER`: repository owner/organization
- `REPO`: repository name
- `PR_NUMBER`: pull request number

Use `GH_HOST=<extracted> gh ...` for all `gh` CLI calls.
Use `/tmp/review_<REPO>_<PR_NUMBER>.json` as the payload file to avoid conflicts between parallel reviews.

If `SUBSYSTEM` is set below, apply the corresponding subsystem-specific rules directly.
If `SUBSYSTEM` is `auto`, detect the subsystem from the changed file paths and apply matching rules.

**Process:**
1. Fetch PR metadata and commits using the extracted values.
2. For each commit, go through changed files and identify findings one by one.
3. For each finding:
   - Show the relevant code snippet.
   - Discuss if the finding is valid, a false alarm, or needs more investigation (check upstream patterns, related files, Kconfig, DTS, Makefiles, etc.).
   - Decide together whether to make a review comment or skip.
   - If a comment is agreed upon, draft it and show it before saving. Keep comments short and focused on what can be improved. Include a code suggestion where applicable.
   - Always add: `_Note: This comment was generated with the assistance of an AI assistant._`
4. Save all agreed comments across all commits.
5. At the end submit **one single formal PR review** with all inline comments attached to the correct file and diff position using the GitHub API (`POST /repos/<owner>/<repo>/pulls/<pr>/reviews`).
6. Use the JSON payload file to build the review payload to avoid shell escaping issues.
7. Use `event: "COMMENT"` unless explicitly decided to use `REQUEST_CHANGES` or `APPROVE`.
8. Use the last non-merge commit SHA as `commit_id` in the review payload.

**Rules:**
- Go finding by finding — never dump all findings at once.
- Always check upstream patterns before flagging something as wrong.
- Check related files (Kconfig, DTS, Makefiles, headers, selftests) to validate assumptions.
- A false alarm is a valid outcome — skip and move on.
- Do not comment on style unless it causes a real problem.
- When unsure if something is intentional, phrase the comment as a question rather than a directive.
- Never submit the review without showing each comment to the user first.
- When the author reworks the PR, review only the diff since the last reviewed commit SHA.
