---
parent: crystal.scene
grand_parent: API Reference
nav_exclude: true
---

# CameraController:draw

Executes a drawing function wrapped with active camera offset and transitions.

## Usage

```lua
camera_controller:draw(draw_function)
```

### Arguments

| Name            | Type       | Description                        |
| :-------------- | :--------- | :--------------------------------- |
| `draw_function` | `function` | Function containing drawing logic. |

## Examples

```lua
MyScene.draw = function(self)
  self.camera_controller:draw(function()
    -- Scene drawing goes here
  end);
end
```
