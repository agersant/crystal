---
parent: crystal.assets
grand_parent: API Reference
nav_order: 2
---

# crystal.Map

## Overview

Represents a 2D tile-based map and its content. These assets can be created using the [Tiled](https://www.mapeditor.org/) map editor (version 1.10 as of this writing). Crystal can only load maps that follow these requirements:

- Map `Orientation` is set to `Orthogonal`.
- Map is exported as a Lua file (select this from the `Export As...` menu in Tiled).
- Tilesets are exported as Lua files (and accompanying `png`), not embedded in the map.
- The `Tile Layer Format` in the map properties is set to `CSV`.

After exporting a map and loading into Crystal via [crystal.assets.get](get), you can call [spawn_entities](map_spawn_entities) to materialize it into visible and interactive objects.

### Tile Layers

Your maps may use any number of tile layers.

Polygons created using Tiled's `Tile Collision Editor` will turn into [colliders](/crystal/api/physics/collider). These colliders have the `level` category and can collide with every other category. Contiguous or overlapping polygons will be merged into larger shapes.

In addition, an additional collider will be added around the outline of the map.

### Object Layers

The content of object layers will be spawned as [entities](/crystal/api/ecs/entity). The entity class to spawn can be chosen by setting the `type` property in Tiled objects (eg. `"Chest"`). The constructor for these entities will receive one table containing:

- The `x` and `y` position of the entity.
- A [love.Shape](https://love2d.org/wiki/Shape) representing the entity's location. Only rectangles are supported.
- Any other property specified in Tiled.

## Constructor

You cannot construct maps manually. Use [crystal.assets.get](get) to load them from disk.

## Methods

| Name                                                   | Description                                                    |
| :----------------------------------------------------- | :------------------------------------------------------------- |
| [find_path](map_find_path)                             | Computes an unobstructed path between two map locations.       |
| [nearest_navigable_point](map_nearest_navigable_point) | Projects a point onto the navigable part of the map.           |
| [pixel_height](map_pixel_height)                       | Returns the map height in pixels.                              |
| [pixel_width](map_pixel_width)                         | Returns the map width in pixels.                               |
| [pixel_size](map_pixel_size)                           | Returns the map size in pixels.                                |
| [spawn_entities](map_spawn_entities)                   | Spawns entities necessary to display and play within this map. |
| [tilesets](map_tilesets)                               | Returns all [tilesets](tileset) used by this map.              |

## Examples

```lua
local ecs = crystal.ECS:new();
local map = crystal.assets.get("assets/maps/dungeon.lua");
map:spawn_entities(ecs);
```
