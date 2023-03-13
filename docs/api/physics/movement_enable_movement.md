---
parent: crystal.physics
grand_parent: API Reference
nav_exclude: true
---

# Movement:enable_movement

Allows this component to affect entity physics. This method is the opposite of [disable_movement](movement_disable_movement).

## Usage

```lua
movement:enable_movement()
```

## Examples

This example creates an entity that is unable to move for 1 second after it spawns.

```lua
local ecs = crystal.ECS:new();
ecs:add_system(crystal.PhysicsSystem);
ecs:add_system(crystal.ScriptSystem);

local entity = ecs:spawn(crystal.Entity);
entity:add_component(crystal.Body, "dynamic");
entity:add_component(crystal.Movement);
entity:add_component(crystal.ScriptRunner);
entity:disable_movement();
entity:add_script(function(self)
  self:wait(1);
  self:enable_movement();
end);
```
