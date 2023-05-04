---
parent: crystal.ui
grand_parent: API Reference
nav_exclude: true
---

# Border:set_rounding

Sets the radius used for corner rounding.

## Usage

```lua
border:set_rounding(radius)
```

### Arguments

| Name     | Type     | Description    |
| :------- | :------- | :------------- |
| `radius` | `number` | Corner radius. |

## Examples

```lua
local border = crystal.Border:new();
border:set_rounding(4);
print(border:rounding()); -- Prints 4
```
