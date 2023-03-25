---
parent: Math Extensions
grand_parent: Lua Extensions
nav_order: 1
---

# math.round

Rounds a number to the nearest integer.

## Usage

```lua
math.round(value)
```

### Arguments

| Name    | Type     | Description     |
| :------ | :------- | :-------------- |
| `value` | `number` | Value to round. |

### Returns

| Name      | Type     | Description    |
| :-------- | :------- | :------------- |
| `rounded` | `number` | Rounded value. |

## Examples

```lua
local rounded = math.round(6.8);
print(rounded); -- Prints "7"
```
