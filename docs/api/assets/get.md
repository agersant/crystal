---
parent: crystal.assets
grand_parent: API Reference
nav_order: 1
---

# crystal.assets.get

Returns a reference to a game asset.

{: .note}
Assets should be loaded via [crystal.assets.load](load) before being accessed with this method. Calling this method to access an asset that has yet to loaded will load it from disk under the `"unplanned"` [context](load).

## Usage

```lua
crystal.assets.get(path)
```

### Arguments

| Name   | Type     | Description                                                   |
| :----- | :------- | :------------------------------------------------------------ |
| `path` | `string` | Filesystem path to the asset on disk, relative to `main.lua`. |

### Returns

| Name    | Type  | Description                       |
| :------ | :---- | :-------------------------------- |
| `asset` | `any` | Reference to the asset in memory. |

## Examples

```lua
local sword_image = crystal.assets.get("sword_image.png");
```

```lua
local hero_spritesheet = crystal.assets.get("hero.lua");
```
