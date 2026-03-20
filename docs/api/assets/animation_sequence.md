---
parent: crystal.assets
grand_parent: API Reference
nav_exclude: true
---

# Animation:sequence

Retrieves a [Sequence](sequence) by name.

## Usage

```lua
animation:sequence(name)
```

### Arguments

| Name   | Type     | Description                                                                                                   |
| :------| :------- | :------------------------------------------------------------------------------------------------------------ |
| `name` | `string` | Name of the sequence to look for. If the animation contains a single sequence, this parameter may be omitted. |

### Returns

| Name       | Type                 | Description                    |
| :--------- | :------------------- | :----------------------------- |
| `sequence` | [Sequence](sequence) | Sequence with a matching name. |

## Examples

```lua
local spritesheet = crystal.assets.get("assets/sprites/hero.json");
local walk = spritesheet:animation("walk");
local sequence = walk:sequence("N");
```
