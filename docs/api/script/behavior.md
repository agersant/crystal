---
parent: crystal.script
grand_parent: API Reference
---

# crystal.Behavior

Behaviors are components which manage a [Script](script). This class is of little use on its own as the managed script does nothing by default.

The recommended usage pattern is to define components that bundle specific logic by inheriting from `crystal.Behavior`. The example on this page follows this pattern to define a component which makes an entity print a string every second.

Entities with Behavior components should also have a [ScriptRunner](script_runner) component. The [ECS](/crystal/api/ecs/ecs) owning these entities must operate a [ScriptSystem](script_system).

When a Behavior component is removed from an entity, all its threads are stopped.

## Constructor

Like all other components, Behaviors are created by calling [Entity:add_component](/crystal/api/ecs/entity_add_component).

When inheriting from `crystal.Behavior` and writing a constructor for your component class, you must call the `super` constructor. The `super` constructor supports one optional argument: a function that contains initial logic for the script to run. Specifying this argument is equivalent to calling [self:script():add_thread(f)](script_add_thread).

## Methods

| Name     | Description                                            |
| :------- | :----------------------------------------------------- |
| `script` | Returns the [Script](script) managed by this behavior. |

## Examples

The two examples below are equivalent. They both define a Behavior which prints `"Hello"` every second.

```lua
local HelloPrinter = Class("HelloPrinter", crystal.Behavior);

HelloPrinter.init = function(self)
  HelloPrinter.super.init(self, function(self)
    while true do
      print("Hello");
      self:wait(1);
    end
  end);
end
```

```lua
local HelloPrinter = Class("HelloPrinter", crystal.Behavior);

HelloPrinter.init = function(self)
  HelloPrinter.super.init(self);
  self:script():add_thread(function(self)
    while true do
      print("Hello");
      self:wait(1);
    end
  end);
end
```
