---
parent: crystal.graphics
grand_parent: API Reference
nav_exclude: true
---

# AnimatedSprite:set_animation

Plays an animation sequence, *not* restarting if the same sequence is already playing.

## Usage

```lua
animated_sprite:set_animation(animation, sequence)
```

### Arguments

| Name        | Type     | Description                                                                                                                                              |
| :---------- | :------- | :------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `animation` | `string` | Name of the [Animation](/crystal/api/assets/animation) to play.                                                                                                              |
| `sequence`  | `string` | Name of the [Sequence](/crystal/api/assets/sequence) (within the animation) to play. This parameter may be omitted if the sequences contains a single sequence.              |

## Examples

```lua
local ecs = crystal.ECS:new();
local hero = ecs:spawn(crystal.Entity);
hero:add_component(crystal.Body);
hero:add_component(crystal.Movement);
hero:add_component(crystal.ScriptRunner);
hero:add_component(crystal.AnimatedSprite, crystal.assets.get("assets/hero.json"));
hero:add_script(function(self)
  while true do
    if self:heading() then
      self:set_animation("walk");
    else
      self:set_animation("idle");
    end
  self:wait_frame();
  end
end);
```
