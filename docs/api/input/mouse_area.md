---
parent: crystal.input
grand_parent: API Reference
nav_order: 2
---

# crystal.MouseArea

A [Component](/crystal/api/ecs/component) which allows an entity to respond to mouse hovers and click-related events.

This component inherits from [crystal.Drawable](/crystal/api/graphics/drawable), which allows you to manipulate is draw order and offset. More importantly, this also means this component requires a [crystal.DrawSystem](/crystal/api/graphics/draw_system) to function.

## Constructor

Like all other components, MouseArea components are created by calling [Entity:add_component](/crystal/api/ecs/entity_add_component).

The constructor for InputListener expects one argument, the [love.Shape](https://love2d.org/wiki/Shape) of the interactive area.

## Methods

| Name                                                    | Description                                                                            |
| :------------------------------------------------------ | :------------------------------------------------------------------------------------- |
| [disable_mouse](mouse_area_disable_mouse)               | Prevents this component from being the mouse target or receiving click-related events. |
| [enable_mouse](mouse_area_enable_mouse)                 | Allows this component to be the mouse target and receive click-related events.         |
| [is_mouse_over](mouse_area_is_mouse_over)               | Returns whether this component currently is the mouse target.                          |
| [mouse_area_shape](mouse_area_mouse_area_shape)         | Returns the shape of the surface that responds to the mouse.                           |
| [set_mouse_area_shape](mouse_area_set_mouse_area_shape) | Sets the shape of the surface that responds to the mouse.                              |

## Callbacks

| Name                                                          | Description                                                                                                     |
| :------------------------------------------------------------ | :-------------------------------------------------------------------------------------------------------------- |
| [on_mouse_clicked](mouse_area_on_mouse_clicked)               | Called when the left mouse button is pressed and then released in a small area within this component.           |
| [on_mouse_double_clicked](mouse_area_on_mouse_double_clicked) | Called when the left mouse button is pressed, released and pressed again in a small area within this component. |
| [on_mouse_out](mouse_area_on_mouse_out)                       | Called when this component stops being the mouse target.                                                        |
| [on_mouse_over](mouse_area_on_mouse_over)                     | Called when this component becomes the mouse target.                                                            |
| [on_mouse_pressed](mouse_area_on_mouse_pressed)               | Called when a mouse button is pressed within this component.                                                    |
| [on_mouse_released](mouse_area_on_mouse_released)             | Called when a mouse button is released within this component.                                                   |
| [on_mouse_right_clicked](mouse_area_on_mouse_right_clicked)   | Called when the right mouse button is pressed and then released in a small area within this component.          |

## Examples

```lua
local ecs = crystal.ECS:new();
local input_system = ecs:add_system(crystal.InputSystem);
local draw_system = ecs:add_system(crystal.DrawSystem);

local entity = ecs:spawn(crystal.Entity);
local mouse_area = entity:add_component(crystal.MouseArea, love.physics.newCircleShape(10));

mouse_area.on_mouse_over = function(self, player_index)
  print("Mouse is inside");
end

mouse_area.on_mouse_out = function(self, player_index)
  print("Mouse is no longer inside");
end

mouse_area.on_mouse_clicked = function(self, player_index)
  print("Clicked!");
end
```
