---
parent: crystal
grand_parent: API Reference
nav_order: 1
---

# crystal.developer_start

Override of [crystal.player_start](player_start) for development builds.

If you give a value to this callback, it is called instead of [crystal.player_start](player_start) in development builds ([not fused](https://love2d.org/wiki/love.filesystem.isFused)).

The intended use of this callback is to load the scene you are working on. This can be changed frequently as you work on different portions of your game, or even between hot reloads.

## Usage

```lua
crystal.developer_start = function()
  -- your code here
end
```

## Examples

```lua
crystal.developer_start = function()
  crystal.scene.replace(FinalBossScene:new());
end
```
