# Adding New Tests to IceEmblem

This guide explains how to create new tests for the IceEmblem project and integrate them with the test runner.

## Quick Start

1. Create a new test script in `Test/` directory
2. Create a corresponding `.tscn` file
3. Add the scene path to `run_all.gd`
4. Run `Test/run_all.tscn` to execute all tests

## Step-by-Step Guide

### 1. Create a New Test Script

Create a new GDScript file in the `Test/` directory that extends the `Test` base class:

```gdscript
extends Test

## Brief description of what this test suite validates

var test_environment_var: YourType  # Any variables needed for testing


func _ready() -> void:
	test_name = "Your Test Name"
	test_description = "Brief description of what this test validates"


func run_test() -> void:
	# Setup
	_setup_test_environment()

	# Run individual test cases
	test_feature_one()
	test_feature_two()
	test_edge_case()

	# Cleanup
	_cleanup_test_environment()


func _setup_test_environment() -> void:
	log_message("Setting up test environment...")
	# Create any nodes, resources, or state needed for testing
	# Example:
	# var unit = Unit.new()
	# add_child(unit)


func _cleanup_test_environment() -> void:
	log_message("Cleaning up test environment...")
	# Free any created nodes
	# Example:
	# if unit:
	#     unit.queue_free()


func test_feature_one() -> void:
	log_message("\n--- Test: Feature One ---")

	# Arrange - set up test conditions
	var expected_value = 10

	# Act - perform the action being tested
	var actual_value = some_function()

	# Assert - verify the result
	assert_equal(actual_value, expected_value, "Feature one should return 10")
```

### 2. Available Assertion Methods

The `Test` base class provides these assertion methods:

- `assert_true(condition, message)` - Assert condition is true
- `assert_false(condition, message)` - Assert condition is false
- `assert_equal(actual, expected, message)` - Assert two values are equal
- `assert_not_equal(actual, expected, message)` - Assert two values are not equal
- `assert_null(value, message)` - Assert value is null
- `assert_not_null(value, message)` - Assert value is not null
- `assert_greater(actual, expected, message)` - Assert actual > expected
- `assert_less(actual, expected, message)` - Assert actual < expected
- `assert_greater_or_equal(actual, expected, message)` - Assert actual >= expected
- `assert_less_or_equal(actual, expected, message)` - Assert actual <= expected
- `assert_in_range(value, min, max, message)` - Assert value is within range

All methods return `bool` (true if passed, false if failed) and automatically track results.

### 3. Create a Scene File

Create a `.tscn` file for your test in the `Test/` directory:

```
[gd_scene load_steps=2 format=4 uid="uid://UNIQUE_UID_HERE"]

[ext_resource type="Script" path="res://Test/your_test_name.gd" id="1_test"]

[node name="YourTestName" type="Node"]
script = ExtResource("1_test")
```

**Important**: Each scene needs a unique UID. You can generate one in Godot or use a placeholder.

### 4. Register the Test in RunAll

Open `Test/run_all.gd` and add your test scene path to the `test_scenes` array:

```gdscript
var test_scenes: Array[String] = [
	"res://Test/test_unit_movement.tscn",
	"res://Test/test_unit_combat.tscn",
	"res://Test/test_terrain_effects.tscn",
	"res://Test/test_unit_types.tscn",
	"res://Test/your_test_name.tscn"  # Add your test here
]
```

**That's it!** Your test will now run when you execute `Test/run_all.tscn`.

## Testing Best Practices

### 1. Test Organization

- Group related tests in the same test suite
- Use descriptive test function names: `test_unit_can_move()` not `test1()`
- One concept per test function

### 2. Test Independence

Each test should be independent:
- Create fresh test data in `_setup_test_environment()`
- Clean up in `_cleanup_test_environment()`
- Don't rely on test execution order
- Don't share state between tests

### 3. Async Testing

If your test needs to wait for frames or timers:

```gdscript
func test_async_feature() -> void:
	log_message("\n--- Test: Async Feature ---")

	var unit = Unit.new()
	add_child(unit)

	# Wait for _ready to be called
	await get_tree().process_frame

	# Now test the unit
	assert_not_null(unit.current_health, "Health should be initialized")

	unit.queue_free()
```

### 4. Logging

Use `log_message(message)` to output information during test execution:

```gdscript
log_message("Setting up player unit...")
log_message("Moving unit from tile (0,0) to tile (5,5)...")
log_message("Note: This test requires TileMapManager to be present")
```

Logs appear in:
- Console output during test run
- Test reports in `Test/TestOutputs/`

### 5. Test Naming Conventions

- **Test Scripts**: `test_feature_name.gd` (lowercase with underscores)
- **Test Scenes**: `test_feature_name.tscn`
- **Test Functions**: `test_specific_behavior()` (descriptive and specific)

## Example: Complete Test Suite

