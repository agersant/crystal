---
parent: crystal.script
grand_parent: API Reference
nav_exclude: true
---

# Thread:block

Blocks the currently running thread until this thread runs to completion or stops. If the blocking thread is already dead, this function returns immediately.

## Usage

```lua
thread:block()
```

### Returns

| Name        | Type      | Description                                                                                                                                                    |
| :---------- | :-------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `completed` | `boolean` | True if the thread ran to completion, false if it was stopped prematurely.                                                                                     |
| `...`       | `any`     | Return values (if any) of the thread we were waiting for. These return values are populated even if the thread had already finished before `block` was called. |

## Examples

```lua
local script = crystal.Script:new();

local my_thread = script:run_thread(function(self)
  self:wait_for("my_signal");
  return "hello", "world";
end);

script:run_thread(function(self)
  local success, hello, world = my_thread:block();
  print(success);
  print(hello);
  print(world);
end);

script:signal("my_signal"); -- Prints "true", "hello", "world"
```
