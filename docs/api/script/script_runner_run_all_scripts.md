---
parent: crystal.script
grand_parent: API Reference
nav_exclude: true
---

# ScriptRunner:run_all_scripts

Runs each script owned by this `ScriptRunner` until it terminates, gets blocked, or gets stopped. Scripts get blocked when they run into statements that cannot be resolved immediately, like [Thread:wait](thread_wait), [Thread:wait_for](thread_wait_for), [Thread:join](thread_join).

This function does not run scripts that are added during its execution.

{: .warning}
Instead of calling this function yourself, you can add a [ScriptSystem](script_system) to your [ECS](ecs).

## Usage

```lua
script_runner:run_all_scripts(delta_time)
```

### Arguments

| Name         | Type     | Description                                |
| :----------- | :------- | :----------------------------------------- |
| `delta_time` | `number` | Time in seconds to advance the scripts by. |

## Example

```lua
local ecs = crystal.ECS:new();
local entity = ecs:spawn(crystal.Entity);
entity:add_component(crystal.ScriptRunner);

entity:add_script(function(self)
  self:wait(1);
  print("Hello");
end);

entity:run_all_scripts(0.4); -- 0.6s remaining to wait
entity:run_all_scripts(0.4); -- 0.2s remaining to wait
entity:run_all_scripts(0.4); -- prints "Hello"
```
