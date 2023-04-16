---
parent: crystal.scene
grand_parent: API Reference
nav_exclude: true
---

# CameraController:offset

Returns the draw offset applied when drawing through the [active camera](camera_controller_camera).

## Usage

```lua
camera_controller:offset()
```

### Returns

| Name | Type     | Description        |
| :--- | :------- | :----------------- |
| `x`  | `number` | Horizontal offset. |
| `y`  | `number` | Vertical offset.   |

## Examples

```lua
MyScene.draw = function(self)
  self.ecs = crystal.ECS:new();
  self.draw_system = self.ecs:add_system(crystal.DrawSystem);
  self.camera_controller = crystal.CameraController:new();
end

MyScene.draw = function(self)
  crystal.window.draw_native(function()
    self.camera_controller:draw(function()
      self.draw_system:draw_entities();
    end);
  end);

  love.graphics.push();
  love.graphics.translate(self.camera_controller:offset());
  self.ecs:notify_systems("draw_debug");
  love.graphics.pop();
end
```
