---
parent: crystal.ui
grand_parent: API Reference
nav_exclude: true
---

# Padding:set_padding_left

Sets the left padding amount.

## Usage

```lua
padding:set_padding_left(amount)
```

### Arguments

| Name     | Type     | Description          |
| :------- | :------- | :------------------- |
| `amount` | `number` | Left padding amount. |

## Examples

```lua
local padding = crystal.Padding:new();
padding:set_padding_left(10);
print(padding:padding_left()); -- Prints "10"
```
