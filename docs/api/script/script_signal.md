---
parent: crystal.script
grand_parent: API Reference
nav_exclude: true
---

# Script:signal

Stops all threads in this script that were [scheduled](thread_stop_on) to [stop](thread_stop) upon this signal, in any order. Afterwards, runs all threads that were [waiting](thread_wait_for) for this same signal, in any order.

## Usage

```lua
script:signal(signal_name, ...)
```

### Arguments

| Name          | Type     | Description                                                     |
| :------------ | :------- | :-------------------------------------------------------------- |
| `signal_name` | `string` | Signal to emit.                                                 |
| `...`         | `any`    | Values that will be received by threads waiting for the signal. |

## Examples

```lua
local script = crystal.Script:new();
script:run_thread(function(self)
  local item, amount = self:wait_for("crafting_complete");
  print(item);
  print(amount);
end);
script:signal("crafting_complete", "fishing rod", 5); -- prints "fishing rod" and "5"
```
