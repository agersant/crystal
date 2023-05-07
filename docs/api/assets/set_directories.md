---
parent: crystal.assets
grand_parent: API Reference
nav_order: 1
---

# crystal.assets.set_directories

Sets the location of asset directories.

When the game starts or is hot reloaded, Crystal loads all `.lua` files within the game directory. While this is useful to load all the source code for the game, it can also pull [maps](map), [spritesheets](spritesheet) or test data that is not relevant to start the game. To avoid this, you should call this function once in `"main.lua"` and specify where your game assets are stored. Crystal will then only load assets when requested via [crystal.assets.get](get) or [crystal.assets.load](load).

## Usage

```lua
crystal.assets.set_directories(directories)
```

### Arguments

| Name          | Type    | Description                                                               |
| :------------ | :------ | :------------------------------------------------------------------------ |
| `directories` | `table` | List of directory paths (relative to `main.lua`) where assets are stored. |

## Examples

```lua
-- In main.lua
require("crystal");

crystal.assets.set_directories({ "assets/", "test-data/" });
```
