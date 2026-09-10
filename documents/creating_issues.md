# GitHub Issue Creation Standard & Guidelines

This document outlines the standard specifications, structure, and workflow for creating GitHub issues for the **LetterLogic** project. Adhering to these standards ensures that any contributor—human developer or autonomous agent—can pick up an issue, understand the context and requirements without ambiguity, implement the change, and properly verify their work.

---

## 1. Principles & Quality Bar

Every issue created in this repository must meet the following criteria:
1. **Self-Contained & Actionable:** Provide all necessary context, architectural decisions, and acceptance criteria. A contributor should never have to guess design intent or look for unlinked resources.
2. **Clear Boundaries:** Group requirements logically by affected components (e.g., UI, Core Logic, AutoLoads, Tests, Documentation).
3. **Traceability:** Explicitly list any dependencies and note which documentation files need to be synchronized as part of the implementation.
4. **No Duplicates:** Always search open and closed issues (`gh issue list --state all`) before submitting a new issue.

---

## 2. Standard Issue Structure

All issues should follow this markdown layout:

```markdown
**Depends on #<issue_number>** (Include only if this issue has blockers)

### 1. Problem & Context
A concise explanation of the problem, bug, or feature request.
- For bugs: Reproduction steps, observed behavior, and expected behavior.
- For features/enhancements: User story, design motivation, and why the change improves the game.

### 2. Technical Scope & Affected Files
Direct references to the files, scenes, or scripts that need modification or inspection:
- `game/scripts/<script_name>.gd`
- `game/scenes/<scene_name>.tscn`
- `game/autoloads/<autoload_name>.gd`
- `game/tests/<test_name>.gd`

### 3. Acceptance Criteria
Checklist grouped by component or responsibility:

#### [Component / Feature Area 1]
- [ ] Explicit requirement 1
- [ ] Explicit requirement 2

#### [Component / Feature Area 2]
- [ ] Explicit requirement 3

#### Automated Tests (`game/tests/`)
- [ ] Add or update unit test cases verifying the new behavior.
- [ ] Ensure all existing automated test suites pass without regressions.

#### Documentation Coordination (Mandatory)
- [ ] Update `documents/requirements.md` to reflect any new or modified specifications.
- [ ] Update `documents/manual_testing.md` with new/updated manual verification test cases.
- [ ] Update `README.md` if user-facing behavior, controls, or visuals are altered.
```

---

## 3. Title & Labeling Conventions

### Title Format
Titles must be concise and use standard prefixes to indicate the area of the codebase:
- `UI - <Action/Description>` (e.g., `UI - Update Absent Letter Color to Flat Red`)
- `Core - <Action/Description>` (e.g., `Core - Validate Daily Seed Calculation`)
- `Stats - <Action/Description>` (e.g., `Stats - Fix Streak Reset on Loss`)
- `Docs - <Action/Description>` (e.g., `Docs - Update Architecture Diagram`)

Conventional commits format (`feat:`, `fix:`, `refactor:`, `docs:`) is also acceptable.

### Labels
Apply at least one standard GitHub label when creating the issue:
- `enhancement`: New features, visual improvements, or gameplay enhancements.
- `bug`: Defects, incorrect logic, UI glitches, or broken mechanics.
- `documentation`: Purely documentation-focused tasks.
- `good first issue`: Self-contained, straightforward tasks suitable for beginners.

---

## 4. Pre-Creation Checklist (For Authors & Agents)

Before publishing an issue via GitHub:
1. [ ] **Search Existing Issues:** Run `gh issue list --state all` to confirm the issue doesn't already exist or duplicate past work.
2. [ ] **Inspect Codebase:** Verify the exact file paths, variable names, and current behavior in the code.
3. [ ] **Clarify Design Choices:** Resolve any open design questions (e.g., color hex codes, UI behaviors, platform fallbacks) before publishing so the issue body contains firm decisions rather than open questions.
4. [ ] **Include Documentation Acceptance Criteria:** Ensure the mandatory documentation coordination checklist is included per `.agents/rules/workflows.md`.

---

## 5. Creating Issues via GitHub CLI

To create an issue from the command line using the GitHub CLI (`gh`), format the body into a variable or markdown string:

```powershell
$body = @"
Short description of the bug or feature and its context.

## Acceptance Criteria

### 1. [Component Name]
- [ ] Action item 1
- [ ] Action item 2

### 2. Automated Tests
- [ ] Verify test suite passes with updates.

### 3. Documentation Coordination (per .agents/rules/workflows.md)
- [ ] Update documents/requirements.md.
- [ ] Update documents/manual_testing.md.
- [ ] Update README.md if applicable.
"@

gh issue create --title "<Prefix> - <Short Summary>" --body "$body" --label "<label_name>"
```

---

## 6. Reference Example

See [Issue #21: UI - Update Absent Letter Color to Flat Red Across Tiles, Keyboard, and Share Grid](https://github.com/OpenGameStack-Games/LetterLogic/issues/21) for a live example of an issue meeting this standard.
