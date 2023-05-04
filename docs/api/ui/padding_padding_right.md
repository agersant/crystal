---
parent: crystal.ui
grand_parent: API Reference
nav_exclude: true
---

# Padding:padding_right

Returns the right padding amount.

## Usage

```lua
padding:padding_right()
```

### Returns

| Name     | Type     | Description           |
| :------- | :------- | :-------------------- |
| `amount` | `number` | Right padding amount. |

## Examples

```lua
local padding = crystal.Padding:new();
padding:set_padding(10);
print(padding:padding_right()); -- Prints "10"
```
