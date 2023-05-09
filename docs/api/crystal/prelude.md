---
parent: crystal
grand_parent: API Reference
nav_order: 1
---

# crystal.prelude

Called upon game launch. This callback is executed during [love.load](https://love2d.org/wiki/love.load) and after every hot reload.

## Usage

```lua
crystal.prelude = function()
  -- your code here
end
```

## Examples

```lua
crystal.prelude = function()
  crystal.assets.load("assets/", "preload_all_assets");
end
```
