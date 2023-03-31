---
parent: crystal.graphics
grand_parent: API Reference
nav_exclude: true
---

# SpriteBatch:set_sprite_batch

Sets the [love.SpriteBatch](https://love2d.org/wiki/SpriteBatch) to draw.

## Usage

```lua
sprite_batch:set_sprite_batch(batch)
```

### Arguments

| Name    | Type                                                    | Description               |
| :------ | :------------------------------------------------------ | :------------------------ |
| `batch` | [love.SpriteBatch](https://love2d.org/wiki/SpriteBatch) | The sprite batch to draw. |

## Examples

```lua
local ecs = crystal.ECS:new();
local entity = ecs:spawn(crystal.Entity);
local sprite_batch = love.graphics.newSpriteBatch(crystal.assets.get("assets/tiles.png"), 200);
entity:add_component(crystal.SpriteBatch, sprite_batch);

local other_sprite_batch = love.graphics.newSpriteBatch(crystal.assets.get("assets/fruits.png"), 40);
entity:set_sprite_batch(other_sprite_batch);
```
