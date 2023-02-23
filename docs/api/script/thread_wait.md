---
parent: crystal.script
grand_parent: API Reference
nav_exclude: true
---

# Thread:wait

Blocks this thread for a specific duration.

## Usage

```lua
thread:wait(duration)
```

### Arguments

| Name       | Type     | Description                   |
| :--------- | :------- | :---------------------------- |
| `duration` | `number` | Duration to wait, in seconds. |

## Examples

````lua

```lua
local script = crystal.Script:new();

script:add_thread(function(self)
  self:wait(2);
  print("Waited 2 seconds");
end);

script:update(0.8); -- 1.2s left to wait
script:update(0.8); -- 0.4s left to wait
script:update(0.8); -- Prints "Waited 2 seconds"
````
