---
parent: crystal.ui
grand_parent: API Reference
nav_exclude: true
---

# BasicJoint:set_horizontal_alignment

Sets horizontal alignment.

## Usage

```lua
basic_joint:set_horizontal_alignment(alignment)
```

### Returns

| Name        | Type                                                        | Description           |
| :---------- | :---------------------------------------------------------- | :-------------------- |
| `alignment` | [HorizontalAlignment](/crystal/api/ui/horizontal_alignment) | Horizontal alignment. |

## Examples

```lua
local overlay = crystal.Overlay:new();

local image = overlay:add_child(crystal.Image:new());
image:set_horizontal_alignment("right");
print(image:horizontal_alignment()); -- Prints "right"
```
