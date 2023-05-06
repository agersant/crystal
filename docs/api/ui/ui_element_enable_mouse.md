---
parent: crystal.ui
grand_parent: API Reference
nav_exclude: true
---

# UIElement:enable_mouse

Allows this element to be the mouse target when hovered. This does not affect the element's descendents. Similar to [set_focusable](ui_element_set_focusable), this is meant to describe the nature of the element and not its current state.

To temporarily allow or prevent mouse detection on an element, see [set_active](ui_element_set_active).

Elements with drawing functionality like [Image](image) or [Text](text) have the mouse enabled by default.

## Usage

```lua
ui_element:enable_mouse()
```

## Examples

```lua
local my_button = crystal.Overlay:new();
my_button:enable_mouse();
my_button.on_mouse_over = function()
 print("Mouse over button");
end
```
