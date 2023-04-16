---
parent: crystal.scene
grand_parent: API Reference
nav_exclude: true
---

# Transition:easing

Returns the easing function used to smooth the transition.

## Usage

```lua
transition:easing()
```

### Arguments

| Name              | Type       | Description      |
| :---------------- | :--------- | :--------------- |
| `easing_function` | `function` | Easing function. |

## Examples

```lua
local fade = crystal.Transition.FadeToBlack:new(0.5, math.ease_in_cubic);
assert(fade:easing() == math.ease_in_cubic);
```
