---
parent: crystal.ui
grand_parent: API Reference
nav_order: 2
---

# crystal.HorizontalListJoint

A [Joint](joint) specifying how elements are positioned in a [HorizontalList](horizontal_list).

When a list has too much or not enough space to size each element at its desired size, they grow or shrink according to their `grow`/`shrink` factors. These factors are relative between elements of the list. For example, an element with a grow factor of `20` will grow twice as much as an element with a grow factor of `10` when filling extraneous space.

## Constructor

`HorizontalListJoint` are created by calling [add_child](container_add_child) on a [HorizontalList](horizontal_list).

## Methods

| Name                                                                   | Description                                     |
| :--------------------------------------------------------------------- | :---------------------------------------------- |
| [grow](horizontal_list_joint_grow)                                     | Returns the growth factor on this list element. |
| [set_grow](horizontal_list_joint_set_grow)                             | Sets the growth factor on this list element.    |
| [set_shrink](horizontal_list_joint_set_shrink)                         | Sets the shrink factor on this list element     |
| [set_vertical_alignment](horizontal_list_joint_set_vertical_alignment) | Sets how this element is aligned vertically.    |
| [shrink](horizontal_list_joint_shrink)                                 | Returns the shrink factor on this list element. |
| [vertical_alignment](horizontal_list_joint_vertical_alignment)         | Returns how this element is aligned vertically. |

### Padding

`HorizontalListJoint` objects transparently expose a [Padding](padding) object, using the [aliasing](/crystal/extensions/oop/#aliasing) mechanism. Refer to the [Padding](padding) documentation for a list of these methods.

## Examples

```lua
local list = crystal.HorizontalList:new();

local fixed_size = list:add_child(crystal.Image:new());
fixed_size:set_image_size(64, 64);

local filler = list:add_child(crystal.Image:new());
filler:set_image_size(64, 64);
filler:set_grow(1); -- This element will grow horizontally to fill available space the list
```
