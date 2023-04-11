---
parent: crystal.script
grand_parent: API Reference
---

# crystal.ScriptSystem

This ECS [System](system) powers [Behavior](behavior) and [ScriptRunner](script_runner) components.

## Methods

| Name                                     | Description                                          |
| :--------------------------------------- | :--------------------------------------------------- |
| [run_scripts](script_system_run_scripts) | Runs all scripts owned by `ScriptRunner` components. |

## Examples

```lua
local ecs = crystal.ECS:new();
local script_system = ecs:add_system(crystal.ScriptSystem);

local entity = ecs:spawn(crystal.Entity);
entity:add_component(crystal.ScriptRunner);
entity:add_script(function(self)
  print("Oink");
end);

-- In your scene's update function:
ecs:update();
script_system:run_scripts(); -- prints Oink
```
