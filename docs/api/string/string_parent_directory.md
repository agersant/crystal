---
parent: crystal.string
grand_parent: API Reference
nav_order: 1
---

# string.parent_directory

Returns a copy of a filesystem path without its final component.

## Usage

```lua
string.parent_directory(path)
```

### Arguments

| Name   | Type     | Description        |
| :----- | :------- | :----------------- |
| `path` | `string` | A filesystem path. |

### Returns

| Name        | Type     | Description                              |
| :---------- | :------- | :--------------------------------------- |
| `directory` | `string` | Filesystem path of the parent directory. |

## Examples

```lua
local path = "assets/sprites/evil_bat.png";
print(path:parent_directory(path)); -- Prints "assets/sprites"
```

```lua
local path = "assets";
print(path:parent_directory(path)); -- Prints ""
```

```lua
local path = "";
print(path:parent_directory(path)); -- Prints "nil"
```
