extends Test

## Tests for terrain system
## Tests terrain types, movement costs, and defense bonuses

var tilemap_manager: TileMapManager


func _ready() -> void:
	test_name = "Terrain Effects Tests"
	test_description = "Tests terrain types, modifiers, and effects on units"


func run_test() -> void:
	# Create test dependencies
	_setup_test_environment()

	# Run test cases
	test_terrain_type_creation()
	test_terrain_definitions()
	test_terrain_passability()
	test_terrain_movement_costs()
	test_terrain_defense_bonuses()
	test_unit_terrain_integration()

	# Cleanup
	_cleanup_test_environment()


func _setup_test_environment() -> void:
	log("Setting up test environment...")

	# Create TileMapManager
	tilemap_manager = TileMapManager.new()
	add_child(tilemap_manager)
	TileMapManager.instance = tilemap_manager


func _cleanup_test_environment() -> void:
	log("Cleaning up test environment...")
	if tilemap_manager:
		tilemap_manager.queue_free()


func test_terrain_type_creation() -> void:
	log("\n--- Test: Terrain Type Creation ---")

	var terrain = TerrainType.new("Test Terrain", 2, 3, 10, true)

	assert_equal(terrain.terrain_name, "Test Terrain", "Terrain name should be set")
	assert_equal(terrain.movement_cost, 2, "Movement cost should be 2")
	assert_equal(terrain.defense_bonus, 3, "Defense bonus should be 3")
	assert_equal(terrain.avoid_bonus, 10, "Avoid bonus should be 10")
	assert_true(terrain.is_passable, "Terrain should be passable")


func test_terrain_definitions() -> void:
	log("\n--- Test: Terrain Definitions ---")

	# Test that all expected terrain types are defined
	var terrain_types = tilemap_manager.terrain_types

	# MUD (0,0)
	assert_true(terrain_types.has(Vector2i(0, 0)), "Mud terrain should be defined")
	var mud = terrain_types[Vector2i(0, 0)]
	assert_equal(mud.terrain_name, "Mud", "Mud terrain name")
	assert_equal(mud.movement_cost, 2, "Mud should cost 2 movement")
	assert_equal(mud.defense_bonus, 0, "Mud should have no defense bonus")
	assert_true(mud.is_passable, "Mud should be passable")

	# PATH (1,0)
	assert_true(terrain_types.has(Vector2i(1, 0)), "Path terrain should be defined")
	var path = terrain_types[Vector2i(1, 0)]
	assert_equal(path.terrain_name, "Path", "Path terrain name")
	assert_equal(path.movement_cost, 1, "Path should cost 1 movement")

	# STONE (2,0)
	assert_true(terrain_types.has(Vector2i(2, 0)), "Stone terrain should be defined")
	var stone = terrain_types[Vector2i(2, 0)]
	assert_equal(stone.terrain_name, "Stone", "Stone terrain name")
	assert_equal(stone.defense_bonus, 2, "Stone should provide +2 defense")

	# GRASS (3,0)
	assert_true(terrain_types.has(Vector2i(3, 0)), "Grass terrain should be defined")
	var grass = terrain_types[Vector2i(3, 0)]
	assert_equal(grass.terrain_name, "Grass", "Grass terrain name")
	assert_equal(grass.defense_bonus, 1, "Grass should provide +1 defense")

	# DEEP WATER (4,0)
	assert_true(terrain_types.has(Vector2i(4, 0)), "Deep water terrain should be defined")
	var deep_water = terrain_types[Vector2i(4, 0)]
	assert_equal(deep_water.terrain_name, "Deep Water", "Deep water terrain name")
	assert_false(deep_water.is_passable, "Deep water should be impassable")

	# SHALLOW WATER (5,0)
	assert_true(terrain_types.has(Vector2i(5, 0)), "Shallow water terrain should be defined")
	var shallow_water = terrain_types[Vector2i(5, 0)]
	assert_equal(shallow_water.terrain_name, "Shallow Water", "Shallow water terrain name")
	assert_equal(shallow_water.movement_cost, 2, "Shallow water should cost 2 movement")


func test_terrain_passability() -> void:
	log("\n--- Test: Terrain Passability ---")

	# Test passable terrains
	var terrain_types = tilemap_manager.terrain_types

	var mud = terrain_types[Vector2i(0, 0)]
	assert_true(mud.is_passable, "Mud should be passable")

	var stone = terrain_types[Vector2i(2, 0)]
	assert_true(stone.is_passable, "Stone should be passable")

	# Test impassable terrain
	var deep_water = terrain_types[Vector2i(4, 0)]
	assert_false(deep_water.is_passable, "Deep water should be impassable")


func test_terrain_movement_costs() -> void:
	log("\n--- Test: Terrain Movement Costs ---")

	var terrain_types = tilemap_manager.terrain_types

	# Normal movement cost
	var path = terrain_types[Vector2i(1, 0)]
	assert_equal(path.movement_cost, 1, "Path should have standard movement cost")

	var stone = terrain_types[Vector2i(2, 0)]
	assert_equal(stone.movement_cost, 1, "Stone should have standard movement cost")

	# Slow movement cost
	var mud = terrain_types[Vector2i(0, 0)]
	assert_equal(mud.movement_cost, 2, "Mud should have double movement cost")

	var shallow_water = terrain_types[Vector2i(5, 0)]
	assert_equal(shallow_water.movement_cost, 2, "Shallow water should have double movement cost")

	# Impassable (high cost)
	var deep_water = terrain_types[Vector2i(4, 0)]
	assert_greater(deep_water.movement_cost, 100, "Deep water should have prohibitive movement cost")


func test_terrain_defense_bonuses() -> void:
	log("\n--- Test: Terrain Defense Bonuses ---")

	var terrain_types = tilemap_manager.terrain_types

	# No defense bonus
	var mud = terrain_types[Vector2i(0, 0)]
	assert_equal(mud.defense_bonus, 0, "Mud should provide no defense bonus")

	var path = terrain_types[Vector2i(1, 0)]
	assert_equal(path.defense_bonus, 0, "Path should provide no defense bonus")

	# Light defense bonus
	var grass = terrain_types[Vector2i(3, 0)]
	assert_equal(grass.defense_bonus, 1, "Grass should provide +1 defense bonus")

	# Strong defense bonus
	var stone = terrain_types[Vector2i(2, 0)]
	assert_equal(stone.defense_bonus, 2, "Stone should provide +2 defense bonus")


func test_unit_terrain_integration() -> void:
	log("\n--- Test: Unit-Terrain Integration ---")

	# Create a test unit
	var unit = Unit.new()
	unit.defense = 5
	unit.tile_size = Vector2i(64, 64)
	add_child(unit)

	# Test that unit can query terrain bonuses
	unit.current_terrain_defense_bonus = 0
	var base_defense = unit.get_effective_defense()
	assert_equal(base_defense, 5, "Base defense without terrain bonus")

	# Simulate unit on defensive terrain
	unit.current_terrain_defense_bonus = 2
	var boosted_defense = unit.get_effective_defense()
	assert_equal(boosted_defense, 7, "Defense should include terrain bonus: 5 + 2 = 7")

	# Test stats dictionary includes terrain info
	var stats = unit.get_stats()
	assert_true(stats.has("terrain_defense_bonus"), "Stats should include terrain_defense_bonus")
	assert_true(stats.has("effective_defense"), "Stats should include effective_defense")

	unit.queue_free()
