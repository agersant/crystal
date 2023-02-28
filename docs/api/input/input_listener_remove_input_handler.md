---
parent: crystal.input
grand_parent: API Reference
nav_exclude: true
---

# InputListener:remove_input_handler

Unregisters a function handling input events.

{: .note}
[InputListener:add_input_handler](input_listener_add_input_handler) returns a more convenient function you can call without arguments to remove a handler.

## Usage

```lua
input_listener:remove_input_handler(handler)
```

### Arguments

| Name      | Type                               | Description        |
| :-------- | :--------------------------------- | :----------------- |
| `handler` | `function(event: string): boolean` | Handler to remove. |

## Examples

```lua
local ecs = crystal.ECS:new();

local my_handler = function(event)
  print(event);
  return false;
end

local entity = ecs:spawn(crystal.Entity);
entity:add_component(crystal.InputListener, 1);
entity:add_input_handler(my_handler);
entity:remove_input_handler(my_handler);
```
