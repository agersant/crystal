---
parent: crystal.ui
grand_parent: API Reference
nav_exclude: true
---

# BasicJoint:set_alignment

Sets horizontal and vertical alignment.

## Usage

```lua
basic_joint:set_alignment(horizontal_alignment, vertical_alignment)
```

### Arguments

| Name                   | Type                                                        | Description           |
| :--------------------- | :---------------------------------------------------------- | :-------------------- |
| `horizontal_alignment` | [HorizontalAlignment](/crystal/api/ui/horizontal_alignment) | Horizontal alignment. |
| `vertical_alignment`   | [VerticalAlignment](/crystal/api/ui/vertical_alignment)     | Vertical alignment.   |

## Examples

```lua
local overlay = crystal.Overlay:new();

local image = overlay:add_child(crystal.Image:new());
image:set_alignment("right", "bottom");
print(image:alignment()); -- Prints "right", "bottom"
```
