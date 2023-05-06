---
parent: crystal.ui
grand_parent: API Reference
nav_exclude: true
---

# UIElement:translation

Returns this element's translation.

## Usage

```lua
ui_element:translation()
```

### Returns

| Name       | Type     | Description               |
| :--------- | :------- | :------------------------ |
| `offset_x` | `number` | Horizontal offset amount. |
| `offset_y` | `number` | Vertical offset amount.   |

## Examples

```lua
local image = crystal.Image:new(crystal.assets.get("sword.png"));
image:set_translation(20, 10);
print(image:translation()); -- Prints "20, 10"
```
