---
parent: crystal.ui
grand_parent: API Reference
nav_exclude: true
---

# HorizontalListJoint:vertical_alignment

Returns how this element is aligned vertically. The default vertical alignment is `"top"`.

## Usage

```lua
horizontal_list_joint:vertical_alignment(alignment)
```

### Returns

| Name        | Type                                                    | Description                             |
| :---------- | :------------------------------------------------------ | :-------------------------------------- |
| `alignment` | [VerticalAlignment](/crystal/api/ui/vertical_alignment) | How this element is aligned vertically. |

## Examples

```lua
local list = crystal.HorizontalList:new();
local image = list:add_child(crystal.Image:new());
image:set_vertical_alignment("stretch");
print(image:vertical_alignment()); -- Prints "stretch"
```
