---
parent: crystal.assets
grand_parent: API Reference
nav_order: 1
---

# crystal.assets.unload_context

Unloads all game assets associated with a specific context. Assets that are also loaded under a different context (or are dependencies of such assets) will remain in memory.

## Usage

```lua
crystal.assets.unload_context(context)
```

### Arguments

| Name      | Type     | Description                         |
| :-------- | :------- | :---------------------------------- |
| `context` | `string` | Context that is no longer relevant. |

## Examples

```lua
crystal.assets.load("sword.png", "battle");
crystal.assets.load("sword.png", "shop");
crystal.assets.is_loaded("sword.png"); -- Prints "true"

crystal.assets.unload_context("shop");
crystal.assets.is_loaded("sword.png"); -- Prints "true", sword is kept loaded by the "battle" context

crystal.assets.unload_context("battle");
crystal.assets.is_loaded("sword.png"); -- Prints "false"
```
