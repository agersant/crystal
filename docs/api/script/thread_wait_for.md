---
parent: crystal.script
grand_parent: API Reference
nav_exclude: true
---

# Thread:wait_for

Blocks this thread until its parent [Script](script) receives a specific signal.

## Usage

```lua
thread:wait_for(signal)
```

### Arguments

| Name      | Type     | Description        |
| :-------- | :------- | :----------------- |
| `signals` | `string` | Signal to wait on. |

### Returns

| Name  | Type  | Description                                                                                  |
| :---- | :---- | :------------------------------------------------------------------------------------------- |
| `...` | `any` | Additional arguments to the [Script:signal](script_signal) call which unblocked this thread. |

## Examples

```lua
local script = crystal.Script:new();

script:run_thread(function(self)
  while true do
    local name = self:wait_for("greet");
    print("Hello " .. name);
  end
end);

script:signal("Alvina"); -- Prints "Hello Alvina"
script:signal("Tarkus"); -- Prints "Hello Tarkus"
```
