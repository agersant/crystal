---
parent: crystal.ui
grand_parent: API Reference
nav_exclude: true
---

# Padding:set_padding_right

Sets the right padding amount.

## Usage

```lua
padding:set_padding_right(amount)
```

### Arguments

| Name     | Type     | Description           |
| :------- | :------- | :-------------------- |
| `amount` | `number` | Right padding amount. |

## Examples

```lua
local padding = crystal.Padding:new();
padding:set_padding_right(10);
print(padding:padding_right()); -- Prints "10"
```
