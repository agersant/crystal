---
parent: crystal.scene
grand_parent: API Reference
nav_exclude: true
---

# Scene:gamepad_released

Called from [love.gamepadreleased](https://love2d.org/wiki/love.gamepadreleased).

## Usage

```lua
scene:gamepad_released(joystick, button)
```

### Arguments

| Name       | Type                                                        | Description                           |
| :--------- | :---------------------------------------------------------- | :------------------------------------ |
| `joystick` | [love.Joystick](https://love2d.org/wiki/Joystick)           | Joystick where a button was released. |
| `button`   | [love.GamepadButton](https://love2d.org/wiki/GamepadButton) | Button that was released              |

## Examples

```lua
local MyScene = Class("MyScene", crystal.Scene);

MyScene.gamepad_released = function(self, joystick, button)
  print(button);
end
```
