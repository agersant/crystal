---
parent: crystal.assets
grand_parent: API Reference
nav_order: 1
---

# crystal.assets.unload_all

Unloads all game assets. This makes crystal drop its references to every asset it has loaded.

## Usage

```lua
crystal.assets.unload_all()
```

## Examples

```lua
crystal.assets.load("assets/forest/");
crystal.assets.load("assets/mountain/");
print(crystal.assets.is_loaded("assets/forest/tree.png")); -- Prints "true"
print(crystal.assets.is_loaded("assets/mountain/snow.png")); -- Prints "true"

crystal.assets.unload_all();
print(crystal.assets.is_loaded("assets/forest/tree.png")); -- Prints "false"
print(crystal.assets.is_loaded("assets/mountain/snow.png")); -- Prints "false"
```
