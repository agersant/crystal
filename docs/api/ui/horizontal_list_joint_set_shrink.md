---
parent: crystal.ui
grand_parent: API Reference
nav_exclude: true
---

# HorizontalListJoint:set_shrink

Sets the shrink factor on this list element.

## Usage

```lua
horizontal_list_joint:set_shrink(factor)
```

### Arguments

| Name     | Type     | Description    |
| :------- | :------- | :------------- |
| `factor` | `number` | Shrink factor. |

## Examples

```lua
local list = crystal.HorizontalList:new();
local image = list:add_child(crystal.Image:new());
image:set_shrink(2);
print(image:shrink()); -- Prints "2"
```
