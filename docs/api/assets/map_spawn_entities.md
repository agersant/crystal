---
parent: crystal.assets
grand_parent: API Reference
nav_exclude: true
---

# Map:spawn_entities

Spawns entities necessary to display and play within this map.

This will spawn:

- One entity with:
  - One drawable component per tile layer per tileset.
  - [Collider](/crystal/api/physics/collider) components representing the tile collision data.
- One entity per Tiled object within object layers. See the [Map](map) overview for more details on how these entities are constructed.

## Usage

```lua
map:spawn_entities(ecs)
```

### Arguments

| Name  | Type                        | Description                       |
| :---- | :-------------------------- | :-------------------------------- |
| `ecs` | [ECS](/crystal/api/ecs/ecs) | ECS to spawn the entities within. |

## Examples

```lua
local ecs = crystal.ECS:new();
local map = crystal.assets.get("assets/maps/dungeon.lua");
map:spawn_entities(ecs);
```
