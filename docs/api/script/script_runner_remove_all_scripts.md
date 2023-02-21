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

## Example

```lua
local ecs = crystal.ECS:new();
local entity = ecs:spawn(crystal.Entity);
entity:add_component(crystal.ScriptRunner);

entity:add_script(function(self)
  self:defer(function(self)
    print("Goodbye");
  end);
  while true do
    self:wait_for("visitor");
    print("Hello");
  end
end);

entity:signal_all_scripts("visitor"); -- prints "Hello"
entity:signal_all_scripts("visitor"); -- prints "Hello"
entity:remove_all_scripts(); -- prints "Goodbye"
entity:signal_all_scripts("visitor"); -- Nothing is printed
```
