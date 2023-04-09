---
parent: crystal.script
grand_parent: API Reference
---

# crystal.ScriptSystem

This ECS [System](system) powers [Behavior](behavior) and [ScriptRunner](script_runner) components.

When it receives the `run_scripts` [notification](/crystal/api/ecs/ecs_notify_systems), this system:

1. Registers or unregisters `Behavior` scripts with the corresponding `ScriptRunner` components.
2. Runs all scripts owned by `ScriptRunner` components.

## Examples

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
ecs:notify_systems("run_scripts"); -- prints Oink
```
