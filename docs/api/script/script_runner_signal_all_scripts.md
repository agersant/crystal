---
parent: crystal.script
grand_parent: API Reference
nav_exclude: true
---

# ScriptRunner:signal_all_scripts

Sends a signal to every script owned by this `ScriptRunner`. This will stop all script threads that previously called [Thread:stop_on](thread_stop_on) for this signal, and resume execution of all threads that were waiting on this signal via [Thread:wait_for](thread_wait_for).

Additional arguments passed to this function will be received by threads that were waiting on this signal.

See also: [Script:signal](script_signal).

## Usage

```lua
script_runner:signal_all_scripts(signal_name, ...)
```

### Arguments

| Name          | Type     | Description                                                     |
| :------------ | :------- | :-------------------------------------------------------------- |
| `signal_name` | `string` | Signal to emit.                                                 |
| `...`         | `any`    | Values that will be received by threads waiting for the signal. |

## Examples

```lua
local ecs = crystal.ECS:new();
local entity = ecs:spawn(crystal.Entity);
local script_runner = entity:add_component(crystal.ScriptRunner);

entity:add_script(function(self)
  self:stop_on("bye");
  while true do
    local name = self:wait_for("greet");
    print("Hello " .. name);
  end
end);

script_runner:update(0); -- Runs the script until the `wait_for` statement
entity:signal_all_scripts("greet", "Alvina"); -- prints "Hello Alvina"
entity:signal_all_scripts("greet", "Tarkus"); -- prints "Hello Tarkus"
entity:signal_all_scripts("bye");
entity:signal_all_scripts("greet", "Ricard"); -- nothing is printed
```
