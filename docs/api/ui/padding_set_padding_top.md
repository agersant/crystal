---
parent: crystal.ui
grand_parent: API Reference
nav_exclude: true
---

# Padding:set_padding_top

Sets the top padding amount.

## Usage

```lua
padding:set_padding_top(amount)
```

### Arguments

| Name     | Type     | Description         |
| :------- | :------- | :------------------ |
| `amount` | `number` | Top padding amount. |

## Examples

```lua
local padding = crystal.Padding:new();
padding:set_padding_top(10);
print(padding:padding_top()); -- Prints "10"
```
