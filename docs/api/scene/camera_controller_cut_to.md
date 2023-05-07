---
parent: crystal.scene
grand_parent: API Reference
nav_exclude: true
---

# CameraController:cut_to

Cuts to another camera, playing [transitions](transition) in-between. Calling this function cancels any in-progress [move_to](camera_controller_move_to) or [cut_to](camera_controller_cut_to) operation.

## Usage

```lua
camera_controller:cut_to(new_camera, ...)
```

### Arguments

| Name         | Type                     | Description          |
| :----------- | :----------------------- | :------------------- |
| `new_camera` | [Camera](camera)         | Camera to cut to.    |
| `...`        | [Transition](transition) | Transitions to play. |

### Returns

| Name     | Type                                 | Description                                                |
| :------- | :----------------------------------- | :--------------------------------------------------------- |
| `thread` | [Thread](/crystal/api/script/thread) | A thread that completes when all transitions are finished. |

## Examples

```lua
local old_camera = crystal.Camera:new();
old_camera.position = function() return 0, 300; end;

local new_camera = crystal.Camera:new();
new_camera.position = function() return 100, 200; end;

local camera_controller = crystal.CameraController:new();
self.camera_controller:cut_to(old_camera);
self.camera_controller:cut_to(
  new_camera,
  crystal.Transition.FadeToBlack:new(),
  crystal.Transition.FadeFromBlack:new()
);
```
