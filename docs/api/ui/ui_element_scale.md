---
parent: crystal.ui
grand_parent: API Reference
nav_exclude: true
---

# UIElement:scale

Returns this element's scaling factors.

## Usage

```lua
ui_element:scale()
```

### Returns

| Name               | Type     | Description                |
| :----------------- | :------- | :------------------------- |
| `horizontal_scale` | `number` | Horizontal scaling factor. |
| `vertical_scale`   | `number` | Vertical scaling factor.   |

## Examples

```lua
local image = crystal.Image:new(crystal.assets.get("sword.png"));
image:set_scale(0.5, 0.75);
print(image:scale()); -- Prints "0.5, .075"
```
