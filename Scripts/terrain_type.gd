class_name TerrainType
extends Resource

## Defines properties for different terrain types
## Used by TileMapManager to determine terrain effects on units

@export var terrain_name: String = "Plain"
@export var movement_cost: int = 1  # How much movement points it costs to enter this tile
@export var defense_bonus: int = 0  # Bonus defense when standing on this terrain
@export var avoid_bonus: int = 0  # Bonus avoid/evasion (for future implementation)
@export var is_passable: bool = true  # Whether units can move through this terrain

func _init(
	p_name: String = "Plain",
	p_movement_cost: int = 1,
	p_defense_bonus: int = 0,
	p_avoid_bonus: int = 0,
	p_passable: bool = true
) -> void:
	terrain_name = p_name
	movement_cost = p_movement_cost
	defense_bonus = p_defense_bonus
	avoid_bonus = p_avoid_bonus
	is_passable = p_passable


func get_description() -> String:
	var desc = "%s - Move: %d, Def: +%d" % [terrain_name, movement_cost, defense_bonus]
	if not is_passable:
		desc += " (Impassable)"
	return desc
