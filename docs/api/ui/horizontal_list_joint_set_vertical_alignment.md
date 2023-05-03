---
parent: crystal.ui
grand_parent: API Reference
nav_exclude: true
---

# HorizontalListJoint:set_vertical_alignment

Sets how this element is aligned vertically.

## Usage

```lua
horizontal_list_joint:set_vertical_alignment(alignment)
```

### Arguments

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
