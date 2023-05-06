---
parent: crystal.ui
grand_parent: API Reference
nav_exclude: true
---

# UIElement:set_color

Sets this element's color multiplier. Colors values are applied multiplicatively throughout the hierarchy of elements. This means an element's final color multiplier is the product of all its ancestors color multipliers and its own.

Elements have a neutral color multiplier of `crystal.Color.white` by default.

## Usage

```lua
ui_element:set_color(new_color)
```

### Arguments

| Name        | Type                                 | Description       |
| :---------- | :----------------------------------- | :---------------- |
| `new_color` | [Color](/crystal/api/graphics/color) | Color multiplier. |

## Examples

```lua
local image = crystal.Image:new(crystal.assets.get("sword.png"));
image:set_color(crystal.Color.blue_martina);
```
