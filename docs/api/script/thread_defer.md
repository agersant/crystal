---
parent: crystal.script
grand_parent: API Reference
nav_exclude: true
---

# Thread:defer

Registers a function that will be executed when this thread runs to completion or stops.

{: .note}
Deferred functions run in the order opposite of their registration.

## Usage

```lua
thread:defer(deferred_function)
```

### Arguments

| Name                | Type                     | Description                                         |
| :------------------ | :----------------------- | :-------------------------------------------------- |
| `deferred_function` | `function(self: Thread)` | Function to run when this thread finishes or stops. |

## Examples

```lua
local script = crystal.Script:new();
script:run_thread(function(self)
  self:defer(function(self)
    print("Hi from deferred function!");
  end);
  self:defer(function(self)
    print("I run first");
  end);
  self:wait_for("my_signal");
  print("thread logic");
end);

-- Prints "thread logic", "I run first", and "Hi from deferred function!" (in this order)
script:signal("my_signal");
```
