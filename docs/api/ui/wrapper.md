---
parent: crystal.ui
grand_parent: API Reference
nav_order: 2
---

# crystal.Wrapper

Base class for [UI elements](ui_element) which can contain one child element.

Some example wrapper classes are [Widget](widget) and [Painter](painter).

## Constructor

```lua
crystal.Wrapper:new(joint_class)
```

The `joint_class` parameter must be a class inheriting from [Joint](joint).

## Methods

| Name                                   | Description                                                   |
| :------------------------------------- | :------------------------------------------------------------ |
| [arrange_child](wrapper_arrange_child) | Computes and sets the relative position of the child element. |
| [child](wrapper_child)                 | Returns the child element of this wrapper, if any.            |
| [remove_child](wrapper_remove_child)   | Removes the child element from this wrapper.                  |
| [set_child](wrapper_set_child)         | Sets the child element wrapped by this wrapper.               |

## Examples

Using an existing `Wrapper` class:

```lua
local widget = crystal.Widget:new();
widget:set_child(crystal.Image:new());
```

Implementing your own `Wrapper` class:

```lua
local MyWrapperJoint = Class("MyWrapperJoint", crystal.Joint);

MyWrapperJoint.init = function(self)
  -- Joint default setup goes here eg. `self.margin = 0;`
end

local MyWrapper = Class("MyWrapper", crystal.Wrapper);

MyWrapper.init = function(self)
  MyWrapper.super.init(self, MyWrapperJoint);
end

MyWrapper.arrange_child = function(self)
  -- Layout logic goes here
end
```
