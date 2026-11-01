#!/usr/bin/env python3
"""Unit tests validating GitHub Actions workflow files for common parser pitfalls."""

from __future__ import annotations

import json
import re
import unittest
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parent.parent
WORKFLOWS_DIR = REPO_ROOT / ".github" / "workflows"


class WorkflowValidationTests(unittest.TestCase):
    def test_workflows_exist_and_have_no_utf8_bom(self) -> None:
        workflows = sorted(WORKFLOWS_DIR.glob("*.yml"))
        self.assertGreaterEqual(len(workflows), 3, "Expected at least 3 workflow files in .github/workflows/")
        for wf in workflows:
            raw = wf.read_bytes()
            self.assertFalse(
                raw.startswith(b"\xef\xbb\xbf"),
                f"{wf.name} must not contain a UTF-8 BOM",
            )

    def test_workflows_do_not_reference_secrets_context_in_if_conditionals(self) -> None:
        # GitHub Actions rejects workflows that reference `secrets.*` directly in `if:` expressions.
        if_secrets_pattern = re.compile(r"^\s*if\s*:.*\bsecrets\.", re.MULTILINE)
        for wf in sorted(WORKFLOWS_DIR.glob("*.yml")):
            text = wf.read_text(encoding="utf-8")
            match = if_secrets_pattern.search(text)
            self.assertIsNone(
                match,
                f"{wf.name} references `secrets.` inside an `if:` expression "
                "(bind to `env:` first and check `env.<VAR> != ''`).",
            )

    def test_ogs_stack_manifest(self) -> None:
        manifest_path = REPO_ROOT / "ogs_stack.json"
        legacy_path = REPO_ROOT / "stack.json"

        self.assertTrue(manifest_path.is_file(), "ogs_stack.json must exist at repository root")
        self.assertFalse(legacy_path.exists(), "Legacy stack.json must not exist at repository root")

        raw_bytes = manifest_path.read_bytes()
        self.assertFalse(
            raw_bytes.startswith(b"\xef\xbb\xbf"),
            "ogs_stack.json must not contain a UTF-8 BOM",
        )

        manifest_data = json.loads(raw_bytes.decode("utf-8"))
        self.assertIsInstance(manifest_data, dict, "ogs_stack.json must parse as a JSON object")
        self.assertEqual(manifest_data.get("stack_name"), "LetterLogic", "stack_name must equal 'LetterLogic'")


if __name__ == "__main__":
    unittest.main()
