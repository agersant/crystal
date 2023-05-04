---
parent: crystal.ui
grand_parent: API Reference
nav_exclude: true
---

# Border:thickness

Returns the border thickness in pixels.

## Usage

```lua
border:thickness()
```

### Returns

| Name     | Type     | Description                 |
| :------- | :------- | :-------------------------- |
| `radius` | `number` | Border thickness in pixels. |

## Examples

```lua
local border = crystal.Border:new();
border:set_thickness(4);
print(border:thickness()); -- Prints 4
```
