---
parent: crystal.ui
grand_parent: API Reference
nav_exclude: true
---

# BasicJoint:vertical_alignment

Returns vertical alignment.

## Usage

```lua
basic_joint:vertical_alignment()
```

### Returns

| Name        | Type                                                    | Description         |
| :---------- | :------------------------------------------------------ | :------------------ |
| `alignment` | [VerticalAlignment](/crystal/api/ui/vertical_alignment) | Vertical alignment. |

## Examples

```lua
local overlay = crystal.Overlay:new();

local image = overlay:add_child(crystal.Image:new());
image:set_vertical_alignment("bottom");
print(image:vertical_alignment()); -- Prints "bottom"
```
