---
parent: crystal.ui
grand_parent: API Reference
nav_exclude: true
---

# Padding:set_padding_y

Sets the top and bottom padding amounts.

## Usage

```lua
padding:set_padding_y(amount)
```

### Arguments

| Name     | Type     | Description                     |
| :------- | :------- | :------------------------------ |
| `amount` | `number` | Top and bottom padding amounts. |

## Examples

```lua
local padding = crystal.Padding:new();
padding:set_padding_y(10);
print(padding:padding_top()); -- Prints "10"
print(padding:padding_bottom()); -- Prints "10"
```
