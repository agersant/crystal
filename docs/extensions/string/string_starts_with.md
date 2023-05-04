---
parent: String Extensions
grand_parent: Lua Extensions
nav_order: 1
---

# string.starts_with

Returns whether a string starts with a specifics substring.

## Usage

```lua
string.starts_with(prefix)
```

### Arguments

| Name     | Type     | Description              |
| :------- | :------- | :----------------------- |
| `prefix` | `string` | Prefix to check against. |

### Returns

| Name     | Type      | Description                                               |
| :------- | :-------- | :-------------------------------------------------------- |
| `result` | `boolean` | True if the string starts with `prefix`, false otherwise. |

## Examples

```lua
local text = "dark sword";
print(text:starts_with("dark")); -- Prints "true"
```

```lua
local text = "dark sword";
print(text:starts_with("f")); -- Prints "false"
```
