---
parent: crystal.graphics
grand_parent: API Reference
nav_exclude: true
---

# Drawable:set_draw_order_modifier

Sets how the draw order of this Drawable is computed.

When the modifier is set to `"replace"`, the [DrawOrder](draw_order) component on the entity is ignored. The draw order is entirely determined by the `value` parameter specified in this function call.

When the modifier is set to `"add"`, the `value` parameter specified in this function call is added to the draw order specified by the [DrawOrder](draw_order) component on the entity. If the entity has no [DrawOrder](draw_order) component, the `value` parameter is used as-is.

## Usage

```lua
drawable:set_draw_order_modifier(modifier, value)
```

### Arguments

| Name       | Type                   | Description                               |
| :--------- | :--------------------- | :---------------------------------------- |
| `modifier` | `"add"` or `"replace"` | Modifier type to apply to the draw order. |
| `value`    | `number`               | Value used when computing the draw order. |

## Examples

```lua
local ecs = crystal.ECS:new();
local entity = ecs:spawn(crystal.Entity);
entity:add_component(crystal.Sprite, crystal.assets.get("wild_boar.png"));
local health_bar = entity:add_component(crystal.WorldWidget, HealthBar:new());
health_bar:set_draw_order_modifier("replace", math.huge); -- Draw health bar in front of everything
```

```lua
local ecs = crystal.ECS:new();
local entity = ecs:spawn(crystal.Entity);
local body = entity:add_component(crystal.Sprite, crystal.assets.get("human_body.png"));
local head = entity:add_component(crystal.Sprite, crystal.assets.get("human_head.png"));
local weapon = entity:add_component(crystal.Sprite, crystal.assets.get("sword.png"));
body:set_draw_order_modifier("add", 0);
head:set_draw_order_modifier("add", 0.1); -- Head draws in front of body
weapon:set_draw_order_modifier("add", 0.2); -- Weapon draws in front of head
```
