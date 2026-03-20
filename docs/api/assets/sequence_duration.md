---
parent: crystal.assets
grand_parent: API Reference
nav_exclude: true
---

# Sequence:duration

Returns the duration of this sequence in seconds.

## Usage

```lua
sequence:duration()
```

### Returns

| Name       | Type     | Description          |
| :--------- | :------- | :------------------- |
| `duration` | `number` | Duration in seconds. |

## Examples

```lua
local spritesheet = crystal.assets.get("assets/sprites/hero.json");
local walk = spritesheet:animation("walk");
local sequence = walk:sequence("N");
print(sequence:duration());
```
