---
parent: crystal.assets
grand_parent: API Reference
nav_exclude: true
---

# Animation:sequence

Each animation contains multiple sequence, corresponding to the same action being performed in various directions. This function retrieves the [sequence](sequence) closest to a specific rotation.

A rotation of 0 radians corresponds to a character facing right. Positive values indicate counter-clockwise rotation.

## Usage

```lua
animation:sequence(rotation)
```

### Arguments

| Name       | Type     | Description                  |
| :--------- | :------- | :--------------------------- |
| `rotation` | `number` | Desired rotation in radians. |

### Returns

| Name       | Type                 | Description                                                             |
| :--------- | :------------------- | :---------------------------------------------------------------------- |
| `sequence` | [Sequence](sequence) | Closest available sequence, or `nil` if the animation has no sequences. |

## Examples

```lua
local spritesheet = crystal.assets.get("assets/sprites/hero.lua");
local walk = spritesheet:animation("walk");
local sequence = walk:sequence(math.pi / 2);
```
