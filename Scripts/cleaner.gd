class_name Cleaner
extends Unit

## Cleaner - Highly mobile close-range assassin
## High mobility and damage with average defense for hit-and-run tactics
## Specializes in eliminating high-value targets quickly

func _ready() -> void:
	# Cleaner stats - Mobile assassin archetype
	max_health = 18
	attack_damage = 9
	defense = 3
	movement_range = 6  # Very high mobility
	attack_range = 1  # Close range only

	# Call parent _ready to initialize
	super._ready()


## Override death behavior for Cleaner-specific effects
func _on_death() -> void:
	# Cleaners might leave behind hazardous materials or have stealth death effects
	# For now, use default behavior
	super._on_death()
