class_name Sharpshooter
extends Unit

## Sharpshooter - Long-range precision unit
## High damage and long attack range but very fragile with low defense
## Excels at picking off enemies from a distance but must be protected

func _ready() -> void:
	# Sharpshooter stats - Glass cannon ranged archetype
	max_health = 12
	attack_damage = 12
	defense = 1  # Very fragile
	movement_range = 4  # Decent mobility to reposition
	attack_range = 4  # Long range attacks

	# Call parent _ready to initialize
	super._ready()


## Override death behavior for Sharpshooter-specific effects
func _on_death() -> void:
	# Sharpshooters might drop valuable equipment or have different death animations
	# For now, use default behavior
	super._on_death()
