---
parent: crystal.script
grand_parent: API Reference
nav_exclude: true
---

# Thread:hang

Blocks this thread forever. It will stop under any of the following circumstances:

- Its parent thread finishes or stops.
- A stopping signal for this thread is emitted (see [Thread:stop_on](thread_stop_on)).
- [Thread:stop](thread_stop) is called on this thread.

{: .note}
This method is useful when a thread spawns child threads and needs to keep them alive.

## Usage

```lua
thread:hang()
```

## Examples

```lua
local script = crystal.Script:new();

script:run_thread(function(self)
  self:stop_on("party_is_over");

  self:thread(function(self)
    while true do
      self:wait_frame();
      print("singing");
    end
  end);

  self:thread(function(self)
    while true do
      self:wait_frame();
      print("dancing");
    end
  end);

  -- Without this statement, the two child threads would immediately stop
  self:hang();
end);

script:update(0); -- Prints "singing" and "dancing" (in any order)
script:update(0); -- Prints "singing" and "dancing" (in any order)
script:signal("party_is_over");
script:update(0); -- Nothign happens
```
