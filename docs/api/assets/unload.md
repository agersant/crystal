---
parent: crystal.assets
grand_parent: API Reference
nav_order: 1
---

# crystal.assets.unload

Unloads a game asset and its dependencies. Assets that are also loaded under a different context (or are dependencies of such assets) will remain loaded.

## Usage

```lua
crystal.assets.unload(path, context)
```

### Arguments

| Name      | Type     | Description                                                                     |
| :-------- | :------- | :------------------------------------------------------------------------------ |
| `path`    | `string` | Filesystem path to the asset on disk, relative to `main.lua`.                   |
| `context` | `string` | Reason why the asset was loaded. If unspecified, the value `"default"` is used. |

## Examples

```lua
crystal.assets.load("sword.png", "battle");
crystal.assets.load("sword.png", "shop");
crystal.assets.is_loaded("sword.png"); -- Prints "true"

crystal.assets.unload("sword.png", "shop");
crystal.assets.is_loaded("sword.png"); -- Prints "true", sword is kept loaded by the "battle" context

crystal.assets.unload("sword.png", "battle");
crystal.assets.is_loaded("sword.png"); -- Prints "false"
```
