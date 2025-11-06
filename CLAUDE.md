# IceEmblem - Fire Emblem Style Game

A tactical turn-based strategy game inspired by Fire Emblem, built in Godot 4.5 with GDScript.

## Project Vision

IceEmblem aims to create a Fire Emblem-style tactical RPG set in space, featuring:
- Turn-based grid combat on tile-based maps
- Diverse unit types with unique stats and roles
- Terrain effects that influence combat and movement
- Strategic depth through positioning and unit composition
- Player vs Enemy tactical gameplay

## Current Implementation Status

### ✅ Core Systems Completed

#### 1. **Unit System** (Scripts/unit.gd)

The foundation of all gameplay - a generic, extensible base class for all units.

**Features:**
- Health management (current/max HP, death handling)
- Combat system (attack, defend, damage calculation)
- Movement system (tile-based with range limits)
- Turn-based action tracking (moved/attacked flags)
- Team allegiance system (PLAYER, ENEMY, NEUTRAL)
- Terrain integration (defense bonuses from terrain)
- Signal-driven architecture for event handling

**Key Methods:**
- `move_to_tile()` - Move unit with terrain validation
- `attack()` - Attack adjacent/ranged units
- `take_damage()` - Process incoming damage
- `reset_turn()` - Reset action flags each turn
- `get_effective_defense()` - Base defense + terrain bonuses

#### 2. **Unit Types** (Scripts/*.gd, Scenes/*.tscn)

Four specialized space-themed unit archetypes:

**BulkHead** - Heavy Melee Tank
- HP: 40 | ATK: 10 | DEF: 8 | MOV: 2 | RNG: 1
- Role: Frontline bruiser, absorbs damage, slow but powerful
- Color: Red

**Sharpshooter** - Long-Range Sniper
- HP: 12 | ATK: 12 | DEF: 1 | MOV: 4 | RNG: 4
- Role: Glass cannon, eliminates targets from distance, very fragile
- Color: Green

**Privateer** - Balanced All-Rounder
- HP: 20 | ATK: 6 | DEF: 4 | MOV: 4 | RNG: 2
- Role: Jack of all trades, versatile, fills any squad gap
- Color: Blue

**Cleaner** - Mobile Assassin
- HP: 18 | ATK: 9 | DEF: 3 | MOV: 6 | RNG: 1
- Role: Hit-and-run specialist, high mobility, flanking attacks
- Color: Yellow

#### 3. **Terrain System** (Scripts/tilemap_manager.gd, Scripts/terrain_type.gd)

Fire Emblem-style terrain with movement costs and defensive bonuses.

**Terrain Types:**
- **Mud**: Movement cost 2, Defense +0 (slows movement)
- **Path**: Movement cost 1, Defense +0 (standard terrain)
- **Stone**: Movement cost 1, Defense +2, Avoid +10 (strong cover)
- **Grass**: Movement cost 1, Defense +1, Avoid +5 (light cover)
- **Deep Water**: Impassable (blocks all movement)
- **Shallow Water**: Movement cost 2, Defense +0 (slows movement)

**TileMapManager Features:**
- Single source of truth for terrain data
- Query methods for terrain at any tile/world position
- Movement range calculation with terrain costs (flood fill algorithm)
- Passability checking
- Defense/avoid bonus retrieval
- Singleton pattern for global access

**Terrain Effects:**
- Units query terrain bonuses when moving
- Combat uses effective defense (base + terrain)
- Movement costs affect reachable tiles
- Impassable terrain blocks pathfinding

#### 4. **Testing Framework** (Test/*, Scripts/test.gd)

Comprehensive automated testing system with 4 test suites.

**Test Base Class:**
- Rich assertion methods (equal, greater, in_range, etc.)
- Automatic result tracking
- Failure-only logging (no PASS spam)
- Structured result output

**Test Suites:**
1. **Unit Movement Tests** - Movement, range, terrain passability, turn reset
2. **Unit Combat Tests** - Attack, damage calculation, death, terrain defense
3. **Terrain Effects Tests** - Terrain types, costs, bonuses, passability
4. **Unit Types Tests** - All unit stats, team allegiance, type differences

**Test Runner (Test/run_all.tscn):**
- Executes all tests sequentially
- Generates comprehensive reports
- Saves timestamped reports to TestOutputs/
- Shows only failures (reduces spam)
- Failure summary at end of report for easy debugging

