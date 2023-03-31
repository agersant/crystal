---
parent: crystal.graphics
grand_parent: API Reference
nav_exclude: true
---

# WorldWidget:set_widget_anchor

Sets how to align the widget when drawing it.

The default anchor position is `(0.5, 0.5)`, which lines up the widget center with the Drawable position. A value of `(0, 0)` lines up the widget top-left with the Drawable position. A value of `(1, 1)` lines up the widget bottom-right with the Drawable position.

## Usage

```lua
world_widget:set_widget_anchor(x, y)
```

### Arguments

| Name | Type     | Description                                 |
| :--- | :------- | :------------------------------------------ |
| `x`  | `number` | X anchor position, usually between 0 and 1. |
| `y`  | `number` | Y anchor position, usually between 0 and 1. |

## Examples

```lua
local ecs = crystal.ECS:new();
local entity = ecs:spawn(crystal.Entity);
entity:add_component(crystal.WorldWidget, crystal.Widget:new());
entity:set_widget_anchor(0, 0);
```
