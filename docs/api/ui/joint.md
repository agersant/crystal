---
parent: crystal.ui
grand_parent: API Reference
nav_order: 2
---

# crystal.Joint

Joints define how a [UI element](ui_element) should be laid out by its parent. Different types of [containers](container) and [wrappers](wrapper) use different types of joint with options relevant to them like padding or alignment. This is the base class for all joint types.

## Constructor

`Joint` are created by calling [add_child](container_add_child) or [set_child](wrapper_set_child). The type of joint being created depends on the type of the container/wrapper.

## Methods

| Name                   | Description                                               |
| :--------------------- | :-------------------------------------------------------- |
| [child](joint_child)   | Returns the child this joint is affecting.                |
| [parent](joint_parent) | Returns the container or wrapper the child element is in. |

## Examples

```lua
local overlay = crystal.Overlay:new();
local image = overlay:add_child(crystal.Image:new());
assert(image:joint():child() == image);
assert(image:joint():parent() == overlay);
```