```gdscript
extends Test

## Tests for the inventory system

var inventory: Inventory
var item1: Item
var item2: Item


func _ready() -> void:
	test_name = "Inventory System Tests"
	test_description = "Tests item management, stacking, and capacity"


func run_test() -> void:
	_setup_test_environment()

	test_add_item()
	test_remove_item()
	test_inventory_capacity()
	test_item_stacking()

	_cleanup_test_environment()


func _setup_test_environment() -> void:
	log_message("Setting up test environment...")

	inventory = Inventory.new()
	inventory.max_capacity = 10
	add_child(inventory)

	item1 = Item.new()
	item1.item_name = "Potion"
	item1.is_stackable = true

	item2 = Item.new()
	item2.item_name = "Sword"
	item2.is_stackable = false


func _cleanup_test_environment() -> void:
	log_message("Cleaning up test environment...")
	if inventory:
		inventory.queue_free()
	if item1:
		item1.queue_free()
	if item2:
		item2.queue_free()


func test_add_item() -> void:
	log_message("\n--- Test: Add Item ---")

	var success = inventory.add_item(item1)

	assert_true(success, "Should be able to add item to empty inventory")
	assert_equal(inventory.get_item_count(), 1, "Inventory should contain 1 item")


func test_remove_item() -> void:
	log_message("\n--- Test: Remove Item ---")

	inventory.add_item(item1)
	var success = inventory.remove_item(item1)

	assert_true(success, "Should be able to remove existing item")
	assert_equal(inventory.get_item_count(), 0, "Inventory should be empty")


func test_inventory_capacity() -> void:
	log_message("\n--- Test: Inventory Capacity ---")

	# Fill inventory to capacity
	for i in range(10):
		inventory.add_item(Item.new())

	var overflow_success = inventory.add_item(Item.new())

	assert_false(overflow_success, "Should not be able to exceed max capacity")
	assert_equal(inventory.get_item_count(), 10, "Inventory should be at max capacity")


func test_item_stacking() -> void:
	log_message("\n--- Test: Item Stacking ---")

	inventory.add_item(item1)
	inventory.add_item(item1)  # Same stackable item

	assert_equal(inventory.get_item_count(), 1, "Stackable items should combine")
	assert_equal(inventory.get_item_stack_size(item1), 2, "Stack size should be 2")
```

## Running Tests

### Run All Tests
```bash
# In Godot editor
Open Test/run_all.tscn
Press F6 or click "Run Current Scene"
```

### Run Individual Test
```bash
# In Godot editor
Open Test/test_your_feature.tscn
Press F6 or click "Run Current Scene"
```

### View Results
- **Console**: Real-time output during test execution
- **Files**: `Test/TestOutputs/test_report_[TIMESTAMP].txt`

## Troubleshooting

### Test Not Running

**Problem**: Your test doesn't appear in the RunAll output.

**Solution**:
1. Verify the scene path in `run_all.gd` is correct
2. Check that the test script extends `Test`
3. Ensure the scene file references the correct script

### Assertions Not Counted

**Problem**: Test runs but shows 0 assertions.

**Solution**:
1. Make sure you're calling assertion methods (assert_true, assert_equal, etc.)
2. Verify `run_test()` is implemented
3. Check that you're not overriding `start_test()` without calling `super.start_test()`

### Tests Failing Unexpectedly

**Problem**: Tests pass individually but fail in RunAll.

**Solution**:
1. Ensure proper cleanup in `_cleanup_test_environment()`
2. Check for shared state between tests
3. Verify TileMapManager.instance is being set up correctly
4. Add `await get_tree().process_frame` for node initialization

## File Structure

```
IceEmblem/
├── Test/
│   ├── TestOutputs/              # Generated test reports
│   │   ├── .gitkeep
│   │   └── test_report_*.txt
│   ├── CLAUDE.md                 # This file
│   ├── run_all.gd                # Test runner script
│   ├── run_all.tscn              # Test runner scene
│   ├── test_unit_movement.gd     # Example test script
│   ├── test_unit_movement.tscn   # Example test scene
│   └── test_your_feature.gd      # Your new test
│   └── test_your_feature.tscn    # Your new test scene
└── Scripts/
    └── test.gd                    # Base Test class
```

## Summary Checklist

When adding a new test:

- [ ] Create `test_feature_name.gd` extending `Test`
- [ ] Set `test_name` and `test_description` in `_ready()`
- [ ] Implement `run_test()` with test cases
- [ ] Implement `_setup_test_environment()` and `_cleanup_test_environment()`
- [ ] Create `test_feature_name.tscn` with script attached
- [ ] Add scene path to `test_scenes` array in `run_all.gd`
- [ ] Run `run_all.tscn` to verify integration
- [ ] Check `TestOutputs/` for generated report

Happy testing! 🎮
