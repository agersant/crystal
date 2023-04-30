---
parent: API Reference
has_children: true
has_toc: false
---

# crystal.assets

## Overview

This modules fulfills two functions:

1. Parsing complex game assets like maps and spritesheets.
2. Loading/unloading game assets on demand.

The central piece of this module is [crystal.assets.get](get). This function returns an asset by path. All paths are relative to `main.lua`.

```lua
local rabbit = crystal.assets.get("assets/rabbit.png");
assert(rabbit:typeOf("Image"));
```

Because loading assets from disk is a slow operation, the first invocation of `crystal.assets.get("assets/rabbit.png")` will cause a performance hitch. To avoid this problem, you can explicitely load assets ahead of time:

```lua
crystal.prelude = function()
  local context = "game_startup";
  crystal.assets.load("assets/hero.png", context);
  crystal.assets.load("assets/rabbit.png", context);
  crystal.assets.load("assets/monster.png", context);
end
```

Unlike [crystal.assets.get](get), [crystal.assets.load](load) expects a second argument. The context `string` describes why we decided to load the asset, and comes into play when unloading assets. When calling [crystal.assets.unload](unload), the asset will only be effectively unloaded when it is no longer needed by any context.

If you call [crystal.assets.get](get) without loading the asset ahead of time, it will be loaded with the `"unplanned"` context.

Going back to our rabbit example, let's imagine `rabbit.png` is needed to decorate forests in our game, and also as a pet the player can summon. We want the rabbit assets to be loaded as long as the player is exploring forests, or they have the summoning spell equipped:

```lua
function on_forest_enter()
  crystal.assets.load("assets/rabbit.png", "forest");
  crystal.assets.load("assets/mushroom.png", "forest");
end

function on_forest_exit()
  crystal.assets.unload_context("forest");
end

function on_summon_spell_equipped()
  crystal.assets.load("assets/rabbit.png", "summon_spell");
  crystal.assets.load("assets/skeleton.png", "summon_spell");
end

function on_summon_spell_unequipped()
  crystal.assets.unload_context("summon_spell");
end
```

Assets don't have to be listed one by one either, you can load an entire directory in one call. For small games that can get away with loading all their assets at once, this might be all you need to do:

```lua
crystal.assets.load("assets/", "loading_the_whole_game");
```

## Built-in Asset Types

Crystal is able to load a variety of assets out of the box. It relies on file extensions to distinguish asset types. You can add support for more asset types using [crystal.assets.add_loader](add_loader).

### Directories

Loads all assets within a directory and its subdirectories.

```lua
crystal.assets.load("assets/forest", "entered_forest");
```

### Packages

Loads all assets listed in a file. This is useful when you want to load/unload a collection of assets that does not directly correspond to a directory.

In `assets/forest.lua`:

```lua
return {
  crystal_package = true,
  files = {
    "assets/images/forest_clouds_overlay.png",
    "assets/sprites/rabbit.lua",
    "assets/sprites/talking_tree.lua",
    "assets/maps/forest_map_1.lua",
    "assets/maps/forest_map_2.lua",
    "assets/maps/forest_map_3.lua",
  }
};
```

Somewhere in your game code:

```lua
crystal.assets.load("assets/forest.lua", "entered_forest");
```

### Images

Loads an image as a [love.Image](https://love2d.org/wiki/Image):

```lua
local rabbit = crystal.assets.get("assets/rabbit.png");
```

### Shaders

Loads a GLSL shader as a [love.Shader](https://love2d.org/wiki/Shader):

```lua
local blur = crystal.assets.get("assets/blur.glsl");
```

### Spritesheets

Loads a spritesheet containing sprite-based animations. See the [Spritesheet](spritesheet) documentation for details on the expected file format and usage examples.

```lua
local hero = crystal.assets.get("assets/hero.lua");
assert(hero:inherits_from(crystal.Spritesheet));
```

### Maps

Loads a 2D tile-based map. See the [Map](map) documentation for details on the expected file format and usage examples.

```lua
local boss_room = crystal.assets.get("assets/boss_room.lua");
assert(boss_room:inherits_from(crystal.Map));
```

## Functions

| Name                                            | Description                                                 |
| :---------------------------------------------- | :---------------------------------------------------------- |
| [crystal.assets.add_loader](add_loader)         | Adds support for a new asset type.                          |
| [crystal.assets.get](get)                       | Returns a reference to a game asset.                        |
| [crystal.assets.is_loaded](is_loaded)           | Returns whether a game asset is currently loaded.           |
| [crystal.assets.load](load)                     | Loads a game asset and its dependencies.                    |
| [crystal.assets.unload_all](unload_all)         | Unloads all game assets.                                    |
| [crystal.assets.unload_context](unload_context) | Unloads all game assets associated with a specific context. |
| [crystal.assets.unload](unload)                 | Unloads a game asset and its dependencies.                  |

## Classes

| Name                               | Description                                         |
| :--------------------------------- | :-------------------------------------------------- |
| [crystal.Animation](animation)     | Animation within a [Spritesheet](spritesheet).      |
| [crystal.Map](map)                 | 2D tile-based map.                                  |
| [crystal.Sequence](sequence)       | Sequence within an [Animation](animation).          |
| [crystal.Spritesheet](spritesheet) | Collection of sprite-based [animations](animation). |
| [crystal.Tileset](tileset)         | Collection of tiles to build [maps](map) with.      |
