---
parent: crystal.string
grand_parent: API Reference
nav_order: 1
---

# string.strip_whitespace

Returns a copy of a string with all whitespace removed.

## Usage

```lua
string.strip_whitespace(my_string)
```

### Arguments

| Name        | Type     | Description                       |
| :---------- | :------- | :-------------------------------- |
| `my_string` | `string` | String to remove whitespace from. |

### Returns

| Name       | Type     | Description                |
| :--------- | :------- | :------------------------- |
| `stripped` | `string` | String without whitespace. |

## Examples

```lua
local example = "Text without spaces is hard to read!";
print(example:strip_whitespace()); -- Prints "Textwithoutspacesishardtoread!"
```
