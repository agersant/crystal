---
parent: crystal.ui
grand_parent: API Reference
nav_exclude: true
---

# UIElement:set_scale

Sets this element's scaling factors. Scaling is always applied around the element's [pivot](ui_element_pivot).

Scaling does not affect an element's layout, it is only a visual effect.

## Usage

```lua
ui_element:set_scale(scale_x, scale_y)
```

### Arguments

| Name      | Type     | Description                |
| :-------- | :------- | :------------------------- |
| `scale_x` | `number` | Horizontal scaling factor. |
| `scale_y` | `number` | Vertical scaling factor.   |

## Examples

```lua
local image = crystal.Image:new(crystal.assets.get("sword.png"));
image:set_scale(0.5, 0.75);
print(image:scale()); -- Prints "0.5, .075"
```
