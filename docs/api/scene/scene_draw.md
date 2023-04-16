---
parent: crystal.scene
grand_parent: API Reference
nav_exclude: true
---

# Scene:draw

Called every frame from [love.update](https://love2d.org/wiki/love.draw).

## Usage

```lua
scene:draw()
```

## Examples

```lua
local TitleScreen = Class("TitleScreen", crystal.Scene);

TitleScreen.draw = function(self)
  love.graphics.print("Legend of Sword", 100, 100);
end
```
