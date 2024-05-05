---
parent: crystal.input
grand_parent: API Reference
nav_order: 2
---

# crystal.InputListener

A [Component](/crystal/api/ecs/component) which allows an entity to receive input events.

## Constructor

Like all other components, InputListener components are created by calling [Entity:add_component](/crystal/api/ecs/entity_add_component).

The constructor for InputListener expects one argument, the [player_index](player) whose inputs this component should listen to.

## Methods

| Name                                                        | Description                                                        |
| :---------------------------------------------------------- | :----------------------------------------------------------------- |
| [add_input_handler](input_listener_add_input_handler)       | Registers a function to handle input events.                       |
| [handle_input](input_listener_handle_input)                 | Calls input handlers.                                              |
| [player_index](input_listener_player_index)                 | Returns the player index whose inputs this components responds to. |
| [remove_input_handler](input_listener_remove_input_handler) | Unregisters a function handling input events.                      |

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
input_system:handle_input("+jump"); -- Prints "+jump"
```
