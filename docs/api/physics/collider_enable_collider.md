---
parent: crystal.physics
grand_parent: API Reference
nav_exclude: true
---

# Collider:enable_collider

Allows this collider to collide with others.

## Usage

```lua
collider:enable_collider()
```

## Examples

```lua
local ecs = crystal.ECS:new();
ecs:add_system(crystal.PhysicsSystem);

local hero = ecs:spawn(crystal.Entity);
hero:add_component(crystal.Body);
hero:add_component(crystal.Collider, love.physics.newCircleShape(4));
hero:set_categories("characters");
hero:enable_collision_with("level", "characters");

hero.set_ghost_mode_enabled = function(self, enabled)
  if enabled then
    self:disable_collider();
  else
    self:enable_collider();
  end
end
```
