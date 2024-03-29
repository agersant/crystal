---
parent: crystal.graphics
grand_parent: API Reference
nav_exclude: true
---

# AnimatedSprite:hitbox

Returns a named hitbox from the current [animation frame](/crystal/api/assets/sequence_keyframe_at).

## Usage

```lua
animated_sprite:hitbox(name)
```

### Arguments

| Name   | Type     | Description  |
| :----- | :------- | :----------- |
| `name` | `string` | Hitbox name. |

### Returns

| Name     | Type                                        | Description                                                                                       |
| :------- | :------------------------------------------ | :------------------------------------------------------------------------------------------------ |
| `hitbox` | [love.Shape](https://love2d.org/wiki/Shape) | Hitbox with the desired name in the current [keyframe](/crystal/api/assets/sequence_keyframe_at). |

## Examples

This example defines an ECS [System](/crystal/api/ecs/system) which adds [Sensor](/crystal/api/physics/sensor) components to entities according to the hitboxes in their animations.

```lua
local AttackHitboxes = Class("AttackHitboxes", crystal.System);

AttackHitboxes.init = function(self)
  self.query = self:add_query({ crystal.Body, crystal.AnimatedSprite });
end

AttackHitboxes.update_hitboxes = function(self)
  for entity in pairs(self.query:entities()) do
    if entity:is_valid() then
      for hitbox in pairs(entity:components(crystal.Sensor)) do
        entity:remove_component(hitbox);
      end
      local animated_sprite = entity:component(crystal.AnimatedSprite);
      local shape = animated_sprite:hitbox("attack_hitbox");
      if shape then
        local hitbox = entity:add_component(crystal.Sensor, shape);
        self:set_categories("hitbox");
      end
    end
  end
end
```
