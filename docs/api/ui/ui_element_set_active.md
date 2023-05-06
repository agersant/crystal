---
parent: crystal.ui
grand_parent: API Reference
nav_exclude: true
---

# UIElement:set_active

Sets whether this element is active. Inactive elements and their descendents are not eligible for input handling, and will not have focus taken away from them by [focus_tree](ui_element_focus_tree) or [focus](ui_element_focus) calls.

An example usage for this function would be to make a menu inactive while a modal dialog on top of it requires attention. By deactivating the menu without unfocusing it, focus naturally "returns" where it was when the menu becomes interactive again.

## Usage

```lua
ui_element:set_active(active)
```

### Arguments

| Name     | Type      | Description                           |
| :------- | :-------- | :------------------------------------ |
| `active` | `boolean` | Whether the element should be active. |

## Examples

```lua
local menu = crystal.Overlay:new();
menu:set_active(false);
print(menu:is_active()); -- Prints "false"
```
