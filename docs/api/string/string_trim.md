---
parent: crystal.string
grand_parent: API Reference
nav_order: 1
---

# string.trim

Returns a copy of a string with starting and ending whitespace removed.

## Usage

```lua
string.trim(my_string)
```

### Arguments

| Name        | Type     | Description     |
| :---------- | :------- | :-------------- |
| `my_string` | `string` | String to trim. |

### Returns

| Name      | Type     | Description     |
| :-------- | :------- | :-------------- |
| `trimmed` | `string` | Trimmed string. |

## Examples

```lua
local example = "     no   superfluous spaces   ";
print(example:trim()); -- Prints "no   superfluous spaces"
```
