---
parent: crystal.ui
grand_parent: API Reference
---

# crystal.BasicJoint

A [Joint](joint) with common padding and alignment options.

This type of joint is used by several built-in element types, like [Overlay](overlay), [Widget](widget), [Switcher](switcher) and [Painter](painter).

## Constructor

Like all other [Joint](joint) classes, `BasicJoint` are created by calling [add_child](container_add_child), [set_child](wrapper_set_child) or [set_root](widget_set_root).

## Methods

## Alignment

| Name                                                             | Description                                |
| :--------------------------------------------------------------- | :----------------------------------------- |
| [alignment](basic_joint_alignment)                               | Returns horizontal and vertical alignment. |
| [horizontal_alignment](basic_joint_horizontal_alignment)         | Returns horizontal alignment.              |
| [set_alignment](basic_joint_set_alignment)                       | Sets horizontal and vertical alignment.    |
| [set_horizontal_alignment](basic_joint_set_horizontal_alignment) | Sets horizontal alignment.                 |
| [set_vertical_alignment](basic_joint_set_vertical_alignment)     | Sets vertical alignment.                   |
| [vertical_alignment](basic_joint_vertical_alignment)             | Returns vertical alignment.                |

## Padding

`BasicJoint` objects transparently expose a [Padding](padding) object, using the [aliasing](/crystal/extensions/oop/#aliasing) mechanism. Refer to the [Padding](padding) documentation for a list of these methods.

## Advanced Functionality

Methods below are useful when implementing your own [Wrapper](wrapper) or [Container](container) types.

| Name                                                               | Description                                                                |
| :----------------------------------------------------------------- | :------------------------------------------------------------------------- |
| [compute_desired_size](basic_joint_compute_desired_size)           | Computes the desired size of the joint's child element.                    |
| [compute_relative_position](basic_joint_compute_relative_position) | Computes the position of the joint's child element relative to its parent. |

## Examples

```lua
local overlay = crystal.Overlay:new();

local top_left = overlay:add_child(crystal.Image:new());
top_left:set_image_size(64, 64);
top_left:set_alignment("left", "top");

local bottom_right = overlay:add_child(crystal.Image:new());
bottom_right:set_image_size(64, 64);
bottom_right:set_alignment("right", "bottom");

local center = overlay:add_child(crystal.Image:new());
center:set_image_size(32, 32);
center:set_padding(100);
center:set_alignment("center", "center");
```