## Architecture & Design Patterns

### Object-Oriented Inheritance
```
Node2D
  └─ Unit (base class)
      ├─ BulkHead
      ├─ Sharpshooter
      ├─ Privateer
      └─ Cleaner
```

### Singleton Pattern
- `TileMapManager.instance` - Global access to terrain data

### Signal-Driven Events
Units emit signals for game events:
- `health_changed(new_health, max_health)`
- `unit_died(unit)`
- `damage_taken(damage, attacker)`
- `unit_moved(from_tile, to_tile)`
- `attack_performed(target, damage_dealt)`

### Resource-Based Data
- `TerrainType` - Encapsulates terrain properties as resources

### Tile-Based Grid System
- 64x64 pixel tiles
- Vector2i for tile coordinates
- World/tile coordinate conversion utilities

## Project Structure

```
IceEmblem/
├── Assets/
│   └── TileMap/
│       └── BasicTiles.png          # 6 terrain types
├── Scenes/
│   ├── bulkhead.tscn               # BulkHead unit scene
│   ├── sharpshooter.tscn           # Sharpshooter unit scene
│   ├── privateer.tscn              # Privateer unit scene
│   └── cleaner.tscn                # Cleaner unit scene
├── Scripts/
│   ├── unit.gd                     # Base unit class
│   ├── bulkhead.gd                 # BulkHead implementation
│   ├── sharpshooter.gd             # Sharpshooter implementation
│   ├── privateer.gd                # Privateer implementation
│   ├── cleaner.gd                  # Cleaner implementation
│   ├── tilemap_manager.gd          # Terrain system manager
│   ├── terrain_type.gd             # Terrain properties resource
│   └── test.gd                     # Test base class
├── Test/
│   ├── CLAUDE.md                   # Testing documentation
│   ├── TestOutputs/                # Generated test reports
│   ├── run_all.gd/tscn             # Test runner
│   ├── test_unit_movement.gd/tscn  # Movement tests
│   ├── test_unit_combat.gd/tscn    # Combat tests
│   ├── test_terrain_effects.gd/tscn # Terrain tests
│   └── test_unit_types.gd/tscn     # Unit type tests
├── World/
│   └── map.tscn                    # Game map with TileMapManager
├── main.tscn                       # Main scene
└── CLAUDE.md                       # This file
```

## Roadmap: Building a Complete Fire Emblem Game

### Phase 1: Core Gameplay Loop ⚡ IN PROGRESS

**Current Progress:**
- ✅ Unit system with stats, movement, combat
- ✅ Multiple unit types with distinct roles
- ✅ Terrain system with costs and bonuses
- ✅ Basic tile-based grid
- ✅ Comprehensive testing framework

**Next Steps:**
- [ ] Turn management system (player turn → enemy turn)
- [ ] Unit selection and cursor system
- [ ] Movement preview/highlighting (show reachable tiles)
- [ ] Attack range preview/highlighting
- [ ] Action confirmation UI
- [ ] Basic game loop (select unit → move → attack → end turn)

### Phase 2: Combat Refinement

- [ ] Combat forecast (show expected damage before attacking)
- [ ] Hit/miss/critical system
- [ ] Weapon triangle (rock-paper-scissors advantages)
- [ ] Counterattack system
- [ ] Experience and leveling system
- [ ] Stat growth on level up
- [ ] Death permanence (units die permanently)
- [ ] Combat animations

### Phase 3: Strategic Depth

- [ ] Support system (units near allies get bonuses)
- [ ] Skills/abilities system
- [ ] Unit classes and promotions
- [ ] Inventory/equipment system
- [ ] Different weapon types (melee, ranged, magic)
- [ ] Status effects (poison, stun, etc.)
- [ ] Objective-based maps (rout enemy, seize throne, defend, escape)
- [ ] Fog of war

### Phase 4: Game Structure

- [ ] Map editor for level design
- [ ] Campaign structure (multiple chapters)
- [ ] Story/dialogue system
- [ ] Character recruitment
- [ ] Permadeath toggle
- [ ] Difficulty levels
- [ ] Save/load system
- [ ] Unit customization/builds

### Phase 5: Polish & Content

- [ ] Refined UI/UX
- [ ] Sound effects and music
- [ ] Visual effects (particles, shaders)
- [ ] Character portraits and unit sprites
- [ ] Map variety (different tilesets, hazards)
- [ ] Enemy AI (threat assessment, targeting priority)
- [ ] Balancing (unit stats, map difficulty)
- [ ] Tutorial/introduction levels

