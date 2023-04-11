---
parent: crystal.script
grand_parent: API Reference
nav_exclude: true
---

# ScriptSystem:run_scripts

Runs all scripts owned by [ScriptRunner](script_runner) components. This implies:

1. Registering or unregistering [Behavior](behavior) scripts with the corresponding `ScriptRunner` components.
2. Running all scripts owned by `ScriptRunner` components.

## Usage

```lua
script_system:run_scripts(delta_time)
```

### Arguments

| Name         | Type     | Description                                     |
| :----------- | :------- | :---------------------------------------------- |
| `delta_time` | `number` | Time elapsed sinced last time scripts were ran. |

## Examples

```lua
local MyScene = Class("MyScene", crystal.Scene);

MyScene.init = function(self)
  self.ecs = crystal.ECS:new();
  self.script_system = self.ecs:add_system(crystal.ScriptSystem);
end

MyScene.update = function(self, delta_time)
  self.script_system:run_scripts(delta_time);
end
```
