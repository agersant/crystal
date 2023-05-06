---
parent: crystal.ui
grand_parent: API Reference
nav_exclude: true
---

# UIElement:set_rotation

Sets this element's rotation angle. Rotation is always applied around the element's [pivot](ui_element_pivot).

Rotation does not affect an element's layout, it is only a visual effect.

## Usage

```lua
ui_element:set_rotation(angle)
```

### Arguments

| Name    | Type     | Description                |
| :------ | :------- | :------------------------- |
| `angle` | `number` | Rotation angle in radians. |

## Examples

```lua
local image = crystal.Image:new(crystal.assets.get("sword.png"));
image:set_rotation(math.pi);
print(image:rotation()); -- Prints "3.1415..."
```
