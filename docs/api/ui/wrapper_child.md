---
parent: crystal.ui
grand_parent: API Reference
nav_exclude: true
---

# Wrapper:child

Returns the child element of this wrapper, if any.

## Usage

```lua
wrapper:child()
```

### Returns

| Name            | Type                             | Description                                       |
| :-------------- | :------------------------------- | :------------------------------------------------ |
| `child_element` | [UIElement](ui_element) \| `nil` | Child element, or `nil` if no child has been set. |

## Examples

```lua
local rounded_corners = crystal.RoundedCorners:new();
local image = rounded_corners:set_child(crystal.Image:new());
assert(rounded_corners:child() == image);
```
