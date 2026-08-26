# tests/test_base.gd
class_name TestBase
extends RefCounted

## Base class for automated unit tests in LetterLogic.

var failed_count: int = 0
var passed_count: int = 0
var current_test_name: String = ""

func cleanup() -> void:
	pass

func assert_true(condition: bool, message: String = "") -> void:
	if condition:
		passed_count += 1
	else:
		failed_count += 1
		var err: String = "  [FAIL] %s: Expected true, got false" % [current_test_name]
		if message != "":
			err += " - " + message
		print_debug(err)

func assert_false(condition: bool, message: String = "") -> void:
	assert_true(!condition, message)

func assert_eq(actual: Variant, expected: Variant, message: String = "") -> void:
	if actual == expected:
		passed_count += 1
	else:
		failed_count += 1
		var err: String = "  [FAIL] %s: Expected '%s', but got '%s'" % [current_test_name, str(expected), str(actual)]
		if message != "":
			err += " - " + message
		print_debug(err)

func assert_ne(actual: Variant, expected: Variant, message: String = "") -> void:
	if actual != expected:
		passed_count += 1
	else:
		failed_count += 1
		var err: String = "  [FAIL] %s: Expected value not to equal '%s'" % [current_test_name, str(expected)]
		if message != "":
			err += " - " + message
		print_debug(err)
