---
parent: crystal.script
grand_parent: API Reference
---

# crystal.Thread

Threads are wrappers around Lua coroutines. Functions executed in a thread can use it to trigger blocking operations, like waiting for a [duration](thread_wait), waiting for a [signal](thread_wait_for), or waiting for [another thread to complete](thread_join).

{: .note}
Threads transparently have access to all methods of the script that owns them.

## Methods

| Name                                | Description                                                                              |
| :---------------------------------- | :--------------------------------------------------------------------------------------- |
| [block](thread_block)               | Blocks the currently running thread until this thread runs to completion or stops.       |
| [defer](thread_defer)               | Registers a function that will be executed when this thread runs to completion or stops. |
| [hang](thread_hang)                 | Blocks this thread forever.                                                              |
| [is_dead](thread_is_dead)           | Returns whether this thread has ran to completion or stopped.                            |
| [join](thread_join)                 | Blocks this thread until a specific thread runs to completion or stops.                  |
| [join_any](thread_join_any)         | Blocks this thread until any of several other threads runs to completion or stops.       |
| [script](thread_script)             | Returns the script owning this thread.                                                   |
| [stop](thread_stop)                 | Stops this thread.                                                                       |
| [stop_on](thread_stop_on)           | Stops this thread whenever its parent [Script](script) receives a specific signal.       |
| [thread](thread_thread)             | Spawns and immediately begins executing a child thread.                                  |
| [wait](thread_wait)                 | Blocks this thread for a specific duration.                                              |
| [wait_for](thread_wait_for)         | Blocks this thread until its parent [Script](script) receives a specific signal.         |
| [wait_for_any](thread_wait_for_any) | Blocks this thread until its parent [Script](script) receives any of several signals.    |
| [wait_frame](thread_wait_frame)     | Blocks this thread until the next [Script:update](script_update) call.                   |

## Examples

```lua
local script = crystal.Script:new();

local my_thread = script:run_thread(function(self)
  self:stop_on("bye");
  self:hang();
end);

script:run_thread(function(self)
  self:join(my_thread);
  print("Finished joining!");
end);

script:signal("bye"); -- Prints "Finished joining!"
```
