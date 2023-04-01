---
parent: crystal.graphics
grand_parent: API Reference
nav_exclude: true
---

# AnimatedSprite:update_sprite_animation

Updates the current animation frame drawn by this component.

{: .note}
When using a [DrawSystem](draw_system), you never have to call this function yourself.

## Usage

```lua
animated_sprite:update_sprite_animation(delta_time)
```

### Arguments

| Name         | Type     | Description            |
| :----------- | :------- | :--------------------- |
| `delta_time` | `number` | Delta time in seconds. |
