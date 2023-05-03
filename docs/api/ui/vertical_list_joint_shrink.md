---
parent: crystal.ui
grand_parent: API Reference
nav_exclude: true
---

# VerticalListJoint:shrink

Returns the shrink factor on this list element. The default shrink factor is `0`.

## Usage

```lua
vertical_list_joint:shrink()
```

### Returns

| Name     | Type     | Description    |
| :------- | :------- | :------------- |
| `factor` | `number` | Shrink factor. |

## Examples

```lua
local list = crystal.VerticalList:new();
local image = list:add_child(crystal.Image:new());
image:set_shrink(2);
print(image:shrink()); -- Prints "2"
```
