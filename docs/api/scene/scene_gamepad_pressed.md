---
parent: crystal.scene
grand_parent: API Reference
nav_exclude: true
---

# Scene:gamepad_pressed

Called from [love.gamepadpressed](https://love2d.org/wiki/love.gamepadpressed).

## Usage

```lua
scene:gamepad_pressed(joystick, button)
```

### Arguments

| Name       | Type                                                        | Description                          |
| :--------- | :---------------------------------------------------------- | :----------------------------------- |
| `joystick` | [love.Joystick](https://love2d.org/wiki/Joystick)           | Joystick where a button was pressed. |
| `button`   | [love.GamepadButton](https://love2d.org/wiki/GamepadButton) | Button that was pressed              |

## Examples

```lua
local MyScene = Class("MyScene", crystal.Scene);

MyScene.gamepad_pressed = function(self, joystick, button)
  print(button);
end
```
