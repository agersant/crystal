---
parent: crystal.ui
grand_parent: API Reference
nav_exclude: true
---

# Padding:padding_left

Returns the left padding amount.

## Usage

```lua
padding:padding_left()
```

### Returns

| Name     | Type     | Description          |
| :------- | :------- | :------------------- |
| `amount` | `number` | Left padding amount. |

## Examples

```lua
local padding = crystal.Padding:new();
padding:set_padding(10);
print(padding:padding_left()); -- Prints "10"
```
