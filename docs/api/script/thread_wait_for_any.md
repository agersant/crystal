---
parent: crystal.script
grand_parent: API Reference
nav_exclude: true
---

# Thread:wait_for_any

Blocks this thread until its parent [Script](script) receives any of several signals.

## Usage

```lua
thread:wait_for_any(signals)
```

### Arguments

| Name      | Type    | Description                  |
| :-------- | :------ | :--------------------------- |
| `signals` | `table` | List of signals as `string`. |

### Returns

| Name     | Type     | Description                                                                                                                    |
| :------- | :------- | :----------------------------------------------------------------------------------------------------------------------------- |
| `signal` | `string` | The signal which unblocked this thread. This return value is skipped if the input list of `signals` only contained one signal. |
| `...`    | `any`    | Additional arguments to the [Script:signal](script_signal) call which unblocked this thread.                                   |

## Examples

```lua
local script = crystal.Script:new();

script:run_thread(function(self)
  local signal, fruit = self:wait_for_any({"plum_signal", "cherry_signal"});
  print(signal);
  print(fruit);
end);

script:signal("plum_signal"); -- Prints "plum_signal" and then "plum"
script:signal("cherry_signal"); -- Nothing happens
```
