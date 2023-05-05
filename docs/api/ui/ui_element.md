---
parent: crystal.ui
grand_parent: API Reference
nav_order: 2
---

# crystal.UIElement

Base class for all UI building blocks.

## Constructor

```lua
crystal.UIElement:new()
```

## Methods

### Lifecycle

| Name            | Description                                                                     |
| :-------------- | :------------------------------------------------------------------------------ |
| [update_tree]() | Computes layout and runs update logic for this element and all its descendants. |
| [draw_tree]()   | Draws this element and all its descendants.                                     |

### Element Hierarchy

| Name                   | Description                                                                              |
| :--------------------- | :--------------------------------------------------------------------------------------- |
| [is_root]()            | Returns whether this element is the root of its element tree.                            |
| [is_within]()          | Returns whether this element is a descendant of another one.                             |
| [joint]()              | Returns the [joint](joint) specifying how this element should be laid out by its parent. |
| [parent]()             | Returns this element's parent.                                                           |
| [remove_from_parent]() | Removes this element from its parent.                                                    |
| [root]()               | Returns the root of this element's tree.                                                 |

### Layout

| Name     | Description                                                                 |
| :------- | :-------------------------------------------------------------------------- |
| [size]() | Returns this element's size, as computed during [update_tree](update_tree). |

### Rendering

| Name                  | Description                                    |
| :-------------------- | :--------------------------------------------- |
| [color]()             | Returns this element's color multiplier.       |
| [opacity]()           | Returns this element's opacity.                |
| [scale]()             | Returns this element's scaling factors.        |
| [set_color]()         | Sets this element's color multiplier.          |
| [set_opacity]()       | Sets this element's opacity.                   |
| [set_scale_x]()       | Sets this element's horizontal scaling factor. |
| [set_scale_y]()       | Sets this element's vertical scaling factor.   |
| [set_scale]()         | Sets this element's scaling factors.           |
| [set_translation_x]() | Sets this element's horizontal translation.    |
| [set_translation_y]() | Sets this element's vertical translation.      |
| [set_translation]()   | Sets this element's translation.               |
| [translation]()       | Returns this element's translation.            |

### Input Handling

| Name                  | Description                                                              |
| :-------------------- | :----------------------------------------------------------------------- |
| [active_bindings]()   | Returns a table of active input bindings within this element.            |
| [bind_input]()        | Binds an input action to a callback function.                            |
| [can_receive_input]() | Returns whether this element can currently receive input actions.        |
| [focus_tree]()        | Gives focus to the first focusable element within this one.              |
| [focus]()             | Gives focus to this element.                                             |
| [focused_element]()   | Returns a focused element within this one.                               |
| [handle_input]()      | Executes bindings bound to an input action.                              |
| [is_active]()         | Returns whether this element is active.                                  |
| [is_focusable]()      | Returns whether this element is focusable.                               |
| [is_focused]()        | Returns whether this element is currently focused.                       |
| [player_index]()      | Returns which player is allowed to focus or emit inputs to this element. |
| [set_active]()        | Sets whether this element is active.                                     |
| [set_focusable]()     | Sets whether this element is focusable.                                  |
| [set_player_index]()  | Sets or clears which is allowed to focus or emit inputs to this element. |
| [unbind_input]()      | Removes a previously bound input callback.                               |
| [unfocus_tree]()      | Unfocuses all elements within this one.                                  |

### Mouse Interactions

| Name                 | Description                                                        |
| :------------------- | :----------------------------------------------------------------- |
| [disable_mouse]()    | Prevents this element from being a mouse target .                  |
| [enable_mouse]()     | Allow this element to be the mouse target when hovered.            |
| [is_mouse_enabled]() | Returns whether this element can be the mouse target.              |
| [is_mouse_inside]()  | Returns whether the mouse target is currently inside this element. |
| [is_mouse_over]()    | Returns whether this element is currently the mouse target.        |

### Implementing Custom Elements

Advanced
{: .label .label-yellow}

| Name                      | Description                                                                                    |
| :------------------------ | :--------------------------------------------------------------------------------------------- |
| [compute_desired_size]()  | Computes the size requested by this elementfor layout purposes.                                |
| [desired_size]()          | Returns this element's desired size.                                                           |
| [draw_self]()             | Draws this element and its descendants.                                                        |
| [first_focusable]()       | Returns the first focusable element inside this one.                                           |
| [next_focusable]()        | Returns the next focusable element from this one in the specified direction.                   |
| [overlaps_mouse]()        | Returns whether can become the mouse target, given a specific player index and mouse position. |
| [set_relative_position]() | Sets this element's left/right/top/bottom relative to its parent top-left corner.              |
| [update]()                | Runs frame-based logic.                                                                        |

## Callbacks

| Name               | Description                                                                       |
| :----------------- | :-------------------------------------------------------------------------------- |
| [on_focused]()     | Called when this element gains focus.                                             |
| [on_mouse_enter]() | Called when this element or one of its descendents becomes the mouse target.      |
| [on_mouse_leave]() | Called when the mouse target is no longer this element or one of its descendents. |
| [on_mouse_out]()   | Called when this element is no longer the mouse target.                           |
| [on_mouse_over]()  | Called when this element becomes the mouse target.                                |
| [on_unfocused]()   | Called when this element loses focus.                                             |

## Examples
