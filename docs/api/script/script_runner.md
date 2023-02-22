---
parent: crystal.script
grand_parent: API Reference
---

# crystal.ScriptRunner

As its name implies, `ScriptRunner` is a component which allows an entity to run [scripts](script). Entities should have at most one `ScriptRunner` component. Scripts can be added or removed throughout the lifetime of the entity.

This component is designed to work in tandem with a [ScriptSystem](script_system).

If you want to re-use the same script on multiple entities, you can define a [Behavior](behavior) component instead of manually adding scripts to a `ScriptRunner`.

{: .note}
Scripts added to a `ScriptRunner` transparently have access to all methods of the entity owning the `ScriptRunner`, and to all methods of its components.

## Constructor

Like all other components, ScriptRunners are created by calling [Entity:add_component](/crystal/api/ecs/entity_add_component).

## Methods

| Name                                                   | Description                              |
| :----------------------------------------------------- | :--------------------------------------- |
| [add_script](script_runner_add_script)                 | Adds a new script.                       |
| [remove_all_scripts](script_runner_remove_all_scripts) | Stops and removes all scripts.           |
| [remove_script](script_runner_remove_script)           | Stops and removes a specific script.     |
| [run_all_scripts](script_runner_run_all_scripts)       | Runs all scripts until they are blocked. |
| [signal_all_scripts](script_runner_signal_all_scripts) | Sends a signal to all scripts.           |

## Examples

```lua
local ecs = crystal.ECS:new();
local entity = ecs:spawn(crystal.Entity);
local script_runner = entity:add_component(crystal.ScriptRunner);

entity:add_script(function(self)
  while true do
    local name = self:wait_for("greet");
    print("Hello " .. name);
  end
end);

script_runner:update(0); -- Runs the script until the `wait_for` statement
entity:signal_all_scripts("greet", "Alvina"); -- prints "Hello Alvina"
entity:signal_all_scripts("greet", "Tarkus"); -- prints "Hello Tarkus"
```
