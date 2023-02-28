---
parent: crystal.input
grand_parent: API Reference
nav_exclude: true
---

# InputListener:handle_inputs

Executes [handler](input_listener_add_input_handler) callbacks for all events held by the associated [InputPlayer](input_player). The events are processed in the order they were emitted.

{: .warning}
Instead of calling this function yourself, you can add an [InputSystem](input_system) to your [ECS](ecs).

## Usage

```lua
input_listener:handle_inputs()
```

## Examples

```lua
crystal.input.player(1):set_bindings({
  space = { "jump" }
});

local ecs = crystal.ECS:new();
local entity = ecs:spawn(crystal.Entity);
entity:add_component(crystal.InputListener, 1);
entity:add_input_handler(function(event)
  print(event);
  return false;
end);

love.keypressed("space", "space", false);
entity:handle_inputs(); -- Prints "+space"
```
