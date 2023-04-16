---
parent: crystal.scene
grand_parent: API Reference
nav_exclude: true
---

# CameraController:move_to

Interpolates to another camera. Calling this function cancels any in-progress [move_to](camera_controller_move_to) or [cut_to](camera_controller_cut_to) operation.

## Usage

```lua
camera_controller:move_to(new_camera, duration, easing)
```

### Arguments

| Name         | Type                     | Description                                                          |
| :----------- | :----------------------- | :------------------------------------------------------------------- |
| `new_camera` | [crystal.Camera](camera) | Camera to cut to.                                                    |
| `duration`   | `number`                 | Duration of the move, in seconds.                                    |
| `easing`     | `function`               | [Easing function](/crystal/extensions/math) to smooth movement with. |

### Returns

| Name     | Type                                         | Description                                        |
| :------- | :------------------------------------------- | :------------------------------------------------- |
| `thread` | [crystal.Thread](/crystal/api/script/thread) | A thread that completes when movement is finished. |

## Examples

```lua
local old_camera = crystal.Camera:new();
old_camera.position = function() return 0, 300; end;

local new_camera = crystal.Camera:new();
new_camera.position = function() return 100, 200; end;

local camera_controller = crystal.CameraController:new();
self.camera_controller:cut_to(old_camera);
self.camera_controller:move_to(new_camera, 0.5, math.ease_in_out_cubic);
```
