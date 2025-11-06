class_name Unit
extends Node2D

## Base class for all units in the game (player units, enemies, NPCs, etc.)
## This class provides core functionality for movement, combat, and stats management.

# Signals for events that other systems can react to
signal health_changed(new_health: int, max_health: int)
signal unit_died(unit: Unit)
signal damage_taken(damage: int, attacker: Unit)
signal unit_moved(from_tile: Vector2i, to_tile: Vector2i)
signal attack_performed(target: Unit, damage_dealt: int)

# Unit Stats - Use @export to make them easily configurable in the editor
@export_group("Base Stats")
@export var max_health: int = 20
@export var attack_damage: int = 5
@export var defense: int = 2
@export var movement_range: int = 5  # How many tiles the unit can move

@export_group("Tile Configuration")
@export var tile_size: Vector2i = Vector2i(64, 64)  # Size of each tile in pixels

# Current state
var current_health: int
var current_tile_position: Vector2i
var is_alive: bool = true
var has_moved_this_turn: bool = false
var has_attacked_this_turn: bool = false

func _ready() -> void:
	# Initialize health to max
	current_health = max_health

	# Calculate initial tile position based on world position
	current_tile_position = world_position_to_tile(global_position)

	# Snap to tile grid
	snap_to_tile(current_tile_position)


## Convert world position to tile coordinates
func world_position_to_tile(world_pos: Vector2) -> Vector2i:
	return Vector2i(
		int(world_pos.x / tile_size.x),
		int(world_pos.y / tile_size.y)
	)


## Convert tile coordinates to world position (center of tile)
func tile_to_world_position(tile_pos: Vector2i) -> Vector2:
	return Vector2(
		tile_pos.x * tile_size.x + tile_size.x / 2,
		tile_pos.y * tile_size.y + tile_size.y / 2
	)


## Snap the unit to a specific tile position
func snap_to_tile(tile_pos: Vector2i) -> void:
	global_position = tile_to_world_position(tile_pos)
	current_tile_position = tile_pos


## Move the unit to a target tile
## Returns true if the move was successful, false otherwise
func move_to_tile(target_tile: Vector2i) -> bool:
	if not is_alive:
		push_warning("Cannot move dead unit")
		return false

	if has_moved_this_turn:
		push_warning("Unit has already moved this turn")
		return false

	# Check if target is within movement range
	var distance = _calculate_tile_distance(current_tile_position, target_tile)
	if distance > movement_range:
		push_warning("Target tile is out of movement range (distance: %d, max: %d)" % [distance, movement_range])
		return false

	# Store old position for signal
	var old_position = current_tile_position

	# Move to new tile
	snap_to_tile(target_tile)
	has_moved_this_turn = true

	# Emit signal
	unit_moved.emit(old_position, target_tile)

	return true


## Attack another unit
## Returns the amount of damage dealt
func attack(target: Unit) -> int:
	if not is_alive:
		push_warning("Dead units cannot attack")
		return 0

	if not target or not target.is_alive:
		push_warning("Cannot attack invalid or dead target")
		return 0

	if has_attacked_this_turn:
		push_warning("Unit has already attacked this turn")
		return 0

	# Check if target is within attack range (adjacent tiles for now)
	var distance = _calculate_tile_distance(current_tile_position, target.current_tile_position)
	if distance > 1:
		push_warning("Target is not within attack range")
		return 0

	# Calculate damage (attack - defense, minimum 1)
	var damage_dealt = max(1, attack_damage - target.defense)

	# Apply damage to target
	target.take_damage(damage_dealt, self)

	# Mark as having attacked
	has_attacked_this_turn = true

	# Emit signal
	attack_performed.emit(target, damage_dealt)

	return damage_dealt


## Take damage from an attack or other source
func take_damage(damage: int, attacker: Unit = null) -> void:
	if not is_alive:
		return

	# Apply damage
	current_health -= damage

	# Emit damage signal
	damage_taken.emit(damage, attacker)
	health_changed.emit(current_health, max_health)

	# Check if unit died
	if current_health <= 0:
		die()


## Handle unit death
func die() -> void:
	if not is_alive:
		return

	is_alive = false
	current_health = 0

	# Emit death signal
	unit_died.emit(self)

	# Override this method in subclasses for custom death behavior
	_on_death()


## Virtual method for subclasses to override for custom death behavior
func _on_death() -> void:
	# Default behavior: hide the unit
	# Subclasses can override this for animations, loot drops, etc.
	visible = false


## Reset turn-based flags (call this at the start of each turn)
func reset_turn() -> void:
	has_moved_this_turn = false
	has_attacked_this_turn = false


## Calculate Manhattan distance between two tiles
func _calculate_tile_distance(from_tile: Vector2i, to_tile: Vector2i) -> int:
	return abs(to_tile.x - from_tile.x) + abs(to_tile.y - from_tile.y)


## Heal the unit by a specified amount
func heal(amount: int) -> void:
	if not is_alive:
		return

	current_health = min(current_health + amount, max_health)
	health_changed.emit(current_health, max_health)


## Check if a tile is within movement range
func is_tile_in_movement_range(tile: Vector2i) -> bool:
	return _calculate_tile_distance(current_tile_position, tile) <= movement_range


## Check if a tile is within attack range (adjacent tiles)
func is_tile_in_attack_range(tile: Vector2i) -> bool:
	return _calculate_tile_distance(current_tile_position, tile) == 1


## Get unit stats as a dictionary (useful for UI or save systems)
func get_stats() -> Dictionary:
	return {
		"max_health": max_health,
		"current_health": current_health,
		"attack_damage": attack_damage,
		"defense": defense,
		"movement_range": movement_range,
		"is_alive": is_alive,
		"tile_position": current_tile_position
	}
