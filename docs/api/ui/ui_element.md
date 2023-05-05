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

| Name            | Description |
| :-------------- | :---------- |
| [update_tree]() |             |
| [update]()      |             |

### Element Hierarchy

| Name                   | Description |
| :--------------------- | :---------- |
| [depth]()              |             |
| [is_root]()            |             |
| [is_within]()          |             |
| [joint]()              |             |
| [parent]()             |             |
| [remove_from_parent]() |             |
| [root]()               |             |

### Layout

| Name                     | Description |
| :----------------------- | :---------- |
| [compute_desired_size]() |             |
| [desired_size]()         |             |
| [layout]()               |             |
| [relative_position]()    |             |
| [size]()                 |             |

### Rendering

| Name                  | Description |
| :-------------------- | :---------- |
| [color]()             |             |
| [draw_self]()         |             |
| [draw]()              |             |
| [opacity]()           |             |
| [scale]()             |             |
| [set_color]()         |             |
| [set_opacity]()       |             |
| [set_scale_x]()       |             |
| [set_scale_y]()       |             |
| [set_scale]()         |             |
| [set_translation_x]() |             |
| [set_translation_y]() |             |
| [set_translation]()   |             |
| [translation]()       |             |

### Input Handling

| Name                  | Description |
| :-------------------- | :---------- |
| [active_bindings]()   |             |
| [bind_input]()        |             |
| [can_receive_input]() |             |
| [first_focusable]()   |             |
| [focus_tree]()        |             |
| [focus]()             |             |
| [handle_input]()      |             |
| [is_active]()         |             |
| [is_focusable]()      |             |
| [is_focused]()        |             |
| [next_focusable]()    |             |
| [player_index]()      |             |
| [set_active]()        |             |
| [set_focusable]()     |             |
| [set_player_index]()  |             |
| [unbind_input]()      |             |
| [unfocus_tree]()      |             |

### Mouse Interactions

| Name                 | Description |
| :------------------- | :---------- |
| [disable_mouse]()    |             |
| [enable_mouse]()     |             |
| [is_mouse_enabled]() |             |
| [is_mouse_inside]()  |             |
| [is_mouse_over]()    |             |
| [overlaps_mouse]()   |             |

## Callbacks

| Name               | Description |
| :----------------- | :---------- |
| [on_mouse_enter]() |             |
| [on_mouse_leave]() |             |
| [on_mouse_out]()   |             |
| [on_mouse_over]()  |             |

## Examples
