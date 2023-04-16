---
parent: crystal.scene
grand_parent: API Reference
nav_exclude: true
---

# CameraController:update

Updates active camera movement or transitions. When using a CameraController, you should call this function every frame.

{: .note}
If you have unrelated scripts [joining](/crystal/api/script/thread_join) on threads owned by CameraController (such as threads returned by [CameraController:cut_to](camera_controller_cut_to)), they may resume execution during this call.

## Usage

```lua
camera_controller:update(delta_time)
```

### Arguments

| Name         | Type     | Description                 |
| :----------- | :------- | :-------------------------- |
| `delta_time` | `number` | Frame duration, in seconds. |

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
```
