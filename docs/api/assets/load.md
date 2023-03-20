---
parent: crystal.assets
grand_parent: API Reference
nav_order: 1
---

# crystal.assets.load

Loads a game asset and its dependencies. Loading assets from disk is a slow operation and you should avoid calling this during gameplay. Loading an asset that is already loaded only updates the list of contexts requiring the asset.

## Usage

```lua
crystal.assets.load(path, context)
```

### Arguments

| Name      | Type     | Description                                                                     |
| :-------- | :------- | :------------------------------------------------------------------------------ |
| `path`    | `string` | Filesystem path to the asset on disk, relative to `main.lua`.                   |
| `context` | `string` | Reason why the asset was loaded. If unspecified, the value `"default"` is used. |

## Examples

```lua
crystal.assets.load("assets/", "preloading_all_assets");
print(crystal.assets.is_loaded("assets/hero.png")); -- Prints "true"
```
