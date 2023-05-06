---
parent: crystal.ui
grand_parent: API Reference
nav_exclude: true
---

# UIElement:is_mouse_enabled

Returns whether this element can be the mouse target, as set by [enable_mouse](ui_element_enable_mouse) / [disable_mouse](ui_element_disable_mouse).

Elements with drawing functionality like [Image](image) or [Text](text) have the mouse enabled by default.

## Usage

```lua
ui_element:is_mouse_enabled()
```

## Returns

| Name     | Type      | Description                                                          |
| :------- | :-------- | :------------------------------------------------------------------- |
| `enable` | `boolean` | True if mouse detection is enabled on this element, false otherwise. |

## Examples

```lua
local image = crystal.Image:new(crystal.assets.get("sword.png"));
image:disable_mouse();
print(image:is_mouse_enabled()); -- Prints "false"
```
