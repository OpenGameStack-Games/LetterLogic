# OpenGameStack Agent Workflows & Standards

This document defines the rules of engagement, Git workflows, and coding standards for autonomous agents working on OpenGameStack game repositories.

## 1. Git Workflow
- **Branching Strategy:** Agents must never push directly to the `main` branch. 
- **Feature Branches:** All work must be done on a branch named `feature/issue-<number>-<short-description>`.
- **Commits:** Use Conventional Commits formatting (e.g., `feat: implement dynamic keyboard`, `fix: correct UTC date calculation`, `docs: update readme`). Keep commits atomic.
- **Pull Requests:** When an issue is complete, push the branch and open a Pull Request (PR) against `main`. Ensure the PR description links to the issue (e.g., `Resolves #4`).

## 2. Issue Processing Workflow
When an agent is assigned an issue, it must follow this sequence:
1. **Dependency Check:** Read the issue description carefully. If the issue states **"Depends on #X"**, verify that issue #X is completely closed and merged. Do not start work if dependencies are open.
2. **Understand & Plan:** Read the issue description and Acceptance Criteria. If anything is ambiguous, pause and ask the user for clarification before writing code.
3. **Branch Creation:** Checkout a new feature branch from the latest `main`.
4. **Implementation:** Write the code to satisfy the issue.
5. **Verification:** Run automated tests (or write them if they don't exist). Ensure the code compiles and runs without warnings.
6. **Commit & Push:** Commit changes using conventional commits, push to origin, and create the PR.

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
- Tests should be placed in a `tests/` directory and runnable via Godot's command line or a framework like GUT (Godot Unit Test).

## 6. Project Setup & Organization
- Keep `scenes/`, `scripts/`, `assets/`, and `autoloads/` neatly separated.
- Avoid large monolithic scripts. Prefer composition and signaling between nodes over hardcoded dependencies.
