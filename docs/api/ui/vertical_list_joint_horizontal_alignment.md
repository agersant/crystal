---
parent: crystal.ui
grand_parent: API Reference
nav_exclude: true
---

# VerticalListJoint:horizontal_alignment

Returns how this element is aligned horizontally. The default horizontal alignment is `"left"`.

## Usage

```lua
vertical_list_joint:horizontal_alignment(alignment)
```

### Returns

| Name        | Type                                                        | Description                               |
| :---------- | :---------------------------------------------------------- | :---------------------------------------- |
| `alignment` | [HorizontalAlignment](/crystal/api/ui/horizontal_alignment) | How this element is aligned horizontally. |

## Examples

```lua
local list = crystal.VerticalList:new();
local image = list:add_child(crystal.Image:new());
image:set_horizontal_alignment("stretch");
print(image:horizontal_alignment()); -- Prints "stretch"
```
