---
parent: crystal.scene
grand_parent: API Reference
nav_exclude: true
---

# Transition:duration

Returns the duration of the transition, in seconds.

## Usage

```lua
transition:duration()
```

### Arguments

| Name       | Type     | Description           |
| :--------- | :------- | :-------------------- |
| `duration` | `number` | Duration, in seconds. |

## Examples

```lua
local fade = crystal.Transition.FadeToBlack:new(0.5, math.ease_in_cubic);
print(fade:duration()); -- Prints "0.5"
```
