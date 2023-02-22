---
parent: crystal.script
grand_parent: API Reference
nav_exclude: true
---

# Script:update

Runs all threads in this script that are not currently blocked by a call like [Thread:join](thread_join), [Thread:wait_for](thread_wait_for). Threads blocked by [Thread:wait](thread_wait) will run if they have waited long enough, as determined by `delta_time` values passed to this method.

Each thread will run to completion or until it runs into a blocking call.

There are no guarantees about the order in which threads run.

## Usage

```lua
script:update(delta_time)
```

### Arguments

| Name         | Type     | Description                                            |
| :----------- | :------- | :----------------------------------------------------- |
| `delta_time` | `number` | Time elapsed since the last script update, in seconds. |

## Examples

```lua
local script = crystal.Script:new();

script:add_thread(function(self)
  while true then
    print("Oink");
    self:wait_frame();
  end
end);

script:add_thread(function(self)
  while true then
    print("Moo");
    self:wait_frame();
  end
end);

script:update(0); -- Prints "Oink" and "Moo" (in any order)
script:update(0); -- Prints "Oink" and "Moo" (in any order)
script:update(0); -- Prints "Oink" and "Moo" (in any order)
```
