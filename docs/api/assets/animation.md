---
parent: crystal.assets
grand_parent: API Reference
nav_order: 2
---

# crystal.Animation

Animation within a [Spritesheet](spritesheet). An animation contains one or more [Sequence](sequence).

## Constructor

You cannot construct animations manually. Use [crystal.assets.get](get) to load a [Spritesheet](spritesheet) containing animations.

## Methods

| Name                               | Description                                                        |
| :--------------------------------- | :----------------------------------------------------------------- |
| [num_repeat](animation_num_repeat) | Returns how many times this animation plays before stopping.       |
| [sequence](animation_sequence)     | Retrieves a [sequence](sequence) by name.                          |

## Examples

```lua
local spritesheet = crystal.assets.get("assets/sprites/hero.json");
local walk = spritesheet:animation("walk");
local sequence = walk:sequence("W");
print(sequence:duration());
```
