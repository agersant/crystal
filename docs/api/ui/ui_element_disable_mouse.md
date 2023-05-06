---
parent: crystal.ui
grand_parent: API Reference
nav_exclude: true
---

# UIElement:disable_mouse

Prevents this element from being the mouse target. This does not affect the element's descendents. Similar to [set_focusable](ui_element_set_focusable), this is meant to describe the nature of the element and not its current state.

To temporarily allow or prevent mouse detection on an element, see [set_active](ui_element_set_active).

Elements with drawing functionality like [Image](image) or [Text](text) have the mouse enabled by default.

## Usage

```lua
ui_element:disable_mouse()
```

## Examples

```lua
local image = crystal.Image:new(crystal.assets.get("sword.png"));
image:disable_mouse();
print(image:is_mouse_enabled()); -- Prints "false"
```
