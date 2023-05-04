---
parent: crystal.ui
grand_parent: API Reference
nav_exclude: true
---

# Padding:set_padding

Sets all four padding amounts.

## Usage

```lua
padding:set_padding(amount)
```

### Arguments

| Name     | Type     | Description                        |
| :------- | :------- | :--------------------------------- |
| `amount` | `number` | Padding amount for all directions. |

## Usage

```lua
padding:set_padding(left, right, top, bottom)
```

### Arguments

| Name     | Type     | Description          |
| :------- | :------- | :------------------- |
| `left`   | `number` | Left padding amount. |
| `right`  | `number` | Left padding amount. |
| `top`    | `number` | Left padding amount. |
| `bottom` | `number` | Left padding amount. |

## Examples

Set all padding amounts to the same value:

```lua
local padding = crystal.Padding:new();
padding:set_padding(10);
print(padding:padding()); -- Prints 10, 10, 10, 10
```

Set individual padding amounts for each direction:

```lua
local padding = crystal.Padding:new();
padding:set_padding(1, 2, 3, 4);
print(padding:padding()); -- Prints 1, 2, 3, 4
```
