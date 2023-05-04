---
parent: crystal.ui
grand_parent: API Reference
nav_exclude: true
---

# Padding:set_padding_bottom

Sets the bottom padding amount.

## Usage

```lua
padding:set_padding_bottom(amount)
```

### Arguments

| Name     | Type     | Description            |
| :------- | :------- | :--------------------- |
| `amount` | `number` | Bottom padding amount. |

## Examples

```lua
local padding = crystal.Padding:new();
padding:set_padding_bottom(10);
print(padding:padding_bottom()); -- Prints "10"
```