### Phase 6: Advanced Features

- [ ] Multiple save slots
- [ ] New Game+
- [ ] Side chapters/paralogues
- [ ] Secret characters/units
- [ ] Bonus objectives
- [ ] Achievements/challenges
- [ ] Replay/rewind system
- [ ] Online features (if desired)

## Fire Emblem Mechanics Reference

Core mechanics to implement for authentic Fire Emblem experience:

### Essential Mechanics ✅
- [x] Turn-based grid combat
- [x] Unit types with varied stats
- [x] Movement range based on unit
- [x] Attack range (melee vs ranged)
- [x] Terrain effects on defense
- [x] Terrain effects on movement cost

### Important Mechanics 🔄
- [ ] Weapon triangle (swords > axes > lances > swords)
- [ ] Hit rate and avoid (accuracy system)
- [ ] Critical hits
- [ ] Experience and leveling
- [ ] Support bonuses (adjacent ally buffs)
- [ ] Enemy AI with tactical behavior
- [ ] Permadeath

### Nice-to-Have Mechanics 📋
- [ ] Skills system
- [ ] Class promotion
- [ ] Inventory management
- [ ] Weapon durability
- [ ] Magic system
- [ ] Mounted units (cavalry movement)
- [ ] Flying units (ignore terrain)

## Technical Notes

### GDScript 4.5 Compatibility
All code is written for Godot 4.5 with proper syntax:
- Typed arrays: `Array[String]`
- `await` instead of `yield`
- `super._ready()` for parent calls
- `FileAccess.open()` instead of `File.new()`
- String repeat: `"=".repeat(80)` instead of `"=" * 80`
- Proper operator precedence in ternary expressions

### Testing Philosophy
- Write tests for all core mechanics
- Only log failures to reduce noise
- Comprehensive failure summaries at end of reports
- Easy to identify and fix broken tests
- Tests as documentation of expected behavior

### Code Organization Principles
- Base classes for extensibility (`Unit` → specific units)
- Single responsibility (TileMapManager for terrain only)
- Signal-driven communication (loose coupling)
- Resources for data (`TerrainType`)
- Singleton for global services (`TileMapManager.instance`)

## Getting Started

### Running Tests
```bash
# In Godot Editor
1. Open Test/run_all.tscn
2. Press F6 or click "Run Current Scene"
3. Check console output for results
4. Check Test/TestOutputs/ for detailed reports
```

### Adding a New Unit Type
```gdscript
# 1. Create Scripts/new_unit.gd
class_name NewUnit
extends Unit

func _ready() -> void:
    max_health = 25
    attack_damage = 8
    defense = 5
    movement_range = 3
    attack_range = 1
    super._ready()

# 2. Create Scenes/new_unit.tscn
# Attach new_unit.gd script
# Add Sprite2D with icon.svg
# Set modulate color

# 3. Done! Unit is ready to use
```

### Adding a New Terrain Type
```gdscript
# In TileMapManager._initialize_terrain_types()
terrain_types[Vector2i(x, y)] = TerrainType.new(
    "Lava",        # name
    999,           # movement_cost (impassable)
    0,             # defense_bonus
    0,             # avoid_bonus
    false          # is_passable
)
```

## Design Philosophy

**Simplicity First**: Start with core mechanics, add complexity gradually
**Test Everything**: Automated tests catch regressions early
**Extensibility**: Base classes and inheritance enable easy expansion
**Fire Emblem DNA**: Authentic tactical gameplay with space theme
**Clean Code**: Readable, maintainable, well-documented

## Contributing

When adding new features:
1. Extend existing base classes when possible
2. Write tests for new functionality (see Test/CLAUDE.md)
3. Update this document if adding major systems
4. Follow GDScript 4.5 syntax conventions
5. Use signals for inter-object communication

## Resources

- **Godot Documentation**: https://docs.godotengine.org/en/stable/
- **Fire Emblem Wiki**: For gameplay mechanics reference
- **Project Tests**: Test/ directory for working examples

---

**Current Status**: Foundation complete, ready for gameplay loop implementation
**Next Milestone**: Interactive unit selection and movement
**Goal**: Create a fully playable Fire Emblem-style tactical RPG in space
