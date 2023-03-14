---
parent: crystal.physics
grand_parent: API Reference
nav_exclude: true
---

# Body:detach_from_parent

Unlinks this entity from any parent it was attached to. This breaks the relationship created by [attach_to](body_attach_to).

## Usage

```lua
body:detach_from_parent()
```

## Examples

```lua
local ecs = crystal.ECS:new();
ecs:add_system(crystal.PhysicsSystem);

local hero = ecs:spawn(crystal.Entity);
hero:add_component(crystal.Body, "dynamic");

local backpack = ecs:spawn(crystal.Entity);
backpack:add_component(crystal.Body, "dynamic");
backpack:attach_to(hero);
backpack:detach_from_parent();
```
