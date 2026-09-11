# Contributing to LetterLogic

Thank you for your interest in contributing to **LetterLogic**! Whether you are fixing bugs, adding new features, improving documentation, or creating automated tests, we welcome your contributions.

Please review our [Code of Conduct](CODE_OF_CONDUCT.md) before participating in our community.

---

## 📚 Project Documentation & Standards

This repository follows structured engineering standards for issues, development, testing, and PR reviews. Please refer to the core documents in the [`documents/`](documents/) directory:

| Document | Purpose |
|---|---|
| [**Requirements Specification**](documents/requirements.md) | Authoritative specifications, gameplay constraints, rules, and requirement IDs (`REQ-*`). |
| [**Manual Testing Guide**](documents/manual_testing.md) | Human and QA testing scenarios for gameplay, input constraints, and daily lockout. |
| [**Creating Issues Standard**](documents/creating_issues.md) | Guidelines and standard structure for filing actionable GitHub issues. |
| [**Resolving Issues Workflow**](documents/resolving_issues.md) | Complete workflow for branch creation, worktree isolation, implementation, and PR creation. |
| [**PR Review & Merge Standards**](documents/reviewing_and_merging_prs.md) | Checklist for reviewers, documentation coordination requirements, and standard merge protocol. |

---

## 🛠️ Development Setup

1. **Prerequisites:**
   * [Godot Engine 4.x](https://godotengine.org/) (standard 64-bit console executable).
   * Git and [GitHub CLI (`gh`)](https://cli.github.com/).
2. **Clone & Open:**
   * Clone the repository:
     ```bash
     git clone https://github.com/OpenGameStack-Games/LetterLogic.git
     ```
   * Open Godot and import `game/project.godot`.
   * The project viewport is configured for mobile portrait (720×1280) with Dark Mode `#121212`.

---

## 🔄 Contribution Workflow

Contributors—both human developers and autonomous agents—follow these core practices:

### 1. Work in Worktrees
To keep the main repository clean and prevent workspace conflicts, all development occurs in an isolated Git worktree:
```powershell
git fetch origin
git worktree add .worktrees/issue-<number> -b feature/issue-<number>-<short-description>
```

### 2. Code Standards
* **Static Typing:** GDScript code strictly uses static typing for all variables, parameters, and return types.
* **Naming Conventions:**
  * Classes & Nodes: `PascalCase` (e.g., `GameBoard`, `KeyboardKey`)
  * Functions, Variables & Signals: `snake_case` (e.g., `current_guess`, `_on_tile_pressed()`)
  * Constants: `UPPER_SNAKE_CASE` (e.g., `MAX_ATTEMPTS = 6`, `COLOR_BG_ABSENT`)
* **Logging:** Avoid raw `print()` statements in production code. Use `print_debug()`, `push_warning()`, and `push_error()`.
* **Comments:** Explain the *why* and design assumptions, not the obvious *what*.

### 3. Automated Testing
Every feature or bug fix touching game logic, autoloads, or calculations must include unit tests in `game/tests/`:
* Test scripts inherit from `res://tests/test_base.gd`.
* Run the headless test suite locally:
  ```powershell
  godot --headless --path game -s res://tests/test_runner.gd
  ```
* All tests must pass (`Test Results: X Passed, 0 Failed`, exit code 0) before submitting changes.

### 4. Submitting Pull Requests
* Commit changes using [Conventional Commits](https://www.conventionalcommits.org/) (`feat:`, `fix:`, `docs:`, `test:`, `refactor:`).
* Push your branch to origin and open a Pull Request using `.github/pull_request_template.md`.
* Follow the detailed PR format including the **Handoff for PR Reviewer & Documentation Agent** checklist.
* **Merging Policy:** LetterLogic uses **standard merge commits** (`gh pr merge <pr> --merge --delete-branch`). **Do not squash or rebase** merge commits, as atomic commit history is preserved for review.

---

## ❓ Getting Help

If you have questions or need guidance:
* Open a [GitHub Discussion](https://github.com/OpenGameStack-Games/LetterLogic/discussions) or issue.
* Contact the maintainers at **contact@opengamestack.org**.
