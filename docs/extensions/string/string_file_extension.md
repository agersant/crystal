---
parent: crystal.string
grand_parent: Lua Extensions
nav_order: 1
---

# string.file_extension

Returns the file extension from a filesystem path.

## Usage

```lua
string.file_extension(path)
```

### Arguments

| Name   | Type     | Description        |
| :----- | :------- | :----------------- |
| `path` | `string` | A filesystem path. |

### Returns

| Name        | Type     | Description                               |
| :---------- | :------- | :---------------------------------------- |
| `extension` | `string` | File extension without the `.`, or `nil`. |

## Examples

```lua
local path = "assets/characters/tarkus.png";
print(path:file_extension()); -- Prints "png"
```

```lua
local path = "assets/characters";
print(path:file_extension()); -- Prints "nil"
```
