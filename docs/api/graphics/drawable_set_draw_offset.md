---
parent: crystal.graphics
grand_parent: API Reference
nav_exclude: true
---

# Drawable:set_draw_offset

Returns the offset to use when drawing this drawable.

## Usage

```lua
drawable:set_draw_offset(x, y)
```

### Arguments

| Name | Type     | Description        |
| :--- | :------- | :----------------- |
| `x`  | `number` | Horizontal offset. |
| `y`  | `number` | Vertical offset.   |

## Examples

```lua
local ecs = crystal.ECS:new();
local entity = ecs:spawn(crystal.Entity);
local drawable = entity:add_component(crystal.Drawable);
drawable:set_draw_offset(10, 20);
print(drawable:draw_offset()); -- Prints "10 20"
```
