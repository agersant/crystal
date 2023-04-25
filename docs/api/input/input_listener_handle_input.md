---
parent: crystal.input
grand_parent: API Reference
nav_exclude: true
---

# InputListener:handle_input

Calls input handlers. Handlers are called in reverse-order from how they were registered. If any handler function returns `true`, additional handlers are not called.

{: .warning}
Instead of calling this function yourself, you can add an [InputSystem](input_system) to your [ECS](ecs) and call its `handle_input` method.

## Usage

```lua
input_listener:handle_input(input)
```

### Arguments

| Name    | Type     | Description                |
| :------ | :------- | :------------------------- |
| `input` | `string` | Input event (eg. `+jump`). |

## Examples

```lua
local ecs = crystal.ECS:new();
local entity = ecs:spawn(crystal.Entity);
entity:add_component(crystal.InputListener, 1);
entity:add_input_handler(function(input)
  print(input);
  return false;
end);

entity:handle_input("+jump"); -- Prints "+jump"
```
