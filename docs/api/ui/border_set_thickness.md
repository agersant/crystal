---
parent: crystal.ui
grand_parent: API Reference
nav_exclude: true
---

# Border:set_thickness

Sets the border thickness in pixels.

## Usage

```lua
border:set_thickness(radius)
```

### Arguments

| Name     | Type     | Description    |
| :------- | :------- | :------------- |
| `radius` | `number` | Corner radius. |

## Examples

```lua
local border = crystal.Border:new();
border:set_thickness(4);
print(border:thickness()); -- Prints 4
```
