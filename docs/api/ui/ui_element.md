---
parent: crystal.ui
grand_parent: API Reference
nav_order: 2
---

# crystal.UIElement

Base class for all UI building blocks.

Elements of this class draw nothing and cannot have children.

## Constructor

```lua
crystal.UIElement:new()
```

## Methods

### Lifecycle

| Name                                  | Description                                                                     |
| :------------------------------------ | :------------------------------------------------------------------------------ |
| [update_tree](ui_element_update_tree) | Computes layout and runs update logic for this element and all its descendants. |
| [draw_tree](ui_element_draw_tree)     | Draws this element and all its descendants.                                     |

### Hierarchy

| Name                                                | Description                                                                              |
| :-------------------------------------------------- | :--------------------------------------------------------------------------------------- |
| [is_root](ui_element_is_root)                       | Returns whether this element is the root of its element tree.                            |
| [is_within](ui_element_is_within)                   | Returns whether this element is a descendant of another one.                             |
| [joint](ui_element_joint)                           | Returns the [joint](joint) specifying how this element should be laid out by its parent. |
| [parent](ui_element_parent)                         | Returns this element's parent.                                                           |
| [remove_from_parent](ui_element_remove_from_parent) | Removes this element from its parent.                                                    |
| [root](ui_element_root)                             | Returns the root of this element's tree.                                                 |

### Layout

| Name                    | Description                                                                             |
| :---------------------- | :-------------------------------------------------------------------------------------- |
| [size](ui_element_size) | Returns this element's width and height, as computed during [update_tree](update_tree). |

### Rendering

| Name                                              | Description                                                       |
| :------------------------------------------------ | :---------------------------------------------------------------- |
| [color](ui_element_color)                         | Returns this element's color multiplier.                          |
| [opacity](ui_element_opacity)                     | Returns this element's opacity.                                   |
| [pivot](ui_element_pivot)                         | Returns this element's pivot, around which it scales and rotates. |
| [rotation](ui_element_rotation)                   | Returns this element's rotation angle.                            |
| [scale](ui_element_scale)                         | Returns this element's scaling factors.                           |
| [set_color](ui_element_set_color)                 | Sets this element's color multiplier.                             |
| [set_opacity](ui_element_set_opacity)             | Sets this element's opacity.                                      |
| [set_pivot_x](ui_element_set_pivot_x)             | Sets the horizontal position of this element's pivot.             |
| [set_pivot_y](ui_element_set_pivot_y)             | Sets the vertical position of this element's pivot.               |
| [set_pivot](ui_element_set_pivot)                 | Sets this element's pivot, around which it scales and rotates.    |
| [set_rotation](ui_element_set_rotation)           | Sets this element's rotation angle.                               |
| [set_scale_x](ui_element_set_scale_x)             | Sets this element's horizontal scaling factor.                    |
| [set_scale_y](ui_element_set_scale_y)             | Sets this element's vertical scaling factor.                      |
| [set_scale](ui_element_set_scale)                 | Sets this element's scaling factors.                              |
| [set_translation_x](ui_element_set_translation_x) | Sets this element's horizontal translation.                       |
| [set_translation_y](ui_element_set_translation_y) | Sets this element's vertical translation.                         |
| [set_translation](ui_element_set_translation)     | Sets this element's translation.                                  |
| [translation](ui_element_translation)             | Returns this element's translation.                               |

### Input Handling

