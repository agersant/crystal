---
parent: crystal.ui
grand_parent: API Reference
nav_exclude: true
---

# UIElement:color

Returns this element's color multiplier. The alpha component of the returned color is always 1.

## Usage

```lua
ui_element:color()
```

### Returns

| Name         | Type                                 | Description       |
| :----------- | :----------------------------------- | :---------------- |
| `multiplier` | [Color](/crystal/api/graphics/color) | Color multiplier. |

## Examples

```lua
local image = crystal.Image:new(crystal.assets.get("sword.png"));
image:set_color(crystal.Color.blue_martina);
love.graphics.setColor(image:color());
love.graphics.circle("fill", 100, 100, 20);
```
