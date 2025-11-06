extends Node

## Test runner that executes all test scenes and generates reports
## Run this scene to execute the full test suite

# List of test scene paths
var test_scenes: Array[String] = [
	"res://Test/test_unit_movement.tscn",
	"res://Test/test_unit_combat.tscn",
	"res://Test/test_terrain_effects.tscn",
	"res://Test/test_unit_types.tscn"
]

# Test results
var all_results: Array[Dictionary] = []
var total_passed: int = 0
var total_failed: int = 0
var tests_completed: int = 0


func _ready() -> void:
	print("\n" + "=".repeat(80))
	print("RUNNING TEST SUITE")
	print("=".repeat(80) + "\n")

	await get_tree().process_frame
	run_all_tests()


func run_all_tests() -> void:
	for test_path in test_scenes:
		await run_test_scene(test_path)

	generate_final_report()


func run_test_scene(scene_path: String) -> void:
	print("\n" + "-".repeat(80))
	print("Loading test: %s" % scene_path)
	print("-".repeat(80))

	# Load the test scene
	var test_scene = load(scene_path)
	if not test_scene:
		printerr("Failed to load test scene: %s" % scene_path)
		return

	# Instance the test
	var test_instance = test_scene.instantiate()
	if not test_instance is Test:
		printerr("Scene is not a Test: %s" % scene_path)
		test_instance.queue_free()
		return

	# Add to scene tree
	add_child(test_instance)

	# Wait a frame for _ready to complete
	await get_tree().process_frame

	# Run the test
	test_instance.start_test()

	# Wait for test to complete (some tests may use await)
	await get_tree().process_frame

	# Collect results
	var results = test_instance.get_results()
	all_results.append(results)

	total_passed += results["passed"]
	total_failed += results["failed"]
	tests_completed += 1

	# Print summary
	print("\n" + test_instance.get_summary())

	# Clean up
	test_instance.queue_free()

	# Wait a frame before next test
	await get_tree().process_frame


func generate_final_report() -> void:
	print("\n" + "=".repeat(80))
	print("TEST SUITE COMPLETE")
	print("=".repeat(80))

	# Print quick failure summary to console if there are failures
	if total_failed > 0:
		print("\n" + "=".repeat(80))
		print("QUICK FAILURE SUMMARY")
		print("=".repeat(80))
		var failed_test_names = []
		for result in all_results:
			if not result["success"]:
				failed_test_names.append(result["name"])
		print("Failed %d of %d tests: %s" % [failed_test_names.size(), tests_completed, ", ".join(failed_test_names)])
		print("Total assertions failed: %d" % total_failed)
		print("See detailed report below and in TestOutputs/")
		print("=".repeat(80))

	var report_lines: Array[String] = []

	# Header
	report_lines.append("=".repeat(80))
	report_lines.append("TEST SUITE RESULTS")
	report_lines.append("=".repeat(80))
	report_lines.append("")
	report_lines.append("Timestamp: %s" % Time.get_datetime_string_from_system())
	report_lines.append("Tests Run: %d" % tests_completed)
	report_lines.append("Total Assertions: %d" % (total_passed + total_failed))
	report_lines.append("Assertions Passed: %d" % total_passed)
	report_lines.append("Assertions Failed: %d" % total_failed)

	var success_rate = 0.0
	if (total_passed + total_failed) > 0:
		success_rate = (float(total_passed) / float(total_passed + total_failed)) * 100.0

	report_lines.append("Success Rate: %.2f%%" % success_rate)
	report_lines.append("")

	# Overall status
	if total_failed == 0:
		report_lines.append("✓ ALL TESTS PASSED")
	else:
		report_lines.append("✗ SOME TESTS FAILED")

	# Failure summary (if any failures)
	if total_failed > 0:
		report_lines.append("")
		report_lines.append("=".repeat(80))
		report_lines.append("FAILURE SUMMARY")
		report_lines.append("=".repeat(80))
		report_lines.append("")

		var failed_tests = []
		for result in all_results:
			if not result["success"]:
				failed_tests.append(result)

		report_lines.append("Failed Tests: %d of %d" % [failed_tests.size(), tests_completed])
		report_lines.append("")

		for result in failed_tests:
			report_lines.append("-".repeat(80))
			report_lines.append("✗ FAILED: %s" % result["name"])
			report_lines.append("-".repeat(80))
			if result["description"]:
				report_lines.append("Description: %s" % result["description"])
			report_lines.append("Assertions Failed: %d of %d" % [result["failed"], result["total"]])
			report_lines.append("")
			report_lines.append("Failed Assertions:")
			for failed in result["failed_assertions"]:
				report_lines.append("  %s" % failed)
			report_lines.append("")

	report_lines.append("")
	report_lines.append("-".repeat(80))
	report_lines.append("INDIVIDUAL TEST RESULTS")
	report_lines.append("-".repeat(80))

	# Individual test results
	for result in all_results:
		report_lines.append("")
		report_lines.append("Test: %s" % result["name"])
		if result["description"]:
			report_lines.append("  Description: %s" % result["description"])
		report_lines.append("  Assertions Passed: %d" % result["passed"])
		report_lines.append("  Assertions Failed: %d" % result["failed"])
		report_lines.append("  Status: %s" % ("✓ PASSED" if result["success"] else "✗ FAILED"))

		# Show failed assertions
		if result["failed"] > 0:
			report_lines.append("  Failed Assertions:")
			for failed in result["failed_assertions"]:
				report_lines.append("    - %s" % failed)

	report_lines.append("")
	report_lines.append("=".repeat(80))
	report_lines.append("DETAILED LOGS")
	report_lines.append("=".repeat(80))

	# Detailed logs for each test
	for result in all_results:
		report_lines.append("")
		report_lines.append("[%s]" % result["name"])
		report_lines.append("-".repeat(80))
		for log_line in result["log"]:
			report_lines.append(log_line)

	report_lines.append("")
	report_lines.append("=".repeat(80))
	report_lines.append("END OF REPORT")
	report_lines.append("=".repeat(80))

	# Print to console
	for line in report_lines:
		print(line)

	# Save to file
	save_report_to_file(report_lines)

	# Exit after a short delay
	await get_tree().create_timer(1.0).timeout
	get_tree().quit()


func save_report_to_file(report_lines: Array[String]) -> void:
	var timestamp = Time.get_datetime_string_from_system().replace(":", "-").replace(" ", "_")
	var filename = "res://Test/TestOutputs/test_report_%s.txt" % timestamp

	var file = FileAccess.open(filename, FileAccess.WRITE)
	if not file:
		printerr("Failed to open file for writing: %s" % filename)
		return

	for line in report_lines:
		file.store_line(line)

	file.close()

	print("\nReport saved to: %s" % filename)
