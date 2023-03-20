---
parent: crystal.assets
grand_parent: API Reference
nav_order: 1
---

# crystal.assets.is_loaded

Returns whether a game asset is currently loaded.

## Usage

```lua
crystal.assets.is_loaded(path)
```

### Arguments

| Name   | Type     | Description                                                   |
| :----- | :------- | :------------------------------------------------------------ |
| `path` | `string` | Filesystem path to the asset on disk, relative to `main.lua`. |

### Returns

| Name     | Type      | Description                                                  |
| :------- | :-------- | :----------------------------------------------------------- |
| `loaded` | `boolean` | True is Crystal is currently keep a reference to this asset. |

## Examples

```lua
print(crystal.assets.is_loaded("sword_image.png")); -- Prints "false"
crystal.assets.load("sword_image.png");
print(crystal.assets.is_loaded("sword_image.png")); -- Prints "true"
crystal.assets.unload("sword_image.png");
print(crystal.assets.is_loaded("sword_image.png")); -- Prints "false"
```
