---
parent: crystal.ui
grand_parent: API Reference
nav_exclude: true
---

# HorizontalListJoint:grow

Returns the growth factor on this list element. The default growth factor is `0`.

## Usage

```lua
horizontal_list_joint:grow()
```

### Returns

| Name     | Type     | Description    |
| :------- | :------- | :------------- |
| `factor` | `number` | Growth factor. |

## Examples

```lua
local list = crystal.HorizontalList:new();
local image = list:add_child(crystal.Image:new());
image:set_grow(2);
print(image:grow()); -- Prints "2"
```
