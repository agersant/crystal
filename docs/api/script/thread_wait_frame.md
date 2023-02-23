---
parent: crystal.script
grand_parent: API Reference
nav_exclude: true
---

# Thread:wait_frame

Blocks this thread until the next [Script:update](script_update) call.

## Usage

```lua
thread:wait_frame()
```

## Examples

```lua
local script = crystal.Script:new();

script:add_thread(function(self)
  while true do
    print(self:time());
	self:wait_frame();
  end
end);

script:update(0.1); -- Prints 0.1
script:update(0.1); -- Prints 0.2
script:update(0.1); -- Prints 0.3
```
