---
parent: crystal.graphics
grand_parent: API Reference
nav_exclude: true
---

# AnimatedSprite:play_animation

Plays an animation sequence from its beginning.

{: .note}
Even though this function returns a [Thread](/crystal/api/script/thread), you can call it on entities that do not have a [ScriptRunner](/crystal/api/script/script_runner) component. The AnimatedSprite component manages its own Script, and updates it during [update_sprite_animation()](animated_sprite_update_sprite_animation).

## Usage

```lua
animated_sprite:play_animation(animation, sequence)
```

### Arguments

| Name        | Type     | Description                                                                                                                                              |
| :---------- | :------- | :------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `animation` | `string` | Name of the [Animation](/crystal/api/assets/animation) to play.                                                                                                              |
| `sequence`  | `string` | Name of the [Sequence](/crystal/api/assets/sequence) (within the animation) to play. This parameter may be omitted if the sequences contains a single sequence.              |

### Returns

| Name       | Type                                 | Description                                                          |
| :--------- | :----------------------------------- | :------------------------------------------------------------------- |
| `playback` | [Thread](/crystal/api/script/thread) | A thread which terminates when the animation ends or is interrupted. |

## Examples

```lua
local ecs = crystal.ECS:new();
local entity = ecs:spawn(crystal.Entity);
entity:add_component(crystal.ScriptRunner);
entity:add_component(crystal.AnimatedSprite, crystal.assets.get("assets/hero.json"));
entity:add_script(function(self)
  if self:play_animation("dance"):block() then
    print("Dance animation finished");
  else
    print("Dance animation was interrupted");
  end
end);
```
