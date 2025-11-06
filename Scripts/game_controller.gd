extends Node2D

## Main game controller
## Sets up the game world, spawns units, and manages gameplay

# Scene references
@onready var turn_manager: TurnManager = $TurnManager
@onready var map_container: Node2D = $MapContainer
@onready var units_container: Node2D = $UnitsContainer
@onready var turn_info_label: Label = $UI/HUD/TurnInfo
@onready var stats_label: Label = $UI/HUD/UnitStats/StatsLabel
@onready var end_turn_button: Button = $UI/HUD/EndTurnButton

# Preload unit scenes
var bulkhead_scene = preload("res://Scenes/bulkhead.tscn")
var sharpshooter_scene = preload("res://Scenes/sharpshooter.tscn")
var privateer_scene = preload("res://Scenes/privateer.tscn")
var cleaner_scene = preload("res://Scenes/cleaner.tscn")

# Preload map scene
var map_scene = preload("res://World/map.tscn")


func _ready() -> void:
	print("GameController: Initializing game...")

	# Connect turn manager signals
	turn_manager.turn_started.connect(_on_turn_started)
	turn_manager.player_turn_started.connect(_on_player_turn_started)
	turn_manager.enemy_turn_started.connect(_on_enemy_turn_started)

	# Spawn the map
	_spawn_map()

	# Wait a frame for map to initialize
	await get_tree().process_frame

	# Spawn units
	_spawn_units()

	# Wait a frame for units to initialize
	await get_tree().process_frame

	# Start the game
	turn_manager.start_game()

	# Update UI
	_update_ui()


## Spawn the game map
func _spawn_map() -> void:
	print("GameController: Spawning map...")
	var map = map_scene.instantiate()
	map_container.add_child(map)


## Spawn all units (player and enemy)
func _spawn_units() -> void:
	print("GameController: Spawning units...")

	# Spawn player units (left side of map)
	_spawn_player_unit(bulkhead_scene, Vector2i(1, 4), "Player BulkHead")
	_spawn_player_unit(sharpshooter_scene, Vector2i(2, 3), "Player Sharpshooter")
	_spawn_player_unit(privateer_scene, Vector2i(2, 5), "Player Privateer")
	_spawn_player_unit(cleaner_scene, Vector2i(1, 6), "Player Cleaner")

	# Spawn enemy units (right side of map)
	_spawn_enemy_unit(bulkhead_scene, Vector2i(15, 4), "Enemy BulkHead")
	_spawn_enemy_unit(sharpshooter_scene, Vector2i(14, 3), "Enemy Sharpshooter")
	_spawn_enemy_unit(privateer_scene, Vector2i(14, 5), "Enemy Privateer")
	_spawn_enemy_unit(cleaner_scene, Vector2i(15, 6), "Enemy Cleaner")


## Spawn a player unit at a specific tile
func _spawn_player_unit(scene: PackedScene, tile_pos: Vector2i, unit_name: String) -> void:
	var unit = scene.instantiate() as Unit
	unit.team = Unit.Team.PLAYER
	unit.name = unit_name

	# Position the unit
	var world_pos = _tile_to_world(tile_pos)
	unit.global_position = world_pos

	units_container.add_child(unit)
	turn_manager.register_unit(unit)

	print("  Spawned %s at tile %s" % [unit_name, tile_pos])


## Spawn an enemy unit at a specific tile
func _spawn_enemy_unit(scene: PackedScene, tile_pos: Vector2i, unit_name: String) -> void:
	var unit = scene.instantiate() as Unit
	unit.team = Unit.Team.ENEMY
	unit.name = unit_name

	# Position the unit
	var world_pos = _tile_to_world(tile_pos)
	unit.global_position = world_pos

	units_container.add_child(unit)
	turn_manager.register_unit(unit)

	print("  Spawned %s at tile %s" % [unit_name, tile_pos])


## Convert tile position to world position
func _tile_to_world(tile_pos: Vector2i) -> Vector2:
	var tile_size = 64
	return Vector2(
		tile_pos.x * tile_size + tile_size / 2,
		tile_pos.y * tile_size + tile_size / 2
	)


## Handle end turn button pressed
func _on_end_turn_pressed() -> void:
	if turn_manager.current_team == Unit.Team.PLAYER:
		print("\n>>> Player ended their turn")
		turn_manager.end_turn()
	else:
		print("Cannot end turn - it's not the player's turn!")


## Update UI elements
func _update_ui() -> void:
	var turn_info = turn_manager.get_turn_info()

	# Update turn display
	var team_name = "PLAYER" if turn_manager.current_team == Unit.Team.PLAYER else "ENEMY"
	turn_info_label.text = "Turn %d - %s TURN" % [turn_info["turn_number"], team_name]

	# Update stats
	stats_label.text = "Player Units: %d\nEnemy Units: %d\n\n%s" % [
		turn_info["player_units_alive"],
		turn_info["enemy_units_alive"],
		"Your turn!" if turn_manager.current_team == Unit.Team.PLAYER else "Enemy thinking..."
	]

	# Enable/disable end turn button
	end_turn_button.disabled = turn_manager.current_team != Unit.Team.PLAYER


## Turn started signal handler
func _on_turn_started(team: Unit.Team) -> void:
	_update_ui()


## Player turn started signal handler
func _on_player_turn_started() -> void:
	print(">>> UI: Player turn started")


## Enemy turn started signal handler
func _on_enemy_turn_started() -> void:
	print(">>> UI: Enemy turn started")
