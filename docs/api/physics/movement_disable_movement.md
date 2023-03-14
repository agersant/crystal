---
parent: crystal.physics
grand_parent: API Reference
nav_exclude: true
---

# Movement:disable_movement

Prevents this component from affecting entity physics.

The return value of this function can be used to call [enable_movement](movement_enable_movement) with no arguments. This is especially useful when combined with [Thread:defer](/crystal/api/script/thread_defer) to never accidentally leave movement disabled. For example, inside a [Behavior](/crystal/api/script/behavior) script:

```lua
self:thread(function(self)
  -- Disables movement for 2 seconds
  self:defer(self:disable_movement());
  self:wait(2);
end);
```

## Usage

```lua
movement:disable_movement()
```

### Returns

| Name              | Type         | Description                                                      |
| :---------------- | :----------- | :--------------------------------------------------------------- |
| `enable_function` | `function()` | A function you can call with no arguments to re-enable movement. |

## Examples

```lua
local ecs = crystal.ECS:new();
ecs:add_system(crystal.PhysicsSystem);

local entity = ecs:spawn(crystal.Entity);
entity:add_component(crystal.Body);
entity:add_component(crystal.Movement);

entity:set_speed(100);
entity:set_heading(0.5 * math.pi);
entity:disable_movement(); -- Entity will no longer move, no matter its speed and heading

ecs:update();
ecs:notify_systems("simulate_physics");
print(entity:position()); -- Prints "0 0'
```
