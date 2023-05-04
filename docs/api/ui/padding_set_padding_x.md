---
parent: crystal.ui
grand_parent: API Reference
nav_exclude: true
---

# Padding:set_padding_x

Sets the left and right padding amounts.

## Usage

```lua
padding:set_padding_x(amount)
```

### Arguments

| Name     | Type     | Description                     |
| :------- | :------- | :------------------------------ |
| `amount` | `number` | Left and right padding amounts. |

## Examples

```lua
local padding = crystal.Padding:new();
padding:set_padding_x(10);
print(padding:padding_left()); -- Prints "10"
print(padding:padding_right()); -- Prints "10"
```
