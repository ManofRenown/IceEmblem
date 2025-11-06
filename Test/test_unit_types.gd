extends Test

## Tests for specialized unit types
## Tests that each unit type has correct stats and behaviors

var tilemap_manager: TileMapManager


func _ready() -> void:
	test_name = "Unit Types Tests"
	test_description = "Tests specialized unit types (BulkHead, Sharpshooter, Privateer, Cleaner)"


func run_test() -> void:
	# Create test dependencies
	_setup_test_environment()

	# Run test cases
	test_bulkhead_stats()
	test_sharpshooter_stats()
	test_privateer_stats()
	test_cleaner_stats()
	test_unit_type_differences()
	test_team_allegiance()

	# Cleanup
	_cleanup_test_environment()


func _setup_test_environment() -> void:
	log_message("Setting up test environment...")

	# Create TileMapManager
	tilemap_manager = TileMapManager.new()
	add_child(tilemap_manager)
	TileMapManager.instance = tilemap_manager


func _cleanup_test_environment() -> void:
	log_message("Cleaning up test environment...")
	if tilemap_manager:
		tilemap_manager.queue_free()


func test_bulkhead_stats() -> void:
	log_message("\n--- Test: BulkHead Stats ---")

	var bulkhead = BulkHead.new()
	add_child(bulkhead)

	# Wait for _ready to be called
	await get_tree().process_frame

	assert_equal(bulkhead.max_health, 40, "BulkHead should have 40 HP")
	assert_equal(bulkhead.attack_damage, 10, "BulkHead should have 10 attack")
	assert_equal(bulkhead.defense, 8, "BulkHead should have 8 defense")
	assert_equal(bulkhead.movement_range, 2, "BulkHead should have 2 movement (slow)")
	assert_equal(bulkhead.attack_range, 1, "BulkHead should be melee (range 1)")

	log_message("BulkHead is a slow, tanky bruiser with high HP, attack, and defense")

	bulkhead.queue_free()


func test_sharpshooter_stats() -> void:
	log_message("\n--- Test: Sharpshooter Stats ---")

	var sharpshooter = Sharpshooter.new()
	add_child(sharpshooter)

	await get_tree().process_frame

	assert_equal(sharpshooter.max_health, 12, "Sharpshooter should have 12 HP (fragile)")
	assert_equal(sharpshooter.attack_damage, 12, "Sharpshooter should have 12 attack (high damage)")
	assert_equal(sharpshooter.defense, 1, "Sharpshooter should have 1 defense (very low)")
	assert_equal(sharpshooter.movement_range, 4, "Sharpshooter should have 4 movement")
	assert_equal(sharpshooter.attack_range, 4, "Sharpshooter should have long range (4)")

	log_message("Sharpshooter is a glass cannon with long range but low HP and defense")

	sharpshooter.queue_free()


func test_privateer_stats() -> void:
	log_message("\n--- Test: Privateer Stats ---")

	var privateer = Privateer.new()
	add_child(privateer)

	await get_tree().process_frame

	assert_equal(privateer.max_health, 20, "Privateer should have 20 HP (balanced)")
	assert_equal(privateer.attack_damage, 6, "Privateer should have 6 attack (balanced)")
	assert_equal(privateer.defense, 4, "Privateer should have 4 defense (balanced)")
	assert_equal(privateer.movement_range, 4, "Privateer should have 4 movement (balanced)")
	assert_equal(privateer.attack_range, 2, "Privateer should have medium range (2)")

	log_message("Privateer is balanced across all stats - jack of all trades")

	privateer.queue_free()


func test_cleaner_stats() -> void:
	log_message("\n--- Test: Cleaner Stats ---")

	var cleaner = Cleaner.new()
	add_child(cleaner)

	await get_tree().process_frame

	assert_equal(cleaner.max_health, 18, "Cleaner should have 18 HP")
	assert_equal(cleaner.attack_damage, 9, "Cleaner should have 9 attack (high)")
	assert_equal(cleaner.defense, 3, "Cleaner should have 3 defense (medium)")
	assert_equal(cleaner.movement_range, 6, "Cleaner should have 6 movement (very high)")
	assert_equal(cleaner.attack_range, 1, "Cleaner should be melee (range 1)")

	log_message("Cleaner is a mobile assassin with high movement and damage")

	cleaner.queue_free()


func test_unit_type_differences() -> void:
	log_message("\n--- Test: Unit Type Differences ---")

	var bulkhead = BulkHead.new()
	var sharpshooter = Sharpshooter.new()
	var privateer = Privateer.new()
	var cleaner = Cleaner.new()

	add_child(bulkhead)
	add_child(sharpshooter)
	add_child(privateer)
	add_child(cleaner)

	await get_tree().process_frame

	# Test movement differences
	assert_less(bulkhead.movement_range, privateer.movement_range,
		"BulkHead should be slower than Privateer")
	assert_greater(cleaner.movement_range, bulkhead.movement_range,
		"Cleaner should be much faster than BulkHead")

	# Test attack range differences
	assert_greater(sharpshooter.attack_range, bulkhead.attack_range,
		"Sharpshooter should have longer range than BulkHead")
	assert_equal(bulkhead.attack_range, cleaner.attack_range,
		"BulkHead and Cleaner should both be melee")

	# Test HP differences
	assert_greater(bulkhead.max_health, sharpshooter.max_health,
		"BulkHead should have more HP than Sharpshooter")
	assert_greater(bulkhead.max_health, cleaner.max_health,
		"BulkHead should have most HP")

	# Test defense differences
	assert_greater(bulkhead.defense, sharpshooter.defense,
		"BulkHead should have much more defense than Sharpshooter")

	bulkhead.queue_free()
	sharpshooter.queue_free()
	privateer.queue_free()
	cleaner.queue_free()


func test_team_allegiance() -> void:
	log_message("\n--- Test: Team Allegiance ---")

	var player_unit = BulkHead.new()
	add_child(player_unit)
	await get_tree().process_frame

	# Default team should be PLAYER
	assert_equal(player_unit.team, Unit.Team.PLAYER, "Default team should be PLAYER")

	# Test setting team to ENEMY
	player_unit.team = Unit.Team.ENEMY
	assert_equal(player_unit.team, Unit.Team.ENEMY, "Should be able to set team to ENEMY")

	# Test setting team to NEUTRAL
	player_unit.team = Unit.Team.NEUTRAL
	assert_equal(player_unit.team, Unit.Team.NEUTRAL, "Should be able to set team to NEUTRAL")

	# Verify team is included in stats
	var stats = player_unit.get_stats()
	assert_true(stats.has("team"), "Stats should include team")

	player_unit.queue_free()
