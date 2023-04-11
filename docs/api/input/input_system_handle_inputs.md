---
parent: crystal.input
grand_parent: API Reference
nav_exclude: true
---

# InputSystem:handle_inputs

Runs all [input handlers](input_listener_add_input_handler).

## Usage

```lua
input_system:handle_inputs()
```

## Examples

```lua
local MyScene = Class("MyScene", crystal.Scene);

MyScene.init = function(self)
  self.ecs = crystal.ECS:new();
  self.input_system = self.ecs:add_system(crystal.InputSystem);
end

MyScene.update = function(self, delta_time)
  self.input_system:handle_inputs();
end
```
