class_name Privateer
extends Unit

## Privateer - Jack of all trades, master of none
## Balanced stats across the board making them versatile and adaptable
## Good for filling gaps in your squad composition

func _ready() -> void:
	# Privateer stats - Balanced archetype
	max_health = 20
	attack_damage = 6
	defense = 4
	movement_range = 4  # Balanced mobility
	attack_range = 2  # Short-medium range

	# Call parent _ready to initialize
	super._ready()


## Override death behavior for Privateer-specific effects
func _on_death() -> void:
	# Privateers might have crew that scatter or unique death behavior
	# For now, use default behavior
	super._on_death()
