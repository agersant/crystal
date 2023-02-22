---
parent: crystal.script
grand_parent: API Reference
nav_exclude: true
---

# Script:stop_thread

Stops a specific [Thread](thread). See [Thread:stop](thread_stop) for more details on what it means to stop a thread.

Attempting to stop a thread which belongs to a different script will cause an error. Calling [Thread:stop](thread_stop) instead avoids this pitfall.

## Usage

```lua
script:stop_thread(thread)
```

### Arguments

| Name     | Type             | Description     |
| :------- | :--------------- | :-------------- |
| `thread` | [Thread](thread) | Thread to stop. |

## Examples

```lua
local script = Script:new();
local thread = script:run_thread(function(self)
  self:defer(function()
    print("bye");
  end);
  self:hang();
end);
script:stop_thread(thread); -- Prints "bye"
script:stop_thread(thread); -- Does nothing
```
