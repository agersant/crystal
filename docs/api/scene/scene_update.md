---
parent: crystal.scene
grand_parent: API Reference
nav_exclude: true
---

# Scene:update

Called every frame from [love.update](https://love2d.org/wiki/love.update).

## Usage

```lua
scene:update(delta_time)
```

### Arguments

| Name         | Type     | Description               |
| :----------- | :------- | :------------------------ |
| `delta_time` | `number` | Time elapsed, in seconds. |

## Examples

```lua
local MyScene = Class("MyScene", crystal.Scene);

MyScene.init = function(self)
  self.time_elapsed = 0;
end

MyScene.update = function(self, delta_time)
  self.time_elapsed = self.time_elapsed + delta_time;
  print(self.time_elapsed);
end
```
