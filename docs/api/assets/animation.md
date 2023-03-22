---
parent: crystal.assets
grand_parent: API Reference
nav_order: 2
---

# crystal.Animation

Animation within a [Spritesheet](spritesheet).

## Constructor

You cannot construct animations manually. Use [crystal.assets.get](get) to load a [Spritesheet](spritesheet) containing animations.

## Methods

| Name                               | Description                                                        |
| :--------------------------------- | :----------------------------------------------------------------- |
| [is_looping](animation_is_looping) | Returns whether this animation loops when it finishes.             |
| [sequence](animation_sequence)     | Retrieves the [sequence](sequence) closest to a specific rotation. |

## Examples

```lua
local spritesheet = crystal.assets.get("assets/sprites/hero.lua");
local walk = spritesheet:animation("walk");
local sequence = walk:sequence(0);
print(sequence:duration());
```
