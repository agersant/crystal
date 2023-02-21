---
parent: crystal.script
grand_parent: API Reference
---

# crystal.ScriptSystem

This ECS [System](system) powers [Behavior](behavior) and [ScriptRunner](script_runner) components.

When it receives the `before_scripts` [notification](/crystal/api/ecs/ecs_notify_systems), this system ensures all `Behavior` scripts are present on entities' `ScriptRunner` components.

When it receives the `during_scripts` [notification](/crystal/api/ecs/ecs_notify_systems), this systems runs all scripts owned by `ScriptRunner` components.

## Example

```lua
local ecs = crystal.ECS:new();
ecs:add_system(crystal.ScriptSystem);

local entity = ecs:spawn(crystal.Entity);
entity:add_component(crystal.ScriptRunner);
entity:add_script(function(self)
	print("Oink");
end);

-- In your scene's update function:
ecs:update();
ecs:notify_systems("before_scripts");
ecs:notify_systems("during_scripts"); -- prints Oink
```
