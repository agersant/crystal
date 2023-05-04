---
parent: crystal.ui
grand_parent: API Reference
nav_exclude: true
---

# Padding:padding_top

Returns the top padding amount.

## Usage

```lua
padding:padding_top()
```

### Returns

| Name     | Type     | Description         |
| :------- | :------- | :------------------ |
| `amount` | `number` | Top padding amount. |

## Examples

```lua
local padding = crystal.Padding:new();
padding:set_padding(10);
print(padding:padding_top()); -- Prints "10"
```
