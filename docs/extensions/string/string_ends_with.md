---
parent: String Extensions
grand_parent: Lua Extensions
nav_order: 1
---

# string.ends_with

Returns whether a string ends with a specifics substring.

## Usage

```lua
string.ends_with(suffix)
```

### Arguments

| Name     | Type     | Description              |
| :------- | :------- | :----------------------- |
| `suffix` | `string` | suffix to check against. |

### Returns

| Name     | Type      | Description                                               |
| :------- | :-------- | :-------------------------------------------------------- |
| `result` | `boolean` | True if the string ends with `suffix`, false otherwise. |

## Examples

```lua
local text = "dark sword";
print(text:ends_with("sword")); -- Prints "true"
```

```lua
local text = "dark sword";
print(text:ends_with("f")); -- Prints "false"
```
