---
parent: crystal.ui
grand_parent: API Reference
nav_exclude: true
---

# UIElement:set_scale_x

Sets this element's horizontal scaling factor.

Scaling does not affect an element's layout, it is only a visual effect.

## Usage

```lua
ui_element:set_scale_x(scale)
```

### Arguments

| Name    | Type     | Description     |
| :------ | :------- | :-------------- |
| `scale` | `number` | Scaling factor. |

## Examples

```lua
local image = crystal.Image:new(crystal.assets.get("sword.png"));
image:set_scale_x(0.5);
```
