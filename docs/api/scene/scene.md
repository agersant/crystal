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

```lua
crystal.Scene:new()
```

## Callbacks

| Name                                       | Description                                                                                                                                                  |
| :----------------------------------------- | :----------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [action_pressed](scene_action_pressed)     | Called from [love.update](https://love2d.org/wiki/love.update) when a player presses a key or button [bound to an action](/crystal/api/input/set_bindings).  |
| [action_released](scene_action_released)   | Called from [love.update](https://love2d.org/wiki/love.update) when a player releases a key or button [bound to an action](/crystal/api/input/set_bindings). |
| [draw](scene_draw)                         | Called every frame from [love.draw](https://love2d.org/wiki/love.draw).                                                                                      |
| [gamepad_pressed](scene_gamepad_pressed)   | Called from [love.gamepadpressed](https://love2d.org/wiki/love.gamepadpressed).                                                                              |
| [gamepad_released](scene_gamepad_released) | Called from [love.gamepadreleased](https://love2d.org/wiki/love.gamepadreleased).                                                                            |
| [key_pressed](scene_key_pressed)           | Called from [love.keypressed](https://love2d.org/wiki/love.keypressed).                                                                                      |
| [key_released](scene_key_released)         | Called from [love.keyreleased](https://love2d.org/wiki/love.keyreleased).                                                                                    |
| [mouse_moved](scene_mouse_moved)           | Called from [love.mousemoved](https://love2d.org/wiki/love.mousemoved).                                                                                      |
| [mouse_pressed](scene_mouse_pressed)       | Called from [love.mousepressed](https://love2d.org/wiki/love.mousepressed).                                                                                  |
| [mouse_released](scene_mouse_released)     | Called from [love.mousereleased](https://love2d.org/wiki/love.mousereleased).                                                                                |
| [update](scene_update)                     | Called every frame from [love.update](https://love2d.org/wiki/love.update).                                                                                  |

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
