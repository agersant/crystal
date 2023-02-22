---
parent: crystal.script
grand_parent: API Reference
nav_exclude: true
---

# ScriptRunner:remove_script

Stops and removes a [Script](script) from this `ScriptRunner`.

## Usage

```lua
script_runner:remove_script(script)
```

### Arguments

| Name     | Type             | Description                |
| :------- | :--------------- | :------------------------- |
| `script` | [Script](script) | Script to stop and remove. |

When passing in a function as the `script` argument, the function should expect one argument: the `Thread` that is running it.

## Examples

```lua
local ecs = crystal.ECS:new();
local entity = ecs:spawn(crystal.Entity);
local script_runner = entity:add_component(crystal.ScriptRunner);

local hello_goodbye = entity:add_script(function(self)
  self:defer(function(self)
    print("Goodbye");
  end);
  while true do
    self:wait_for("visitor");
    print("Hello");
  end
end);

script_runner:update(0); -- Runs the script until the `wait_for` statement
entity:signal_all_scripts("visitor"); -- prints "Hello"
entity:signal_all_scripts("visitor"); -- prints "Hello"
entity:remove_script(hello_goodbye); -- prints "Goodbye"
entity:signal_all_scripts("visitor"); -- nothing is printed
```
