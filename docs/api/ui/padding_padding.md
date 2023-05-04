---
parent: crystal.ui
grand_parent: API Reference
nav_exclude: true
---

# Padding:padding()

Returns all four padding amounts.

## Usage

```lua
padding:padding()
```

### Returns

| Name     | Type     | Description            |
| :------- | :------- | :--------------------- |
| `left`   | `number` | Left padding amount.   |
| `right`  | `number` | Right padding amount.  |
| `top`    | `number` | Top padding amount.    |
| `bottom` | `number` | Bottom padding amount. |

## Examples

```lua
local padding = crystal.Padding:new();
local left, right, top, bottom = padding:set_padding(1, 2, 3, 4);
print(bottom); -- Prints "4"
```
