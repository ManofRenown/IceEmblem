class_name Test
extends Node

## Base class for all unit tests
## Provides assertion methods and result tracking

# Test metadata
var test_name: String = "Unnamed Test"
var test_description: String = ""

# Test results
var assertions_passed: int = 0
var assertions_failed: int = 0
var failed_assertions: Array[String] = []
var test_log: Array[String] = []

# Test status
var is_running: bool = false
var is_complete: bool = false


## Override this method in subclasses to implement test logic
func run_test() -> void:
	push_error("run_test() not implemented in %s" % test_name)
	is_complete = true


## Start the test
func start_test() -> void:
	is_running = true
	is_complete = false
	assertions_passed = 0
	assertions_failed = 0
	failed_assertions.clear()
	test_log.clear()

	log_message("=== Starting Test: %s ===" % test_name)
	if test_description:
		log_message("Description: %s" % test_description)

	run_test()

	is_running = false
	is_complete = true

	log_message("=== Test Complete: %s ===" % test_name)
	log_message("Passed: %d | Failed: %d" % [assertions_passed, assertions_failed])


## Log a test message (renamed from log to avoid conflict with built-in math function)
func log_message(message: String) -> void:
	test_log.append(message)
	print("[%s] %s" % [test_name, message])


## Assert that a condition is true
func assert_true(condition: bool, message: String = "") -> bool:
	if condition:
		assertions_passed += 1
		var msg = ("✓ PASS: %s" % message) if message else "Assertion passed"
		log_message(msg)
		return true
	else:
		assertions_failed += 1
		var fail_msg = ("✗ FAIL: %s" % message) if message else "Assertion failed"
		failed_assertions.append(fail_msg)
		log_message(fail_msg)
		return false


## Assert that a condition is false
func assert_false(condition: bool, message: String = "") -> bool:
	var msg = message if message else "Expected false"
	return assert_true(not condition, msg)


## Assert that two values are equal
func assert_equal(actual, expected, message: String = "") -> bool:
	var is_equal = actual == expected
	var msg = message if message else ("Expected %s, got %s" % [expected, actual])
	return assert_true(is_equal, msg)


## Assert that two values are not equal
func assert_not_equal(actual, expected, message: String = "") -> bool:
	var is_not_equal = actual != expected
	var msg = message if message else ("Expected not %s, got %s" % [expected, actual])
	return assert_true(is_not_equal, msg)


## Assert that a value is null
func assert_null(value, message: String = "") -> bool:
	var msg = message if message else ("Expected null, got %s" % value)
	return assert_true(value == null, msg)


## Assert that a value is not null
func assert_not_null(value, message: String = "") -> bool:
	var msg = message if message else "Expected non-null, got null"
	return assert_true(value != null, msg)


## Assert that a value is greater than another
func assert_greater(actual, expected, message: String = "") -> bool:
	var msg = message if message else ("Expected %s > %s" % [actual, expected])
	return assert_true(actual > expected, msg)


## Assert that a value is less than another
func assert_less(actual, expected, message: String = "") -> bool:
	var msg = message if message else ("Expected %s < %s" % [actual, expected])
	return assert_true(actual < expected, msg)


## Assert that a value is greater than or equal to another
func assert_greater_or_equal(actual, expected, message: String = "") -> bool:
	var msg = message if message else ("Expected %s >= %s" % [actual, expected])
	return assert_true(actual >= expected, msg)


## Assert that a value is less than or equal to another
func assert_less_or_equal(actual, expected, message: String = "") -> bool:
	var msg = message if message else ("Expected %s <= %s" % [actual, expected])
	return assert_true(actual <= expected, msg)


## Assert that a value is within a range
func assert_in_range(value, min_val, max_val, message: String = "") -> bool:
	var msg = message if message else ("Expected %s in range [%s, %s]" % [value, min_val, max_val])
	return assert_true(value >= min_val and value <= max_val, msg)


## Get test results as a dictionary
func get_results() -> Dictionary:
	return {
		"name": test_name,
		"description": test_description,
		"passed": assertions_passed,
		"failed": assertions_failed,
		"total": assertions_passed + assertions_failed,
		"success": assertions_failed == 0,
		"failed_assertions": failed_assertions,
		"log": test_log
	}


## Get a summary string
func get_summary() -> String:
	var status = "✓ PASSED" if assertions_failed == 0 else "✗ FAILED"
	return "%s - %s (%d/%d assertions passed)" % [
		test_name,
		status,
		assertions_passed,
		assertions_passed + assertions_failed
	]
