---
parent: crystal.scene
grand_parent: API Reference
nav_exclude: true
---

# CameraController:camera

Returns the current camera.

- If a [move_to](camera_controller_move_to) operation is in progress, this function returns the camera being moved towards.
- If a [cut_to](camera_controller_cut_to) operation is in progress, this function returns the camera that was last drawn by the active transition.

## Usage

```lua
camera_controller:camera()
```

### Returns

| Name             | Type             | Description         |
| :--------------- | :--------------- | :------------------ |
| `current_camera` | [Camera](camera) | The current camera. |

## Examples

```lua
local camera_1 = crystal.Camera:new();
local camera_2 = crystal.Camera:new();
local camera_controller = crystal.CameraController:new();
camera_controller:cut_to(camera_1);
assert(camera_controller:camera() == camera_1);
camera_controller:move_to(camera_2, 0.5, math.ease_in_quadractic);
assert(camera_controller:camera() == camera_2);
```
