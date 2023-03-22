---
parent: crystal.assets
grand_parent: API Reference
nav_order: 2
---

# crystal.Sequence

Sequence within an [Animation](animation).

## Constructor

You cannot construct sequences manually. Use [crystal.assets.get](get) to load a [Spritesheet](spritesheet) containing animations and sequences.

## Methods

| Name                                | Description                                        |
| :---------------------------------- | :------------------------------------------------- |
| [duration](sequence_duration)       | Returns the duration of this sequence in seconds.  |
| [keyframe_at](sequence_keyframe_at) | Retrieves the keyframe to play at a specific time. |

## Examples

```lua
local spritesheet = crystal.assets.get("assets/sprites/hero.lua");
local walk = spritesheet:animation("walk");
local sequence = walk:sequence(0);
print(sequence:duration());
```
