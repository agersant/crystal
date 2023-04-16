---
parent: crystal.scene
grand_parent: API Reference
nav_exclude: true
---

# Scene:key_pressed

Called from [love.keypressed](https://love2d.org/wiki/love.keypressed).

## Usage

```lua
scene:key_pressed(key, scan_code, is_repeat)
```

### Arguments

| Name        | Type                                                    | Description                                                                                                   |
| :---------- | :------------------------------------------------------ | :------------------------------------------------------------------------------------------------------------ |
| `key`       | [love.KeyConstant](https://love2d.org/wiki/KeyConstant) | Character of the pressed key.                                                                                 |
| `scan_code` | [love.KeyConstant](https://love2d.org/wiki/Scancode)    | The scancode representing the pressed key.                                                                    |
| `is_repeat` | `boolean`                                               | Whether this keypress event is a repeat. The delay between key repeats depends on the user's system settings. |

## Examples

```lua
local MyScene = Class("MyScene", crystal.Scene);

MyScene.key_pressed = function(self, key, scan_code, is_repeat)
  print(key);
end
```
