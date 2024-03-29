---
parent: API Reference
has_children: true
has_toc: false
---

# crystal.graphics

This modules contains components related to displaying graphics. It is recommended to use them in combination with a [DrawSystem](draw_system).

Entities can have any number of [Drawable](drawable) components on them. The order in which they are drawn is decided in part by the presence of a [DrawOrder](draw_order) component, and in part by the [draw order modifier](drawable_set_draw_order_modifier) settings on the drawable. The resulting order may intertwine drawables from multiple entities.

Not every [love.Drawable](https://love2d.org/wiki/Drawable) has a corresponding Drawable component. However, you are encouraged to make your own Drawable classes when necessary. If making classes is too much ceremony, you can also overwrite the [draw](drawable_draw) method on Drawable instances.

## Classes

| Name                                      | Description                                                                                                             |
| :---------------------------------------- | :---------------------------------------------------------------------------------------------------------------------- |
| [crystal.AnimatedSprite](animated_sprite) | A [Drawable](drawable) component that can draw animations from a [Spritesheet](crystal/api/assets/spritesheet).         |
| [crystal.Color](color)                    | A color, with RGBA components.                                                                                          |
| [crystal.Drawable](drawable)              | A base [Component](/crystal/api/ecs/component) for anything that can draw on the screen.                                |
| [crystal.DrawEffect](draw_effect)         | A [Component](/crystal/api/ecs/component) that can affect how [Drawable](drawable) components on this entity are drawn. |
| [crystal.DrawOrder](draw_order)           | A [Component](/crystal/api/ecs/component) that determines in what order entities are drawn.                             |
| [crystal.DrawSystem](draw_system)         | A [System](/crystal/api/ecs/system) that updates and draws [Drawable](drawable) components.                             |
| [crystal.Sprite](sprite)                  | A [Drawable](drawable) component that can draw a [love.Texture](https://love2d.org/wiki/Texture).                       |
| [crystal.SpriteBatch](sprite_batch)       | A [Drawable](drawable) component that can draw a [love.SpriteBatch](https://love2d.org/wiki/SpriteBatch).               |
| [crystal.WorldWidget](world_widget)       | A [Drawable](drawable) component that can draw a UI [Widget](/crystal/api/ui/widget).                                   |
