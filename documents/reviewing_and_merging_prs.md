# Pull Request Review, Documentation & Merge Standards

This document establishes the official standards and workflow for reviewing, documenting, and merging Pull Requests in the **LetterLogic** repository—whether handled by a human developer or an autonomous agent.

---

## 1. Role Overview & Responsibilities

The **PR Reviewer & Documentation Agent** acts as the quality gatekeeper and documentation steward for the repository.

### Primary Responsibilities
1. **Review Diff & Context:** Inspect the Pull Request description, code diff, and automated test results provided by the Issue Resolver.
2. **Verify Acceptance Criteria:** Confirm that all criteria in the linked issue are satisfied.
3. **Manual Verification:** Perform or verify manual test steps if UI/visual changes are involved.
4. **Synchronize Documentation:** Update `documents/requirements.md`, `documents/manual_testing.md`, and `README.md` to keep all project documentation strictly aligned with code changes.
5. **Merge to Main:** Perform a standard Git merge commit (preserving full history) and delete the remote feature branch.
6. **Workspace Cleanup:** Pull latest `main` into the repository and clean up any local worktrees.

---

## 2. Review Checklist

Before approving or merging any Pull Request, verify the following:

### 1. Code Quality & Standards
* [ ] **Static Typing:** GDScript code strictly uses static typing for all variables, function arguments, and return types.
* [ ] **Naming Conventions:** Classes/Nodes use `PascalCase`; functions/variables/signals use `snake_case`; constants use `UPPER_SNAKE_CASE`.
* [ ] **Logging:** No raw `print()` statements. Uses `print_debug()`, `push_warning()`, or `push_error()`.
* [ ] **Comments:** Explains the *why*, not the obvious *what*.

### 2. Testing Verification
* [ ] **Automated Tests:** PR body includes evidence that all automated tests pass (`Test Results: X Passed, 0 Failed`).
* [ ] **New Tests Added:** If core logic, autoloads, or calculations were altered, corresponding unit tests are present in `game/tests/`.

### 3. Reviewer Handoff Notes
* [ ] Check the PR description's **"Handoff for PR Reviewer & Documentation Agent"** section for specific documentation and testing notes provided by the resolver.

---

## 3. Documentation Coordination (Mandatory Prior to Merge)

The reviewing agent is directly responsible for synchronizing project documentation with code changes.

### 1. `documents/requirements.md`
* Update existing requirement specifications or add new requirement IDs if functionality, constraints, or colors changed.
* Ensure status tracking and traceability remain accurate.

### 2. `documents/manual_testing.md`
* Add or update test scenarios to provide human testers and QA agents with reproduction and validation steps for the new functionality.

### 3. `README.md`
* Update if user-facing behavior, controls, rules, or visuals (e.g., color indicators or emoji representations) are changed.

### Committing Documentation Updates
Documentation updates should be committed either directly to the feature branch before merging:
```powershell
git commit -m "docs: update requirements and manual testing for issue #<number>"
git push origin feature/issue-<number>-<short-description>
```
Or immediately after merging directly to `main` if preferred by the workflow.

---

## 4. Merging Protocol

### 1. Merge the Pull Request
Merge the PR using the GitHub CLI with a **standard merge commit** (preserving the complete Git graph and atomic commits):
```powershell
gh pr merge <pr_number> --merge --delete-branch
```
> [!IMPORTANT]
> **DO NOT squash** (`--squash`) or rebase (`--rebase`). Standard merge commits (`--merge`) preserve the detailed history of atomic commits in the repository.

### 2. Verify Issue Closure
Confirm that the linked issue (`Resolves #<number>`) has transitioned to `CLOSED`.

### 3. Local Repository Synchronization & Worktree Cleanup
From the main project directory:
```powershell
# Switch to main and pull latest merge commit
git checkout main
git pull origin main

# Remove the feature worktree
git worktree remove .worktrees/issue-<number>

# Prune worktree metadata
git worktree prune
```
