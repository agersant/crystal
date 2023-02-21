---
parent: crystal.script
grand_parent: API Reference
nav_exclude: true
---

# ScriptRunner:add_script

Adds a new [Script](script) to this `ScriptRunner`.

## Usage

```lua
script_runner:add_script(script)
```

### Arguments

| Name     | Type                           | Description                                                                             |
| :------- | :----------------------------- | :-------------------------------------------------------------------------------------- |
| `script` | [Script](script) or `function` | Either a fully constructed script, or a function that will be used to create a new one. |

When passing in a function as the `script` argument, the function should expect one argument: the `Thread` that is running it.

### Returns

| Name     | Type             | Description            |
| :------- | :--------------- | :--------------------- |
| `script` | [Script](script) | Script that was added. |

## Examples

Using a function as `script` argument:

```lua
local ecs = crystal.ECS:new();
local entity = ecs:spawn(crystal.Entity);
entity:add_component(crystal.ScriptRunner);

entity:add_script(function(self)
  while true do
    print("Hello");
	self:wait(1);
  end
end);
```

Constructing a [Script](script) yourself instead:

```lua
local ecs = crystal.ECS:new();
local entity = ecs:spawn(crystal.Entity);
entity:add_component(crystal.ScriptRunner);

local script = crystal.Script:new(function(self)
  while true do
    print("Hello");
	self:wait(1);
  end
end);

entity:add_script(script);
```
