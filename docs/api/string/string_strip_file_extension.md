---
parent: crystal.string
grand_parent: API Reference
nav_order: 1
---

# string.strip_file_extension

Returns a copy of a filesystem path without its file extension (if any).

## Usage

```lua
string.strip_file_extension(path)
```

### Arguments

| Name   | Type     | Description        |
| :----- | :------- | :----------------- |
| `path` | `string` | A filesystem path. |

### Returns

| Name       | Type     | Description                             |
| :--------- | :------- | :-------------------------------------- |
| `stripped` | `string` | Filesystem path without file extension. |

## Examples

```lua
local path = "monsters/evil_bat.png";
print(path:strip_file_extension()); -- Prints "monsters/evil_bat"
```

```lua
local path = "projectile.lua";
print(path:strip_file_extension()); -- Prints "projectile"
```
