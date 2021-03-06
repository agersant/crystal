# Custom Tiled Properties

## Layers Properties

There is no restriction on the number of tile layers or object layers in a map.

Z-ordering of tile layers against entities can be arranged by adding a "sort" property on each layer. Acceptables values are:
	- "below": Layer draws below all entities. Fixed runtime performance cost per layer. This is the default value.
	- "above": Layer draws above all entities. Fixed runtime performance cost per layer.
	- "dynamic": Tiles on this layer sort dynamically with entities based on Y-position. Runtime performance cost of these layers scales linearly with the number of tiles they hold.

## Collisions

Use Tiled's collision editor to paint collision shapes on individual tiles. The restrictions are:
- Only use the rectangle and polygon tools. Anything else will be ignored.
- It is recommended that collisions shapes fit entirely within their tile.

It is easier to position collision shapes using Tiled "snap to grid" option (or at least "snap to fine grid").

## Entities

Entities are placed on the map using rectangular objects. For monsters/characters, the center point of the rectangle will be used as spawn position. The nature of the entity and its expected properties are determined by the "class" property.

### Teleport entity

- Class: "Teleport"
- Required properties:
	- targetMap: Name of the map to teleport to
	- targetX: Horizontal position (in pixels) in the destination map corresponding to the center of the teleport object
	- targetY: Vertical position (in pixels) in the destination map corresponding to the center of the teleport object

