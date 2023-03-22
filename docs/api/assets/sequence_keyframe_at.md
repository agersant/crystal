---
parent: crystal.assets
grand_parent: API Reference
nav_exclude: true
---

# Sequence:keyframe_at

Retrieves the keyframe to play at a specific time. If the time value is greater than the sequence duration, the final keyframe will be returned.

This function will return `nil` if the sequence contains no keyframes.

## Usage

```lua
sequence:keyframe_at(time)
```

### Arguments

| Name   | Type     | Description             |
| :----- | :------- | :---------------------- |
| `time` | `number` | Time offset in seconds. |

### Returns

| Name       | Type    | Description                             |
| :--------- | :------ | :-------------------------------------- |
| `keyframe` | `table` | Information about the keyframe to play. |

The keyframe table contains the following members:

- `duration`: keyframe duration in seconds.
- `hitboxes`: a table where each key is a hitbox name, and the associated value is a [love.Shape](https://love2d.org/wiki/Shape).
- `quad`: a [love.Quad](https://love2d.org/wiki/Quad) framing the corresponding sprite in the spritesheet image.
- `x`: horizontal pixel offset to apply when displaying this frame.
- `y`: vertical pixel offset to apply when displaying this frame.

{: .warning}
For performance reasons, this function does not return copies of the underlying data. Modifications to `keyframe` tables will persist across calls (and are not recommended).

## Examples

```lua
local spritesheet = crystal.assets.get("assets/sprites/hero.lua");
local walk = spritesheet:animation("walk");
local sequence = walk:sequence(0);
local keyframe = sequence:keyframe_at(0.1);
print(keyframe.duration);
```
