---
parent: crystal.script
grand_parent: API Reference
nav_exclude: true
---

# Thread:thread

Creates a child thread of the current thread. The function passed to the new thread runs before this call returns, until it completes or runs into a blocking call such as [Thread:wait](thread_wait).

The child thread cannot outlive this thread, and will stop when this thread completes or is stopped (see [Thread:stop](thread_stop)).

## Usage

```lua
thread:thread(function_to_thread)
```

### Arguments

| Name                 | Type                          | Description                                 |
| :------------------- | :---------------------------- | :------------------------------------------ |
| `function_to_thread` | `function(self: Thread): any` | Function that will run in the child thread. |

### Returns

| Name         | Type             | Description                         |
| :----------- | :--------------- | :---------------------------------- |
| `new_thread` | [Thread](thread) | Child thread that was just created. |

## Examples

This example runs a long operation (represented as randomly waiting 2 to 8 seconds), which uses a child thread to enforce a 5s timeout.

```lua
local script = crystal.Script:new();

script:run_thread(function(self)
  self:thread(function(self)
    self:wait(5);
	self:signal("timeout");
  end);

  self:stop_on("timeout");
  self:wait(math.random(2, 8));
  print("Made it through without timing out!");
end);

for i = 1, 100 do
  script:update(0.1);
end
```
