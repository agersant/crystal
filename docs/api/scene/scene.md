---
parent: crystal.scene
grand_parent: API Reference
nav_order: 2
---

# crystal.Scene

Game state or level which can draw to the screen. Crystal keeps track of the currently active scene and forwards LÖVE callbacks (update, draw, etc.) to it.

{: .note}
This class is of little use on its own. You should implement subclasses fitting your game and override some of the callbacks.

## Constructor

The `Scene` constructor expects no arguments.

## Callbacks

| Name                                       | Description                                                                       |
| :----------------------------------------- | :-------------------------------------------------------------------------------- |
| [draw](scene_draw)                         | Called every frame from [love.update](https://love2d.org/wiki/love.draw).         |
| [gamepad_pressed](scene_gamepad_pressed)   | Called from [love.gamepadpressed](https://love2d.org/wiki/love.gamepadpressed).   |
| [gamepad_released](scene_gamepad_released) | Called from [love.gamepadreleased](https://love2d.org/wiki/love.gamepadreleased). |
| [key_pressed](scene_key_pressed)           | Called from [love.keypressed](https://love2d.org/wiki/love.keypressed).           |
| [key_released](scene_key_released)         | Called from [love.keyreleased](https://love2d.org/wiki/love.keyreleased).         |
| [update](scene_update)                     | Called every frame from [love.update](https://love2d.org/wiki/love.update).       |

## Examples

```lua
local TitleScreen = Class("TitleScreen", crystal.Scene);

TitleScreen.draw = function(self)
  love.graphics.print("Legend of Sword", 100, 100);
end

TitleScreen.key_pressed = function(self)
  crystal.scene.replace(
  MyGameScene:new(),
    crystal.Transition.FadeToBlack:new(),
    crystal.Transition.FadeFromBlack:new()
  );
end
```
