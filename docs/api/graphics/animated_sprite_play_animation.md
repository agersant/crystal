---
parent: crystal.graphics
grand_parent: API Reference
nav_exclude: true
---

# AnimatedSprite:play_animation

Plays an animation from its beginning.

{: .note}
Even though this function returns a [Thread](/crystal/api/script/thread), you can call on entities that do not have a [ScriptRunner](/crystal/api/script/script_runner) component. The AnimatedSprite component manages its own Script, and updates it via [update_sprite_animation()](animated_sprite_update_sprite_animation).

## Usage

```lua
animated_sprite:play_animation(animation, rotation)
```

### Arguments

| Name        | Type     | Description                                                                                                                                              |
| :---------- | :------- | :------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `animation` | `string` | Name of the animation to play.                                                                                                                           |
| `rotation`  | `number` | Direction the character is facing (in radians), used to select the most applicable [Sequence](/crystal/api/assets/sequence). Defaults to 0 when omitted. |

### Returns

| Name       | Type                                 | Description                                                          |
| :--------- | :----------------------------------- | :------------------------------------------------------------------- |
| `playback` | [Thread](/crystal/api/script/thread) | A thread which terminates when the animation ends or is interrupted. |

## Examples

```lua
local ecs = crystal.ECS:new();
local entity = ecs:spawn(crystal.Entity);
entity:add_component(crystal.ScriptRunner);
entity:add_component(crystal.AnimatedSprite, crystal.assets.get("assets/hero.lua"));
entity:add_script(function(self)
  if self:join(self:play_animation("dance")) then
    print("Dance animation finished");
  else
    print("Dance animation did not complete");
  end
end);
```
