---
parent: crystal.input
grand_parent: API Reference
nav_order: 1
---

# crystal.InputListener

A [Component](/crystal/api/ecs/component) which allows an entity to receive input events.

## Constructor

Like all other components, InputListener are created by calling [Entity:add_component](/crystal/api/ecs/entity_add_component).

## Methods

| Name                                                        | Description                                                                                   |
| :---------------------------------------------------------- | :-------------------------------------------------------------------------------------------- |
| [input_player](input_listener_input_player)                 | Returns the [InputPlayer](input_player) associated with this InputListener.                   |
| [add_input_handler](input_listener_add_input_handler)       | Registers a function to handle input events.                                                  |
| [remove_input_handler](input_listener_remove_input_handler) | Unregisters a function handling input events.                                                 |
| [handle_inputs](input_listener_handle_inputs)               | Executes handler callbacks for all events held by the associated [InputPlayer](input_player). |

## Examples

```lua
crystal.input.player(1):set_bindings({
  space = { "jump" }
});

local ecs = crystal.ECS:new();
ecs:add_system(crystal.InputSystem);

local entity = ecs:spawn(crystal.Entity);
entity:add_component(crystal.InputListener, 1);
entity:add_input_handler(function(event)
  print(event);
  return false;
end);

ecs:update();
love.keypressed("space", "space", false);
ecs:notify_systems("handle_inputs"); -- Prints "+jump"
```
