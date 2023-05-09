---
parent: crystal
grand_parent: API Reference
nav_order: 1
---

# crystal.player_start

Called upon game launch, after [crystal.prelude](prelude).

The intended use of this callback is to load an initial scene where the game starts.

## Usage

```lua
crystal.player_start = function()
  -- your code here
end
```

## Examples

```lua
crystal.player_start = function()
  crystal.scene.replace(TitleScreen:new());
end
```
