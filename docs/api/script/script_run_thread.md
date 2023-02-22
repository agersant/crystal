---
parent: crystal.script
grand_parent: API Reference
nav_exclude: true
---

# Script:run_thread

Creates a new top-level [Thread](thread) in this script to run a specific function. Before this call returns, the newly created thread is executed to completion or until it runs into a blocking call like [Thread:wait](thread_wait) or [Thread_wait_for](thread_wait_for).

The function you pass in will receive the thread running it as parameter. Return values of the function (if any) are used in conjunction with [Thread:join](thread_join).

## Usage

```lua
script:add_thread(function_to_thread)
```

### Arguments

| Name                 | Type                          | Description                                |
| :------------------- | :---------------------------- | :----------------------------------------- |
| `function_to_thread` | `function(self: Thread): any` | Function to be executed by the new thread. |

### Returns

| Name     | Type             | Description         |
| :------- | :--------------- | :------------------ |
| `thread` | [Thread](thread) | New thread created. |

Note that if `function_to_thread` does not run into a blocking call, the thread returned by `run_thread` is already [dead](thread_is_dead).

## Examples

```lua
local script = crystal.Script:new();
local thread = script:run_thread(function(self)
  print("Hello from the thread");
end); -- Prints "Hello from the thread"
print(thread:is_dead()); -- Prints "true"
```

```lua
local script = crystal.Script:new();
local thread = script:run_thread(function(self)
  print("Hello from the thread");
  self:wait_for("some_signal");
end); -- Prints "Hello from the thread"
print(thread:is_dead()); -- Prints "false"
```
