---
parent: crystal.graphics
grand_parent: API Reference
nav_exclude: true
---

# AnimatedSprite:set_animation

Plays an animation, not restarting if it's already playing.

## Usage

```lua
animated_sprite:set_animation(animation, rotation)
```

### Arguments

| Name        | Type     | Description                                                                                                                                              |
| :---------- | :------- | :------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `animation` | `string` | Name of the animation to play.                                                                                                                           |
| `rotation`  | `number` | Direction the character is facing (in radians), used to select the most applicable [Sequence](/crystal/api/assets/sequence). Defaults to 0 when omitted. |

## Examples

```lua
local ecs = crystal.ECS:new();
local hero = ecs:spawn(crystal.Entity);
hero:add_component(crystal.Body);
hero:add_component(crystal.Movement);
hero:add_component(crystal.ScriptRunner);
hero:add_component(crystal.AnimatedSprite, crystal.assets.get("assets/hero.lua"));
hero:add_script(function(self)
  while true do
    if self:heading() then
      self:set_animation("walk", self:rotation());
    else
      self:set_animation("idle", self:rotation());
    end
	self:wait_frame();
  end
end);
```
