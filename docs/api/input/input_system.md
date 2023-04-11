---
parent: crystal.input
grand_parent: API Reference
nav_order: 2
---

# crystal.InputSystem

This ECS [System](system) powers [InputListener](input_listener) components.

## Methods

| Name                                        | Description                                                  |
| :------------------------------------------ | :----------------------------------------------------------- |
| [handle_inputs](input_system_handle_inputs) | Runs all [input handlers](input_listener_add_input_handler). |

## Examples

```lua
crystal.input.player(1):set_bindings({
  space = { "jump" }
});

local ecs = crystal.ECS:new();
local input_system = ecs:add_system(crystal.InputSystem);

local entity = ecs:spawn(crystal.Entity);
entity:add_component(crystal.InputListener, 1);
entity:add_input_handler(function(event)
  print(event);
  return false;
end);

ecs:update();
love.keypressed("space", "space", false);
input_system:handle_inputs(); -- Prints "+jump"
```
