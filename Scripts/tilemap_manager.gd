class_name TileMapManager
extends Node2D

## Manages terrain data and provides query methods for units
## This is the single source of truth for terrain information

# Reference to the TileMapLayer node
@export var tile_map_layer: TileMapLayer

# Terrain type definitions - mapped to tile atlas coordinates
var terrain_types: Dictionary = {}

# Singleton reference for easy access
static var instance: TileMapManager


func _ready() -> void:
	instance = self
	_initialize_terrain_types()

	# If tile_map_layer is not set, try to find it
	if not tile_map_layer:
		tile_map_layer = get_node_or_null("TileMapLayer")
		if not tile_map_layer:
			push_error("TileMapManager: No TileMapLayer found!")


## Initialize all terrain type definitions
## Maps atlas coordinates (Vector2i) to TerrainType objects
func _initialize_terrain_types() -> void:
	# Based on BasicTiles.png atlas:
	# Row 0: MUD(0,0), PATH(1,0), STONE(2,0), GRASS(3,0), DEEP_WATER(4,0), SHALLOW_WATER(5,0)

	# MUD - Slow movement, no defense bonus
	terrain_types[Vector2i(0, 0)] = TerrainType.new(
		"Mud",
		2,  # movement_cost: 2 (slow)
		0,  # defense_bonus: 0
		0,  # avoid_bonus: 0
		true  # is_passable: true
	)

	# PATH - Easy movement, no defense bonus
	terrain_types[Vector2i(1, 0)] = TerrainType.new(
		"Path",
		1,  # movement_cost: 1 (normal)
		0,  # defense_bonus: 0
		0,  # avoid_bonus: 0
		true  # is_passable: true
	)

	# STONE - Normal movement, good defense
	terrain_types[Vector2i(2, 0)] = TerrainType.new(
		"Stone",
		1,  # movement_cost: 1 (normal)
		2,  # defense_bonus: +2
		10,  # avoid_bonus: +10
		true  # is_passable: true
	)

	# GRASS - Normal movement, slight defense
	terrain_types[Vector2i(3, 0)] = TerrainType.new(
		"Grass",
		1,  # movement_cost: 1 (normal)
		1,  # defense_bonus: +1
		5,  # avoid_bonus: +5
		true  # is_passable: true
	)

	# DEEP WATER - Impassable
	terrain_types[Vector2i(4, 0)] = TerrainType.new(
		"Deep Water",
		999,  # movement_cost: 999 (effectively impassable)
		0,  # defense_bonus: 0
		0,  # avoid_bonus: 0
		false  # is_passable: false
	)

	# SHALLOW WATER - Slow movement, no defense bonus
	terrain_types[Vector2i(5, 0)] = TerrainType.new(
		"Shallow Water",
		2,  # movement_cost: 2 (slow)
		0,  # defense_bonus: 0
		0,  # avoid_bonus: 0
		true  # is_passable: true
	)


## Get the terrain type at a specific tile position
func get_terrain_at_tile(tile_pos: Vector2i) -> TerrainType:
	if not tile_map_layer:
		push_error("TileMapManager: No TileMapLayer available")
		return _get_default_terrain()

	# Get the tile data at this position
	var tile_data = tile_map_layer.get_cell_tile_data(tile_pos)
	if not tile_data:
		# No tile at this position, return default
		return _get_default_terrain()

	# Get the atlas coordinates of this tile
	var atlas_coords = tile_map_layer.get_cell_atlas_coords(tile_pos)

	# Look up the terrain type
	if terrain_types.has(atlas_coords):
		return terrain_types[atlas_coords]
	else:
		push_warning("TileMapManager: Unknown terrain type at atlas coords %s" % atlas_coords)
		return _get_default_terrain()


## Get terrain at a world position (converts to tile coordinates)
func get_terrain_at_world_position(world_pos: Vector2) -> TerrainType:
	var tile_pos = tile_map_layer.local_to_map(world_pos)
	return get_terrain_at_tile(tile_pos)


## Check if a tile is passable
func is_tile_passable(tile_pos: Vector2i) -> bool:
	var terrain = get_terrain_at_tile(tile_pos)
	return terrain.is_passable


## Get movement cost for a tile
func get_movement_cost(tile_pos: Vector2i) -> int:
	var terrain = get_terrain_at_tile(tile_pos)
	return terrain.movement_cost


## Get defense bonus for a tile
func get_defense_bonus(tile_pos: Vector2i) -> int:
	var terrain = get_terrain_at_tile(tile_pos)
	return terrain.defense_bonus


## Get avoid bonus for a tile
func get_avoid_bonus(tile_pos: Vector2i) -> int:
	var terrain = get_terrain_at_tile(tile_pos)
	return terrain.avoid_bonus


## Calculate path cost between two tiles (accounting for terrain)
## Returns -1 if path is impossible
func calculate_path_cost(from_tile: Vector2i, to_tile: Vector2i, max_movement: int) -> int:
	# This is a simplified version - for now just checks direct distance
	# A proper implementation would use A* with movement costs
	var distance = abs(to_tile.x - from_tile.x) + abs(to_tile.y - from_tile.y)

	if distance == 0:
		return 0

	# Check if destination is passable
	if not is_tile_passable(to_tile):
		return -1

	# For now, estimate by adding destination's movement cost
	# A proper pathfinding would sum all tiles in the path
	var estimated_cost = distance + get_movement_cost(to_tile) - 1

	return estimated_cost if estimated_cost <= max_movement else -1


## Get all tiles within movement range of a position
## Returns array of Vector2i tile positions
func get_tiles_in_movement_range(start_tile: Vector2i, movement_range: int) -> Array[Vector2i]:
	var reachable_tiles: Array[Vector2i] = []

	# Use flood fill algorithm to find reachable tiles considering movement costs
	var open_set: Array = [{
		"pos": start_tile,
		"cost": 0
	}]
	var visited: Dictionary = {start_tile: 0}

	while open_set.size() > 0:
		var current = open_set.pop_front()
		var current_pos: Vector2i = current["pos"]
		var current_cost: int = current["cost"]

		# Check all adjacent tiles
		var neighbors = [
			current_pos + Vector2i(1, 0),
			current_pos + Vector2i(-1, 0),
			current_pos + Vector2i(0, 1),
			current_pos + Vector2i(0, -1)
		]

		for neighbor in neighbors:
			# Skip if not passable
			if not is_tile_passable(neighbor):
				continue

			# Calculate cost to reach this neighbor
			var move_cost = get_movement_cost(neighbor)
			var new_cost = current_cost + move_cost

			# Skip if too expensive
			if new_cost > movement_range:
				continue

			# Skip if we've found a better path already
			if visited.has(neighbor) and visited[neighbor] <= new_cost:
				continue

			# Mark as visited with this cost
			visited[neighbor] = new_cost
			reachable_tiles.append(neighbor)

			# Add to open set for further exploration
			open_set.append({
				"pos": neighbor,
				"cost": new_cost
			})

	return reachable_tiles


## Default terrain for fallback
func _get_default_terrain() -> TerrainType:
	return TerrainType.new("Unknown", 1, 0, 0, true)


## Get terrain description for UI
func get_terrain_description(tile_pos: Vector2i) -> String:
	var terrain = get_terrain_at_tile(tile_pos)
	return terrain.get_description()
