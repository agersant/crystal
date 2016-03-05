# Custom Tiled Properties

## Layer Properties

### Sort

- Key: "sort"
- Acceptable values:
	- "below": layer draws below all entities
	- "above": layer draws above all entities
	- "dynamic": tiles on this layer sort dynamically with entities based on Y-position


## Collisions

Use Tiled's collision editor to paint collision shapes on individual tiles. The restrictions are:
- Only use the rectangle and polygon tools. Anything else will be ignored.
- Polygons must not self-intersect. The game doesn't verify this restriction! Overlapping or partially-overlapping edges are ok.
- Collisions shapes on a given tile must not intersect. The game doesn't verify this restriction! Overlapping or partially-overlapping edges are ok.
- Collisions shapes must be entirely contained within their tile (touching the tile edges is ok). Game will assert if this isn't respected.

For a given tile in the map, only one layer's collision information will be used. If multiple layers have collision information for the same map position, the top-most one will be used.