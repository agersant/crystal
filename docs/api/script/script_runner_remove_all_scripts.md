---
parent: crystal.script
grand_parent: API Reference
nav_exclude: true
---

# ScriptRunner:remove_all_scripts

Stops and removes all scripts on this `ScriptRunner`.

## Usage

```lua
script_runner:remove_all_scripts()
```

## Examples

```lua
local ecs = crystal.ECS:new();
local entity = ecs:spawn(crystal.Entity);
local script_runner = entity:add_component(crystal.ScriptRunner);

entity:add_script(function(self)
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
entity:remove_all_scripts(); -- prints "Goodbye"
entity:signal_all_scripts("visitor"); -- Nothing is printed
```
