---
parent: crystal.scene
grand_parent: API Reference
nav_order: 2
---

# crystal.Camera

Base class for cameras to inherit from. [Camera controllers](camera_controller) expect cameras to derive from this class.

{: .note}
This class is of little use on its own. You should implement subclasses fitting your game and override the `position` method accordingly.

## Constructor

The `Camera` constructor expects no arguments.

## Methods

| Name       | Description                                                                                             |
| :--------- | :------------------------------------------------------------------------------------------------------ |
| `position` | Returns the location that should be centered in the game window. Default implementation returns `0, 0`. |

## Examples

This example defines a class for cameras that never move:

```lua
local FixedCamera = Class("FixedCamera", crystal.Camera);

FixedCamera.init = function(self, x, y)
  self.x = x;
  self.y = y;
end

FixedCamera.position = function(self)
  return self.x, self.y;
end

return FixedCamera;
```

This example defines a class for a camera following a player character

```lua
local PlayerCamera = Class("PlayerCamera", crystal.Camera);

PlayerCamera.init = function(self, player)
  self.player = player;
end

PlayerCamera.position = function(self)
  return self.player:position();
end

return PlayerCamera;
```
