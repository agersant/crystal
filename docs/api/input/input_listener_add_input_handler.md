---
parent: crystal.input
grand_parent: API Reference
nav_exclude: true
---

# InputListener:add_input_handler

Registers a function to handle input events.

When this component handles an input, handlers are called in reverse-order from how they were registered. If any handler function returns `true`, additional handlers are not called.

The return value of this function can be used to remove an input handler. This is especially useful when combined with [Thread:defer](/crystal/api/script/thread_defer) to guarantee you never forget to remove an input handler. For example, inside a [Behavior](/crystal/api/script/behavior) script:

```lua
self:defer(self:add_input_handler(function(event)
  if event == "+my_action" then
    self:signal(event);
    return true;
  end
end));

while true do
  self:wait_for("+my_action");
  -- implement my_action
end
```

## Usage

```lua
input_listener:add_input_handler(handler)
```

### Arguments

| Name      | Type                               | Description                                                                       |
| :-------- | :--------------------------------- | :-------------------------------------------------------------------------------- |
| `handler` | `function(event: string): boolean` | Function that will be called by [InputSystem](input_system) for each input event. |

### Returns

| Name              | Type         | Description                                           |
| :---------------- | :----------- | :---------------------------------------------------- |
| `remove_function` | `function()` | A function you can call to remove this input handler. |

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
