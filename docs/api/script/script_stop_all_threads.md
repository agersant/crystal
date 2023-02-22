---
parent: crystal.script
grand_parent: API Reference
nav_exclude: true
---

# Script:stop_all_threads

Stops all threads in this script. See [Thread:stop](thread_stop) for more details on what it means to stop a thread.

## Usage

```lua
script:stop_all_threads()
```

## Example

```lua
local script = Script:new();

script:run_thread(function(self)
  while true do
    self:wait_frame();
    print("Hello");
  end
end);

script:run_thread(function(self)
  while true do
    self:wait_frame();
    print("Bonjour");
  end
end);

script:update(0); -- Prints "Hello" and "Bonjour" (in any order)
script:update(0); -- Prints "Hello" and "Bonjour" (in any order)
script:stop_all_threads();
script:update(0); -- Does nothing
```
