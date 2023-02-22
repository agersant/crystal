---
parent: crystal.script
grand_parent: API Reference
---

# crystal.Thread

{: .note}
Threads transparently have access to all methods of the script that owns them.

## Methods

| Name         | Description                                                                              |
| :----------- | :--------------------------------------------------------------------------------------- |
| defer        | Registers a function that will be executed when this thread runs to completion or stops. |
| hang         | Blocks this thread forever.                                                              |
| is_dead      | Returns whether this thread has ran to completion or stopped.                            |
| join         | Blocks this thread until a specific thread runs to completion or stops.                  |
| join_any     | Blocks this thread until any of several other threads runs to completion or stops.       |
| stop         | Stops this thread.                                                                       |
| stop_on      | Stops this thread whenever its parent [Script](script) receives a specific signal.       |
| thread       | Spawns and immediately begins executing a child thread.                                  |
| wait         | Blocks this thread for a specific duration.                                              |
| wait_for     | Blocks this thread until its parent [Script](script) receives a specific signal.         |
| wait_for_any | Blocks this thread until its parent [Script](script) receives any of several signals.    |
| wait_frame   | Blocks this thread until the next [Script:update](script_update) call.                   |

## Examples

```lua

```
