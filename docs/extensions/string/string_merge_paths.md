---
parent: crystal.string
grand_parent: Lua Extensions
nav_order: 1
---

# string.merge_paths

Merges two filesystem paths.

## Usage

```lua
string.merge_paths(path_a, path_b)
```

### Arguments

| Name     | Type     | Description        |
| :------- | :------- | :----------------- |
| `path_a` | `string` | A filesystem path. |
| `path_b` | `string` | A filesystem path. |

### Returns

| Name     | Type     | Description                    |
| :------- | :------- | :----------------------------- |
| `merged` | `string` | Result of the merge operation. |

## Examples

```lua
local sprites = "assets/sprites";
local evil_bat = "monsters/evil_bat.png";
print(string.merge(sprites, evil_bat)); -- Prints "assets/sprites/monsters/evil_bat.png"
```

```lua
local sprites = "assets/sprites";
local cave = "../maps/cave.lua";
print(string.merge(sprites, cave)); -- Prints "assets/maps/cave.lua"
```
