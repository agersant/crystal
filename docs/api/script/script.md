---
parent: crystal.script
grand_parent: API Reference
---

# crystal.Script

A script manages a hierarchical collection of [threads](thread).

## Constructor

```lua
crystal.Script:new(startup_function)
```

The `startup_function` parameter is optional. If specified, the script will start with one top-level thread set to execute this function. This parameter is effectively a short hand for:

```lua
local script = crystal.Script:new();
script:add_thread(startup_function);
```

## Methods

### Starting threads

| Name                            | Description                                                                     |
| :------------------------------ | :------------------------------------------------------------------------------ |
| [add_thread](script_add_thread) | Creates a new top-level [Thread](thread) in this script.                        |
| [run_thread](script_run_thread) | Creates and immediately begins executing a new top-level thread in this script. |

### Working with threads

| Name                            | Description                                                                                                                                  |
| :------------------------------ | :------------------------------------------------------------------------------------------------------------------------------------------- |
| [delta_time](script_delta_time) | Returns the delta time that was passed to the last [update](script_update) call.                                                             |
| [signal](script_signal)         | Ends all threads that were scheduled to [end upon it](thread_end_on) a signal. Runs all threads that were [waiting](thread_wait_for) for it. |
| [time](script_time)             | Returns the cumulative time passed to all [update](script_update) calls.                                                                     |
| [update](script_update)         | Runs all threads that are not currently blocked by a call like [join](thread_join) or [wait_for](thread_wait_for).                           |

### Stopping threads

| Name                                        | Description                        |
| :------------------------------------------ | :--------------------------------- |
| [stop_all_threads](script_stop_all_threads) | Stops all threads in this script.  |
| [stop_thread](script_stop_thread)           | Stops a specific [Thread](thread). |

## Example

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
