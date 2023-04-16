---
parent: crystal.scene
grand_parent: API Reference
nav_order: 2
---

# crystal.CameraController

Utility class to handle multiple cameras in a scene.

## Constructor

```lua
crystal.CameraController:new()
```

## Methods

| Name                                 | Description                                                                    |
| :----------------------------------- | :----------------------------------------------------------------------------- |
| [camera](camera_controller_camera)   | Returns the current camera.                                                    |
| [cut_to](camera_controller_cut_to)   | Cuts to another camera, playing [transitions](transition) in-between.          |
| [draw](camera_controller_draw)       | Executes a drawing function wrapped with active camera offset and transitions. |
| [move_to](camera_controller_move_to) | Interpolates to another camera.                                                |
| [offset](camera_controller_offset)   | Returns the offset applied when drawing through the active camera.             |
| [update](camera_controller_update)   | Updates active camera movement or transitions.                                 |

## Examples

```lua
local MyScene = Class("MyScene", crystal.Scene);

MyScene.init = function(self)
  self.camera_controller = crystal.CameraController:new();
end

MyScene.update = function(self, dt)
  self.camera_controller:update(dt);
end

MyScene.draw = function(self)
  self.camera_controller:draw(function()
    -- Scene drawing goes here
  end);
end

MyScene.play_cutscene = function(self)
  local new_camera = crystal.Camera:new();
  new_camera.position = function() return 100, 200; end;
  self.camera_controller:cut_to(
    new_camera,
    crystal.Transition.FadeToBlack:new(),
    crystal.Transition.FadeFromBlack:new()
  );
  -- More cutscene logic goes here
end
```
