---
parent: crystal.ui
grand_parent: API Reference
nav_exclude: true
---

# Border:rounding

Returns the radius used for corner rounding.

## Usage

```lua
border:rounding()
```

### Returns

| Name     | Type     | Description    |
| :------- | :------- | :------------- |
| `radius` | `number` | Corner radius. |

## Examples

```lua
local border = crystal.Border:new();
border:set_rounding(4);
print(border:rounding()); -- Prints 4
```
