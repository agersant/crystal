---
parent: crystal.ui
grand_parent: API Reference
nav_exclude: true
---

# UIElement:set_translation

Sets this element's translation.

Translation does not affect an element's layout, it is only a visual effect.

## Usage

```lua
ui_element:set_translation(offset_x, offset_y)
```

### Arguments

| Name       | Type     | Description               |
| :--------- | :------- | :------------------------ |
| `offset_x` | `number` | Horizontal offset amount. |
| `offset_y` | `number` | Vertical offset amount.   |

## Examples

```lua
local image = crystal.Image:new(crystal.assets.get("sword.png"));
image:set_translation(20, 10);
```
