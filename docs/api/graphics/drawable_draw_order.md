---
parent: crystal.graphics
grand_parent: API Reference
nav_exclude: true
---

# Drawable:draw_order

Returns the draw order of this Drawable.

## Usage

```lua
drawable:draw_order()
```

### Returns

| Name    | Type     | Description                  |
| :------ | :------- | :--------------------------- |
| `order` | `number` | Draw order of this drawable. |

## Examples

```lua
local ecs = crystal.ECS:new();
local entity = ecs:spawn(crystal.Entity);
local drawable = entity:add_component(crystal.Drawable);
drawable:set_draw_order_modifier("replace", 50);
print(drawable:draw_order()); -- Prints "50"
```
