---
parent: crystal.ui
grand_parent: API Reference
nav_exclude: true
---

# Padding:padding_bottom

Returns the bottom padding amount.

## Usage

```lua
padding:padding_bottom()
```

### Returns

| Name     | Type     | Description            |
| :------- | :------- | :--------------------- |
| `amount` | `number` | Bottom padding amount. |

## Examples

```lua
local padding = crystal.Padding:new();
padding:set_padding(10);
print(padding:padding_bottom()); -- Prints "10"
```
