---
parent: crystal.script
grand_parent: API Reference
nav_exclude: true
---

# Thread:is_dead

Returns whether this thread has ran to completion or stopped.

## Usage

```lua
thread:is_dead()
```

### Returns

| Name   | Type      | Description                                           |
| :----- | :-------- | :---------------------------------------------------- |
| `dead` | `boolean` | True if this thread has ran to completion or stopped. |

## Examples

```lua
local script = crystal.Script:new();
local thread = script:run_thread(function(self)
  print("Hello and goodbye");
end);
assert(thread:is_dead());
```

```lua
local script = crystal.Script:new();
local thread = script:run_thread(function(self)
  self:wait(5);
end);
assert(not thread:is_dead());
```
