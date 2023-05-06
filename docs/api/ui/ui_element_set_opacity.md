---
parent: crystal.ui
grand_parent: API Reference
nav_exclude: true
---

# UIElement:set_opacity

Sets this element's color opacity. Opacity values are applied multiplicatively throughout the hierarchy of elements. This means an element's final opacity is the product of all its ancestors color multipliers and its own.

Elements have an opacity of `1` by default.

## Usage

```lua
ui_element:set_opacity(new_opacity)
```

### Arguments

| Name          | Type     | Description                          |
| :------------ | :------- | :----------------------------------- |
| `new_opacity` | `number` | Element opacity between `0` and `1`. |

## Examples

```lua
local image = crystal.Image:new(crystal.assets.get("sword.png"));
image:set_opacity(0.5); -- Half-transparent
```
