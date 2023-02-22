---
parent: crystal.script
grand_parent: API Reference
nav_exclude: true
---

# Script:add_thread

Creates a new top-level [Thread](thread) in this script to run a specific function.

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

## Examples

```lua
local script = crystal.Script:new();
script:add_thread(function(self)
  print("Hello from the thread");
end);
script:update(0); -- Prints "Hello from the thread"
```
