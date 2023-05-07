---
parent: crystal.ui
grand_parent: API Reference
nav_order: 2
---

# crystal.Container

Base class for [UI elements](ui_element) which can contain multiple child elements.

Some example container classes are [HorizontalList](horizontal_list), [VerticalList](vertical_list) and [Overlay](overlay).

## Constructor

```lua
crystal.Container:new(joint_class)
```

The `joint_class` parameter must be a class inheriting from [Joint](joint).

## Methods

| Name                                           | Description                                                 |
| :--------------------------------------------- | :---------------------------------------------------------- |
| [add_child](container_add_child)               | Adds a child element to this container.                     |
| [arrange_children](container_arrange_children) | Computes and sets the relative positions of child elements. |
| [child](container_child)                       | Returns a child element by index.                           |
| [children](container_children)                 | Returns the list of child elements.                         |
| [remove_child](container_remove_child)         | Removes a child element.                                    |

## Examples

Using an existing `Container` class:

```lua
local title_screen = crystal.Overlay:new();
local background = title_screen:add_child(crystal.Image:new());
local logo = title_screen:add_child(crystal.Image:new(crystal.assets.get("logo.png")));
background:set_alignment("stretch", "stretch");
logo:set_alignment("center", "center");
```

Implementing your own `Container` class:

```lua
local MyContainerJoint = Class("MyContainerJoint", crystal.Joint);

MyContainerJoint.init = function(self)
  -- Joint default setup goes here eg. `self.margin = 0;`
end

local MyContainer = Class("MyContainer", crystal.Container);

MyContainer.init = function(self)
  MyContainer.super.init(self, MyContainerJoint);
end

MyContainer.arrange_children = function(self)
  -- Layout logic goes here
end
```
