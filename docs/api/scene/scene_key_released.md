---
parent: crystal.scene
grand_parent: API Reference
nav_exclude: true
---

# Scene:key_released

Called from [love.keyreleased](https://love2d.org/wiki/love.keyreleased).

## Usage

```lua
scene:key_released(key, scan_code)
```

### Arguments

| Name        | Type                                                    | Description                                 |
| :---------- | :------------------------------------------------------ | :------------------------------------------ |
| `key`       | [love.KeyConstant](https://love2d.org/wiki/KeyConstant) | Character of the released key.              |
| `scan_code` | [love.KeyConstant](https://love2d.org/wiki/Scancode)    | The scancode representing the released key. |

## Examples

```lua
local MyScene = Class("MyScene", crystal.Scene);

MyScene.key_released = function(self, key, scan_code)
  print(key);
end
```