| Name                                              | Description                                                                                          |
| :------------------------------------------------ | :--------------------------------------------------------------------------------------------------- |
| [action_pressed](ui_element_action_pressed)       | Executes callbacks [bound](ui_element_bind_input) to an action being pressed.                        |
| [action_released](ui_element_action_pressed)      | Executes callbacks [bound](ui_element_bind_input) to an action being released.                       |
| [active_bindings](ui_element_active_bindings)     | Returns a table of active input bindings within this element.                                        |
| [bind_input](ui_element_bind_input)               | Binds an input action to a callback function.                                                        |
| [can_receive_input](ui_element_can_receive_input) | Returns whether this element can currently receive input actions.                                    |
| [focus_tree](ui_element_focus_tree)               | Gives focus to the first focusable element within this one (including itself).                       |
| [focus](ui_element_focus)                         | Gives focus to this element.                                                                         |
| [focused_element](ui_element_focused_element)     | Returns a focused element within this one.                                                           |
| [is_active](ui_element_is_active)                 | Returns whether this element is active.                                                              |
| [is_focusable](ui_element_is_focusable)           | Returns whether this element is focusable.                                                           |
| [is_focused](ui_element_is_focused)               | Returns whether this element is currently focused by a specific player.                              |
| [player_index](ui_element_player_index)           | Returns which player is allowed to focus and emit inputs to this element and its descendents.        |
| [set_active](ui_element_set_active)               | Sets whether this element is active.                                                                 |
| [set_focusable](ui_element_set_focusable)         | Sets whether this element is focusable.                                                              |
| [set_player_index](ui_element_set_player_index)   | Sets or clears which player is allowed to focus and emit inputs to this element and its descendents. |
| [unbind_input](ui_element_unbind_input)           | Removes a previously bound input callback.                                                           |
| [unfocus_tree](ui_element_unfocus_tree)           | Unfocuses all elements within this one (including itself).                                           |

### Mouse Interactions

| Name                                            | Description                                                                 |
| :---------------------------------------------- | :-------------------------------------------------------------------------- |
| [disable_mouse](ui_element_disable_mouse)       | Prevents this element from being the mouse target.                          |
| [enable_mouse](ui_element_enable_mouse)         | Allows this element to be the mouse target when hovered.                    |
| [is_mouse_enabled](ui_element_is_mouse_enabled) | Returns whether this element can be the mouse target.                       |
| [is_mouse_inside](ui_element_is_mouse_inside)   | Returns whether the mouse target is an element inside this one (or itself). |
| [is_mouse_over](ui_element_is_mouse_over)       | Returns whether this element is the current mouse target.                   |

### Implementing Custom Elements

Advanced
{: .label .label-yellow}

| Name                                                      | Description                                                                                                 |
| :-------------------------------------------------------- | :---------------------------------------------------------------------------------------------------------- |
| [compute_desired_size](ui_element_compute_desired_size)   | Computes the size requested by this element for layout purposes.                                            |
| [desired_size](ui_element_desired_size)                   | Returns this element's desired size.                                                                        |
| [draw_self](ui_element_draw_self)                         | Draws this element and all its descendants.                                                                 |
| [first_focusable](ui_element_first_focusable)             | Returns the first focusable element inside this one (or itself).                                            |
| [next_focusable](ui_element_next_focusable)               | Returns the next focusable element from this one in the specified direction.                                |
| [overlaps_mouse](ui_element_overlaps_mouse)               | Returns whether this element can become the mouse target, given a specific player index and mouse position. |
| [set_relative_position](ui_element_set_relative_position) | Sets this element's position relative to its parent top-left corner.                                        |
| [transform](ui_element_transform)                         | Returns the global [Transform](https://love2d.org/wiki/Transform) in use last time this element was drawn.  |
| [update](ui_element_update)                               | Runs frame-based logic.                                                                                     |

## Callbacks

| Name                                        | Description                                                                       |
| :------------------------------------------ | :-------------------------------------------------------------------------------- |
| [on_focus](ui_element_on_focus)             | Called when this element gains focus.                                             |
| [on_mouse_enter](ui_element_on_mouse_enter) | Called when this element or one of its descendents becomes the mouse target.      |
| [on_mouse_leave](ui_element_on_mouse_leave) | Called when the mouse target is no longer this element or one of its descendents. |
| [on_mouse_out](ui_element_on_mouse_out)     | Called when this element is no longer the mouse target.                           |
| [on_mouse_over](ui_element_on_mouse_over)   | Called when this element becomes the mouse target.                                |
| [on_unfocus](ui_element_on_unfocus)         | Called when this element loses focus.                                             |
