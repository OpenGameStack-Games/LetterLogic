# OpenGameStack Agent Workflows & Standards

This document defines the rules of engagement, Git workflows, and coding standards for autonomous agents working on OpenGameStack game repositories.

## 1. Git & Worktree Workflow
- **Branching Strategy:** Agents must never push or commit directly to the `main` branch.
- **Git Worktrees:** Agents should create and use isolated Git worktrees (or dedicated feature branches) when working on issues:
  ```bash
  git worktree add ../LetterLogic-issue-<number> -b feature/issue-<number>-<short-description>
  ```
- **Feature Branches:** All feature branches must be named `feature/issue-<number>-<short-description>`.
- **Commits:** Use Conventional Commits formatting (e.g., `feat: implement dynamic keyboard`, `fix: correct UTC date calculation`, `docs: update readme`). Keep commits atomic and informative.
- **Pull Requests (PRs):**
  - When an issue is complete, push the branch to `origin` and open a Pull Request against `main` using the GitHub CLI (`gh pr create`).
  - The PR body must include a summary of changes, test verification results, and link the issue using closing keywords (e.g., `Resolves #<number>` or `Closes #<number>`).
- **PR Review & Merge:**
  - Verify PR checks/diffs.
  - Merge the PR cleanly via `gh pr merge --squash --delete-branch` (or standard merge) once verified.
  - Pull latest `main` back into the main repository and clean up any worktrees (`git worktree remove ...`).

## 2. Issue Processing Workflow
When an agent is assigned an issue, it must follow this sequence:
1. **Dependency Check:** Read the issue description carefully. If the issue states **"Depends on #X"**, verify that issue #X is completely closed and merged into `main`. Do not start work if dependencies are open.
2. **Understand & Plan:** Read the issue description and Acceptance Criteria. If anything is ambiguous, pause and ask for clarification before writing code.
3. **Workspace Setup:** Create a new feature branch and worktree from latest `main`.
4. **Implementation:** Write clean, modular, and typed GDScript code satisfying all acceptance criteria.
5. **Testing & Verification:** Run automated tests (or write them if they don't exist). Ensure the game/code runs without errors or warnings.
6. **Commit & Push:** Commit using conventional commits and push the feature branch to origin.
7. **Create PR:** Open a Pull Request with complete details linking the issue (`Resolves #<number>`).
8. **Merge PR:** Review diff, merge the PR into `main`, and clean up the worktree.

## 3. Coding Standards & Documentation
- **Godot GDScript Guidelines:** 
  - Use static typing everywhere possible (e.g., `var count: int = 0`, `func get_word() -> String:`).
  - Use PascalCase for class names and Node names. Use snake_case for variables and functions.
- **Commenting:** 
  - Do not state the obvious (e.g., `count += 1 # increments count`).
  - Comment *why* a specific architectural decision was made or *why* a complex algorithm works the way it does.
  - Every AutoLoad and core class must have a brief docstring explaining its responsibility.

## 4. Logging Standards
- Avoid polluting standard output. Use custom log wrappers if available, or categorize prints:
  - `print_debug("GameState: Transitioning to Game Over")` for state changes.
  - `push_warning()` for non-fatal edge cases.
  - `push_error()` for fatal failures.

## 5. Automated Testing
- Agents should implement tests for core logic (non-UI logic).
- Tests should be placed in a `tests/` or `game/tests/` directory and runnable via Godot headless / command line scripts or unit test runner.
- Every feature PR touching core logic must include automated tests verifying the changes.

## 6. Project Setup & Organization
- Keep `scenes/`, `scripts/`, `assets/`, and `autoloads/` neatly separated.
- Avoid large monolithic scripts. Prefer composition and signaling between nodes over hardcoded dependencies.
