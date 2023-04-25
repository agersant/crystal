---
parent: crystal.input
grand_parent: API Reference
nav_order: 2
---

# crystal.InputSystem

This ECS [System](system) powers [InputListener](input_listener) components.

## Methods

| Name                                      | Description                                                                         |
| :---------------------------------------- | :---------------------------------------------------------------------------------- |
| [handle_input](input_system_handle_input) | Routes an input to the relevant [input handlers](input_listener_add_input_handler). |

## Examples

```lua
local ecs = crystal.ECS:new();
local input_system = ecs:add_system(crystal.InputSystem);

local entity = ecs:spawn(crystal.Entity);
entity:add_component(crystal.InputListener, 1);
entity:add_input_handler(function(input)
  print(input);
  return false;
end);

ecs:update();
input_system:handle_input(1, "+jump"); -- Prints "+jump"
```
