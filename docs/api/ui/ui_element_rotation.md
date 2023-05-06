---
parent: crystal.ui
grand_parent: API Reference
nav_exclude: true
---

# UIElement:rotation

Returns this element's rotation.

## Usage

```lua
ui_element:rotation()
```

### Returns

| Name    | Type     | Description                |
| :------ | :------- | :------------------------- |
| `angle` | `number` | Rotation angle in radians. |

## Examples

```lua
local image = crystal.Image:new(crystal.assets.get("sword.png"));
image:set_rotation(math.pi);
print(image:rotation()); -- Prints "3.1415..."
```
