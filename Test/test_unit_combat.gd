extends Test

## Tests for unit combat mechanics
## Tests attacking, damage calculation, and death

var attacker: Unit
var defender: Unit
var tilemap_manager: TileMapManager


func _ready() -> void:
	test_name = "Unit Combat Tests"
	test_description = "Tests combat system including damage, defense, and death"


func run_test() -> void:
	# Create test dependencies
	_setup_test_environment()

	# Run test cases
	test_basic_attack()
	test_damage_calculation()
	test_defense_reduces_damage()
	test_minimum_damage()
	test_attack_range()
	test_unit_death()
	test_attack_dead_unit()
	test_terrain_defense_bonus()

	# Cleanup
	_cleanup_test_environment()


func _setup_test_environment() -> void:
	log_message("Setting up test environment...")

	# Create TileMapManager
	tilemap_manager = TileMapManager.new()
	add_child(tilemap_manager)
	TileMapManager.instance = tilemap_manager

	# Create attacker unit
	attacker = Unit.new()
	attacker.max_health = 20
	attacker.current_health = 20
	attacker.attack_damage = 10
	attacker.defense = 2
	attacker.attack_range = 1
	attacker.tile_size = Vector2i(64, 64)
	add_child(attacker)
	attacker.global_position = Vector2(32, 32)  # Tile 0,0

	# Create defender unit
	defender = Unit.new()
	defender.max_health = 20
	defender.current_health = 20
	defender.attack_damage = 5
	defender.defense = 3
	defender.attack_range = 1
	defender.tile_size = Vector2i(64, 64)
	add_child(defender)
	defender.global_position = Vector2(96, 32)  # Tile 1,0 (adjacent)


func _cleanup_test_environment() -> void:
	log_message("Cleaning up test environment...")
	if attacker:
		attacker.queue_free()
	if defender:
		defender.queue_free()
	if tilemap_manager:
		tilemap_manager.queue_free()


func test_basic_attack() -> void:
	log_message("\n--- Test: Basic Attack ---")

	var initial_health = defender.current_health
	assert_equal(attacker.has_attacked_this_turn, false, "Attacker should not have attacked yet")

	var damage = attacker.attack(defender)

	assert_greater(damage, 0, "Attack should deal damage")
	assert_less(defender.current_health, initial_health, "Defender health should decrease")
	assert_true(attacker.has_attacked_this_turn, "Attacker should be marked as having attacked")


func test_damage_calculation() -> void:
	log_message("\n--- Test: Damage Calculation ---")

	# Reset units
	attacker.reset_turn()
	defender.current_health = defender.max_health

	var expected_damage = max(1, attacker.attack_damage - defender.get_effective_defense())
	var actual_damage = attacker.attack(defender)

	assert_equal(actual_damage, expected_damage,
		"Damage should be attack - defense (min 1): Expected %d, got %d" % [expected_damage, actual_damage])


func test_defense_reduces_damage() -> void:
	log_message("\n--- Test: Defense Reduces Damage ---")

	# Create a high defense unit
	var tank = Unit.new()
	tank.max_health = 30
	tank.current_health = 30
	tank.defense = 8
	tank.tile_size = Vector2i(64, 64)
	add_child(tank)
	tank.global_position = Vector2(32, 96)  # Tile 0,1

	# Move attacker adjacent to tank
	attacker.reset_turn()
	attacker.snap_to_tile(Vector2i(0, 0))
	tank.snap_to_tile(Vector2i(0, 1))

	var damage = attacker.attack(tank)

	# attacker.attack_damage = 10, tank.defense = 8, so damage = 2
	var expected = max(1, attacker.attack_damage - tank.get_effective_defense())
	assert_equal(damage, expected, "High defense should reduce damage significantly")

	tank.queue_free()


func test_minimum_damage() -> void:
	log_message("\n--- Test: Minimum Damage ---")

	# Create a unit with defense higher than attack
	var fortress = Unit.new()
	fortress.max_health = 50
	fortress.current_health = 50
	fortress.defense = 20  # Higher than attacker's 10 attack
	fortress.tile_size = Vector2i(64, 64)
	add_child(fortress)
	fortress.global_position = Vector2(32, 96)

	attacker.reset_turn()
	attacker.snap_to_tile(Vector2i(0, 0))
	fortress.snap_to_tile(Vector2i(0, 1))

	var damage = attacker.attack(fortress)

	assert_equal(damage, 1, "Damage should always be at least 1, even with high defense")

	fortress.queue_free()


func test_attack_range() -> void:
	log_message("\n--- Test: Attack Range ---")

	# Reset units
	attacker.reset_turn()

	# Place defender far away
	defender.snap_to_tile(Vector2i(10, 10))

	var damage = attacker.attack(defender)

	assert_equal(damage, 0, "Attack should fail when target is out of range")


func test_unit_death() -> void:
	log_message("\n--- Test: Unit Death ---")

	# Create a weak unit
	var weak_unit = Unit.new()
	weak_unit.max_health = 5
	weak_unit.current_health = 5
	weak_unit.defense = 0
	weak_unit.tile_size = Vector2i(64, 64)
	add_child(weak_unit)
	weak_unit.global_position = Vector2(32, 96)

	attacker.reset_turn()
	attacker.snap_to_tile(Vector2i(0, 0))
	weak_unit.snap_to_tile(Vector2i(0, 1))

	assert_true(weak_unit.is_alive, "Unit should start alive")

	# Attack should kill the unit
	attacker.attack(weak_unit)

	assert_false(weak_unit.is_alive, "Unit should be dead after taking lethal damage")
	assert_less_or_equal(weak_unit.current_health, 0, "Health should be 0 or less")
	assert_false(weak_unit.visible, "Dead unit should be hidden")

	weak_unit.queue_free()


func test_attack_dead_unit() -> void:
	log_message("\n--- Test: Attack Dead Unit ---")

	# Create and kill a unit
	var dead_unit = Unit.new()
	dead_unit.max_health = 10
	dead_unit.current_health = 0
	dead_unit.is_alive = false
	dead_unit.tile_size = Vector2i(64, 64)
	add_child(dead_unit)
	dead_unit.global_position = Vector2(32, 96)

	attacker.reset_turn()
	attacker.snap_to_tile(Vector2i(0, 0))
	dead_unit.snap_to_tile(Vector2i(0, 1))

	var damage = attacker.attack(dead_unit)

	assert_equal(damage, 0, "Cannot attack dead units")

	dead_unit.queue_free()


func test_terrain_defense_bonus() -> void:
	log_message("\n--- Test: Terrain Defense Bonus ---")

	# Manually set terrain defense bonus
	defender.reset_turn()
	defender.current_health = defender.max_health
	defender.current_terrain_defense_bonus = 5  # Simulate defensive terrain

	attacker.reset_turn()
	attacker.snap_to_tile(Vector2i(0, 0))
	defender.snap_to_tile(Vector2i(1, 0))

	var effective_defense = defender.get_effective_defense()
	var expected_defense = defender.defense + 5

	assert_equal(effective_defense, expected_defense,
		"Effective defense should include terrain bonus: Expected %d, got %d" % [expected_defense, effective_defense])

	var damage = attacker.attack(defender)
	var expected_damage = max(1, attacker.attack_damage - effective_defense)

	assert_equal(damage, expected_damage,
		"Damage calculation should use effective defense with terrain bonus")
