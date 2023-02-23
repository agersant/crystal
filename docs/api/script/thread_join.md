---
parent: crystal.script
grand_parent: API Reference
nav_exclude: true
---

# Thread:join

Blocks this thread until a specific thread runs to completion or stops. If the thread to wait on is already dead, this function is not blocking.

## Usage

```lua
thread:join(other_thread)
```

### Arguments

| Name           | Type             | Description            |
| :------------- | :--------------- | :--------------------- |
| `other_thread` | [Thread](thread) | The thread to wait on. |

### Returns

| Name        | Type      | Description                                                                                                                                                   |
| :---------- | :-------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `completed` | `boolean` | True if the thread ran to completion, false if it was stopped prematurely.                                                                                    |
| `...`       | `any`     | Return values (if any) of the thread we were waiting for. These return values are populated even if the thread had already finished before `join` was called. |

## Examples

```lua
local script = crystal.Script:new();

local my_thread = script:run_thread(function(self)
  self:wait_for("my_signal");
  return "hello", "world";
end);

script:run_thread(function(self)
  local success, hello, world = self:join(my_thread);
  print(completed);
  print(hello);
  print(world);
end);

script:signal("my_signal"); -- Prints "true", "hello", "world"
```
