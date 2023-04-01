---
parent: crystal.graphics
grand_parent: API Reference
---

# crystal.AnimatedSprite

A [Drawable](drawable) component that can draw animations from a [Spritesheet](crystal/api/assets/spritesheet).

## Constructor

Like all other components, AnimatedSprite components are created by calling [Entity:add_component](/crystal/api/ecs/entity_add_component).

The constructor for AnimatedSprite expects one argument, the [Spritesheet](/crystal/api/assets/spritesheet) to play animations from.

## Methods

| Name                                                               | Description                                                  |
| :----------------------------------------------------------------- | :----------------------------------------------------------- |
| [play_animation](animated_sprite_play_animation)                   | Plays an animation from its beginning.                       |
| [set_animation](animated_sprite_set_animation)                     | Plays an animation, not restarting if it's already playing.  |
| [hitbox](animated_sprite_hitbox)                                   | Returns a named hitbox from the current animation frame.     |
| [update_sprite_animation](animated_sprite_update_sprite_animation) | Updates the current animation frame drawn by this component. |

## Examples

```lua
local ecs = crystal.ECS:new();
local entity = ecs:spawn(crystal.Entity);
entity:add_component(crystal.AnimatedSprite, crystal.assets.get("assets/hero.lua"));
entity:play_animation("idle");
```
