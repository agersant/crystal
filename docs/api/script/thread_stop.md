---
parent: crystal.script
grand_parent: API Reference
nav_exclude: true
---

# Thread:stop

Stops this thread. This has the following effects (in order):

1. All child threads are stopped (in any order).
2. [Deferred functions](thread_defer) for this thread are executed.
3. Threads [joining](thread_join) on this one are unblocked (in any order).

## Usage

```lua
thread:stop()
```

## Examples

```lua
local script = crystal.Script:new();

local thread = script:add_thread(function(self)
  print("This will not be printed");
end);

thread:stop();
script:update(0); -- Nothing happens
```
