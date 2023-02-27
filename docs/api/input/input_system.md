---
parent: crystal.input
grand_parent: API Reference
---

# crystal.InputSystem

This ECS [System](system) powers [InputListener](input_listener) components.

When it receives the `handle_inputs` [notification](/crystal/api/ecs/ecs_notify_systems), every [InputListener](input_listener) dispatches events to its [handlers](input_listener_add_input_handler).

## Examples

```lua
crystal.input.player(1):set_bindings({
  space = { "jump" }
});

local ecs = crystal.ECS:new();
ecs:add_system(crystal.InputSystem);

local entity = ecs:spawn(crystal.Entity);
entity:add_component(crystal.InputListener);
entity:add_input_handler(function(event)
  print(event);
  return false;
end);

love.keypressed("space", "space", false);
ecs:update();
ecs:notify_systems("handle_inputs"); -- Prints "+jump"

love.keyreleased("space", "space", false);
ecs:update();
ecs:notify_systems("handle_inputs"); -- Prints "-jump"
```
