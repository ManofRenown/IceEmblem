class_name BulkHead
extends Unit

## BulkHead - Heavy melee bruiser unit
## High health, high damage, high defense but very slow movement
## Ideal for frontline combat and holding positions in space battles

func _ready() -> void:
	# BulkHead stats - Tank/Bruiser archetype
	max_health = 40
	attack_damage = 10
	defense = 8
	movement_range = 2  # Very slow
	attack_range = 1  # Melee only

	# Call parent _ready to initialize
	super._ready()


## Override death behavior for BulkHead-specific effects
func _on_death() -> void:
	# BulkHeads could have special death effects like explosions
	# For now, use default behavior
	super._on_death()
