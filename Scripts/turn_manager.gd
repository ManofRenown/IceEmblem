class_name TurnManager
extends Node

## Manages the turn-based gameplay loop
## Handles player turn → enemy turn cycling and unit action resets

# Signals for turn changes
signal turn_started(team: Unit.Team)
signal turn_ended(team: Unit.Team)
signal player_turn_started()
signal enemy_turn_started()

# Current turn state
var current_team: Unit.Team = Unit.Team.PLAYER
var turn_number: int = 1

# References to units
var all_units: Array[Unit] = []
var player_units: Array[Unit] = []
var enemy_units: Array[Unit] = []


func _ready() -> void:
	print("TurnManager initialized")


## Register a unit with the turn manager
func register_unit(unit: Unit) -> void:
	if unit in all_units:
		return

	all_units.append(unit)

	# Categorize by team
	match unit.team:
		Unit.Team.PLAYER:
			player_units.append(unit)
		Unit.Team.ENEMY:
			enemy_units.append(unit)
		Unit.Team.NEUTRAL:
			pass  # Neutral units don't participate in turns

	# Connect to unit death signal to remove them
	unit.unit_died.connect(_on_unit_died)

	print("Registered %s unit (Team: %s)" % [unit.get_class(), Unit.Team.keys()[unit.team]])


## Unregister a unit (e.g., when it dies)
func unregister_unit(unit: Unit) -> void:
	all_units.erase(unit)
	player_units.erase(unit)
	enemy_units.erase(unit)


## Start the game (begins player turn)
func start_game() -> void:
	print("\n=== GAME START ===")
	turn_number = 1
	current_team = Unit.Team.PLAYER
	_start_turn()


## Start a new turn for the current team
func _start_turn() -> void:
	print("\n=== Turn %d: %s TURN START ===" % [turn_number, Unit.Team.keys()[current_team]])

	# Reset all units of the current team
	var units = _get_units_for_team(current_team)
	for unit in units:
		if unit.is_alive:
			unit.reset_turn()
			print("  Reset %s at tile %s" % [unit.get_class(), unit.current_tile_position])

	# Emit signals
	turn_started.emit(current_team)

	if current_team == Unit.Team.PLAYER:
		player_turn_started.emit()
		print(">>> Waiting for player actions...")
	else:
		enemy_turn_started.emit()
		print(">>> Enemy AI would take actions here...")
		# For now, enemy turn ends immediately
		# Later: Call enemy AI system
		await get_tree().create_timer(1.0).timeout  # Simulate AI thinking
		end_turn()


## End the current turn and switch to next team
func end_turn() -> void:
	print("\n=== %s TURN END ===" % Unit.Team.keys()[current_team])

	# Emit signal
	turn_ended.emit(current_team)

	# Switch to next team
	if current_team == Unit.Team.PLAYER:
		current_team = Unit.Team.ENEMY
	else:
		current_team = Unit.Team.PLAYER
		turn_number += 1

	# Start next turn
	_start_turn()


## Get all units for a specific team
func _get_units_for_team(team: Unit.Team) -> Array[Unit]:
	match team:
		Unit.Team.PLAYER:
			return player_units
		Unit.Team.ENEMY:
			return enemy_units
		_:
			return []


## Check if all units of a team have finished their actions
func are_all_units_finished(team: Unit.Team) -> bool:
	var units = _get_units_for_team(team)
	for unit in units:
		if unit.is_alive and (not unit.has_moved_this_turn or not unit.has_attacked_this_turn):
			# Unit still has actions available
			return false
	return true


## Handle unit death
func _on_unit_died(unit: Unit) -> void:
	print("Unit died: %s" % unit.get_class())
	unregister_unit(unit)

	# Check for win/lose conditions
	_check_victory_conditions()


## Check if either team has won
func _check_victory_conditions() -> void:
	var player_alive = false
	var enemy_alive = false

	for unit in player_units:
		if unit.is_alive:
			player_alive = true
			break

	for unit in enemy_units:
		if unit.is_alive:
			enemy_alive = true
			break

	if not player_alive:
		_on_defeat()
	elif not enemy_alive:
		_on_victory()


## Handle player victory
func _on_victory() -> void:
	print("\n=== VICTORY! ===")
	print("All enemies defeated!")
	# Later: Show victory screen, rewards, etc.


## Handle player defeat
func _on_defeat() -> void:
	print("\n=== DEFEAT! ===")
	print("All player units defeated!")
	# Later: Show game over screen


## Get current turn info as dictionary
func get_turn_info() -> Dictionary:
	return {
		"turn_number": turn_number,
		"current_team": current_team,
		"player_units_alive": _count_alive_units(player_units),
		"enemy_units_alive": _count_alive_units(enemy_units)
	}


## Count alive units in an array
func _count_alive_units(units: Array[Unit]) -> int:
	var count = 0
	for unit in units:
		if unit.is_alive:
			count += 1
	return count
