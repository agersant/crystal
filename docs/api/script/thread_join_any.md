---
parent: crystal.script
grand_parent: API Reference
nav_exclude: true
---

# Thread:join_any

Blocks this thread until any of several other threads runs to completion or stops. If any of the threads to wait on is already dead, this function is not blocking.

## Usage

```lua
thread:join_any(other_threads)
```

### Arguments

| Name            | Type    | Description                 |
| :-------------- | :------ | :-------------------------- |
| `other_threads` | `table` | List of threads to wait on. |

### Returns

| Name        | Type      | Description                                                                                                                                                             |
| :---------- | :-------- | :---------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `completed` | `boolean` | True if the thread which unblocks this call ran to completion, false if it was stopped prematurely.                                                                     |
| `...`       | `any`     | Return values (if any) of the thread which unblocked this call. These return values are populated even if the thread had already finished before `join_any` was called. |

## Examples

```lua
local script = crystal.Script:new();

local plum_thread = script:run_thread(function(self)
  self:wait_for("plum_signal");
  return "plum";
end);

local cherry_thread = script:run_thread(function(self)
  self:wait_for("cherry_signal");
  return "cherry";
end);

script:run_thread(function(self)
  local success, fruit = self:join_any({ plum_thread, cherry_thread });
  print(fruit);
end);

script:signal("cherry_signal"); -- Prints "cherry"
script:signal("plum_signal"); -- Nothing happens
```
